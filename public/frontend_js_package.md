# JavaScriptパッケージ

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. npmによるパッケージの管理

### ```package.json```ファイルの実装

#### ・バージョンを定義

```shell
{
  # npmパッケージ名．全てのnpmパッケージの中で，一意の名前でなければならない．
  "name": "foo-package",
  "description": "foo package ever",
  "license": "MIT",
  "version": "1.0.0",
  "bin": "./cli.js",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  # 本番環境と開発環境で依存するパッケージ
  "dependencies": {
    "axios": "^0.18.0"
  },
  # 開発環境のみ依存するパッケージ
  "devDependencies": {
    "eslint": "^5.14.1"
  }
}
```

<br>

### install

#### ・インストール

インストールされていないパッケージをインストールする．

```shell
$ npm install
```

#### ・インストール時の実行権限を無視する

パッケージのインストール時に，ディレクトリの実行権限不足でインストールが停止することがある．これを無視してインストールを行う．

```shell
$ npm install --force
```

#### ・package.jsonの```dependencies```キーに書き込む

デフォルトで有効化されている．パッケージのインストール時に，依存するパッケージとして，```dependencies```キーにパッケージ名とバージョンを書き込む．

```shell
$ npm install --save
```

<br>

### update

#### ・インストール，アップデート

インストールされていないパッケージをインストールする．また，バージョン定義をもとに更新可能なパッケージを更新する．

```shell
$ npm update
```

<br>

### run

ユーザが定義したエイリアス名のコマンドを実行する．

```shell
$ npm run <エイリアス名>
```

あらかじめ，任意のエイリアス名を```scripts```キー下に定義する．エイリアスの中で，実行するコマンドのセットを定義する．ちなみに，実行するコマンドの中で，再度```run```コマンドを定義することも可能である．

```json
{
    "scripts": {
        "<エイリアス名>": "<実行するコマンド>",
        "dev": "npm run development",
        "development": "cross-env NODE_ENV=development node_modules/webpack/bin/webpack.js --progress --hide-modules --config=node_modules/laravel-mix/setup/webpack.config.js",
        "watch": "npm run development -- --watch",
        "watch-poll": "npm run watch -- --watch-poll",
        "hot": "cross-env NODE_ENV=development node_modules/webpack-dev-server/bin/webpack-dev-server.js --inline --hot --disable-host-check --config=node_modules/laravel-mix/setup/webpack.config.js",
        "prod": "npm run production",
        "production": "cross-env NODE_ENV=production node_modules/webpack/bin/webpack.js --no-progress --hide-modules --config=node_modules/laravel-mix/setup/webpack.config.js"
    }
}
```

<br>

### NODE_OPTIONS

#### ・メモリ上限をなくす

```shell
$ export NODE_OPTIONS="--max-old-space-size=2048"
```

<br>

## 02. モジュールバンドル

### モジュールバンドルとは

<br>

### 機能

#### ・読み込むパッケージをまとめる

参考：https://qiita.com/soarflat/items/28bf799f7e0335b68186

**＊例＊**

以下のようなHTMLファイルがあるとする．

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>webpack tutorial</title>
</head>
<body>
<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script src="js/app.js"></script>
</body>
</html>
```

モジュールバンドルは，scriptタグでのパッケージの読み込みをまとめる．これがブラウザにレンダリングされると，JavaScriptのファイルへのリクエスト数が減るため，ページの読み込みが早くなる．

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>webpack tutorial</title>
</head>
<body>
<!-- jQueryもバンドルされたファイル -->
<script src="js/bundle.js"></script>
</body>
</html>
```



