# Authenticate（認証）／Authorization（認可）

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. HTTP認証

### HTTP認証とは

認証時にHTTP通信の中で認証を行うこと。リクエストの```authorization```ヘッダーとレスポンスの```WWW-Authenticate```ヘッダーで認証スキームを指定する。認証スキームの種類には、『Basic認証』、『Digest認証』、『Bearer認証』などがある。認証情報の一時的な保存は、ブラウザのWebStoregeで行うため、認証解除（ログアウト）をサーバ側で完全に制御できない。

参考：

- https://www.iana.org/assignments/http-authschemes/http-authschemes.xhtml
- https://architecting.hateblo.jp/entry/2020/03/27/130535
- https://developer.mozilla.org/ja/docs/Web/HTTP/Authentication#authentication_schemes

<br>

### Basic認証

#### ・Basic認証の仕組み

![Basic認証](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Basic認証.png)


| 役割         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| クライアント | リクエスト送信元のアプリケーションのこと。文脈によっては、ブラウザがクライアントである場合とそうでない場合（例：OAuth認証）がある。 |
| ユーザ       | クライアントを用いている人物のこと。                       |
| サーバ       | クライアントからリクエストを受信し、レスポンスを送信するアプリケーションのこと。 |

最初、クライアントは、認証後にアクセスできるページのリクエストをサーバに送信する。

```http
GET https://example.co.jp/foo-form HTTP/2
```

サーバは、これ拒否し、```401```ステータスで認証領域を設定し、レスポンスを送信する。これにより、認証領域の値をユーザに示して、ユーザ名とパスワードの入力を求められる。ユーザに表示するための認証領域には、任意の値を持たせることができ、サイト名が設定されることが多い。

```http
401 Unauthorized
WWW-Authenticate: Basic realm="<認証領域>", charaset="UTF-8"
```

『```<ユーザ名>:<パスワード>```』をBase64でエンコードした値を```authorization```ヘッダーに割り当て、リクエストを送信する。

```http
POST https://example.co.jp/foo-form HTTP/2
authorization: Basic bG9naW46cGFzc3dvcmQ=
```

サーバは、ユーザ名とパスワードを照合し、合致していれば、認証後ページのレスポンスを送信する。また、認証情報をブラウザのWebストレージに保存する。

```http
200 OK
WWW-Authenticate: Basic realm=""
```

認証の解除時は、誤った認証情報をブラウザに意図的に送信させて認証を失敗させるようにする。

参考：https://stackoverflow.com/questions/4163122/http-basic-authentication-log-out

```http
POST https://example.co.jp/foo-form/logout HTTP/2
authorization: Basic <誤った認証情報>
```

サーバは、```401```ステータスでレスポンスを返信し、認証が解除される。

```http
401 Unauthorized
WWW-Authenticate: Basic realm="<認証領域>", charaset="UTF-8"
```

<br>


### Digest認証

#### ・Digest認証の仕組み

```http
200 OK
WWW-Authenticate: Basic realm="<認証領域>", charaset="UTF-8"
```

```http
POST https://example.co.jp/foo-form HTTP/2
authorization: Digest realm="<認証領域>" nonce="<サーバ側が生成した任意の文字列>" algorithm="<ハッシュ関数名>" qoq="auth"
```

<br>

### Bearer認証

#### ・Bearer認証とは

認証時にBearerトークンを用いる認証スキームのこと。

#### ・Bearerトークン（署名なしトークン）とは

単なる文字列で定義されたアクセストークン。Bearer認証にて、トークンとして用いる。署名なしトークンとも呼ばれ、実際に認証された本人かどうかを判定する機能は無く、トークンを持っていればそれを本人として認可する。そのため、トークンの文字列が流出してしまわないよう、厳重に管理する必要がある。Bearerトークンを用いるBearer認証については、別項目の説明を参考にせよ。

参考：https://openid-foundation-japan.github.io/rfc6750.ja.html#anchor3

#### ・Bearer認証の仕組み

指定されたエンドポイントに対して、```POST```リクエストを送信する。この時、```Content-Type```ヘッダーを```application/x-www-form-urlencoded```とする。必要なボディパラメータはAPIの提供元によって異なる。クライアントID、付与タイプ、などが必要なことが多い。

参考：

- https://developer.amazon.com/ja/docs/adm/request-access-token.html#request-format
- https://ja.developer.box.com/reference/post-oauth2-token/#request

```http
POST https://example.co.jp/foo HTTP/2
Content-Type: application/x-www-form-urlencoded
    
# ボディ
client_id=*****&grant_type=client_credentials&scope=messaging:push
```

レスポンスボディにBearerトークンを含むレスポンスが返信される。他に、有効期限、権限のスコープ、指定可能な認証スキーマ、などが提供されることが多い。

参考：

- https://developer.amazon.com/ja/docs/adm/request-access-token.html#request-format
- https://ja.developer.box.com/reference/resources/access-token/

```http
200 OK
X-Amzn-RequestId: d917ceac-2245-11e2-a270-0bc161cb589d
Content-Type: application/json

{
  "access_token":"*****",
  "expires_in":3600,
  "scope":"messaging:push",
  "token_type":"Bearer"
}
```

発行されたBearerトークンを指定された認証スキーマで```Authorization```ヘッダーに割り当て、リクエストを送信する。ここでは詳しく言及しないが、BearerトークンをForm認証のように```Cookie```ヘッダーに割り当てることもある。

参考：

- https://stackoverflow.com/questions/34817617/should-jwt-be-stored-in-localstorage-or-cookie
- https://ja.developer.box.com/reference/post-oauth2-token/#response

```http
POST https://example.co.jp/foo HTTP/2
authorization: Bearer <Bearerトークン>
```

サーバは、Bearerトークンを照合し、合致していれば、認証後ページのレスポンスを送信する。無効なBearerトークンをブラックリストとしてRedis／DBで管理しておく。DBでブラックリストを管理すると、リクエストの度にDBアクセス処理が実行されることなってしまうため、Redisでこれを管理した方が良い。

```http
200 OK
WWW-Authenticate: Bearer realm=""
```

認証の解除時は、Redis／DBでBearerトークンの状態を無効化する。またサーバは、```401```ステータスでレスポンスを返信し、認証が解除される。

参考：

- https://stackoverflow.com/questions/21978658/invalidating-json-web-tokens
- https://medium.com/devgorilla/how-to-log-out-when-using-jwt-a8c7823e8a6

```http
401 Unauthorized
WWW-Authenticate: Basic realm="<認証領域>", charaset="UTF-8"
```

#### ・正常系／異常系レスポンス

参考：https://qiita.com/h_tyokinuhata/items/ab8e0337085997be04b1

成功の場合は、realm属性を空にしたレスポンスを返信する。

```http
200 OK
WWW-Authenticate: Bearer realm=""
```

失敗の場合は、error属性にエラメッセージを割り当てたレスポンスを返信する。

```http
400 Bad Request
WWW-Authenticate: Bearer error="invalid_request"
```

```http
401 Unauthorized
WWW-Authenticate: Bearer realm="token_required"
```

```http
403 Forbidden
WWW-Authenticate: Bearer error="insufficient_scope"
```

#### ・```Authorization```ヘッダーのトークンのクライアント保持

不便ではあるが、```Authorization```ヘッダーは```Cookie```ヘッダーとは異なり、ローカルPCに保存できない。その代わり、ブラウザの設定によって、ブラウザのWebStorageでも保持できる。Chromeでは、LocalStorage／SessionStorageに保持される。LocalStorageはSessionStorageと比べて保存期間が長いため、XSSの危険性がより高い。これらの確認方法については、以下のリンク先を参考にせよ

参考：

- https://developer.chrome.com/docs/devtools/storage/localstorage/
- https://developer.chrome.com/docs/devtools/storage/sessionstorage/
- https://stackoverflow.com/questions/5523140/html5-local-storage-vs-session-storage

<br>

### OAuth認証

#### ・OAuth認証とは

OAuthの項目を参考にせよ。

<br>

## 01-02. HTTP認証以外の認証方法

### Form認証（Cookieベースの認証）

#### ・Form認証とは

認証時に```Cookie```ヘッダーの値を用いる方法のこと。『`Cookieベースの認証』ともいう。Stateful化を行うため、HTTP認証には属していない。認証情報の一時的な保存は、サーバのセッションファイルで行うため、認証解除（ログアウト）をサーバ側で制御できる。```Cookie```ヘッダーによる送受信では、CSRFの危険性がある。

参考：

- https://h50146.www5.hpe.com/products/software/security/icewall/iwsoftware/report/certification.html
- https://auth0.com/docs/sessions/cookies#cookie-based-authentication

#### ・セッションIDを用いたForm認証の場合（セッションベース）

セッションIDを```Cookie```ヘッダーに割り当て、リクエストを送信する。

最初、ユーザ作成の段階で、クライアントが認証情報をサーバに送信する。サーバは、認証情報をデータベースに保存する。

```http
POST https://example.co.jp/users HTTP/2

{
    "email_address": "foo@gmail.com",
    "password": "foo"
}
```

次回の認証時に、再びユーザが認証情報を送信する。

```http
POST https://example.co.jp/foo-form HTTP/2

{
    "email_address": "foo@gmail.com",
    "password": "foo"
}
```

サーバは、データベースの認証情報を照合し、ログインを許可する。サーバは、セッションIDを生成し、セッションファイルに書き込む。

```bash
# セッションファイル
{ sessionid: ***** }
```

レスポンスの```Set-Cookie```ヘッダーを用いて、セッションIDをクライアントに送信する。

```http
200 OK
Set-Cookie: sessionid=<セッションID>
```

サーバは、セッションIDとユーザIDを紐付けてサーバ内に保存する。さらに次回のログイン時、クライアントは、リクエストの```Cookie```ヘッダーを用いて、セッションIDをクライアントに送信する。サーバは、保存されたセッションIDに紐付くユーザIDから、ユーザを特定し、ログインを許可する。これにより、改めて認証情報を送信せずに、素早くログインできるようになる。

```http
POST https://example.co.jp/foo-form HTTP/2
cookie: sessionid=<セッションID>
```

認証解除時、サーバでセッションファイルを削除する。

参考：https://blog.tokumaru.org/2013/02/purpose-and-implementation-of-the-logout-function.html

#### ・トークンを用いたForm認証の場合（トークンベース）

トークンを```Cookie```ヘッダーに割り当て、リクエストを送信する。この時のトークンの選択肢として、単なるランダムな文字列やJWTがある。

参考：https://scrapbox.io/fendo181/JWT(JSON_Web_Token)%E3%82%92%E7%90%86%E8%A7%A3%E3%81%99%E3%82%8B%E3%80%82

![JWT](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/JWT.png)

#### ・```Cookie```ヘッダーの値のクライアント保持

再利用のため、```Cookie```ヘッダーに割り当てるための値（セッションID、トークン）は、ブラウザを通して、ローカルPCに有効期限に応じた間だけ保持できる。またはブラウザの設定によって、ブラウザのWebストレージでも保持できる。Chromeの場合は、Cookieストレージに保持される。確認方法については、以下のリンク先を参考にせよ。

参考：

- https://developer.chrome.com/docs/devtools/storage/cookies/
- https://qiita.com/cobachan/items/05fa537a4ffcb189d001

<br>

### APIキー認証

#### ・APIキー認証とは

事前にAPIキーとなる文字列を配布し、認証フェースは行わずに認可フェーズのみでユーザを照合する方法のこと。API GatewayにおけるAPIキー認証については、以下を参考にせよ。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/cloud_computing/cloud_computing_aws.html

#### ・照合情報の送信方法

独自ヘッダーとして、```x-api-key```ヘッダーを定義する。これにAPIキーを割り当て、リクエストを送信する。リクエストヘッダへのパラメータの割り当てについては、以下を参考にせよ。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/software/software_application_collaboration_api_restful.html

```http
GET https://example.co.jp/bar.php HTTP/2
x-api-key: <APIキー>
```

<br>

### Personal Access Tokenによる認証：PAT

#### ・PATによる認証

クライアントがPersonal Access Token（個人用アクセストークン）の付与をリクエストし、認証フェースは行わずに認可フェーズのみでユーザを照合する方法のこと。```Authorization```ヘッダーにPATを割りあてて、リクエストを送信する。作成時以降、アクセストークンを確認できなくなるため、クライアントがアクセストークンを管理する必要がある。

参考：https://www.contentful.com/help/personal-access-tokens/

```http
GET https://example.co.jp/bar.php HTTP/2
authorization: <Personal Acccess Token>
```

| サービス例 | トークン名            | 説明                                                         |
| ---------- | --------------------- | ------------------------------------------------------------ |
| GitHub     | Personal access Token | HTTPSを用いて、プライベートリポジトリにリクエストを送信するために必要。HTTPSを用いる場面として、アプリの拡張機能のGitHub連携、リポジトリのライブラリ化、などがある。<br>参考：https://docs.github.com/ja/github/authenticating-to-github/creating-a-personal-access-token |

<br>

## 01-03. 複数の認証の組み合わせ

### Two Step Verification（二段階認証）

#### ・Two Step Verificationとは

認証時に段階的に二つの方法を設定し、クライアントを照合する方法のこと。

| 一段階目の認証例 | 二段階目の認証例 | 説明                                                         | 備考                                         |
| ---------------- | ---------------- | ------------------------------------------------------------ | -------------------------------------------- |
| IDとパスワード   | IDとパスワード   | IDとパスワードによる方法の後、別のIDとパスワードによる方法を設定する。 |                                              |
|                  | 秘密の質問       | IDとパスワードによる方法の後、質問に対してあらかじめ設定した回答による方法を設定する。 |                                              |
|                  | SMS              | IDとパスワードによる方法の後、SMS宛に送信した認証コードによる方法を設定する。 | 異なる要素のため、これは二要素認証でもある。 |
|                  | 指紋             | IDとパスワードによる方法の後、指紋の解析結果による方法を設定する。 | 異なる要素のため、これは二要素認証でもある。 |

<br>

### Two Factor Authorization（二要素認証）

#### ・Two Factor Authorizationとは

二段階認証のうちで特に、認証時に異なる要素の方法を用いて、段階的にクライアントを照合すること方法のこと。後述するOAuth認証を組み込んでも良い。

| 一要素目の認証例       | 二要素目の認証例                                             |
| ---------------------- | ------------------------------------------------------------ |
| IDとパスワード（知識） | 事前登録された電話番号のSMSで受信したワンタイムパスワード（所持） |
|                        | 事前登録された電話番号のSMSで受信した認証コード（所持）      |
|                        | OAuth認証（所持）                                            |
|                        | 指紋（生体）                                                 |
| 暗証番号（知識）       | キャッシュカード（所持）                                     |

<br>

## 02. 認可フェーズ

### 認証フェーズと認可フェーズ

#### ・処理の違い

![アクセストークンを用いたセキュリティ仕組み](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/アクセストークンを用いたセキュリティの仕組み.jpg)

認証フェーズと認可フェーズでは、仕組みの中に、３つの役割が定義されている。

1. クライアントが、HTTPリクエストにIDとパスワードを設定してリクエスト。
2. IdP：Identity Providerが、IDを『認証』し、クライアント側にアクセストークンを発行。
3. クライアントが、HTTPリクエストのヘッダーにアクセストークンを設定してリクエスト。
4. アクセストークンが『認可』されれば、API側がデータをレスポンスする。

| 役割              | 説明                                                         | 例                                    |
| ----------------- | ------------------------------------------------------------ | ----------------------------------------- |
| APIクライアント   | APIに対して、リクエストを送信したいサーバのこと。            | Ouath認証の仕組みにおけるクライアント。   |
| Identity Provider | トークンを生成するサーバのこと。                             | Ouath認証の仕組みにおける認可サーバ。     |
| APIサーバ         | クライアントに対して、リソースのレスポンスを送信するサーバのこと。 | Ouath認証の仕組みにおけるリソースサーバ。 |

#### ・ステータスコードの違い

認証フェーズにて、誤ったトークンが発行されたことを表現したい場合、401ステータスを用いる。認可フェーズにて、正しいトークンが発行されたが、トークンの所有者に閲覧権限がないことを表現したい場合、403ステータスを用いる。ステータスコードについては、以下のリンク先を参考にせよ。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/software/software_application_collaboration_api_restful.html

<br>

### OAuthプロトコル、OAuth認証

#### ・OAuthプロトコル、OAuth認証とは

認証認可フェーズ全体の中で、認可フェーズにOAuthプロトコルを用いたクライアントの照合方法を『OAuth認証』と呼ぶ。認証フェーズと認可フェーズでは、３つの役割が定義されていることを説明したが、OAuthプロトコル```2.0```では、より具体的に４つの役割が定義されている。

| 役割              | 名称               | 説明                                                         | 補足                                                         |
| ----------------- | ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| APIクライアント   | クライアントアプリ | リソースオーナに対するアクション機能を持つサーバのこと。     | OAuthの文脈では、ブラウザがクライアントと呼ばれないことに注意する。また、クライアントアプリとリソース間のデータ通信は、ブラウザを介したリダイレクトによって実現することに注意する。 |
|                   | リソースオーナー   | クライアントを用いているユーザのこと。                     |                                                              |
| Identity Provider | 認可サーバ         | リソースサーバがリソースオーナーにアクセスできるトークンを生成するサーバのこと。 | 認可サーバがリダイレクト先のクライアントアプリのURLをレスポンスに割り当てられるように、クライアントアプリの開発者がURLを事前登録しておく必要がある。認可サーバを利用する開発者用に、コンソール画面が用意されていることが多い。<br>参考：https://qiita.com/TakahikoKawasaki/items/8567c80528da43c7e844 |
| APIサーバ         | リソースサーバ     | クライアントのアカウント情報を持っているサーバのこと。       |                                                              |

![Oauthの具体例](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Oauthの具体例.png)

1. ユーザは、Facebookアカウントを用いてInstagramにログインしようとし、ブラウザはFacebookにリクエストを送信する。FacebookはInstagramにアカウント連携の承認ボタンをレスポンスとして返信する。
2. ユーザが表示された承認ボタンを押し、ブラウザはFacebookにリクエストを送信する。
3. アクセストークンを発行してもらうため、ブラウザはInstagram認可サーバにリクエストを送信する。Instagramは、アクセストークンを発行する。また、Facebookにリダイレクトできるように、```Location```ヘッダーにURLと認可レスポンスパラメータを割り当て、ブラウザにレスポンスを返信する。ブラウザはFacebookにリクエストを再送信し、Facebookは認可レスポンスパラメータを受け取る。

```http
302 Found
Location: https://example.com/foo.php?code=123&state=abc
```

1. Facebookは、アクセストークンを割り当てたリクエストをInstagramのサーバに送信する。
2. Instagramは、アクセストークンを認証し、データへのアクセスを許可する。また、Facebookにリダイレクトできるように、```Location```ヘッダーにURLを割り当て、ブラウザにレスポンスを返信する。ブラウザからFacebookにレスポンスがリダイレクトされる。ブラウザはFacebookにリクエストを再送信する。

参考：

- https://boxil.jp/mag/a3207/
- https://qiita.com/TakahikoKawasaki/items/8567c80528da43c7e844

#### ・用いられる認証スキーム

OAuth認証では、認証スキーマとしてBearer認証が選ばれることが多く、AWSやGitHubは、独自の認証スキームを用いている。なお、認可サーバによって発行されたBearerトークンは、```Authorization```ヘッダー、リクエストボディ、クエリパラメータのいずれかに割り当てて送信できる。

#### ・付与タイプ

OAuth認証のトークンの付与方法には種類がある。

参考：https://oauth.net/2/grant-types/

| 付与タイプ名             | 説明                                                         | 使用例                          |
| ------------------------ | ------------------------------------------------------------ | ------------------------------- |
| Authorization Code Grant | アプリケーションが他のAPIにアクセスする場合に用いる。推奨されている。<br>参考：https://oauth.net/2/grant-types/authorization-code/ | 他のSNSアプリとのアカウント連携 |
| Client Credentials Grant | 推奨されている。<br>参考：https://oauth.net/2/grant-types/client-credentials/ |                                 |
| Device Code              | 推奨されている。<br>参考：https://oauth.net/2/grant-types/device-code/ |                                 |
| Implicit Grant           | 非推奨されている。<br>参考：https://oauth.net/2/grant-types/implicit/ |                                 |
| Password Grant           | ユーザ名とパスワードを元に、トークンを付与する。非推奨されている。<br>参考：<br>・https://oauth.net/2/grant-types/password/<br>・https://developer.okta.com/blog/2018/06/29/what-is-the-oauth2-password-grant#the-oauth-20-password-grant |                                 |

<br>

### OpenID Connect

#### ・OpenID Connectとは

要勉強。

#### ・用いられる認証スキーム

要勉強

<br>

## 03. JWT：JSON Web Token

### JWTとは

『ヘッダー』『ペイロード』『署名』のそれぞれのJSONデータをBase64urlによってエンコードし、ドットでつないだトークン。Bear認証やOauth認証のトークンとして使用できる。ランダムな文字列をこれら認証のトークンとするより、JWTを用いた方がより安全である。

```http
GET https://example.co.jp/bar.php HTTP/2
authorization: Bearer <ヘッダーJSONエンコード値>.<ペイロードJSONエンコード値>.<署名JSONエンコード値>
```

JWTをBearerトークンとして用いるBearer認証については、別項目の説明を参考にせよ。

参考：

- https://meetup-jp.toast.com/3511
- https://dev.classmethod.jp/articles/json-signing-jws-jwt-usecase/

<br>

### JWTの生成

#### ・JWT生成の全体像

JWTは以下のサイトから取得できる。

参考：https://jwt.io/

JWTの生成時に、例えばJavaScriptであれば、以下のような処理が実行されている。

```javascript
// <ヘッダーエンコード値>.<ペイロードエンコード値>.<署名エンコード値>
const token = base64urlEncoding(header) + "." +
      base64urlEncoding(payload) + "." +
      base64urlEncoding(signature)
```

#### ・ヘッダーのJSONデータの生成

ヘッダーは以下のJSONデータで定義される。署名のための暗号化アルゴリズムは、『```HS256```』『```RS256```』『```ES256```』『```none```』から選択できる。

```javascript
const header = {
    "typ" : "JWT"    // JWTの使用
    "alg" : "HS256", // 署名のための暗号化アルゴリズム
}
```

#### ・ペイロードのJSONデータの生成

ペイロードは以下のJSONデータで定義される。ペイロードには、実際に送信したいJSONを設定するようにする。必ず設定しなければならない『予約済みクレーム』と、ユーザ側が自由に定義できる『プライベートクレーム』がある。

| 予約済みクレーム名         | 役割                      | 例       |
| -------------------------- | ------------------------- | -------- |
| ```sub```：Subject         | 一意な識別子を設定する。  | ユーザID |
| ```iss```：Issuer          |                           |          |
| ```aud```：Audience        |                           |          |
| ```exp```：Expiration Time | JWTの有効期限を設定する。 |          |
| ```jti```：JWT ID          |                           |          |

```javascript
const payload = {
    "sub": "foo",
    "aud": "foo",
    "iss": "https://example.com",
    "exp": 1452565628,
    "iat": 1452565568
}
```

#### ・署名のJSONデータの生成

例えばJavaScriptであれば、以下のような処理が実行されている。

```javascript
const signature = HMACSHA256(
    base64urlEncoding(header) + "." + base64urlEncoding(payload),
    secret
)
```

<br>

### JWTのクライアント保持

#### ・ 保持方法と安全度の比較

参考：https://qiita.com/Hiro-mi/items/18e00060a0f8654f49d6#%E6%97%A9%E8%A6%8B%E8%A1%A8

| クライアント保持方法 | 組み合わせ             | おすすめ度 | コメント                                                     |
| :------------------- | ---------------------- | :--------- | :----------------------------------------------------------- |
| localStorage         |                        | △〜×       | XSSでJWTが盗まれる可能性がある。                             |
| ```Cookie```ヘッダー | プリフライトリクエスト | △          | Access-Control-Max-Ageの期間内だとCSRFでJWTが盗まれる可能性がある。 |
| ```Cookie```ヘッダー | CSRFトークン           | ◯          |                                                              |
| SameSiteCookie       |                        | ◯          | SPAとAPIが同一オリジンの必要がある。                         |

<br>
