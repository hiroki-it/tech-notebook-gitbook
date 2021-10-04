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

#### ・主要項目

| 設定項目             | 説明                                                         | 補足                                                         |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| リスナー             | ALBに割り振るポート番号お，受信するプロトコルを設定する．リバースプロキシかつロードバランサ－として，これらの通信をターゲットグループにルーティングする． |                                                              |
| セキュリティポリシー | リクエストの送信者が使用するSSL/TLSプロトコルや暗号化方式のバージョンに合わせて，ALBが受信できるこれらのバージョンを設定する． | ・リクエストの送信者には，ブラウザ，APIにリクエストを送信する外部サービス，転送元のAWSリソース（CloudFrontなど），などを含む．<br/>・参考：https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies |
| ルール               | リクエストのルーティングのロジックを設定する．               |                                                              |
| ターゲットグループ   | ルーティング時に使用するプロトコルと，ルーティング先のアプリケーションに割り当てられたポート番号を指定する． | ターゲットグループ内のターゲットのうち，トラフィックはヘルスチェックがOKになっているターゲットにルーティングされる． |
| ヘルスチェック       | ターゲットグループに属するプロトコルとアプリケーションのポート番号を指定して，定期的にリクエストを送信する． |                                                              |

#### ・ターゲットグループの詳細

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

#### ・一覧

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

#### ・リソースの詳細

| 順番 | 処理               | 説明                                                         | 補足                                                         |
| ---- | ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | メソッドリクエスト | クライアントから送信されたデータのうち，実際に転送するデータのフィルタリングを行う． |                                                              |
| 2    | 統合リクエスト     | メソッドリクエストから転送された各データを，マッピングテンプレートのJSONに紐づける． |                                                              |
| 3    | 統合レスポンス     |                                                              | 統合リクエストでプロキシ統合を使用する場合，統合レスポンスを使用できなくなる． |
| 4    | メソッドレスポンス | レスポンスが成功した場合，クライアントに送信するステータスコードを設定する． |                                                              |

#### ・メソッドリクエストの詳細

| 設定項目                  | 説明                                                         | 補足                                                         |
| ------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 認可                      | 定義したLambdaまたはCognitoによるオーソライザーを有効化する． |                                                              |
| リクエストの検証          | 『URLクエリ文字列パラメータ』『HTTPリクエストヘッダー』『リクエスト本文』のバリデーションを有効化する． |                                                              |
| APIキーの必要性           | リクエストヘッダーにおけるAPIキーのバリデーションを行う．リクエストのヘッダーに『```x-api-key```』を含み，これにAPIキーが割り当てられていることを強制する． | ヘッダー名は大文字でも小文字でも問題ないが，小文字が推奨．<br>参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_api_restful.html |
| URLクエリ文字列パラメータ | リクエストされたURLのクエリパラメータのバリデーションを行う． |                                                              |
| HTTPリクエストヘッダー    | リクエストヘッダーのバリデーションを行う．                   |                                                              |
| リクエスト本文            | リクエストボディのバリデーションを行う．                     |                                                              |
| SDK設定                   |                                                              |                                                              |

#### ・統合リクエストの詳細

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
  "httpMethod": "Incoming request"s method name",
  "headers": {String containing incoming request headers},
  "multiValueHeaders": {List of strings containing incoming request headers},
  "queryStringParameters": {query string parameters },
  "multiValueQueryStringParameters": {List of query string parameters},
  "pathParameters":  {path parameters},
  "stageVariables": {Applicable stage variables},
  "requestContext": {Request context, including authorizer-returned key-value pairs},
  "body": "A JSON string of the request payload.",
  "isBase64Encoded": "A boolean flag to indicate if the applicable request payload is Base64-encoded"
}

```

#### ・レスポンス時のマッピング

API Gatewayは，Lambdaからのレスポンスを，以下のJSONデータにマッピングする．これ以外の構造のJSONデータを送信すると，API Gatewayで『```Internal Server Error```』のエラーが起こる．

```bash
{
  "isBase64Encoded": true|false,
  "statusCode": httpStatusCode,
  "headers": { "headerName": "headerValue", ... },
  "multiValueHeaders": { "headerName": ["headerValue", "headerValue2", ...], ... },
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

## 08. CloudFront

### CloudFrontとは

クラウドリバースプロキシサーバとして働く．VPCの外側（パブリックネットワーク）に設置されている．オリジンサーバ（コンテンツ提供元）をS3とした場合，動的コンテンツへのリクエストをEC2に振り分ける．また，静的コンテンツへのリクエストをCacheし，その上でS3へ振り分ける．次回以降の静的コンテンツのリンクエストは，CloudFrontがレンスポンスを行う．

![AWSのクラウドデザイン一例](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/CloudFrontによるリクエストの振り分け.png)

### 設定項目

#### ・一覧

| 設定項目            | 説明 |
| ------------------- | ---- |
| Distributions       |      |
| Reports & analytics |      |

<br>

### Distributions

#### ・Distributionsの詳細

[参考になったサイト](https://www.geekfeed.co.jp/geekblog/wordpress%E3%81%A7%E6%A7%8B%E7%AF%89%E3%81%95%E3%82%8C%E3%81%A6%E3%81%84%E3%82%8B%E3%82%A6%E3%82%A7%E3%83%96%E3%82%B5%E3%82%A4%E3%83%88%E3%81%ABcloudfront%E3%82%92%E7%AB%8B%E3%81%A6%E3%81%A6%E9%AB%98/)

| 設定項目                 | 説明                                                         | 補足 |
| ------------------------ | ------------------------------------------------------------ | ---- |
| General                  |                                                              |      |
| Origin and Origin Groups | コンテンツを提供するAWSリソースを設定する．                  |      |
| Behavior                 | オリジンにリクエストが行われた時のCloudFrontの挙動を設定する． |      |
| ErrorPage                | 指定したオリジンから，指定したファイルのレスポンスを返信する． |      |
| Restriction              |                                                              |      |
| Invalidation             | CloudFrontに保存されているCacheを削除できる．                |      |

#### ・Generalの詳細

| 設定項目            | 説明                                                         | 補足                                                         |
| ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Price Class         | 使用するエッジロケーションを設定する．                       | Asiaが含まれているものを選択．                               |
| AWS WAF             | CloudFrontに紐づけるWAFを設定する．                          |                                                              |
| CNAME               | CloudFrontのデフォルトドメイン名（```xxxxx.cloudfront.net.```）に紐づけるRoute53レコード名を設定する． | ・Route53からルーティングする場合は必須．<br>・複数のレコード名を設定できる． |
| SSL Certificate     | HTTPSプロトコルでオリジンに転送する場合に設定する．          | 上述のCNAMEを設定した場合，SSL証明書が別途必要になる．また，Certificate Managerを使用する場合，この証明書は『バージニア北部』で申請する必要がある． |
| Security Policy     | リクエストの送信者が使用するSSL/TLSプロトコルや暗号化方式のバージョンに合わせて，CloudFrontが受信できるこれらのバージョンを設定する． | ・リクエストの送信者には，ブラウザ，APIにリクエストを送信する外部サービス，転送元のAWSリソース，などを含む．<br>・参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html |
| Default Root Object | オリジンのドキュメントルートを設定する．                     | ・何も設定しない場合，ドキュメントルートは指定されず，Behaviorで明示的にルーティングする必要がある．<br>・index.htmlを設定すると，『```/```』でリクエストした時に，オリジンのルートディレクトリにある```index,html```ファイルがドキュメントルートになる． |
| Standard Logging    | CloudFrontのアクセスログをS3に生成するかどうかを設定する．   |                                                              |

#### ・Origin and Origin Groupsの詳細

| 設定項目               | 説明                                                         | 補足                                                         |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Origin Domain Name     | CloudFrontをリバースプロキシとして，AWSリソースのエンドポイントやDNSにルーティングする． | ・例えば，S3のエンドポイント，ALBのDNS名を設定する．<br>・別アカウントのAWSリソースのDNS名であってもよい． |
| Origin Path            | オリジンのルートディレクトリを設定する．                     | ・何も設定しないと，デフォルトは『```/```』のなる．Behaviorでは，『```/```』の後にパスが追加される．<br>・『```/var/www/app```』を設定すると，Behaviorで設定したパスが『```/var/www/app/xxxxx```』のように追加される． |
| Origin Access Identity | リクエストの転送先となるAWSリソースでアクセス権限のアタッチが必要な場合に設定する．転送先のAWSリソースでは，アクセスポリシーをアタッチする． | CloudFrontがS3に対して読み出しを行うために必要．             |
| Origin Protocol Policy | リクエストの転送先となるAWSリソースに対して，HTTPとHTTPSのいずれのプロトコルで転送するかを設定する． | ・ALBで必要．ALBのリスナーのプロトコルに合わせて設定する．<br>・```HTTP Only```：HTTPで転送<br/>・```HTTPS Only```：HTTPSで転送<br/>・```Match Viewer```：両方で転送 |
| HTTPポート             | 転送時に指定するオリジンのHTTPのポート番号                   |                                                              |
| HTTPSポート            | 転送時に指定するオリジンのHTTPSのポート番号                  |                                                              |

#### ・Behaviorの詳細

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
$ curl https://ip-ranges.amazonaws.com/ip-ranges.json | jq  ".prefixes[] | select(.service=="CLOUDFRONT") | .ip_prefix"
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

## 07. CloudTrail

### CloudTrailとは

IAMユーザによる操作や，ロールのアタッチの履歴を記録し，ログファイルとしてS3に転送する．CloudWatchと連携することもできる．

![CloudTrailとは](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/CloudTrailとは.jpeg)

<br>

## 08. CloudWatch

### CloudWatchメトリクス

#### ・CloudWatchメトリクスとは

使用しているAWSリソースの状態をメトリクス化し，内部監視できる．

#### ・名前空間，メトリクス，ディメンションとは

データ収集の対象とする領域のこと．

![名前空間，メトリクス，ディメンション](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/名前空間，メトリクス，ディメンション.png)

CloudWatchメトリクス上では，以下のように確認できる．

![cloudwatch_namespace_metric_dimension](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/cloudwatch_namespace_metric_dimension.png)

#### ・SLIに関連するメトリクス

| 指標                           | 関連するメトリクス                                           | 補足                                                         |
| ------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| サーバ稼働率                   | ECS<br>・```RunningTaskCount```                              | ターゲット追跡スケーリングポリシーのECSサービスメトリクスも参考にせよ． |
| データベース稼働率             | RDS：<br>・```CPUUtilization```<br>・```FreeableMemory```    |                                                              |
| レイテンシー                   | API Gateway：<br>・```Latency```<br>・```IntegrationLatency``` |                                                              |
| レスポンスのステータスコード率 | ALB：<br>・```HTTPCode_ELB_4XX_Count```<br>・```HTTPCode_ELB_5XX_Count```<br>・```HTTPCode_TARGET_4XX_Count```<br>・```HTTPCode_TARGET_5XX_Count```<br>・```RejectedConnectionCount```<br>・```HealthyHostCount```<br>・```TargetConnectionErrorCount```<br>・```TargetTLSNegotiationErrorCount```<br><br>API Gateway：<br>・```4XXError```<br>・```5XXError``` |                                                              |

#### ・パフォーマンスに関するメトリクス

| 種類     | 名前                     | 補足                                                         |
| -------- | ------------------------ | ------------------------------------------------------------ |
| RDS      | パフォーマンスインサイト | RDSのパフォーマンスに関するメトリクスを収集し，SQLレベルで監視できるようになる．パラメータグループの```performance_schema```を有効化する必要がある．対応するエンジンバージョンとインスタンスタイプについては，以下のリンクを参考にせよ．<br>参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_PerfInsights.Overview.Engines.htm |
| ECS／EKS | Container インサイト     | ECS／EKSのパフォーマンスに関するメトリクスを収集し，ECS／EKSのクラスター，サービス，タスク，インスタンス，単位で監視できるようになる．また，コンテナ間の繋がりをコンテナマップで視覚化できるようになる．ECS／EKSのアカウント設定でContainerインサイトを有効化する必要がある． |
| Lambda   | Lambdaインサイト         | Lambdaのパフォーマンスに関するメトリクスを収集できるようになる． |

<br>

### CloudWatch Synthetics

#### ・CloudWatch Syntheticsとは

合成監視を行えるようになる．

<br>

### CloudWatchログ

####  ・設定項目

クラウドログサーバとして働く．様々なAWSリソースで生成されたログファイルを収集できる．

| 設定項目                     | 説明                                                       | 補足                                                         |
| ---------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------ |
| ロググループ                 | ログストリームをグループ化して収集するかどうかを設定する． | 基本的に，ログファイルはグループ化せずに，一つのロググループには一つのログストリームしか含まれないようにする． |
| メトリクスフィルター         | 紐づくロググループで，出現を監視する文字列を設定する．     |                                                              |
| サブスクリプションフィルター |                                                            |                                                              |
| Logsインサイト               | クエリを使用してログを抽出する．                           |                                                              |

#### ・メトリクスフィルターの詳細

| 設定項目           | 説明                                                         | 補足                                                       |
| ------------------ | ------------------------------------------------------------ | ---------------------------------------------------------- |
| フィルターパターン | 紐づくロググループで，メトリクス値増加のトリガーとする文字列を設定する． | 大文字と小文字を区別するため，網羅的に設定する必要がある． |
| 名前空間           | 紐づくロググループが属する名前空間を設定する．CloudWatchログが，設定した名前空間に対して，値を発行する． |                                                            |
| メトリクス         | 紐づくロググループが属する名前空間内のメトリクスを設定する．CloudWatchログが，設定したメトリクスに対して，値を発行する． |                                                            |
| メトリクス値       | フィルターパターンで文字列が検出された時に，メトリクスに対して発行する値のこと． | 例えば『検出数』を発行する場合は，『１』を設定する．       |

#### ・フィルターパターンのテンプレート

```bash
# OR条件で大文字小文字を考慮し，『XXXXX:』を検出
?"WARNING:" ?"Warning:" ?"ERROR:" ?"Error:" ?"CRITICAL:" ?"Critical:" ?"EMERGENCY:" ?"Emergency:" ?"ALERT:" ?"Alert:"
```

```bash
# OR条件で大文字小文字を考慮し，『XXXXX message』を検出
?"WARNING message" ?"Warning message" ?"ERROR message" ?"Error message" ?"CRITICAL message" ?"Critical message" ?"EMERGENCY message" ?"Emergency message" ?"ALERT message" ?"Alert message"
```

#### ・Logインサイト

汎用的なクエリを示す．

```bash
# 小文字と大文字を区別せずに，ExceptionまたはErrorを含むログを検索する．
fields @timestamp, @message, @logStream
| filter @message like /(?i)(Exception|Error)/
| sort @timestamp desc
| limit 100
```



<br>

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
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
```

#### ・ログ送信権限

参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/logs/AWS-logs-and-resource-policy.html

#### ・操作コマンド

**＊コマンド例＊**

```bash
# EC2内にある設定ファイルを，CloudWatchエージェントに読み込ませる（再起動を含む）
$ /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

# プロセスのステータスを確認
$ /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -m ec2 \
  -a status
```

```bash
# 設定ファイルが読み込まれたかを確認

### CloudWatchエージェントのプロセスのログファイル
$ tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log

### 設定ファイルの構文チェックのログファイル
$ tail -f /opt/aws/amazon-cloudwatch-agent/logs/configuration-validation.log

### OS起動時にデーモンが稼働するように設定されているかを確認
$ systemctl list-unit-files --type=service
```

<br>

### CloudWatchログエージェント

#### ・CloudWatchログエージェントとは（非推奨）

インスタンス内で稼働する常駐システムのこと．インスタンス内のデータを収集し，CloudWatchログに対して送信する．2020/10/05現在は非推奨で，CloudWatchエージェントへの設定の移行が推奨されている．

#### ・CloudWatchログエージェントの設定

confファイルを，インスタンス内の```etc```ディレクトリ下に設置する．OS，ミドルウェア，アプリケーション，の各層でログを収集するのがよい．

参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/logs/AgentReference.html#agent-configuration-file

**＊実装例＊**

```bash
#############################
# /var/awslogs/awslogs.conf
#############################

# ------------------------------------------
# CentOS CloudWatch Logs
# ------------------------------------------
[/var/log/messages]

# タイムスタンプ
#（例）Jan 1 00:00:00
datetime_format = %b %d %H:%M:%S
#（例）2020-01-01 00:00:00
# datetime_format = %Y-%m-%d %H:%M:%S

# 収集したいログファイル．ここでは，CentOSのログを指定する．
file = /var/log/messages

# 文字コードutf_8として送信する．文字コードが合わないと，CloudWatchログの画面上で文字化けする．
encoding = utf_8

# 要勉強
buffer_duration = 5000
initial_position = start_of_file

# インスタンスID
log_stream_name = {instance_id}

# AWS上で管理するロググループ名
log_group_name = /var/log/messages

# ------------------------------------------
# Nginx CloudWatch Logs
# ------------------------------------------
[/var/log/nginx/error.log]
file             = /var/log/nginx/error.log
buffer_duration  = 5000
log_stream_name  = {instance_id}
initial_position = start_of_file
log_group_name   = /var/log/nginx/error_log.production

# ------------------------------------------
# Application CloudWatch Logs
# ------------------------------------------
[/var/www/project/app/storage/logs/laravel.log]
file             = /var/www/project/app/storage/logs/laravel.log
buffer_duration  = 5000
log_stream_name  = {instance_id}
initial_position = start_of_file
log_group_name   = /var/www/project/app/storage/logs/laravel_log.production
```

```bash
#############################
# /var/awslogs/awscli.conf
#############################

[plugins]
cwlogs = cwlogs
[default]
region = ap-northeast-1
```

#### ・操作コマンド

設定後，```awslogs```コマンドでプロセスを起動する．

**＊コマンド例＊**

```bash
# CloudWatchエージェントの再起動
# 注意: restartだとCloudWatchに反映されない時がある．
$ service awslogs restart

# もしくは
$ service awslogs stop
$ service awslogs start

# ログが新しく生成されないと変更が適用されないことがあるため，ログファイルに適当な文字列行を増やしてみる．
```

<br>

### CLI

#### ・メトリクス収集量を確認

**＊コマンド例＊**

全てのロググループに対して，一日当たりのメトリクス収集量を```start-time```から```end-time```の間で取得する．```--dimensions ```オプションを使用して，特定のディメンション（ロググループ）に対して集計を実行することもできる．（ただ，やってみたけどうまくいかず）

参考：https://docs.aws.amazon.com/cli/latest/reference/cloudwatch/get-metric-statistics.html

 ```bash
 $ aws cloudwatch get-metric-statistics \
   --namespace AWS/Logs \
   --metric-name IncomingBytes \
   --start-time 2021-08-01T00:00:00 \
   --end-time 2021-08-31T23:59:59 \
   --period 86400 
   --statistics Sum | jq -r ".Datapoints[] | [.Timestamp, .Sum] | @csv" | sort
 ```

#### ・CloudWatchアラームの状態変更

**＊コマンド例＊**

CloudWatchアラームの状態を変更する．

```bash
$ aws cloudwatch set-alarm-state \
  --alarm-name "prd-foo-alarm" \
  --state-value ALARM \
  --state-reason "アラーム!!"
```

<br>

## 09. Code系サービス

### CodePipeline

#### ・CodePipelineとは

CodeCommit，CodeBuild，CodeDeployを連携させて，AWSに対するCI/CD環境を構築する．CodeCommitは，他のソースコード管理サービスで代用できる．

![code-pipeline](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/code-pipeline.png)

#### ・CodeCommitとは

ソースコードをバージョン管理する．

#### ・CodeBuildとは

ビルドフェーズとテストフェーズを実行する．

#### ・CodeDeployとは

デプロイフェーズを実行する．

<br>

### CodeBuild

#### ・```buildspec.yml```ファイル

CodeBuildの設定を行う．ルートディレクトリの直下に配置しておく．

参考：https://docs.aws.amazon.com/ja_jp/codebuild/latest/userguide/build-spec-ref.html

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
  preBuild:
    commands:
      # ECRにログイン
      - $(aws ecr get-login --no-include-email --region ${AWS_DEFAULT_REGION})
      # イメージタグはGitHubコミットのハッシュ値を使用
      - IMAGE_TAG=$CODEBUILD_RESOLVED_SOURCE_VERSION
      # ECRのURLをCodeBuildの環境変数から作成
      - REPOSITORY_URI=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}
  build:
    commands:
      # タグ付けしてイメージをビルド
      - docker build -t REPOSITORY_URI:$IMAGE_TAG -f Dockerfile .
  postBuild:
    commands:
      # ECRにイメージをプッシュ
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      # ECRにあるデプロイ対象のイメージの情報（imageDetail.json）
      - printf "{"Version":"1.0","ImageURI":"%s"}" $REPOSITORY_URI:$IMAGE_TAG > imageDetail.json
    
# デプロイ対象とするビルドのアーティファクト    
artifacts:
  files: imageDetail.json
```

#### ・ビルド時に作成すべきデプロイ設定ファイル

デプロイ対象となるイメージを定義するために，標準デプロイアクションの場合には```imagedefinitions.json```ファイル，またはBlue/Greenデプロイメントの場合には```imageDetail.json```ファイルを用意する必要がある．これはリポジトリに事前に配置するのではなく，ビルド時に自動的に作成するようにした方がよい．

参考：https://docs.aws.amazon.com/ja_jp/codepipeline/latest/userguide/file-reference.html

<br>

### CodeDeployによるBlue/Greenデプロイメント

#### ・Blue/Greenデプロイメントとは

![blue-green-deployment](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/blue-green-deployment.jpeg)

以下の手順でデプロイを行う．

1. ECRのイメージを更新
2. タスク定義の新しいリビジョンを構築．
3. サービスを更新．
4. CodeDeployによって，タスク定義を基に，現行の本番環境（Prodブルー）のタスクとは別に，テスト環境（Testグリーン）が構築される．ロードバランサーの接続先を，本番環境（Prodブルー）のターゲットグループ（Primaryターゲットグループ）に加えて，テスト環境（Testグリーン）にも向ける．
5. 社内からテスト環境（Testグリーン）のALBに，特定のポート番号でアクセスし，動作を確認する．
6. 動作確認で問題なければ，Console画面からの入力で，ロードバランサーの接続先をテスト環境（Testグリーン）のみに設定する．
7. テスト環境（Testグリーン）が新しい本番環境としてユーザに公開される．
8. 元々の本番環境（Prodブルー）は削除される．

#### ・```appspec.yml```ファイル

CodeDeployの設定を行う．ルートディレクトリの直下に配置しておく．仕様として，複数のコンテナをデプロイできない．タスク定義名を```<TASK_DEFINITION>```とすると，自動補完してくれる．

参考：https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-resources.html

```yaml
version: 0.0

Resources:
  - TargetService:
      # 使用するAWSリソース
      Type: AWS::ECS::Service
      Properties:
        # 使用するタスク定義
        TaskDefinition: "<TASK_DEFINITION>"
        # 使用するロードバランサー
        LoadBalancerInfo:
          ContainerName: "<コンテナ名>"
          ContainerPort: "80"
        PlatformVersion: "1.4.0"
```

#### ・```taskdef.json```ファイル

デプロイされるタスク定義を実装し，ルートディレクトリの直下に配置する．CodeDeployは，CodeBuildから渡された```imageDetail.json```ファイルを検知し，ECRからイメージを取得する．この時，```taskdef.json```ファイルのイメージ名を```<IMAGE1_NAME>```としておくと，ECRから取得したイメージ名を使用して，自動補完してくれる．

```bash
{
  "family": "<タスク定義名>",
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "networkMode": "awsvpc",
  "taskRoleArn": "<タスクロールのARN>",
  "executionRoleArn": "<タスク実行ロールのARN>",
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "<コンテナ名>",
      "image": "<IMAGE1_NAME>",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "secrets": [
        {
          "name": "DB_HOST",
          "valueFrom": "/ecs/DB_HOST"
        },
        {
          "name": "DB_DATABASE",
          "valueFrom": "/ecs/DB_DATABASE"
        },
        {
          "name": "DB_PASSWORD",
          "valueFrom": "/ecs/DB_PASSWORD"
        },
        {
          "name": "DB_USERNAME",
          "valueFrom": "/ecs/DB_USERNAME"
        },
        {
          "name": "REDIS_HOST",
          "valueFrom": "/ecs/REDIS_HOST"
        },
        {
          "name": "REDIS_PASSWORD",
          "valueFrom": "/ecs/REDIS_PASSWORD"
        },
        {
          "name": "REDIS_PORT",
          "valueFrom": "/ecs/REDIS_PORT"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "<ロググループ名>",
          # スタックトレースのログを紐付けられるように，日付で区切るようにする．
          "awslogs-datetime-format": "\\[%Y-%m-%d %H:%M:%S\\]",
          "awslogs-region": "<リージョン>",
          "awslogs-stream-prefix": "<ログストリーム名のプレフィクス>"
        }
      }
    }
  ]
}
```

<br>

### CodeDeployによるインプレースデプロイメント

<br>

## 10. EBS：Elastic Block Storage

### EBSとは

クラウド内蔵ストレージとして働く．

<br>

### 設定項目

#### ・ストレージの種類とボリュームタイプ

| ストレージの種類 | ボリューム名            |
| ---------------- | ----------------------- |
| SSD              | 汎用SSD                 |
| SSD              | プロビジョンド IOPS SSD |
| HDD              | スループット最適化 HDD  |
| HDD              | Cold HDD                |

#### ・最小ボリューム

踏み台サーバを構築する時，できるだけ最小限のボリュームを選択し，ストレージ合計を抑える必要がある．

| OS           | 仮想メモリ | ボリュームサイズ |
| ------------ | ---------- | ---------------- |
| Amazon Linux | t2.micro   | 8                |
| CentOS       | t2.micro   | 10               |

<br>

## 11. EC2：Elastic Computer Cloud

### EC2とは

クラウドサーバとして働く．注意点があるものだけまとめる．ベストプラクティスについては，以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ec2-best-practices.html

<br>

### 設定項目

#### ・一覧

| 設定項目                  | 説明                                              | 補足                                                         |
| ------------------------- | ------------------------------------------------- | ------------------------------------------------------------ |
| AMI：Amazonマシンイメージ | OSを選択する．                                    | ベンダー公式のものを選択すること．（例：CentOSのAMI一覧 https://wiki.centos.org/Cloud/AWS） |
| インスタンスの詳細設定    | EC2インスタンスの設定する．                       | ・インスタンス自動割り当てパブリックにて，EC2に動的パブリックIPを割り当てる．EC2インスタンス構築後に有効にできない．<br/>・終了保護は必ず有効にすること． |
| ストレージの追加          | EBSボリュームを設定する．                         | 一般的なアプリケーションであれば，20～30GiBでよい．踏み台サーバの場合，最低限で良いため，OSの下限までサイズを下げる．（例：AmazonLinuxの下限は8GiB，CentOSは10GiB） |
| キーペア                  | EC2の秘密鍵に対応した公開鍵をインストールできる． | キーペアに割り当てられるフィンガープリント値を調べることで，公開鍵と秘密鍵の対応関係を調べることができる． |

<br>

### インスタンスのダウンタイム

#### ・ダウンタイムの発生条件

以下の条件の時にEC2にダウンタイムが発生する．EC2を冗長化している場合は，ユーザに影響を与えずに対処できる．ダウンタイムが発生する方のインスタンスを事前にALBのターゲットグループから解除しておき，停止したインスタンスが起動した後に，ターゲットグループに再登録する．

| 変更する項目                     | ダウンタイムの有無 | 補足                                                         |
| -------------------------------- | ------------------ | ------------------------------------------------------------ |
| インスタンスタイプ               | あり               | インスタンスタイプを変更するためにはEC2を停止する必要がある．そのため，ダウンタイムが発生する． |
| ホスト物理サーバのリタイアメント | あり               | AWSから定期的にリタイアメントに関する警告メールが届く．ルートデバイスタイプが『EBS』の場合，ホスト物理サーバの引っ越しを行うためにEC2の停止と起動が必要である．そのため，ダウンタイムが発生する．なお，再起動では引っ越しできない． |

<br>

### スペック

#### ・インスタンスタイプ

『世代』と『大きさ』からなる名前で構成される．世代の数字が上がるにつれて，より小さな世代と同じ大きさであっても，パフォーマンスと低コストになる．AMIのOSのバージョンによっては，新しく登場したインスタンスタイプを適用できないことがあるため注意する．例えば，CentOS 6系のAMIでは，```t3.small```を選択できない．

参考：https://aws.amazon.com/marketplace/pp/prodview-gkh3rqhqbgzme?ref=cns_srchrow

|        | 種類                                                         |
| ------ | ------------------------------------------------------------ |
| 世代   | ```t2```，```t3```，```t3a```，```t4g```，```a1```           |
| 大きさ | ```nano```，```small```，```medium```，```large```，```xlarge```，```2xlarge``` |

#### ・ストレージ

EBSの説明を参考にせよ．

#### ・CPUバーストモード

バーストモードのインスタンスタイプの場合，一定水準のベースラインCPU使用率を提供しつつ，これを超過できる．CPU使用率がベースラインを超えたとき，超過した分だけEC2はCPUクレジットを消費する．CPUクレジットは一定の割合で回復する．蓄積できる最大CPUクレジット，クレジットの回復率，ベースラインCPU使用率は，インスタンスタイプによって異なる．詳しくは以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/burstable-performance-instances.html

<br>

### キーペア

#### ・キーペアのフィンガープリント値

ローカルに置かれている秘密鍵が，該当するEC2に置かれている公開鍵とペアなのかどうか，フィンガープリント値を照合して確認する方法

```bash
$ openssl pkcs8 \
  -in <秘密鍵名>.pem \
  -inform PEM \
  -outform DER \
  -topk8 \
  -nocrypt | openssl sha1 -c
```

#### ・EC2へのSSH接続

クライアントのSSHプロトコルもつパケットは，まずインターネットを経由して，インターネットゲートウェイを通過する．その後，Route53，ALBを経由せず，そのままEC2へ向かう．

![ssh-port-forward](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ssh-port-forward.png)

<br>

## 12. ECR

### ECRとは

AWSが提供するDockerイメージのレジストリサービス

<br>

### 設定項目

#### ・設定項目

| 設定項目                 | 説明                                                         | 補足                                                         |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 可視性                   | リポジトリをパブリックアクセス／プライベートアクセスにするかを設定する． | 様々なベンダーがパブリックリポジトリでECRイメージを提供している．<br>参考：https://gallery.ecr.aws/ |
| タグのイミュータビリティ | 同じタグ名でイメージがプッシュされた場合に，イメージタグを上書き可能／不可能かを設定できる． |                                                              |
| プッシュ時にスキャン     | イメージがプッシュされた時に，イメージにインストールされているライブラリの脆弱性を検証し，一覧表示する． | 参考：https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/image-scanning.html |
| 暗号化設定               |                                                              |                                                              |

<br>

### ライフサイクル

#### ・ライフサイクルポリシー

ECRのイメージの有効期間を定義できる．

| 設定項目             | 説明                                                         | 補足                                                         |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ルールの優先順位     | 順位の大きさで，ルールの優先度を設定できる．                 | 数字は連続している必要はなく，例えば，10，20，90，のように設定しても良い． |
| イメージのステータス | ルールを適用するイメージの条件として，タグの有無や文字列を設定できる． |                                                              |
| 一致条件             | イメージの有効期間として，同条件に当てはまるイメージが削除される閾値を設定できる． | 個数，プッシュされてからの期間，などを閾値として設定できる． |

<br>

### イメージタグ

#### ・タグ名のベストプラクティス

Dockerのベストプラクティスに則り，タグ名にlatestを使用しないようにする．その代わりに，イメージのバージョンごとに異なるタグ名になるようハッシュ値（例：GitHubのコミットID）を使用する．

参考：https://matsuand.github.io/docs.docker.jp.onthefly/develop/dev-best-practices/

<br>

## 13-01. ECS

### ECSとは

コンテナオーケストレーションを実行する環境を提供する．VPCの外に存在している．ECS，EKS，Fargate，EC2の対応関係は以下の通り．

| Control Plane（コンテナオーケストレーション環境） | Data Plane（コンテナ実行環境） | 説明                                                         |
| ------------------------------------------------- | ------------------------------ | ------------------------------------------------------------ |
| ECS：Elastic Container Service                    | Fargate，EC2                   | 単一のOS上でコンテナオーケストレーションを実行する．         |
| EKS：Elastic Kubernetes Service                   | EC2                            | 複数のOS上それぞれでコンテナオーケストレーションを実行する． |

<br>

## 13-02. ECS on EC2

### EC2起動タイプのコンテナ

#### ・タスク配置戦略

タスクをインスタンスに配置する時のアルゴリズムを選択できる．

| 戦略    | 説明                                         |
| ------- | -------------------------------------------- |
| Spread  | タスクを各場所にバランスよく配置する         |
| Binpack | タスクを一つの場所にできるだけ多く配置する． |
| Random  | タスクをランダムに配置する．                 |

<br>

## 13-03. ECS on Fargate：Elastic Container Service

### クラスター

#### ・クラスターとは

![ECSクラスター](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ECSクラスター.png)

<br>

### サービス

#### ・サービスとは

タスク数の維持管理や，タスクへのロードバランシング，リリースの成否の管理を行う機能のこと．

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/service_definition_parameters.html

| 設定項目                     | 説明                                                         | 補足                                                         |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| タスク定義                   | サービスで維持管理するタスクの定義ファミリー名とリビジョン番号を設定する． |                                                              |
| 起動タイプ                   | タスク内のコンテナの起動タイプを設定する．                   |                                                              |
| プラットフォームのバージョン | タスクの実行環境のバージョンを設定する．                     | バージョンによって，連携できるAWSリソースが異なる．          |
| サービスタイプ               |                                                              |                                                              |
| タスクの必要数               | 非スケーリング時またはデプロイ時のタスク数を設定する．       | 最小ヘルス率と最大率の設定値に影響する．                     |
| 最小ヘルス率                 | タスクの必要数の設定を100%とし，新しいタスクのデプロイ時に，稼働中タスクの最低合計数を割合で設定する． | 例として，タスク必要数が４個だと仮定する．タスクヘルス最小率を50%とすれば，稼働中タスクの最低合計数は２個となる．デプロイ時の既存タスク停止と新タスク起動では，稼働中の既存タスク／新タスクの数が最低合計数未満にならないように制御される．<br>参考：https://toris.io/2021/04/speeding-up-amazon-ecs-container-deployments |
| 最大率                       | タスクの必要数の設定を100%とし，新しいタスクのデプロイ時に，稼働中／停止中タスクの最高合計数を割合で設定する． | 例として，タスク必要数が４個だと仮定する．タスク最大率を200%とすれば，稼働中／停止中タスクの最高合計数は８個となる．デプロイ時の既存タスク停止と新タスク起動では，稼働中／停止中の既存タスク／新タスクの数が最高合計数を超過しないように制御される．<br>参考：https://toris.io/2021/04/speeding-up-amazon-ecs-container-deployments |
| ヘルスチェックの猶予期間     | デプロイ時のALB／NLBのヘルスチェックの状態を確認するまでの待機時間を設定する．猶予期間を過ぎても，ALB／NLBのヘルスチェックが失敗していれば，サービスはタスクを停止し，新しいタスクを再起動する． | ALB／NLBではターゲットを登録し，ヘルスチェックを実行するプロセスがある．特にNLBでは，これに時間がかかる．またアプリケーションによっては，コンテナの構築に時間がかかる．そのため，NLBのヘルスチェックが完了する前に，ECSサービスがNLBのヘルスチェックの結果を確認してしまうことがある．例えば，NLBとLaravelを使用する場合は，ターゲット登録とLaravelコンテナの築の時間を加味して，```330```秒以上を目安とする．例えば，ALBとNuxtjs（SSRモード）を使用する場合は，```600```秒以上を目安とする．なお，アプリケーションのコンテナ構築にかかる時間は，ローカル環境での所要時間を参考にする． |
| タスクの最小数               | スケーリング時のタスク数の最小数を設定する．                 |                                                              |
| タスクの最大数               | スケーリング時のタスク数の最大数を設定する．                 |                                                              |
| ロードバランシング           | ALBでルーティングするコンテナを設定する．                    |                                                              |
| タスクの数                   | タスクの構築数をいくつに維持するかを設定する．               | タスクが何らかの原因で停止した場合，空いているAWSサービスを使用して，タスクが自動的に補填される． |
| デプロイメント               | ローリングアップデート，Blue/Greenデプロイがある．           |                                                              |

#### ・ターゲット追跡スケーリングポリシー

| 設定項目                           | 説明                                                         | 補足                                                         |
| ---------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ターゲット追跡スケーリングポリシー | 監視対象のメトリクスがターゲット値を超過しているか否かに基づいて，タスク数のスケーリングが実行される． |                                                              |
| ECSサービスメトリクス              | 監視対象のメトリクスを設定する．                             | 『平均CPU』，『平均メモリ』，『タスク当たりのALBからのリクエスト数』を監視できる．SLIに対応するCloudWatchメトリクスも参考にせよ． |
| ターゲット値                       | タスク数のスケーリングが実行される収束値を設定する．         | ターゲット値を超過している場合，タスク数がスケールアウトされる．反対に，ターゲット値未満（正確にはターゲット値の９割未満）の場合，タスク数がスケールインされる． |
| スケールアウトクールダウン期間     | スケールアウトを発動してから，次回のスケールアウトを発動できるまでの時間を設定する． | ・期間を短くし過ぎると，ターゲット値を超過する状態が断続的に続いた場合に，余分なスケールアウトが連続して実行されてしまうため注意する．<br>・期間を長く過ぎると，スケールアウトが不十分になり，ECSの負荷が緩和されないため注意する． |
| スケールインクールダウン期間       | スケールインを発動してから，次回のスケールインを発動できるまでの時間を設定する． |                                                              |
| スケールインの無効化               |                                                              |                                                              |

ターゲット値の設定に応じて，自動的にスケールアウトやスケールインが起こるシナリオ例を示す．

1. 最小タスク数を2，必要タスク数を4，最大数を6，CPU平均使用率を40%に設定するとする．
2. 平常時，CPU使用率40%に維持される．
3. リクエストが増加し，CPU使用率55%に上昇する．
4. タスク数が6つにスケールアウトし，CPU使用率40%に維持される．
5. リクエスト数が減少し，CPU使用率が20%に低下する．
6. タスク数が2つにスケールインし，CPU使用率40%に維持される．

#### ・マイクロサービスアーキテクチャ風

マイクロサービスアーキテクチャのアプリケーション群を稼働させる時，Kubernetesを使用し，またインフラとしてEKSを使用するのが基本である．ただし，モノリスなアプリケーションをECSサービスで分割し，Fargateで稼働させることにより，マイクロサービスアーキテクチャ風のインフラを構築できる．

参考：https://tangocode.com/2018/11/when-to-use-lambdas-vs-ecs-docker-containers/

![ecs-fargate_microservice](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ecs-fargate_microservice.png)

<br>

### タスク

![タスクとタスク定義](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/タスクとタスク定義.png)

#### ・タスク

グルーピングされたコンテナ群のこと

#### ・タスク定義とは

各タスクをどのような設定値に基づいて構築するかを設定できる．タスク定義は，バージョンを示す『リビジョンナンバー』で番号づけされる．タスク定義を削除するには，全てのリビジョン番号のタスク定義を登録解除する必要がある．

#### ・タスクのライフサイクル

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task-lifecycle.html#lifecycle-states

![ecs-task_life-cycle](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ecs-task_life-cycle.png)

#### ・タスクサイズの詳細


| 設定項目     | 説明                                     |
| ------------ | ---------------------------------------- |
| タスクメモリ | タスク当たりのコンテナの合計メモリ使用量 |
| タスクCPU    | タスク当たりのコンテナの合計CPU使用量    |

#### ・新しいタスクを一時的に実行

現在起動中のECSタスクとは別に，新しいタスクを一時的に起動する．CI/CDツールで実行する以外に，ローカルから手動で実行する場合もある．起動時に，```overrides```オプションを使用して，指定したタスク定義のコンテナ設定を上書きできる．正規表現で設定する必要があり，さらにJSONでは『```\```』を『```\\```』にエスケープしなければならない．コマンドが実行された後に，タスクは自動的にStopped状態になる．

**＊実装例＊**

LaravelのSeederコマンドやロールバックコマンドを，ローカルPCから実行する．

```bash
#!/bin/bash

set -x

echo "Set Variables"
SERVICE_NAME="stg-foo-ecs-service"
CLUSTER_NAME="stg-foo-ecs-cluster"
TASK_NAME="stg-foo-ecs-task-definition"
SUBNETS_CONFIG=$(aws ecs describe-services \
  --cluster ${CLUSTER_NAME} \
  --services ${SERVICE_NAME} \
  --query "services[].deployments[].networkConfiguration[].awsvpcConfiguration[].subnets[]")
SGS_CONFIG=$(aws ecs describe-services \
  --cluster ${CLUSTER_NAME} \
  --services ${SERVICE_NAME} \
  --query "services[].deployments[].networkConfiguration[].awsvpcConfiguration[].securityGroups[]")

# 実行したいコマンドをoverridesに設定する．
echo "Run Task"
TASK_ARN=$(aws ecs run-task \
  --launch-type FARGATE \
  --cluster ${CLUSTER_NAME} \
  --platform-version "1.4.0" \
  --network-configuration "awsvpcConfiguration={subnets=${SUBNETS_CONFIG},securityGroups=${SGS_CONFIG}}" \
  --task-definition ${TASK_NAME} \
  --overrides '{\"containerOverrides\": [{\"name\": \"laravel-container\",\"command\": [\"php\", \"artisan\", \"db:seed\", \"--class=DummySeeder\", \"--force\"]}]}' \
  --query "tasks[0].taskArn" | tr -d """)

echo "Wait until task stopped"
aws ecs wait tasks-stopped \
  --cluster ${CLUSTER_NAME} \
  --tasks ${TASK_ARN}

echo "Get task result"
RESULT=$(aws ecs describe-tasks \
  --cluster ${CLUSTER_NAME} \
  --tasks ${TASK_ARN})
echo ${RESULT}

EXIT_CODE=$(echo ${RESULT} | jq .tasks[0].containers[0].exitCode)
echo exitCode ${EXIT_CODE}
exit ${EXIT_CODE}
```

なお，実行IAMユーザを作成し，ECSタスクを起動できる最低限の権限をアタッチする．

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole",
                "ecs:RunTask",
                "ecs:DescribeServices",
                "ecs:DescribeTasks"
            ],
            "Resource": [
                "arn:aws:ecs:*:<アカウントID>:service/*",
                "arn:aws:ecs:*:<アカウントID>:task/*",
                "arn:aws:ecs:*:<アカウントID>:task-definition/*",
                "arn:aws:iam::<アカウントID>:role/*"
            ]
        }
    ]
}
```

####  ・ECS Exec

ECSタスクのコンテナに対して，シェルログインを実行する．ECSサービスにおけるECS-Execオプションの有効化，ssmmessagesエンドポイントの作成，System ManagerにアクセスするためのIAMポリシーの作成，ECSタスク実行ロールへのIAMポリシーの付与，IAMユーザへのポリシーの付与，が必要になる．

参考：

- https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/ecs-exec.html
- https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/systems-manager-setting-up-messageAPIs.html

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        # ssmmesages APIへのアクセス権限
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
    }
  ]
}
```

なお，事前の設定がなされているかどうかをecs-exec-checkerスクリプトを実行して確認できる．

参考：https://github.com/aws-containers/amazon-ecs-exec-checker

```bash
#!/bin/bash

ECS_CLUSTER_NAME=prd-foo-ecs-cluster
ECS_TASK_ID=bar

bash <(curl -Ls https://raw.githubusercontent.com/aws-containers/amazon-ecs-exec-checker/main/check-ecs-exec.sh) $ECS_CLUSTER_NAME $ECS_TASK_ID
```

ECS Execを実行するユーザに，実行権限のポリシーを付与する必要がある．

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:ExecuteCommand",
            ],
            "Resource": [
                "arn:aws:ecs:*:<アカウントID>:cluster/*",
                "arn:aws:ecs:*:<アカウントID>:task/*",
            ]
        }
    ]
}
```

laravelコンテナに対して，シェルログインを実行する．bashを実行する時に，『```/bin/bash```』や『```/bin/sh```』で指定すると，binより上のパスもECSに送信されてしまう．例えば，Windowsなら『```C:/Program Files/Git/usr/bin/bash```』が送信される．これはCloudTrailでExecuteCommandイベントとして確認できる．ECSコンテナ内ではbashへのパスが異なるため，接続に失敗する．そのため，bashを直接指定するようにする．

```bash
#!/bin/bash

set -xe

ECS_CLUSTER_NAME=prd-foo-ecs-cluster
ECS_TASK_ID=bar
ECS_CONTAINER_NAME=laravel

aws ecs execute-command \
    --cluster $ECS_CLUSTER_NAME \
    --task $ECS_TASK_ID \
    --container $ECS_CONTAINER_NAME \
    --interactive \
    --debug \
    --command "bash"
```

<br>

### Fargate

#### ・Fargateとは

コンテナの実行環境のこと．『ECS on Fargate』という呼び方は，Fargateが環境の意味合いを持つからである．Fargate環境ではホストが隠蔽されており，実体としてEC2インスタンスをホストとしてコンテナが稼働している（ドキュメントに記載がないが，AWSサポートに確認済み）．

参考：https://aws.amazon.com/jp/blogs/news/under-the-hood-fargate-data-plane/

![fargate_data-plane](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fargate_data-plane.png)

#### ・コンテナエージェント

コンテナ内で稼働し，コンテナの操作を行うプログラムのこと．

#### ・コンテナ定義の詳細

タスク内のコンテナ一つに対して，環境を設定する．

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/task_definition_parameters.html

| 設定項目                         | 対応するdockerコマンドオプション             | 説明                                                         | 補足                                                         |
| -------------------------------- | -------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| cpu                              | ```--cpus```                                 | タスク全体に割り当てられたCPUのうち，該当のコンテナに割り当てるCPU分を設定する． |                                                              |
| dnsServers                       | ```--dns```                                  | コンテナが名前解決に使用するDNSサーバのIPアドレスを設定する． |                                                              |
| essential                        |                                              | コンテナが必須か否かを設定する．                             | ・```true```の場合，コンテナが停止すると，タスクに含まれる全コンテナが停止する．<br>```false```の場合，コンテナが停止しても，その他のコンテナは停止しない． |
| healthCheck<br>(command)         | ```--health-cmd```                           | ホストマシンからFargateに対して，```curl```コマンドによるリクエストを送信し，レスポンス内容を確認． |                                                              |
| healthCheck<br>(interval)        | ```--health-interval```                      | ヘルスチェックの間隔を設定する．                             |                                                              |
| healthCheck<br>(retries)         | ```--health-retries```                       | ヘルスチェックを成功と見なす回数を設定する．                 |                                                              |
| hostName                         | ```--hostname```                             | コンテナにホスト名を設定する．                               |                                                              |
| image                            |                                              | ECRのURLを設定する．                                         |                                                              |
| logConfiguration<br/>(logDriver) | ```--log-driver```                           | ログドライバーを指定することにより，ログの出力先を設定する． | Dockerのログドライバーにおおよそ対応しており，Fargateであれば『awslogs，awsfirelens，splunk』に設定できる．EC2であれば『awslogs，json-file，syslog，journald，fluentd，gelf，logentries』を設定できる． |
| logConfiguration<br/>(options)   | ```--log-opt```                              | ログドライバーに応じて，詳細な設定を行う．                   |                                                              |
| portMapping                      | ```--publish```<br>```--expose```            | ホストマシンとFargateのアプリケーションのポート番号をマッピングし，ポートフォワーディングを行う． | ```containerPort```のみを設定し，```hostPort```は設定しなければ，EXPOSEとして定義できる．<br>参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/APIReference/API_PortMapping.html |
| secrets<br>(volumesFrom)         |                                              | SSMパラメータストアから出力する変数を設定する．              |                                                              |
| memory                           | ```--memory```<br>```--memory-reservation``` | タスク全体に割り当てられたメモリのうち，該当のコンテナに割り当てるメモリ分を設定する． |                                                              |
| mountPoints                      |                                              |                                                              |                                                              |
| ulimit                           | Linuxコマンドの<br>```--ulimit```に相当      |                                                              |                                                              |

#### ・awslogsドライバー

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/using_awslogs.html#create_awslogs_logdriver_options

| 設定項目                      | 説明                                                         | 補足                                                         |
| ----------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ```awslogs-group```           | ログ送信先のCloudWatchログのロググループを設定する．         |                                                              |
| ```awslogs-datetime-format``` | 日時フォーマットを定義し，またこれをログの区切り単位としてログストリームに出力する． | 正規表現で設定する必要があり，さらにJSONでは『```\```』を『```\\```』にエスケープしなければならない．例えば『```\\[%Y-%m-%d %H:%M:%S\\]```』となる．<br>参考：https://docs.docker.com/config/containers/logging/awslogs/#awslogs-datetime-format |
| ```awslogs-region```          | ログ送信先のCloudWatchログのリージョンを設定する．           |                                                              |
| ```awslogs-stream-prefix```   | ログ送信先のCloudWatchログのログストリームのプレフィックス名を設定する． | ログストリームには，『<プレフィックス名>/<コンテナ名>/<タスクID>』の形式で送信される． |

#### ・割り当てられるプライベートIPアドレス

タスクごとに異なるプライベートIPが割り当てられる．このIPアドレスに対して，ALBはルーティングを行う．

<br>

### ロール

#### ・サービスロール

サービス機能がタスクを操作するために必要なロールのこと．サービスリンクロールに含まれ，ECSの構築時に自動的にアタッチされる．

#### ・タスクロール

タスク内のコンテナのアプリケーションが，他のリソースにアクセスするために必要なロールのこと．アプリケーションにS3やSSMへのアクセス権限を与えたい場合は，タスク実行ロールではなくタスクロールに権限をアタッチする．

**＊実装例＊**

アプリケーションからCloudWatchログにログを送信するために，ECSタスクロールにカスタマー管理ポリシーをアタッチする．

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
```

**＊実装例＊**

SSMパラメータストアから変数を取得するために，ECSタスクロールにインラインポリシーをアタッチする．

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "*"
        }
    ]
}
```

#### ・タスク実行ロール

タスク上に存在するコンテナエージェントが，他のリソースにアクセスするために必要なロールのこと．AWS管理ポリシーである『```AmazonECSTaskExecutionRolePolicy```』がアタッチされたロールを，タスクにアタッチする必要がある．このポリシーには，ECRへのアクセス権限の他，CloudWatchログにログを生成するための権限が設定されている．タスク内のコンテナがリソースにアクセスするために必要なタスクロールとは区別すること．

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

**＊実装例＊**

Datadogエージェントがクラスターやコンテナにアクセスできるように，ECSタスク実行ロールにカスタマー管理ポリシーをアタッチする．

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecs:ListClusters",
                "ecs:ListContainerInstances",
                "ecs:DescribeContainerInstances"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
```

<br>

### ネットワークモードとコンテナ間通信

#### ・noneモード

外部ネットワークが無く，タスクと外と通信できない．

#### ・hostモード

Dockerのhostネットワークに相当する．

![network-mode_host-mode](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/network-mode_host-mode.png)

#### ・bridgeモード

Dockerのbridgeネットワークに相当する．

![network-mode_host-mode](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/network-mode_host-mode.png)

#### ・awsvpcモード

awsの独自ネットワークモード．タスクはElastic Networkインターフェースと紐づけられ，Primary プライベートIPアドレスを割り当てられる．同じタスクに属するコンテナ間は，localhostインターフェイスというENI経由で通信できるようになる（推測ではあるが，Fargate環境でコンテナのホストとなるEC2インスタンスにlocalhostインターフェースが関連付けられる）．これにより，コンテナからコンテナにリクエストを転送するとき（例：NginxコンテナからPHP-FPMコンテナへの転送）は，転送元コンテナにて，転送先のアドレスを『localhost（```127.0.0.1```）』で指定すれば良い．また，awsvpcモードの独自の仕組みとして，同じタスク内であれば，互いにコンテナポートを開放せずとも，プロセスのリッスンするポートを指定するだけでコンテナ間通信が可能である．例えば，NginxコンテナからPHP-FPMコンテナにリクエストを転送するためには，PHP-FPMプロセスが```9000```番ポートをリッスンし，さらにコンテナが```9000```番ポートを開放する必要がある．しかし，awsvpcモードではコンテナポートを開放する必要はない．

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/fargate-task-networking.html

![network-mode_awsvpc](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/network-mode_awsvpc.png)

<br>

### タスクのデプロイ方法の種類

#### ・ローリングアップデート

![rolling-update](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/rolling-update.png)

参考：https://toris.io/2021/04/speeding-up-amazon-ecs-container-deployments/

1. 最小ヘルス率の設定値に基づいて，ローリングアップデート時の稼働中タスクの最低合計数が決定される．
2. 最大率の設定値に基づいて，ローリングアップデート時の稼働中／停止中タスクの最高合計数が決まる
3. ECSは，既存タスクを稼働中のまま，新タスクを最高合計数いっぱいまで構築する．
4. ECSは，猶予期間後にALB／NLBによる新タスクに対するヘルスチェックの結果を確認する．ヘルスチェックが成功していれば，既存タスクを停止する．ただし，最小ヘルス率によるタスクの最低合計数が保たれる．
5. 『新タスクの起動』と『ヘルスチェック確認後の既存タスクの停止』のプロセスが繰り返し実行され，徐々に既存タスクが新タスクに置き換わる．
6. 全ての既存タスクが新タスクに置き換わる．

#### ・Blue/Greenデプロイメント

CodeDeployを使用してデプロイを行う．本ノート内を検索せよ．

<br>

### プライベートなECSタスクのアウトバウンド通信

#### ・プライベートサブネットからの通信

プライベートサブネットにECSタスクを配置した場合，アウトバウンドな通信を実行するためには，NAT GatewayまたはVPCエンドポイントを配置する必要がある．パブリックサブネットに配置すればこれらは不要となるが，パブリックサブネットよりもプライベートサブネットにECSタスクを配置する方が望ましい．

#### ・NAT Gatewayを経由

FargateからECRに対するDockerイメージのプルは，VPCの外側に対するアウトバウンド通信（グローバルネットワーク向き通信）である．以下の通り，NAT Gatewayを設置したとする．この場合，ECSやECRとのアウトバウンド通信がNAT Gatewayを通過するため，高額料金を請求されてしまう．

![ecs_nat-gateway](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ecs_nat-gateway.png)

#### ・VPCエンドポイントを経由

VPCエンドポイントを設け，これに対してアウトバウンド通信を行うようにするとよい．なお，NAT GatewayとVPCエンドポイントの両方を構築している場合，ルートテーブルでは，VPCエンドポイントへのアウトバウンド通信の方が優先される．料金的な観点から，NAT GatewayよりもVPCエンドポイントを経由した方がよい．

![ecs_vpc-endpoint](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ecs_vpc-endpoint.png)

| VPCエンドポイントの接続先 | プライベートDNS名                                            | 説明                                               |
| ------------------------- | ------------------------------------------------------------ | -------------------------------------------------- |
| CloudWatchログ            | ```logs.ap-northeast-1.amazonaws.com```                      | ECSコンテナのログをPOSTリクエストを送信するため．  |
| ECR                       | ```api.ecr.ap-northeast-1.amazonaws.com```<br>```*.dkr.ecr.ap-northeast-1.amazonaws.com``` | イメージのGETリクエストを送信するため．            |
| S3                        | なし                                                         | イメージのレイヤーをPOSTリクエストを送信するため   |
| SSMパラメータストア       | ```ssm.ap-northeast-1.amazonaws.com```<br>                   | SSMパラメータストアにGETリクエストを送信するため． |
| SSMシークレットマネージャ | ```ssmmessage.ap-northeast-1.amazonaws.com```                | シークレットマネージャの機能を使用するため．       |

<br>

### FireLensコンテナ

#### ・FireLensコンテナとは

以下のノートを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_fluentd_and_fluentbit.html

<br>

### Tips

#### ・割り当てられるパブリックIPアドレス，FargateのIPアドレス問題

FargateにパブリックIPアドレスを持たせたい場合，Elastic IPアドレスの設定項目がなく，動的パブリックIPアドレスしか設定できない（Fargateの再構築後に変化する）．アウトバウンド通信の先にある外部サービスが，セキュリティ上で静的なIPアドレスを要求する場合，アウトバウンド通信（グローバルネットワーク向き通信）時に送信元パケットに付加されるIPアドレスが動的になり，リクエストができなくなってしまう．

![NatGatewayを介したFargateから外部サービスへのアウトバウンド通信](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/NatGatewayを介したFargateから外部サービスへのアウトバウンド通信.png)

そこで，Fargateのアウトバウンド通信が，Elastic IPアドレスを持つNAT Gatewayを経由するようにする（Fargateは，パブリックサブネットとプライベートサブネットのどちらに置いても良い）．これによって，Nat GatewayのElastic IPアドレスが送信元パケットに付加されるため，Fargateの送信元IPアドレスを見かけ上静的に扱うことができるようになる．

参考：https://aws.amazon.com/jp/premiumsupport/knowledge-center/ecs-fargate-static-elastic-ip-address/

<br>

## 14. EFS：Elastic File System

![EFSのファイル共有機能](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/EFSのファイル共有機能.png)

### EFSとは

マウントターゲットと接続された片方のEC2インスタンスから，ファイルを読み込み，これをもう一方に出力する．ファイルの実体はいずれかのEC2に存在しているため，接続を切断している間，片方のEC2インスタンス内のファイルは無くなる．再接続すると，切断直前のファイルが再び表示されようになる．

<br>

### 設定項目

#### ・一覧

| 設定項目                 | 説明                                                         | 補足                                                         |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| パフォーマンスモード     |                                                              |                                                              |
| スループットモード       | EFSのスループット性能を設定する．                            |                                                              |
| ライフサイクルポリシー   | しばらくリクエストされていないファイルが低頻度アクセス（IA：Infrequent Access）ストレージクラスに移動保存するまでの期限を設定する． | ・ライフサイクルポリシーを有効にしない場合，スタンダードストレージクラスのみが使用される．<br>・画面から両ストレージの使用量を確認できる．<br>参考：https://ap-northeast-1.console.aws.amazon.com/efs/home?region=ap-northeast-1#/file-systems/fs-f77d60d6 |
| ファイルシステムポリシー | 他のAWSリソースがEFSを利用する時のポリシーを設定する．       |                                                              |
| 自動バックアップ         | AWS Backupに定期的に保存するかどうかを設定する．             |                                                              |
| ネットワーク             | マウントターゲットを設置するサブネット，セキュリティグループを設定する． | ・サブネットは，ファイル供給の速度の観点から，マウントターゲットにアクセスするAWSリソースと同じにする．<br>・セキュリティグループは，EC2からのNFSプロトコルアクセスを許可したものを設定する．EC2のセキュリティグループを通過したアクセスだけを許可するために，IPアドレスでは，EC2のセキュリティグループを設定する． |

<br>

### スペック

#### ・バーストモードの仕組み

スループット性能の自動スケーリングに残高があり，ベースラインを超過した分だけ自動スケーリング残高が減っていく．また，ベースライン未満の分は残高として蓄積されていく．

![burst-mode_balance](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/burst-mode_credit-balance-algorithm.png)

元々の残高は，ファイルシステムのスタンダードストレージクラスの容量に応じて大きくなる．

参考：https://docs.aws.amazon.com/ja_jp/efs/latest/ug/performance.html#efs-burst-credits

![burst-mode_credit](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/burst-mode_credit-balance-size.png)

残高は，```BurstCreditBalance```メトリクスから確認できる．このメトリクスが常に減少し続けている場合はプロビジョニングモードの方がより適切である．

参考：https://docs.aws.amazon.com/ja_jp/efs/latest/ug/performance.html#using-throughputmode

#### ・プロビジョニングモードの仕組み

スループット性能の自動スケーリング機能は無いが，一定の性能は保証されている．

参考：https://docs.aws.amazon.com/ja_jp/efs/latest/ug/performance.html#provisioned-throughput

![burst-mode_credit](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/provisioning-mode_credit-balance-size.png)

<br>

### コマンド

#### ・マウント

DNS経由で，EFSマウントヘルパーを使用した場合を示す．

```bash
$ mount -t <ファイルシステムタイプ> -o tls <ファイルシステムID>:/ <マウントポイント>
```

```bash
# EFSで，マウントポイントを登録
$ mount -t efs -o tls fs-xxxxx:/ /var/www/app

# マウントポイントを解除
$ umount /var/www/app

# dfコマンドでマウントしているディレクトリを確認できる
$ df
Filesystem                                1K-blocks Used Available Use% Mounted on
fs-xxx.efs.ap-northeast-1.amazonaws.com:/ xxx       xxx  xxx       1%   /var/www/cerenavi
```

<br>

## 15. ElastiCache

### ElasticCacheとは

アプリケーションの代わりに，セッション，クエリCache，を管理する．RedisとMemcachedがある．

<br>

### Redisの設定項目

![Redis](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Redis.png)

| 設定項目                         | 説明                                                         | 補足                                                         |
| -------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| クラスターエンジン               | キャッシュエンジンを設定する．Redis通常モード，Redisクラスターモードから選択する． | Redisクラスターモードと同様に，Redis通常モードもクラスター構成になる．ただ，クラスターモードとはクラスターの構成方法が異なる． |
| ロケーション                     |                                                              |                                                              |
| エンジンバージョンの互換性       | 選んだキャッシュエンジンのバージョンを設定する．             | マイナーバージョンが自動的に更新されないように，例えば『6.x』は設定しない方がよい． |
| パラメータグループ               | グローバルパラメータを設定する．                             | デフォルトを使用せずに独自定義する場合，事前に構築しておく必要がある． |
| ノードのタイプ                   |                                                              |                                                              |
| レプリケーション数               | プライマリノードとは別に，リードレプリカノードをいくつ構築するかを設定する． | マルチAZにプライマリノードとリードレプリカノードを一つずつ配置させる場合，ここでは『１個』を設定する． |
| マルチAZ                         | プライマリノードとリードレプリカを異なるAZに配置するかどうかを設定する．合わせて，自動フェールオーバーを実行できるようになる． |                                                              |
| サブネットグループ               | Redisにアクセスできるサブネットを設定する．                  |                                                              |
| セキュリティ                     | セキュリティグループを設定する．                             |                                                              |
| クラスターへのデータのインポート | あらかじめ作成しておいたバックアップをインポートし，これを元にRedisを構築する． | キャッシュデータを引き継ぐことができる．そのため，新しいRedisへのセッションファイルの移行に役立つ．新しいRedisを構築する例としては，Redisのアップグレード時に，セッションIDを引き継いだアップグレード後のRedisを別途構築し，アプリケーションの向き先を古いRedisから新しいRedisに変える，といった状況がある． |
| バックアップ                     | バックアップの有効化，保持期間，時間を設定する．             | バックアップを取るほどでもないため，無効化しておいて問題ない． |
| メンテナンス                     | メンテナンスの時間を設定する．                               |                                                              |

<br>

### セッション管理機能

#### ・仕組み

サーバ内のセッションファイルの代わりにセッションIDを管理し，冗長化されたアプリケーション間で共通のセッションIDを使用できるようにする．セッションIDについては，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_api_restful.html

![ElastiCacheのセッション管理機能](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ElastiCacheのセッション管理機能.png)

<br>

### クエリCache管理機能

#### ・仕組み

RDSに対するSQLと読み出されたデータを，キャッシュとして管理する．

![クエリCache管理機能_1](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/クエリCache管理機能_1.png)

1. アプリケーションは，RDSの前に，Redisに対してSQLを実行する．

```sql
SELECT * FROM users;
```

2. 始めて実行されたSQLの場合，RedisはSQLをキーとして保存し，Cacheが無いことがアプリケーションに返却する．
3. アプリケーションはRDSに対してSQLを実行する．
4. データが読み出される．
5. アプリケーションはRedisにデータを登録する．

```bash
# ElastiCacheには，SQLの実行結果がまだ保存されていない

*** no cache ***
{"id"=>"1", "name"=>"alice"}
{"id"=>"2", "name"=>"bob"}
{"id"=>"3", "name"=>"charles"}
{"id"=>"4", "name"=>"donny"}
{"id"=>"5", "name"=>"elie"}
{"id"=>"6", "name"=>"fabian"}
{"id"=>"7", "name"=>"gabriel"}
{"id"=>"8", "name"=>"harold"}
{"id"=>"9", "name"=>"Ignatius"}
{"id"=>"10", "name"=>"jonny"}
```

![クエリCache管理機能_2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/クエリCache管理機能_2.png)

6. 次回，アプリケーションは，RDSの前に，Redisに対してSQLを実行する．

```sql
SELECT * FROM users;
```

7. Redisは，SQLをキーにしてデータを特定し，アプリケーションに返却する．

```bash
# ElastiCacheには，SQLの実行結果が既に保存されている

*** cache hit ***
{"id"=>"1", "name"=>"alice"}
{"id"=>"2", "name"=>"bob"}
{"id"=>"3", "name"=>"charles"}
{"id"=>"4", "name"=>"donny"}
{"id"=>"5", "name"=>"elie"}
{"id"=>"6", "name"=>"fabian"}
{"id"=>"7", "name"=>"gabriel"}
{"id"=>"8", "name"=>"harold"}
{"id"=>"9", "name"=>"Ignatius"}
{"id"=>"10", "name"=>"jonny"}
```

#### ・クエリCacheの操作

```bash
# Redis接続コマンド
$ /usr/local/sbin/redis-stable/src/redis-cli \
  -c
  -h <Redisのホスト名>
  -p 6379
```

```bash
# Redis接続中の状態
# 全てのキーを表示
redis xxxxx:6379> keys *
```

```bash
# Redis接続中の状態
# キーを指定して，対応する値を表示
redis xxxxx:6379> type <キー名>
```

```bash
# Redis接続中の状態
# Redisが受け取ったコマンドをフォアグラウンドで表示
redis xxxxx:6379> monitor
```

<br>

### Redisの障害対策

#### ・フェイルオーバー

ノードの障害を検知し，障害が発生したノードを新しいものに置き換えることができる．

| 障害の発生したノード | 挙動                                                         |
| -------------------- | ------------------------------------------------------------ |
| プライマリノード     | リードレプリカの一つがプライマリノードに昇格し，障害が起きたプライマリノードと置き換えられる． |
| リードレプリカノード | 障害が起きたリードレプリカノードが，別の新しいものに置き換えられる． |

<br>

### ノードのダウンタイム

バックアップとインポート機能を使用して，セッションIDを引き継いだアップグレード後のRedisを別途構築する．その後，アプリケーションの向き先を古いRedisから新しいRedisに変えるようにすると，ダウンタイムを最小限にしてアップグレードできる．

| 状況                     | ダウンタイム                          |
| ------------------------ | ------------------------------------- |
| サービスのアップグレード | 1分30秒ほどのダウンタイムが発生する． |

<br>

## 16. EventBridge（CloudWatchイベント）

### EventBridge（CloudWatchイベント）とは

AWSリソースで起こったイベントを，他のAWSリソースに転送する．サポート対象のAWSリソースは以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/eventbridge/latest/userguide/what-is-amazon-eventbridge.html

<br>

### パターン

#### ・イベントパターン

指定したAWSリソースでイベントが起こると，以下のようなJSONが送信される．イベントパターンを定義し，JSON構造が一致するイベントのみをターゲットに転送する．イベントパターンに定義しないキーは任意のデータと見なされる．

参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html

```bash
{
  "version": "0",
  "id": "*****",
  "detail-type": "<イベント名>",
  "source": "aws.<AWSリソース名>",
  "account": "*****",
  "time": "2021-01-01T00:00:00Z",
  "region": "us-west-1",
  "resources": [
    "<イベントを起こしたリソースのARN>"
  ],
  "detail": {
    // その時々のイベントごとに異なるデータ
  }
}
```

**＊実装例＊**

Amplifyの指定したIDのアプリケーションが，```Amplify Deployment Status Change```のイベントを送信し，これの```jobStatus```が```SUCCEED```／```FAILED```だった場合に，これを転送する．

```bash
{
  "detail": {
    "appId": [
      "foo",
      "bar"
    ],
    "jobStatus": [
      "SUCCEED",
      "FAILED"
    ]
  },
  "detail-type": [
    "Amplify Deployment Status Change"
  ],
  "source": "aws.amplify"
}
```

#### ・スケジュール

cron式またはrate式を使用し，定期ジョブを定義づける．これとLambdaを組み合わせることにより，バッチ処理を構築できる．

参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/events/ScheduledEvents.html

<br>

### ターゲット

#### ・ターゲットの一覧

参考：https://docs.aws.amazon.com/ja_jp/eventbridge/latest/userguide/eb-targets.html

#### ・デバッグ

EventBridgeでは，どのようなJSONのイベントをターゲットに転送したかを確認できない．そこで，デバッグ時はEventBridgeのターゲットにLambdaを設定し，イベント構造をログから確認する．

**＊実装例＊**

あらかじめ，イベントの内容を出力する関数をLambdaに作成しておく．

```javascript
// Lambdaにデバッグ用の関数を用意する
exports.handler = async (event) => {
    console.log(JSON.stringify({event}, null, 2));
};
```

対象のAWSリソースで任意のイベントが起こった時に，EventBridgeからLambdaに転送するように設定する．

```bash
{
  "source": "aws.amplify"
}
```

AWSリソースで意図的にイベントを起こし，Lambdaのロググループから内容を確認する．```detail```キーにイベントが割り当てられている．

```bash
{
    "event": {
        "version": "0",
        "id": "b4a07570-eda1-9fe1-da5e-b672a1705c39",
        "detail-type": "Amplify Deployment Status Change",
        "source": "aws.amplify",
        "account": "<AWSアカウントID>",
        "time": "<イベントの発生時間>",
        "region": "<リージョン>",
        "resources": [
            "<AmplifyのアプリケーションのARN>"
        ],
        "detail": {
            "appId": "<アプリケーションID>",
            "branchName": "<ブランチ名>",
            "jobId": "<ジョブID>",
            "jobStatus": "<CI/CDのステータス>"
        }
    }
}
```

<br>

### 入力

#### ・入力トランスフォーマー

入力パスで使用する値を抽出し，入力テンプレートで転送するJSONを定義できる．イベントのJSONの値を変数として出力できる．```event```キーをドルマークとして，ドットで繋いでアクセスする．

**＊実装例＊**

入力パスにて，使用する値を抽出する．Amplifyで起こったイベントのJSONを変数として取り出す．JSONのキー名が変数名として機能する．

```bash
{
  "appId": "$.detail.appId",
  "branchName": "$.detail.branchName",
  "jobId": "$.detail.jobId",
  "jobStatus": "$.detail.jobStatus",
  "region": "$.region"
}
```

入力テンプレートにて，転送するJSONを定義する．例えばここでは，Slackに送信するJSONに出力する．出力するときは，入力パスの変数名を『```<>```』で囲う．Slackに送信するメッセージの作成ツールは，以下のリンクを参考にせよ．

参考：https://app.slack.com/block-kit-builder

```bash
{
  "channel": "XXXXXX",
  "text": "Amplifyデプロイ完了通知",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ":github: プルリク検証用環境"
      }
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": "*結果*: <jobStatus>"
        }
      ]
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": "*ブランチ名*: <branchName>"
        }
      ]
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": "*検証URL*: https://<branchName>.<appId>.amplifyapp.com"
        }
      ]
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": ":amplify: <https://<region>.console.aws.amazon.com/amplify/home?region=<region>#/<appId>/<branchName>/<jobId>|*Amplifyコンソール画面はこちら*>"
        }
      ]
    },
    {
      "type": "divider"
    }
  ]
}
```

<br>

## 17. Global Accelerator

### 設定項目

#### ・基本的設定の詳細

| 設定項目           | 説明                                                         | 補足                                                         |
| ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Accelerator タイプ | エンドポイントグループへのルーティング時のアルゴリズムを設定する． | Standard：ユーザに最も近いリージョンにあるエンドポイントグループに，リクエストがルーティングされる． |
| IPアドレスプール   | Global Acceleratorに割り当てる静的IPアドレスを設定する．     |                                                              |

#### ・リスナーの詳細

| 設定項目        | 説明                                               | 補足                                                         |
| --------------- | -------------------------------------------------- | ------------------------------------------------------------ |
| ポート          | ルーティング先のポート番号を設定する．             |                                                              |
| プロトコル      | ルーティング先のプロトコルを設定する．             |                                                              |
| Client affinity | ユーザごとにルーティング先を固定するかを設定する． | ・None：複数のルーティング先があった場合，各ユーザの毎リクエスト時のルーティング先は固定されなくなる．<br>・Source IP：複数のルーティング先があったとしても，各ユーザの毎リクエスト時のルーティング先を固定できるようになる． |

#### ・エンドポイントグループの詳細

| 設定項目               | 説明                                                         | 補足                                                         |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| エンドポイントグループ | 特定のリージョンに関連付くエンドポイントのグループを設定する． | トラフィックダイヤルにて，各エンドポイントグループの重みを設定できる． |
| トラフィックダイヤル   | 複数のエンドポイントグループがある場合，それぞれの重み（%）を設定する． | ・例えば，カナリアリリースのために，新アプリと旧アプリへのルーティングに重みを付ける場合に役立つ． |
| ヘルスチェック         | ルーティング先に対するヘルスチェックを設定する．             |                                                              |

#### ・エンドポイントの詳細

| 設定項目                     | 説明                                                         | 補足                                                         |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| エンドポイントタイプ         | ルーティング先のAWSリソースを設定する．                      | ALB，NLB，EC2，Elastic IPを選択できる．                      |
| 重み                         | 複数のエンドポイントがある場合，それぞれの重みを設定する．   | 各エンドポイントの重みの合計値を256とし，1～255で相対値を設定する． |
| クライアントIPアドレスの保持 | ```X-Forwarded-For```ヘッダーにクライアントIPアドレスを含めて転送するかどうかを設定する． |                                                              |

<br>

### 素早いレスポンスの理由

![GlobalAccelerator](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/GlobalAccelerator.png)

最初，クライアントPCからのリクエストはエッジロケーションで受信される．プライベートネットワーク内のエッジロケーションを経由して，ルーティング先のリージョンまで届く．パブリックネットワークを使用しないため，小さなレイテシーでトラフィックをルーティングできる．

![GlobalAccelerator導入後](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/GlobalAccelerator導入後.png)

Global Acceleratorを使用しない場合，クライアントPCのリージョンから指定したリージョンに至るまで，いくつもパブリックネットワークを経由する必要があり，時間がかかってしまう．

![GlobalAccelerator導入前](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/GlobalAccelerator導入前.png)

以下のサイトで，Global Acceleratorを使用した場合としなかった場合のレスポンス速度を比較できる．

参考：https://speedtest.globalaccelerator.aws/#/

<br>

## 18. IAM：Identify and Access Management

### IAM

#### ・IAMとは

AWSリソースへのアクセスに関する認証と認可を制御する．認証はアクセスキーとシークレットアクセスキーによって，また認可はIAMロール／IAMポリシー／IAMステートメントによって制御される．

#### ・IAMロールとは

IAMポリシーのセットを定義する．

#### ・IAMポリシーとは

IAMステートメントのセットを定義する．

| IAMポリシーの種類                  | 説明                                                         |
| ---------------------------------- | ------------------------------------------------------------ |
| アイデンティティベースのポリシー   | IAMユーザ，IAMグループ，IAMロール，にアタッチするためのポリシーのこと． |
| リソースベースのインラインポリシー | 単一のAWSリソースにインポリシーのこと．                      |
| アクセスコントロールポリシー       | json形式で定義する必要が無いポリシーのこと．                 |

**＊具体例＊**

以下に，EC2の読み出しのみ権限（```AmazonEC2ReadOnlyAccess```）をアタッチできるポリシーを示す．このIAMポリシーには，他のAWSリソースに対する権限も含まれている．

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "elasticloadbalancing:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:Describe*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "autoscaling:Describe*",
      "Resource": "*"
    }
  ]
}
```

####  ・IAMステートメントとは

AWSリソースに関する認可のスコープを定義する．各アクションについては以下のリンクを参考にせよ．

| AWSリソースの種類 | リンク                                                       |
| ----------------- | ------------------------------------------------------------ |
| CloudWatchログ    | https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/logs/permissions-reference-cwl.html |

**＊具体例＊**

以下のインラインポリシーがアタッチされたロールを持つAWSリソースは，任意のSSMパラメータを取得できるようになる．

```yaml
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
```

| Statementの項目 | 説明                                             |
| --------------- | ------------------------------------------------ |
| Sid             | 任意の一意な文字列を設定する．空文字でもよい．   |
| Effect          | 許可／拒否を設定する．                           |
| Action          | リソースに対して実行できるアクションを設定する． |
| Resource        | アクションの実行対象に選べるリソースを設定する． |


以下に主要なアクションを示す．

| アクション名 | 説明                   |
| ------------ | ---------------------- |
| Create       | リソースを構築する．   |
| Describe     | リソースを表示する．   |
| Delete       | リソースを削除する．   |
| Get          | リソースを取得する．   |
| Put          | リソースを上書きする． |

#### ・ARNとは：Amazon Resource Namespace

AWSリソースの識別子のこと．

参考：https://docs.aws.amazon.com/ja_jp/general/latest/gr/aws-arns-and-namespaces.html

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Resource": "arn:<パーティション>:<AWSリソース>:<リージョン>:<アカウントID>:<AWSリソースID>"
    }
  ]
}
```

<br>

### IAMロール

#### ・サービスリンクロール

AWSリソースを構築した時に自動的に作成されるロール．他にはアタッチできない専用のポリシーがアタッチされている．『```AWSServiceRoleFor*****```』という名前で自動的に構築される．特に設定せずとも，自動的にリソースにアタッチされる．関連するリソースを削除するまで，ロール自体できない．サービスリンクロールの一覧については，以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html

#### ・クロスアカウントのアクセスロール  

#### ・プロバイダのアクセスロール  

<br>

### アイデンティティベースのポリシー

#### ・アイデンティティベースのポリシーとは

IAMユーザ，IAMグループ，IAMロール，にアタッチするためのポリシーのこと．

#### ・AWS管理ポリシー

AWSが提供しているポリシーのこと．アタッチ式のポリシーのため，すでにアタッチされていても，他のものにもアタッチできる．

#### ・カスタマー管理ポリシー

ユーザが独自に構築したポリシーのこと．すでにアタッチされていても，他のものにもアタッチできる．

#### ・インラインポリシー

単一のアイデンティティにアタッチするためのポリシーのこと．組み込み式のポリシーのため，アイデンティティ間で共有してアタッチすることはできない．

**＊実装例＊**

IAMロールにインラインポリシーをアタッチする．このロールを持つユーザは，ユーザーアカウントのすべての ACM 証明書を一覧表示できるようになる．

```bash
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":"acm:ListCertificates",
      "Resource":"*"
    }
  ]
}
```

**＊実装例＊**

IAMロールにインラインポリシーをアタッチする．このロールを持つユーザは，全てのAWSリソースに，任意のアクションを実行できる．

```bash
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":"*",
      "Resource":"*"
    }
  ]
}
```

<br>

### リソースベースのインラインポリシー

#### ・リソースベースのインラインポリシーとは

単一のAWSリソースにインポリシーのこと．すでにアタッチされていると，他のものにはアタッチできない．

#### ・バケットポリシー

S3にアタッチされる，自身へのアクセスを制御するためのインラインポリシーのこと．

#### ・ライフサイクルポリシー

ECRにアタッチされる，イメージの有効期間を定義するポリシー．コンソール画面から入力できるため，基本的にポリシーの実装は不要であるが，TerraformなどのIaCツールでは必要になる．

**＊実装例＊**

```bash
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images untagged",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep last 10 images any",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

#### ・信頼ポリシー

ロールにアタッチされる，Assume Roleを行うためのインラインポリシーのこと．

**＊実装例＊**

例えば，以下の信頼ポリシーを任意のロールにアタッチしたとする．その場合，```Principal```の```ecs-tasks```が信頼されたエンティティと見なされ，ロールをアタッチできるようになる．

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

信頼ポリシーでは，IAMユーザを信頼されたエンティティとして設定することもできる．

**＊実装例＊**

例えば，以下の信頼ポリシーを任意のロールにアタッチしたとする．その場合，```Principal```のIAMユーザが信頼されたエンティティと見なされ，ロールをアタッチできるようになる．

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<アカウントID>:user/<ユーザ名>"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "<適当な文字列>"
        }
      }
    }
  ]
}
```

<br>

### IAMポリシーをアタッチできる対象

#### ・IAMユーザに対するアタッチ

![IAMユーザにポリシーを付与](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/IAMユーザにポリシーを付与.jpeg)

#### ・IAMグループに対するアタッチ

![IAMグループにポリシーを付与](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/IAMグループにポリシーを付与.jpeg)

#### ・IAMロールに対するアタッチ

![IAMロールにポリシーを付与](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/IAMロールにポリシーを付与.jpeg)

<br>

### ルートユーザ，IAMユーザ

#### ・ルートユーザとは

全ての権限をもったアカウントのこと．

#### ・IAMユーザとは

特定の権限をもったアカウントのこと．

#### ・```credentials```ファイルを使用したCLI

AWS CLIでクラウドインフラを操作するためには，```credentials```ファイルに定義されたクレデンシャル情報が必要である．『```aws_region```』ではなく『```aws_default_region```』であることに注意する．

```bash
$ aws configure set aws_access_key_id "<アクセスキー>"
$ aws configure set aws_secret_access_key "<シークレットキー>"
$ aws configure set aws_default_region "リージョン>"
```

```bash
# Linux，Unixの場合：$HOME/.aws/<credentialsファイル名>
# Windowsの場合：%USERPROFILE%\.aws\<credentialsファイル名>

[default]
aws_access_key_id=<アクセスキー>
aws_secret_access_key=<シークレットキー>

[user1]
aws_access_key_id=<アクセスキー>
aws_secret_access_key=<シークレットキー>
```

#### ・環境変数を使用したCLI

AWS CLIでクラウドインフラを操作するためには，環境変数で定義されたクレデンシャル情報が必要である．『```AWS_REGION```』ではなく『```AWS_DEFAULT_REGION```』であることに注意する．

```bash
$ export AWS_ACCESS_KEY_ID=<アクセスキー>
$ export AWS_SECRET_ACCESS_KEY=<シークレットキー>
$ export AWS_DEFAULT_REGION=<リージョン>
```

<br>

### IAMグループ

#### ・IAMグループとは

IAMユーザをグループ化したもの．IAMグループごとにIAMロールをアタッチすれば，IAMユーザのIAMロールを管理しやすくなる．

![グループ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/グループ.png)

#### ・IAMグループへのIAMロールの紐付け

IAMグループに対して，IAMロールを紐づける．そのIAMグループに対して，IAMロールをアタッチしたいIAMユーザを追加していく．

![グループに所属するユーザにロールを付与](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/グループに所属するユーザにロールを付与.png)

#### ・グループ一覧

| 種類            | 説明                       | 補足 |
| --------------- | -------------------------- | ---- |
| Administrator   | 全ての操作に権限がある．   |      |
| PowerUserAccess | IAM以外の操作権限がある．  |      |
| ViewOnlyAccess  | 閲覧のみの操作権限がある． |      |

<br>

### CLI

#### ・CLIの社内アクセス制限

特定の送信元IPアドレスを制限するポリシーをIAMユーザにアタッチすることで，そのIAMユーザがAWS CLIの実行する時に，社外から実行できないように制限をかけられる．

**＊実装例＊**

```bash
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Deny",
    "Action": "*",
    "Resource": "*",
    "Condition": {
      "NotIpAddress": {
        "aws:SourceIp": [
          "nn.nnn.nnn.nnn/32"
        ]
      }
    }
  }
}
```

#### ・ユーザ名を変更

ユーザ名は，コンソール画面から変更できず，コマンドで変更する必要がある．

```bash
$ aws iam update-user --user-name <現行のユーザ名> --new-user-name <新しいユーザ名>
```

<br>

## 19. Kinesis

### Kinesisとは

ストリーミングデータ（動画データ，音声データ，など）を受信し，リアルタイムで継続的に収集／加工／解析を実行する．ちなみに，

参考：https://docs.aws.amazon.com/ja_jp/kinesis/index.html

<br>

## 20. Lambda

### Lambdaとは

他のAWSリソースのイベントによって駆動する関数を管理できる．ユースケースについては，以下のリンクを参考にせよ．

参考：参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/applications-usecases.html

![サーバレスアーキテクチャとは](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/サーバレスアーキテクチャとは.png)

<br>

### 設定項目

#### ・一覧

| 設定項目                           | 説明                                                         | 補足                                                         |
| ---------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ランタイム                         | 関数の実装に使用する言語を設定する．                         | コンテナイメージの関数では使用できない．                     |
| ハンドラ                           | 関数の実行時にコールしたい具体的メソッド名を設定する．       | ・コンテナイメージの関数では使用できない．<br>・Node.js：```index.js``` というファイル名で ```exports.handler``` メソッドを呼び出したい場合，ハンドラ名を```index.handler```とする |
| レイヤー                           | 異なる関数の間で，特定の処理を共通化できる．                 | コンテナイメージの関数では使用できない．                     |
| メモリ                             | Lambdaに割り当てるメモリ量を設定する．                       | 最大10240MBまで増設でき，増設するほどパフォーマンスが上がる．インターネットで向上率グラフを検索せよ． |
| タイムアウト                       |                                                              |                                                              |
| 実行ロール                         | Lambda内のメソッドが実行される時に必要なポリシーをもつロールを設定する． |                                                              |
| 既存ロール                         | Lambdaにロールを設定する．                                   |                                                              |
| トリガー                           | LambdaにアクセスできるようにするAWSリソースを設定する．      | 設定されたAWSリソースに応じて，Lambdaのポリシーが自動的に修正される． |
| アクセス権限                       | Lambdaのポリシーを設定する．                                 | トリガーの設定に応じて，Lambdaのポリシーが自動的に修正される． |
| 送信先                             | LambdaからアクセスできるようにするAWSリソースを設定する．    | 送信先のAWSリソースのポリシーは自動的に修正されないため，別途，手動で修正する必要がある． |
| 環境変数                           | Lambdaの関数内に出力する環境変数を設定する．                 | 標準では，環境変数はAWSマネージド型KMSキーによって暗号化される． |
| 同時実行数                         | 同時実行の予約を設定する．                                   |                                                              |
| プロビジョニングされた同時実行設定 |                                                              |                                                              |
| モニタリング                       | LambdaをCloudWatchまたはX-Rayを用いて，メトリクスを収集する． | 次の方法がある<br>・CloudWatchによって，メトリクスを収集する．<br>・CloudWatchのLambda Insightsによって，パフォーマンスに関するメトリクスを収集する．<br>・X-Rayによって，APIへのリクエスト，Lambdaコール，Lambdaの下流とのデータ通信をトレースし，これらをスタックトレース化する． |

#### ・設定のベストプラクティス

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/best-practices.html#function-configuration

<br>

### Lambdaと関数の関係性

![lambda-execution-environment-api-flow](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/lambda-execution-environment-api-flow.png)

#### ・Lambdaサービス

コンソール画面のLamdaに相当する．

#### ・関数の実行環境

Lambdaの実行環境は，API（ランタイムAPI，ログAPI，拡張API）と実行環境から構成されている．関数は実行環境に存在し，ランタイムAPIを介して，Lambdaによって実行される．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/runtimes-extensions-api.html#runtimes-extensions-api-lifecycle

実行環境には，３つのフェーズがある．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/runtimes-context.html#runtimes-lifecycle

![lambda-execution-environment-life-cycle](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/lambda-execution-environment-lifecycle.png)

#### ・Initフェーズ

Lambdaが発火する．実行環境が構築され，関数を実行するための準備が行われる．

#### ・Invokeフェーズ

Lambdaは関数を実行する．実行環境側のランタイムは，APIを介してLambdaから関数に引数を渡す．また関数の実行後に，APIを介して返却値をLambdaに渡す．

#### ・Shutdownフェーズ

一定期間，Invokeフェーズにおける関数実行が行われなかった場合，Lambdaはランタイムを終了し，実行環境を削除する．

<br>

### Lambda関数 on Docker

#### ・ベースイメージの準備

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/runtimes-images.html#runtimes-images-lp

#### ・RIC：Runtime Interface Clients

通常のランタイムはコンテナ内関数と通信できないため，ランタイムの代わりにRICを使用してコンテナ内関数と通信を行う．言語別にRICパッケージが用意されている．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/runtimes-images.html#runtimes-api-client

#### ・RIE：Runtime Interface Emulator

開発環境のコンテナで，擬似的にLambda関数を再現する．全ての言語で共通のRIEライブラリが用意されている．

参考：https://github.com/aws/aws-lambda-runtime-interface-emulator

RIEであっても，稼働させるためにAWSのクレデンシャル情報（アクセスキー，シークレットアクセスキー，リージョン）が必要なため，環境変数や```credentials```ファイルを使用して，Lambdaにこれらの値を出力する．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/images-test.html#images-test-env

**＊参考＊**

```bash
$ docker run --rm \
    # エミュレーターをエントリポイントをバインドする．
    -v ~/.aws-lambda-rie:/aws-lambda \
    -p 9000:8080 \
    # エミュレーターをエントリポイントとして指定する．
    --entrypoint /aws-lambda/aws-lambda-rie \
    <イメージ名>:<タグ名> /go/bin/cmd
```

```bash
# ハンドラー関数の引数に合ったJSONデータを送信する．
$ curl \
  -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -d '{}'
```

**＊参考＊**

```yaml
version: "3.7"

services:
  lambda:
    build:
      context: .
      dockerfile: ./build/Dockerfile
    container_name: lambda
    # エミュレーターをエントリポイントとして指定する．
    entrypoint: /aws-lambda/aws-lambda-rie
    env_file:
      - .docker.env
    image: <イメージ名>:<タグ名>
    ports:
      - 9000:8080
    # エミュレーターをエントリポイントをバインドする．
    volumes:
      - ~/.aws-lambda-rie:/aws-lambda
```

```bash
$ docker-compose up lambda
```

```bash
$ curl \
  -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -d '{}'
```

<br>

### Lambda関数

#### ・Goの使用例

以下のリンクを参考にせよ．

参考：

- https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/lambda-golang.html
- https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws_lambda_function.html

#### ・Node.jsの使用例

以下のリンクを参考にせよ．

参考：

- https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/lambda-nodejs.html
- https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws_lambda_function.html

<br>

### 同時実行

#### ・同時実行の予約

Lambdaは，関数の実行中に再びリクエストが送信されると，関数のインスタンスを新しく作成する．そして，各関数インスタンスを用いて，同時並行的にリクエストに応じる．標準では，関数の種類がいくつあっても，AWSアカウント当たり，合計で```1000```個までしかスケーリングして同時実行できない．関数ごとに同時実行数の使用枠を割り当てるためには，同時実行の予約を設定する必要がある．同時実行の予約数を```0```個とした場合，Lambdがスケーリングしなくなる．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/configuration-concurrency.html#configuration-concurrency-reserved

![lambda_concurrency-model](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/lambda_concurrency-model.png)

<br>

### VPC外／VPC内

#### ・VPC外への配置

Lambdaは標準ではVPC外に配置される．この場合，LambdaにENIがアタッチされ，ENIに割り当てられたIPアドレスがLambdaに適用される．Lambdaの実行時にENIは再作成されるため，実行ごとにIPアドレスは変化するが，一定時間内の再実行であればENIは再利用されるため，前回の実行時と同じIPアドレスになることもある．

#### ・VPC内への配置

LambdaをVPC内に配置するように設定する．VPC内に配置したLambdaにはパブリックIPアドレスが割り当てられないため，アウトバウンドな通信を行うためには，NAT Gatewayを設置する必要がある．

<br>

### ポリシー

#### ・実行のための最低限のポリシー

Lambdaを実行するためには，デプロイされた関数を使用する権限が必要である．そのため，関数を取得するためのステートメントを設定する．

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:<リージョン>:<アカウントID>:function:<関数名>*"
    }
  ]
}
```

<br>

### デプロイ

#### ・直接修正

デプロイを行わずに，関数のソースコードを直接修正し，『Deploy』ボタンでデプロイする．

#### ・S3におけるzipファイル

ビルド後のソースコードをzipファイルにしてアップロードする．ローカルPCまたはS3からアップロードできる．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/gettingstarted-package.html#gettingstarted-package-zip

#### ・ECRにおけるイメージ

コンテナイメージの関数でのみ有効である．ビルド後のソースコードをDockerイメージしてアップロードする．ECRからアップロードできる．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/gettingstarted-package.html#gettingstarted-package-images

<br>

## 20-02. Lambda@Edge

### Lambda@Edgeとは

CloudFrontに統合されたLambdaを，特別にLambda@Edgeという．

<br>

### 設定項目

#### ・トリガーの種類

![Lambda@Edge](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Lambda@Edge.png)

CloudFrontのビューワーリクエスト，オリジンリクエスト，オリジンレスポンス，ビューワーレスポンス，をトリガーとする．エッジロケーションのCloudFrontに，Lambdaのレプリカが構築される．

| トリガーの種類       | 発火のタイミング                                             |
| -------------------- | ------------------------------------------------------------ |
| ビューワーリクエスト | CloudFrontが，ビューワーからリクエストを受信した後（キャッシュを確認する前）． |
| オリジンリクエスト   | CloudFrontが，リクエストをオリジンサーバーに転送する前（キャッシュを確認した後）． |
| オリジンレスポンス   | CloudFrontが，オリジンからレスポンスを受信した後（キャッシュを確認する前）． |
| ビューワーレスポンス | CloudFrontが，ビューワーにレスポンスを転送する前（キャッシュを確認した後）． |

#### ・各トリガーのeventオブジェクトへのマッピング

各トリガーのeventオブジェクトへのマッピングは，リンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/lambda-event-structure.html

<br>

### ポリシー

#### ・実行のための最低限のポリシー

Lambda@Edgeを実行するためには，最低限，以下の権限が必要である．

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:GetFunction",
        "lambda:EnableReplication*"
      ],
      "Resource": "arn:aws:lambda:<リージョン名>:<アカウントID>:function:<関数名>:<バージョン>"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:UpdateDistribution"
      ],
      "Resource": "arn:aws:cloudfront::<アカウントID>:distribution/<DistributionID>"
    }
  ]
}
```

<br>

### Node.jsを用いた関数例

#### ・オリジンの動的な切り替え

![Lambda@Edge_動的オリジン](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Lambda@Edge_動的オリジン.png)

**＊実装例＊**

eventオブジェクトの```domainName```と```host.value```に代入されたバケットのドメイン名によって，ルーティング先のバケットが決まる．そのため，この値を切り替えれば，動的オリジンを実現できる．なお，各バケットには同じOAIを設定する必要がある．

```javascript
"use strict";

exports.handler = (event, context, callback) => {

    const request = event.Records[0].cf.request;
    // ログストリームに変数を出力する．
    console.log(JSON.stringify({request}, null, 2));

    const headers = request.headers;
    const s3Backet = getBacketBasedOnDeviceType(headers);

    request.origin.s3.domainName = s3Backet
    request.headers.host[0].value = s3Backet
    // ログストリームに変数を出力する．
    console.log(JSON.stringify({request}, null, 2));

    return callback(null, request);
};

/**
 * デバイスタイプに基づいて，オリジンを切り替える．
 *
 * @param   {Object} headers
 * @param   {string} env
 * @returns {string} pcBucket|spBucket
 */
const getBacketBasedOnDeviceType = (headers) => {

    const pcBucket = env + "-bucket.s3.amazonaws.com";
    const spBucket = env + "-bucket.s3.amazonaws.com";

    if (headers["cloudfront-is-desktop-viewer"]
        && headers["cloudfront-is-desktop-viewer"][0].value === "true") {
        return pcBucket;
    }

    if (headers["cloudfront-is-tablet-viewer"]
        && headers["cloudfront-is-tablet-viewer"][0].value === "true") {
        return pcBucket;
    }

    if (headers["cloudfront-is-mobile-viewer"]
        && headers["cloudfront-is-mobile-viewer"][0].value === "true") {
        return spBucket;
    }

    return spBucket;
};
```

オリジンリクエストは，以下のeventオブジェクトのJSONデータにマッピングされている．なお，一部のキーは省略している．

```bash
{
  "Records": [
    {
      "cf": {
        "request": {
          "body": {
            "action": "read-only",
            "data": "",
            "encoding": "base64",
            "inputTruncated": false
          },
          "clientIp": "nnn.n.nnn.nnn",
          "headers": {
            "host": [
              {
                "key": "Host",
                "value": "prd-sp-bucket.s3.ap-northeast-1.amazonaws.com"
              }
            ],
            "cloudfront-is-mobile-viewer": [
              {
                "key": "CloudFront-Is-Mobile-Viewer",
                "value": true
              }
            ],
            "cloudfront-is-tablet-viewer": [
              {
                "key": "loudFront-Is-Tablet-Viewer",
                "value": false
              }
            ],
            "cloudfront-is-smarttv-viewer": [
              {
                "key": "CloudFront-Is-SmartTV-Viewer",
                "value": false
              }
            ],
            "cloudfront-is-desktop-viewer": [
              {
                "key": "CloudFront-Is-Desktop-Viewer",
                "value": false
              }
            ],
            "user-agent": [
              {
                "key": "User-Agent",
                "value": "Amazon CloudFront"
              }
            ]
          },
          "method": "GET",
          "origin": {
            "s3": {
              "authMethod": "origin-access-identity",                
              "customHeaders": {
                  "env": [
                      {
                          "key": "env",
                          "value": "prd"
                      }
                  ]
              },
              "domainName": "prd-sp-bucket.s3.amazonaws.com",
              "path": "",
              "port": 443,
              "protocol": "https",
              "region": "ap-northeast-1"
            }
          },
          "querystring": "",
          "uri": "/images/12345"
        }
      }
    }
  ]
}
```

<br>

## 21. RDS：Relational Database Service

### 設定項目

| 設定項目                               | 説明                                                         | 補足                                                         |
| -------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| エンジンのオプション                   | データベースエンジンの種類を設定                             |                                                              |
| エディション                           | Amazon Auroraを選んだ場合の互換性を設定する．                |                                                              |
| キャパシティタイプ                     |                                                              |                                                              |
| エンジンバージョン                     | データベースエンジンのバージョンを指定する．                 | ・```SELECT AURORA_VERSION()```を使用して，エンジンバージョンを確認できる． |
| レプリケーション機能                   |                                                              |                                                              |
| DBクラスター識別子                     | クラスター名を設定する．                                     | インスタンス名は，最初に設定できず，RDSの構築後に設定できる． |
| マスタユーザ名                         | データベースのrootユーザを設定                               |                                                              |
| マスターパスワード                     | データベースのrootユーザのパスワードを設定                   |                                                              |
| DBインスタンスサイズ                   | データベースのインスタンスのスペックを設定する．             | バースト可能クラスを選ぶこと．ちなみに，Amazon Auroraのデータベース容量は自動でスケーリングするため，設定する必要がない． |
| マルチAZ配置                           | プライマリインスタンスとは別に，リーダーレプリカをマルチAZ配置で追加するかどうかを設定する． |                                                              |
| 最初のデータベース名                   | データベースに自動的に構築されるデータベース名を設定         |                                                              |
| サブネットグループ                     | データベースにアクセスできるサブネットを設定する．           |                                                              |
| パラメータグループ                     | グローバルパラメータを設定する．                             | デフォルトを使用せずに独自定義する場合，事前に構築しておく必要がある．クラスターパラメータグループとインスタンスパラメータグループがあるが，クラスターパラメータを設定すればよい．各パラメータに適用タイプ（dynamic/static）があり，dynamicタイプは設定の適用に再起動が必要である．新しく作成したクラスタパラメータグループにて以下の値を設定するとよい．<br>・```time_zone=Asia/Tokyo```<br>・```character_set_client=utf8mb4```<br/>・```character_set_connection=utf8mb4```<br/>・```character_set_database=utf8mb4```<br/>・```character_set_results=utf8mb4```<br/>・```character_set_server=utf8mb4```<br>・```server_audit_logging=1```（監査ログをCloudWatchに送信するかどうか）<br/>・```server_audit_logs_upload=1```<br/>・```general_log=1```（通常クエリログをCloudWatchに送信するかどうか）<br/>・```slow_query_log=1```（スロークエリログをCloudWatchに送信するかどうか）<br/>・```long_query_time=3```（スロークエリと見なす最短秒数） |
| ログのエクスポート                     |                                                              | 必ず，全てのログを選択すること．                             |
| バックアップ保持期間                   | RDSがバックアップを保持する期間を設定する．                  | ```7```日間にしておく．                                      |
| マイナーバージョンの自動アップグレード | データベースエンジンのバージョンを自動的に更新するかを設定する． | 開発環境では有効化，本番環境とステージング環境では無効化しておく．開発環境で新しいバージョンに問題がなければ，ステージング環境と本番環境にも適用する． |

<br>

### データベースインスタンス

#### ・データベースエンジン，RDB，DBMSの対応関係

RDSでは，DBMS，RDBを選べる．

| DBMSの種類        | RDBの種類              |
| ----------------- | ---------------------- |
| MySQL／PostgreSQL | Amazon Aurora          |
| MariaDB           | MariaDBデータベース    |
| MySQL             | MySQLデータベース      |
| PostgreSQL        | PostgreSQLデータベース |

#### ・データベースインスタンスの種類

|                | 読み出し／書き込みインスタンス                               | 読み出しオンリーインスタンス                                 |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 別名           | プライマリインスタンス                                       | リードレプリカインスタンス                                   |
| CRUD制限       | 制限なし．ユーザ権限に依存する．                             | ユーザ権限の権限に関係なく，READしか実行できない．           |
| エンドポイント | 各インスタンスに，リージョンのイニシャルに合わせたエンヂポイントが割り振られる． | 各インスタンスに，リージョンのイニシャルに合わせたエンヂポイントが割り振られる． |
| データ同期     | RDSクラスターに対するデータ変更を受けつける．                | 読み出し／書き込みインスタンスのデータの変更が同期される．   |

<br>

### インスタンスのダウンタイム

#### ・ダウンタイムの発生条件

その他の全ての項目は，以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html#USER_ModifyInstance.Settings

| 変更する項目                         | ダウンタイムの有無 | 補足                                                         |
| ------------------------------------ | ------------------ | ------------------------------------------------------------ |
| インスタンスクラス                   | あり               |                                                              |
| サブネットグループ                   | あり               |                                                              |
| エンジンバージョン                   | あり               | ```20```～```30```秒のダウンタイムが発生する．<br>参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Updates.html |
| メンテナンスウィンドウ               | 条件付きでなし     | ダウンタイムが発生する操作が保留中になっている状態で，メンテナンス時間を現在が含まれるように変更すると，保留中の操作がすぐに適用される．そのため，ダウンタイムが発生する． |
| バックアップウインドウ               | 条件付きでなし     | ```0```から```0```以外の値，```0```以外の値から```0```に変更した場合，ダウンタイムが発生する． |
| パラメータグループ                   | なし               | パラメータグループの変更ではダウンタイムは発生しない．ただし，パラメータグループの変更をインスタンスに反映させる上で再起動が必要なため，ここでダウンタイムが発生する． |
| セキュリティグループ                 | なし               |                                                              |
| マイナーバージョン自動アップグレード | なし               | エンジンバージョンの変更にはダウンタイムが発生するが，自動アップグレードの設定にはダウンタイムが発生しない． |
| パフォーマンスインサイト             | 条件付きでなし     | パフォーマンスインサイトの有効化ではダウンタイムが発生しない．ただし，有効化のためにパラメータグループの```performance_schema```を有効化する必要がある．パラメータグループの変更をインスタンスに反映させる上で再起動が必要なため，ここでダウンタイムが発生する． |

#### ・再起動ダウンタイムの短縮

非マルチAZ構成の場合，アプリケーションの向き先をプライマリーインスタンスにしたまま，変更対象のデータベースからリードレプリカを新しく作成し，これを更新した後に，リードレプリカを手動フェイルオーバーさせる．フェイルオーバー時に約```1```～```2```分のダウンタイムが発生するが，インスタンスの再起動よりも時間が短いため，相対的にダウンタイムを短縮できる．

参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.MySQL.html#USER_UpgradeDBInstance.MySQL.ReducedDowntime

マルチAZ構成の場合，アプリケーションの向き先をプライマリーインスタンスにしたまま，既存のリードレプリカを更新し，リードレプリカを自動フェイルオーバーさせる．フェイルオーバー時に約```1```～```2```分のダウンタイムが発生するが，インスタンスの再起動よりも時間が短いため，相対的にダウンタイムを短縮できる．

#### ・メンテナンスウインドウ

メンテナスウインドウには，以下の状態がある．

| 状態           | 説明                                                         |
| -------------- | ------------------------------------------------------------ |
| 利用可能       | アクションは実行可能である．また，以降のメンテナンスウィンドウの間に自動的に実行することはない． |
| 次のウィンドウ | アクションは実行可能である．また，次回のメンテナンスウィンドウの間に，アクションを自動的に実行する．後でアップグレードを選択することで，『利用可能』の状態に戻すことも可能． |
| 必須           | アクションは実行可能である．また，指定されたメンテナンスウィンドウの間に必ず実行され，これは延期できない． |
| 進行中         | 現在時刻がメンテナンスウィンドウに含まれており，アクションを実行中である． |

#### ・ダウンタイムの計測

アプリケーションの目視ではなく，RDSに直接クエリを送信し，レスポンスとRDSイベントログから，ダウンタイムを計測する．

**＊実装例＊**

踏み台サーバを経由してRDSに接続し，現在時刻を取得するSQLを送信する．平常アクセス時の再現テストも同時に実行することで，より正確なダウンタイムを取得するようにする．また，ヘルスチェックの時刻を正しくロギングできるように，ローカルPCから時刻を取得する．

```bash
#!/bin/bash

set -x

BASTION_HOST=""
BASTION_USER=""
DB_HOST=""
DB_PASSWORD=""
DB_USER=""
SECRET_KEY="~/.ssh/xxx.pem"
SQL="SELECT NOW();"

ssh -o serveraliveinterval=60 -f -N -L 3306:${DB_HOST}:3306 -i ${SECRET_KEY} ${BASTION_USER}@${BASTION_HOST} -p 22

for i in {1..900};
do
  LOCAL_DATETIME=$(date +"%Y-%m-%d %H:%M:%S")
  echo "---------- No. ${i} Local PC: ${LOCAL_DATETIME} ------------" >> health_check.txt
  echo ${SQL} | mysql -u ${DB_USER} -P 3306 -p${DB_PASSWORD} >> health_check.txt 2>&1 & sleep 1
done
```

上記のシェルスクリプトにより，例えば次のようなログを取得できる．このログからは，```15:23:09 ~ 15:23:14```の間で，接続に失敗していることを確認できる．

```log
---------- No. 242 Local PC: 2021-04-21 15:23:06 ------------
mysql: [Warning] Using a password on the command line interface can be insecure.
NOW()
2021-04-21 06:23:06
---------- No. 243 Local PC: 2021-04-21 15:23:07 ------------
mysql: [Warning] Using a password on the command line interface can be insecure.
NOW()
2021-04-21 06:23:08
---------- No. 244 Local PC: 2021-04-21 15:23:08 ------------
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 2026 (HY000): SSL connection error: error:00000000:lib(0):func(0):reason(0)
---------- No. 245 Local PC: 2021-04-21 15:23:09 ------------
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 2013 (HY000): Lost connection to MySQL server at 'reading initial communication packet', system error: 0
---------- No. 246 Local PC: 2021-04-21 15:23:10 ------------
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 2013 (HY000): Lost connection to MySQL server at 'reading initial communication packet', system error: 0
---------- No. 247 Local PC: 2021-04-21 15:23:11 ------------
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 2013 (HY000): Lost connection to MySQL server at 'reading initial communication packet', system error: 0
---------- No. 248 Local PC: 2021-04-21 15:23:13 ------------
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 2013 (HY000): Lost connection to MySQL server at 'reading initial communication packet', system error: 0
---------- No. 249 Local PC: 2021-04-21 15:23:14 ------------
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 2013 (HY000): Lost connection to MySQL server at 'reading initial communication packet', system error: 0
---------- No. 250 Local PC: 2021-04-21 15:23:15 ------------
mysql: [Warning] Using a password on the command line interface can be insecure.
NOW()
2021-04-21 06:23:16
---------- No. 251 Local PC: 2021-04-21 15:23:16 ------------
mysql: [Warning] Using a password on the command line interface can be insecure.
NOW()
2021-04-21 06:23:17
```

アップグレード時のプライマリインスタンスのRDSイベントログは以下の通りで，ログによるダウンタイムは，再起動からシャットダウンまでの期間と一致することを確認する．

![rds-event-log](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/rds-event-log_primary-instance.png)

ちなみに，リードレプリカは再起動のみを実行していることがわかる．

![rds-event-log](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/rds-event-log_read-replica-instance.png)

<br>

### 負荷対策

#### ・エンドポイントの使い分け

![RDSエンドポイント](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/RDSエンドポイント.png)

インスタンスに応じたエンドポイントが用意されている．アプリケーションからのCRUDの種類に応じて，アクセス先を振り分けることにより，負荷を分散させられる．読み出しオンリーエンドポイントに対して，READ以外の処理を行うと，以下の通り，エラーとなる．


```log
/* SQL Error (1290): The MySQL server is running with the --read-only option so it cannot execute this statement */
```

| 種類                       | エンドポイント                                               | クエリの種類       | 説明                                                         |
| -------------------------- | ------------------------------------------------------------ | ------------------ | ------------------------------------------------------------ |
| クラスターエンドポイント   | ```<クラスター名>.cluster-<id>.ap-northeast-1.rds.amazonaws.com``` | 書き込み／読み出し | プライマリインスタンスに接続できる．                         |
| 読み出しエンドポイント     | ```<クラスター名>.cluster-ro-<id>.ap-northeast-1.rds.amazonaws.com``` | 読み出し           | リードレプリカインスタンスに接続できる．インスタンスが複数ある場合，クエリが自動的に割り振られる． |
| インスタンスエンドポイント | ```<インスタンス名>.cwgrq25vlygf.ap-northeast-1.rds.amazonaws.com``` |                    | 選択したインスタンスに接続できる．フェイルオーバーによって読み書きインスタンスと読み出しインスタンスが入れ替わってしまうため，インスタンスエンドポイントを指定しない方が良い．これは，Redisも同じである． |

#### ・クエリキャッシュの利用

MySQLやRedisのクエリキャッシュ機能を利用する．ただし，MySQLのクエリキャッシュ機能は，バージョン```8```で廃止されることになっている．

#### ・ユニークキーまたはインデックスの利用

スロークエリを検出し，そのSQLで対象としているカラムにユニークキーやインデックスを設定する．スロークエリを検出する方法として，RDSの```long_query_time```パラメータに基づいた検出や，```EXPLAIN```句による予想実行時間の比較などがある．ユニークキー，インデックス，```EXPLAIN```句，については以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_database_mysql.html

#### ・テーブルを正規化し過ぎない

テーブルを正規化すると保守性が高まるが，アプリケーションのSQLで```JOIN```句が必要になる．しかし，```JOIN```句を含むSQLは，含まないSQLと比較して，実行速度が遅くなる．そこで，戦略的に正規化し過ぎないようにする．

#### ・インスタンスタイプのスケールアップ

インスタンスタイプをスケールアップさせることで，接続過多のエラー（```ERROR 1040 (HY000): Too many connections```）に対処する．ちなみに現在の最大接続数はパラメータグループの値から確認できる．コンソール画面からはおおよその値しかわからないため，SQLで確認した方が良い．

```sql
MySQL > SHOW GLOBAL VARIABLES LIKE 'max_connections';

+-----------------+-------+
| Variable_name  | Value |
+-----------------+-------+
| max_connections | 640  |
+-----------------+-------+
1 row in set (0.00 sec)
```

<br>

### 障害対策

#### ・フェイルオーバー

RDSのフェイルオーバーには，データベースの種類に応じて，以下の種類のものがある．フェイルオーバー時に約```1```～```2```分のダウンタイムが発生する．

参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html#Concepts.MultiAZ.Failover

| データベース | フェイルオーバーの仕組み                               | 補足                                                         |
| ------------ | ------------------------------------------------------ | ------------------------------------------------------------ |
| Aurora       | リードレプリカがプライマリインスタンスに昇格する．     | 参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html |
| Aurora以外   | スタンバイレプリカがプライマリインスタンスに昇格する． | 参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html |

Auroraの場合，フェイルオーバーによって昇格するインスタンスは次の順番で決定される．基本的には，優先度の数値の小さいインスタンスが昇格対象になる．優先度が同じだと，インスタンスクラスが大きいインスタンスが昇格対象になる．インスタンスクラスが同じだと，同じサブネットにあるインスタンスが昇格対象になる．

1. 優先度の順番
2. インスタンスクラスの大きさ
3. 同じサブネット

#### ・エンジンバージョンアップグレード時の事前調査

エンジンバージョンのアップグレード時，ダウンタイムが発生する．そのため，以下のような報告書のもと，調査と対応を行う．

参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Updates.html

またマージされる内容の調査のため，リリースノートの確認が必要になる．

参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Updates.11Updates.html

```markdown
# 調査

## バージョンの違い

『SELECT AURORA_VERSION()』を使用して，正確なバージョンを取得する．

## マージされる内容

ベンダーのリリースノートを確認し，どのような『機能追加』『バグ修正』『機能廃止』『非推奨機能』がマージされるかを調査する．
機能廃止や非推奨機能がある場合，アプリケーション内のSQL文に影響が出る可能性がある．

## 想定されるダウンタイム

テスト環境でダウンタイムを計測し，ダウンタイムを想定する．
```

```markdown
# 本番環境対応

## 日時と周知

対応日時と周知内容を決定する．

## 想定外の結果

本番環境での対応で起こった想定外の結果を記載する．
```

<br>

### セキュリティ

#### ・配置されるサブネット

データベースが配置されるサブネットはプライベートサブネットにする，これには，data storeサブネットと名付ける．アプリケーション以外は，踏み台サーバ経由でしかデータベースにアクセスできないようにする．

![subnet-types](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/subnet-types.png)

#### ・セキュリティグループ

コンピューティングからのインバウンド通信のみを許可するように，これらのプライベートIPアドレス（```n.n.n.n/32```）を設定する．

<br>

## 22. RegionとZone

### Region

#### ・Regionとは

物理サーバのあるデータセンターの地域名のこと．

#### ・Globalとエッジロケーションとは

Regionとは別に，物理サーバが世界中にあり，これらの間ではグローバルネットワークが構築されている．そのため，Globalなサービスは，特定のRegionに依存せずに，全てのRegionと連携できる．

![edge-location](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/edge-location.png)

<br>

## 23. Route53

### Route53とは

クラウドDNSサーバーとして働く．リクエストされた完全修飾ドメイン名とEC2のグローバルIPアドレスをマッピングしている．

<br>

### 設定項目

#### ・一覧

| 設定項目       | 説明                                                         |
| -------------- | ------------------------------------------------------------ |
| ホストゾーン   | ドメイン名を設定する．                                       |
| レコードセット | 名前解決時のルーティング方法を設定する．サブドメイン名を扱うことも可能． |

<br>

### ホストゾーン

#### ・レコードタイプの設定値の違い

| レコードタイプ |                                                              | 補足                                |
| -------------- | ------------------------------------------------------------ | ----------------------------------- |
| NS             | IPアドレスの問い合わせに応えられる権威DNSサーバの名前が定義されている． |                                     |
| A              | リクエストを転送したいAWSリソースの，IPv4アドレスまたはDNS名を設定する． |                                     |
| AAAA           | リクエストを転送したいAWSリソースの，IPv6アドレスまたはDNS名を設定する． |                                     |
| CNAME          | リクエストを転送したい任意のサーバのドメイン名を設定する．   | 転送先はAWSリソースでなくともよい． |
| MX             | リクエストを転送したいメールサーバのドメイン名を設定する．   |                                     |
| TXT            | リクエストを転送したいサーバのドメイン名に関連付けられた文字列を設定する． |                                     |

#### ・リソースのDNS名，ドメイン名，エンドポイント名

リソースのDNS名は，以下の様に決定される．

| 種別             | リソース   | 例                                                           |
| ---------------- | ---------- | ------------------------------------------------------------ |
| DNS名            | ALB        | ```<ALB名>-<ランダムな文字列>.<リージョン>.elb.amazonaws.com``` |
|                  | EC2        | ```ec2-<パブリックIPをハイフン区切りにしたもの>.<リージョン>.compute.amazonaws.com``` |
| ドメイン名       | CloudFront | ```<ランダムな文字列>.cloudfront.net```                      |
| エンドポイント名 | S3         | ```<バケット名>.<リージョン>.amazonaws.com```                |

#### ・レコードタイプの名前解決方法の違い

![URLと電子メールの構造](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/URLと電子メールの構造.png)

| レコードタイプ | 名前解決方法（1）  |      |      （2）       |      |     （3）      |
| -------------- | :----------------: | :--: | :--------------: | :--: | :------------: |
| A              | 完全修飾ドメイン名 |  →   |  パブリックIPv4  |  →   |       -        |
| AAAA           | 完全修飾ドメイン名 |  →   |  パブリックIPv6  |  →   |       -        |
| CNAME          | 完全修飾ドメイン名 |  →   | （リダイレクト） |  →   | パブリックIPv4 |

#### ・CloudFrontへのルーティング

CloudFrontにルーティングする場合，CloudFrontのCNAMEをレコード名とすると，CloudFrontのデフォルトドメイン名（```xxxxx.cloudfront.net.```）が，入力フォームに表示されるようになる．

#### ・Route53を含む多数のDNSサーバによって名前解決される仕組み

![Route53を含む名前解決の仕組み](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Route53を含む名前解決の仕組み.png)

=== （1）完全修飾ドメイン名に対応するIPアドレスのレスポンス ===

1. クライアントPCは，自身に保存される```www.example.jp```（完全修飾ドメイン名）のキャッシュを検索する．
2. キャッシュが無ければ，クライアントPCは```www.example.jp```を，フォワードプロキシサーバ（キャッシュDNSサーバ）にリクエスト．
3. フォワードプロキシサーバは，DNSキャッシュを検索する．
4. フォワードプロキシサーバは，ルートDNSサーバに```www.example.jp```のIPアドレスを問い合わせる．
5. ルートDNSサーバは，NSレコードとして定義された権威DNSサーバ名をレスポンス．
6. フォワードプロキシサーバは，```www.example.jp```を，リバースプロキシサーバに代理リクエスト．次いで，リバースプロキシサーバは，DNSサーバ（ネームサーバ）に```www.example.jp```のIPアドレスを問い合わせる．
7. DNSサーバは，NSレコードとして定義された権威DNSサーバ名をレスポンス．
8. フォワードプロキシサーバは，```www.example.jp```を，リバースプロキシサーバに代理リクエスト．次いで，リバースプロキシサーバは，グローバルリージョンRoute53に```www.example.jp```のIPアドレスを問い合わせる．
9. グローバルリージョンRoute53はDNSサーバとして機能し，リバースプロキシサーバに東京リージョンALBのIPアドレスをレスポンス．次いで，リバースプロキシサーバは，東京リージョンALBのIPアドレスを，フォワードプロキシサーバに代理レスポンス．（※ NATによるIPアドレスのネットワーク間変換が起こる）


|      完全修飾ドメイン名      | Route53 |     IPv4アドレス      |
| :--------------------------: | :-----: | :-------------------: |
| ```http://www.example.com``` |    ⇄    | ```203.142.205.139``` |

10. フォワードプロキシサーバは，東京リージョンALBのIPアドレスを，クライアントPCに代理レスポンス．
11. クライアントPCは東京リージョンALBのIPアドレスにリクエストを送信する．

=== （2）東京リージョンALBのIPアドレスに対応するWebページのレスポンス ===

1. クライアントPCは，レスポンスされた東京リージョンALBのIPアドレスを基に，Webページを，リバースプロキシサーバにリクエスト．
2. リバースプロキシサーバは，Webページを，東京リージョンALBに代理リクエスト．
3. 東京リージョンALBは，EC2やFargateにリクエストを転送する．
4. EC2やFargateは，Webページをリバースプロキシサーバにレスポンス．
5. リバースプロキシサーバは，WebページをクライアントPCに代理レスポンス．

#### ・AWS以外でドメインを購入した場合

DNSサーバによる名前解決は，ドメインを購入したドメインレジストラで行われる．そのため，AWS以外でドメインを購入した場合，Route53のNSレコード値を，ドメインレジストラに登録する必要がある．これにより，ドメインレジストラに対してIPアドレスの問い合わせがあった場合は，Route53のNSレコード値がレスポンスされるようになる．NSレコード値を元に，クライアントはRoute53にアクセスする．

#### ・Route53におけるDNSキャッシュ

ルートサーバは世界に13機しか存在しておらず，世界中の名前解決のリクエストを全て処理することは現実的に不可能である．そこで，IPアドレスとドメイン名の関係をキャッシュするプロキシサーバ（キャッシュDNSサーバ）が使用されている．基本的には，プロキシサーバとDNSサーバは区別されるが，Route53はプロキシサーバとDNSサーバの機能を両立している．

<br>

### リゾルバー

#### ・リゾルバーとは

要勉強．

<br>

## 24. S3：Simple Storage Service

### S3とは

クラウド外付けストレージとして働く．S3に保存するCSSファイルや画像ファイルを管理できる．

<br>

### 設定項目

#### ・主要項目

| 設定項目             | 説明                       |
| -------------------- | -------------------------- |
| バケット             | バケットに関して設定する． |
| バッチオペレーション |                            |
| アクセスアナライザー |                            |

#### ・プロパティの詳細

| 設定項目                     | 説明 | 補足 |
| ---------------------------- | ---- | ---- |
| バージョニング               |      |      |
| サーバアクセスのログ記録     |      |      |
| 静的サイトホスティング       |      |      |
| オブジェクトレベルのログ記録 |      |      |
| デフォルト暗号化             |      |      |
| オブジェクトのロック         |      |      |
| Transfer acceleration        |      |      |
| イベント                     |      |      |
| リクエスタ支払い             |      |      |

#### ・外部／内部ネットワークからのアクセス制限の詳細

| 設定項目                   | 説明                                                         | 補足                                                         |
| -------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ブロックパブリックアクセス | パブリックネットワークがS3にアクセスする時の許否を設定する． | ・パブリックアクセスを有効にすると，パブリックネットワークから『```https://<バケット名>.s3.amazonaws.com```』というようにURLを指定して，S3にアクセスできるようになる．ただし非推奨．<br>・パブリックアクセスを全て無効にすると，パブリックネットワークからの全アクセスを遮断できる．<br>・特定のオブジェクトで，アクセスコントロールリストを制限した場合，そのオブジェクトだけはパブリックアクセスにならない． |
| バケットポリシー           | IAMユーザ（クロスアカウントも可）またはAWSリソースがS3へにアクセスするためのポリシーで管理する． | ・IAMユーザ（クロスアカウントも可）やAWSリソースがS3にアクセスするために必要である．ただし代わりに，IAMポリシーをAWSリソースにアタッチすることでも，アクセスを許可できる．<br>・ポリシーをアタッチできないCloudFrontやALBなどでは，自身へのアクセスログを生成するために必須である． |
| アクセスコントロールリスト | IAMユーザ（クロスアカウントも可）がS3にアクセスする時の許否を設定する． | ・バケットポリシーと機能が重複する．<br/>・仮にバケット自体のブロックパブリックアクセスを無効化したとしても，特定のオブジェクトでアクセスコントロールリストを制限した場合，そのオブジェクトだけはパブリックアクセスにならない． |
| CORSの設定                 |                                                              |                                                              |

<br>

### レスポンスヘッダー

#### ・レスポンスヘッダーの設定

レスポンスヘッダーに埋め込むHTTPヘッダーを，メタデータとして設定する．

| 設定可能なヘッダー              | 説明                                                         | 補足                                           |
| ------------------------------- | ------------------------------------------------------------ | ---------------------------------------------- |
| ETag                            | コンテンツの一意な識別子．ブラウザキャッシュの検証に使用される． | 全てのコンテンツにデフォルトで設定されている． |
| Cache-Control                   | Expiresと同様に，ブラウザにおけるキャッシュの有効期限を設定する． | 全てのコンテンツにデフォルトで設定されている． |
| Content-Type                    | コンテンツのMIMEタイプを設定する．                           | 全てのコンテンツにデフォルトで設定されている． |
| Expires                         | Cache-Controlと同様に，ブラウザにおけるキャッシュの有効期限を設定する．ただし，Cache-Controlの方が優先度が高い． |                                                |
| Content-Disposition             |                                                              |                                                |
| Content-Encoding                |                                                              |                                                |
| x-amz-website-redirect-location | コンテンツのリダイレクト先を設定する．                       |                                                |

<br>

### バケットポリシーの例

#### ・S3のARNについて

ポリシーにおいて，S3のARでは，『```arn:aws:s3:::<バケット名>/*```』のように，最後にバックスラッシュアスタリスクが必要．

#### ・ALBのアクセスログの保存を許可

パブリックアクセスが無効化されたS3に対して，ALBへのアクセスログを保存したい場合，バケットポリシーを設定する必要がある．バケットポリシーには，ALBからS3へのログ書き込み権限を実装する．『```"AWS": "arn:aws:iam::582318560864:root"```』において，```582318560864```は，ALBアカウントIDと呼ばれ，リージョンごとに値が決まっている．これは，東京リージョンのアカウントIDである．その他のリージョンのアカウントIDについては，以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions

**＊実装例＊**

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::582318560864:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::<バケット名>/*"
    }
  ]
}
```

#### ・CloudFrontのファイル読み出しを許可

パブリックアクセスが無効化されたS3に対して，CloudFrontからのルーティングで静的ファイルを読み出したい場合，バケットポリシーを設定する必要がある．

**＊実装例＊**

```bash
{
  "Version": "2008-10-17",
  "Id": "PolicyForCloudFrontPrivateContent",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity <OAIのID番号>"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::<バケット名>/*"
    }
  ]
}
```

#### ・CloudFrontのアクセスログの保存を許可

2020-10-08時点の仕様では，パブリックアクセスが無効化されたS3に対して，CloudFrontへのアクセスログを保存することはできない．よって，危険ではあるが，パブリックアクセスを有効化する必要がある．

```bash
// ポリシーは不要
```

#### ・Lambdaからのアクセスを許可

バケットポリシーは不要である．代わりに，AWS管理ポリシーの『```AWSLambdaExecute```』がアタッチされたロールをLambdaにアタッチする必要がある．このポリシーには，S3へのアクセス権限の他，CloudWatchログにログを生成するための権限が設定されている．

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:*"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::*"
    }
  ]
}
```

#### ・特定のIPアドレスからのアクセスを許可

パブリックネットワーク上の特定のIPアドレスからのアクセスを許可したい場合，そのIPアドレスをポリシーに設定する必要がある．

```bash
{
  "Version": "2012-10-17",
  "Id": "S3PolicyId1",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::<バケット名>/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "<IPアドレス>/32"
        }
      }
    }
  ]
}
```

<br>

### CORS設定

#### ・指定したドメインからのGET送信を許可

```bash
[
  {
    "AllowedHeaders": [
      "Content-*"
    ],
    "AllowedMethods": [
      "GET"
    ],
    "AllowedOrigins": [
      "https://example.jp"
    ],
    "ExposeHeaders": [],
    "MaxAgeSeconds": 3600
  }
]
```

<br>

### CLI

#### ・バケット内ファイルを表示

**＊コマンド例＊**

指定したバケット内のファイル名を表示する．

```bash
$ aws s3 ls s3://<バケット名>
```

#### ・バケット内容量を合計

**＊コマンド例＊**

指定したバケット内のファイル容量を合計する．

```bash
$ aws s3 ls s3://<バケット名> --summarize --recursive --human-readable
```

<br>

## 25. Security Group

### Security Groupとは

アプリケーションのクラウドパケットフィルタリング型ファイアウォールとして働く．インバウンド通信（プライベートネットワーク向き通信）では，プロトコルや受信元IPアドレスを設定でき，アウトバウンド通信（グローバルネットワーク向き通信）では，プロトコルや送信先プロトコルを設定できる．

<br>

### 設定項目

#### ・一覧

インバウンドルールとアウトバウンドルールを設定できる．

<br>

### インバウンドルール

#### ・パケットフィルタリング型ファイアウォール

パケットのヘッダ情報に記載された送信元IPアドレスやポート番号などによって，パケットを許可するべきかどうかを決定する．速度を重視する場合はこちら．ファイアウォールとWebサーバの間には，NATルータやNAPTルータが設置されている．これらによる送信元プライベートIPアドレスから送信元グローバルIPアドレスへの変換についても参考にせよ．

![パケットフィルタリング](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/パケットフィルタリング.gif)

#### ・セキュリティグループIDの紐づけ

ソースに対して，セキュリティグループIDを設定した場合，そのセキュリティグループがアタッチされているENIと，このENIに関連付けられたリソースからのトラフィックを許可できる．リソースのIPアドレスが動的に変化する場合，有効な方法である．

参考：https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/VPC_SecurityGroups.html#DefaultSecurityGroup

#### ・アプリケーションEC2の例

ALBに割り振られる可能性のあるIPアドレスを許可するために，ALBのSecurity GroupのID，またはサブネットのIPアドレス範囲を設定する．

| タイプ | プロトコル | ポート    | ソース                       | 説明                        |
| ------ | ---------- | --------- | ---------------------------- | --------------------------- |
| HTTP   | TCP        | ```80```  | ALBのSecurity Group ID       | HTTP access from ALB        |
| HTTPS  | TCP        | ```443``` | 踏み台EC2のSecurity Group ID | SSH access from bastion EC2 |

#### ・踏み台EC2の例

| タイプ | プロトコル | ポート   | ソース                     | 説明                             |
| ------ | ---------- | -------- | -------------------------- | -------------------------------- |
| SSH    | TCP        | ```22``` | 社内のグローバルIPアドレス | SSH access from global ip addess |

#### ・EFSの例

EC2に割り振られる可能性のあるIPアドレスを許可するために，EC2のSecurity GroupのID，またはサブネットのIPアドレス範囲を設定する．

| タイプ | プロトコル | ポート     | ソース                                 | 説明                    |
| ------ | ---------- | ---------- | -------------------------------------- | ----------------------- |
| NFS    | TCP        | ```2049``` | アプリケーションEC2のSecurity Group ID | NFS access from app EC2 |

#### ・RDSの例

EC2に割り振られる可能性のあるIPアドレスを許可するために，EC2のSecurity GroupのID，またはサブネットのIPアドレス範囲を設定する．

| タイプ       | プロトコル | ポート     | ソース                                 | 説明                      |
| ------------ | ---------- | ---------- | -------------------------------------- | ------------------------- |
| MYSQL/Aurora | TCP        | ```3306``` | アプリケーションEC2のSecurity Group ID | MYSQL access from app EC2 |

#### ・Redisの例

EC2に割り振られる可能性のあるIPアドレスを許可するために，EC2のSecurity GroupのID，またはサブネットのIPアドレス範囲を設定する．

| タイプ      | プロトコル | ポート     | ソース                                 | 説明                    |
| ----------- | ---------- | ---------- | -------------------------------------- | ----------------------- |
| カスタムTCP | TCP        | ```6379``` | アプリケーションEC2のSecurity Group ID | TCP access from app EC2 |

#### ・ALBの例

CloudFrontと連携する場合，CloudFrontに割り振られる可能性のあるIPアドレスを許可するために，全てのIPアドレスを許可する．その代わりに，CloudFrontにWAFを紐づけ，ALBの前でIPアドレスを制限するようにする．CloudFrontとは連携しない場合，ALBのSecurity GroupでIPアドレスを制限するようにする．

| タイプ | プロトコル | ポート    | ソース          | 説明                         |      |
| ------ | ---------- | --------- | --------------- | ---------------------------- | ---- |
| HTTP   | TCP        | ```80```  | ```0.0.0.0/0``` | HTTP access from CloudFront  |      |
| HTTPS  | TCP        | ```443``` | ```0.0.0.0/0``` | HTTPS access from CloudFront |      |

<br>

### アウトバウンドルール

#### ・任意AWSリソースの例

| タイプ               | プロトコル | ポート | 送信先          | 説明        |
| -------------------- | ---------- | ------ | --------------- | ----------- |
| すべてのトラフィック | すべて     | すべて | ```0.0.0.0/0``` | Full access |

<br>

### Zone

#### ・Availability Zoneとは

Regionは，さらに，各データセンターは物理的に独立したAvailability Zoneというロケーションから構成されている．例えば，東京Regionには，3つのAvailability Zoneがある．AZの中に，VPCサブネットを作ることができ，そこにEC2を構築できる．

<br>

## 26. SES：Simple Email Service

### SESとは

クラウドメールサーバとして働く．メール受信をトリガーとして，アクションを実行する．

<br>

### 設定項目

![SESとは](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/SESとは.png)

#### ・主要項目

| 設定項目           | 説明                                                         | 補足                                                         |
| ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Domain             | SESのドメイン名を設定する．                                  | 設定したドメイン名には，『```10 inbound-smtp.us-east-1.amazonaws.com```』というMXレコードタイプの値が紐づく． |
| Email Addresses    | 送信先として認証するメールアドレスを設定する．設定するとAWSからメールが届くので，指定されたリンクをクリックする． | Sandboxモードの時だけ機能する．                              |
| Sending Statistics | SESで収集されたデータをメトリクスで確認できる．              | ```Request Increased Sending Limits```のリンクにて，Sandboxモードの解除を申請できる． |
| SMTP Settings      | SMTP-AUTHの接続情報を確認できる．                            | アプリケーションの25番ポートは送信制限があるため，465番を使用する．これに合わせて，SESも受信で465番ポートを使用するようにする． |
| Rule Sets          | メールの受信したトリガーとして実行するアクションを設定できる． |                                                              |
| IP Address Filters |                                                              |                                                              |

#### ・Rule Setsの詳細

| 設定項目 | 説明                                                         |
| -------- | ------------------------------------------------------------ |
| Recipiet | 受信したメールアドレスで，何の宛先の時にこれを許可するかを設定する． |
| Actions  | 受信を許可した後に，これをトリガーとして実行するアクションを設定する． |

<br>

### 仕様上の制約

#### ・構築リージョンの制約

SESは連携するAWSリソースと同じリージョンに構築しなければならない．

#### ・Sandboxモードの解除

SESはデフォルトではSandboxモードになっている．Sandboxモードでは以下の制限がかかっており．サポートセンターに解除申請が必要である．

| 制限     | 説明                                          |
| -------- | --------------------------------------------- |
| 送信制限 | SESで認証したメールアドレスのみに送信できる． |
| 受信制限 | 1日に200メールのみ受信できる．                |

<br>

### SMTP-AUTH

#### ・AWSにおけるSMTP-AUTHの仕組み

一般的なSMTP-AUTHでは，クライアントユーザの認証が必要である．同様にして，AWSにおいてもこれが必要であり，IAMユーザを用いてこれを実現する．送信元となるアプリケーションにIAMユーザを紐付け，このIAMユーザにはユーザ名とパスワードを設定する．アプリケーションがSESを介してメールを送信する時，アプリケーションに対して，SESがユーザ名とパスワードを用いた認証を実行する．ユーザ名とパスワードは後から確認できないため，メモしておくこと．SMTP-AUTHの仕組みについては，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_network_internet.html?h=smtp

<br>

## 27. SNS：Simple Notification Service

### SNSとは

パブリッシャーから発信されたメッセージをエンドポイントで受信し，サブスクライバーに転送するAWSリソース．

![SNSとは](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/SNSとは.png)

<br>

### 設定項目

#### ・主要項目

| 設定項目           | 説明                                                 |
| ------------------ | ---------------------------------------------------- |
| トピック           | 複数のサブスクリプションをグループ化したもの．       |
| サブスクリプション | エンドポイントで受信するメッセージの種類を設定する． |

#### ・トピックの詳細

| 設定項目                 | 説明                                                         |
| ------------------------ | ------------------------------------------------------------ |
| サブスクリプション       | サブスクリプションを登録する．                               |
| アクセスポリシー         | トピックへのアクセス権限を設定する．                         |
| 配信再試行ポリシー       | サブスクリプションのHTTP/Sエンドポイントが失敗した時のリトライ方法を設定する．<br>参考：https://docs.aws.amazon.com/ja_jp/sns/latest/dg/sns-message-delivery-retries.html |
| 配信ステータスのログ記録 | サブスクリプションへの発信のログをCloudWatchLogsに転送するように設定する． |
| 暗号化                   |                                                              |

#### ・サブスクリプションの詳細

| メッセージの種類      | 転送先                | 補足                                                         |
| --------------------- | --------------------- | ------------------------------------------------------------ |
| Kinesis Data Firehose | Kinesis Data Firehose |                                                              |
| SQS                   | SQS                   |                                                              |
| Lambda                | Lambda                |                                                              |
| Eメール               | 任意のメールアドレス  |                                                              |
| HTTP/S                | 任意のドメイン名      | Chatbotのドメイン名は『```https://global.sns-api.chatbot.amazonaws.com```』 |
| JSON形式のメール      | 任意のメールアドレス  |                                                              |
| SMS                   | SMS                   | 受信者の電話番号を設定する．                                 |

<br>

## 28. SQS：Simple Queue Service

### SQSとは

![AmazonSQSとは](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/SQS.jpeg)

クラウドメッセージキューとして働く．パブリッシャーが送信したメッセージは，一旦SQSに追加される．その後，サブスクライバーは，SQSに対してリクエストを送信し，メッセージを取り出す．異なるVPC間でも，メッセージキューを同期できる．

<br>

### 設定項目

#### ・SQSの種類

| 設定項目         | 説明                                                         |
| ---------------- | ------------------------------------------------------------ |
| スタンダード方式 | サブスクライバーの取得レスポンスを待たずに，次のキューを非同期的に転送する． |
| FIFO方式         | サブスクライバーの取得レスポンスを待ち，キューを同期的に転送する． |

<br>

### CLI

#### ・キューURLを取得

キューのURLを取得する．

```bash
$ aws sqs get-queue-url --queue-name <キュー名>
```

#### ・キューに受信リクエストを送信

キューに受信リクエストを送信し，メッセージを受信する．

```bash
$ SQS_QUEUE_URL=$(aws sqs get-queue-url --queue-name <キュー名>)

$ aws sqs receive-message --queue-url ${SQS_QUEUE_URL}
```

キューに受信リクエストを送信し，メッセージを受信する．また，メッセージの内容をファイルに書き出す．

```bash
$ SQS_QUEUE_URL=$(aws sqs get-queue-url --queue-name <キュー名>)

$ aws sqs receive-message --queue-url ${SQS_QUEUE_URL} > receiveOutput.json
```

```bash
{
    "Messages": [
        {
            "Body": "<メッセージの内容>", 
            "ReceiptHandle": "AQEBUo4y+XVuRSe4jMv0QM6Ob1viUnPbZ64WI01+Kmj6erhv192m80m+wgyob+zBgL4OMT+bps4KR/q5WK+W3tnno6cCFuwKGRM4OQGM9omMkK1F+ZwBC49hbl7UlzqAqcSrHfxyDo5x+xEyrEyL+sFK2MxNV6d0mF+7WxXTboyAu7JxIiKLG6cUlkhWfk3W4/Kghagy5erwRhwTaKtmF+7hw3Y99b55JLFTrZjW+/Jrq9awLCedce0kBQ3d2+7pnlpEcoY42+7T1dRI2s7um+nj5TIUpx2oSd9BWBHCjd8UQjmyye645asrWMAl1VCvHZrHRIG/v3vgq776e1mmi9pGxN96IW1aDZCQ1CSeqTFASe4=", 
            "MD5OfBody": "6699d5711c044a109a6aff9fc193aada", 
            "MessageId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        }
    ]
 }
```

<br>

## 29. STS：Security Token Service

### STSとは

AWSリソースに一時的にアクセスできる認証情報（アクセスキー，シークレットアクセスキー，セッショントークン）を発行する．この認証情報は，一時的なアカウント情報として使用できる．

![STS](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/STS.jpg)

<br>

### STSの設定手順

#### 1. IAMロールに信頼ポリシーをアタッチ

必要なポリシーが設定されたIAMロールを構築する．その時，信頼ポリシーにおいて，ユーザの```ARN```を信頼されたエンティティとして設定しておく．これにより，そのユーザに対して，ロールをアタッチできるようになる．

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<アカウントID>:user/<ユーザ名>"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "<適当な文字列>"
        }
      }
    }
  ]
}
```

#### 2. ロールを引き受けたアカウント情報をリクエスト

信頼されたエンティティ（ユーザ）から，STS（```https://sts.amazonaws.com```）に対して，ロールのアタッチをリクエストする．

```bash
#!/bin/bash

set -xeuo pipefail
set -u

# 事前に環境変数にインフラ環境名を代入する．
case $ENV in
    "test")
        aws_account_id="<作業環境アカウントID>"
        aws_access_key_id="<作業環境アクセスキーID>"
        aws_secret_access_key="<作業環境シークレットアクセスキー>"
        aws_iam_role_external_id="<信頼ポリシーに設定した外部ID>"
    ;;
    "stg")
        aws_account_id="<ステージング環境アカウントID>"
        aws_access_key_id="<ステージング環境アクセスキーID>"
        aws_secret_access_key="<ステージング環境シークレットアクセスキー>"
        aws_iam_role_external_id="<信頼ポリシーに設定した外部ID>"
    ;;
    "prd")
        aws_account_id="<本番環境アカウントID>"
        aws_access_key_id="<本番環境アクセスキーID>"
        aws_secret_access_key="<本番環境シークレットアクセスキー>"
        aws_iam_role_external_id="<信頼ポリシーに設定した外部ID>"
    ;;
    *)
        echo "The parameter ${ENV} is invalid."
        exit 1
    ;;
esac

# 信頼されたエンティティのアカウント情報を設定する．
aws configure set aws_access_key_id "$aws_account_id"
aws configure set aws_secret_access_key "$aws_secret_access_key"
aws configure set aws_default_region "ap-northeast-1"

# https://sts.amazonaws.com に，ロールのアタッチをリクエストする．
aws_sts_credentials="$(aws sts assume-role \
  --role-arn "arn:aws:iam::${aws_access_key_id}:role/${ENV}-<アタッチしたいIAMロール名>" \
  --role-session-name "<任意のセッション名>" \
  --external-id "$aws_iam_role_external_id" \
  --duration-seconds "<セッションの有効秒数>" \
  --query "Credentials" \
  --output "json")"
```

STSへのリクエストの結果，ロールがアタッチされた新しいIAMユーザ情報を取得できる．この情報には有効秒数が存在し，期限が過ぎると新しいIAMユーザになる．秒数の最大値は，該当するIAMロールの概要の最大セッション時間から変更できる．

![AssumeRole](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/AssumeRole.png)

レスポンスされるデータは以下の通り．

```bash
{
  "AssumeRoleUser": {
    "AssumedRoleId": "<セッションID>:<セッション名>",
    "Arn": "arn:aws:sts:<新しいアカウントID>:assumed-role/<IAMロール名>/<セッション名>"
  },
  "Credentials": {
    "SecretAccessKey": "<シークレットアクセスキー>",
    "SessionToken": "<セッショントークン文字列>",
    "Expiration": "<セッションの期限>",
    "AccessKeyId": "<アクセスキーID>"
  }
}
```

#### 3-1. アカウント情報を取得（１）

jqを使用して，レスポンスされたJSONデータからアカウント情報を抽出する．環境変数として出力し，使用できるようにする．あるいは，AWSの```credentials```ファイルを作成してもよい．

参考：https://stedolan.github.io/jq/


```bash
#!/bin/bash

cat << EOF > assumed_user.sh
export AWS_ACCESS_KEY_ID="$(echo "$aws_sts_credentials" | jq -r ".AccessKeyId")"
export AWS_SECRET_ACCESS_KEY="$(echo "$aws_sts_credentials" | jq -r ".SecretAccessKey")"
export AWS_SESSION_TOKEN="$(echo "$aws_sts_credentials" | jq -r ".SessionToken")"
export AWS_ACCOUNT_ID="$aws_account_id"
export AWS_DEFAULT_REGION="ap-northeast-1"
EOF
```

#### 3-2. アカウント情報を取得（２）

jqを使用して，レスポンスされたJSONデータからアカウント情報を抽出する．ロールを引き受けた新しいアカウントの情報を，```credentials```ファイルに書き込む．

```bash
#!/bin/bash

aws configure --profile ${ENV}-repository << EOF
$(echo "$aws_sts_credentials" | jq -r ".AccessKeyId")
$(echo "$aws_sts_credentials" | jq -r ".SecretAccessKey")
ap-northeast-1
json
EOF

echo aws_session_token = $(echo "$aws_sts_credentials" | jq -r ".SessionToken") >> ~/.aws/credentials
```

#### 4. 接続確認

ロールを引き受けた新しいアカウントを使用して，AWSリソースに接続できるかを確認する．アカウント情報の取得方法として```credentials```ファイルの作成を選んだ場合，```profile```オプションが必要である．

```bash
#!/bin/bash

# 3-2を選んだ場合，credentialsファイルを参照するオプションが必要がある．
aws s3 ls --profile <プロファイル名>
2020-xx-xx xx:xx:xx <tfstateファイルが管理されるバケット名>
```

<br>

## 30. Step Functions

### Step Functionsとは

AWSサービスを組み合わせて，イベント駆動型アプリケーションを構築できる．

<br>

### AWSリソースのAPIコール

#### ・APIコールできるリソース

参考：https://docs.aws.amazon.com/step-functions/latest/dg/connect-supported-services.html

### ・Lambda

**＊実装例＊**

```bash
{
  "StartAt": "Call Lambda",
  "States": {
    "Call Lambda": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke.waitForTaskToken",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:ap-northeast-1:xxxxx:foo-function:1"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "<リトライの対象とするエラー>"
          ],
          "MaxAttempts": 0
        }
      ],
      "End": true,
      "Comment": "The state that call Lambda"
    }
  }
}
```

<br>

## 31. VPC：Virtual Private Cloud

### VPCとは

クラウドプライベートネットワークとして働く．プライベートIPアドレスが割り当てられた，VPCと呼ばれるプライベートネットワークを仮想的に構築できる．異なるAvailability Zoneに渡ってEC2を立ち上げることによって，クラウドサーバをデュアル化することできる．

![VPCが提供できるネットワークの範囲](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/VPCが提供できるネットワークの範囲.png)

<br>

### VPCのパケット通信の仕組み

参考：https://pages.awscloud.com/rs/112-TZM-766/images/AWS-08_AWS_Summit_Online_2020_NET01.pdf

<br>

### Internet Gateway，NAT Gateway

![InternetGatewayとNATGateway](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/InternetGatewayとNATGateway.png)

#### ・Internet Gatewayとは

VPCの出入り口に設置され，グローバルネットワークとプライベートネットワーク間（ここではVPC）におけるNAT（静的NAT）の機能を持つ．一つのパブリックIPに対して，一つのEC2のプライベートIPを紐づけられる．NAT（静的NAT）については，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_network_internet.html

#### ・NAT Gatewayとは

NAPT（動的NAT）の機能を持つ．一つのパブリックIPに対して，複数のEC2のプライベートIPを紐づけられる．パブリックサブネットに置き，プライベートサブネットのEC2からのレスポンスを受け付ける．NAPT（動的NAT）については，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_network_internet.html

#### ・比較表


|              | Internet Gateway                                             | NAT Gateway            |
| :----------- | :----------------------------------------------------------- | :--------------------- |
| **機能**     | グローバルネットワークとプライベートネットワーク間（ここではVPC）におけるNAT（静的NAT） | NAPT（動的NAT）        |
| **設置場所** | VPC上                                                        | パブリックサブネット内 |

<br>

### Route Table（= マッピングテーブル）

![route-table](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/route-table.png)

#### ・ルートテーブルとは

クラウドルータのマッピングテーブルとして働く．ルータについては，別ノートのNATとNAPTを参考にせよ．

| Destination（プライベートIPの範囲） |                Target                 |
| :---------------------------------: | :-----------------------------------: |
|          ```xx.x.x.x/xx```          | Destinationの範囲内だった場合の送信先 |

#### ・ルートテーブルの種類

| 種類                   | 説明                                                         |
| ---------------------- | ------------------------------------------------------------ |
| メインルートテーブル   | VPCの構築時に自動で構築される．どのルートテーブルにも関連付けられていないサブネットのルーティングを設定する． |
| カスタムルートテーブル | 特定のサブネットのルーティングを設定する．                   |

#### ・具体例1

上の図中で，サブネット2にはルートテーブル1が関連づけられている．サブネット2内のEC2の送信先のプライベートIPアドレスが，```10.0.0.0/16```の範囲内にあれば，インバウンド通信と見なし，local（VPC内の他サブネット）を送信先に選び，範囲外にあれば通信を破棄する．

| Destination（プライベートIPアドレス範囲） |  Target  |
| :---------------------------------------: | :------: |
|             ```10.0.0.0/16```             |  local   |
|            指定範囲以外の場合             | 通信破棄 |

#### ・具体例2

上の図中で，サブネット3にはルートテーブル2が関連づけられている．サブネット3内のEC2の送信先のプライベートIPアドレスが，```10.0.0.0/16```の範囲内にあれば，インバウンド通信と見なし，local（VPC内の他サブネット）を送信先に選び，```0.0.0.0/0```（local以外の全IPアドレス）の範囲内にあれば，アウトバウンド通信と見なし，インターネットゲートウェイを送信先に選ぶ．

| Destination（プライベートIPアドレス範囲） |      Target      |
| :---------------------------------------: | :--------------: |
|             ```10.0.0.0/16```             |      local       |
|              ```0.0.0.0/0```              | Internet Gateway |

<br>

### Network ACL：Network Access  Control List

![network-acl](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/network-acl.png)

#### ・Network ACLとは

サブネットのクラウドパケットフィルタリング型ファイアウォールとして働く．ルートテーブルとサブネットの間に設置され，双方向のインバウンドルールとアウトバウンドルールを決定する．

#### ・ACLルール

ルールは上から順に適用される．例えば，インバウンドルールが以下だった場合，ルール100が最初に適用され，サブネットに対する，全IPアドレス（```0.0.0.0/0```）からのインバウンド通信を許可していることになる．

| ルール # | タイプ                | プロトコル | ポート範囲 / ICMP タイプ | ソース    | 許可 / 拒否 |
| -------- | --------------------- | ---------- | ------------------------ | --------- | ----------- |
| 100      | すべての トラフィック | すべて     | すべて                   | 0.0.0.0/0 | ALLOW       |
| *        | すべての トラフィック | すべて     | すべて                   | 0.0.0.0/0 | DENY        |

<br>

### VPCサブネット

クラウドプライベートネットワークにおけるセグメントとして働く．

#### ・パブリックサブネットとは

非武装地帯に相当する．攻撃の影響が内部ネットワークに広がる可能性を防ぐために，外部から直接リクエストを受ける，

#### ・プライベートサブネットとは

内部ネットワークに相当する．外部から直接リクエストを受けずにレスポンスを返せるように，内のNATを経由させる必要がある．

![public-subnet_private-subnet](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/public-subnet_private-subnet.png)

#### ・同一VPC内の各AWSリソースに割り当てる最低限のIPアドレス数

一つのVPC内には複数のサブネットが入る．そのため，サブネットのIPアドレス範囲は，サブネットの個数だけ狭めなければならない．また，VPCがもつIPアドレス範囲から，VPC内の各AWSリソースにIPアドレスを割り当てていかなければならない．VPC内でIPアドレスが枯渇しないように，　以下の手順で，割り当てを考える．

1. rfc1918 に準拠し，VPCに以下の範囲内でIPアドレスを割り当てる．

| IPアドレス                                | サブネットマスク（CIDR形式） | 範囲                 |
| ----------------------------------------- | ---------------------------- | -------------------- |
| ```10.0.0.0```  ~ ```10.255.255.255```    | ```/8```                     | ```10.0.0.0/8```     |
| ```172.16.0.0``` ~ ```172.31.255.255```   | ```/12```                    | ```172.16.0.0/12```  |
| ```192.168.0.0``` ~ ```192.168.255.255``` | ```/16```                    | ```192.168.0.0/16``` |

2. VPC内の各AWSリソースにIPアドレス範囲を割り当てる．

| AWSサービスの種類  | 最低限のIPアドレス数                    |
| ------------------ | --------------------------------------- |
| ALB                | ALB1つ当たり，8個                       |
| オートスケーリング | 水平スケーリング時のEC2最大数と同じ個数 |
| VPCエンドポイント  | VPCエンドポイント1つ当たり，1個         |
| ECS                | Elastic Network Interface 数と同じ個数  |
| Lambda             | Elastic Network Interface 数と同じ個数  |

#### ・サブネットの種類

サブネットには，役割ごとにいくつか種類がある．

| 名前                            | 役割                                    |
| ------------------------------- | --------------------------------------- |
| Public subnet (Frontend Subnet) | NATGatewayを配置する．                  |
| Private app subnet              | アプリケーション，Nginxなどを配置する． |
| Private datastore subnet        | RDS，Redisなどを配置する                |

![subnet-types](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/subnet-types.png)

<br>

### VPCエンドポイント

![VPCエンドポイント](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/VPCエンドポイント.png)

#### ・設定項目

VPCのプライベートサブネット内のリソースが，VPC外のリソースに対して，アウトバウンド通信を実行できるようにする．Gateway型とInterface型がある．VPCエンドポイントを使用しない場合，プライベートサブネット内からのアウトバウンド通信には，インターネットゲートウェイとNAT Gatewayを使用する必要がある．

**＊（例）＊**

ECS Fargateをプライベートサブネットに置いた場合に，ECS FargateからVPC外にあるAWSリソースに対するアウトバウンドな通信のために必要．（例：CloudWatchログ，ECR，S3，SSM）

#### ・メリット

インターネットゲートウェイとNAT Gatewayの代わりに，VPCエンドポイントを使用すると，料金が少しだけ安くなり，また，VPC外のリソースとの通信がより安全になる．

#### ・タイプ

| タイプ      | 説明                                                         | リソース例                       |
| ----------- | ------------------------------------------------------------ | -------------------------------- |
| Interface型 | プライベートリンクともいう．プライベートIPアドレスを持つENIとして機能し，AWSリソースからアウトバウンドな通信を受信する． | S3，DynamoDB以外の全てのリソース |
| Gateway型   | ルートテーブルにおける定義に従う．VPCエンドポイントとして機能し，AWSリソースからアウトバウンドな通信を受信する． | S3，DynamoDBのみ                 |

<br>

### ENI：Elastic Network Interface

#### ・ENIとは

クラウドネットワークインターフェースとして働く．物理ネットワークにおけるNICについては以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_network_internet.html

#### ・関連付けられるリソース

| リソースの種類    | 役割                                                         | 補足                                                         |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ALB               | ENIに関連付けられたパブリックIPアドレスをALBに割り当てられる． |                                                              |
| EC2               | ENIに関連付けられたパブリックIPアドレスがEC2に割り当てられる． | 参考：https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/using-eni.html#eni-basics |
| Fargate環境のEC2  | 明言されていないため推測ではあるが，ENIに関連付けられたlocalインターフェースがFargate環境でコンテナのホストとなるEC2インスタンスに割り当てられる． | Fargate環境のホストがEC2とは明言されていない．<br>参考：https://aws.amazon.com/jp/blogs/news/under-the-hood-fargate-data-plane/ |
| Elastic IP        | ENIにElastic IPアドレスが関連付けられる．このENIを他のAWSリソースに関連付けることにより，ENIを介して，Elastic IPを関連付けられる． | 参考：https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/using-eni.html#managing-network-interface-ip-addresses |
| GlobalAccelerator |                                                              |                                                              |
| NAT Gateway       | ENIに関連付けられたパブリックIPアドレスがNAT Gatewayに割り当てられる． |                                                              |
| RDS               |                                                              |                                                              |
| Security Group    | ENIにセキュリティグループが関連付けれる．このENIを他のAWSリソースに関連付けることにより，ENIを介して，セキュリティグループを関連付けられる． |                                                              |
| VPCエンドポイント | Interface型のVPCエンドポイントとして機能する．               |                                                              |

<br>

### IPアドレスの関連付け

#### ・種類

| IPアドレスの種類                                   | 説明                                          |
| -------------------------------------------------- | --------------------------------------------- |
| 自動割り当てパブリックIPアドレス（動的IPアドレス） | 動的なIPアドレスで，EC2の再構築後に変化する． |
| Elastic IP（静的IPアドレス）                       | 静的なIPアドレスで，再構築後も保持される．    |

#### ・関連付け

| 種類                     | 補足                                                         |
| ------------------------ | ------------------------------------------------------------ |
| インスタンスとの関連付け | 非推奨の方法である．<br/>参考：https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/vpc-eips.html#vpc-eip-overview |
| ENIとの関連付け          | 推奨される方法である．<br>参考：https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/vpc-eips.html#vpc-eip-overview |

<br>

## 31-02. VPC間，VPC-オンプレ間の通信

### VPCピアリング接続

![VPCピアリング接続](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/VPCピアリング接続.png)

#### ・VPCピアリング接続とは

『一対一』の関係で，『異なるVPC間』の双方向通信を可能にする．

#### ・VPCピアリング接続の可否

| アカウント   | VPCのあるリージョン | VPC内のCIDRブロック    | 接続の可否 |
| ------------ | ------------------- | ---------------------- | ---------- |
| 同じ／異なる | 同じ／異なる        | 全て異なる             | **〇**     |
|              |                     | 同じものが一つでもある | ✕          |

VPC に複数の IPv4 CIDR ブロックがあり，一つでも 同じCIDR ブロックがある場合は，VPC ピアリング接続はできない．

![VPCピアリング接続不可の場合-1](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/VPCピアリング接続不可の場合-1.png)

たとえ，IPv6が異なっていても，同様である．

![VPCピアリング接続不可の場合-2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/VPCピアリング接続不可の場合-2.png)

<br>

### VPCエンドポイントサービス

![vpc-endpoint-service](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/vpc-endpoint-service.png)

#### ・VPCエンドポイントサービスとは

VPCエンドポイントとは異なる機能なので注意．Interface型のVPCエンドポイント（プライベートリンク）をNLBに関連付けることにより，『一対多』の関係で，『異なるVPC間』の双方向通信を可能にする．エンドポイントのサービス名は，『``` com.amazonaws.vpce.ap-northeast-1.vpce-svc-xxxxx```』になる．API GatewayのVPCリンクは，VPCエンドポイントサービスに相当する．

<br>

### Transit Gateway

![transit-gateway](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/transit-gateway.png)

#### ・Transit Gatewayとは

『多対多』の関係で，『異なるVPC間』や『オンプレ-VPC間』の双方向通信を可能にする．クラウドルーターとして働く．

<br>

### 各サービスとの比較

| 機能                         | VPCピアリング接続 | VPCエンドポイントサービス           | Transit gateway        |
| ---------------------------- | ----------------- | ----------------------------------- | ---------------------- |
| 通信可能なVPC数              | 一対一            | 一対一，一対多                      | 一対一，一対多，多対多 |
| 通信可能なIPアドレスの種類   | IPv4，IPv6        | IPv4                                | IPv4，IPv6             |
| 接続可能なリソース           | 制限なし          | NLBでルーティングできるリソースのみ | 制限なし               |
| CIDRブロックによる通信の可否 | ×                 | ◯                                   | ×                      |
| クロスアカウント             | ◯                 | ◯                                   | ◯                      |
| クロスリージョン             | ◯                 | ×                                   | ◯                      |
| VPC間                        | ◯                 | ◯                                   | ◯                      |
| VPC-オンプレ間               | ×                 | ×                                   | ◯                      |

<br>

## 32. WAF：Web Applicarion Firewall

### 設定項目

定義できるルール数や文字数に制限がある．以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/limits.html

| 設定項目                          | 説明                                                         | 補足                                                         |
| --------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Web ACLs：Web Access Control List | 各トリガーと許可／拒否アクションの関連付けを『ルール』とし，これをセットで設定する． | アタッチするAWSリソースに合わせて，リージョンが異なる．      |
| IP sets                           | アクション実行のトリガーとなるIPアドレス                     | ・許可するIPアドレスは，意味合いに沿って異なるセットとして構築するべき．例えば，社内IPアドレスセット，協力会社IPアドレスセット，など<br>・拒否するIPアドレスはひとまとめにしてもよい． |
| Regex pattern sets                | アクション実行のトリガーとなるURLパスの文字列                | ・許可／拒否する文字列は，意味合いに沿って異なる文字列セットとして構築するべき．例えば，ユーザエージェントセット，リクエストパスセット，など |
| Rule groups                       |                                                              |                                                              |
| AWS Markets                       |                                                              |                                                              |

<br>

### AWSリソース vs. サイバー攻撃

| サイバー攻撃の種類 | 対抗するAWSリソースの種類                                    |
| ------------------ | ------------------------------------------------------------ |
| マルウェア         | なし                                                         |
| 傍受，盗聴         | VPC内の特にプライベートサブネット間のピアリング接続．VPC外を介さずにデータを送受信できる． |
| ポートスキャン     | セキュリティグループ                                         |
| DDoS               | Shield                                                       |
| ゼロディ           | WAF                                                          |
| インジェクション   | WAF                                                          |
| XSS                | WAF                                                          |
| データ漏洩         | KMS，CloudHSM                                                |
| 組織内部での裏切り | IAM                                                          |

<br>

### 設定項目

#### ・主要項目

| 設定項目           | 説明                                              | 補足                                                         |
| ------------------ | ------------------------------------------------- | ------------------------------------------------------------ |
| Web ACLs           | アクセス許可と拒否のルールを定義する．            |                                                              |
| Bot Control        | Botに関するアクセス許可と拒否のルールを定義する． |                                                              |
| IP Sets            | IPアドレスの共通部品を管理する．                  |                                                              |
| Regex pattern sets | 正規表現パターンの共通部品を管理する．            |                                                              |
| Rule groups        | ルールの共通部品を管理する．                      | 各WAFに同じルールを設定する場合，ルールグループを使用するべきである．ただ，ルールグループを使用すると，これらのルールを共通のメトリクスで監視しなければならなくなる．そのため，もしメトリクスを分けるのであれば，ルールグループを使用しないようにする． |

#### ・Web ACLsの詳細

| 設定項目                 | 説明                                                         | 補足                                                         |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Overview                 | WAFによって許可／拒否されたリクエストのアクセスログを確認できる． |                                                              |
| Rules                    | 順番にルールを判定し，一致するルールがあればアクションを実行する．この時，一致するルールの後にあるルールは．判定されない． | AWSマネージドルールについては，以下のリンクを参考にせよ．<br>参考：https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/aws-managed-rule-groups-list.html |
| Associated AWS resources | WAFをアタッチするAWSリソースを設定する．                     | CloudFront，ALBなどにアタッチできる．                        |
| Logging and metrics      | アクセスログをKinesis Data Firehoseに出力するように設定する． |                                                              |

#### ・OverviewにおけるSampled requestsの見方

『全てのルール』または『個別のルール』におけるアクセス許可／拒否の履歴を確認できる．ALBやCloudFrontのアクセスログよりも解りやすく，様々なデバッグに役立つ．ただし，３時間分しか残らない．一例として，CloudFrontにアタッチしたWAFで取得できるログを以下に示す．

```http
GET /foo/
# ホスト
Host: example.jp
Upgrade-Insecure-Requests: 1
# ユーザエージェント
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Sec-Fetch-Mode: navigate
Sec-Fetch-User: ?1
Sec-Fetch-Dest: document
# CORSであるか否か
Sec-Fetch-Site: same-origin
Accept-Encoding: gzip, deflate, br
Accept-Language: ja,en;q=0.9
# Cookieヘッダー
Cookie: sessionid=<セッションID>; _gid=<GoogleAnalytics値>; __ulfpc=<GoogleAnalytics値>; _ga=<GoogleAnalytics値>
```

<br>

### ルール

#### ・ルールの種類

参考：https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/classic-web-acl-rules-creating.html

| 種類         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| レートベース | 同じ送信元IPアドレスからの５分間当たりのリクエスト数制限をルールに付与する． |
| レギュラー   | リクエスト数は制限しない．                                   |

#### ・ルールの粒度のコツ

わかりやすさの観点から，可能な限り設定するステートメントを少なくし，一つのルールに一つの意味合いだけを持たせるように命名する．

#### ・Count（検知）モード

ルールに該当するリクエスト数を数え，許可／拒否せずに次のルールを検証する．計測結果に応じて，Countモードを無効化し，拒否できるようにする．

参考：https://oji-cloud.net/2020/09/18/post-5501/

#### ・Countアクションの上書き

ルールのCountモードが有効になっている場合に，Countアクションに続けて，そのルールの元々のアクションを実行する．そのため，Countアクションしつつ，Blockアクションを実行できる（仕様がややこしすぎるので，なんとかしてほしい）．

参考：https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/web-acl-rule-group-override-options.html

| 元々のアクション | Countモード | オーバライド | 結果                                                         |
| ---------------- | ----------- | ------------ | ------------------------------------------------------------ |
| Block            | ON          | チェックあり | Countし，その後Blockを実行する．そのため，その後のルールは検証せずに終了する． |
| Block            | ON          | チェックなし | Countのみを実行する．そのため，その後のルールも検証する．    |
| Block            | OFF         | チェックあり | Countモードが無効なため，設定に意味がない．                  |
| Block            | OFF         | チェックなし | Countモードが無効なため，設定に意味がない．                  |

<br>

### ルールの具体例

#### ・ユーザエージェント拒否

**＊具体例＊**

悪意のあるユーザエージェントを拒否する．

ルール：block-user-agents

| Statementの順番 | If a request | Inspect  | Match type                             | Regex pattern set | Then  | 挙動                                                         |
| --------------- | ------------ | -------- | -------------------------------------- | ----------------- | ----- | ------------------------------------------------------------ |
| 0               | matches      | URI path | Matches pattern from regex pattern set | 文字列セット      | Block | 指定した文字列を含むユーザエージェントの場合，アクセスすることを拒否する． |

| Default Action | 説明                                                         |
| -------------- | ------------------------------------------------------------ |
| Allow          | 指定したユーザエージェントでない場合，全てのファイルパスにアクセスすることを許可する． |

#### ・CI/CDツールのアクセスを許可

**＊具体例＊**

社内の送信元IPアドレスのみ許可した状態で，CircleCIなどのサービスが社内サービスにアクセスできるようにする．

ルール：allow-request-including-access-token

| Statementの順番 | If a request | Inspect | Header field name | Match type              | String to match                                     | Then  | 挙動                                                         |
| --------------- | ------------ | ------- | ----------------- | ----------------------- | --------------------------------------------------- | ----- | ------------------------------------------------------------ |
| 0               | matches      | Header  | authorization     | Exactly matched  string | 『```Bearer <トークン文字列>```』で文字列を設定する | Allow | authorizationヘッダーに指定した文字列を含むリクエストの場合，アクセスすることを拒否する． |

| Default Action | 説明                                                         |
| -------------- | ------------------------------------------------------------ |
| Block          | 正しいトークンを持たないアクセスの場合，全てのファイルパスにアクセスすることを拒否する． |

#### ・特定のパスを社内アクセスに限定

**＊具体例＊**

アプリケーションにおいて，特定のURLパスにアクセスできる送信元IPアドレスを，社内だけに制限する．二つのルールを構築する必要がある．

ルール：allow-access--to-url-path

| Statementの順番 | If a request  | Inspect                          | IP set       | Match type                             | Regex pattern set | Then  | 挙動                                                         |
| --------------- | ------------- | -------------------------------- | ------------ | -------------------------------------- | ----------------- | ----- | ------------------------------------------------------------ |
| 0               | matches (AND) | Originates from an IP address in | 社内IPセット | -                                      | -                 | -     | 社内の送信元IPアドレスの場合，指定したファイルパスにアクセスすることを許可する． |
| 1               | matches       | URI path                         | -            | Matches pattern from regex pattern set | 文字列セット      | Allow | 0番目かつ，指定した文字列を含むURLパスアクセスの場合，アクセスすることを許可する． |

ルール：block-access-to-url-path

| Statementの順番 | If a request | Inspect  | Match type                             | Regex pattern set | Then  | 挙動                                                         |
| --------------- | ------------ | -------- | -------------------------------------- | ----------------- | ----- | ------------------------------------------------------------ |
| 0               | matches      | URI path | Matches pattern from regex pattern set | 文字列セット      | Block | 指定した文字列を含むURLパスアクセスの場合，アクセスすることを拒否する． |

| Default Action | 説明                                                         |
| -------------- | ------------------------------------------------------------ |
| Allow          | 指定したURLパス以外のアクセスの場合，そのパスにアクセスすることを許可する． |

#### ・社内アクセスに限定

**＊具体例＊**

アプリケーション全体にアクセスできる送信元IPアドレスを，特定のIPアドレスだけに制限する．

ルール：allow-global-ip-addresses

| Statementの順番 | If a request  | Inspect                          | IP set           | Originating address | Then  | 挙動                                                         |
| --------------- | ------------- | -------------------------------- | ---------------- | ------------------- | ----- | ------------------------------------------------------------ |
| 0               | matches  (OR) | Originates from an IP address in | 社内IPセット     | Source IP address   | -     | 社内の送信元IPアドレスの場合，全てのファイルパスにアクセスすることを許可する． |
| 1               | matches       | Originates from an IP address in | 協力会社IPセット | Source IP address   | Allow | 0番目あるいは，協力会社の送信元IPアドレスの場合，全てのファイルパスにアクセスすることを許可する． |

| Default Action | 説明                                                         |
| -------------- | ------------------------------------------------------------ |
| Block          | 指定した送信元IPアドレス以外の場合，全てのファイルパスにアクセスすることを拒否する． |

<br>

## 33. WorkMail

### WorkMailとは

Gmail，サンダーバード，Yahooメールなどと同類のメール管理アプリケーション．

<br>

### 設定項目

| 設定項目              | 説明                                                     | 補足                                                         |
| --------------------- | -------------------------------------------------------- | ------------------------------------------------------------ |
| Users                 | WorkMailで管理するユーザを設定する．                     |                                                              |
| Domains               | ユーザに割り当てるメールアドレスのドメイン名を設定する． | ```@{組織名}.awsapps.com```をドメイン名としてもらえる．ドメイン名の検証が完了した独自ドメイン名を設定することもできる． |
| Access Controle rules | 受信するメール，受信を遮断するメール，の条件を設定する． |                                                              |

<br>

## 34. 負荷テスト

### Distributed Load Testing（分散負荷テスト）

#### ・分散負荷テストとは

AWSから提供されている負荷を発生させるインフラ環境のこと．CloudFormationで構築でき，Fargateを使用して，ユーザからのリクエストを擬似的に再現できる．

参考：https://d1.awsstatic.com/Solutions/ja_JP/distributed-load-testing-on-aws.pdf

#### ・インフラ構成

![distributed_load_testing](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/distributed_load_testing.png)

<br>

## 35. コスト管理

### コスト管理の観点

#### ・スペック

#### ・時間単価

#### ・数量

#### ・月額料金

<br>

### SLA：Service Level Agreement

#### ・SLAとは

サービスレベル合意と訳せる．インターネットサービスに最低限のサービスのレベルを保証し，これを下回った場合には返金できるように合意するもの．SLAとして，例えば以下がある．

| 項目             | 説明                                 | レベル例    | 返金率 |
| ---------------- | ------------------------------------ | ----------- | ------ |
| サーバ稼働率     | サーバの時間当たりの稼働率           | 99.9%以上   | 10%    |
| 障害回復時間     | 障害が起こってから回復するまでの時間 | 2時間以内   | 10%    |
| 障害お問い合わせ | 障害発生時のお問い合わせ可能時間帯   | 24時間365日 | 10%    |

#### ・AWSのSLA

AWSではサービスレベルの項目として，サーバ稼働率を採用している．これに対して，ほとんどのAWSリソースで，以下のSLAが設定されている．

| 毎月の稼働率         | サービスクレジットの割合 |
| -------------------- | ------------------------ |
| 99.0％以上SLA未満    | 10%                      |
| 95.0％以上99.0％未満 | 25%                      |
| 95.0%未満            | 100%                     |

各リソースにSLAが定義されている．例として，EC2やECSのSLAを参考にせよ．

参考：https://d1.awsstatic.com/legal/AmazonComputeServiceLevelAgreement/Amazon%20Compute%20Service%20Level%20Agreement_Japanese_2020-07-22_Updated.pdf

<br>

### Service Quotas

#### ・Service Quotastとは

各種AWSリソースの設定の上限値を上げられる．

参考：https://docs.aws.amazon.com/ja_jp/servicequotas/latest/userguide/intro.html

#### ・各種AWSリソースの上限値

参考：https://docs.aws.amazon.com/ja_jp/general/latest/gr/aws-service-information.html

#### ・方法

参考：https://docs.aws.amazon.com/ja_jp/servicequotas/latest/userguide/request-quota-increase.html

<br>

## 35-02. リソース別コスト

### CloudFront

#### ・転送

オリジンに転送する前にキャッシュを用いてレスポンスを返信できるため，オリジンでかかる料金を抑えられる．

<br>

### EBS

#### ・ボリュームサイズ

ボリュームの使用率にかかわらず，構築されたボリュームの合計サイズに基づいて，料金が発生する．そのため，安易に500GiBを選んではいけない．

<br>

### EC2

#### ・料金体系の選択

使い方に応じた料金体系を選べる．レスポンスの返信時に料金が発生する．

参考：https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/concepts.html#ec2-pricing

| 種類                     | 説明                                                         | 補足                                                   |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------ |
| オンデマンドインスタンス |                                                              | 参考：https://aws.amazon.com/jp/ec2/pricing/on-demand/ |
| Savings Plans            |                                                              |                                                        |
| リザーブドインスタンス   | EC2インスタンスの一定期間分の使用料金を前払いし，その代わりに安く利用できるようになる． |                                                        |
| スポットインスタンス     |                                                              |                                                        |

#### ・料金発生の条件

インスタンスのライフサイクルの状態に応じて，料金が発生する．

参考：https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ec2-instance-lifecycle.html

| インスタンスの状態 | 料金発生の有無 | 補足                                                       |
| ------------------ | -------------- | ---------------------------------------------------------- |
| pending            | なし           |                                                            |
| running            | あり           |                                                            |
| stopping           | 条件付きでなし | 停止準備中の間は料金が発生し，休止準備中の間は発生しない． |
| stopped            | なし           |                                                            |
| shutting-down      | なし           |                                                            |
| terminated         | なし           |                                                            |

<br>

### ECS

#### ・ECRの容量

500MBを超えると，請求が発生するため，古いイメージを定期的に削除する必要がある．

<br>

### Lambda

#### ・実行時間の従量課金制

関数を実行している時間分だけ料金がかかる．関数を使用せずに設置しているだけであれば，料金はかからない．

<br>

### RDS

#### ・料金体系

以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/User_DBInstanceBilling.html

| 種類                     | 説明                                                         |
| :----------------------- | ------------------------------------------------------------ |
| オンデマンドインスタンス | 参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_OnDemandDBInstances.html |
| リザーブドインスタンス   | RDSインスタンスの一定期間分の使用料金を前払いし，その代わりに安く利用できるようになる．<br>参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_WorkingWithReservedDBInstances.html |

<br>

### SES

#### ・送受信数

受信は```1000件/月```まで，送信は```62000/月```まで無料である．

<br>

### VPC

##### ・レスポンス

<br>

## 36. タグ

### タグ付け戦略

#### ・よくあるタグ

| タグ名      | 用途                                                         |
| ----------- | ------------------------------------------------------------ |
| Name        | リソース自体に名前を付けられない場合，代わりにタグで名付けるため． |
| Environment | 同一のAWS環境内に異なる実行環境が存在している場合，それらを区別するため． |
| User        | 同一のAWS環境内にリソース別に所有者が存在している場合，それらを区別するため． |

#### ・タグ付けによるフィルタリング

AWSの各リソースには，タグをつけることができる．例えば，AWSコストエクスプローラーにて，このタグでフィルタリングすることにより，任意のタグが付いたリソースの請求合計額を確認できる．