# kubernetesコマンド

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Kubernetesの仕組み

### Node

#### ・Master Node

Kubernetesが実行されるホスト物理サーバを指す。

#### ・Worker Node

Dockerが実行されるホスト仮想サーバを指す。

![Kubernetesの仕組み](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Kubernetesの仕組み.png)

<br>

### Service

#### ・Serviceとは

Podにリクエストを転送するロードバランサーとして機能する。

参考：https://kubernetes.io/ja/docs/concepts/services-networking/service/

<br>

### Pod

#### ・Podとは

ホスト仮想サーバ上のコンテナを最小グループ単位のこと。Podを単位として、コンテナ起動／停止や水平スケールイン／スケールアウトを実行する。

参考：https://kubernetes.io/ja/docs/concepts/workloads/pods/

AWS ECSタスクにおける類似するessential機能やオートスケーリングについては、以下のリンクを参考にせよ。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/cloud_computing/cloud_computing_aws.html

**＊例＊**

PHP-FPMコンテナとNginxコンテナを稼働させる場合、これら同じPodに配置する。

![kubernetes_php-fpm_nginx](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_php-fpm_nginx.png)

<br>

### Secret

#### ・Secretとは

セキュリティに関するデータを管理し、コンテナに選択的に提供するもの。

<br>

### Replica Set

#### ・Replica Set（Replication Controller）とは

<br>

## 02. コマンド