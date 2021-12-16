# dockerコマンド

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Dockerの構成要素

### 全体像

参考：https://www.slideshare.net/zembutsu/docker-underlying-and-containers-lifecycle

![docker-daemon](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/docker-daemon.png)

<br>

### dockerクライアント
    
#### ・dockerクライアントとは

dockerクライアントは、dockerコマンドを使用してdockerデーモンAPIをコールできる。

<br>

### dockerデーモン

#### ・dockerデーモンとは

ホスト側で稼働し、コンテナの操作を担う常駐プログラム。dockerクライアントにdockerデーモンAPIを公開する。クライアントがdockerコマンドを実行すると、dockerデーモンAPIがコールされ、コマンドに沿ってコンテナが操作される。

<br>

## 02. コマンド

### attach

#### ・オプション無し

**＊コマンド例＊**

デタッチドモードを用いて、起動中コンテナに接続する。

```bash
$ docker attach <起動中コンテナ名>
```

<br>

### build

#### ・-force-rm、--no-cache

**＊コマンド例＊**

キャッシュ無しで、指定のDockerfileを基に、イメージをビルドする。失敗した時は削除するように、```--force-rm```オプションを有効化する。

```bash
$ docker build --file Dockerfile --tag <イメージ名>:<バージョン> --force-rm=true --no-cache .
```

<br>

### commit

#### ・オプション無し

停止中コンテナからイメージを作成する。

**＊コマンド例＊**

```bash
$ docker commit <停止中コンテナ名> <コンテナID>

$ docker commit <停止中コンテナ名> <Docker Hubユーザ名>/<イメージ名>:<バージョン>
```

<br>

### container

#### ・prune

停止中コンテナのみを全て削除する。

**＊コマンド例＊**

```bash
$ docker container prune
```

<br>

### cp

#### ・オプション無し

Dockerfileの```COPY```コマンドを用いてコンテナ内に配置しているファイルに関して、変更のたびにイメージをビルドを行うことは面倒のため、ホストからコンテナにコピーし、再読み込みを行う。ただし、コンテナを再構築すると元に戻ってしまうことに注意。

**＊コマンド例＊**

```bash
# ホスト側のファイルをコンテナにコピー
$ docker cp ./docker/www/nginx.conf <コンテナID>:/etc/nginx/nginx.conf

# コンテナに接続後に、nginxの設定ファイルを再読み込み。
$ docker exec -it <コンテナ名> bin/bash # もしくはbin/sh
[root@<ホスト名>:~] $ nginx -s reload
[root@<ホスト名>:~] $ exit

# アクセスログを確認
$ docker logs <コンテナ名>
```

<br>

### create

#### ・オプション無し

**＊コマンド例＊**

コンテナレイヤーを生成し、コンテナを構築。起動はしない。

```bash
$ docker create <コンテナ名> <使用イメージ名>:<タグ>
```

<br>

### exec

#### ・-it

**＊コマンド例＊**

デタッチドモードを用いて、起動中コンテナ内でコマンドを実行する。実行するコマンドが```bash```や```bash```の場合、コンテナに接続できる。

```bash
# i：interactive、t：tty（対話モード）
$ docker exec -it <起動中コンテナ名> /bin/bash

# イメージ内に/bin/bash がない場合
$ docker exec -it <起動中コンテナ名> /bin/sh
```

#### ・attach、execの違い

まず```attach```コマンドでは、起動中コンテナに接続する。```exit```コマンドを用いて、コンテナとの接続を切断した後、コンテナが停止してしまう。

```bash
# デタッチドモードによる起動
$ docker run -d -it --name <コンテナ名> <使用イメージ名>:<タグ> /bin/bash

# デタッチドモードによって起動中コンテナに接続
$ docker attach <起動中コンテナ名>

# PID=1で、1つの/bin/bashプロセスが稼働していることを確認できる
[root@<ホスト名>:~] ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  16152  3872 pts/0    Ss+  18:06   0:00 /bin/bash
root        33  0.0  0.1  45696  3732 pts/1    R+   18:22   0:00 ps aux

# コンテナとの接続を切断
[root@<ホスト名>:~] exit

# コンテナの状態を確認
$ docker container ps -a --no-trunc # ==> コンテナのSTATUSがEXITedになっている
```

一方で```exec```コマンドでは、起動中コンテナでコマンドを実行する。実行するコマンドが```bash```や```bash```の場合、コンテナに接続できる。```exit```コマンドを用いて、コンテナとの接続を切断した後でも、コンテナが起動し続ける。

```bash
# デタッチドモードによる起動
$ docker run -d -it --name <コンテナ名> <使用イメージ名>:<タグ> /bin/bash

# 対話モードを用いて、デタッチドモードによって起動中コンテナに接続
$ docker exec -it <起動中コンテナ名> /bin/bash # もしくはbin/sh

# PID=1,17で、2つの/bin/bashプロセスが稼働していることを確認できる
[root@<ホスト名>:~] ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  16152  3872 pts/0    Ss+  18:06   0:00 /bin/bash
root        17  0.0  0.1  16152  4032 pts/1    Ss   18:21   0:00 /bin/bash
root        34  0.0  0.1  45696  3732 pts/1    R+   18:22   0:00 ps aux

# コンテナとの接続を切断
[root@<ホスト名>:~] exit

# コンテナの状態を確認
$ docker container ps -a --no-trunc # ==> コンテナのSTATUSがUPになっている
```



<br>

### search

#### ・オプション無し

**＊コマンド例＊**

レジストリ側に保管されているイメージを検索する。

```bash
$ docker search <イメージ名>
```

<br>

### images

#### ・オプション無し

**＊コマンド例＊**

ホストにインストールされたイメージを確認する。

```bash
$ docker images
```

#### ・prune

**＊コマンド例＊**

コンテナに使用されていないイメージを一括で削除

```bash
$ docker image prune
```

#### ・rmi

**＊コマンド例＊**

タグ名のないイメージのみを全て削除する。

```bash
$ docker rmi --force $(sudo docker images --filter "dangling=true" --all --quiet)
```

<br>

### inspect

#### ・オプション無し

**＊コマンド例＊**

起動中コンテナの全ての設定内容を表示する。```grep```とも組み合わせられる。

```bash
$ docker inspect <起動中コンテナ名>

$ docker inspect <起動中コンテナ名> | grep IPAddress
```

**＊コマンド例＊**

json-fileドライバーを用いている時に、ログファイルの出力先を確認する。

```bash
 $ docker inspect <起動中コンテナ名> | grep 'LogPath'
 
 "LogPath": "/var/lib/docker/containers/*****-json.log",
```

<br>

### network

#### ・ls

**＊コマンド例＊**

```bash
$ docker network ls

NETWORK ID          NAME                    DRIVER              SCOPE
ae25b9b7740b        bridge                  bridge              local
aeef782b227d        tech-notebook_default   bridge              local
```

#### ・prune

```bash
$ docker network prune
```

#### ・inspect

複数のコンテナが起動している時に、コンテナがいずれのネットワークを用いているかを確認する。

```bash
$ docker network inspect <ネットワーク名>
```

<br>

### ps

#### ・-a

**＊コマンド例＊**

コンテナの起動と停止にかかわらず、IDなどを一覧で表示。

```bash
$ docker ps -a
```

<br>

### pull

**＊コマンド例＊**

レジストリ側のイメージをクライアント側にインストールする。

```bash
$ docker pull <イメージ名>:<バージョン>
```

<br>

### push

#### ・オプション無し

**＊コマンド例＊**

ホストで作成したイメージを、指定したDockerHubのユーザにアップロードする。

```bash
$ docker push <Docker Hubユーザ名>/<イメージ名>:<バージョン>
```

**＊コマンド例＊**

ホストで作成したイメージを、指定したECRにアップロードする。ECRはタグ名がやや特殊のため、事前にタグを付け替える必要がある。

```bash
$ docker tag <ローカル上でのイメージ名>:<ローカル上でのバージョン> <リポジトリURL>/<ECR上でのイメージ名>:<ECR上でのバージョン>

$ docker push <リポジトリURL>/<ECR上でのイメージ名>:<ECR上でのバージョン>
```

<br>

### rm

#### ・--force

**＊コマンド例＊**

起動中／停止中の全てコンテナを強制的に削除する。

```bash
$ docker rm --force $(docker ps --all --quiet)
```

<br>

### run

#### ・--hostname

コンテナ内の```etc/hosts```ファイルで、コンテナのプライベートIPアドレスを確認できる。```hostname```オプションで命名していればその名前、指定していなければランダムな文字列が割り当てられる。

**＊コマンド例＊**

```bash
$ docker run -d -it --hostname <ホスト名> --name <コンテナ名> --publish=8080:80 <用いるイメージ名>:<タグ> /bin/bash
$ docker exec -it <起動中コンテナ名> /bin/bash

[root@<ホスト名>:/] cat /etc/hosts

127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
172.18.0.2	<ホスト名>
```

#### ・--publish

指定したホストポートとコンテナポートのマッピングを実行する。```--publish-all```オプションではホストポートをランダムに選んでポートマッピングを実行する。

参考：https://www.whitesourcesoftware.com/free-developer-tools/blog/docker-expose-port/

```bash
$ docker run -d -it --name <コンテナ名> --publish=8080:80 <用いるイメージ名>:<タグ> /bin/bash
```

#### ・--expose

コンテナポート公開を```expose```オプションで設定できる。これはDockerfileでEXPOSE命令として設定してもよい。なお、プロセスのリッスンするポートと合わせる必要がある。

参考：https://www.whitesourcesoftware.com/free-developer-tools/blog/docker-expose-port/

```bash
$ docker run -d -it --name <コンテナ名> --expose=80 <用いるイメージ名>:<タグ> /bin/bash
```

#### ・-a、-d

すでに停止中または起動中コンテナが存在していても、これとは別にコンテナを新しく構築し、起動する。さらにそのコンテナ内でコマンドを実行する。起動時に```bash```プロセスや```bash```プロセスを実行すると、コンテナに接続できる。何も渡さない場合は、デフォルトのプロセスとして```bash```プロセスが実行される。```run```コマンドでは、アタッチモードとデタッチモードを選ぶことができる。新しく起動したコンテナを停止後に自動削除する場合は、```rm```オプションを付けるようにする。

**＊コマンド例＊**

```bash
# アタッチモードによる起動。フォアグラウンドで起動する。
$ docker run -a -it --rm --name <コンテナ名> <使用イメージ名>:<タグ> /bin/bash

# デタッチドモードによる起動。バックグラウンドで起動する。
$ docker run -d -it --rm --name <コンテナ名> <使用イメージ名>:<タグ> /bin/bash
```

コンテナを起動する時に、```bash```プロセスを実行すると以下のようなエラーが出ることがある。その場合は、```bash```プロセスを実行するようにする。

```bash
docker: Error response from daemon: OCI runtime create failed: container_linux.go:370: starting container process caused: exec: "/bin/bash": stat /bin/bash: no such file or directory: unknown.
```

アタッチモードは、フォアグラウンド起動である。ターミナルにプロセスのログが表示されないため、同一ターミナルで他のコマンドを入力できる。

**＊コマンド例＊**

```bash
# -a：atattch mode
$ docker run -a -it --name <コンテナ名> <使用イメージ名>:<タグ> /bin/bash
```

デタッチドモードは、バックグラウンド起動である。ターミナルにプロセスのログが表示され続けるため、同一ターミナルで他のコマンドを入力できない。プロセスのログを監視できるが、他のプロセスを入力するためには、そのターミナル上でコンテナを停止させる必要がある。

**＊コマンド例＊**


```bash
# -d；detached mode
$ docker run -d -it --name <コンテナ名> <使用イメージ名>:<タグ> /bin/bash
```

<br>

### start

コンテナを起動する。```start```コマンドでは、アタッチモードによる起動しかできない。

**＊コマンド例＊**

停止中コンテナをアタッチモードによって起動する。

```bash
$ docker start -i <停止中コンテナ名>
```

<br>

### stop

#### ・オプション無し

**＊コマンド例＊**

起動中コンテナを停止する。

```bash
$ docker stop <起動中コンテナ名>
```

**＊コマンド例＊**

全てのコンテナを停止する。

```bash
$ docker stop $(docker ps --all --quiet)
```

<br>

### volume

#### ・create

ボリュームマウントを作成する。dockerコマンドではなく、docker-composeコマンドで作成することが推奨されている。

**＊コマンド例＊**

ホスト側のdockerエリアにボリュームを作成

```bash
$ docker volume create <ボリューム名>
```

#### ・ls

**＊コマンド例＊**

dockerエリアのVolumeの一覧を表示

```bash
$ docker volume ls
```

#### ・rm

**＊コマンド例＊**

dockerエリアのボリュームを削除

```bash
$ docker volume rm <ボリューム名>
```

#### ・inspect

**＊コマンド例＊**

dockerエリアのVolumeの詳細を表示

```bash
$ docker volume inspect <ボリューム名>

[
    {
        "CreatedAt": "2020-09-06T15:04:02Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "<プロジェクト名>",
            "com.docker.compose.version": "1.26.2",
            "com.docker.compose.volume": "foo"
        },
        "Mountpoint": "/var/lib/docker/volumes/<プロジェクト名>_foo/_data",
        "Name": "<プロジェクト名>_foo",
        "Options": null,
        "Scope": "local"
    }
]
```

```bash
# dockerエリアをボリュームマウントして起動
# マウントポイントのボリューム名を使用
$ docker run -d -it --name <コンテナ名> /bin/bash \
  --mount type=volume, src=<ホストボリューム名> volume-driver=local, dst=<コンテナ側ディレクトリ>
```

**＊実装例＊**

Dockerfileでボリュームマウントを行う場合、マウント先のコンテナ側ディレクトリ名を設定する。dockerエリアのマウントポイントは、自動的に作成される。Docker Composeで行うことが推奨されている。

```dockerfile
FROM ubuntu
RUN mkdir /myvol
RUN echo "hello world" > /myvol/greeting

# マウント先のコンテナ側ディレクトリ名
VOLUME /myvol
```

<br>

## 03. ロギング

### log

#### ・--follow

ログを表示し続ける。ロギングドライバーが```json-file```の場合のみ有効。

```bash
$ docker logs -f <コンテナ名>
```

#### ・--tail

**＊コマンド例＊**

指定した行数だけ、ログを表示する。ロギングドライバーが```json-file```の場合のみ有効。

```bash
$ docker logs --follow=true --tail=500 <コンテナ名>
```

<br>

### --log-driver

#### ・ロギングドライバーとは

コンテナ内の標準出力（```/dev/stdout```）と標準エラー出力（```/dev/stderr```）に出力されたログを、ファイルやAPIに対して転送する。

```bash
$ docker run -d -it --log-driver <ロギングドライバー名> --name  <コンテナ名> <使用イメージ名>:<タグ> /bin/bash
```

#### ・json-file

標準出力／標準エラー出力に出力されたログを、```/var/lib/docker/containers/＜コンテナID＞/＜コンテナID＞-json.log```ファイルに転送する。デフォルトの設定値である。

```bash
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3" 
  }
}
```

#### ・fluentd

構造化ログに変換し、サイドカーとして稼働するFluentdコンテナに送信する。ECSコンテナのawsfirelensドライバーは、fluentdドライバーをラッピングしたものである。

参考：

- https://docs.docker.com/config/containers/logging/fluentd/
- https://aws.amazon.com/jp/blogs/news/under-the-hood-firelens-for-amazon-ecs-tasks/

```bash
 {
   "log-driver": "fluentd",
   "log-opts": {
     "fluentd-address": "<Fluentdコンテナのホスト名>:24224"
   }
 }
```

#### ・none

標準出力／標準エラー出力に出力されたログを、ファイルやAPIに転送しない。 ファイルに出力しないことで、開発環境のアプリケーションサイズの肥大化を防ぐ。

#### ・awslogs

標準出力／標準エラー出力に出力されたログをCloudWatch-APIに送信する。

参考：https://docs.docker.com/config/containers/logging/awslogs/

```bash
{
  "log-driver": "awslogs",
  "log-opts": {
    "awslogs-region": "us-east-1"
  }
}
```

#### ・gcplogs

標準出力／標準エラー出力に出力されたログを、Google Cloud LoggingのAPIに転送する。

参考：https://docs.docker.com/config/containers/logging/gcplogs/

```bash
{
  "log-driver": "gcplogs",
  "log-opts": {
    "gcp-meta-name": "example-instance-12345"
  }
}
```

<br>

### 各ベンダーのイメージのログ出力先

#### ・dockerコンテナの標準出力／標準エラー出力

Linuxでは、標準出力は『```/proc/<プロセスID>/fd/1```』、標準エラー出力は『```/proc/<プロセスID>/fd/2```』である。dockerコンテナでは、『```/dev/stdout```』が『```/proc/self/fd/1```』のシンボリックリンク、また『```/dev/stderr```』が『```/proc/<プロセスID>/fd/2```』のシンボリックリンクとして設定されている。

```bash
[root@*****:/dev] ls -la
total 4
drwxr-xr-x 5 root root  340 Oct 14 11:36 .
drwxr-xr-x 1 root root 4096 Oct 14 11:28 ..
lrwxrwxrwx 1 root root   11 Oct 14 11:36 core -> /proc/kcore
lrwxrwxrwx 1 root root   13 Oct 14 11:36 fd -> /proc/self/fd
crw-rw-rw- 1 root root 1, 7 Oct 14 11:36 full
drwxrwxrwt 2 root root   40 Oct 14 11:36 mqueue
crw-rw-rw- 1 root root 1, 3 Oct 14 11:36 null
lrwxrwxrwx 1 root root    8 Oct 14 11:36 ptmx -> pts/ptmx
drwxr-xr-x 2 root root    0 Oct 14 11:36 pts
crw-rw-rw- 1 root root 1, 8 Oct 14 11:36 random
drwxrwxrwt 2 root root   40 Oct 14 11:36 shm
lrwxrwxrwx 1 root root   15 Oct 14 11:36 stderr -> /proc/self/fd/2 # 標準エラー出力
lrwxrwxrwx 1 root root   15 Oct 14 11:36 stdin -> /proc/self/fd/0
lrwxrwxrwx 1 root root   15 Oct 14 11:36 stdout -> /proc/self/fd/1 # 標準出力
crw-rw-rw- 1 root root 5, 0 Oct 14 11:36 tty
crw-rw-rw- 1 root root 1, 9 Oct 14 11:36 urandom
crw-rw-rw- 1 root root 1, 5 Oct 14 11:36 zero
```

#### ・nginxイメージ

公式のnginxイメージは、```/dev/stdout```というシンボリックリンクを、```/var/log/nginx/access.log```ファイルに作成している。また、```/dev/stderr```というシンボリックリンクを、```/var/log/nginx/error.log```ファイルに作成している。これにより、これらのファイルに対するログの出力は、```/dev/stdout```と```/dev/stderr```に転送される。

参考：https://docs.docker.com/config/containers/logging/

#### ・php-fpmイメージ

要勉強。

<br>
