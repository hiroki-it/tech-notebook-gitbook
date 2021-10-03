# 言語プロセッサ

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 02. プログラミング言語

### 言語の種類

プログラム言語のソースコードは，言語プロセッサによって機械語に変換された後，CPUによって読み込まれる．そして，ソースコードに書かれた様々な処理が実行される．

<br>

### コンパイラ型言語

C#など．コンパイラという言語プロセッサによって，コンパイラ方式で翻訳される言語．

<br>

### インタプリタ型言語

PHP，Ruby，JavaScript，Python，など．インタプリタという言語プロセッサによって，インタプリタ方式で翻訳される言語をインタプリタ型言語という．

<br>

### Java仮想マシン型言語

Scala，Groovy，Kotlin，など．Java仮想マシンによって，中間言語方式で翻訳される．

![コンパイル型とインタプリタ型言語](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/コンパイル型とインタプリタ型言語.jpg)

<br>

## 02-02. 処理方式の種類

### 並行処理（Concurrent processing）

#### ・並行処理とは

プロセスでシングルスレッドが実行されている場合に，複数の処理を『独立的』に実行すること．

参考：

- https://techdifferences.com/difference-between-concurrency-and-parallelism.html
- https://moz.hatenablog.jp/entry/2018/04/10/175643
- https://zenn.dev/hsaki/books/golang-concurrency/viewer/term

#### ・言語別の実現方法

| 言語 | 方法                                                         |
| ---- | ------------------------------------------------------------ |
| Go   | Goroutinesを使用する．<br/>参考：<br>・https://golang.org/doc/effective_go#concurrency<br>・https://qiita.com/taigamikami/items/fc798cdd6a4eaf9a7d5e |

<br>

### 並列処理（Parallel processing）

#### ・並列処理とは

プロセスでマルチスレッドが実行されている場合に，各スレッド上で複数の処理を『同時発生的』に実行すること．開始は同時であるが，終了はバラバラになる．

参考：

- https://techdifferences.com/difference-between-concurrency-and-parallelism.html
- https://moz.hatenablog.jp/entry/2018/04/10/175643

#### ・言語別の実現方法

| 言語       | 方法                                                         |
| ---------- | ------------------------------------------------------------ |
| JavaScript | WebWorkerを使用する．<br>参考：https://developer.mozilla.org/ja/docs/Web/API/Web_Workers_API/Using_web_workers |
| PHP        | parallelライブラリを使用する．<br>参考：<br>・https://github.com/krakjoe/parallel<br>・https://qiita.com/WhiteGrouse/items/6fb906386b8fbabd6405 |
| Go         | 要調査                                                       |

<br>

### 同期処理（Synchronous 9rocessing）

#### ・同期処理とは

<br>

### 非同期処理（Asynchronous 9rocessing）

#### ・非同期処理とは

一連の処理を順不同で実行する．並行処理とは異なることに気を付ける．

参考：

- https://qiita.com/kiyodori/items/da434d169755cbb20447
- https://qiita.com/klme_u6/items/ea155f82cbe44d6f5d88

<br>

## 02-03. 実行のエントリポイント

### 動的型付け型言語の場合

#### ・エントリポイント

動的型付け言語では，エントリポイントが指定プログラムの先頭行と決まっており，そこから枝分かれ状に処理が実行されていく．

#### ・PHPの場合

PHPでは，```index.php```ファイルがエントリポイントと決められている．その他のファイルにはエントリポイントは存在しない．

```PHP
<?php

use App\Kernel;
use Symfony\Component\ErrorHandler\Debug;
use Symfony\Component\HttpFoundation\Request;

// まず最初に，bootstrap.phpを読み込む．
require dirname(__DIR__) . "/config/bootstrap.php";

if ($_SERVER["APP_DEBUG"]) {
    umask(0000);
    
    Debug::enable();
}

if ($trustedProxies = $_SERVER["TRUSTED_PROXIES"]?? $_ENV["TRUSTED_PROXIES"] ?? false) {
    Request::setTrustedProxies(explode(",", $trustedProxies), Request::HEADER_X_FORWARDED_ALL ^ Request::HEADER_X_FORWARDED_HOST);
}

if ($trustedHosts = $_SERVER["TRUSTED_HOSTS"] ?? $_ENV["TRUSTED_HOSTS"] ?? false) {
    Request::setTrustedHosts([$trustedHosts]);
}

$kernel = new Kernel($_SERVER["APP_ENV"], (bool)$_SERVER["APP_DEBUG"]);
$request = Request::createFromGlobals();
$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
```

<br>

### 静的型付け型言語の場合

#### ・エントリポイント

静的型付け言語では，エントリポイントが決まっておらず，自身で定義する必要がある．

#### ・Java

Javaでは，「```public static void main(String[] args)```メソッドを定義した場所がエントリポイントになる．

```java
import java.util.*;

public class Age
{
    // エントリポイントとなるメソッド
    public static void main(String[] args)
    {
        // 定数を定義．
        final int age = 20;
        System.out.println("私の年齢は" + age);

        // 定数は再定義できないので，エラーになる．
        age = 31;
        System.out.println("…いや，本当の年齢は" + age);
    }
}
```

<br>

## 03. 言語プロセッサによる翻訳方式

### アセンブラ方式

アセンブリ型言語を機械語に翻訳する方法のこと．

<br>

### コンパイラ方式

コンパイラ型言語を機械語に翻訳する方法のこと．

<br>

### インタプリタ方式

インタプリタ型言語を機械語に翻訳する方法のこと．

<br>

## 03-02. コンパイラ型言語の機械語翻訳

### コンパイラ方式

#### ・機械語翻訳と実行のタイミング

コードを，バイナリ形式のオブジェクトコードとして，まとめて機械語に翻訳した後，CPUに対して命令が実行される．

![コンパイラ言語](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/コンパイラ言語.png)

#### ・ビルド（コンパイル＋リンク）

コンパイルによって，ソースコードは機械語からなるオブジェクトコードに変換される．その後，各オブジェクトコードはリンクされ．exeファイルとなる．この一連のプロセスを『ビルド』という．また，ビルドによって生成されたファイルを『アーティファクト（成果物）』という．

![ビルドとコンパイル](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ビルドとコンパイル.jpg)

#### ・仕組み（じ，こ，い，さい，せい，リンク，実行）

![字句解析，構文解析，意味解析，最適化](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/字句解析，構文解析，意味解析，最適化.png)

1. **Lexical analysis（字句解析）**

   ソースコードの文字列を言語の最小単位（トークン）の列に分解． 以下に，トークンの分類方法の例を示す．

   ![構文規則と説明](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/構文規則と説明.png)

2. **Syntax analysis（構文解析）**

   トークンの列をツリー構造に変換．

3. **Semantics analysis（意味解析）**

   ツリー構造を基に，ソースコードに論理的な誤りがないか解析．

4. **Code optimization（コード最適化）**

   ソースコードの冗長な部分を削除または編集．機械語をより短くするこができる．

5. **Code generation（コード生成）**

   最適化されたコードをバイナリ形式のオブジェクトコードに変換．

6. **リンク**

   オブジェクトコードをリンクする．

7. **命令の実行**

   リンクされたオブジェクトコードを基に，命令が実行される．

<br>

### makeによるビルド

#### 1. パッケージをインストール

```bash
# パッケージを公式からインストールと解答
$ wget <パッケージのリンク>
$ tar <パッケージのフォルダ名>

# ビルド用ディレクトリの作成．
$ mkdir build
$ cd build
```

#### 2. ビルドのルールを定義

configureファイルを元に，ルールが定義されたMakefileを作成する．

```bash
# configureへのパスに注意．
$ ../configure --prefix="<ソースコードのインストール先のパス>"
```

#### 3. ビルド （コンパイル＋リンク）

パッケージのソースコードからexeファイルをビルドする．

```bash
# -j で使用するコア数を宣言し，処理の速度を上げられる．
$ make -j4
```

任意で，exeファイルのテストを行える．

```bash
$ make check
```

#### 4. exeファイルの実行

生成されたソースコードのファイルを，指定したディレクトリにコピー．

```bash
# installと命令するが，実際はコピー．sudoを付ける．
$ sudo make install
```

元となったソースコードやオブジェクトコードを削除．

```bash
$ make clean
```

<br>

## 03-03. インタプリタ型言語の機械語翻訳

### インタプリタ方式

#### ・機械語翻訳と実行のタイミング

コードを，一行ずつ機械語に変換し，その都度，CPUに対して命令が実行される．

![インタプリタ言語](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/インタプリタ言語.png)

コマンドラインでそのまま入力し，機械語翻訳と実行を行うことができる．

```bash
#===========
# PHPの場合
#===========

# PHPなので，処理終わりにセミコロンが必要
$ php -r "<何らかの処理>"

# Hello Worldを出力
$ php -r "echo "Hello World";"

# phpinfoを出力
$ php -r "phpinfo();"

# （おまけ）phpinfoの出力をテキストファイルに保存
$ php -r "phpinfo();" > phpinfo.txt
```

```bash
# php.iniの読み込み状況を出力
$ php --ini
```

#### ・仕組み（じ，こ，い，実行）

![字句解析，構文解析，意味解析，最適化](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/字句解析，構文解析，意味解析，最適化.png)

1. **Lexical analysis（字句解析）**

   ソースコードの文字列を言語の最小単位（トークン）の列に分解． 以下に，トークンの分類方法の例を示す．

   ![構文規則と説明](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/構文規則と説明.png)

2. **Syntax analysis（構文解析）**

   トークンの列をツリー構造に変換．ソースコードから構造体を構築することを構文解析といい，htmlを構文解析してDOMツリーを構築する処理とは別物なので注意．

3. **Semantics analysis（意味解析）**

   ツリー構造を基に，ソースコードに論理的な誤りがないか解析．

4. **命令の実行**

   意味解析の結果を基に，命令が実行される．

5. **１から４をコード行ごとに繰り返す**

#### ・補足：JSの機械語翻訳について

Webサーバを仮想的に構築する時，PHPの言語プロセッサが同時に組み込まれるため，PHPのソースコードの変更はブラウザに反映される．しかし，JavaScriptの言語プロセッサは組み込まれない．そのため，JavaScriptのインタプリタは別に手動で起動する必要がある．

<br>

## 03-04. Java仮想マシン型言語の機械語翻訳

### 中間言語方式

#### ・中間言語方式の機械語翻訳の流れ

1. JavaまたはJVM型言語のソースコードを，Javaバイトコードを含むクラスファイルに変換する．
2. JVM：Java Virtual Machine内で，インタプリタによって，クラスデータを機械語に翻訳する．
3. 結果的に，OS（制御プログラム？）に依存せずに，命令を実行できる．（C言語）

![Javaによる言語処理_1](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Javaによる言語処理_1.png)

![矢印_80x82](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/矢印_80x82.jpg)

![Javaによる言語処理_2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Javaによる言語処理_2.png)

![矢印_80x82](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/矢印_80x82.jpg)

![Javaによる言語処理_3](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Javaによる言語処理_3.png)

#### ・C言語とJavaのOSへの依存度比較

![CとJavaのOSへの依存度比較](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/CとJavaのOSへの依存度比較.png)

- JVM言語

ソースコード

<br>