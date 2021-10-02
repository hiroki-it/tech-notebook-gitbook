# Nuxt.js

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## コマンド

#### serverモード

#### ・serverモードとは

アプリケーションをSSRとして稼働させる．

参考：https://ja.nuxtjs.org/docs/2.x/get-started/commands#target-server

#### ・dev

ローカル環境として使用するため，アプリケーションをビルドし，Nodeサーバを起動する．Webpackは使用されないため，静的ファイルの圧縮や画像ファイル名のハッシュ化は実行されない．

```shell
$ nuxt dev
```

#### ・build

本番環境として使用するため，Nodeサーバの起動前にアプリケーションのビルドを実行する．```dev```コマンドとは異なり，ビルド時にWebpackによる最適化が実行される．これにより，JavaScriptとCSSはminifyされる．minifyにより，不要な改行やインデントが削除され，パッケージの読み込みURLはまとめられ，圧縮される．画像名はハッシュ化される．

```shell
$ nuxt build
```

#### ・start

本番環境として使用するため，ビルド完了後にNodeサーバを起動する．SSRモードのために使用する．

```shell
$ nuxt start
```

<br>

### staticモード

#### ・staticモードとは

アプリケーションをSSGとして稼働させる．

参考：https://ja.nuxtjs.org/docs/2.x/get-started/commands#target-static

#### ・dev

ローカル環境として使用するため，アプリケーションをビルドし，Nodeサーバを起動する．Webpackは使用されないため，静的ファイルの圧縮や画像ファイル名のハッシュ化は実行されない．

```shell
$ nuxt dev
```

#### ・build

Node.jsを使用してテストフレームワークを動かすために使用する．```dev```コマンドとは異なり，ビルド時にWebpackによる最適化が実行される．これにより，JavaScriptとCSSはminifyされる．minifyにより，不要な改行やインデントが削除され，パッケージの読み込みURLはまとめられ，圧縮される．画像名はハッシュ化される．

```shell
$ nuxt build
```

#### ・generate

JavaScriptから静的ファイルを生成する．静的ファイルをビデータベースに格納したデータ（例：画像ファイルパス）を元にビルドすることも可能である．SSGモードのために使用する．

```shell
$ nuxt generate
```

#### ・```start```

静的ホスティングサイトを起動する．

```shell
$ nuxt start
```

<br>

### ビルド時のWebpackオプション

serverモードとstaticモードにおいて，```build```コマンド時に使用されるWebpackの最適化方法を指定できる．`

https://ja.nuxtjs.org/docs/2.x/get-started/commands#webpack-%E3%81%AE%E8%A8%AD%E5%AE%9A%E3%82%92%E6%A4%9C%E6%9F%BB

<br>

## 設定ファイル

### ```env```ファイル

```sh
# API側のURL（フロントエンドからのリクエスト向け）
API_URL=http://web:80/
# API側のURL（外部サーバからのリクエスト向け）
API_URL_BROWSER=http://localhost:8500/
# API側のOauth認証の情報
OAUTH_CLIENT_ID=
OAUTH_CLIENT_SECRET=
# GoogleMapのURL
GOOGLE_MAP_QUERY_URL=https://www.google.com/maps/search/?api=1&query=
# ホームパス
HOME_PATH=/
```

<br>

### ```nuxt.config.js```ファイル

#### ・概要

Nuxtが標準で用意している設定を上書きできる．

参考：https://ja.nuxtjs.org/docs/2.x/directory-structure/nuxt-config#nuxtconfigjs

```javascript
import { Configuration } from '@nuxt/types'

const nuxtConfig: Configuration = {

}
```

#### ・hardSource

ビルド時のキャッシュを有効化する．ビルドの完了が早くなる．

参考：https://nuxtjs.org/docs/2.x/configuration-glossary/configuration-build#hardsource

```javascript
import { Configuration } from '@nuxt/types'

const nuxtConfig: Configuration = {
    
  build: {
    hardSource: true,
  },
}
```

#### ・quiet

ビルド時にログを最小限にする．CICDツールでログが確認できなくなるため，無効化しておいた方が良い．

参考：https://ja.nuxtjs.org/docs/2.x/configuration-glossary/configuration-build#quiet

```javascript
import { Configuration } from '@nuxt/types'

const nuxtConfig: Configuration = {
    
  build: {
    quiet: false,
  },
}
```

