# Dockerfile

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. コンテナに接続するまでの手順

### 手順の流れ

1. Docker Hubから、ベースとなるイメージをインストールする。
2. Dockerfileがイメージレイヤーからなるイメージをビルド。
3. コマンドによって、イメージ上にコンテナレイヤーを生成し、コンテナを構築。
4. コマンドによって、停止中コンテナを起動。
5. コマンドによって、起動中コンテナに接続。

![Dockerfileの作成からコンテナ構築までの手順](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Dockerfileの作成からコンテナ構築までの手順.png)

<br>

## 02. Dockerfileの実装

### 記法

#### ・命令の種類

| 種類               | 処理                                                         |
| -------------------- | ------------------------------------------------------------ |
| **```ADD```**     | ```COPY```と同様にして、ホスト側のファイルを、コンテナの指定ディレクトリにコピーする。インターネットからファイルをダウンロードし、解凍も行う。イメージのビルド時にコピーされるだけで、ビルド後のコードの変更は反映されない。 |
| **```ARG```**        | Dockerfikeの命令で扱える変数を定義する。OS上のコマンド処理では扱えない。 |
| **```CMD```**        | イメージのプロセスの起動コマンドを実行。```run```コマンドの引数として、上書きできる。命令のパラメータの記述形式には、文字列形式、JSON形式がある。 |
| **```COPY```**       | ホスト側（第一引数）のディレクトリ／ファイルをコンテナ側（第二引数）にコピーする。コンテナ側のファイルパスは、```WORKDIR```をルートとした相対パスで定義できるが、絶対パスで指定した方がわかりやすい。ディレクトリ内の複数ファイルを丸ごとコンテナ内にコピーする場合は、『/』で終える必要がある。イメージのビルド時にコピーされるだけで、ビルド後のコードの変更は反映されない。```nginx.conf```ファイル、```php.ini```ファイル、などの設定ファイルをホストからコンテナにコピーしたい時によく使う。 |
| **```ENTRYPOINT```** | イメージのプロセスの起動コマンドを実行。```CMD```とは異なり、後から上書き実行できない。使用者に、コンテナの起動方法を強制させたい場合に適する。 |
| **```ENV```**        | OS上のコマンド処理で扱える変数を定義する。Dockerfileの命令では扱えない。 |
| **```EXPOSE```**     | コンテナのポートを開放する。また、イメージの利用者にとってのドキュメンテーション機能もあり、ポートマッピングを実行する時に使用可能なコンテナポートとして保証する機能もある。<br>参考：<br>・https://docs.docker.com/engine/reference/builder/#expose<br>・https://www.whitesourcesoftware.com/free-developer-tools/blog/docker-expose-port/<br><br>また加えて、プロセス自体が命令をリッスンできるようにポートを設定する必要がある。ただし、多くの場合デフォルトでこれが設定されている。（例：PHP-FPMでは、```/usr/local/etc/www.conf.default```ファイルと```/usr/local/etc/php-fpm.d/www.conf```ファイルには、```listen = 127.0.0.1:9000```の設定がある） |
| **```FROM```**       | ベースのイメージを、コンテナにインストール.            |
| **```RUN```**        | ベースイメージ上に、ソフトウェアをインストール.              |
| **```VOLUME```**     | ボリュームマウントを行う。<br>参考：https://qiita.com/namutaka/items/f6a574f75f0997a1bb1d |
| **```WORKDIR```** | ビルド中の各命令の作業ディレクトリを絶対パスで指定する。また、コンテナ接続時の最初のディレクトリも定義できる。 |

**＊実装例＊**

PHPのイメージをビルドするためのDockerfileを示す。

```dockerfile
FROM php:7.4.9-fpm as base

RUN apt-get update -y \
  && apt-get install -y \
      git \
      vim \
      unzip \
      zip \
  && docker-php-ext-install \
      bcmath \
      pdo_mysql \
  && apt-get clean

COPY --from=composer:1.10.23 /usr/bin/composer /usr/bin/composer

#===================
# Development Stage
#===================
FROM base as development
LABEL mantainer=${LABEL}

#===================
# Production Stage
#===================
FROM base as production
LABEL mantainer=${LABEL}

# 本番環境ではアプリケーションをイメージ内にコピー。
# コンテナ側のファイルパスは絶対パスの方がわかりやすい。
# ディレクトリ内の複数ファイルを丸ごとコンテナ内にコピーする場合は、『/』で終える必要がある。
COPY ./ /var/www/foo/
```

**＊実装例＊**

NginxのイメージをビルドするためのDockerfileを示す。

```dockerfile
# ベースのイメージ（CentOS）を、コンテナにインストール
FROM centos:8

# ubuntu上に、nginxをインストール
RUN yum update -y \
   && yum install -y \
     nginx

# ホスト側の設定ファイルを、コンテナ側の指定ディレクトリにコピー
# コンテナ側のファイルパスは絶対パスの方がわかりやすい。
COPY infra/docker/web/nginx.conf /etc/nginx/nginx.conf

# nginxをデーモン起動
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

# コンテナのポートを開放を明示する。これはドキュメンテーションとしての機能しかない。
EXPOSE 80
```

#### ・CMDの決め方

Dockerfileで```CMD```を指定しない場合、イメージのデフォルトのバイナリファイルが割り当てられる。一旦、デフォルトのバイナリファイルを確認した後に、これをDockerfileに明示的に実装するようにする。

```bash
CONTAINER ID   IMAGE   COMMAND     CREATED          STATUS         PORTS                    NAMES
2b2d3dfafee8   xxxxx   "/bin/sh"   11 seconds ago   Up 8 seconds   0.0.0.0:8000->8000/tcp   xxxxx
```

静的型付け言語ではプロセスの起動時に、代わりにアーティファクトのバイナリファイルを実行しても良い。その場合、```bin```ディレクトリにバイナリファイルとしてのアーティファクトを配置することになる。しかし、```bin```ディレクトリへのアクセス権限がないことがあるため、その場合は、1つ下にディレクトリを作成し、そこにバイナリファイルを置くようにする。

```bash
# /go/bin にアクセスできない時は、/go/bin/cmdにアーティファクトを置く。
ERROR: for xxx-container  Cannot start service go: OCI runtime create failed: container_linux.go:367: starting container process caused: exec: "/go/bin": permission denied: unknown

```

#### ・ENTRYPOINTの注意点

イメージのプロセスの起動コマンドを後から上書きできなくなるため、```run```コマンドの引数として新しいコマンドを渡せずに、デバッグができないことがある。

```bash
# 上書きできず、失敗してしまう。
$ docker run --rm -it <イメージ名> /bin/bash
```

#### ・ENVとARGの違い

1つ目に、```ENV```が使えて、```ARG```が使えない例。

```dockerfile
# ENVは、OS上のコマンド処理で扱える変数を定義
ARG PYTHON_VERSION="3.8.0"
RUN pyenv install ${PYTHON_VERSION}

# ARGは、OS上のコマンド処理では扱えない
ARG PYTHON_VERSION="3.8.0"
RUN pyenv install ${PYTHON_VERSION} # ===> 変数を展開できない
```

二つ目に、```ARG```が使えて、```ENV```が使えない例。

```dockerfile
# ARGは,Dockerfikeの命令で扱える変数を定義
ARG OS_VERSION="8"
FROM centos:${OS_VERSION}

# ENVは、OS上のコマンド処理では扱えない
ENV OS_VERSION "8"
FROM centos:${OS_VERSION} # ===> 変数を展開できない
```

三つ目に、これらの違いによる可読性の悪さの対策として、```ENV```と```ARG```を組み合わせた例。

```dockerfile
# 最初に全て、ARGで定義
ARG CENTOS_VERSION="8"
ARG PYTHON_VERSION="3.8.0"

# 変数展開できる
FROM centos:${OS_VERSION}

# ARGを事前に宣言
ARG PYTHON_VERSION
# 必要に応じて、事前にENVに詰め替える。
ENV PYTHON_VERSION ${PYTHON_VERSION}

# 変数展開できる
RUN pyenv install ${PYTHON_VERSION}
```

<br>

### Dockerfileを用いるメリット

Dockerfileを用いない場合、各イメージレイヤーのインストールを手動で行わなければならない。しかし、Dockerfileを用いることで、これを自動化できる。

![Dockerfileのメリット](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Dockerfileのメリット.png)

<br>

### イメージのデバッグ

**＊コマンド例＊**

ビルドに失敗したイメージからコンテナを構築し、接続する。```rm```オプションを設定し、接続の切断後にコンテナを削除する。Dockerfileにおいて、イメージのプロセスの起動コマンドを```ENTRYPOINT```で設定している場合は、後から上書きできなくなるため、```run```コマンドの引数として新しいコマンドを渡せずに、デバッグができないことがある。

```bash
$ docker run --rm -it <ビルドに失敗したイメージID> /bin/bash

# コンテナの中
root@xxxxxxxxxx: 
```

<br>

### レイヤー

#### ・イメージレイヤー

![イメージレイヤーからなるイメージのビルド](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/イメージのビルド.png)

任意のイメージをベースとして、新しいイメージをビルドするためには、ベースのイメージの上に、他のイメージレイヤーを積み重ねる必要がある。この時、Dockerfileを用いて、各命令によってイメージレイヤーを積み重ねていく。

#### ・コンテナレイヤー

イメージレイヤーの上に積み重ねられる

![イメージ上へのコンテナレイヤーの積み重ね](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/イメージ上へのコンテナレイヤーの積み重ね.png)

<br>

## 02-02. ベースイメージ

### イメージリポジトリ

#### ・イメージリポジトリとは

イメージは、実行OSによらずに一貫してビルドできるため、配布できる。各イメージリポジトリ（DockerHub、ECR、など）には、カスタマイズする上でのベースとなるイメージが提供されている。

<br>

### ベースイメージ

#### ・ベースイメージの種類

| イメージ         | 特徴                                                         | 相性の良いシステム例 |
| ---------------- | ------------------------------------------------------------ | -------------------- |
| **scratch**      | 以下の通り、何も持っていない<br>・OS：無<br>・パッケージ：無<br>・パッケージマネージャ：無 | ？                   |
| **BusyBox**      | ・OS：Linux（※ディストリビューションではない）<br>・パッケージ：基本ユーティリティツール<br>・パッケージマネージャ：無 | 組み込みシステム     |
| **Alpine Linux** | ・OS：Linux（※ディストリビューションではない）<br>・パッケージ：基本ユーティリティツール<br>・パッケージマネージャ：Apk | ？                   |

#### ・対応可能なCPUアーキテクチャの種類

Dockerは全てのPCで稼働できるわけではなく、イメージごとに対応可能なCPUアーキテクチャ（AMD系、ARM系、など）がある。同じOSでも、機種ごとに搭載されるCPUアーキテクチャは異なる。例えば、MacBook 2020 にはIntel、またMacBook 2021（M1 Mac）にはARMベースの独自CPUが搭載されているため、ARMに対応したイメージを選ぶ必要がある。ただし、イメージがOSのCPUアーキテクチャに対応しているかどうかを開発者が気にする必要はなく、```docker pull```時に、OSのCPUアーキテクチャに対応したイメージが自動的に選択されるようになっている。

参考：https://github.com/docker-library/official-images#architectures-other-than-amd64

#### ・バージョン

イメージのバージョンには種類があり、追跡できるバージョンアップが異なる。ここでは、composerのイメージを例に挙げる。

参考：https://hub.docker.com/_/composer/?tab=description&page=1&ordering=last_updated

| composerバージョン | 追跡できるバージョンアップ                                   |
| ------------------ | ------------------------------------------------------------ |
| ```2.0.9```        | バージョンを直指定し、追跡しない。                           |
| ```2.0```          | 『```2.0.X```』のマイナーアップデートのみを追跡する。        |
| ```2```            | 『```2.X```』と『```2.0.X```』のマイナーアップデートのみを追跡する。 |
| ```latest```       | メジャーアップデートとマイナーアップデートを追跡する。       |

<br>

## 03-02 イメージの軽量化

### プロセス単位によるDockerfileの分割

これは、Dockerの原則である。アプリケーションを稼働させるには、最低限、Webサーバミドルウェア、アプリケーション、DBMSが必要である。これらを、個別のコンテナで稼働させ、ネットワークで接続するようにする。

![プロセス単位のコンテナ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/プロセス単位のコンテナ.png)

<br>

### キャッシュを削除

Unixユーティリティをインストールすると、キャッシュが残る。

**＊実装例＊**


```dockerfile
FROM centos:8

RUN dnf upgrade -y \
  && dnf install -y \
      curl \
  # メタデータ削除
  && dnf clean all \
  # キャッシュ削除
  && rm -rf /var/cache/dnf
```

<br>


### ```RUN```コマンドをまとめる

Dockerfileの各命令によって、イメージ レイヤーが1つ増えてしまうため、同じ命令に異なるパラメータを与える時は、これを1つにまとめてしまう方が良い。例えば、以下のような時、

```dockerfile
# ベースイメージ上に、複数のソフトウェアをインストール
RUN yum -y isntall httpd
RUN yum -y install php
RUN yum -y install php-mbstring
RUN yum -y install php-pear
```

これは、以下のように一行でまとめられる。イメージレイヤーが少なくなり、イメージを軽量化できる。

```dockerfile
# ベースイメージ上に、複数のソフトウェアをインストール
RUN yum -y install httpd php php-mbstring php-pear
```

さらに、これは以下のようにも書くことができる。

```dockerfile
# ベースイメージ上に、複数のソフトウェアをインストール
RUN yum -y install \
     httpd \
     php \
     php-mbstring \
     php-pear
```

<br>

### マルチステージビルド

#### ・マルチステージビルドとは

1つのDockerfile内に複数の独立したステージを定義する方法。以下の手順で作成する。

1. シングルステージビルドに成功するDockerfileを作成する。
2. ビルドによって生成されたバイナリファイルがどこに配置されるかを場所を調べる。
3. Dockerfileで、二つ目の```FROM```を宣言する。
4. 1つ目のステージで、バイナリファイルをコンパイルするだけで終わらせる。
5. 二つ目のステージで、Unixユーティリティをインストールする。また、バイナリファイルを1つ目のステージからコピーする。

#### ・コンパイルされたバイナリファイルを再利用

**＊実装例＊**

```dockerfile
# 中間イメージ
FROM golang:1.7.3 AS builder
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY app.go /go/src/github.com/alexellis/href-counter/
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# 最終イメージ
FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/alexellis/href-counter/app .
CMD ["./app"]  
```

#### ・実行環境別にステージを分ける

**＊実装例＊**

```dockerfile
#===================
# Global ARG
#===================
ARG NGINX_VERSION="1.19"
ARG LABEL="Hiroki <hasegawafeedshop@gmail.com>"

#===================
# Build Stage
#===================
FROM nginx:${NGINX_VERSION} as build

RUN apt-get update -y \
  && apt-get install -y \
     curl \
     vim \
  # キャッシュ削除
  && apt-get clean

#===================
# Develop Stage
#===================
FROM build as develop
LABEL mantainer=${LABEL}

COPY ./infra/docker/www/develop.nginx.conf /etc/nginx/nginx.conf

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

#===================
# Production Stage
#===================
FROM build as production
LABEL mantainer=${LABEL}

COPY ./infra/docker/www/production.nginx.conf /etc/nginx/nginx.conf

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
```

<br>

### 可能な限りOSイメージをベースとしない

#### ・OSイメージをベースとした場合（悪い例）

OSベンダーが提供するベースイメージを用いると、不要なバイナリファイルが含まれてしまう。原則として、1つのコンテナで1つのプロセスしか実行せず、OS全体のシステムは不要なため、OSイメージをベースとしないようにする。

**＊実装例＊**

```dockerfile
# CentOSイメージを、コンテナにインストール
FROM centos:8

# PHPをインストールするために、EPELとRemiリポジトリをインストールして有効化。
RUN dnf upgrade -y \
  && dnf install -y \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
      https://rpms.remirepo.net/enterprise/remi-release-8.rpm \
  && dnf module enable php:remi-${PHP_VERSION} \
  # フレームワークの要件のPHP拡張機能をインストール
  && dnf install -y \
      php \
      php-bcmath \
      php-ctype \
      php-fileinfo \
      php-json \
      php-mbstring \
      php-openssl \
      php-pdo \
      php-tokenizer \
      php-xml \
  && dnf clean all \
  && rm -Rf /var/cache/dnf

# DockerHubのComposerイメージからバイナリファイルを取得
COPY --from=composer /usr/bin/composer /usr/bin/composer
```

**＊実装例＊**

```dockerfile
# CentOSイメージを、コンテナにインストール
FROM centos:8

# nginxをインストール
RUN dnf upgrade -y \
　　&& dnf install -y \
　　   nginx \
　　   curl \
　　&& dnf clean all \
　　&& rm -Rf /var/cache/dnf

COPY infra/docker/web/nginx.conf /etc/nginx/nginx.conf

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

EXPOSE 80
```

#### ・ミドルウェアイメージをベースとした場合（良い例）

代わりに、ミドルウェアベンダーが提供するベースイメージを用いるようにする。

**＊実装例＊**

```dockerfile
# Nginxイメージを、コンテナにインストール
FROM nginx:1.19

# NginxイメージがUbuntuベースなためにapt-getコマンド
RUN apt-get updatedocke -y \
  && apt-get install -y \
     curl \
  && apt-get clean

COPY ./infra/docker/www/production.nginx.conf /etc/nginx/nginx.conf
```

#### ・言語イメージをベースとした場合

代わりに、言語ベンダーが提供するベースイメージを用いるようにする。

```dockerfile
# ここに実装例
```

#### ・alpineイメージをベースとした場合

```dockerfile
# ここに実装例
```

<br>

## 04. ホストとコンテナ間のマウント

### バインドマウント

#### ・バインドマウントとは

![docker_bind-mount](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/docker_bind-mount.png)

ホスト側のディレクトリをコンテナ側にマウントする方法。ホストで作成されるデータが継続的に変化する場合に適しており、例えば開発環境でアプリケーションをホストコンテナ間と共有する方法として推奨である。しかし、ホスト側のデータを永続化する方法としては不適である。

参考：

- https://docs.docker.com/storage/bind-mounts/
- https://www.takapy.work/entry/2019/02/24/110932

#### ・使用方法

Dockerfileや```docker-compose.yml```ファイルへの定義、```docker```コマンドの実行、で使用できるが、```docker-compose.yml```ファイルでの定義が推奨である。

**＊コマンド例＊**

```bash
# ホストをコンテナ側にバインドマウント
$ docker run -d -it --name <コンテナ名> /bin/bash \
  --mount type=bind, src=home/projects/<ホスト側のディレクトリ名>, dst=/var/www/<コンテナ側のディレクトリ名>
```

#### ・マウント元として指定できるディレクトリ

以下の通り、ホスト側のマウント元のディレクトリにはいくつか選択肢がある。

![マウントされるホスト側のディレクトリ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/マウントされるホスト側のディレクトリ.png)

<br>

### ボリュームマウント

#### ・ボリュームマウントとは

![docker_volume-mount](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/docker_volume-mount.png)

ホストにあるdockerエリア（```/var/lib/docker/volumes```ディレクトリ）のマウントポイント（```/var/lib/docker/volumes/<ボリューム名>/_data```）をコンテナ側にマウントする方法。ホストで作成されるデータがめったに変更しない場合に適しており、例えばDBのデータをホストコンテナ間と共有する方法として推奨である。しかし、例えばアプリケーションやパッケージといったような変更されやすいデータを共有する方法としては不適である。

参考：

- https://docs.docker.com/storage/volumes/
- https://www.takapy.work/entry/2019/02/24/110932

#### ・ボリューム、マウントポイントとは

ホスト側のdockerエリア（```/var/lib/docker/volumes```ディレクトリ）に保存される永続データをボリュームという。また、ボリュームへのパス（```/var/lib/docker/volumes/<ボリューム名>/_data```）をマウントポイントという。

#### ・使用方法

Dockerfileや```docker-compose.yml```ファイルへの定義、```docker```コマンドの実行、で使用できるが、```docker-compose.yml```ファイルでの定義が推奨である。

**＊コマンド例＊**

```bash
# ホストをコンテナ側にバインドマウント
$ docker run -d -it --name <コンテナ名> /bin/bash \
  --mount type=volume, src=home/projects/<ホスト側のディレクトリ名>, dst=/var/www/<コンテナ側のディレクトリ名>
```

#### ・Data Volumeコンテナによる永続化データの提供

ボリュームを用いる場合のコンテナ配置手法の一種。dockerエリアのボリュームをData Volumeをコンテナのディレクトリにマウントしておく。ボリュームを用いる時は、dockerエリアを参照するのではなく、Data Volumeコンテナを参照するようにする。

![data-volumeコンテナ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/data-volumeコンテナ.png)

<br>

### バインドマウント vs. ボリュームマウント

#### ・ボリュームマウントの方がバインドマウントよりも安全

本番環境で、ホストからコンテナにバインドマウントを実行することは技術的に可能である。しかし、バインドマウントではホストとコンテナ間が依存し合うため、ホストとコンテナのどちらかのアプリケーションが変化した時に、もう一方も影響が出る。対して、ホストにあるdockerエリア内のボリュームはホスト側から変更しにくく、より安全である。

参考：

- https://www.ibm.com/docs/en/zos/2.4.0?topic=zcx-bind-mounts-docker-volumes
- https://www.takapy.work/entry/2019/02/24/110932

#### ・ボリュームマウントの代わりに```COPY```を使用

本番環境ではボリュームマウント（```VOLUME```）や```COPY```を使用して、アプリケーションをdockerイメージに組み込む。

参考：https://docs.docker.com/develop/dev-best-practices/#differences-in-development-and-production-environments

ボリュームマウントでは、組み込んだアプリケーションをコンテナ起動後しか参照できないため、コンテナ起動前にアプリケーションで何かする場合は```COPY```の方が便利である。方法として、プライベートリポジトリにデプロイするイメージのビルド時に、ホスト側のアプリケーションをイメージ側に```COPY```しておく。これにより、本番環境ではこのイメージをプルしさえすれば、アプリケーションを使用できるようになる。

参考：

- https://www.nyamucoro.com/entry/2018/03/15/200412
- https://blog.fagai.net/2018/02/22/docker%E3%81%AE%E7%90%86%E8%A7%A3%E3%82%92%E3%81%84%E3%81%8F%E3%82%89%E3%81%8B%E5%8B%98%E9%81%95%E3%81%84%E3%81%97%E3%81%A6%E3%81%84%E3%81%9F%E8%A9%B1/

<br>

## 05. ホストとコンテナ間のネットワーク接続

### bridgeネットワーク

#### ・bridgeネットワークとは

複数のコンテナ間に対して、仮想ネットワークで接続させる。また、仮想ネットワークを物理ネットワークの間を、仮想ブリッジを用いてbridge接続する。ほとんどの場合、この方法を用いる。

参考：https://www.itmedia.co.jp/enterprise/articles/1609/21/news001.html

![Dockerエンジン内の仮想ネットワーク](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Dockerエンジン内の仮想ネットワーク.jpg)

物理サーバへのリクエストメッセージがコンテナに届くまでを以下に示す。物理サーバの```8080```番ポートと、WWWコンテナの```80```番ポートのアプリケーションの間で、ポートフォワーディングを行う。これにより、『```http://<物理サーバのプライベートIPアドレス（localhost）>:8080```』にリクエストを送信すると、WWWコンテナのポート番号に転送されるようになる。

| 処理場所           | リクエストメッセージの流れ         | プライベートIPアドレス例                                     | ポート番号例 |
| :----------------- | :--------------------------------- | :----------------------------------------------------------- | ------------ |
| コンテナ内プロセス | プロセスのリッスンするポート       |                                                              | ```:80```    |
|                    | ↑                                  |                                                              |              |
| コンテナ           | コンテナポート                     | ・```http://127.0.0.1```<br>・```http://<Dockerのhostnameの設定値>``` | ```:80```    |
|                    | ↑                                  |                                                              |              |
| ホストOS         | 仮想ネットワーク                   | ```http://172.XX.XX.XX```                                    |              |
|                    | ↑                                  |                                                              |              |
| ホストOS         | 仮想ブリッジ                       |                                                              |              |
|                    | ↑                                  |                                                              |              |
| ホストハードウェア | 物理サーバのNIC（ Ethernetカード） | ```http://127.0.0.1```                                       | ```:8080```  |

<br>

### noneネットワーク

#### ・noneネットワークとは

特定のコンテナを、ホストや他のコンテナとは、ネットワーク接続させない。


```bash
$ docker network list

NETWORK ID          NAME                    DRIVER              SCOPE
7edf2be856d7        none                    null                local
```

<br>


### hostネットワーク

#### ・hostネットワークとは

特定のコンテナに対して、ホストと同じネットワーク情報をもたせる。

```bash
$ docker network list

NETWORK ID          NAME                    DRIVER              SCOPE
ac017dda93d6        host                    host                local
```

<br>

### コンテナ間の接続方法

#### ・『ホスト』から『ホスト（```localhost```）』にリクエスト

『ホスト』から『ホスト』に対して、アウトバウンドなリクエストを送信する。ここでのホスト側のホスト名は、『```localhost```』となる。リクエストは、ポートフォワーディングされたコンテナに転送される。ホストとコンテナの間のネットワーク接続の成否を確認できる。

**＊コマンド例＊**

『ホスト』から『ホスト』に対してアウトバウンドなリクエストを送信し、ホストとappコンテナの間の成否を確認する。

```bash
# ホストで実行
$ curl --fail http://localhost:8080/
```

#### ・『コンテナ』から『コンテナ』にリクエスト

『コンテナ』から『コンテナ』に対して、アウトバウンドなリクエストを送信する。ここでのコンテナのホスト名は、コンテナ内の『```/etc/hosts```』に定義されたものとなる。リクエストはホストを経由せず、そのままコンテナに送信される。コンテナ間のネットワーク接続の成否を確認できる。コンテナのホスト名の定義方法については、以下を参考にせよ。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/virtualization/virtualization_container_orchestration.html

**＊コマンド例＊**

『appコンテナ』から『nginxコンテナ』に対して、アウトバウンドなリクエストを送信し、appコンテナとnginxコンテナの間の成否を確認する。

```bash
# コンテナ内で実行
$ curl --fail http://<nginxコンテナに割り当てたホスト名>:80/
```

#### ・『コンテナ』から『ホスト（```host.docker.internal```）』にリクエスト

『コンテナ』から『ホスト』に対して、アウトバウンドなリクエストを送信する。ここでのホスト側のホスト名は、『```host.docker.internal```』になる。リクエストは、ホストを経由して、ポートフォワーディングされたコンテナに転送される。ホストとコンテナの間のネットワーク接続の成否を確認できる。

```bash
# コンテナ内で実行
$ curl --fail http://host.docker.internal:8080/
```
