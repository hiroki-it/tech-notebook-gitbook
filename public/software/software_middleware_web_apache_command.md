# apacheコマンド

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. コマンド

### リファレンス

### httpd

参考：https://httpd.apache.org/docs/trunk/ja/programs/httpd.html

<br>

### apachectl

参考：https://httpd.apache.org/docs/trunk/ja/programs/apachectl.html

<br>

## 02. apacheプロセスの操作

### ディレクティブの実装場所の一覧

特定のディレクティブを実装するべき設定ファイルの一覧を表示する。

```bash
$ sudo httpd -L
```

<br>

### 設定ファイルのバリデーション

```bash
# systemctlコマンドでは実行不可能

$ sudo service httpd configtest

$ sudo apachectl configtest

$ sudo apachectl -t
```

<br>

### コンパイル済みモジュールの一覧

コンパイル済みのモジュールの一覧を表示する。表示されているからといって、読み込まれているとは限らない。

```bash
$ sudo httpd -l
```

<br>

### 読み込み済みモジュールの一覧

コンパイル済みのモジュールのうちで、実際に読み込まれているモジュールを表示する。

```bash
$ sudo httpd -M
```

<br>

### 読み込み済み```conf```ファイルの一覧

読み込まれた```conf```ファイルの一覧を表示する。この結果から、使われていない```conf```ファイルもを検出できる。

```bash
$ sudo httpd -t -D DUMP_CONFIG 2>/dev/null | grep "# In" | awk "{print $4}"
```

<br>

### 読み込まれるVirtualHost設定の一覧

```bash
$ sudo httpd -S
```

<br>

### 強制的な起動/停止/再起動

```bash
# 起動
$ sudo systemctl start httpd

# 停止
$ sudo systemctl stop httpd

# 再起動
$ sudo systemctl restart httpd
```

<br>

### 安全な再起動

Apacheを段階的に再起動する。安全に再起動できる。

```bash
$ sudo apachectl graceful
```

