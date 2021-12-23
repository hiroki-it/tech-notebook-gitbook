# パッケージ

## 01. supervisor

### supervisorとは

Python製のユーティリティであり、常駐プロセスを一括で管理する。

参考：http://supervisord.org/index.html

```bash
$ pip3 install supervisor
```

<br>

### supervisord

#### ・supervisordとは

supervisor自体のプロセスのこと。

参考：http://supervisord.org/introduction.html#supervisor-components

#### ・```[supervisord]```

supervisordについて設定する。

参考：http://supervisord.org/configuration.html#supervisord-section-settings

```bash
[supervisord]

# 〜 中略 〜
```

#### ・logfile

supervisordのログファイルの場所を設定する。

```bash
logfile=/var/log/supervisor/supervisord.log
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

#### ・user

supervisordの実行ユーザを設定する。

```bash
user=root
```

<br>

### 常駐プロセスの管理

#### ・```[program:<常駐プロセス名>]```

管理対象の常駐プロセスについて設定する。

参考：http://supervisord.org/configuration.html#program-x-section-settings

```bash
[program:php-fpm]

# 〜 中略 〜

[program:crond]

# 〜 中略 〜
```

#### ・autorestart

常駐プロセスの異常停止時に自動的に起動させるかどうか、を設定する。

```bash
autorestart=true
```

#### ・autostart

OSの起動時に常駐プロセスを自動的に起動させるかどうか、を設定する。

```bash
autostart=true
```

#### ・command

常駐プロセスの起動コマンドを設定する。

```bash
command=/usr/sbin/crond -n
```

#### ・stdout_logfile、stderr_logfile、stdout_logfile_maxbytes

常駐プロセスの標準出力／標準エラー出力の出力先を設定する。デフォルト値は```/var/log/supervisor```ディレクトリである。もし、```/dev/stdout```ディレクトリまたは```/dev/stderr```を使用する場合は、```logfile_maxbytes ```を```0```とする必要がある。

参考：http://supervisord.org/configuration.html#supervisord-section-values

```bash
# 標準出力の場所
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0

# 標準エラー出力の場所
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
```

・user

常駐プロセスの実行ユーザを設定する。

```bash
user=root
```

#### ・directory

常駐プロセスの起動コマンドを実行する作業ディレクトリを設定する。

```bash
directory=/var/www/foo
```

<br>

### supervisorctl

#### ・supervisorctlとは

supervisordを操作する。

参考：http://supervisord.org/introduction.html#supervisor-components

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



