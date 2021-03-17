#  フロントエンドアーキテクチャ

## 01. フロントエンドアーキテクチャの種類

### SPA：Single Page Application

#### ・SPAとは

1つのWebページの中で，サーバとデータを非同期通信し，ブラウザ側で部分的に静的ファイルを生成する方法のこと．非同期通信は，Ajaxの手法を用いて実現される．また，静的ファイルの部分的な生成は，MVVMアーキテクチャによって実現する．SPAでは，ページ全体の静的ファイルをリクエストするのは最初のみで，それ以降はページ全体をリクエストすることはない．２回目以降は，ページ部分的にリクエストを行い，サーバ側からJSONを受け取っていく．

参考：https://developers.google.com/analytics/devguides/collection/analyticsjs/single-page-applications?hl=ja

![SPアプリにおけるデータ通信の仕組み](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/SPアプリにおけるデータ通信の仕組み.png)

#### ・MVVMアーキテクチャとは

Vue.jsでは，意識せずにMVVMアーキテクチャで実装できるようになっている．詳しくは，Vue.jsのノートを参考にせよ．

#### ・Ajaxとは：Asynchronous JavaScript + XML

![AJAXの処理フロー](https://user-images.githubusercontent.com/42175286/58467340-6741cb80-8176-11e9-9692-26e6401f1de9.png)

HTML，XHTML，CSS，JavaScript，DOM，XML，XSLT，を組み合わせて非同期通信を実現する手法のこと．これらの技術を以下の順で組み合わせる．

1. urlにアクセスすることにより，サーバからデータがレスポンスされる．
2. DOMのマークアップ言語の解析により，Webページが構成される．
3. ページ上で任意のイベント（ページング操作，フォーム入力など）が発火し，紐づくハンドラ関数が実行される．
4. JavaScript型オブジェクトがJSONに変換される．
5. 非同期通信処理により，バックエンドにリクエストを送信する．
6. コントローラは，JSON型データを受信し，またそれを元にDBからオブジェクトをReadする．
7. コントローラは，PHP型オブジェクトをJSONに変換し，レスポンスを返信する．
8. 非同期通信メソッドがバックエンドからレスポンスを受信する．
9. JSONがJavaScript型オブジェクトに変換される．
10. オブジェクトがマークアップ言語に出力される．
11. DOMを用いて，Webページを再び構成する．

#### ・MPAとSPAの処理速度の違い

ャであるMPAと比較して，データを非同期的に通信できるため，1つのWebページの中で必要なデータだけを通信すればよく，レンダリングが速い．

![従来WebアプリとSPアプリの処理速度の違い](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/従来WebアプリとSPアプリの処理速度の違い.png)

<br>

### SSR：Server Side Rendering

#### ・SSRとは

1つのWebページの中で，サーバとデータを非同期通信し，サーバ側で部分的に静的ファイルを生成する方法のこと．SPAと同様にして，非同期通信は，Ajaxの手法を用いて実現される．また，静的ファイルの部分的な生成は，MVVMアーキテクチャによって実現する．また，ページ全体の静的ファイルをリクエストするのは最初のみで，２回目以降は，サーバ側からJSONを受け取り，部分的にリクエストを行う．

<br>

### SSG：Static Site Generation

#### ・SSGとは

静的ファイルとしてビルドされたWebページをフロントエンドとして使用する方法．動的な要素を含む静的ファイルについては，ビルド時にバックエンドからデータを取得し，これを元にビルドを行うようにする．

<br>

## 02. Ajaxの非同期処理

### 非同期処理の実現方法

#### ・基本実装

歴史的に，非同期処理を実装するための方法がいくつかある．

| 種類                   | 説明                                                         | 補足                                                         |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ビルトインオブジェクト | XMLHttpRequestクラス．今では使うことは少ないが，Ajaxが登場した初期の頃によく使われた． | 参考：https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest |
| ビルトイン関数         | ```fetch```メソッド．                                        | 参考：https://developer.mozilla.org/ja/docs/Web/API/Fetch_API/Using_Fetch |
| JQueryパッケージ       | ```get```メソッド，```post```メソッド，```ajax```メソッドを使用する． | 参考：<br/>・https://api.jquery.com/category/ajax/shorthand-methods/<br/>・https://api.jquery.com/jquery.ajax |
| Axiosパッケージ        | axiosオブジェクトを使用する．                                | 参考：https://github.com/axios/axios#request-method-aliases  |

#### ・応用実装

コールバック関数地獄など，非同期処理の実装時に起こる問題点を解決するための方法がある．

| 種類                   | 説明                                                         | 補足                                                         |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ビルトインオブジェクト | Promiseオブジェクト．JQueryのPromiseオブジェクトを参考にして，ES2015から新しく使用できるようになった． | 参考：https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Promise |
| ビルトインオブジェクト | 任意の関数にてasync/awaitを宣言する．ES2017から新しく使用できるようになった．ビルトインオブジェクトのPromiseオブジェクトをより使用しやすくしたもの． | 参考：https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Statements/async_function |
| JQueryパッケージ       | Deferredオブジェクト．                                       | 参考：https://api.jquery.com/category/deferred-object/       |

<br>

## 02-02. 基本実装

### JQueryパッケージの場合

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

### Axiosパッケージの場合

#### ・axiosオブジェクト

Ajaxを実現する．HTTPメソッド，URL，ヘッダー，メッセージボディなどを設定し，非同期的にデータを送受信する．Promiseオブジェクトを返却する．

参考：https://github.com/axios/axios#axios

<br>

## 02-03. 応用実装

### JQueryパッケージの場合

#### ・```done```メソッド，```fail```メソッド，```always```メソッドとは

Promiseオブジェクトがもつメソッド．```ajax```メソッドによってレスポンスを受信した後，その結果を```done```，```fail```，```always```の三つに分類し，これに応じたコールバック処理を実行する方法．

**＊実装例＊**

JQueryパッケージの```get```メソッドや```post```メソッドを使用した場合．

```javascript
const url = "https://www.google.co.jp/";

$.get(url)
    .done((data) => {
        console.log(data);
    })
    .fail((error) => {
        console.log(error);
    });
```

```javascript
const url = "https://www.google.co.jp/";

const params = {
    name: "Hiroki",
};

$.post(url, params)
    .done((data) => {
        console.log(data);
    })
    .fail((error) => {
        console.log(error);
    });
```

JQueryパッケージの```ajax```メソッドを使用した場合．

```javascript
const id = 1;

$.ajax({
    type: "POST",
    url: "/xxx/xxx/" + id + "/",
    contentType: "application/json",
    data: {
        param1: "AAA",
        param2: "BBB"
    },
})
    // 非同期通信の成功時のコールバック処理
    .done((data) => {
        console.log(data);
    })

    // 非同期通信の失敗時のコールバック処理
    .fail((error) => {
        console.log(data);
        toastr.error("", "エラーが発生しました．");
    })

    // 非同期通信の成功失敗に関わらず常に実行する処理
    .always((data) => {
        this.isLoaded = false;
    });
```

#### ・```then```メソッドとは

Promiseオブジェクトがもつメソッド．```ajax```メソッドによってレスポンスを受信した後，その結果を```then```メソッドの引数の順番で分類し，これに応じたコールバック処理を実行する方法．非同期処理の後に同期処理を行いたい場合に用いる．

**＊実装例＊**

JQueryパッケージの```ajax```メソッドを使用した場合．

```javascript
const id = 1;

$.ajax({
    type: "POST",
    url: "/xxx/xxx/" + id + "/",
    contentType: "application/json",
    data: {
        param1: "AAA",
        param2: "BBB"
    },
})
    // 最初のthen
    .then(
        // 引数1つめは通信成功時のコールバック処理
        (data) => {

        },
        // 引数2つめは通信失敗時のコールバック処理
        (data) => {

        })
    // 次のthen
    .then(
        // 引数1つめは通信成功時のコールバック処理
        (data) => {

        });
```

<br>

### ビルトインオブジェクトの場合

#### ・async宣言

任意の関数を，非同期関数化する．Promiseオブジェクトを返却するようになる．

参考：https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Statements/async_function

**＊実装例＊**

```javascript
// アロー関数記法
const asyncFunc = async () => {
    // 何らかの処理
}

async function asyncFunc() {
    // 何らかの処理
}
```

#### ・await宣言

Promiseオブジェクトの```then```メソッドと同じ機能を持つ．async関数がPromiseオブジェクトを返却した後に実行される．

**＊実装例＊**

```javascript
// awaitを使用した場合
const asyncFunc = async () => {

    const res = await axios.get("/some/path");

    console.log(res.data); // "some data"
}

// Promiseオブジェクトのthenメソッドを使用した場合
const asyncFunc = async () => {

    axios.get("/some/path")
        .then((res) => {
            console.log(res.data); // "some data"
        });
}
```

await宣言により，コールバック地獄のソースコードが分かりやすくなる．

```js
// awaitを使用した場合
const asyncFunc = async () => {

    const res1 = await axios.get("/some/path1");

    const res2 = await axios.get("/some/path2");

    console.log(res1.data + res2.data); // "some data"
}

// Promiseオブジェクトのthenメソッドを使用した場合
const asyncFunc = async () => {

    // コールバック関数地獄になっている．
    axios.get("/some/path1")
        .then((res) => {
            const res1 = res;
            axios.get("/some/path1")
                .then((res) => {
                    const res2 = res;
                    console.log(res1.data + res2.data); // "some data"
                });
        })
}
```

#### ・```then```メソッド，```catch```メソッド

**＊実装例＊**

```javascript
// asyncを使用した場合
const resolveFunc = async () => {
    // returnする時，resolveメソッドが実行される．
    return "resolve!!";
}

// Promiseオブジェクトを使用した場合
const resolveFunc = new Promise((resolve, reject) => {
    resolve("resolve!!");
});

resolveFunc
    .then((value) => {
        // resolveFuncがPromiseを返し、resolve!!がresolveされるため
        // then()が実行されコンソールにresolve!!が表示される
        console.log(value); // resolve!!
    });
```

```javascript
const resolveFunc = () => {
    // resolveFuncはasync functionではないため、Promiseを返さない
    return "resolve!!";
}

resolveFunc
    .then((value) => {
        // resolveFuncはPromiseを返さないため、エラーが発生して動かない
        // Uncaught TypeError: resolveError(...).then is not a function
        console.log(value);
    });
```

```javascript
// asyncを使用した場合
const rejectFunc = async () => {
    // throwする時，rejectメソッドが内部で実行される．
    throw new Error("reject!!");
}

const rejectFunc = new Promise((resolve, reject) => {
    reject(new Error("reject!!"));
});

rejectFunc
    .catch((err) => {
        // rejectFuncがPromiseを返し、reject!!がrejectされるため
        // catch()が実行されコンソールにreject!!が表示される
        console.log(err); // reject!!
    });
```
