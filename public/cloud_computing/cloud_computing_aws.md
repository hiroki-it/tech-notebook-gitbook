# AWS：Amazon Web Service

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. ALB：Application Load Balancing

### ALBとは

クラウドリバースプロキシサーバ，かつクラウドロードバランサーとして働く．リクエストを代理で受信し，インスタンスへのアクセスをバランスよく分配することによって，サーバへの負荷を緩和する．

![ALBの機能](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ALBの機能.png)

<br>

### 設定項目

#### ・概要

| 設定項目             | 説明                                                         | 補足                                                         |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| リスナー             | ALBに割り振るポート番号お，受信するプロトコルを設定する．リバースプロキシかつロードバランサ－として，これらの通信をターゲットグループにルーティングする． |                                                              |
| セキュリティポリシー | リクエストの送信者が使用するSSL/TLSプロトコルや暗号化方式のバージョンに合わせて，ALBが受信できるこれらのバージョンを設定する． | ・リクエストの送信者には，ブラウザ，APIにリクエストを送信する外部サービス，転送元のAWSリソース（CloudFrontなど），などを含む．<br/>・参考：https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies |
| ルール               | リクエストのルーティングのロジックを設定する．               |                                                              |
| ターゲットグループ   | ルーティング時に使用するプロトコルと，ルーティング先のアプリケーションに割り当てられたポート番号を指定する． | ターゲットグループ内のターゲットのうち，トラフィックはヘルスチェックがOKになっているターゲットにルーティングされる． |
| ヘルスチェック       | ターゲットグループに属するプロトコルとアプリケーションのポート番号を指定して，定期的にリクエストを送信する． |                                                              |

#### ・ターゲットグループ

| ターゲットの指定方法 | 補足                                                         |
| -------------------- | ------------------------------------------------------------ |
| インスタンス         | ターゲットが，EC2でなければならない．                        |
| IPアドレス           | ターゲットのパブリックIPアドレスが，静的でなければならない． |
| Lambda               | ターゲットが，Lambdaでなければならない．                     |

<br>

### ルール

#### ・ルールの設定例

| ユースケース                                                 | ポート    | IF                                             | THEN                                                         |
| ------------------------------------------------------------ | --------- | ---------------------------------------------- | ------------------------------------------------------------ |
| リクエストがポート```80```を指定した時に，```443```にリダイレクトしたい． | ```80```  | それ以外の場合はルーティングされないリクエスト | リダイレクト先：```https://#{host}:443/#{path}?#{query}```<br>ステータスコード：```HTTP_301``` |
| リクエストがポート```443```を指定した時に，ターゲットグループに転送したい． | ```443``` | それ以外の場合はルーティングされないリクエスト | 特定のターゲットグループ                                     |

<br>

### Webサーバ，アプリケーションにおける対応

#### ・問題

ALBからEC2へのルーティングをHTTPプロトコルとした場合，アプリケーション側で，HTTPSプロトコルを用いた処理ができなくなる．そこで，クライアントからALBに対するリクエストのプロトコルがHTTPSだった場合，Webサーバまたはアプリケーションにおいて，ルーティングのプロトコルをHTTPSと見なすように対処する．

![ALBからEC2へのリクエストのプロトコルをHTTPSと見なす](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ALBからEC2へのリクエストのプロトコルをHTTPSと見なす.png)

#### ・Webサーバにおける対処方法

ALBを経由したリクエストの場合，リクエストヘッダーに```X-Forwarded-Proto```ヘッダーが付与される．これには，ALBに対するリクエストのプロトコルの種類が，文字列で代入されている．これが『HTTPS』だった場合，WebサーバへのリクエストをHTTPSであるとみなすように対処する．これにより，アプリケーションへのリクエストのプロトコルがHTTPSとなる（こちらを行った場合は，以降のアプリケーション側の対応不要）．

**＊実装例＊**

```apacheconf
SetEnvIf X-Forwarded-Proto https HTTPS=on
```

#### ・アプリケーションにおける対処方法

ALBを経由したリクエストの場合，リクエストヘッダーに```HTTP_X_FORWARDED_PROTO```ヘッダーが付与される．これには，ALBに対するリクエストのプロトコルの種類が．文字列で代入されている．これが『HTTPS』だった場合，アプリケーションへのリクエストをHTTPSであるとみなすように，```index.php```に追加実装を行う．

**＊実装例＊**


```php
<?php
    
// index.php
if (isset($_SERVER["HTTP_X_FORWARDED_PROTO"])
    && $_SERVER["HTTP_X_FORWARDED_PROTO"] == "https") {
    $_SERVER["HTTPS"] = "on";
}
```

<br>

### その他の留意事項

#### ・割り当てられるプライベートIPアドレス範囲

ALBに割り当てられるIPアドレス範囲には，VPCのものが適用される．そのため，EC2のSecurity Groupでは，VPCのIPアドレス範囲を許可するように設定する必要がある．

#### ・ALBのセキュリティグループ

Route53から転送されるパブリックIPアドレスを受信できるようにしておく必要がある．パブリックネットワークに公開するWebサイトであれば，IPアドレスは全ての範囲（```0.0.0.0/0```と``` ::/0```）にする．社内向けのWebサイトであれば，社内のプライベートIPアドレスのみ（```n.n.n.n/32```）を許可するようにする．

<br>

## 02. Amplify

### Amplifyとは

サーバレスアプリケーションを構築するためのクラウドインフラストラクチャのフレームワーク．SSGの場合，静的ファイルをデプロイしさえすれば，アプリケーションとしての要件が全て整う．SPAの場合，サーバレスのバックエンドを自動構築してくれ，フロントエンドをデプロイしさえすれば，要件が全て整う．これのAWSリソースはCloudFormationによって構築されるが，Amplify経由でしか設定を変更できず，各AWSリリースのコンソール画面を見ても，非表示になっている．ただし，Route53の設定は表示されており，Amplifyが追加したレコードをユーザが編集できるようになっている．

参考：https://d1.awsstatic.com/webinars/jp/pdf/services/20200520_AWSBlackBelt_Amplify_A.pdf

| 役割                   | 使用されているAWSリソース    |
| ---------------------- | ---------------------------- |
| 認証                   | Gognito                      |
| 静的サイトホスティング | CloudFront，S3               |
| API                    | API Gateway，AppSync GraphQL |
| バックエンドロジック   | Lambda                       |
| DB                     | DynamoDB                     |
| ストレージ             | S3                           |
| 全文検索               | Elastic Search               |
| リアルタイム通知       | AppSync，IoT Core            |

<br>

### 設定項目

| 項目                 | 説明                             | 補足                                                         |
| -------------------- | -------------------------------- | ------------------------------------------------------------ |
| 本番稼働ブランチ     | 基点ブランチを設定する．         | Amplifyを本番運用しない場合は，developブランチを設定すればよい． |
| Branch autodetection | ブランチの自動検出を有効化する． | ワイルドカードを組み込む場合，アスタリスクを二つ割り当てないと，ブランチが検知されないことがある． |
|                      |                                  |                                                              |

<br>

### 手動ビルド＆デプロイ

#### ・開発環境で擬似再現

サーバレスアプリケーションを開発環境で再現する．

```bash
$ amplify mock api
```

#### ・開発環境から直接ビルド&デプロイ

開発／ステージング／本番環境に切り替える必要がある．

```bash
# アプリケーションの設定
$ amplify add hosting

# ビルド&デプロイ
$ amplify publish
```

<br>

### 自動ビルド&デプロイ

#### ・連携可能なバージョン管理システム

参考：https://docs.aws.amazon.com/ja_jp/amplify/latest/userguide/getting-started.html#step-1-connect-repository

#### ・対応するリポジトリ構造

| 種類             | ビルド開始ディレクトリ                         |
| ---------------- | ---------------------------------------------- |
| 非モノリポジトリ | リポジトリ名からなるディレクトリ               |
| モノリポジトリ   | モノリポジトリの各アプリケーションディレクトリ |

#### ・amplify.ymlファイル

リポジトリのルートに```amplify.yml```ファイルを配置する．Next.jsではSSG／SSRの両モードでビルド＆デプロイが可能である．```package.json```ファイルで使用される```next```コマンドに応じて，SSGまたはSSRのいずれかのインフラが構築され，デプロイされる．SSGの場合，裏側ではS3，CloudFront，Route53などが構築され，静的ホスティングが実行される．SSRの場合，フロントエンドだけでなくバックエンドの稼働環境が必要になるため，LambdaやCogniteが構築される．

参考：

- https://docs.aws.amazon.com/ja_jp/amplify/latest/userguide/build-settings.html
- https://docs.aws.amazon.com/ja_jp/amplify/latest/userguide/server-side-rendering-amplify.html#deploy-nextjs-app

```yaml
version: 1

#=====================
# 環境変数
#===================== 
env:
  variables:
    key: # 環境変数のハードコーディング
      
#=====================      
# バックエンドのCI/CD
#===================== 
backend:
  phases:
    preBuild:
      commands:
         - # コマンド
    build:
      commands:
        - # コマンド
    postBuild:
      commands:
        - # コマンド
        
#=====================         
# フロントエンドのCI/CD
#=====================  
frontend:
  phases:
    preBuild:
      commands:
        - npm install
        # 環境変数として登録したエンコード値をデコード
        - echo $ENV | base64 -di > .env
        - cat .env
    build:
      commands:
        - nuxt generate --fail-on-error
        - ls -la ./dist
  artifacts:
    # デプロイ対象のディレクトリ  
    files:
        # 全てのディレクトリ
        - "**/*"
    discard-paths: yes
    # ビルドのアーティファクトを配置するディレクトリ 
    baseDirectory: dist
  # キャッシュとして保存するディレクトリ
  cache:
    paths:
      - node_modules/**/*
        
#=====================         
# テスト        
#===================== 
test:
  phases:
    preTest:
      commands:
        - # コマンド
    test:
      commands:
        - # コマンド
    postTest:
      commands:
        - # コマンド
  artifacts:
    # デプロイ対象のディレクトリ
    files:
        # 全てのディレクトリ
        - "**/*"
    configFilePath: *location*
    # ビルドのアーティファクトのディレクトリ      
    baseDirectory: *location*
```

<br>

## 03. API Gateway

### API Gatewayとは

異なるクライアントからのリクエストを受信して差分を吸収し，適切なAPIに振り分けられる．

![API Gatewayの仕組み](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/APIGatewayの仕組み.png)

<br>

### 設定項目

#### ・概要

API Gatewayは，メソッドリクエスト，統合リクエスト，統合レスポンス，メソッドレスポンス，から構成される．

| 設定項目                 | 説明                                                         | 補足                                                         |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| リソース                 | エンドポイント，HTTPメソッド，転送先，などを設定する．       | 構築したAWSリソースのパスが，API Gatewayのエンドポイントになる． |
| ステージ                 | API Gatewayをデプロイする環境を定義する．                    |                                                              |
| オーソライザー           | LambdaまたはCognitoによるオーソライザーを使用して，認可プロセスを定義する． |                                                              |
| ゲートウェイのレスポンス |                                                              |                                                              |
| モデル                   | リクエスト／レスポンスのスキーマを設定する．これらのバリデーションのために使用できる． | OpenAPI仕様におけるスキーマについては，以下のリンクを参考にせよ．<br>参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_api_restful.html |
| リソースポリシー         | ポリシーを使用して，API Gatewayにセキュリティを定義づける．  |                                                              |
| ドキュメント             |                                                              |                                                              |
| ダッシュボード           |                                                              |                                                              |
| APIの設定                |                                                              |                                                              |
| 使用量プラン             | 有料サービスとしてAPIを公開し，料金体系に応じてリクエスト量を制限するために使用する．APIキーにリクエスト量のレートを設定する． | 有料サービスとして使用しないAPIの場合は，レートを設定する必要はない． |
| APIキー                  | APIキー認証を設定する．                                      | ・その他のアクセス制御の方法として，以下がある．<br>参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/apigateway-control-access-to-api.html<br>・APIキー認証については，以下のリンクを参考にせよ．<br>参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/frontend_and_backend_authentication_authorization.html |
| クライアント証明書       | SSLサーバ証明書をAPI Gatewayに割り当てる．                   | APIが，API Gatewayから転送されたリクエストであること識別できるようになる． |
| CloudWatchログの設定     | API GatewayがCloudWatchログにアクセスできるよう，ロールを設定する． | 一つのAWS環境につき，一つのロールを設定すればよい．          |

<br>

### リソース

#### ・リソース

| 順番 | 処理               | 説明                                                         | 補足                                                         |
| ---- | ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | メソッドリクエスト | クライアントから送信されたデータのうち，実際に転送するデータのフィルタリングを行う． |                                                              |
| 2    | 統合リクエスト     | メソッドリクエストから転送された各データを，マッピングテンプレートのJSONに紐づける． |                                                              |
| 3    | 統合レスポンス     |                                                              | 統合リクエストでプロキシ統合を使用する場合，統合レスポンスを使用できなくなる． |
| 4    | メソッドレスポンス | レスポンスが成功した場合，クライアントに送信するステータスコードを設定する． |                                                              |

#### ・メソッドリクエスト

| 設定項目                  | 説明                                                         | 補足                                                         |
| ------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 認可                      | 定義したLambdaまたはCognitoによるオーソライザーを有効化する． |                                                              |
| リクエストの検証          | 『URLクエリ文字列パラメータ』『HTTPリクエストヘッダー』『リクエスト本文』のバリデーションを有効化する． |                                                              |
| APIキーの必要性           | リクエストヘッダーにおけるAPIキーのバリデーションを行う．リクエストのヘッダーに『```x-api-key```』を含み，これにAPIキーが割り当てられていることを強制する． | ヘッダー名は大文字でも小文字でも問題ないが，小文字が推奨．<br>参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_api_restful.html |
| URLクエリ文字列パラメータ | リクエストされたURLのクエリパラメータのバリデーションを行う． |                                                              |
| HTTPリクエストヘッダー    | リクエストヘッダーのバリデーションを行う．                   |                                                              |
| リクエスト本文            | リクエストボディのバリデーションを行う．                     |                                                              |
| SDK設定                   |                                                              |                                                              |

#### ・統合リクエスト

| 設定項目                  | 説明                                                         | 補足                                   |
| ------------------------- | ------------------------------------------------------------ | -------------------------------------- |
| 統合タイプ                | リクエストの転送先を設定する．                               |                                        |
| URLパスパラメータ         | メソッドリクエストから転送されたデータを，API Gatewayから転送するリクエストのパスパラメータに紐づける．または紐づけずに，新しいデータを転送しても良い． |                                        |
| URLクエリ文字列パラメータ | メソッドリクエストから転送されたデータを，API Gatewayから転送するリクエストのクエリパラメータに紐づける．または紐づけずに，新しいデータを転送しても良い． |                                        |
| HTTPヘッダー              | メソッドリクエストから転送されたデータを，API Gatewayから転送するリクエストのヘッダーに紐づける．または紐づけずに，新しいデータを転送しても良い． | 値はシングルクオートで囲う必要がある． |
| マッピングテンプレート    | メソッドリクエストから転送されたデータを，API Gatewayから転送するリクエストのメッセージボディに紐づける．または紐づけずに，新しいデータを転送しても良い． |                                        |

#### ・テスト

| 設定項目       | 設定例              | 補足                                         |
| -------------- | ------------------- | -------------------------------------------- |
| クエリ文字     |                     |                                              |
| ヘッダー       | X-API-Token: test   | 波括弧，スペース，クオーテーションは不要．   |
| リクエスト本文 | ```{test:"test"}``` | 改行タグやスペースが入り込まないようにする． |

#### ・OpenAPI仕様のインポート

以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws_apigateway_import.html

#### ・CORSの有効化

CORSを有効化し，異なるオリジンによって表示されたページからのリクエストを許可する．以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/how-to-cors.html

<br>

### プライベート統合

#### ・プライベート統合とは

API GatewayとVPCリンクの間で，リクエスト／レスポンスのJSONデータを自動的にマッピングする機能のこと．

参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/set-up-private-integration.html

また，VPCリンクの設定によって，VPCエンドポイントサービスが構築される．VPCエンドポイントサービスについては，VPCエンドポイントサービスの説明を参考にせよ．

| 設定項目                     | 説明                                                  |
| ---------------------------- | ----------------------------------------------------- |
| 統合タイプ                   | VPCリンクを選択する．                                 |
| プロキシ統合の使用           | VPCリンクとのプロキシ統合を有効化する．               |
| メソッド                     | HTTPメソッドを設定する．                              |
| VPCリンク                    | VPCリンク名を設定する．                               |
| エンドポイントURL            | NLBのDNS名をドメイン名として，転送先のURLを設定する． |
| デフォルトタイムアウトの使用 |                                                       |

#### ・メソッドリクエストと統合リクエストのマッピング

<br>

### Lambdaプロキシ統合

#### ・Lambdaプロキシ統合とは

API GatewayとLambdaの間で，リクエスト／レスポンスのJSONデータを自動的にマッピングする機能のこと．プロキシ統合を使用すると，Lambdaに送信されたリクエストはハンドラ関数のeventオブジェクトに代入される．プロキシ統合を使用しない場合，LambdaとAPI Gatewayの間のマッピングを手動で行う必要がある．

参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/set-up-lambda-integrations.html

| 設定項目                     | 説明                                                         |
| ---------------------------- | ------------------------------------------------------------ |
| 統合タイプ                   | Lambda関数を選択する．                                       |
| Lambdaプロキシ統合の使用     | Lambdaとのプロキシ統合を有効化する．                         |
| Lambdaリージョン             | 実行したLambda関数のリージョンを設定する．                   |
| Lambda関数                   | 実行したLambda関数の名前を設定する．                         |
| 実行ロール                   | 実行したいLambda関数へのアクセス権限がアタッチされたロールのARNを設定する．ただし，Lambda側にAPI Gatewayへのアクセス権限をアタッチしてもよい． |
| 認証情報のキャッシュ         |                                                              |
| デフォルトタイムアウトの使用 |                                                              |

#### ・リクエスト時のマッピング

API Gateway側でプロキシ統合を有効化すると，API Gatewayを経由したクライアントからのリクエストは，ハンドラ関数のeventオブジェクトのJSONデータにマッピングされる．

```bash
{
    "resource": "Resource path",
    "path": "Path parameter",
    "httpMethod": "Incoming request's method name",
    "headers": {
        String
        containing
        incoming
        request
        headers
    },
    "multiValueHeaders": {
        List
        of
        strings
        containing
        incoming
        request
        headers
    },
    "queryStringParameters": {
        query
        string
        parameters
    },
    "multiValueQueryStringParameters": {
        List
        of
        query
        string
        parameters
    },
    "pathParameters": {
        path
        parameters
    },
    "stageVariables": {
        Applicable
        stage
        variables
    },
    "requestContext": {
        Request
        context,
        including
        authorizer-returned
        key-value
        pairs
    },
    "body": "A JSON string of the request payload.",
    "isBase64Encoded": "A boolean flag to indicate if the applicable request payload is Base64-encoded"
}

```

#### ・レスポンス時のマッピング

API Gatewayは，Lambdaからのレスポンスを，以下のJSONデータにマッピングする．これ以外の構造のJSONデータを送信すると，API Gatewayで『```Internal Server Error```』のエラーが起こる．

```bash
{
    "isBase64Encoded": true
    |
    false,
    "statusCode": httpStatusCode,
    "headers": {
        "headerName": "headerValue",
        ...
    },
    "multiValueHeaders": {
        "headerName": [
            "headerValue",
            "headerValue2",
            ...
        ],
        ...
    },
    "body": "Hello Lambda"
}
```

API Gatewayは上記のJSONデータを受信した後，```body```のみ値をレスポンスのメッセージボディに持たせ，クライアントに送信する．

```
"Hello Lambda"
```

<br>

### ステージ

#### ・設定

| 設定項目                           | 説明                                                         |
| ---------------------------------- | ------------------------------------------------------------ |
| キャッシュ設定                     | 参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-caching.html |
| デフォルトのメソッドスロットリング | １秒当たりのリクエスト数制限を設定する．<br>参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-request-throttling.html |
| WAF                                | 参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/apigateway-control-access-aws-waf.html |
| クライアント証明書                 | 関連付けるWAFを設定する．                                    |

#### ・ログ／分散トレース

| 設定項目                   | 説明                                                         |
| -------------------------- | ------------------------------------------------------------ |
| CloudWatch設定             | CloudWatchログにAPI Gatewayの実行ログを送信するかどうかを設定する．<br>参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/set-up-logging.html |
| カスタムアクセスのログ記録 | CloudWatchログにAPI Gatewayのアクセスログを送信するかどうかを設定する．<br>参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/set-up-logging.html |
| X-Ray分散トレース      | 参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/apigateway-xray.html |

#### ・ステージ変数

デプロイされるステージ固有の環境変数を設定できる．Lambda関数名，エンドポイントURL，パラメータマッピング，マッピングテンプレートで値を出力できる．以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/aws-api-gateway-stage-variables-reference.html

#### ・SDKの生成

#### ・Canary

| 設定項目                                   | 説明 |
| ------------------------------------------ | ---- |
| ステージのリクエストディストリビューション |      |
| Canaryのデプロイ                           |      |
| Canaryステージ変数                         |      |
| キャッシュ                                 |      |

<br>

### APIの設定

#### ・エンドポイントタイプ

参考：https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-api-endpoint-types.html

| 種類         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| リージョン   | API Gatewayのエンドポイントへのリクエストを，リージョン内の物理サーバで受け付ける． |
| プライベート | API Gatewayのエンドポイントへのリクエストを，VPC内からのみ受け付ける． |
| エッジ最適化 | API Gatewayのエンドポイントへのリクエストを，CloudFrontのエッジサーバで受け付ける． |

<br>

## 04. Auto Scaling

### Auto Scalingとは

アプリケーションのメトリクスの閾値を基準として，自動水平スケーリングを自動的に実行する．

![Auto-scaling](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Auto-scaling.png)

<br>

### 設定項目

#### ・起動設定

スケーリングの対象となるAWSリソースを定義する．

#### ・スケーリンググループ

スケーリングのグループ構成を定義する．各グループで最大最小必要数を設定できる．

#### ・スケーリングポリシー

スケーリングの方法を定義する．

| 種類                       | 説明                                                         | 補足                                                         |
| -------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| シンプルスケーリング       | 特定のメトリクスに単一の閾値を設定し，それに応じてスケーリングを行う． |                                                              |
| ステップスケーリング       | 特定のメトリクスに段階的な閾値を設定し，それに応じて段階的にスケーリングを実行する． | （例）CPU平均使用率に段階的な閾値を設定する．<br>・40%の時にインスタンスが１つスケールアウト<br>・70%の時にインスタンスを２つスケールアウト<br>・90%の時にインスタンスを３つスケールアウト |
| ターゲット追跡スケーリング | 特定のメトリクス（CPU平均使用率やMemory平均使用率）にターゲット値を設定し，それに収束するように自動的にスケールインとスケールアウトを実行する． | ターゲット値を設定できるリソースの例<br>・ECSサービスのタスク数<br>・RDSクラスターのAuroraのリードレプリカ数<br>・Lambdaのスクリプト同時実行数 |

<br>

## 05. Certificate Manager

### 設定項目

| 設定項目   | 説明                                       |
| ---------- | ------------------------------------------ |
| ドメイン名 | 認証をリクエストするドメイン名を設定する． |
| 検証の方法 | DNS検証かEmail検証かを設定する．           |

<br>

### 認証局

認証局であるATSによって認証されたSSLサーバ証明書を管理できる．

| 自社の中間認証局名         | ルート認証局名 |
| -------------------------- | -------------- |
| ATS：Amazon Trust Services | Starfield社    |

<br>

### ドメインの承認方法

#### ・DNS検証

CNAMEレコードランダムトークンを用いて，ドメイン名の所有者であることを証明する方法．ACMによって生成されたCNAMEレコードランダムトークンが提供されるので，これをRoute53に設定しておけば，ACMがこれを検証し，証明書を発行してくれる．

<br>

### 証明書

#### ・セキュリティポリシー

許可するプロトコルを定義したルールこと．SSL/TLSプロトコルを許可しており，対応できるバージョンが異なるため，ブラウザがそのバージョンのSSL/TLSプロトコルを使用できるかを認識しておく必要がある．

|                      | Policy-2016-08 | Policy-TLS-1-1 | Policy-TLS-1-2 |
| -------------------- | :------------: | :------------: | :------------: |
| **Protocol-TLSv1**   |       〇       |       ✕        |       ✕        |
| **Protocol-TLSv1.1** |       〇       |       〇       |       ✕        |
| **Protocol-TLSv1.2** |       〇       |       〇       |       〇       |

#### ・SSLサーバ証明書の種類

DNS検証またはEメール検証によって，ドメイン名の所有者であることが証明されると，発行される．証明書は，PKIによる公開鍵検証に用いられる．

| 証明書の種類         | 説明                                             |
| -------------------- | ------------------------------------------------ |
| ワイルドカード証明書 | 証明するドメイン名にワイルドカードを用いたもの． |

#### ・SSLサーバ証明書の設置場所パターン

AWSの使用上，ACM証明書を設置できないAWSリソースに対しては，外部の証明書を手に入れて設置する．HTTPSによるSSLプロトコルを受け付けるネットワークの最終地点のことを，SSLターミネーションという．

| パターン<br>（Route53には必ず設置）                      | SSLターミネーション<br>（HTTPSの最終地点） | 補足                                                         |
| -------------------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------ |
| Route53 → ALB(+ACM証明書) → EC2                          | ALB                                        |                                                              |
| Route53 → CloudFront(+ACM証明書) → ALB(+ACM証明書) → EC2 | ALB                                        | CloudFrontはバージニア北部で，またALBは東京リージョンで，証明書を構築する必要がある．CloudFrontに送信されたHTTPSリクエストをALBにルーティングするために，両方に関連付ける証明書で承認するドメインは，一致させる必要がある． |
| Route53 → CloudFront(+ACM証明書) → EC2                   | CloudFront                                 |                                                              |
| Route53 → CloudFront(+ACM証明書) → S3                    | CloudFront                                 |                                                              |
| Route53 → ALB(+ACM証明書) → EC2(+外部証明書)             | EC2                                        |                                                              |
| Route53 → NLB → EC2(+外部証明書)                         | EC2                                        |                                                              |
| Route53 → EC2(+外部証明書)                               | EC2                                        |                                                              |
| Route53 → Lightsail(+ACM証明書)                          | Lightsail                                  |                                                              |

<br>

### 証明書の確認方法

#### ・ブラウザからの確認

Chromeを例に挙げると，SSLサーバ証明書はURLの鍵マークから確認できる．

**＊例＊**

CircleCIのサイトは，SSLサーバ証明書のためにACMを使用している．

![ssl_certificate_chrome](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ssl_certificate_chrome.png)

<br>

## 06. Chatbot

### Chatbotとは

SNSを経由して，CloudWatchからの通知をチャットアプリに転送するAWSリソース．

![ChatbotとSNSの連携](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ChatbotとSNSの連携.png)

<br>

### 設定項目

#### ・slack通知の場合

クライアントをSlackとした場合の設定を以下に示す．

| 設定項目        | 説明                                                         |
| --------------- | ------------------------------------------------------------ |
| Slackチャンネル | 通知の転送先のSlackチャンネルを設定する．                    |
| アクセス許可    | SNSを介して，CloudWatchにアクセスするためのロールを設定する． |
| SNSトピック     | CloudWatchへのアクセス時経由する，SNSトピックを設定する．    |

#### ・サポート対象のイベント

AWSリソースのイベントを，EventBridge（CloudWatchイベント）を用いて，Chatbotに転送できるが，全てのAWSリソースをサポートしているわけではない．サポート対象のAWSリソースは以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/chatbot/latest/adminguide/related-services.html#cloudwatchevents

#### ・インシデント

４大シグナルを含む，システム的に良くない事象のこと．

#### ・オンコール

インシデントを通知するようにし，通知を受けて対応すること．

<br>

## 07. CloudFront

### CloudFrontとは

クラウドリバースプロキシサーバとして働く．VPCの外側（パブリックネットワーク）に設置されている．オリジンサーバ（コンテンツ提供元）をS3とした場合，動的コンテンツへのリクエストをEC2に振り分ける．また，静的コンテンツへのリクエストをCacheし，その上でS3へ振り分ける．次回以降の静的コンテンツのリンクエストは，CloudFrontがレンスポンスを行う．

![AWSのクラウドデザイン一例](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/CloudFrontによるリクエストの振り分け.png)

### 設定項目

#### ・概要

| 設定項目            | 説明 |
| ------------------- | ---- |
| Distributions       |      |
| Reports & analytics |      |

<br>

### Distributions

#### ・Distributions

[参考になったサイト](https://www.geekfeed.co.jp/geekblog/wordpress%E3%81%A7%E6%A7%8B%E7%AF%89%E3%81%95%E3%82%8C%E3%81%A6%E3%81%84%E3%82%8B%E3%82%A6%E3%82%A7%E3%83%96%E3%82%B5%E3%82%A4%E3%83%88%E3%81%ABcloudfront%E3%82%92%E7%AB%8B%E3%81%A6%E3%81%A6%E9%AB%98/)

| 設定項目                 | 説明                                                         | 補足 |
| ------------------------ | ------------------------------------------------------------ | ---- |
| General                  |                                                              |      |
| Origin and Origin Groups | コンテンツを提供するAWSリソースを設定する．                  |      |
| Behavior                 | オリジンにリクエストが行われた時のCloudFrontの挙動を設定する． |      |
| ErrorPage                | 指定したオリジンから，指定したファイルのレスポンスを返信する． |      |
| Restriction              |                                                              |      |
| Invalidation             | CloudFrontに保存されているCacheを削除できる．                |      |

#### ・General

| 設定項目            | 説明                                                         | 補足                                                         |
| ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Price Class         | 使用するエッジロケーションを設定する．                       | Asiaが含まれているものを選択．                               |
| AWS WAF             | CloudFrontに紐づけるWAFを設定する．                          |                                                              |
| CNAME               | CloudFrontのデフォルトドメイン名（```xxxxx.cloudfront.net.```）に紐づけるRoute53レコード名を設定する． | ・Route53からルーティングする場合は必須．<br>・複数のレコード名を設定できる． |
| SSL Certificate     | HTTPSプロトコルでオリジンに転送する場合に設定する．          | 上述のCNAMEを設定した場合，SSL証明書が別途必要になる．また，Certificate Managerを使用する場合，この証明書は『バージニア北部』で申請する必要がある． |
| Security Policy     | リクエストの送信者が使用するSSL/TLSプロトコルや暗号化方式のバージョンに合わせて，CloudFrontが受信できるこれらのバージョンを設定する． | ・リクエストの送信者には，ブラウザ，APIにリクエストを送信する外部サービス，転送元のAWSリソース，などを含む．<br>・参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html |
| Default Root Object | オリジンのドキュメントルートを設定する．                     | ・何も設定しない場合，ドキュメントルートは指定されず，Behaviorで明示的にルーティングする必要がある．<br>・index.htmlを設定すると，『```/```』でリクエストした時に，オリジンのルートディレクトリにある```index,html```ファイルがドキュメントルートになる． |
| Standard Logging    | CloudFrontのアクセスログをS3に生成するかどうかを設定する．   |                                                              |

#### ・Origin and Origin Groups

| 設定項目               | 説明                                                         | 補足                                                         |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Origin Domain Name     | CloudFrontをリバースプロキシとして，AWSリソースのエンドポイントやDNSにルーティングする． | ・例えば，S3のエンドポイント，ALBのDNS名を設定する．<br>・別アカウントのAWSリソースのDNS名であってもよい． |
| Origin Path            | オリジンのルートディレクトリを設定する．                     | ・何も設定しないと，デフォルトは『```/```』のなる．Behaviorでは，『```/```』の後にパスが追加される．<br>・『```/var/www/app```』を設定すると，Behaviorで設定したパスが『```/var/www/app/xxxxx```』のように追加される． |
| Origin Access Identity | リクエストの転送先となるAWSリソースでアクセス権限のアタッチが必要な場合に設定する．転送先のAWSリソースでは，アクセスポリシーをアタッチする． | CloudFrontがS3に対して読み出しを行うために必要．             |
| Origin Protocol Policy | リクエストの転送先となるAWSリソースに対して，HTTPとHTTPSのいずれのプロトコルで転送するかを設定する． | ・ALBで必要．ALBのリスナーのプロトコルに合わせて設定する．<br>・```HTTP Only```：HTTPで転送<br/>・```HTTPS Only```：HTTPSで転送<br/>・```Match Viewer```：両方で転送 |
| HTTPポート             | 転送時に指定するオリジンのHTTPのポート番号                   |                                                              |
| HTTPSポート            | 転送時に指定するオリジンのHTTPSのポート番号                  |                                                              |

#### ・Behavior

何に基づいたCacheを行うかについては，★マークの項目で制御できる．★マークで，各項目の全て値が，過去のリクエストに合致した時のみ，そのリクエストと過去のものが同一であると見なす仕組みになっている．キャッシュ判定時のパターンを減らし，HIT率を改善するために，★マークで可能な限り『None』を選択した方が良い．最終的に，対象のファイルがCloudFrontのCacheの対象となっているかは，レスポンスのヘッダーに含まれる『```X-Cache:```』が『```Hit from cloudfront```』，『```Miss from cloudfront```』のどちらで，Cacheの使用の有無を判断できる．その他の改善方法は，以下リンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/cache-hit-ratio.html#cache-hit-ratio-query-string-parameters

| 設定項目                                                     | 説明                                                         | 補足                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Precedence                                                   | 処理の優先順位．                                             | 最初に構築したBehaviorが『```Default (*)```』となり，これは後から変更できないため，主要なBehaviorをまず最初に設定する． |
| Path Pattern                                                 | Behaviorを行うファイルパスを設定する．                       |                                                              |
| Origin or Origin Group                                       | Behaviorを行うオリジンを設定する．                           |                                                              |
| Viewer Protocol Policy                                       | HTTP／HTTPSのどちらを受信するか，またどのように変換して転送するかを設定 | ・```HTTP and HTTPS```：両方受信し，そのまま転送<br/>・```Redirect HTTP to HTTPS```：両方受信し，HTTPSで転送<br/>・```HTTPS Only```：HTTPSのみ受信し，HTTPSで転送 |
| Allowed HTTP Methods                                         | リクエストのHTTPメソッドのうち，オリジンへの転送を許可するものを設定 | ・パスパターンが静的ファイルへのリクエストの場合，GETのみ許可．<br>・パスパターンが動的ファイルへのリクエストの場合，全てのメソッドを許可． |
| ★Cache Based on Selected Request Headers<br>（★については表上部参考） | リクエストヘッダーのうち，オリジンへの転送を許可し，またCacheの対象とするものを設定する． | ・各ヘッダー転送の全拒否，一部許可，全許可を設定できる．<br>・全拒否：全てのヘッダーの転送を拒否し，Cacheの対象としない．動的になりやすい値をもつヘッダー（Accept-Datetimeなど）を一切使用せずに，それ以外のクエリ文字やCookieでCacheを判定するようになるため，同一と見なすリクエストが増え，HIT率改善につながる．<br>・一部転送：指定したヘッダーのみ転送を許可し，Cacheの対象とする．<br>・全許可：全てのヘッダーがCacheの対象となる．しかし，日付に関するヘッダーなどの動的な値をCacheの対象としてしまうと．同一と見なすリクエストがほとんどなくなり，HITしなくなる．そのため，この設定でCacheは実質無効となり，『対象としない』に等しい． |
| Whitelist Header                                             | Cache Based on Selected Request Headers を参考にせよ．       | ・```Accept-xxxxx```：アプリケーションにレスポンスして欲しいデータの種類（データ型など）を指定．<br/>・ ```CloudFront-Is-xxxxx-Viewer```：デバイスタイプのBool値が格納されている． |
| Object Caching                                               | CloudFrontにコンテンツのCacheを保存しておく秒数を設定する．  | ・Origin Cache ヘッダーを選択した場合，アプリケーションからのレスポンスヘッダーのCache-Controlの値が適用される．<br>・カスタマイズを選択した場合，ブラウザのTTLとは別に設定できる． |
| TTL                                                          | CloudFrontにCacheを保存しておく秒数を詳細に設定する．        | ・Min，Max，Default，の全てを0秒とすると，Cacheを無効化できる．<br>・『Cache Based on Selected Request Headers = All』としている場合，Cacheが実質無効となるため，最小TTLはゼロでなければならない． |
| ★Farward Cookies<br/>（★については表上部参考）               | Cookie情報のキー名のうち，オリジンへの転送を許可し，Cacheの対象とするものを設定する． | ・Cookie情報キー名転送の全拒否，一部許可，全許可を設定できる．<br>・全拒否：全てのCookieの転送を拒否し，Cacheの対象としない．Cookieはユーザごとに一意になることが多く，動的であるが，それ以外のヘッダーやクエリ文字でCacheを判定するようになるため，同一と見なすリクエストが増え，HIT率改善につながる．<br/>・リクエストのヘッダーに含まれるCookie情報（キー名／値）が変動していると，CloudFrontに保存されたCacheがHITしない．CloudFrontはキー名／値を保持するため，変化しやすいキー名／値は，オリジンに転送しないように設定する．例えば，GoogleAnalyticsのキー名（```_ga```）の値は，ブラウザによって異なるため，１ユーザがブラウザを変えるたびに，異なるCacheが生成されることになる．そのため，ユーザを一意に判定することが難しくなってしまう．GoogleAnalyticsのキーはブラウザからAjaxでGoogleに送信されるもので，オリジンにとっても基本的に不要である．<br>・セッションIDはCookieヘッダーに設定されているため，フォーム送信に関わるパスパターンでは，セッションIDのキー名を許可する必要がある． |
| ★Query String Forwarding and Caching<br/>（★については表上部参考） | クエリストリングのうち，オリジンへの転送を許可し，Cacheの対象とするものを設定する． | ・クエリストリング転送とCacheの，全拒否，一部許可，全許可を選択できる．全拒否にすると，Webサイトにクエリストリングをリクエストできなくなるので注意．<br>・異なるクエリパラメータを，別々のCacheとして保存するかどうかを設定できる． |
| Restrict Viewer Access                                       | リクエストの送信元を制限するかどうかを設定できる．           | セキュリティグループで制御できるため，ここでは設定しなくてよい． |
| Compress Objects Automatically                               | レスポンス時にgzipを圧縮するかどうかを設定                   | ・クライアントからのリクエストヘッダーのAccept-Encodingにgzipが設定されている場合，レスポンス時に，gzip形式で圧縮して送信するかどうかを設定する．設定しない場合，圧縮せずにレスポンスを送信する．<br>・クライアント側のダウンロード速度向上のため，基本的には有効化する． |

#### ・Invalidation

TTL秒によるCacheの自動削除を待たずに，手動でCacheを削除できる．全てのファイルのCacheを削除したい場合は『```/*```』，特定のファイルのCacheを削除したい場合は『```/<ファイルへのパス>```』，を指定する．CloudFrontに関するエラーページが表示された場合，不具合を修正した後でもCacheが残っていると，エラーページが表示されてしまうため，作業後には必ずCacheを削除する．

#### ・オリジンに対するリクエストメッセージの構造

CloudFrontからオリジンに送信されるリクエストメッセージの構造例を以下に示す．

```http
GET /foo/
# リクエストされたドメイン名
Host: foo.com
User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1
Authorization: Bearer <Bearerトークン>
X-Amz-Cf-Id: XXXXX
Via: 2.0 77c20654dd474081d033f27ad1b56e1e.cloudfront.net (CloudFront)
# 各Cookieの値（二回目のリクエスト時に設定される）
Cookie: sessionid=<セッションID>; __ulfpc=<GoogleAnalytics値>; _ga=<GoogleAnalytics値>; _gid=<GoogleAnalytics値>
# 送信元IPアドレス
# ※プロキシサーバ（ALBやCloudFrontなども含む）を経由している場合，それら全てのIPアドレスも順に設定される
X-Forwarded-For: <client>, <proxy1>, <proxy2>
Accept-Language: ja,en;q=0.9
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Accept-Encoding: gzip, deflate, br
pragma: no-cache
cache-control: no-cache
upgrade-insecure-requests: 1
sec-fetch-site: none
sec-fetch-mode: navigate
sec-fetch-user: ?1
sec-fetch-dest: document
# デバイスタイプ
CloudFront-Is-Mobile-Viewer: true
CloudFront-Is-Tablet-Viewer: false
CloudFront-Is-SmartTV-Viewer: false
CloudFront-Is-Desktop-Viewer: false
# リクエストの送信元の国名
CloudFront-Viewer-Country: JP
# リクエストのプロトコル
CloudFront-Forwarded-Proto: https
```

#### ・CloudFrontとオリジン間のHTTPS通信

CloudFrontとオリジン間でHTTPS通信を行う場合，両方にドメイン証明書を割り当てる必要がある．割り当てたとしても，以下の条件を満たさないとHTTPS通信を行うことはできない．CLoudFronからオリジンにHostヘッダーを転送しない設定の場合，オリジンが返却する証明書に『Origin Domain Name』と一致するドメイン名が含まれている必要がある．一方で，Hostヘッダーを転送しない場合，オリジンが返却する証明書に『Origin Domain Name』と一致するドメイン名が含まれているか，またはオリジンが返却する証明書に，Hostヘッダーの値と一致するドメイン名が含まれている必要がある．

#### ・キャッシュの時間の決まり方

キャッシュの時間は，リクエストヘッダー（```Cache-Control```，```Expires```）の値とCloudFrontの設定（最大最小デフォルトTTL）の組み合わせによって決まる．ちなみに，CloudFrontの最大最小デフォルトTTLを全て０秒にすると，キャッシュを完全に無効化できる．

参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/Expiration.html#ExpirationDownloadDist

<br>

### Reports & analytics

#### ・Cache statistics

リクエストに関連する様々なデータを，日付別に集計したものを確認できる．

#### ・Popular objects

リクエストに関連する様々なデータを，オブジェクト別に集計したものを確認できる．

<br>

### エッジロケーションとエッジサーバ

#### ・Point Of Presence

CloudFrontは世界中に設置される『Point Of Presence（エッジロケーション＋中間層キャッシュ）』にデプロイされる．

参考：https://aws.amazon.com/jp/cloudfront/features/?whats-new-cloudfront.sort-by=item.additionalFields.postDateTime&whats-new-cloudfront.sort-order=desc

#### ・エッジロケーションにおける全エッジサーバのIPアドレス

CloudFrontには，エッジロケーションの数だけエッジサーバがあり，各サーバにIPアドレスが割り当てられている．以下のコマンドで，全てのエッジサーバのIPアドレスを確認できる．

```bash
$ curl https://ip-ranges.amazonaws.com/ip-ranges.json \
  | jq  ".prefixes[]| select(.service=="CLOUDFRONT") | .ip_prefix"
```

もしくは，以下のリンクを直接参考し，『```"service": "CLOUDFRONT"```』となっている部分を探す．

参考：https://ip-ranges.amazonaws.com/ip-ranges.json

#### ・エッジロケーションの使用中サーバのIPアドレス

CloudFrontには，エッジロケーションがあり，各ロケーションにサーバがある．以下のコマンドで，エッジロケーションにある使用中サーバのIPアドレスを確認できる．

```bash
$ nslookup <割り当てられた文字列>.cloudfront.net
```

<br>

### カスタムエラーページ

#### ・カスタムエラーページとは

オリジンに該当のファイルが存在しない場合，オリジンはCloudFrontに以下の403ステータスのレスポンスを返信する．カスタムエラーページを設定しない場合，CloudFrontはこの403ステータスをそのままレスポンスしてしまうため，オリジンに配置したカスタムエラーページを404ステータスでレスポンスするように設定する．

```xml
This XML file does not appear to have any style information associated with it. The document tree is shown below.
<Error>
<Code>AccessDenied</Code>
<Message>Access Denied</Message>
<RequestId>*****</RequestId>
<HostId>*****</HostId>
</Error>
```

#### ・設定方法

オリジンからカスタムエラーページをレスポンスするパスパターンを定義する．Lamnda@Edgeを使用したCloudFrontの場合は，Lambda@Edgeを経由して，カスタムエラーページをレスポンスする必要がある．

参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/HTTPStatusCodes.html

<br>

## 08. CloudTrail

### CloudTrailとは

IAMユーザによる操作や，ロールのアタッチの履歴を記録し，ログファイルとしてS3に転送する．CloudWatchと連携することもできる．

![CloudTrailとは](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/CloudTrailとは.jpeg)

<br>

## 09. CloudWatch

### CloudWatchエージェント

#### ・CloudWatchエージェントとは

インスタンス内で稼働する常駐システムのこと．インスタンス内のデータを収集し，CloudWatchに対して送信する．

#### ・CloudWatchエージェントの設定

| セクションの種類        | 説明                                   | 補足                                                         |
| ----------------------- | -------------------------------------- | ------------------------------------------------------------ |
| ```agent```セクション   | CloudWatchエージェント全体を設定する． | ・ウィザードを使用した場合，このセクションの設定はスキップされる．<br>・実装しなかった場合，デフォルト値が適用される． |
| ```metrics```セクション |                                        | ・ウィザードを使用した場合，このセクションの設定はスキップされる．<br>・実装しなかった場合，何も設定されない． |
| ```logs```セクション    |                                        |                                                              |

CloudWatchエージェントは，```/opt/aws/amazon-cloudwatch-agent/bin/config.json```ファイルの定義を元に，実行される．設定ファイルは分割できる．設定後，```amazon-cloudwatch-agent-ctl```コマンドで設定ファイルを読み込ませる．CloudWatchエージェントを使用して，CloudWatchにログファイルを送信するだけであれば，設定ファイル（```/opt/aws/amazon-cloudwatch-agent/bin/config.json```）には```log```セッションのみの実装で良い．```run_as_user```には，プロセスのユーザ名（例：```cwagent```）を設定する．

**＊実装例＊**

```bash
{
  "agent": {
    "run_as_user": "cwagent"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/foo-www/var/log/nginx/error_log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/php-fpm/error.log",
            "log_group_name": "/foo-www/var/log/php-fpm/error_log",
            "log_stream_name": 