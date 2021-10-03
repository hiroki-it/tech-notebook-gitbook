# JSON

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. データ記述言語

### データ記述言語の種類

#### ・JSON：JavaScript Object Notation

一番外側を波括弧で囲う．

```json
{
  "fruit": ["banana", "apple"],
  "account": 200
}
```

#### ・YAML：YAML Ain"t a Markup Language

```yaml
{
  fruit:
    - "banana"
    - "apple"
  account: 200
}  
```

#### ・マークアップ言語

詳しくは以下のノートを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/frontend_browser_rendering.html

#### ・CSV：Comma Separated Vector

データ解析の入力ファイルとしてよく使うやつ．

<br>

## 02-01. JS型オブジェクト，JSON，PHP型オブジェクト

### JS型オブジェクト

#### ・定義方法

キーはクオーテーションで囲う必要が無い．

**＊実装例＊**

```javascript
const object = {
  fruit: ["banana", "apple"],
  account: 200
};
```

```javascript
class Foo {
  constructor(fruit, account) {
    this.fruit = fruit;
    this.account = account;
  }
}
```

<br>

### JSON

#### ・定義方法

キーを，シングルクオーテーションではなく，クオーテーションで囲う必要がある．

**＊実装例＊**

```javascript
const json = {
  "fruit": ["banana", "apple"],
  "account": 200
};
```

#### ・キーと値の変更方法

**＊実装例＊**

```javascript
// どんなデータを含むJSONなのかわかりやすい方法
const json = {
  "name": null,
  "age": null,
  "tel": null
}

json.name = "taro";
json.age = 30;
json.tel = "090-0123-4567";
```

**＊実装例＊**

```javascript
const json = {}

// areaというキーの値を追加
json.prefecture = "Tokyo";

// もしくは，
json["prefecture"] = "Tokyo";

// 以下は．undefined になる．二段階の定義はできない．
//// json.prefecture.area = "Shibuya";
```

**＊実装例＊**

```javascript
const json = {
  "name": "taro",
  "age": 30,
  "tel": "090-0123-4567"
}

// areaというキーの値を追加
json.prefecture = "Tokyo";

// もしくは，
json["prefecture"] = "Tokyo";
```

### PHP型オブジェクト

#### ・定義方法

**＊実装例＊**

```php
<?php
    
class Foo 
{
    private $fruit;
    private $account;
    
    public function __construct($fruit, $account)
    {
        $this->fruit = $fruit;
        $this->account = $account;
    }
}    
```

<br>

## 02-02. 相互パース（シリアライズ＋デシリアライズ）

### シリアライズ，デシリアライズとは

#### ・バックエンドとフロントエンド間

データ送信のためにオブジェクト（JS型，PHP型）をJSONに変換する処理はシリアライズである．一方で，送信のためにJSONをオブジェクト（JS型，PHP型）に変換する処理はデシリアライズである．

![シリアライズとデシリアライズ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/シリアライズとデシリアライズ.png)

#### ・バックエンドとデータベース間

データ送信のためにオブジェクト（PHP型）をJSONに変換する処理はシリアライズである．一方で，送信のためにJSONをオブジェクト（PHP型）に変換する処理はデシリアライズである．

<br>

### フロントエンド

#### ・シリアライズ：JS型からJSON

JS型オブジェクトからJSONへの変換には，```JSON.stringfy```メソッドを使用する．

**＊実装例＊**

```javascript
const object = {
  fruit: ["banana", "apple"],
  account: 200
};

// シリアライズ
const json = JSON.stringify(object);

console.log(json);
// {"fruit":["banana","apple"],"account":200}
```

#### ・デシリアライズ：JSONからJS型

JSONからJS型オブジェクトへの変換には，```JSON.parse```メソッドを使用する．レスポンスされたJSONはエスケープされていることに注意する．

**＊実装例＊**

```javascript
const escapedJson = "{\"fruit\":[\"banana\",\"apple\"],\"account\":200}"

console.log(escapedJson); // {"fruit":["banana","apple"],"account":200}

// デシリアライズ
const object = JSON.parse(escapedJson);

console.log(object);
// { fruit: [ 'banana', 'apple' ], account: 200 }
```

#### ・相互パースメソッドをもつクラス

**＊実装例＊**

以下でシリアライズとデシリアライズを行うクラスを示す．

```javascript
class StaffParser {

  // デシリアライズによるJS型データを自身に設定
  constructor(properties) {
    this.id   = properties.id;
    this.name = properties.name;
  }


  //-- デシリアライズ（JSONからJavaScriptへ） --//
  static deserializeStaff(json) {

    // JS型オブジェクトの定義方法
    return new StaffParser({
      id: json.id,
      name: json.name
    });
  }


  //-- シリアライズ（JavaScriptからJSONへ） --//
  static serializeCriteria(criteria) {

    // JSONの定義
    const json = {
      "id" : null,
      "name" : null
    }

    // ID
    if (criteria.id) {
      // JSONが生成される．
      json.id = _.trim(criteria.id);
    }

    // 氏名
    if (criteria.name) {
      json.name = _.trim(criteria.name);
    }
  }
}     
```

<br>

### バックエンド

#### ・デシリアライズ：JSONからPHP型

JSONからPHP型オブジェクトの変換には．```json_decode```メソッドを使用する．第二引数が```false```の場合，object形式オブジェクトに変換する．リクエストで送信するJSONはエスケープする必要があることに注意する．

```php
<?php

// リクエストで取得したJSON
$escapedJson = '{\"fruit\":[\"banana\",\"apple\"],\"account\":200}';

// object形式オブジェクトに変換
$object = json_decode($escapedJson, false);

var_dump($object);
//  object(stdClass)#1 (2) {
//    ["fruit"]=>
//    array(2) {
//      [0]=>
//      string(9) "banana"
//      [1]=>
//      string(9) "apple"
//    }
//    ["account"]=>
//    int(200)
//  }
```

第二引数が```true```の場合，連想配列形式に変換する．

```php
<?php

// リクエストで取得したJSON
$escapedJson = '{\"fruit\":[\"banana\",\"apple\"],\"account\":200}';

// 連想配列形式オブジェクトに変換
$array = json_decode($escapedJson, true);

var_dump($array);
//  array(2) {
//    ["fruit"]=>
//    array(2) {
//      [0]=>
//      string(9) "banana"
//      [1]=>
//      string(9) "apple"
//    }
//    ["account"]=>
//    int(200)
//  }
```

#### ・シリアライズ：PHP型からJSON

```php
<?php

$object = '{"fruit":["banana","apple"],"account":200}';

// JSONに変換
$json = json_encode($object);

var_dump($json);
// ""{\"fruit\":[\"banana\",\"apple\"],\"account\":200}""
```

<br>

## 03. JSONのクエリ言語

### クエリ言語の種類

#### ・JMESPath

**＊実装例＊**

```javascript
// ここに実装例
```

