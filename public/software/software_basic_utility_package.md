# パッケージ

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. dnsutils

### インストール

#### ・apt-get経由

``` bash
$ apt-get install dnsutils
```

#### ・yum経由

```bash
$ yum install bind-utils
```

<br>

### nslookup

#### ・オプション無し

正引き/逆引きによる名前解決を行う。もしドメイン名に複数のIPアドレスが割り当てられている場合、正引きを行うと、全てのIPアドレスが返却される。

**＊例＊**

```bash
# 正引き
$ nslookup google.co.jp

Non-authoritative answer:
Server:  UnKnown
Address:  2400:2650:7e1:5a00:1111:1111:1111:1111

Name:  google.co.jp
Addresses:  2404:6800:4004:80f::2003 # IPv6アドレス
            172.217.175.3            # IPv4アドレス
```

```bash
# 逆引き
$ nslookup 172.217.175.3

Server:  UnKnown
Address:  2400:2650:7e1:5a00:1111:1111:1111:1111

Name:  nrt20s18-in-f3.1e100.net # IPv4アドレスにマッピングされたドメイン名
Address:  172.217.175.3 # IPv4アドレス
```

#### ・-type

正引き/逆引きによる名前解決を行い、この時に指定したレコードタイプのレコード値を返却させる。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/cloud_computing/cloud_computing_aws.html

**＊例＊**

名前解決を行い、NSレコード値を返却させる。

```bash
$ nslookup -type=NS google.co.jp

Non-authoritative answer:
Server:  UnKnown
Address:  2400:2650:7e1:5a00:1111:1111:1111:1111

google.co.jp    nameserver = ns3.google.com
google.co.jp    nameserver = ns4.google.com
google.co.jp    nameserver = ns2.google.com
google.co.jp    nameserver = ns1.google.com

ns1.google.com  AAAA IPv6 address = 2001:4860:4802:32::a
ns2.google.com  AAAA IPv6 address = 2001:4860:4802:34::a
ns3.google.com  AAAA IPv6 address = 2001:4860:4802:36::a
ns4.google.com  AAAA IPv6 address = 2001:4860:4802:38::a
ns1.google.com  internet address = 216.239.32.10
ns2.google.com  internet address = 216.239.34.10
ns3.google.com  internet address = 216.239.36.10
ns4.google.com  internet address = 216.239.38.10
(root)  ??? unknown type 41 ???
```

<br>

## 02. supervisor

### インストール

#### ・pip経由

参考：http://supervisord.org/installing.html#installing-a-distribution-package

```bash
$ pip3 install supervisor
```

<br>

### supervisorの構成要素

#### ・supervisor

Python製のユーティリティであり、常駐プロセスを一括で管理する。

参考：http://supervisord.org/index.html

#### ・supervisorctl

supervisordを操作する。

参考：http://supervisord.org/introduction.html#supervisor-components

#### ・supervisord

supervisor自体のプロセスのこと。

参考：http://supervisord.org/introduction.html#supervisor-components

<br>

### supervisordセクション

#### ・supervisordセクションとは

supervisordについて設定する。

参考：http://supervisord.org/configuration.html#supervisord-section-settings

```bash
[supervisord]

# 〜 中略 〜
```

#### ・directory

常駐プロセスの起動コマンドを実行する作業ディレクトリを設定する。

```bash
directory=/var/www/foo
```

#### ・logfile

supervisordのログファイルの場所を設定する。

```bash
logfile=/var/log/supervisor/supervisord.log
```

#### ・loglevel

supervisordのログレベルを設定する。

```bash
loglevel=info
```

#### ・nodaemon

supervisordをフォアグラウンドで起動するかどうかを設定する。

```bash
nodaemon=true
```

#### ・pidfile

supervisordのpidが記載されるファイルを設定する。

```bash
pidfile=/var/tmp/supervisor/supervisord.pid
```

#### ・redirect_stderr

標準出力への出力を標準エラー出力に転送する可動化を設定する。

```bash
redirect_stderr=true
```

#### ・user

supervisordの実行ユーザを設定する。

```bash
user=root
```

<br>

### programセクション

#### ・programセクションとは

管理対象の常駐プロセスについて設定する。

参考：

- http://supervisord.org/configuration.html#program-x-section-settings
- https://christina04.hatenablog.com/entry/2015/07/21/215525

```bash
[program:php-fpm]

# 〜 中略 〜

[program:crond]

# 〜 中略 〜
```

#### ・autorestart

常駐プロセスの異常停止時に自動的に起動させるかどうかを設定する。

```bash
autorestart=true
```

#### ・autostart

supervisordの起動時に常駐プロセスを自動的に起動させるかどうか、を設定する。

```bash
autostart=true
```

#### ・command

常駐プロセスの起動コマンドを設定する。

```bash
command=/usr/sbin/crond -n
```

#### ・redirect_stderr

常駐プロセスの標準出力への出力を標準エラー出力に転送するかどうかを設定する。

```bash
redirect_stderr=true
```

#### ・startretries

常駐プロセスの起動に失敗した場合に、何回再試行するかを設定する。

```bash
startretries=10
```

#### ・stdout_logfile、stderr_logfile

常駐プロセスの標準出力/標準エラー出力の出力先を設定する。デフォルト値は```/var/log/supervisor```ディレクトリである。もし、```/dev/stdout```ディレクトリまたは```/dev/stderr```ディレクトリを使用する場合は、```logfile_maxbytes ```オプションの値を```0```（無制限）とする必要がある。

参考：http://supervisord.org/configuration.html#supervisord-section-values

```bash
# 標準出力の場所
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0

# 標準エラー出力の場所
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
```

#### ・stdout_logfile_backups

ログローテートによって作成されるバックアップの世代数。

```bash
stdout_logfile_backups=10
```

#### ・stdout_logfile_maxbytes

ログファイルの最大サイズ。設定値を超えると、ログローテートが実行される。これにより、ログファイルがバックアップとして保存され、新しいログファイルが作成される。

```bash
stdout_logfile_maxbytes=50MB
```

#### ・user

常駐プロセスの実行ユーザを設定する。

```bash
user=root
```

<br>

### groupセクション

#### ・priority

```bash
priority=999
```

#### ・programs

グループ化する常駐プロセス名を設定する。

```bash
programs=bar,baz
```

<br>

### supervisorctl

#### ・restart

指定した常駐プロセスを再起動する。```all```とした場合は、全てを再起動する。

参考：http://supervisord.org/running.html#supervisorctl-actions

```bash
$ supervisorctl restart <常駐プロセス名>
```

#### ・update

もし```supervisord.conf```ファイルの設定を変更した場合に、これを読み込み直す。

参考：http://supervisord.org/running.html#supervisorctl-actions

```
$ supervisorctl update
```

