# Authenticate（認証）とAuthorization（認可）

## 01. HTTP認証

### HTTP認証とは

ログイン時にHTTP通信の中で認証を行うこと．リクエストヘッダーとレスポンスヘッダーにおいて，認証方法としての認証スキームを選べる．認証スキームの種類には，『Basic認証』，『Digest認証』，『Bearer認証』などがある．

参考：

- https://www.iana.org/assignments/http-authschemes/http-authschemes.xhtml
- https://developer.mozilla.org/ja/docs/Web/HTTP/Authentication#authentication_schemes

<br>

### Basic認証

#### ・Basic認証の仕組み

![Basic認証](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Basic認証.png)


| 役割         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| クライアント | リクエスト送信元のアプリケーションのこと．文脈によっては，ブラウザがクライアントである場合とそうでない場合（例：OAuth認証）がある． |
| ユーザ       | クライアントを使用している人物のこと．                       |
| サーバ       | クライアントからリクエストを受信し，レスポンスを送信するアプリケーションのこと． |

1. 最初，クライアントは，認証後にアクセスできるページのリクエストをサーバに送信する．
2. サーバは，これ拒否し，```401```ステータスで認証領域を設定し，レスポンスを送信する．これにより，認証領域の値をユーザに示して，ユーザ名とパスワードの入力を求めることができる．ユーザに表示するための認証領域には，任意の値を持たせることができ，サイト名が設定されることが多い．

```http
401 Unauthorized
WWW-Authenticate: Basic realm="<認証領域>", charaset="UTF-8"
```

3. 『```<ユーザ名>:<パスワード>```』をBase64でエンコードした値を```authorization```ヘッダーに割り当て，リクエストを送信する．

```http
POST http://example.co.jp/foo-form.php HTTP/2
authorization: Basic bG9naW46cGFzc3dvcmQ=
```

4. サーバは，ユーザ名とパスワードを照合し，合致していれば，認証後ページのレスポンスを送信する．

```http
200 OK
WWW-Authenticate: Basic realm=""
```

<br>


### Digest認証

#### ・Digest認証の仕組み

```http
200 OK
WWW-Authenticate: Basic realm="<認証領域>", charaset="UTF-8"
```

```http
POST http://example.co.jp/foo-form.php HTTP/2
authorization: Digest realm="<認証領域>" nonce="<サーバ側が生成した任意の文字列>" algorithm="<ハッシュ関数名>" qoq="auth"
```

<br>

### Bearer認証

#### ・Bearer認証とは

ログイン時にBearerトークンを使用する認証スキームのこと．使用できるアクセストークンの種類については，別項目の説明を参照せよ．

#### ・アクセストークンのクライアント保持

最初の認証後，アクセストークンはクライアントで保持される．Chromeの場合は，LocalStorage／SessionStorageに保持される．確認方法については，以下のリンクを参考にせよ．

参考：

- https://developer.chrome.com/docs/devtools/storage/localstorage/
- https://developer.chrome.com/docs/devtools/storage/sessionstorage/

#### ・Bearer認証の仕組み

1. 最初，クライアントは，認証後にアクセスできるページのリクエストをサーバに送信する．
2. サーバは，これ拒否し，```401```ステータスで認証領域を設定し，レスポンスを送信する．これにより，認証領域の値をユーザに示して，アクセストークンを求めることができる．ユーザに表示するための認証領域には，任意の値を持たせることができ，サイト名が設定されることが多い．

```http
401 Unauthorized
WWW-Authenticate: Bearer realm="<認証領域>", charaset="UTF-8"
```

3. 発行されたトークンを```Authorization```ヘッダーに割り当てて，リクエストを送信する．

```http
POST http://example.co.jp/foo-form.php HTTP/2
authorization: Bearer <Bearerトークン，JWT，など>
```

4. サーバは，アクセストークンを照合し，合致していれば，認証後ページのレスポンスを送信する．

```http
200 OK
WWW-Authenticate: Bearer realm=""
```

#### ・正常系／異常系レスポンス

参考：https://qiita.com/h_tyokinuhata/items/ab8e0337085997be04b1

成功の場合は，realm属性を空にしたレスポンスを返信する．

```http
200 OK
WWW-Authenticate: Bearer realm=""
```

失敗の場合は，error属性にエラメッセージを割り当てたレスポンスを返信する．

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

<br>

### OAuth認証

#### ・OAuth認証とは

OAuthの項目を参考にせよ．

<br>

## 01-02. HTTP認証以外の認証方法

### Form認証（Cookieベースの認証）

#### ・Form認証とは

ログイン時にセッションIDを使用する認証方法のこと．認証スキームには属していない．```Cookie```ヘッダーを使用した認証のため，『`Cookieベースの認証』ともいう．

参考：

- https://h50146.www5.hpe.com/products/software/security/icewall/iwsoftware/report/certification.html
- https://auth0.com/docs/sessions/cookies#cookie-based-authentication

認証方法以外のセッションの仕様については，以下のノートを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_api_restful.html

#### ・セッションIDのクライアント保持

最初の認証後，セッションIDはクライアントで保持される．Chromeの場合は，Cookieストレージに保持される．確認方法については，以下のリンクを参考にせよ．

参考：https://developer.chrome.com/docs/devtools/storage/cookies/

#### ・Form認証の仕組み

1. 最初，ユーザ作成の段階で，クライアントがログイン情報をサーバに送信する．
2. サーバは，ログイン情報をデータベースに保存する．
3. 次回のログイン時に，再びユーザがログイン情報を送信する．
4. サーバは，データベースのログイン情報を照合し，ログインを許可する．
5. サーバは，セッションIDを生成する．また，レスポンスの```Set-Cookie```ヘッダーを使用して，セッションIDをクライアントに送信する．

```http
200 OK
# レスポンスヘッダーの場合
Set-Cookie: sessionId=<セッションID>
```

6. サーバは，セッションIDとユーザIDを紐づけてサーバ内に保存する．
7. さらに次回のログイン時，クライアントは，リクエストの```Cookie```ヘッダーを使用して，セッションIDをクライアントに送信する．サーバは，保存されたセッションIDに紐づくユーザIDから，ユーザを特定し，ログインを許可する．これにより，改めてログイン情報を送信せずに，素早くログインできるようになる．

```http
POST http://example.co.jp/foo-form.php HTTP/2
# リクエストヘッダーの場合
cookie: PHPSESSID=<セッションID>
```

<br>

### APIキー認証

#### ・APIキー認証とは

事前にAPIキーとなる文字列を配布し，認証フェースは行わずに認可フェーズのみでユーザを照合する方法のこと．API GatewayにおけるAPIキー認証については，以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws.html

#### ・照合情報の送信方法

独自ヘッダーとして，```x-api-key```ヘッダーを定義する．これにAPIキーを割り当て，リクエストを送信する．リクエストヘッダへのパラメータの割り当てについては，以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_api_restful.html

```http
GET http://example.co.jp/bar.php HTTP/2
# リクエストヘッダー
x-api-key: <APIキー>
```

<br>

### Personal Access Tokenによる認証：PAT

#### ・PATによる認証

クライアントがPersonal Access Token（個人用アクセストークン）の付与をリクエストし，認証フェースは行わずに認可フェーズのみでユーザを照合する方法のこと．```Authorization```ヘッダーにPATを割りあてて，リクエストを送信する．作成時以降，アクセストークンを確認できなくなるため，クライアントがアクセストークンを管理する必要がある．

参考：https://www.contentful.com/help/personal-access-tokens/

```http
GET http://example.co.jp/bar.php HTTP/2
# リクエストヘッダー
authorization: <Personal Acccess Token>
```

| サービス例 | トークン名            | 説明                                                         |
| ---------- | --------------------- | ------------------------------------------------------------ |
| GitHub     | Personal access Token | HTTPSを使用して，プライベートリポジトリにリクエストを送信するために必要．HTTPSを使用する場面として，アプリの拡張機能のGitHub連携，リポジトリのライブラリ化，などがある．<br>参考：https://docs.github.com/ja/github/authenticating-to-github/creating-a-personal-access-token |

<br>

## 01-03. 複数の認証の組み合わせ

### Two Step Verification（二段階認証）

#### ・Two Step Verificationとは

ログイン時に段階的に二つの認証方法を設定し，クライアントを照合する方法のこと．

| 一段階目の認証例 | 二段階目の認証例 | 説明                                                         | 備考                                         |
| ---------------- | ---------------- | ------------------------------------------------------------ | -------------------------------------------- |
| IDとパスワード   | IDとパスワード   | IDとパスワードによる認証方法の後，別のIDとパスワードによる認証方法を設定する． |                                              |
|                  | 秘密の質問       | IDとパスワードによる認証方法の後，質問に対してあらかじめ設定した回答による認証方法を設定する． |                                              |
|                  | SMS              | IDとパスワードによる認証方法の後，SMS宛に送信した認証コードによる認証方法を設定する． | 異なる要素のため，これは二要素認証でもある． |
|                  | 指紋             | IDとパスワードによる認証方法の後，指紋の解析結果による認証方法を設定する． | 異なる要素のため，これは二要素認証でもある． |

<br>

### Two Factor Authorization（二要素認証）

#### ・Two Factor Authorizationとは

二段階認証のうちで特に，ログイン時に異なる要素の認証方法を使用して，段階的にクライアントを照合すること方法のこと．後述するOAuth認証を組み込んでも良い．

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

認証フェーズと認可フェーズでは，仕組みの中に，３つの役割が定義されている．

1. クライアントが，HTTPリクエストにIDとパスワードを設定してリクエスト．
2. IdP：Identity Providerが，IDを『認証』し，クライアント側にアクセストークンを発行．
3. クライアントが，HTTPリクエストのヘッダーにアクセストークンを設定してリクエスト．
4. アクセストークンが『認可』されれば，API側がデータをレスポンスする．

| 役割              | 説明                                                         | 具体例                                    |
| ----------------- | ------------------------------------------------------------ | ----------------------------------------- |
| APIクライアント   | APIに対して，リクエストを送信したいサーバのこと．            | Ouath認証の仕組みにおけるクライアント．   |
| Identity Provider | トークンを生成するサーバのこと．                             | Ouath認証の仕組みにおける認可サーバ．     |
| APIサーバ         | クライアントに対して，リソースのレスポンスを送信するサーバのこと． | Ouath認証の仕組みにおけるリソースサーバ． |

#### ・ステータスコードの違い

認証フェーズにて，誤ったトークンが発行されたことを表現したい場合，401ステータスを使用する．認可フェーズにて，正しいトークンが発行されたが，トークンの所有者に閲覧権限がないことを表現したい場合，403ステータスを使用する．ステータスコードについては，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_api_restful.html

<br>

### OAuthプロトコル，OAuth認証

#### ・OAuthプロトコル，OAuth認証とは

認証認可フェーズ全体の中で，認可フェーズにOAuthプロトコルを用いたクライアントの照合方法を『OAuth認証』と呼ぶ．認証フェーズと認可フェーズでは，３つの役割が定義されていることを説明したが，OAuthプロトコル```2.0```では，より具体的に４つの役割が定義されている．

| 役割              | 名称               | 説明                                                         | 補足                                                         |
| ----------------- | ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| APIクライアント   | クライアントアプリ | リソースオーナに対するアクション機能を持つサーバのこと．     | OAuthの文脈では，ブラウザがクライアントと呼ばれないことに注意する．また，クライアントアプリとリソース間のデータ通信は，ブラウザを介したリダイレクトによって実現することに注意する． |
|                   | リソースオーナー   | クライアントを使用しているユーザのこと．                     |                                                              |
| Identity Provider | 認可サーバ         | リソースサーバがリソースオーナーにアクセスできるトークンを生成するサーバのこと． | 認可サーバがリダイレクト先のクライアントアプリのURLをレスポンスに割り当てられるように，クライアントアプリの開発者がURLを事前登録しておく必要がある．認可サーバを利用する開発者用に，コンソール画面が用意されていることが多い．<br>参考：https://qiita.com/TakahikoKawasaki/items/8567c80528da43c7e844 |
| APIサーバ         | リソースサーバ     | クライアントのアカウント情報を持っているサーバのこと．       |                                                              |

![Oauthの具体例](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Oauthの具体例.png)

1. ユーザは，Facebookアカウントを使用してInstagramにログインしようとし，ブラウザはFacebookにリクエストを送信する．FacebookはInstagramにアカウント連携の承認ボタンをレスポンスとして返信する．
2. ユーザが表示された承認ボタンを押し，ブラウザはFacebookにリクエストを送信する．
3. アクセストークンを発行してもらうため，ブラウザはInstagram認可サーバにリクエストを送信する．Instagramは，アクセストークンを発行する．また，Facebookにリダイレクトできるように，```Location```ヘッダーにURLと認可レスポンスパラメータを割り当て，ブラウザにレスポンスを返信する．ブラウザはFacebookにリクエストを再送信し，Facebookは認可レスポンスパラメータを受け取る．

```http
302 Found
Location: https://example.com/foo.php?code=123&state=abc
```

1. Facebookは，アクセストークンを割り当てたリクエストをInstagramのサーバに送信する．
2. Instagramは，アクセストークンを認証し，データへのアクセスを許可する．また，Facebookにリダイレクトできるように，```Location```ヘッダーにURLを割り当て，ブラウザにレスポンスを返信する．ブラウザからFacebookにレスポンスがリダイレクトされる．ブラウザはFacebookにリクエストを再送信する．

参考：

- https://boxil.jp/mag/a3207/
- https://qiita.com/TakahikoKawasaki/items/8567c80528da43c7e844

#### ・使用される認証スキーム

OAuth認証では，認証スキーマとしてBearer認証が選ばれることが多く，認可サーバが発行するアクセストークンとしては，BearerトークンやJWTが用いられる．AWSやGitHubは，独自の認証スキームを使用している．なお，認可サーバによって発行されたBearerトークンは，```Authorization```ヘッダー，リクエストボディ，クエリパラメータのいずれかに割り当てて送信できる．

#### ・付与タイプ

OAuth認証のトークンの付与方法には種類がある．

参考：https://oauth.net/2/grant-types/

| 付与タイプ名             | 説明                                                         | 使用例                          |
| ------------------------ | ------------------------------------------------------------ | ------------------------------- |
| Authorization Code Grant | アプリケーションが他のAPIにアクセスする場合に使用する．推奨されている．<br>参考：https://oauth.net/2/grant-types/authorization-code/ | 他のSNSアプリとのアカウント連携 |
| Client Credentials Grant | 推奨されている．<br/>参考：https://oauth.net/2/grant-types/client-credentials/ |                                 |
| Device Code              | 推奨されている．<br/>参考：https://oauth.net/2/grant-types/device-code/ |                                 |
| Implicit Grant           | 非推奨されている．<br/>参考：https://oauth.net/2/grant-types/implicit/ |                                 |
| Password Grant           | ユーザ名とパスワードを元に，トークンを付与する．非推奨されている．<br>参考：<br>・https://oauth.net/2/grant-types/password/<br>・https://developer.okta.com/blog/2018/06/29/what-is-the-oauth2-password-grant#the-oauth-20-password-grant |                                 |

<br>

### OpenID Connect

#### ・OpenID Connectとは

要勉強．

#### ・使用される認証スキーム

要勉強

<br>

## 02-02. アクセストークンの種類

### Bearerトークン

#### ・Bearerトークンとは

単なる文字列で定義されたアクセストークン．認証フェーズと認可フェーズにおいて，実際に認証された本人かどうかを判定する機能は無く，トークンを持っていれば，それを本人と見なす．そのため，トークンの文字列が流出してしまわないよう，厳重に管理する必要がある．Bearerトークンを使用するBearer認証については，別項目の説明を参考にせよ．

＼<br>

### JWT：JSON Web Token

#### ・JWTとは

JSON型で実装されたアクセストークン．OAuth認証のアクセストークンとして使用されることもある．JWTトークンを使用するBearer認証については，別項目の説明を参考にせよ．

#### ・JWTの構造

**＊実装例＊**

JWTは，エンコードされたヘッダー，ペイロード，署名，から構成される．

```javascript
const token = base64urlEncoding(header) + "." +
      base64urlEncoding(payload) + "." +
      base64urlEncoding(signature)
```

ここで，ヘッダーは以下の構造からなる．署名のための暗号化アルゴリズムは，『```HS256```』『```RS256```』『```ES256```』『```none```』から選択できる．

```javascript
const header = {
    "typ" : "JWT"    // JWTの使用
    "alg" : "HS256", // 署名のための暗号化アルゴリズム
}
```

ここで，ペイロードは以下の構造からなる．ペイロードには，実際に送信したいJSONを設定するようにする．必ず設定しなければならない『予約済みクレーム』と，ユーザ側が自由に定義できる『プライベートクレーム』がある．

| 予約済みクレーム名         | 役割                      | 例       |
| -------------------------- | ------------------------- | -------- |
| ```sub```：Subject         | 一意な識別子を設定する．  | ユーザID |
| ```iss```：Issuer          |                           |          |
| ```aud```：Audience        |                           |          |
| ```exp```：Expiration Time | JWTの有効期限を設定する． |          |
| ```jti```：JWT ID          |                           |          |

```javascript
const payload = {
    "sub" : "123456789",
}
```

ここで，署名は以下の構造からなる．

```javascript
const signature = HMACSHA256(
    base64urlEncoding(header) + "." + base64urlEncoding(payload),
    secret
)
```

#### ・JWTを用いた認証フェーズと認可フェーズ

![JWT](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/JWT.png)