# CentOS

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. 基本ソフトウェア（広義のOS）

### 基本ソフトウェアの構成

![基本ソフトウェアの構成](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/基本ソフトウェアの構成.png)

<br>

## 02. ユーティリティ

### ユーティリティの種類

#### ・Unixの場合

今回，以下に紹介するものをまとめる．

| ファイルシステム系 | プロセス管理系 | ネットワーク系 | テキスト処理系 | 環境変数系  | ハードウェア系 |
| ------------------ | -------------- | -------------- | -------------- | :---------- | -------------- |
| mkdir              | batch          | nslookup       | tail           | export      | df             |
| ls                 | ps             | curl           | vim            | printenv    | free           |
| cp                 | kill           | netstat        | grep           | timedatectl | -              |
| find               | systemctl      | route          | history        | -           | -              |
| chmod              | cron           | ssh            | -              | -           | -              |
| rm                 | -              | -              | -              | -           | -              |
| chown              | -              | -              | -              | -           | -              |
| ln                 | -              | -              | -              | -           | -              |
| od                 | -              | -              | -              | -           | -              |
| tar                |                |                |                |             |                |

#### ・Windowsの場合

Windowsは，GUIでユーティリティを使用する．よく使うものを記載する．

| システム系         | ストレージデバイス管理系 | ファイル管理系         | その他             |
| ------------------ | ------------------------ | ---------------------- | ------------------ |
| マネージャ         | デフラグメントツール     | ファイル圧縮プログラム | スクリーンセーバー |
| クリップボード     | アンインストーラー       | -                      | ファイアウォール   |
| レジストリクリーナ | -                        | -                      | -                  |
| アンチウイルス     | -                        | -                      | -                  |

<br>

### ユーティリティのバイナリファイル

####  ・バイナリファイルの配置場所

| バイナリファイルのディレクトリ | バイナリファイルの種類                                       |
| ------------------------------ | ------------------------------------------------------------ |
| ```/bin```                     | Unixユーティリティのバイナリファイルの多く．                 |
| ```/usr/bin```                 | 管理ユーティリティによってインストールされるバイナリファイルの多く． |
| ```/usr/local/bin```           | Unix外のソフトウェアによってインストールされたバイナリファイル．最初は空になっている． |
| ```/sbin```                    | Unixユーティリティのバイナリファイルうち，```sudo```権限が必要なもの． |
| ```/usr/sbin```                | 管理ユーティリティによってインストールされたバイナリファイルのうち，```sudo```権限が必要なもの． |
| ```/usr/local/sbin```          | Unix外のソフトウェアによってインストールされたバイナリファイルのうち，```sudo```権限が必要なもの．最初は空になっている． |

``` bash
# バイナリファイルが全ての場所で見つからないエラー
$ which python3
which: no python3 in (/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin)

# バイナリファイルの場所
$ which python3 
/usr/bin/python3
```

<br>

### pipeline

#### ・pipelineとは

「```|```」の縦棒記号のこと．複数のプログラムの入出力を繋ぐことができる．

![pipeline](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/pipeline.png)

#### ・grepとの組み合わせ

コマンドの出力結果を```grep```コマンドに渡し，フィルタリングを行う．

**＊コマンド例＊**

検索されたファイル内で，さらに文字列を検索する．

```bash
$ find /* \
  -type f | xargs grep "<検索文字>"
```

#### ・killとの組み合わせ

コマンドの出力結果に対して，```kill```コマンドを行う．

**＊コマンド例＊**

フィルタリングされたプロセスを削除する．

```bash
$ sudo pgrep \
  -f <コマンド名> | sudo xargs kill -9
```

#### ・awkとの組み合わせ

コマンドの出力結果に対して，```awk```コマンドを行う．

**＊コマンド例＊**

検索されたファイルの容量を合計する．

```bash
$ find ./* -name "*.js" -type f -printf "%s\n" | awk "{ sum += $1; } END { print sum; }"
$ find ./* -name "*.css" -type f -printf "%s\n" | awk "{ sum += $1; } END { print sum; }"
$ find ./* -name "*.png" -type f -printf "%s\n" | awk "{ sum += $1; } END { print sum; }"
```

#### ・sortとの組み合わせ

コマンドの出力結果に対して，並び順を変更する．

**＊コマンド例＊**

表示された環境変数をAZ昇順に並び替える．

```bash
$ printenv | sort -f
```

<br>

### 標準入出力

#### ・標準入出力とは

| 種類                     | 説明                                                         |
| ------------------------ | ------------------------------------------------------------ |
| stddin（標準入力）       | キーボードからのコマンドに対して，データを入力するためのインターフェースのこと． |
| stdout（標準出力）       | コマンドからターミナルに対して，エラー以外のデータを出力するためのインターフェースのこと． |
| stderr（標準エラー出力） | コマンドからターミナルに対して，エラーデータを出力するためのインターフェースのこと． |

![標準入力，標準出力，標準出力エラー](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/標準入力，標準出力，標準出力エラー.jpg)

#### ・標準出力に出力

コマンド処理の後に，「```>&1```」を追加すると，処理の結果を，標準出力に出力できる．

**＊コマンド例＊**

```bash
$ echo "stdout" >&1
```

#### ・標準エラー出力に出力

コマンド処理の後に，「```>&2```」を追加すると，処理の結果を，標準エラー出力に出力できる．

**＊コマンド例＊**

```bash
$ echo "stderr" >&2
```

<br>

## 02-02. シェルスクリプト／Makefile

### シェルスクリプト

#### ・シェルスクリプトとは

ユーティリティの処理を手続き的に実装したファイル．最初の「```#!```」をシェバンという．

**＊実装例＊**

```bash
#!/bin/bash

echo "foo"
echo "bar"
echo "baz"
```

<br>

### Makefile

#### ・Makefileとは

ユーティリティの処理を手続き的に実装したファイル．ターゲットごとに処理を実装する．複数のターゲット名を割り当てられる．

```makefile
foo:
  echo "foo"
  
bar:
  echo "bar"
  
baz qux: # 複数のターゲット名
  echo "baz"
```

#### ・ターゲット間依存関係

特定のターゲットの実行前に，他のターゲットを実行しておきたい場合，依存関係を定義できる．これは複数定義できる．

```makefile
foo:
  echo "foo"
  
bar: foo # fooを事前に実行する．
  echo "bar"
  
baz: foo baz # foo，bazを事前に実行する．
  echo "baz"
```

<br>

### シェルスクリプトの実行方法

#### ・source

現在開かれているインタラクティブで処理を実行する．そのため，シェルスクリプト内で定義した変数は，シェルスクリプトの実行後も維持される．

```bash
$ source hello.sh
```

#### ・bash

新しくインタラクティブを開き，処理を実行する．そのため，シェルスクリプト内で定義した変数は，シェルスクリプトの実行後に破棄される．

```bash
$ bash hello.sh
```

#### ・ドット

```bash
$ . hello.sh
```

#### ・パス指定

相対パスもしくは絶対パスでシェルスクリプトを指定する．実行するファイルをカレントディレクトリに置くことはできない．

```bash
$ ./hello.sh
```

<br>

### Makefileの実行方法とオプション

#### ・make

Makefileが置かれた階層で，makeコマンドの引数としてターゲット名や環境変数を渡せる．Makefile内で環境変数のデフォルト値を定義できる．

```bash
$ make <ターゲット名> <環境変数名>=<値>
```

**＊実装例＊**

```bash
$ make foo FOO=foo
```

```makefile
FOO=default

foo:
  echo ${FOO}
```

<br>

### ロジック

#### ・ヒアドキュメント

ヒアドキュメントで作成したシェルスクリプトには，各行にechoが追加される．

```bash
#!/bin/bash

cat << EOF > "echo.sh"
#!/bin/bash
hoge
fuga
EOF
```

```bash
#!/bin/bash
echo hoge
echo fuga
```

#### ・for

**＊実装例＊**

```bash
#!/bin/bash
 
for i in 1 2 3 4 5
do
   echo "$i"
done
```

#### ・switch-case

変数に代入された値によって，処理を分ける．全ての場合以外をアスタリスクで定義する．

**＊実装例＊**

```bash
#!/bin/bash

case "$ENV" in
    "test")
        VAR="XXXXX"
    ;;
    "stg")
        VAR="YYYYY"
    ;;
    "prd")
        VAR="ZZZZZ"
    ;;
    *)
        echo "The parameter ${ENV} is invalid."
        exit 1
    ;;
esac
```

<br>

## 02-03. ファイルシステム系

### chmod：change mode

#### ・<数字>

ファイルの権限を変更する．よく使用されるパーミッションのパターンは次の通り．

```bash
$ chmod 600 <ファイル名>
```

#### ・-R <数字>

ディレクトリ内のファイルに対して，再帰的に権限を付与する．

```bash
$ chmod -R 600 <ディレクトリ名>
```

#### ・100番刻みの規則性

所有者以外に全権限が与えられない．

| 数字 | 所有者 | グループ | その他 | 特徴                   |
| :--: | :----- | :------- | :----- | ---------------------- |
| 500  | r-x    | ---      | ---    | 所有者以外に全権限なし |
| 600  | rw-    | ---      | ---    | 所有者以外に全権限なし |
| 700  | rwx    | ---      | ---    | 所有者以外に全権限なし |

#### ・111番刻みの規則性

全てのパターンで同じ権限になる．

| 数字 | 所有者 | グループ | その他 | 特徴                 |
| :--: | :----- | :------- | :----- | -------------------- |
| 555  | r-x    | r-x      | r-x    | 全てにWrite権限なし  |
| 666  | rw-    | rw-      | rw-    | 全てにExecut権限なし |
| 777  | rwx    | rwx      | rwx    | 全てに全権限あり     |

#### ・その他でよく使う番号

| 数字 | 所有者 | グループ | その他 | 特徴                               |
| :--: | :----- | :------- | :----- | ---------------------------------- |
| 644  | rw-    | r--      | r--    | 所有者以外にWrite，Execute権限なし |
| 755  | rwx    | r-x      | r-x    | 所有者以外にWrite権限なし          |

<br>

### cp

#### ・-Rp

ディレクトリの属性情報も含めて，ディレクトリ構造とファイルを再帰的にコピー．

```bash
$ cp -Rp /<ディレクトリ名1>/<ディレクトリ名2> /<ディレクトリ名1>/<ディレクトリ名2>
```

```bash
# 隠しファイルも含めて，ディレクトリの中身を他のディレクトリ内にコピー
# 「アスタリスク」でなく「ドット」にする
$ cp -Rp /<ディレクトリ名>/ /<ディレクトリ名> 
```

#### ・-p

『ファイル名.YYYYmmdd』の形式でバックアップファイルを作成

```bash
$ cp -p <ファイル名> <ファイル名>.`date +"%Y%m%d"`
```

<br>

### echo

#### ・オプション無し

定義されたシェル変数を出力する．変数名には```$```マークを付ける．ダブルクオートはあってもなくてもよい．

```bash
$ <変数名>=<値>

$ echo $<変数名>

$ echo "$<変数名>"
```

<br>

### file

#### ・オプション無し

ファイルの改行コードを確認する．

```bash
# LFの場合（何も表示されない）
$ file foo.txt
foo.txt: ASCII text

# CRLFの場合
$ file foo.txt
foo.txt: ASCII text, with CRLF line terminators

# CRの場合
$ file foo.txt
foo.txt: ASCII text, with CR line terminators<br>
```

<br>

### find

#### ・-type

ファイルを検索するためのユーティリティ．アスタリスクを付けなくとも，自動的にワイルドカードが働く．

```bash
$ find /* -type f | xargs grep "<検索文字>"
```

```bash
# パーミッションエラーなどのログを破棄して検索．
$ find /* -type f | xargs grep "<検索文字>" 2> /dev/null
```

#### ・-name

名前が .conf で終わるファイルを全て検索する．

```bash
$ find /* -name "*.conf" -type f
```

名前が dir で終わるディレクトリを全て検索する．

```bash
$ find /* -name "*dir" -type d
```

ルートディレクトリ以下で， <検索文字> という文字をもち，ファイル名が .conf で終わるファイルを全て検索する．

```bash
$ find /* -name "*.conf" -type f | xargs grep "<検索文字>"
```

<br>

### ln

####  ・シンボリックリンクとは

ファイルやディレクトリのショートカットのこと．シンボリックリンクに対する処理は，リンク元のファイルやディレクトリに転送される．

#### ・-s

カレントディレクトリに，シンボリックリンクを作成する．リンクの元になるディレクトリやファイルのパスを指定する．

```bash
$ ln -s <リンク元までのパス> <シンボリックリンク名> 
```

<br>

### ls

#### ・-l，-a

隠しファイルや隠しディレクトリも含めて，全ての詳細を表示する．

```bash
$ ls -l -a
```

<br>

### mkdir

#### ・-p

複数階層のディレクトリを作成する．

```bash
$ mkdir -p /<ディレクトリ名1>/<ディレクトリ名2>
```

<br>

### rm

#### ・-R

ディレクトリ自体と中のファイルを再帰的に削除する．

```bash
$ rm -R <ディレクトリ名> 
```

<br>

### od：octal dump

#### ・オプション無し

ファイルを8進数の機械語で出力する．

```bash
$ od <ファイル名>
```

#### ・-Ad，-tx

ファイルを16進数の機械語で出力する．

```bash
$ od -Ad -tx <ファイル名>
```

<br>

### set

#### ・オプション無し

現在設定されているシェル変数を一覧で表示する．

```bash
$ set
```

#### ・-n

シェルスクリプトの構文解析を行う．

```bash
$ set -n
```

#### ・-e

一連の処理の途中で```0```以外の終了ステータスが出力された場合，全ての処理を終了する．

```bash
$ set -e
```

#### ・-x

一連の処理をデバッグ情報として出力する．

```bash
$ set -x
```

#### ・-u

一連の処理の中で，未定義の変数が存在した場合，全ての処理を終了する．

```bash
$ set -u
```

#### ・-o pipefail

パイプライン（```|```）内の一連の処理の途中で，エラーが発生した場合，その終了ステータスを出力し，全ての処理を終了する．

```bash
$ set -o pipefail
```

<br>

### tar

#### ・-x

圧縮ファイルを解凍する．

```bash
$ tar -xf foo.tar.gz
```

#### ・-f

圧縮ファイル名を指定する．これを付けない場合，テープドライブが指定される．

```bash
$ tar -xf foo.tar.gz
```

#### ・-v

解凍中のディレクトリ／ファイルの生成ログを表示する．

```bash
$ tar -xvf foo.tar.gz

./
./opt/
./opt/foo/
./opt/foo/bar/
./opt/foo/bar/install.sh
./opt/foo/bar/baz/
./opt/foo/bar/baz/init.sh
```

#### ・-g

gzip拡張子の圧縮ファイルを解凍する．ただし，標準で有効になっているため，オプションは付けないくても問題ない．

```bash
$ tar -zxf foo.tar.gz
```

<br>

### unlink

#### ・オプション無し

カレントディレクトリのシンボリックリンクを削除する．

```bash
$ unlink <シンボリックリンク名>
```

<br>

## 02-04. ネットワーク系

### curl

#### ・-o（小文字）

インストール後のファイル名を定義する．これを指定しない場合，```-O```オプションを有効化する必要がある．

```bash
$ curl -o <ファイル名> http://example.com/foo  
```

#### ・-O（大文字）

インストール後のファイル名はそのままでインストールする．これを指定しない場合，```-o```オプションを有効化する必要がある．

#### ・-L

指定したURLでリダイレクトが行われても，リダイレクト後のURLからファイルをインストールする．

```bash
$ curl -L http://example.com/foo
```

<br>

### ssh：secure shell

#### ・-l，-p，<ポート>，-i，-T

事前に，秘密鍵の権限は「600」にしておく．tty（擬似ターミナル）を使用する場合は，```-T```オプションをつける．

```bash
$ ssh -l <サーバのユーザ名>@<サーバのホスト名> -p 22 -i <秘密鍵のパス> -T
```

#### ・-l，-p，<ポート>，-i，-T，-vvv

```bash
# -vvv：ログを出力する
$ ssh -l <サーバのユーザ名>@<サーバのホスト名> -p 22 -i <秘密鍵のパス> -T -vvv
```

#### ・設定ファイル（```~/.ssh/config```）

設定が面倒な```ssh```コマンドのオプションの引数を，```~/.ssh/config```ファイルに記述しておく．

```bash
# サーバ１
Host <接続名1>
    User <サーバ１のユーザ名>
    Port 22
    HostName <サーバ１のホスト名>
    IdentityFile <秘密鍵へのパス>

# サーバ２
Host <接続名２>
    User <サーバ２のユーザ名>
    Port 22
    HostName <サーバ２のホスト名>
    IdentityFile <秘密へのパス>
```

これにより，コマンド実行時の値渡しを省略できる．tty（擬似ターミナル）を使用する場合は，-Tオプションをつける．

```bash
# 秘密鍵の権限は，事前に「600」にしておく
$ ssh <接続名> -T
```

<br>

## 02-05. プロセス系

### ps： process status

#### ・aux

稼働しているプロセスの詳細情報を表示するためのユーティリティ．

```bash
# 稼働しているプロセスのうち，詳細情報に「xxx」を含むものを表示する．
$ ps aux | grep "<検索文字>"
```

<br>

### systemctl：system control（旧service）

#### ・systemctlとは

デーモンを起動するsystemdを制御するためのユーティリティ．

#### ・list-unit-files

デーモンのUnitを一覧で確認する．

```bash
$ systemctl list-unit-files --type=service

crond.service           enabled  # enable：自動起動する
supervisord.service     disabled # disable：自動起動しない
systemd-reboot.service  static   # enable：他サービス依存
```

#### ・enable

マシン起動時にデーモンが自動起動するように設定する．

```bash
$ systemctl enable <プロセス名>

# 例：Cron，Apache
$ systemctl enable crond.service
$ systemctl enable httpd.service
```
#### ・disable

マシン起動時にデーモンが自動起動しないように設定する．

```bash
$ systemctl disable <プロセス名>

# 例：Cron，Apache
$ systemctl disable crond.service
$ systemctl disable httpd.service
```

#### ・systemd：system daemon のUnitの種類

各デーモンを，```/usr/lib/systemd/system```や```/etc/systemd/system```下でUnit別に管理し，Unitごとに起動する．Unitは拡張子の違いで判別する．

| Unitの拡張子 | 意味                                       | デーモン例         |
| ------------ | ------------------------------------------ | ------------------ |
| mount        | ファイルのマウントに関するデーモン．       |                    |
| service      | プロセス起動停止に関するデーモン．         | httpd：http daemon |
| socket       | ソケットとプロセスの紐づけに関するデーモン |                    |

### kill

#### ・-9

指定したPIDのプロセスを削除する．

```bash
$ kill -9 <プロセスID（PID）>
```

指定したコマンドによるプロセスを全て削除する．

```bash
$ sudo pgrep -f <コマンド名> | sudo xargs kill -9
```

<br>

### cron

#### ・cronとは

指定したスケジュールに従って，指定されたプログラムを定期実行する常駐プログラム．

#### ・cronファイル

| ファイル名<br>ディレクトリ名 | 利用者 | 主な用途                                               |
| ---------------------------- | ------ | ------------------------------------------------------ |
| /etc/crontab                 | root   | 毎時，毎日，毎月，毎週の自動タスクのメイン設定ファイル |
| /etc/cron.hourly             | root   | 毎時実行される自動タスク設定ファイルを置くディレクトリ |
| /etc/cron.daily              | root   | 毎日実行される自動タスク設定ファイルを置くディレクトリ |
| /etc/cron.monthly            | root   | 毎月実行される自動タスク設定ファイルを置くディレクトリ |
| /etc/cron.weekly             | root   | 毎週実行される自動タスク設定ファイルを置くディレクトリ |


**＊実装例＊**

1. あらかじめ，各ディレクトリにcronファイルを配置しておく．
2. cronとして登録するファイルを作成する．```run-parts```コマンドで，指定した時間に，各cronディレクトリ内のcronファイルを一括で実行するように記述しておく．

```bash
# 設定
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO="hasegawafeedshop@gmail.com"
LANG=ja_JP.UTF-8
LC_ALL=ja_JP.UTF-8
CONTENT_TYPE=text/plain; charset=UTF-8

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed

# run-parts
1 * * * * root run-parts /etc/cron.hourly # 毎時・1分
5 2 * * * root run-parts /etc/cron.daily # 毎日・2時5分
20 2 * * 0 root run-parts /etc/cron.weekly # 毎週日曜日・2時20分
40 2 1 * * root run-parts /etc/cron.monthly # 毎月一日・2時40分
@reboot make clean html # cron起動時に一度だけ
```


#### ・cron.dファイル

複数のcronファイルで全ての一つのディレクトリで管理する場合に用いる．

| ディレクトリ名 | 利用者 | 主な用途                                           |
| -------------- | ------ | -------------------------------------------------- |
| /etc/cron.d    | root   | 上記以外の自動タスク設定ファイルを置くディレクトリ |

#### ・supervisorとの組み合わせ

ユーザーが，OS上のプロセスを制御できるようにするためのプログラム．

```bash
# インストール
$ pip3 install supervisor
```

```bash
# /etc/supervisor/supervisord.conf に設定ファイルを置いて起動．
$ /usr/local/bin/supervisord
```

以下に設定ファイルの例を示す．

**＊実装例＊**

```bash
[supervisord]
# 実行ユーザ
user=root
# フォアグラウンドで起動
nodaemon=true
# ログ
logfile=/var/log/supervisord.log
# Pid
pidfile=/var/tmp/supervisord.pid

[program:crond]
# 実行コマンド
command=/usr/sbin/crond -n
# プログラムの自動起動
autostart=true
# プログラム停止後の再起動
autorestart=true
# コマンドの実行ログ
stdout_logfile=/var/log/command.log
stderr_logfile=/var/log/command-error.log
# コマンドの実行ユーザ
user=root
# コマンドの実行ディレクトリ
directory=/var/www/tech-notebook
```

<br>

### crontab

#### ・crontabとは

cronデーモンの動作が定義されたcrontabファイルを操作するためのユーティリティ．

#### ・オプション無し

作成したcronファイルを登録する．cron.dファイルは操作できない．

```bash
$ crontab <ファイルパス>
```

#### ・登録されたcronファイルの処理を確認

```bash
$ crontab -l

# crontabコマンドで登録されたcronファイルの処理
1 * * * * rm foo
```

#### ・cronファイルの登録手順

**＊実装例＊**

１. 拡張子は自由で，時刻とコマンドが実装されたファイルを用意する．この時，最後に改行がないとエラー（```premature EOF```）になるため，改行を追加する．

参考：

```bash
# cron-hourly.txt
# 毎時・1分
1 * * * * root run-parts /etc/cron.hourly

```

```bash
# cron-daily.txt
# 毎日・2時5分
5 2 * * * root run-parts /etc/cron.daily

```

```bash
# cron-monthly.txt
# 毎週日曜日・2時20分
20 2 * * 0 root run-parts /etc/cron.weekly

```

```bash
# cron-weekly.txt
# 毎月一日・2時40分
40 2 1 * * root run-parts /etc/cron.monthly

```

```bash
# cron起動時に一度だけ
@reboot make clean html

```

２. このファイルをcrontabコマンドで登録する．cronファイルの実体はないことと，ファイルの内容を変更した場合は登録し直さなければいけないことに注意する．

```bash
$ crontab /foo/cron-hourly.txt
```

３. 登録されている処理を確認する．

```bash
$ crontab -l

1 * * * * root run-parts /etc/cron.hourly
```

４. ログに表示されているかを確認．

```bash
$ cd /var/log

$ tail -f cron
```

５. 改行コードを確認．改行コードが表示されない場合はLFであり，問題ない．

```bash
$ file /foo/cron-hourly.txt

foo.txt: ASCII text
```

<br>

### crond

#### ・crondとは

cronデーモンを起動するためのプログラム

#### ・-n

フォアグラウンドプロセスとしてcronを起動

```bash
$ crond -n
```

<br>

## 02-06. テキスト処理系

### vim：Vi Imitaion，Vi Improved  

#### ・オプション無し

vim上でファイルを開く．

```bash
$ vim <ファイル名>
```

<br>

### history

#### ・オプション無し

履歴1000件の中からコマンドを検索する．

```bash
$ history | grep <過去のコマンド>
```

<br>

### tr

```bash
#!/bin/bash

cat ./src.txt | tr "\n" "," > ./dst.txt
```

<br>

## 02-07. 環境変数系


### export

#### ・オプション無し

基本的な手順としては，シェル変数を設定し，これを環境変数に追加する．

```bash
# シェル変数を設定
$ PATH=$PATH:<バイナリファイルへのあるディレクトリへの絶対パス>
# 環境変数に追加
$ export PATH
```

シェル変数の設定と，環境変数への追加は，以下の通り同時に記述できる．

```bash
# 環状変数として，指定したバイナリファイル（bin）のあるディレクトリへの絶対パスを追加．
# バイナリファイルを入力すると，絶対パス
$ export PATH=$PATH:<バイナリファイルへのあるディレクトリへの絶対パス>
```

```bash
# 不要なパスを削除したい場合はこちら
# 環状変数として，指定したバイナリファイル（bin）のあるディレクトリへの絶対パスを上書き
$ export PATH=/sbin:/bin:/usr/sbin:/usr/bin
```

#### ・```.bashrc```への追記


exportの結果は，OSの再起動で初期化されてしまう．そのため，再起動時に自動的に実行されるよう，```/home/centos/.bashrc```に追記しておく．

```bash
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# xxxバイナリファイルのパスを追加 を追加 <--- ここに追加
PATH=$PATH:/usr/local/sbin/xxxx

export PATH

# Uncomment the following line if you don"t like systemctl"s auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
```

<br>

### printenv

#### ・オプション無し

全ての環境変数を表示する．

```bash
$ printenv
```

また，特定の環境変数を表示する．

```bash
$ printenv VAR
```

<br>

### timedatactl

#### ・set-timezone

```bash
# タイムゾーンを日本時間に変更
$ timedatectl set-timezone Asia/Tokyo

# タイムゾーンが変更されたかを確認
$ date
```

<br>

## 02-08. ハードウェア系


### top

#### ・オプション無し

各プロセスの稼働情報（ユーザ名，CPU，メモリ）を確認する． CPU使用率昇順に並べる

```bash
$ top
```

#### ・-a

メモリ使用率昇順に並べる．

```bash
$ top -a
```

<br>

### free

#### ・-m，-total

物理メモリ，スワップ領域，の使用状況をメガバイトで確認する．

```bash
# m：Mega Bytes
# t: -total
$ free -m -total
```

<br>

### df

#### ・-h，-m，-t

ストレージの使用状況をメガバイトで確認する．

```bash
# h：--human-readable
# t: -total
$ df -h -m -t
```

<br>

### mkswap，swapon，swapoff

#### ・スワッピング方式

物理メモリのアドレス空間管理の方法の一つ．ハードウェアのノートを参照．

![スワッピング方式](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/スワッピング方式.png)

#### ・スワップ領域の作成方法

```bash
# 指定したディレクトリをスワップ領域として使用
$ mkswap /swap_volume
```
```bash
# スワップ領域を有効化
# 優先度のプログラムが，メモリからディレクトリに，一時的に退避されるようになる
$ swapon /swap_volume
```
```bash
# スワップ領域の使用状況を確認
$ swapon -s
```
```bash
# スワップ領域を無効化
$ swapoff /swap_volume
```

<br>

##  03. 管理ユーティリティ

### 管理ユーティリティの種類

#### ・管理ユーティリティの対象

様々なレベルを対象にした管理ユーティリティがある．

![ライブラリ，パッケージ，モジュールの違い](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ライブラリ，パッケージ，モジュールの違い.png)

#### ・ライブラリ管理ユーティリティ

| ユーティリティ名                  | 対象プログラミング言語 |
| --------------------------------- | ---------------------- |
| composer.phar：Composer           | PHP                    |
| pip：Package Installer for Python | Python                 |
| npm：Node Package Manager         | Node.js                |
| maven：Apache Maven               | Java                   |
| gem：Ruby Gems                    | Ruby                   |

#### ・パッケージ管理ユーティリティ

| ユーティリティ名                                        | 対象OS       | 依存関係のインストール可否 |
| ------------------------------------------------------- | ------------ | -------------------------- |
| Rpm：Red Hat Package Manager                            | RedHat系     | ✕                          |
| Yum：Yellow dog Updater Modified<br/>DNF：Dandified Yum | RedHat系     | 〇                         |
| Apt：Advanced Packaging Tool                            | Debian系     | 〇                         |
| Apk：Alpine Linux package management                    | Alpine Linux | 〇                         |

#### ・言語バージョン管理ユーティリティ

| ユーティリティ名 | 対象プログラミング言語 |
| ---------------- | ---------------------- |
| phpenv           | PHP                    |
| pyenv            | Python                 |
| rbenv            | Ruby                   |

<br>

## 03-02. ライブラリ管理ユーティリティ

### pip

#### ・install

指定したライブラリをインストールする．

```bash
# /usr/local 以下にインストール
$ pip install --user <ライブラリ名>
```
```bash
# requirements.txt を元にライブラリをインストール
$ pip install -r requirements.txt

# 指定したディレクトリにライブラリをインストール
pip install -r requirements.txt　--prefix=/usr/local
```

#### ・freeze

pipでインストールされたパッケージを元に，要件ファイルを作成する．

```bash
$ pip freeze > requirements.txt
```

#### ・show

pipでインストールしたパッケージ情報を表示する．

```bash
$ pip show sphinx

Name: Sphinx
Version: 3.2.1
Summary: Python documentation generator
Home-page: http://sphinx-doc.org/
Author: Georg Brandl
Author-email: georg@python.org
License: BSD
# インストール場所
Location: /usr/local/lib/python3.8/site-packages
# このパッケージの依存対象
Requires: sphinxcontrib-applehelp, imagesize, docutils, sphinxcontrib-serializinghtml, snowballstemmer, sphinxcontrib-htmlhelp, sphinxcontrib-devhelp, sphinxcontrib-jsmath, setuptools, packaging, Pygments, babel, alabaster, sphinxcontrib-qthelp, requests, Jinja2
# このパッケージを依存対象としているパッケージ
Required-by: sphinxcontrib.sqltable, sphinx-rtd-theme, recommonmark
```

<br>

### npm

#### ・入手方法

```bash
# リポジトリの作成
$ curl -sL https://rpm.nodesource.com/setup_<バージョン>.x | bash -

# nodejsのインストールにnpmも含まれる
$ yum install nodejs
```

#### ・init

package.jsonを生成する．

```bash
$ npm init
```

#### ・install

ディレクトリにパッケージをインストール

```bash
# ローカルディレクトリにパッケージをインストール
$ npm install <パッケージ名>
```

```bash
# グローバルディレクトリにインストール（あまり使わない）
$ npm install -g <パッケージ名>
```

<br>

## 03-03. パッケージ管理ユーティリティ

### rpm

#### ・-ivh

パッケージをインストールまたは更新する．一度に複数のオプションを組み合わせて記述する．インストール時にパッケージ間の依存関係を解決できないので注意．

```bash
# パッケージをインストール
# -ivh：--install -v --hash 
$ rpm -ivh <パッケージ名>
```

```bash
# パッケージを更新
# -Uvh：--upgrade -v --hash 
$ rpm -Uvh <パッケージ名>
```

#### ・-qa

インストールされた全てのパッケージの中で，指定した文字を名前に含むものを表示する．

```bash
# -qa：
$ rpm -qa | grep <検索文字>
```

#### ・-ql

指定したパッケージ名で，関連する全てのファイルの場所を表示する．

```bash
# -ql：
$ rpm -ql <パッケージ名>
```

#### ・-qi

指定したパッケージ名で，インストール日などの情報を表示する．

```bash
# -qi：
$ rpm -qi <パッケージ名>
```

<br>

### yum，dnf

#### ・install，reinstall

rpmと同様の使い方ができる．また，インストール時にパッケージ間の依存関係を解決できる．

```bash
# パッケージをインストール
$ yum install -y <パッケージ名>

# 再インストールする時は，reinstallとすること
$ yum reinstall -y <パッケージ名>
```

#### ・list

インストールされた全てのパッケージを表示する．

```bash
# 指定した文字を名前に含むものを表示．
$ yum list | grep <検索文字>
```

#### ・EPELリポジトリ，Remiリポジトリ

CentOS公式リポジトリはパッケージのバージョンが古いことがある．そこで，```--enablerepo```オプションを使用すると，CentOS公式リポジトリではなく，最新バージョンを扱う外部リポジトリ（EPEL，Remi）から，パッケージをインストールできる．外部リポジトリ間で依存関係にあるため，両方のリポジトリをインストールする必要がある．

1. CentOSのEPELリポジトリをインストール．インストール時の設定ファイルは，/etc/yu.repos.d/* に配置される．

```bash
# CentOS7系の場合
$ yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# CentOS8系の場合
$ dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

# こちらでもよい
$ yum install -y epel-release でもよい
```
2. CentOSのRemiリポジトリをインストール．RemiバージョンはCentOSバージョンを要確認．インストール時の設定ファイルは，```/etc/yu.repos.d/*```に配置される．

```bash
# CentOS7系の場合
$ yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm

# CentOS8系の場合
$ dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
```

4. 設定ファイルへは，インストール先のリンクなどが自動的に書き込まれる．

```bash
[epel]
name=Extra Packages for Enterprise Linux 6 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
failovermethod=priority
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 6 - $basearch - Debug
#baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch/debug
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-6&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 6 - $basearch - Source
#baseurl=http://download.fedoraproject.org/pub/epel/6/SRPMS
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-source-6&arch=$basearch
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
gpgcheck=1
```

5. Remiリポジトリの有効化オプションを永続的に使用できるようにする．

```bash
# CentOS7の場合
$ yum install -y yum-utils
# 永続的に有効化
$ yum-config-manager --enable remi-php74


# CentOS8の場合（dnf moduleコマンドを使用）
$ dnf module enable php:remi-7.4
```

6. remiリポジトリを指定して，php，php-mbstring，php-mcryptをインストールする．Remiリポジトリを経由してインストールしたソフトウェアは```/opt/remi/*```に配置される．

```bash
# CentOS7の場合
# 一時的に有効化できるオプションを利用して，明示的にremiを指定
$ yum install --enablerepo=remi,remi-php74 -y php php-mbstring php-mcrypt


# CentOS8の場合
# リポジトリの認識に失敗することがあるのでオプションなし
$ dnf install -y php php-mbstring php-mcrypt
```

7. 再インストールする時は，reinstallとすること．

```bash
# CentOS7の場合
# 一時的に有効化できるオプションを利用して，明示的にremiを指定
$ yum reinstall --enablerepo=remi,remi-php74 -y php php-mbstring php-mcrypt


# CentOS8の場合
# リポジトリの認識に失敗することがあるのでオプションなし
$ dnf reinstall -y php php-mbstring php-mcrypt
```

<br>

## 03-04. 言語バージョン管理ユーティリティ

### pyenv

#### ・which

```bash
# pythonのインストールディレクトリを確認
$ pyenv which python
/.pyenv/versions/3.8.0/bin/python
```
