# kubernetesコマンド

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. kubernetesオブジェクトの種類

### ノード

#### ・マスターノード

Kubernetesが実行されるホスト物理サーバを指す。

#### ・ワーカーノード

Dockerが実行されるホスト仮想サーバを指す。

![Kubernetesの仕組み](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Kubernetesの仕組み.png)

<br>

### サービス

#### ・サービスとは

ポッドにリクエストを転送するロードバランサーとして機能する。マイクロさービスアーキテクチャのコンポーネントである『サービス』とは区別する。

参考：https://kubernetes.io/ja/docs/concepts/services-networking/service/

<br>

### ポッド

#### ・ポッドとは

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

### apply

#### ・applyとは

同じ識別子（オブジェクト名）のオブジェクトが存在しない場合はオブジェクトを構築し、存在する場合はマニフェストファイルの差分を更新する。全ての項目を更新できるわけでない。

#### ・-f

マニフェストファイルを指定し、```apply```コマンドを実行する。

```bash
$ kubectl apply -f ./kubernetes-manifests/foo-pod.yml

pod/foo-pod created
```

```bash
# ベースイメージを変更
$ kubectl apply -f ./kubernetes-manifests/foo-pod.yml

pod/foo-pod configured
```

<br>

### config

#### ・config

Kubernetes自体の設定を操作する。

#### ・view

Kubernetes自体の設定が実装された```~/.kude/config```ファイルを表示する。

```bash
$ kubectl config view                                                                       
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://kubernetes.docker.internal:6443
  name: docker-desktop
contexts:
- context:
    cluster: docker-desktop
    user: docker-desktop
  name: docker-desktop
current-context: docker-desktop
kind: Config
preferences: {}
users:
- name: docker-desktop
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
```

<br>

### create

#### ・createとは

オブジェクトを構築する。同じ識別子（オブジェクト名）のオブジェクトが存在する場合は重複エラーになる。

#### ・-f

マニフェストファイルを指定し、```create```コマンドを実行する。

```bash
$ kubectl create -f ./kubernetes-manifests/foo-pod.yml

pod/foo-pod created
```

```bash
$ kubectl create -f ./kubernetes-manifests/foo-service.yml

service/foo-service created
```

<br>

### get

#### ・getとは

オブジェクトを参照する。

#### ・node

構築済みのノードを表示する。

```bash
$  kubectl get nodes 

NAME             STATUS   ROLES                  AGE   VERSION
docker-desktop   Ready    control-plane,master   12h   v1.21.5 # マスターノード
```

#### ・pod

構築済みのポッドを表示する。

```bash
$ kubectl get pods

NAME       READY   STATUS             RESTARTS   AGE
foo-pod    0/2     ImagePullBackOff   0          7m52s
```

#### ・services

構築済みのサービスを表示する。

```bash
$ kubectl get services

NAME           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
foo-service    ClusterIP   nn.nnn.nnn.n   <none>        80/TCP    10s
kubernetes     ClusterIP   nn.nn.n.n      <none>        443/TCP   12h
```

