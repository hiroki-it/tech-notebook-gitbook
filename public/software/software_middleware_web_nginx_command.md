# nginxコマンド

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. コマンド

### -c

設定ファイルを指定して、nginxプロセスを実行する。

```bash
$ sudo nginx -c ./custom-nginx.conf
```

<br>

### -t

設定ファイルのバリデーションを実行する。また、読み込まれている全ての設定ファイル（```include```ディレクティブの対象も含む）の内容の一覧を表示する。

参考：https://www.nginx.com/resources/wiki/start/topics/tutorials/commandline/

```bash
$ sudo nginx -t
```

<br>

## 02. nginxプロセスの操作

### プロセス起動

```bash
$ sudo systemctl start nginx
```

<br>

### プロセス停止

```bash
$ sudo systemctl stop nginx
```

<br>

### 設定ファイルのバリデーション

```bash
$ sudo service nginx configtest
```

<br>

### プロセスの安全な再起動

```bash
$ sudo systemctl reload nginx
```