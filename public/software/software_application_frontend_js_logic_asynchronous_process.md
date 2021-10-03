# 非同期処理ロジック

## 01. 非同期処理とは

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/software/software_basic_centos_language_processor.html

<br>

## 02. ネイティブなJavaScript

### Promiseオブジェクト

#### ・Promiseオブジェクトとは

非同期処理を監視し，処理の結果と，その結果のステータスを返却する．

参考：https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Promise

<br>

### async/await宣言を使用しない場合

#### ・```resolve```メソッド，```reject```メソッド

Promiseオブジェクト内では暗黙的に```try-catch```が実行されており，結果のステータスが成功であれば```resolve```メソッドの結果を返却し，反対に失敗であれば```reject```メソッドを返却する．両方を実装すると良しなに実行してくれる．```resolve```メソッドと```resolve```メソッドのコール時に```return```を使用しないと，後続の処理も実行される．一つ目の書き方として，Promiseインスタンスのコールバック関数に渡す方法がある．

```javascript
const asyncFunc = () => {

    return new Promise((resolve, reject) => {

        // ステータスが成功の場合に選択される．
        resolve("SUCCESS"); // Promise { "SUCCESS" }

        // ステータスが失敗の場合に選択される．
        reject("FAILED"); // Promise { "FAILED" }
        
        console.log("test");
    })
}

console.log(asyncFunc()); 
// 後続の処理も実行され，resolveメソッドの結果が返却される．
// test
// Promise { 'SUCCESS' }
```

一方で，```resolve```メソッドと```resolve```メソッドのコール時に```return```を使用すると，後続の処理は実行されない．

```javascript
const asyncFunc = () => {

    return new Promise((resolve, reject) => {

        return resolve("SUCCESS");

        reject("FAILED");
        
        console.log("test");
    })
}

console.log(asyncFunc()); 
// 後続の処理も実行されない．
// Promise { 'SUCCESS' }
```

別の書き方として，Promiseオブジェクトから直接```resolve```メソッドや```reject```メソッドをコールしてもよい．この場合，必ず```return```で返却する必要がある．```return```を使用しないと，何も返却されない．

```javascript
const asyncFunc = () => {

    // ステータスが成功の場合に選択される．
    return Promise.resolve("SUCCESS"); // Promise { "SUCCESS" }
}

const asyncFunc = () => {

    // ステータスが失敗の場合に選択される．
    return Promise.reject("FAILED"); // Promise { "FAILED" }
}

console.log(asyncFunc()); // Promise { 'SUCCESS' }
```

```javascript
const asyncFunc = () => {
    return Promise.resolve("SUCCESS");
}

asyncFunc()
    // 失敗時に返却されたrejectをハンドリング
    .catch((reject) => {
        // rejectメソッドを実行
        reject
    })
    .then((resolve) => {
        // resolveメソッドを実行
        resolve
    })
    
console.log(asyncFunc()); // Promise { 'SUCCESS' }
```

非同期処理内で両方をコールするとエラーになる．

```javascript
const asyncFunc = () => {

    Promise.resolve("SUCCESS");
    Promise.reject("FAILED");
}

console.log(asyncFunc()); // エラーになる
```

```shell
UnhandledPromiseRejectionWarning: FAILED
(Use `node --trace-warnings ...` to show where the warning was created)
UnhandledPromiseRejectionWarning: Unhandled promise rejection. This error originated either by throwing inside of an async function without a catch block, or by rejecting a promise which was not handled with .catch(). To terminate the node process on unhandled promise rejection, use the CLI flag `--unhandled-rejections=strict` (see https://nodejs.org/api/cli.html#cli_unhandled_rejections_mode). (rejection id: 1)
[DEP0018] DeprecationWarning: Unhandled promise rejections are deprecated. In the future, promise rejections that are not handled will terminate the Node.js process with a non-zero exit code.
```

補足として，NodeのHTTPライブラリの関数は，Promiseインスタンスのコールバック関数として使用しないと，正しく挙動しない．

参考：https://stackoverflow.com/questions/38533580/nodejs-how-to-promisify-http-request-reject-got-called-two-times

#### ・```then```メソッド，```catch```メソッド，```finally```メソッド

参考：https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Promise#instance_methods

**＊実装例＊**

```javascript
const resolveFunc = new Promise((resolve, reject) => {
    
    return resolve("resolve!!");
});

resolveFunc.then((value) => {
    
    // resolveFuncがPromiseを返し、resolve!!がresolveされるため
    // thenメソッドが実行されコンソールにresolve!!が表示される
    console.log(value); // resolve!!
});
```

```javascript
const resolveFunc = () => {
    
    // resolveFuncはasync functionではないため、Promiseを返さない
    return "resolve!!";
}

resolveFunc.then((value) => {
    
    // resolveFuncはPromiseを返さないため、エラーが発生して動かない
    // Uncaught TypeError: resolveError(...).then is not a function
    console.log(value);
});
```

```javascript
const rejectFunc = new Promise((resolve, reject) => {
    
    reject(new Error("reject!!"));
});

rejectFunc.catch((err) => {
    
    // rejectFuncがPromiseを返し、reject!!がrejectされるため
    // catchメソッドが実行されコンソールにreject!!が表示される
    console.log(err); // reject!!
});
```

<br>

### async/await宣言を使用する場合

#### ・async宣言

任意の関数を非同期関数化する．Promiseオブジェクトを返却するように定義しなくとも，Promiseオブジェクト返却してくれるため，可読性が高まる．ただし，Promiseオブジェクトを返すようにしても，入れ子にならないように処理してくれる．

参考：https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Statements/async_function

**＊実装例＊**

以下の全ては，同じ処理を定義している．

```javascript
const asyncFunc = async () => {
    
    return "SUCCESS"
}

// 単にreturnとしてもPromiseオブジェクトが返却される．
console.log(asyncFunc()); // Promise { "SUCCESS" }
```

```javascript
const asyncFunc = async () => {
    
    return new Promise((resolve, reject) => {
        return resolve("SUCCESS") // Promise { "SUCCESS" }
    })
}

// Promiseオブジェクトを返却するようにしても，入れ子にはならない．
console.log(asyncFunc()); // Promise { "SUCCESS" }
```

```javascript
const asyncFunc = async () => {
    
    return Promise.resolve("SUCCESS") // Promise { "SUCCESS" }
}

// Promiseオブジェクトを返却するようにしても，入れ子にはならない．
console.log(asyncFunc()); // Promise { "SUCCESS" }
```

また，axiosオブジェクトのようにPromiseオブジェクトを標準で返却するメソッドを使用してもよい．

**＊実装例＊**

非道処理としてGETでリクエストを送信している．

```javascript
// axiosオブジェクトのメソッドはPromiseオブジェクトを返却する．
const asyncFunc = async () => {
    
    axios.get("/some/path").then((res) => {
        console.log(res.data); // "some data"
    });
}
```

#### ・await宣言

以降の全処理を```then```メソッドに渡す．Promiseオブジェクトの```then```メソッドに相当するが，```then```メソッドのようにメソッドチェーンする必要はなくなるため，可読性が高い．時間のかかる非同期処理でこれを宣言すると，予期せず処理が流れてしまうことを防げる．

**＊実装例＊**

```javascript
// Promiseオブジェクトのthenメソッドを使用した場合
const asyncFunc = async () => {

    axios.get("/some/path").then((res) => {
        console.log(res.data); // "some data"
    });
}

// awaitを使用した場合
const asyncFunc = async () => {

    // 以降の全処理がthenメソッドに渡される．
    const res = await axios.get("/some/path");

    console.log(res.data); // "some data"
}

```

await宣言により，コールバック地獄のソースコードが分かりやすくなる．

```js
// Promiseオブジェクトのthenメソッドを使用した場合
const asyncFunc = async () => {

    // コールバック関数地獄になっている．
    axios.get("/some/path1").then((res) => {
        const res1 = res;
        axios.get("/some/path1").then((res) => {
            const res2 = res;
            console.log(res1.data + res2.data); // "some data"
        });
    })
}

// awaitを使用した場合
const asyncFunc = async () => {

    const res1 = await axios.get("/some/path1");

    const res2 = await axios.get("/some/path2");

    console.log(res1.data + res2.data); // "some data"
}
```

#### ・エラーハンドリング

Promiseオブジェクトの```then```メソッド，```catch```メソッド，```finally```メソッドを使用してエラーハンドリングを実装できるが，```try-catch```構文とawait宣言を組み合わせて，より可読性高く実装できる．

参考：https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Promise#instance_methods

**＊実装例＊**

```javascript
const asyncFunc = async () => {

    return axios.get("/some/path1")
        .catch((error) => {
            console.error(error);
        })
        .then((data) => {
            console.info(data);
        });
}
```

```javascript
const asyncFunc = async () => {
    
    // 初期化
    let response;
    
    try {
        
        response = await axios.get("/some/path1")
        console.info(response);
        
    } catch (error) {
        
        console.error(error);
        
    }
    
    return response;
}
```

#### ・スリープ

指定した秒数だけ処理を待機する．

```javascript
// 5秒待機する．
await new Promise((resolve) => {
    setTimeout(resolve, 5000)
});
```

<br>

## 03. JavaScriptライブラリ

### JQuery

#### ・```done```メソッド，```fail```メソッド，```always```メソッド

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

#### ・```then```メソッド

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
