# 言語別の処理方式

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. エントリポイント

### エントリポイントとは

プログラムを実行する時の起点となるファイル／関数のこと．エントリポイントのファイル／関数を起点として，そのプログラムの全てのファイルの処理が実行される．

参考：https://en.wikipedia.org/wiki/Entry_point

<br>

### 動的型付け型言語のエントリポイント

#### ・特徴

動的型付け言語では，エントリポイントの定義方法が強制されず，指定したファイルの先頭行がエントリポイントになる．ただし慣例として，『```index```』という名前のファイルをエントリポイントとする言語が多い．

#### ・PHP

慣例として```index.php```ファイルをエントリポイントとすることになっている．

<br>

### 静的型付け型言語のエントリポイント

#### ・特徴

静的型付け言語では，エントリポイントの定義方法が強制される．『```main```』という名前の関数でエントリポイントを定義させる言語が多い．

#### ・Java

修飾子が『```public static```』，返却値型が『```void```』，引数名が『```args```』，引数型が『```String[]```』である```main```関数が，自動的にエントリポイントになる．

```java
import java.util.*;

public class Age
{
    // エントリポイントとなる関数
    public static void main(String[] args)
    {
        // 他の全ファイルに繋がる処理
    }
}
```

#### ・Go

パッケージ名が『```main```』である````main```が，自動的にエントリポイントとなる．

```go
package main

// エントリポイントとなる関数
func main() {
    // 他の全ファイルに繋がる処理
}
```

<br>

## 02. 並行処理（Concurrent processing）

### 並行処理とは

プロセスでシングルスレッドが実行されている場合に，複数の処理を『独立的』に実行すること．

参考：

- https://techdifferences.com/difference-between-concurrency-and-parallelism.html
- https://moz.hatenablog.jp/entry/2018/04/10/175643
- https://zenn.dev/hsaki/books/golang-concurrency/viewer/term

<br>

### 言語別の並行処理

#### ・Go

Goroutinesを使用する．

参考：

- https://golang.org/doc/effective_go#concurrency
- https://qiita.com/taigamikami/items/fc798cdd6a4eaf9a7d5e

<br>

## 03. 並列処理（Parallel processing）

### 並列処理とは

プロセスでマルチスレッドが実行されている場合に，各スレッド上で複数の処理を『同時発生的』に実行すること．開始は同時であるが，終了はバラバラになる．

参考：

- https://techdifferences.com/difference-between-concurrency-and-parallelism.html
- https://moz.hatenablog.jp/entry/2018/04/10/175643

<br>

### 言語別の並列処理

#### ・PHP

parallelライブラリを使用する．

参考：

- https://github.com/krakjoe/parallel
- https://qiita.com/WhiteGrouse/items/6fb906386b8fbabd6405

#### ・JavaScript

  WebWorkerを使用する．

参考：https://developer.mozilla.org/ja/docs/Web/API/Web_Workers_API/Using_web_workers

<br>

## 04. 同期処理（Synchronous 9rocessing）

### 同期処理とは

プログラムの一連の処理を上から順番に実行する．

<br>

## 05. 非同期処理（Asynchronous 9rocessing）

### 非同期処理とは

一連の処理の中に非同期処理が含まれる場合，非同期処理の完了を待たずに後続の処理が始まる．

参考：

- https://qiita.com/kiyodori/items/da434d169755cbb20447
- https://qiita.com/klme_u6/items/ea155f82cbe44d6f5d88

<br>

### 非同期処理の結果を用いる後続処理

#### ・後続処理の定義

後続の全処理が非同期処理と無関係であれば，そのままで問題は起こらない．しかし，後続の処理に非同期処理の結果を使用するものが含まれている場合，この処理だけは非同期処理の後に実行されるように定義する必要がある．言語別にこれを定義できる機能が提供されている．

#### ・JavaScript

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/software/software_application_frontend_js_logic_asynchronous_process.html?h=%E5%9C%B0%E7%8D%84

