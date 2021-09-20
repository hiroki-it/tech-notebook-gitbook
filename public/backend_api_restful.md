# RESTful APIの概念と実装

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. RESTとRESTfulとは

### REST

#### ・RESTとは

分散型アプリケーションを構築する時に，それぞれアプリケーションを連携させるのに適したアーキテクチャスタイルをRESTという．また，アーキテクチャスタイルについては，オブジェクト指向に関するノートを参照せよ．RESTは，以下の特徴を持つ．

![REST](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/REST.jpg)

#### ・RESTfulとRESTful APIとは

RESTに基づいた設計をRESTfulという．RESTful設計が用いられたWebAPIをRESTful APIという．例えば，RESTful APIの場合，DBにおけるUserInfoのCRUDに対して，一つの『/UserInfo』というURIを対応づけている．

![RESTfulAPIを用いたリクエスト](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/RESTfulAPIを用いたリクエスト.png)

<br>

### RESTの４原則

#### ・Stateless

クライアントに対してレスポンスを返信した後に，クライアントの情報を保持せずに破棄する仕組みのこと．擬似的にStatefulな通信を行う時は，キャッシュ，Cookie，セッションIDを用いて，クライアントの情報を保持する．

| Statelessプロトコル | Statefulプロトコル |
| ------------------- | ------------------ |
| HTTP                | SSH                |
| HTTPS               | TLS/SSL            |
| -                   | SFTP               |

#### ・Connectability
#### ・Uniform Interface

HTTPプロトコルを使用したリクエストを，『リソースに対する操作』とらえ，リクエストにHTTPメソッドを対応づけるようにする．

#### ・Addressability

エンドポイントによって，特定のリソースを操作できること．

<br>

## 02. Addressability

### エンドポイント

#### ・エンドポイントとは

特定のリソースを操作するための固有のURIのこと．エンドポイント は，リソース1つごと，あるいはまとまりごとに割り振られる．

#### ・HTTPメソッド，エンドポイント，ユースケースの対応関係

RESTfulAPIでは，全てのHTTPメソッドの内，主に以下の4つを使用して，データ処理の方法をリクエストする．それぞれが，APIのユースケースに対応する．ユースケースごとのメソッド名については，Laravelを参考にする．

参考：https://noumenon-th.net/programming/2020/01/30/laravel-crud/

| HTTPメソッド | エンドポイント                         | ユースケース                                                 | メソッド名の例  |
| ------------ | -------------------------------------- | ------------------------------------------------------------ | --------------- |
| GET          | ```https://example.co.jp/users```      | ・全データのインデックス取得<br>・条件に基づくデータの取得   | index           |
|              | ```https://example.co.jp/users/{id}``` | IDに基づくデータの取得                                       | show            |
| POST         | ```https://example.co.jp/users```      | ・データの作成<br>・PDFの作成<br>・ファイルデータの送信<br>・ログイン／ログアウト | create，store   |
| PUT`         | ```https://example.co.jp/users/{id}``` | データの更新（置換）                                         | update          |
| DELETE       | ```https://example.co.jp/users/{id}``` | データの削除                                                 | delete，destroy |

#### ・POST送信 vs PUT送信

POST送信とPUT送信の重要な違いについてまとめる．データを作成するユースケースの時はPOST送信，または更新する時はPUT送信を使用する．ただしもっと正確には，ユースケースが『作成』or『更新』ではなく，『非冪等』or『冪等』で判断したほうが良い．

参考：

- https://stackoverflow.com/a/2691891/12771072
- https://restfulapi.net/rest-put-vs-post/

|                            | POST送信                                           | PUT送信                                                      |
| -------------------------- | -------------------------------------------------- | ------------------------------------------------------------ |
| データ作成の冪等性         | リクエスト1つにつき，1つのデータを作成（非冪等的） | リクエスト数に限らず，1つのデータを作成する（冪等的）．古いデータを新しいデータに置換する行為に近い． |
| リクエストパラメータの場所 | メッセージボディにJSONデータなどを割り当てる．     | パスパラメータにidなど，またメッセージボディにJSONデータなどを割り当てる． |

<br>


### パラメータの割り当て方法

#### ・パス，クエリストリングへの割り当て

URIの構造のうち，パスまたはクエリストリングにパラメータを割り当てて送信する．それぞれ，パスパラメータまたはクエリパラメータという．

```http
GET https://example.co.jp:80/users/777?text1=a&text2=b
```

| 完全修飾ドメイン名          | 送信先のポート番号（```80```の場合は省略可） | ルート      | パスパラメータ | ？      | クエリパラメータ（GET送信時のみ） |
| --------------------------- | -------------------------------------------- | ----------- | -------------- | ------- | --------------------------------- |
| ```https://example.co.jp``` | ```80```                                     | ```users``` | ```{id}```     | ```?``` | ```text1=a&text2=b```             |

#### ・使い分け（再掲）

| データの送信対象         | パスパラメータ | クエリパラメータ |
| ------------------------ | :------------: | :--------------: |
| 単一条件で決まる検索処理 |       ◯        |        △         |
| 複数条件で決まる検索処理 |       ✕        |        ◯         |
| フィルタリング処理       |       ✕        |        ◯         |
| ソーティング処理         |       ✕        |        ◯         |

#### ・メッセージボディへの割り当て

JSON型データ内に定義し，メッセージボディにパラメータを割り当てて送信する．

```http
POST https://example.co.jp HTTP/2

# メッセージボディ
{
  "id": 1,
  "name": "foo",
}
```

#### ・リクエストヘッダーへの割り当て

リクエストヘッダーにパラメータを割り当てて送信する．送信時のヘッダー名は大文字でも小文字でもいずれでも問題ないが，内部的に小文字に変換されるため，小文字が推奨である．APIキーのヘッダー名の頭文字に『```X```』を付けるのは，独自ヘッダーの頭文字に『```X```』を付ける慣習があったためである．ただし，現在は非推奨である．

参考：https://developer.mozilla.org/ja/docs/Web/HTTP/Headers

```http
POST https://example.co.jp HTTP/2
# Authorizationヘッダー
authorization: Bearer ${Token}
# APIキーヘッダー
x-api-key: *****
```

<br>

### レスポンスのステータスコード

#### ・使い分け

| コード | 概要                                           | 説明                                                         |
| ------ | ---------------------------------------------- | ------------------------------------------------------------ |
| 200    | 成功                                           | 正しいリクエストである．                                     |
| 401    | 認証エラー                                     | 誤ったリクエストである．認証プロセスで正しいトークンが発行されず，認可プロセスのリクエストでこの誤ったトークンを送信したことを表している．認可の失敗ではなく，認証の失敗であることに注意する． |
| 403    | 認可エラーによるトークン所有者の認可スコープ外 | 誤ったリクエストである．APIに認証プロセスが存在し，トークンの発行が必要だとする．認証プロセスにて正しいトークンが発行されたが，認可プロセスにてトークンの所有者の認可スコープ外と判定されたことを表している． |
|        | 送信元IPアドレスの閲覧禁止                     | 誤ったリクエストである．APIに認証認可プロセスが存在せず，トークン発行と閲覧権限検証が不要だとする．送信元IPアドレスに閲覧権限がないと判定されてことを表している． |
| 404    | ページが見つからない                           | 誤ったリクエストである．存在しないデータをリクエストしていることを表している． |
| 409    | 競合エラー                                     | 誤ったリクエストである．UPDATE処理による新しいデータと現在のDBのデータの間で競合が起こっていることを表している．楽観的ロックによる排他制御の結果として使用する．<br>参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_database_operation.html |
| 412    | リソースアクセスエラー                         | 誤ったリクエストである．リソースへのアクセスに失敗したことを表している． |
| 422    | バリデーションエラー                           | 誤ったリクエストである．送信されたパラメータが誤っていることを示している． |
| 500    | サーバエラー                                   | サーバーの処理でランタイムエラーが起こっている．エラーの種類については，以下のリンクを参考にせよ．<br>参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/frontend_and_backend_authentication_authorization.html |
| 503    | ビジネスロジックエラー                         | エラーは起こらないが，ビジネス上ありえないデータをリクエストしていることを表す． |

#### ・リダイレクトとリライトの違い

リダイレクトでは，リクエストされたURLをサーバ側で新しいURLに書き換えてブラウザに返信し，ブラウザがリクエストを再送信する．そのため，クライアント側は新しいURLで改めてリクエストを送信することになる．一方で，リライトでは，リクエストされたURLをサーバ側で異なるURLに書き換え，サーバがそのままリクエストを送信する．そのため，クライアント側は古いURLのままリクエストを送信することになる．その他の違いについては，以下を参考にせよ．

参考：https://blogs.iis.net/owscott/url-rewrite-vs-redirect-what-s-the-difference

#### ・リライトとフォワードの違い

リライトでは異なるサーバにリクエストを送信できるが，フォワードでは同一サーバ内の異なるファイルにアクセスすることしかできない．

<br>

### リソースアクセスのエンドポイントの作り方

#### ・動詞を使用しないこと

すでにHTTPメソッド自体に動詞の意味合いが含まれるため，エンドポイントに動詞を含めないようにする．この時，アクセスするリソース名がわかりやすいような名詞を使用する．

参考：

- https://cloud.google.com/blog/products/api-management/restful-api-design-nouns-are-good-verbs-are-bad
- https://stackoverflow.blog/2020/03/02/best-practices-for-rest-api-design/#h-use-nouns-instead-of-verbs-in-endpoint-paths

ただし認証に関しては，慣例として，エンドポイントが動詞になることが許容されている．

参考：

- https://stackoverflow.com/questions/7140074/restfully-design-login-or-register-resources
- https://www.developer.com/web-services/best-practices-restful-api

**＊悪い実装例＊**

```http
GET https://example.co.jp/show-user/12345
```

**＊良い実装例＊**

```http
GET https://example.co.jp/users/12345
```

```http
GET https://example.co.jp/users/hiroki_hasegawa
```

**＊認証の場合＊**

動詞を許容するのであれば```login```や```logout```とし，名詞を採用するのであれば```session```とする．

```http
GET https://example.co.jp/login
```

```http
GET https://example.co.jp/session
```

#### ・短くすること

**＊悪い実装例＊**

ここで，```service```，```api```，といったキーワードは，なくても問題ない．


```http
GET https://example.co.jp/service/api/users/12345
```

**＊良い実装例＊**


```http
GET https://example.co.jp/users/12345
```

#### ・略称を使わないこと

**＊悪い実装例＊**

ここで，Usersを意味する『```u```』といった略称は，当時の設計者しかわからないため，不要である．

```http
GET https://example.co.jp/u/12345
```

**＊良い実装例＊**

略称を使わずに，『users』とする．

```http
GET https://example.co.jp/users/12345
```

#### ・小文字を使うこと

**＊悪い実装例＊**

```http
GET https://example.co.jp/Users/12345
```

**＊良い実装例＊**

```http
GET https://example.co.jp/users/12345
```

#### ・ケバブケースを使うこと

**＊悪い実装例＊**

```http
GET https://example.co.jp/users_id/12345
```

**＊良い実装例＊**

スネークケースやキャメケースを使わずに，ケバブケースを使用する．

```http
GET https://example.co.jp/users-id/12345
```

ただ，そもそもケバブ方式も利用せずに，スラッシュで区切ってしまうのも手である

```http
GET https://example.co.jp/users/id/12345
```

#### ・複数形を使用すること

**＊悪い実装例＊**

Usersという集合の中に，Idが存在しているため，単数形は使わない．

```http
GET https://example.co.jp/user/12345
```

**＊良い実装例＊**

```http
GET https://example.co.jp/users/12345
```

#### ・システムの設計方法がバレないURIにすること

**＊悪い実装例＊**

悪意のあるユーザに，脆弱性を狙われる可能性があるため，システムの設計方法がばれないアーキテクチャにすること．ミドルウェアにCGIプログラムが使用されていることや，phpを使用していることがばれてしまう．

```http
GET https://example.co.jp/cgi-bin/get_users.php
```

**＊良い実装例＊**

```http
GET https://example.co.jp/users/12345
```

#### ・HTTPメソッドの名前を使用しないこと

**＊悪い実装例＊**

メソッドから，処理の目的はわかるので，URIに対応する動詞名を実装する必要はない．

```http
GET https://example.co.jp/users/get/12345
```

```http
POST https://example.co.jp/users/create/12345
```


```http
PUT https://example.co.jp/users/update/12345
```

```http
DELETE https://example.co.jp/users/delete/12345
```

**＊良い実装例＊**

```http
GET https://example.co.jp/users/{id}
```

```http
POST https://example.co.jp/users
```

```http
PUT https://example.co.jp/users/{id}
```

```http
DELETE https://example.co.jp/users/{id}
```

#### ・数字，バージョン番号を可能な限り使用しないこと

**＊悪い実装例＊**

ここで，```alpha```，```v2```，といったキーワードは，当時の設計者しかわからないため，あまり良くない．ただし，利便上，使う場合もある．

```http
GET https://example.co.jp/v2/users/12345
```

**＊良い実装例＊**

```http
GET https://example.co.jp/users/12345
```

URLにバージョンを表記しない代わりに，リクエストヘッダーの```X-api-Version```にバージョン情報を格納する方法がより良い．

```http
X-Api-Version: 1
```

#### ・異なるHTTPメソッドの間でルールを統一すること

**＊悪い実装例＊**

GET送信とPOST送信の間で，IDパラメータのHTTPメソッドが統一されていない．

```http
GET https://example.co.jp/users/?id=12345
```

```http
POST https://example.co.jp/users/12345/messages
```

**＊良い実装例＊**

以下のように，異なるHTTPメソッドの間でも統一する．


```http
GET https://example.co.jp/users/12345
```

```http
POST https://example.co.jp/users/12345/messages
```

<br>

## 03. リクエスト／レスポンスメッセージ

### メッセージとは

アプリケーション層で生成されるデータを，メッセージという．リクエスト時にクライアント側で生成されるメッセージをリクエストメッセージ，レスポンス時にサーバ側で生成されるメッセージをレスポンスメッセージという．

<br>

### リクエストメッセージの構造

#### ・GET送信の場合

クエリパラメータに送信するデータを記述する方法．リクエストメッセージは，以下の要素に分類できる．以下では，Web APIのうち，特にRESTfulAPIに対して送信するためのリクエストメッセージの構造を説明する．

```http
GET https://example.co.jp/bar-form.php?text1=a&text2=b HTTP/2
# リクエストされたドメイン名
Host: example.co.jp
Connection: keep-alive
Upgrade-Insecure-Requests: 1
# ブラウザキャッシュの最大有効期限（リクエストヘッダーとレスポンスヘッダーの両方で定義可能）
Cache-Control: max-age=31536000
# ブラウザのバージョン情報等
User-Agent: Mozzila/5.0 (Windows NT 10.0; Win64; x64) Ch
# レスポンスで送信してほしいMIMEタイプ
Accept: text/html, application/xhtml+xml, application/xml; q=0
# 遷移元のページ
Referer: https://foo.co.jp/
# レスポンスしてほしいエンコーディング形式
Accept-Encondig: gzip, deflate, br
# レスポンスで送信してほしい言語
Accept-Language: ja, en-US; q=0.9, en; q=0.8
# 送信元IPアドレス
# ※プロキシサーバ（ALBやCloudFrontなども含む）を経由している場合に，それら全てのIPアドレスも順に設定される
X-Forwarded-For: <client>, <proxy1>, <proxy2>
```

#### ・POST送信の場合


クエリパラメータを，URLに記述せず，メッセージボディに記述してリクエストメッセージを送る方法．以下では，Web APIのうち，特にRESTfulAPIに対して送信するためのリクエストメッセージの構造を説明する．メッセージボディに情報が記述されるため，履歴では確認できない．また，SSLによって暗号化されるため，傍受できない．リクエストメッセージは，以下の要素に分類できる．

```http
POST https://example.co.jp/bar-form.php HTTP/2
# リクエストされたドメイン名
Host: example.co.jp
Connection: keep-alive
Content-Length: 15
# ブラウザキャッシュの最大有効期限（リクエストヘッダーとレスポンスヘッダーの両方で定義可能）
Cache-Control: no-store
# オリジン（プロトコル＋ドメイン＋ポート番号）
Origin: https://example.co.jp
Upgrade-Insecure-Requests: 1
# リクエストで送信するMIMEタイプ
Content-Type: application/x-www-firm-urlencoded
# ブラウザのバージョン情報等
User-Agent: Mozzila/5.0 (Windows NT 10.0; Win64; x64) Ap
# レスポンスで送信してほしいMIMEタイプ
Accept: text/html, application/xhtml+xml, application/xml; q=0
# 遷移元のページ
Referer: https://foo.co.jp/
Accept-Encondig: gzip, deflate, br
# レスポンスで送信してほしい言語
Accept-Language: ja, en-US; q=0.9, en; q=0.8
# 各Cookieの値（二回目のリクエスト時に設定される）
Cookie: sessionid=<セッションID>; csrftoken=<トークン>; _gat=1
# 送信元IPアドレス
# ※プロキシサーバ（ALBやCloudFrontなども含む）を経由している場合に，それら全てのIPアドレスも順に設定される
X-Forwarded-For: <client>, <proxy1>, <proxy2>

# ボディ．（SSLによって暗号化されるため閲覧不可）
text=a&text2=b 
```

#### ・例外として，ボディをもつGET送信の場合

GET送信ではあるが，ボディにクエリパラメータを記述して送信する方法がある．

POSTMANで，GET送信にメッセージボディを含めることについて：
https://github.com/postmanlabs/postman-app-support/issues/131

<br>

### レスポンスメッセージの構造

**＊具体例＊**

```http
200 OK
# レスポンスで送信するMIMEタイプ
Content-Type: text/html;charset=UTF-8
Transfer-Encoding: chunked
Connection: close
# Webサーバ（nginx，apache，AmazonS3などが表示される）
Server: nginx
Date: Sat, 26 Sep 2020 04:25:08 GMT
# リファラポリシー（nginx，apache，などで実装可能）
Referrer-Policy: no-referrer-when-downgrade
x-amz-rid:	*****
# セッションIDを含むCookie情報
Set-Cookie: session-id=*****; Domain=.amazon.co.jp; Expires=Sun, 26-Sep-2021 04:25:08 GMT; Path=/
Set-Cookie: session-id-time=*****; Domain=.amazon.co.jp; Expires=Sun, 26-Sep-2021 04:25:08 GMT; Path=/
Set-Cookie: i18n-prefs=JPY; Domain=.amazon.co.jp; Expires=Sun, 26-Sep-2021 04:25:08 GMT; Path=/
Set-Cookie: skin=noskin; path=/; domain=.amazon.co.jp
Accept-CH: ect,rtt,downlink
Accept-CH-Lifetime:	86400
X-UA-Compatible: IE=edge
Content-Language: ja-JP
# ブラウザキャッシュの最大有効期限（リクエストヘッダーとレスポンスヘッダーの両方で定義可能）
Cache-Control: no-cache
# ブラウザキャッシュの最大有効期限（レスポンスヘッダーのみで定義可能）
Expires: Wed, 21 Oct 2015 07:28:00 GMT
Pragma:	no-cache
X-XSS-Protection: 1;
X-Content-Type-Options:	nosniff
Vary: Accept-Encoding,User-Agent,Content-Type,Accept-Encoding,X-Amzn-CDN-Cache,X-Amzn-AX-Treatment,User-Agent
Strict-Transport-Security: max-age=*****; includeSubDomains; preload
X-Frame-Options: SAMEORIGIN
# CloudFrontのキャッシュにヒットしたかどうか
X-Cache: Miss from cloudfront
Via: 1.1 *****.cloudfront.net (CloudFront)
X-Amz-Cf-Pop: SEA19-C2
X-Amz-Cf-Id: *****==
# 言語のバージョン（※ php.ini にて，expose_php = Off と設定することで非表示にできる）
X-Powered-By: PHP/7.3.22

# ボディ
ここにサイトのHTMLのコード
```

<br>

### リクエストメッセージの送信方法

#### ・PHP

```php
<?php

define("URL", "https://foo.com");

// curlセッションを初期化する
$curl = curl_init();

// オプションの設定
curl_setopt_array(
    $curl,
    [
        // URL
        CURLOPT_URL            => URL,
        // HTTPメソッド
        CURLOPT_CUSTOMREQUEST  => "GET",
        // SSL証明書の検証
        CURLOPT_SSL_VERIFYPEER => false,
        // 文字列型で受信
        CURLOPT_RETURNTRANSFER => true
    ]
);

// リクエストの実行
$messageBody = (curl_exec($curl))
    ? curl_exec($curl)
    : [];

// curlセッションを閉じる
curl_close($curl);
```

<br>

### リクエストコンテキスト

#### ・リクエストコンテキストとは

リクエストを受信した時に，これのデータ（ボディ，ヘッダー，など）や，セッションを操作できる仕組みのこと．

<br>

## 04. オブジェクトデータ

### オブジェクトデータ

#### ・オブジェクトデータとは

リクエスト（POST）／レスポンスにて，メッセージボディに割り当てて送信／返信するデータのこと．

#### ・MIME type（Content type）

POST／PUT送信において，ボディパラメータのデータ形式を表現する識別子のこと．リクエストヘッダー／レスポンスヘッダーのContent-Typeヘッダーに割り当てると，オブジェクトデータのデータ型を定義できる．GET送信には不要である．

参考：https://stackoverflow.com/questions/5661596/do-i-need-a-content-type-header-for-http-get-requests

| トップレベルタイプ | サブレベルタイプ      | 意味                                |
| ------------------ | --------------------- | ----------------------------------- |
| application        | octet-stream          | 任意のMIME type（指定なし）を示す． |
|                    | javascript            |                                     |
|                    | json                  |                                     |
|                    | x-www-form-urlencoded | POST送信のデータ                    |
|                    | zip                   |                                     |
| text               | html                  | HTMLテキスト                        |
|                    | css                   | CSSテキスト                         |
|                    | plane                 | プレーンテキスト                    |
| image              | png                   |                                     |
|                    | jpeg                  |                                     |
|                    | gif                   |                                     |

#### ・データ型の指定方法

最も良い方法は，リクエストのContent-Typeヘッダーに，『```application/json```』を設定することである．

```http
POST https://example.co.jp/users/12345
# ヘッダー
Content-Type: application/json
```

他に，URIでデータ型を記述する方法がある．

```http
POST https://example.co.jp/users/12345?format=json
```

<br>

### リクエスト（POST，PUT）

正常系レスポンスで返信するオブジェクトデータと同じ．

<br>

### 正常系レスポンスの場合

#### ・POST／PUTでは処理後データをレスポンス

POST／PUTメソッドでは，処理後のデータを200レスポンスとして返信する．もし処理後のデータを返信しない場合，改めてGETリクエストを送信する必要があり，余分なAPIコールが必要になってしまう．

参考：

- https://developer.ntt.com/ja/blog/741a176b-372f-4666-b649-b677dd23e3f3
- https://qiita.com/wim/items/dbb6def4e207f6048735

#### ・DELETEではメッセージのみをレスポンス

DELETEメソッドでは，メッセージのみを200レスポンスとして返信する．空ボディ204レスポンスとして返信してもよい．

参考：

- https://stackoverflow.com/questions/25970523/restful-what-should-a-delete-response-body-contain/50792918
- https://qiita.com/fukuma_biz/items/a9e8d18467fe3e04068e#4-delete---%E3%83%AA%E3%82%BD%E3%83%BC%E3%82%B9%E3%81%AE%E5%89%8A%E9%99%A4

#### ・ステータスコードは不要

正常系レスポンスの場合，オブジェクトデータへのステータスコードの割り当ては不要である．

```shell
{
  "name": "Taro Yamada"
}
```

#### ・フラットなデータ構造にすること

JSONの場合，階層構造にすると，データ容量が増えてしまう．

**＊具体例＊**

```shell
{
  "name": "Taro Yamada",
  "age": 10,
  "interest": {
    "sports":["soccer", "baseball"],
    "subjects": "math"
  }
}
```

そこで，できるだけデータ構造をフラットにする．ただし，見やすさによっては階層構造も許容される．

参考：https://www.amazon.co.jp/Web-API-The-Good-Parts/dp/4873116864

**＊具体例＊**

```shell
{
  "name": "Taro Yamada",
  "age": 10,
  "sports":["soccer", "baseball"],
  "subjects": "math"
}
```

あるいは，Content-Typeヘッダーに『```application/hal+json```』『```application/vnd.api+json```』『```application/vnd.collection+json```』といったよりJSONベースの強い制約のフォーマットを利用する．

#### ・日付データの形式に気をつけること

RFC3339（W3C-DTF）形式でオブジェクトデータに含めて送受信すること．

**＊具体例＊**

````
2020-07-07T12:00:00+09:00
````

ただし，日付をリクエストパラメータで送受信する時，RFC3339（W3C-DTF）形式を正規表現で設定する必要があるので注意．

**＊具体例＊**

```
https://example.co.jp/users/12345?date=2020-07-07T12:00:00%2B09:00
```

<br>

### 異常系レスポンスの場合

```shell
{
  "code": 400
  "errors": [
    "〇〇は必ず入力してください．",
    "□□は必ず入力してください．"
  ]
  "url" : "https://*****x"
}
```

参考：https://qiita.com/suin/items/f7ac4de914e9f3f35884#%E3%82%A8%E3%83%A9%E3%83%BC%E3%83%AC%E3%82%B9%E3%83%9D%E3%83%B3%E3%82%B9%E3%81%A7%E8%80%83%E6%85%AE%E3%81%97%E3%81%9F%E3%81%84%E3%81%93%E3%81%A8

| 種類                 | 必要性 | データ型 | 説明                                                         |
| -------------------- | ------ | -------- | ------------------------------------------------------------ |
| エラーメッセージ     | 必須   | 文字列型 | 複数のエラーメッセージを返信できるように，配列として定義する． |
| ステータスコード     | 任意   | 整数型   | エラーの種類がわかるステータスコードを割り当てる．           |
| エラーコード         | 任意   | 文字列型 | APIドキュメントのエラーの識別子として，エラコードを割り当てる． |
| APIドキュメントのURL | 任意   | 文字列型 | 外部に公開するAPIの場合に，エラーの解決策がわかるAPIドキュメントのURLを割り当てる． |

<br>

## 05. Statelessプロトコルにおける擬似Stateful化

### Cookie，Cookie情報（キー名／値）

#### ・Cookie，Cookie情報とは

クライアントからの次回のリクエスト時でも，Cookie情報（キー名／値のセット）を用いて，同一クライアントと認識できる仕組みをCookieという．HTTPはStatelessプロトコルであるが，Cookie情報により擬似的にStatefulな通信を行える．

#### ・Cookie情報に関わるヘッダー

最初，サーバからのレスポンス時，Set-Cookieヘッダーを用いて送信される．反対に，クライアントからのリクエスト時，Cookie情報は，Cookieヘッダーを用いて送信される．


| HTTPメッセージの種類 | ヘッダー名 | 属性     | 内容                                                         |
| -------------------- | ---------- | -------- | ------------------------------------------------------------ |
| レスポンスメッセージ | Set-Cookie | Name     | Cookie名と値                                                 |
|                      |            | Expires  | Cookieの有効期限（日数）                                     |
|                      |            | Max-Age  | Cookieの有効期限（秒数）                                     |
|                      |            | Domain   | クライアントがリクエストする時のCookie送信先ドメイン名．      |
|                      |            | Path     | クライアントがリクエストする時のCookie送信先ディレクトリ     |
|                      |            | Secure   | クライアントからのリクエストでSSLプロトコルが使用されている時のみ，リクエストを送信できるようにする． |
|                      |            | HttpOnly | クライアント側で，JavaScriptがCookieを使用できないようにする．XSS攻撃の対策になる． |
| リクエストメッセージ | Cookie     |          | セッションIDなどのCookie情報                                 |

クライアントから送信されてきたリクエストメッセージのCookieヘッダーの内容は，グローバル変数に格納されている．

```php
<?php
    
$_COOKIE = ["Cookie名" => "値"]
```

#### ・仕組み

1. 最初，ブラウザはリクエストでデータを送信する．
2. サーバは，レスポンスヘッダーのSet-CookieヘッダーにCookie情報を埋め込んで送信する．

```php
<?php

setcookie(Cookie名, Cookie値, 有効日時, パス, ドメイン, HTTPS接続のみ, Javascript無効）
```

3. ブラウザは，そのCookie情報を保存する．
4. 2回目以降のリクエストでは，ブラウザは，リクエストヘッダーのCookieヘッダーにCookie情報を埋め込んでサーバに送信する．サーバは，Cookie情報に紐づくクライアントのデータをReadする．

![cookie](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/cookie.png)

<br>

### セッション

#### ・セッション，セッションIDとは

![session-id_page-transition](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/session-id_page-transition.png)

特定のサイトを訪問してから，離脱するまでの一連のユーザ操作を『セッション』という．この時，セッションIDを用いると，セッションの各リクエストの送信元を同一クライアントとして識別できる．HTTPはStatelessプロトコルであるが，セッションIDにより擬似的にStatefulな通信を行える．例えばセッションIDにより，ログイン後にページ遷移を行っても，ログイン情報を保持でき，同一ユーザからのリクエストとして認識できる．セッションIDは，Cookie情報の一つとして，CookieヘッダーとSet-Cookieヘッダーを使用して送受信される．

```http
# リクエストヘッダーの場合
Cookie: sessionid=<セッションID>; csrftoken=u32t4o3tb3gg43; _gat=1
```


```http
# レスポンスヘッダーの場合
Set-Cookie: sessionId=<セッションID>
```

セッション数はGoogleコンソールで確認できる．GoogleConsoleにおけるセッションについては，以下のリンクを参考にせよ．

参考：https://support.google.com/analytics/answer/6086069?hl=ja

#### ・セッションIDの発行，セッションファイルの生成

セッションは，```session_start```メソッドを用いることで開始される．また同時に，クライアントにセッションIDを発行する．グローバル変数にセッションIDを代入することによって，セッションIDの記載されたセッションファイルを作成する．セッションIDに紐づくその他のデータはこのセッションファイルに書き込まれていく．セッションファイルの名前は，```sess_*****```ファイルとなっており，セッションファイル名を元にしてセッションIDに紐づくデータを参照する．もしクライアントに既にセッションIDが発行されている場合，セッションファイルを参照するようになる．

**＊実装例＊**

```php
<?php

// セッションの開始．セッションIDを発行する．
session_start();

// セッションファイルを作成
$_SESSION["セッション名"] = "値"; 
```

#### ・セッションファイルの保存場所

セッションファイルの保存場所は```/etc/php.ini```ファイルで定義できる．

```ini
# /etc/php.ini

### ファイル形式
session.save_handler = files
### 保存場所
session.save_path = "/tmp"
```

セッションファイルは，サーバ外（PHP Redis，ElastiCache Redisなど）に保存することもできる．```/etc/php-fpm.d/www.conf```ファイルではなく，```/etc/php.ini```ファイルにて保存先の指定が必要である．ElastiCache Redisについては，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws.html

```ini
# /etc/php.ini

### Redis形式
session.save_handler = redis
### Amazon RedisのOrigin
session.save_path = "tcp://*****-redis.*****.ng.0001.apne1.cache.amazonaws.com:6379"
```

なお，PHP-FPMを使用している場合は，```/etc/php-fpm.d/www.conf```ファイルにて，セッションファイルの保存先を指定する必要がある．

```ini
# /etc/php-fpm.d/www.conf

### Redis形式
php_value[session.save_handler] = redis
### Amazon RedisのOrigin
php_value[session.save_path] = "tcp://*****-redis.*****.ng.0001.apne1.cache.amazonaws.com:6379"
```

#### ・セッションの有効期限と初期化確率

セッションの有効期限を設定できる．これにより，画面遷移時にログイン情報を保持できる秒数を定義できる．

```ini
# 24時間
session.gc_maxlifetime = 86400
```

ただし，有効期限が切れた後にセッションファイルを初期化するかどうかは確率によって定められている．確率は， 『```gc_probability```÷```gc_divisor```』 で計算される．

参考：https://www.php.net/manual/ja/session.configuration.php#ini.session.gc-divisor

```ini
# 有効期限後に100%初期化されるようにする．
session.gc_probability = 1
session.gc_divisor = 1
```

#### ・仕組み

1. 最初，ブラウザはリクエストでデータを送信する．セッションIDを発行し，セッションIDごとに```sess_*****```ファイルを生成．
2. サーバは，レスポンスヘッダ情報のCookieヘッダーを使用して，セッションIDを送信する．
3. ブラウザは，そのセッションIDを保存する．
4. 2回目以降のリクエストでは，ブラウザは，リクエストヘッダ情報のCookieヘッダーを使用して，セッションIDをサーバに送信する．サーバは，セッションIDに紐づくクライアントのデータをReadする．

![session-id](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/session-id.png)

<br>

## 06. API仕様書

### OpenAPI仕様

#### ・OpenAPI仕様とは

RESTful APIの仕様を実装により説明するためのフォーマットのこと．JSON型またはYAML型で実装できる．いくつかのフィールドから構成されている．

参考：https://spec.openapis.org/oas/v3.1.0#fixed-fields

```yaml
openapi: # openapiフィールド

info: # infoフィールド

servers: # serversフィールド

paths: # pathsフィールド

webhooks: # webhooksフィールド

components: # componentsフィールド

security: # securityフィールド

tags: # tagsフィールド

externalDocs: # externalDocsフィールド
```

#### ・API Gatewayによるインポート

API GatewayによるOpenAPI仕様のインポートについては，以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws_apigateway_import.html

#### ・openapiフィールド（必須）

OpenAPI仕様のバージョンを定義する．

**＊実装例＊**

```yaml
openapi: 3.0.0
```

#### ・infoフィールド（必須）

API名，作成者名，メールアドレス，ライセンス，などを定義する．

**＊実装例＊**

```yaml
info:
  title: Foo API # API名
  description: The API for Foo. # APIの説明
  termsOfService: https://www.foo.com/terms/ # 利用規約
  contact:
    name: API support # 連絡先名
    url: https://www.foo.com/support # 連絡先に関するURL
    email: support@foo.com # メールアドレス
  license:
    name: Apache 2.0 # ライセンス
    url: https://www.apache.org/licenses/LICENSE-2.0.html # URL
  version: 1.0.0 # APIドキュメントのバージョン
```

#### ・serversフィールド

API自体のURL，などを定義する．

**＊実装例＊**

```yaml
servers:
  - url: https://{env}.foo.com/api/v1
    description: |
    variables:
      env:
        default: stg
        description: API environment
        enum:
          - stg
          - www
```

#### ・pathsフィールド（必須）

APIのエンドポイント，HTTPメソッド，ステータスコード，などを定義する．

```yaml
paths:
  #===========================
  # pathsオブジェクト
  #===========================
  /users:
    #===========================
    # path itemオブジェクト
    #===========================
    get: # GETメソッドを指定する．
      tags:
        - ユーザ情報取得エンドポイント
      summary: ユーザ情報取得
      description: 全ユーザ情報を取得する．
      #===========================
      # リクエスト
      #===========================
      parameters: []
      #===========================
      # レスポンス
      #===========================
      responses:
        '200':
          description: OK レスポンス
          content:
            application/json: # MIME type
              foo: # レスポンスボディ例
                Users:
                  User:
                    userId: 1
                    name: Hiroki
              schema:
                $ref: "#/components/schemas/user" # Userモデルを参照する．
        '400':
          description: Bad Request レスポンス
          content:
            application/json: # MIME type
              foo: # レスポンスボディ例
                status: 400
                title: Bad Request
                errors:
                messages: [
                    "不正なリクエストです．"
                ]
              schema:
                $ref: "#/components/schemas/error" # 異常系モデルを参照する．
        '401':
          $ref: "#/components/responses/unauthorized" # 認証エラーを参照する．              
    #===========================
    # path itemオブジェクト
    #===========================
    post: # POSTメソッドを指定する．
      tags:
        - ユーザ情報作成エンドポイント
      summary: ユーザ情報作成
      description: ユーザ情報を作成する．
      #===========================
      # リクエスト
      #===========================
      parameters: []
      requestBody: # メッセージボディにパラメータを割り当てる．
        description: ユーザID
        content:
          application/json: # MIME type
            foo: # メッセージボディ例
              userId: 1
            schema: # スキーマ
              $ref: "#/components/schemas/user" # Userモデルを参照する．
      #===========================
      # レスポンス
      #===========================
      responses:
        '200':
          description: OK レスポンス
          content:
            application/json: # MIME type
              foo: # レスポンスボディ例
                userId: 1
              schema:
                $ref: "#/components/schemas/normal" # スキーマとして，正常系モデルを参照する．
        '400':
          description: Bad Request レスポンス
          content:
            application/json: # MIME type
              foo: # レスポンスボディ例
                status: 400
                title: Bad Request
                errors:
                  messages: [
                      "ユーザIDは必ず指定してください．"
                  ]
              schema:
                $ref: "#/components/schemas/error" # スキーマとして，異常系モデルを参照する．
        '401':
          $ref: "#/components/responses/unauthorized" # 認証エラーを参照する．              
  #===========================
  # pathsオブジェクト
  #===========================
  /users/{userId}:
    #===========================
    # path itemオブジェクト
    #===========================
    get:
      tags:
        - ユーザ情報取得エンドポイント
      summary: 指定ユーザ情報取得
      description: 指定したユーザ情報を取得する．
      #===========================
      # リクエスト
      #===========================
      parameters:
        - in: path # パスにパラメータを割り当てる．
          name: userId
          required: true
          description: ユーザID
          schema:
            type: string
            foo: # パスパラメータ例
              userId=1
      #===========================
      # レスポンス
      #===========================
      responses:
        '200':
          description: OK レスポンス
          content:
            application/json: # MIME type
              foo: # ボディ例
                userId: 1
                name: Hiroki
              schema: # スキーマ
                $ref: "#/components/schemas/user" # Userモデルを参照する．
        '400':
          description: Bad Request レスポンス
          content:
            application/json: # MIME type
              foo: # ボディ例
                status: 400
                title: Bad Request
                errors:
                  messages: [
                      "ユーザIDは必ず指定してください．"
                  ]
              schema:
                $ref: "#/components/schemas/error" # 異常系モデルを参照する．
        '401':
          $ref: "#/components/responses/unauthorized" # 認証エラーを参照する．
        '404':
          description: Not Found レスポンス
          content:
            application/json: # MIME type
              foo: # ボディ例
                status: 404
                title: Not Found
                errors:
                  messages: [
                      "対象のユーザが見つかりませんでした．"
                  ]
              schema:
                $ref: "#/components/schemas/error" # 異常系モデルを参照する．
    #===========================
    # path itemオブジェクト
    #===========================                
    put:
      tags:
        - ユーザ情報更新エンドポイント
      summary: 指定ユーザ更新
      description: 指定したユーザ情報を更新する．
      #===========================
      # リクエスト
      #===========================
      parameters:
        - in: path # パスにパラメータを割り当てる．
          name: userId
          required: true
          description: ユーザID
          schema:
            type: string
            foo: # パスパラメータ例
              userId=1
      #===========================
      # レスポンス
      #===========================
      responses:
        '200':
          description: OK レスポンス
          content:
            application/json: # Content-Type
              foo: # ボディ例
                userId: 1
                name: Hiroki
              schema: # スキーマ
                $ref: "#/components/schemas/user" # Userモデルを参照する．
        '400':
          description: Bad Request レスポンス
          content:
            application/json: # Content-Type
              foo: # ボディ例
                status: 400
                title: Bad Request
                errors:
                  messages: [
                      "ユーザIDは必ず指定してください．"
                  ]
              schema:
                $ref: "#/components/schemas/error" # 異常系モデルを参照する．
        '401':
          $ref: "#/components/responses/unauthorized" # 認証エラーを参照する．
        '404':
          description: Not Found レスポンス
          content:
            application/json: # Content-Type
              foo: # ボディ例
                status: 404
                title: Not Found
                errors:
                  messages: [
                      "対象のユーザが見つかりませんでした．"
                  ]
              schema:
                $ref: "#/components/schemas/error" # 異常系モデルを参照する．                 
```

#### ・componentsフィールド（必須）

スキーマなど，他の項目で共通して利用するものを定義する．

```yaml
components:
  #===========================
  # callbackキーの共通化
  #===========================
  callbacks: { }
  #===========================
  # linkキーの共通化
  #===========================
  links: { }
  #===========================
  # responseキーの共通化
  #===========================
  responses:
    unauthorized:
      description: Unauthorized レスポンス
      content:
        application/json: # MIME type
          foo: # ボディ例
            status: 401
            title: Unauthorized
            errors:
              messages: [
                  "APIキーの認可に失敗しました．"
              ]
          schema:
            $ref: "#/components/schemas/error" # 異常系モデルを参照する．              
  #===========================
  # schemaキーの共通化
  #===========================
  schemas:
    # ユーザ
    user:
      type: object
      properties:
        userId:
          type: string
        name:
          type: string
    # 正常系
    normal:
      type: object
      properties:
        userId:
          type: string
    # 異常系      
    error:
      type: object
      properties:
        messages:
          type: array
          items:
            type: string
  #===========================
  # securityフィールドの共通化
  #===========================
  securitySchemes:
    # Basic認証
    basicAuth:
      description: Basic認証
      type: http
      scheme: basic
    # Bearer認証
    bearerAuth:
      description: Bearer認証
      type: http
      scheme: bearer
    # APIキー認証
    apiKeyAuth:
      description: APIキー認証
      type: apiKey
      name: x-api-key # ヘッダ名は『x-api-key』とする．小文字が推奨である．
      in: header
```

**＊実装例＊**

#### ・securityフィールド

componentsフィールドで定義した認証方法を宣言する．ルートで宣言すると，全てのパスに適用できる．

**＊実装例＊**

```yaml
security: 
  - apiKeyAuth: []
```

#### ・tagsフィールド

各項目に付けるタグを定義する．同名のタグをつけると，自動的にまとめられる．

**＊実装例＊**

```yaml
tags:
  - name: ユーザ情報取得エンドポイント
    description: |
```

#### ・externalDocsフィールド

APIを説明するドキュメントのリンクを定義する．

**＊実装例＊**

```yaml
externalDocs:
  description: 補足情報はこちら
  url: https://foo.com
```

<br>

### スキーマ

#### ・スキーマとは

APIに対して送信されるリクエストメッセージのデータ，またはAPIから返信されるレスポンスメッセージのデータについて，データ型や必須データを，JSON型またはYAML型で実装しておいたもの．リクエスト／レスポンス時のデータのバリデーションに用いる．

#### ・スキーマによるバリデーション

データ型や必須データにより，リクエスト／レスポンスのデータのバリデーションを行う．

参考：https://spec.openapis.org/oas/v3.1.0#data-types

**＊実装例＊**

例えば，APIがレスポンス時に以下のようなJSON型データを返信するとする．

```shell
{
  "id": 1,
  "name": "Taro Yamada",
  "age": 10,
  "sports":["soccer", "baseball"],
  "subjects": "math"
}
```

ここで，スキーマを以下のように定義しておき，APIからデータをレスポンスする時のバリデーションを行う．

```shell
{
  "$schema": "https://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "minimum": 1
    },
    "name": {
      "type": "string"
    },
    "age": {
      "type": "integer",
      "minimum": 0
    },
    "sports": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "subjects": {
      "type": "string"
    }
  },
  "required": ["id"]
}
```

#### ・API Gatewayにおけるスキーマ設定

API Gatewayにて，バリデーションのためにスキーマを設定できる．詳しくは，以下のノートを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws.html



