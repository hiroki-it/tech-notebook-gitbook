# パッケージ管理

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. composerによるパッケージの管理

### composer.jsonファイルの実装

#### ・バージョンを定義

```bash
# 個人的に一番おすすめ
# キャレット表記
{
  "require": {
    "foo": "^1.1.1",  # >=1.1.1 and <1.2.0
    "bar": "^1.1",    # >=1.1.0 and <1.2.0
    "baz": "^0.0.1"   # >=0.0.1 and <0.0.2
  }
}
```

```bash
# チルダ表記
{
  "require": {
    "foo": "~1.1.1",  # >=1.1.1 and <2.0.0
    "bar": "~1.1",    # >=1.1.0 and <2.0.0
    "baz": "~1"       # >=1.1.0 and <2.0.0
  }
}
```

```bash
# エックス，アスタリスク表記
{
  "require": {
    "foo": "*",     # どんなバージョンでもOK
    "bar": "1.1.x", # >=1.1.0 and <1.2.0 
    "baz": "1.X",   # >=1.0.0 and <2.0.0
    "qux": ""       # "*"と同じことになる = どんなバージョンでもOK
  }
}
```

####  ・名前空間のユーザ定義

名前空間とファイルパスの対応関係を設定する．

```bash
{
    "autoload": {
        "psr-4": {
             # "<名前空間>": "<ファイルパス>",
            "App\\": "app/",
            "Database\\Factories\\Infrastructure\\DTO\\": "database/factories/production",
            "Database\\Seeders\\": "database/seeds/production"
        },
        "classmap": [
            "database/seeds",
            "database/factories"
        ]
    }
}
```

その後，名前空間の読み込みを登録する．

```bash
$ composer dump-autoload
```

<br>

### require

#### ・オプションなし

パッケージ名を```composer.json```ファイルを書き込む．インストールは行わない．コマンドを使用せずに自分で実装しても良い．

```bash
$ composer require <パッケージ名>:^x.x
```

<br>

### install

#### ・オプションなし

アプリケーションにて，```composer.lock```ファイルに実装されたパッケージを全てインストールする．```composer.lock```ファイルのおかげで，リポジトリの利用者が，```composer install```の実行時に，共通のバージョンのパッケージをインストールできる．

```bash
$ composer install 
```

####  ・-vvv

コマンド処理中のログを表示する

```bash
$ composer install -vvv
```

####  ・--no-dev

require-devタグ内のパッケージは除いてインストール

```bash
$ composer install --no-dev
```

#### ・--prefer-dist

Composerの配布サイトからインストールする．```prefer-source```オプションを使用するよりも高速でインストールできる．デフォルトでdistを使用するため，実際は宣言しなくても問題ない．

```bash
$ composer install --prefer-dist
```

#### ・--prefer-source

GitHubのComposerリポジトリからインストールする．Composerの開発者用である．

```bash
$ composer install --prefer-source
```

<br>

### update

#### ・オプションなし

アプリケーションにて，```composer.json```ファイルに実装されたパッケージのうちで，インストールされていないものをインストールする．また，バージョンの指定をもとに更新可能なパッケージを更新する．```composer.lock```ファイルに全てのパッケージ情報を書き込む．リポジトリの利用者がインストールするパッケージにも影響を与える．

```bash
$ composer update
```

####  ・-vvv

コマンド処理中のログを表示する

```bash
$ composer install -vvv
```

####  ・COMPOSER_MEMORY_LIMIT=-1

phpのメモリ上限を無しにして，任意のcomposerコマンドを実行する．phpバイナリファイルを使用する．Dockerコンテナ内で実行する場合，設定画面からコンテナのCPUやメモリを増設することもできる．

```bash
$ COMPOSER_MEMORY_LIMIT=-1 composer update -vvv
```

<br>

### その他のコマンド

#### ・clear-cache

インストール時に生成されたキャッシュを削除する．

```bash
$ composer clear-cache
```

#### ・エイリアス名

ユーザが定義したエイリアス名のコマンドを実行する．

```bash
$ composer <エイリアス名>
```

あらかじめ，任意のエイリアス名を```scripts```キー下に定義する．エイリアスの中で，実行するコマンドのセットを定義する．

```bash
{
    "scripts": {
        # エイリアス名
        "post-autoload-dump": [
            # 実行するコマンド
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists(".env") || copy(".env.example", ".env");\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    }
}
```

<br>

### バージョンアップの手順

#### ・事前確認の重要性

バージョン更新により，アプリケーションやこれに関係する他のアプリケーションに影響が起こる可能性がある．そのため，予想外の影響が起こらないように，マニュアルやリリースノートにて，バージョン間の差異を全て確認しておく必要がある．

#### 1. バージョン間の互換性を確認

破壊的変更のためにバージョン間で互換性が全くなく，古いバージョンと新しいバージョンで使用方法やオプションが異なる可能性がある．一方で，互換性があるものの，大きな変更がなされている可能性がある．

#### 2. 追加，廃止，非推奨を確認

バージョンアップにより，新しい機能が追加されている可能性がある．一方で，今までの方法が廃止または非推奨に移行している可能性がある．

#### 3. 予約語や関数を確認

バージョンアップにより，予約語や関数が変更されている可能性がある．予約語を自身が使用しているとバッティングしてエラーになってしまう．

#### 4. アプリケーションの修正作業の考慮

バージョンアップに伴ってソースコードの修正が必要なことがわかった場合，バージョンアップの手順自体に修正作業を組み込む必要がある．

#### 5. メンテナンスページの表示

バージョンアップによりダウンタイムが発生する場合，その間はメンテナンスページを表示する必要がある，例えば，ALBにはメンテナンスページを表示するための機能がある．

#### 6. 更新作業をリハーサル

テスト環境で更新作業をリハーサルし，問題なく完了することを確認する．

#### 7. アプリケーションのテスト

テスト環境のバージョンアップ後に，アプリケーションをテストする必要がある．

#### 8. リードレプリカを最初にアップデート

#### 9. 切り戻し作業の考慮

本番環境のバージョンアップ後に想定外の問題が起こることも考慮して，バージョンアップの手順自体に切り戻し作業を組み込む必要がある．

<br>

## 02. アプリケーションによるパッケージの読み込み

### エントリポイントにおける```autoload.php```ファイルの読み込み

パッケージが，```vendor```ディレクトリ下に保存されていると仮定する．パッケージを使用するたびに，各クラスでディレクトリを読み込むことは手間なので，エントリーポイント（```index.php```）あるいは```bootstrap.php```で，最初に読み込んでおき，クラスでは読み込まなくて良いようにする．

**＊実装例＊**

```php
<?php
    
require_once realpath(__DIR__ . "/vendor/autoload.php");
```
