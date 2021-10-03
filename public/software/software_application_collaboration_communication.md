# アプリケーション間通信

## 01. 同期通信

<br>

## 02. 非同期通信

<br>

## 03. JavaScriptにおける非同期通信

### Ajax：Asynchronous JavaScript + XML

#### ・Ajaxとは

JavaScriptで非同期通信を実現する手法のこと．JavaScript，HTML，XHTML，CSS，DOM，XML，XSLT，を組み合わせて，

#### ・Ajaxの仕組み

![AJAXの処理フロー](https://user-images.githubusercontent.com/42175286/58467340-6741cb80-8176-11e9-9692-26e6401f1de9.png)

1. urlにアクセスすることにより，サーバからデータがレスポンスされる．
2. DOMのマークアップ言語の解析により，Webページが構成される．
3. ページ上で任意のイベント（ページング操作，フォーム入力など）が発火し，紐づくハンドラ関数が実行される．
4. JavaScript型オブジェクトがJSONに変換される．
5. 非同期通信により，バックエンドにリクエストを送信する．
6. コントローラは，JSON型データを受信し，またそれを元にDBからオブジェクトをReadする．
7. コントローラは，PHP型オブジェクトをJSONに変換し，レスポンスを返信する．
8. 非同期通信メソッドがバックエンドからレスポンスを受信する．
9. JSONがJavaScript型オブジェクトに変換される．
10. オブジェクトがマークアップ言語に出力される．
11. DOMを用いて，Webページを再び構成する．

<br>

### Ajaxの実装方法

#### ・実装方法の種類

歴史的に，Ajaxを実装するための方法がいくつかある．

| 種類                 | 提供                   | 説明                                                         | 補足                                                         |
| -------------------- | ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| XMLHttpRequestクラス | ビルトインオブジェクト | 今では使うことは少ないが，Ajaxが登場した初期の頃によく使われた． | 参考：https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest |
| ```fetch```メソッド  | ビルトイン関数         |                                                              | 参考：https://developer.mozilla.org/ja/docs/Web/API/Fetch_API/Using_Fetch |
| JQueryオブジェクト   | JQueryパッケージ       | ```get```メソッド，```post```メソッド，```ajax```メソッドを使用する． | 参考：<br/>・https://api.jquery.com/category/ajax/shorthand-methods/<br/>・https://api.jquery.com/jquery.ajax |
| axiosオブジェクト    | Axiosパッケージ        |                                                              | 参考：https://github.com/axios/axios#request-method-aliases  |

#### ・追加オプション

コールバック関数地獄など，非同期処理の実装時に起こる問題点を解決するための方法がある．

| 種類                 | 提供                   | 説明                                                         | 補足                                                         |
| -------------------- | ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Promiseオブジェクト  | ビルトインオブジェクト | JQueryのPromiseオブジェクトを参考にして，ES2015から新しく使用できるようになった． | 参考：https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Promise |
| async/awaitを宣言    | ビルトインオブジェクト | ES2017から新しく使用できるようになった．ビルトインオブジェクトのPromiseオブジェクトをより使用しやすくしたもの． | 参考：https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Statements/async_function |
| Deferredオブジェクト | JQueryパッケージ       |                                                              | 参考：https://api.jquery.com/category/deferred-object/       |

<br>

## 03-02. 実装

### JQueryオブジェクトの場合

#### ・```get```メソッド，```post```メソッド

```javascript
const url = "https://www.google.co.jp/";

$.get(url);
```

```javascript
const url = "https://www.google.co.jp/";

const params = {
    name: "Hiroki",
};

$.post(url, params);
```

#### ・```ajax```メソッド

Ajaxを実現する．HTTPメソッド，URL，ヘッダー，メッセージボディなどを設定し，非同期的にデータを送受信する．Promiseオブジェクトを返却する．

参考：https://api.jquery.com/jquery.ajax

**＊実装例＊**

```javascript
const id = 1;

$.ajax({

    // ###################
    //  リクエストメッセージ
    // ###################

    // HTTPメソッドを指定
    type: "POST",

    // ルートとパスパラメータを指定
    url: "/xxx/xxx/" + id + "/",

    // 送信するデータの形式を指定
    contentType: "application/json",

    // メッセージボディ
    data: {
        param1: "AAA",
        param2: "BBB"
    },

    // ###################
    //  レスポンスメッセージ
    // ###################

    // 受信するメッセージボディのデータ型を指定
    dataType: "json",
})
```

<br>

### Axiosオブジェクトの場合

#### ・axiosオブジェクトとは

Ajaxを実現する．HTTPメソッド，URL，ヘッダー，メッセージボディなどを設定し，非同期的にデータを送受信する．Promiseオブジェクトを返却する．

参考：https://github.com/axios/axios#axios

<br>
