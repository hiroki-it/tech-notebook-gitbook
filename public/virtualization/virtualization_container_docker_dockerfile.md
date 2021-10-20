# Dockerfile

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. コンテナに接続するまでの手順

### 手順の流れ

1. Docker Hubから，ベースとなるイメージをインストールする．
2. Dockerfileがイメージレイヤーからなるイメージをビルド．
3. コマンドによって，イメージ上にコンテナレイヤーを生成し，コンテナを構築．
4. コマンドによって，停止中のコンテナを起動．
5. コマンドによって，起動中のコンテナに接続．

![Dockerfileの作成からコンテナ構築までの手順](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Dockerfileの作成からコンテナ構築までの手順.png)

<br>

## 02. Dockerfileの実装

### イメージレイヤーの積み重ね

#### ・Dockerfileの仕組み

![イメージレイヤーからなるイメージのビルド](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/イメージのビルド.png)

任意のイメージをベースとして，新しいイメージをビルドするためには，ベースのイメージの上に，他のイメージレイヤーを積み重ねる必要がある．この時，Dockerfileを用いて，各命令によってイメージレイヤーを積み重ねていく．


#### ・Dockerfileの記述方法

任意のイメージをベースとして，新しいイメージをビルドするためには，以下の5つ順番で命令を用いて，イメージレイヤーを積み重ねていく．命令は，慣例的に大文字で記述する．

**＊実装例＊**

NginxのイメージをビルドするためのDockerfileを示す．命令のパラメータの記述形式には，文字列形式，JSON形式がある．ここでは，JSON形式で記述する．

```dockerfile
# ベースのイメージ（CentOS）を，コンテナにインストール
FROM centos:8

# ubuntu上に，nginxをインストール
RUN yum update -y \
   && yum install -y \
     nginx

# ホストOSの設定ファイルを，コンテナ側の指定ディレクトリにコピー
COPY infra/docker/web/nginx.conf /etc/nginx/nginx.conf

# nginxをデーモン起動
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

# コンテナのポートを開放を明示する．これはドキュメンテーションとしての機能しかない．
EXPOSE 80
```

| 命令                 | 処理                                                         |
| -------------------- | ------------------------------------------------------------ |
| **```FROM```**       | ベースのイメージを，コンテナにインストール.            |
| **```RUN```**        | ベースイメージ上に，ソフトウェアをインストール.              |
| **```COPY```**       | ・ホストOSのファイルをイメージレイヤー化し，コンテナの指定ディレクトリにコピー.<br>・イメージのビルド時にコピーされるだけで，ビルド後のコードの変更は反映されない．<br>・```nginx.conf```ファイル，```php.ini```ファイル，などの設定ファイルをホストOSからコンテナにコピーしたい時によく使う． |
| **```CMD```**        | イメージのプロセスの起動コマンドを実行．```run```コマンドの引数として，上書きできる． |
| **```VOLUME```**     | Volumeマウントを行う．```COPY```とは異なり，ビルド後のコードの変更が反映される．Docker Composeで記述した方が良い． |
| **```EXPOSE```**     | コンテナのポートを開放する．また，イメージの利用者にとってのドキュメンテーション機能もあり，ポートマッピングを実行する時に使用可能なコンテナポートとして保証する機能もある．<br>参考：<br>・https://docs.docker.com/engine/reference/builder/#expose<br>・https://www.whitesourcesoftware.com/free-developer-tools/blog/docker-expose-port/<br><br>また加えて，プロセス自体が命令をリッスンできるようにポートを設定する必要がある．ただし，多くの場合標準でこれが設定されている．（例：PHP-FPMでは，```/usr/local/etc/www.conf.default```ファイルと```/usr/local/etc/php-fpm.d/www.conf```ファイルには，```listen = 127.0.0.1:9000```の設定がある） |
| **```ENTRYPOINT```** | イメージのプロセスの起動コマンドを実行．```CMD```とは異なり，後から上書き実行できない．使用者に，コンテナの起動方法を強制させたい場合に適する． |
| **```ENV```**        | OS上のコマンド処理で扱える変数を定義する．Dockerfileの命令では扱えない．```ARG```との違いの具体例については下記． |
| **```ARG```**        | Dockerfikeの命令で扱える変数を定義する．OS上のコマンド処理では扱えない．```ENV```との違いの具体例については下記． |
| **```ADD```**     | ・ホストOSのファイルを，コンテナの指定ディレクトリにコピー（**```COPY```と同じ**）<br>・インターネットからファイルをダウンロードし，解凍も行う．<br>・イメージのビルド時にコピーされるだけで，ビルド後のコードの変更は反映されない． |
| **```WORKDIR```** | 絶対パスによる指定で，現在のディレクトリを変更.              |

#### ・CMDの決め方

Dockerfileで```CMD```を指定しない場合，イメージのデフォルトのバイナリファイルが割り当てられる．一旦，デフォルトのバイナリファイルを確認した後に，これをDockerfileに明示的に実装するようにする．

```bash
CONTAINER ID   IMAGE   COMMAND     CREATED          STATUS         PORTS                    NAMES
2b2d3dfafee8   xxxxx   "/bin/sh"   11 seconds ago   Up 8 seconds   0.0.0.0:8000->8000/tcp   xxxxx
```

静的型付け言語ではプロセスの起動時に，代わりにアーティファクトのバイナリファイルを実行しても良い．その場合，```bin```ディレクトリにバイナリファイルとしてのアーティファクトを配置することになる．しかし，```bin```ディレクトリへのアクセス権限がないことがあるため，その場合は，一つ下にディレクトリを作成し，そこにバイナリファイルを置くようにする．

```bash
# /go/bin にアクセスできない時は，/go/bin/cmdにアーティファクトを置く．
ERROR: for xxx-container  Cannot start service go: OCI runtime create failed: container_linux.go:367: starting container process caused: exec: "/go/bin": permission denied: unknown

```

#### ・ENTRYPOINTの注意点

イメージのプロセスの起動コマンドを後から上書きできなくなるため，```run```コマンドの引数として新しいコマンドを渡せずに，デバッグができないことがある．

```bash
# 上書きできず，失敗してしまう．
$ docker run --rm -it <イメージ名> /bin/bash
```

#### ・ENVとARGの違い

一つ目に，```ENV```が使えて，```ARG```が使えない例．

```dockerfile
# ENVは，OS上のコマンド処理で扱える変数を定義
ARG PYTHON_VERSION="3.8.0"
RUN pyenv install ${PYTHON_VERSION}

# ARGは，OS上のコマンド処理では扱えない
ARG PYTHON_VERSION="3.8.0"
RUN pyenv install ${PYTHON_VERSION} # ===> 変数を展開できない
```

二つ目に，```ARG```が使えて，```ENV```が使えない例．

```dockerfile
# ARGは,Dockerfikeの命令で扱える変数を定義
ARG OS_VERSION="8"
FROM centos:${OS_VERSION}

# ENVは，OS上のコマンド処理では扱えない
ENV OS_VERSION "8"
FROM centos:${OS_VERSION} # ===> 変数を展開できない
```

三つ目に，これらの違いによる可読性の悪さの対策として，```ENV```と```ARG```を組み合わせた例．

```dockerfile
# 最初に全て，ARGで定義
ARG CENTOS_VERSION="8"
ARG PYTHON_VERSION="3.8.0"

# 変数展開できる
FROM centos:${OS_VERSION}

# ARGを事前に宣言
ARG PYTHON_VERSION
# 必要に応じて，事前にENVに詰め替える．
ENV PYTHON_VERSION ${PYTHON_VERSION}

# 変数展開できる
RUN pyenv install ${PYTHON_VERSION}
```


#### ・Docker Hubに対する継続的インテグレーション

| 方法                  | 仕組み                                            |
| --------------------- | ------------------------------------------------- |
| GitHub Actions        | GitHubが，Docker Hubに対して，pushを行う．        |
| Circle CI             | GitHubが，Circle CIに対して，送信WebHookを行う．  |
| Docker Hub Auto Build | GitHubが，Docker Hubに対して，送信WebHookを行う． |

#### ・Dockerfileを使用するメリット

Dockerfileを用いない場合，各イメージレイヤーのインストールを手動で行わなければならない．しかし，Dockerfileを用いることで，これを自動化することができる．

![Dockerfileのメリット](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Dockerfileのメリット.png)

<br>

### イメージのデバッグ

**＊コマンド例＊**

ビルドに失敗したイメージからコンテナを構築し，接続する．```rm```オプションを設定し，接続の切断後にコンテナを削除する．Dockerfileにおいて，イメージのプロセスの起動コマンドを```ENTRYPOINT```で設定している場合は，後から上書きできなくなるため，```run```コマンドの引数として新しいコマンドを渡せずに，デバッグができないことがある．

```bash
$ docker run --rm -it <ビルドに失敗したイメージID> /bin/bash

# コンテナの中
root@xxxxxxxxxx: 
```

<br>

### コンテナレイヤー

#### ・コンテナレイヤーとは

イメージレイヤーの上に積み重ねられる

![イメージ上へのコンテナレイヤーの積み重ね](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/イメージ上へのコンテナレイヤーの積み重ね.png)

<br>

## 02-02. ベースイメージ

### イメージリポジトリ

#### ・イメージリポジトリとは

イメージは，実行OSによらずに一貫してビルドできるため，配布できる．各イメージリポジトリ（DockerHub，ECR，など）には，カスタマイズする上でのベースとなるイメージが提供されている．

<br>

### ベースイメージ

#### ・ベースイメージの種類

| イメージ         | 特徴                                                         | 相性の良いシステム例 |
| ---------------- | ------------------------------------------------------------ | -------------------- |
| **scratch**      | 以下の通り，何も持っていない<br>・OS：無<br>・パッケージ：無<br>・パッケージマネージャ：無 | ？                   |
| **BusyBox**      | ・OS：Linux（※ディストリビューションではない）<br>・パッケージ：基本ユーティリティツール<br>・パッケージマネージャ：無 | 組み込みシステム     |
| **Alpine Linux** | ・OS：Linux（※ディストリビューションではない）<br/>・パッケージ：基本ユーティリティツール<br>・パッケージマネージャ：Apk | ？                   |

#### ・対応可能なCPUアーキテクチャの種類

Dockerは全てのPCで稼働できるわけではなく，イメージごとに対応可能なCPUアーキテクチャ（AMD系，ARM系，など）がある．同じOSでも，機種ごとに搭載されるCPUアーキテクチャは異なる．例えば，MacBook 2020 にはIntel，またMacBook 2021（M1 Mac）にはARMベースの独自CPUが搭載されているため，ARMに対応したイメージを選ぶ必要がある．ただし，イメージがOSのCPUアーキテクチャに対応しているかどうかを開発者が気にする必要はなく，```docker pull```時に，OSのCPUアーキテクチャに対応したイメージが自動的に選択されるようになっている．

参考：https://github.com/docker-library/official-images#architectures-other-than-amd64

#### ・バージョン

イメージのバージョンには種類があり，追跡できるバージョンアップが異なる．ここでは，composerのイメージを例に挙げる．

参考：https://hub.docker.com/_/composer/?tab=description&page=1&ordering=last_updated

| composerバージョン | 追跡できるバージョンアップ                                   |
| ------------------ | ------------------------------------------------------------ |
| ```2.0.9```        | バージョンを直指定し，追跡しない．                           |
| ```2.0```          | 「```2.0.X```」のマイナーアップデートのみを追跡する．        |
| ```2```            | 「```2.X```」と「```2.0.X```」のマイナーアップデートのみを追跡する． |
| ```latest```       | メジャーアップデートとマイナーアップデートを追跡する．       |

<br>

## 03-02 イメージの軽量化

### プロセス単位によるDockerfileの分割

これは，Dockerの原則である．アプリケーションを稼働させるには，最低限，Webサーバミドルウェア，アプリケーション，DBMSが必要である．これらを，個別のコンテナで稼働させ，ネットワークで接続するようにする．

![プロセス単位のコンテナ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/プロセス単位のコンテナ.png)

<br>

### キャッシュを削除

Unixユーティリティをインストールすると，キャッシュが残る．

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

Dockerfileの各命令によって，イメージ レイヤーが一つ増えてしまうため，同じ命令に異なるパラメータを与える時は，これを一つにまとめてしまう方が良い．例えば，以下のような時，

```dockerfile
# ベースイメージ上に，複数のソフトウェアをインストール
RUN yum -y isntall httpd
RUN yum -y install php
RUN yum -y install php-mbstring
RUN yum -y install php-pear
```

これは，以下のように一行でまとめられる．イメージレイヤーが少なくなり，イメージを軽量化することができる．

```dockerfile
# ベースイメージ上に，複数のソフトウェアをインストール
RUN yum -y install httpd php php-mbstring php-pear
```

さらに，これは以下のようにも書くことができる．

```dockerfile
# ベースイメージ上に，複数のソフトウェアをインストール
RUN yum -y install \
     httpd \
     php \
     php-mbstring \
     php-pear
```

<br>

### マルチステージビルド

#### ・マルチステージビルドとは

一つのDockerfile内に複数の独立したステージを定義する方法．以下の手順で作成する．

1. シングルステージビルドに成功するDockerfileを作成する．
2. ビルドによって生成されたバイナリファイルがどこに配置されるかを場所を調べる．
3. Dockerfileで，二つ目の```FROM```を宣言する．
4. 一つ目のステージで，バイナリファイルをコンパイルするだけで終わらせる．
5. 二つ目のステージで，Unixユーティリティをインストールする．また，バイナリファイルを一つ目のステージからコピーする．

#### ・コンパイルされたバイナリファイルを再利用

**＊実装例＊**

```dockerfile
# 中間イメージ
FROM golang:1.7.3 AS builder
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY app.go    .
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

OSベンダーが提供するベースイメージを使用すると，不要なバイナリファイルが含まれてしまう．原則として，一つのコンテナで一つのプロセスしか実行せず，OS全体のシステムは不要なため，OSイメージをベースとしないようにする．

**＊実装例＊**

```dockerfile
# CentOSイメージを，コンテナにインストール
FROM centos:8

# PHPをインストールするために，EPELとRemiリポジトリをインストールして有効化．
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
# CentOSイメージを，コンテナにインストール
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

代わりに，ミドルウェアベンダーが提供するベースイメージを使用するようにする．

**＊実装例＊**

```dockerfile
# Nginxイメージを，コンテナにインストール
FROM nginx:1.19

# NginxイメージがUbuntuベースなためにapt-getコマンド
RUN apt-get updatedocke -y \
  && apt-get install -y \
     curl \
  && apt-get clean

COPY ./infra/docker/www/production.nginx.conf /etc/nginx/nginx.conf
```

#### ・言語イメージをベースとした場合

代わりに，言語ベンダーが提供するベースイメージを使用するようにする．

```dockerfile
# ここに実装例
```

#### ・alpineイメージをベースとした場合

```dockerfile
# ここに実装例
```

<br>

## 04. ホストとコンテナ間のマウント

### Bindマウント

#### ・Bindマウントとは

ホストOSの```/Users```ディレクトリをコンテナ側にマウントする方法．ホストOSで作成されるデータが継続的に変化する場合に適しており，例えばアプリケーションをホストコンテナ間と共有する方法として推奨である．しかし，ホストOSのデータを永続化する方法としては不適である．また，Dockerfileまたはdocker-composeファイルに記述する方法があるが，後者が推奨である．

![bindマウント](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/bindマウント.png)

**＊コマンド例＊**

```bash
# ホストOSをコンテナ側にbindマウント
$ docker run -d -it --name <コンテナ名> /bin/bash \
  --mount type=bind, src=home/projects/<ホストOS側のディレクトリ名>, dst=/var/www/<コンテナ側のディレクトリ名>
```

#### ・マウント元として指定できるディレクトリ

以下の通り，ホストOSのマウント元のディレクトリにはいくつか選択肢がある．

![マウントされるホスト側のディレクトリ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/マウントされるホスト側のディレクトリ.png)

<br>

### Volumeマウント

#### ・Volume（Data Volume），Dockerエリアとは

ホストOSのDockerエリア（```/var/lib/docker/volumes```ディレクトリ）に保存される永続データのこと．Data Volumeともいう．Volumeへのパス（```/var/lib/docker/volumes/<Volume名>/_data```）は，マウントポイントという．

#### ・Volumeマウントとは

ホストOSにあるDockerエリアのマウントポイントをコンテナ側にマウントする方法．ホストOSで作成されるデータがめったに変化しない場合に適しており，例えばDBのデータをホストコンテナ間と共有する方法として推奨である．

![volumeマウント](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/volumeマウント.png)

#### ・Data Volumeコンテナによる永続化データの提供

Volumeを使用する場合のコンテナ配置手法の一つ．DockerエリアのVolumeをData Volumeをコンテナ （Data Volumeコンテナ）のディレクトリにマウントしておく．Volumeを使用する時は，Dockerエリアを参照するのではなく，Data Volumeコンテナを参照するようにする．

![data-volumeコンテナ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/data-volumeコンテナ.png)

<br>

## 05. ホストとコンテナ間のネットワーク接続

### bridgeネットワーク

#### ・bridgeネットワークとは

複数のコンテナ間に対して，仮想ネットワークで接続させる．また，仮想ネットワークを物理ネットワークの間を，仮想ブリッジを用いてbridge接続する．ほとんどの場合，この方法を用いる．

参考：https://www.itmedia.co.jp/enterprise/articles/1609/21/news001.html

![Dockerエンジン内の仮想ネットワーク](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Dockerエンジン内の仮想ネットワーク.jpg)

物理サーバへのリクエストメッセージがコンテナに届くまでを以下に示す．物理サーバの```8080```番ポートと，WWWコンテナの```80```番ポートのアプリケーションの間で，ポートフォワーディングを行う．これにより，『```http://<物理サーバのプライベートIPアドレス（localhost）>:8080```』にリクエストを送信すると，WWWコンテナのポート番号に転送されるようになる．

| 処理場所           | リクエストメッセージの流れ         | プライベートIPアドレス例                                     | ポート番号例 |
| :----------------- | :--------------------------------- | :----------------------------------------------------------- | ------------ |
| コンテナ内プロセス | プロセスのリッスンするポート       |                                                              | ```:80```    |
|                    | ↑                                  |                                                              |              |
| コンテナ           | コンテナポート                     | ・```http://127.0.0.1```<br>・```http://<dockerのhostnameの設定値>``` | ```:80```    |
|                    | ↑                                  |                                                              |              |
| ホストOS           | 仮想ネットワーク                   | ```http://172.XX.XX.XX```                                    |              |
|                    | ↑                                  |                                                              |              |
| ホストOS           | 仮想ブリッジ                       |                                                              |              |
|                    | ↑                                  |                                                              |              |
| ホストハードウェア | 物理サーバのNIC（ Ethernetカード） | ```http://127.0.0.1```                                       | ```:8080```  |

<br>

### noneネットワーク

#### ・noneネットワークとは

特定のコンテナを，ホストOSや他のコンテナとは，ネットワーク接続させない．


```bash
$ docker network list

NETWORK ID          NAME                    DRIVER              SCOPE
7edf2be856d7        none                    null                local
```

<br>


### hostネットワーク

#### ・hostネットワークとは

特定のコンテナに対して，ホストOSと同じネットワーク情報をもたせる．

```bash
$ docker network list

NETWORK ID          NAME                    DRIVER              SCOPE
ac017dda93d6        host                    host                local
```

<br>

### コンテナ間の接続方法

#### ・『ホストOS』から『ホストOS（```localhost```）』にリクエスト

『ホストOS』から『ホストOS』に対して，アウトバウンドなリクエストを送信する．ここでのホストOSのホスト名は，『```localhost```』となる．リクエストは，ポートフォワーディングされたコンテナに転送される．ホストOSとコンテナの間のネットワーク接続の成否を確認できる．

**＊コマンド例＊**

『ホストOS』から『ホストOS』に対してアウトバウンドなリクエストを送信し，ホストOSとappコンテナの間の成否を確認する．

```bash
# ホストOSで実行
$ curl --fail http://localhost:8080/
```

#### ・『コンテナ』から『コンテナ』にリクエスト

『コンテナ』から『コンテナ』に対して，アウトバウンドなリクエストを送信する．ここでのコンテナのホスト名は，コンテナ内の『```/etc/hosts```』に定義されたものとなる．リクエストはホストOSを経由せず，そのままコンテナに送信される．コンテナ間のネットワーク接続の成否を確認できる．コンテナのホスト名の定義方法については，以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_virtualization_container_orchestration.html

**＊コマンド例＊**

『appコンテナ』から『nginxコンテナ』に対して，アウトバウンドなリクエストを送信し，appコンテナとnginxコンテナの間の成否を確認する．

```bash
# コンテナ内で実行
$ curl --fail http://<nginxコンテナに割り当てたホスト名>:80/
```

#### ・『コンテナ』から『ホストOS（```host.docker.internal```）』にリクエスト

『コンテナ』から『ホストOS』に対して，アウトバウンドなリクエストを送信する．ここでのホストOSのホスト名は，『```host.docker.internal```』になる．リクエストは，ホストOSを経由して，ポートフォワーディングされたコンテナに転送される．ホストOSとコンテナの間のネットワーク接続の成否を確認できる．

```bash
# コンテナ内で実行
$ curl --fail http://host.docker.internal:8080/
```
