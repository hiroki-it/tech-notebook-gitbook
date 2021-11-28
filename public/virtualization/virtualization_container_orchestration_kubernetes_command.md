# kubernetesコマンド

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Kubernetesの構成要素

### 全体像

参考：

- https://medium.com/easyread/step-by-step-introduction-to-basic-concept-of-kubernetes-e20383bdd118
- https://qiita.com/baby-degu/items/ce26507bd954621d6dc5

![kubernetes_overview](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_overview.png)<br>

### Kubernetesクライアント

#### ・Kubernetesクライアントとは

Kubernetesクライアントは、kubectlコマンドを使用して、KubernetesマスターAPIをコールできる。

<br>

### Kubernetesマスター（マスターノード）

#### ・Kubernetesマスターとは

ワーカーノードの操作を担う。『マスターノード』ともいう。クライアントがkubectlコマンドの実行すると、apiserverがコールされ、コマンドに沿ってワーカーノードが操作される。

参考：https://kubernetes.io/ja/docs/concepts/#kubernetes%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC

#### ・apiserver

KubernetesクライアントにコマンドのAPIを提供する。

#### ・controller-manager

#### ・scheduler

<br>

### クラスター

#### ・クラスターとは

ワーカーノードの管理単位のこと。

<br>

### ワーカーノード

#### ・ワーカーノードとは

ポッドが稼働するサーバ単位こと。

参考：https://kubernetes.io/ja/docs/concepts/architecture/nodes/

#### ・Kubelet

#### ・コンテナエンジン

コンテナ起動停止、イメージのプル、などを行う。

#### ・Kubeプロキシ

受信したリクエストをポッドに振り分ける。

#### ・ポッドとは

コンテナの最小グループ単位のこと。Podを単位として、コンテナ起動／停止や水平スケールイン／スケールアウトを実行する。

参考：https://kubernetes.io/ja/docs/concepts/workloads/pods/

AWS ECSタスクにおける類似するessential機能やオートスケーリングについては、以下のリンクを参考にせよ。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/cloud_computing/cloud_computing_aws.html

**＊例＊**

PHP-FPMコンテナとNginxコンテナを稼働させる場合、これら同じPodに配置する。

![kubernetes_pod_php-fpm_nginx](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_pod_php-fpm_nginx.png)

<br>

### サービス

#### ・サービスとは

ポッドにリクエストを転送するロードバランサーのこと。マイクロサービスアーキテクチャのコンポーネントである『サービス』とは区別する。

参考：https://kubernetes.io/ja/docs/concepts/services-networking/service/

<br>

### シークレット

#### ・シークレットとは

セキュリティに関するデータを管理し、コンテナに選択的に提供する。

<br>

### レプリカセット（レプリカコントローラ）

#### ・レプリカセットとは

<br>

### ボリューム

#### ・PersistentVolume

ノードのストレージを使用したボリュームのこと。ポッドがPersistentVolumeを使用するためには、PersistentVolumeClaimオブジェクトにPersistentVolumeを要求させておき、ポッドでこのPersistentVolumeClaimオブジェクトを指定する必要がある。

参考：https://thinkit.co.jp/article/14195

#### ・EmptyDir

ポッドのストレージを使用したボリュームのこと。ポッドのストレージをボリュームとして使用するため、ポッドが削除されると、このボリュームも同時に削除される。

参考：https://zenn.dev/suiudou/articles/31ab107f3c2de6#%E2%96%A0kubernetes%E3%81%AE%E3%81%84%E3%82%8D%E3%82%93%E3%81%AA%E3%83%9C%E3%83%AA%E3%83%A5%E3%83%BC%E3%83%A0

#### ・外部ボリューム

Kubernetes外のストレージを使用したボリュームのこと。クラウドベンダー、NFS、などがある。

参考：https://zenn.dev/suiudou/articles/31ab107f3c2de6#%E2%96%A0kubernetes%E3%81%AE%E3%81%84%E3%82%8D%E3%82%93%E3%81%AA%E3%83%9C%E3%83%AA%E3%83%A5%E3%83%BC%E3%83%A0

<br>

## 02. コマンド

### apply

#### ・applyとは

同じ識別子（オブジェクト名）のオブジェクトが存在しない場合はオブジェクトを作成し、存在する場合はマニフェストファイルの差分を更新する。全ての項目を更新できるわけでない。

#### ・-f

マニフェストファイルを指定し、```apply```コマンドを実行する。

**＊実行例＊**

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

**＊実行例＊**

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

### cp

ホストPCのファイルまたはディレクトリを指定したポッド内のコンテナにコピーする。

``` bash
$kubectl cp <ホストPCのファイルパス> <名前空間>/<ポッドID>:<コンテナのファイルパス>
```

```bash
$kubectl cp <ホストPCのファイルパス> <名前空間>/<ポッドID>:<コンテナのディレクトリパス>/
```

<br>

### create

#### ・createとは

オブジェクトを作成する。同じ識別子（オブジェクト名）のオブジェクトが存在する場合は重複エラーになる。

#### ・-f

マニフェストファイルを指定し、```create```コマンドを実行する。

**＊実行例＊**

```bash
$ kubectl create -f ./kubernetes-manifests/foo-pod.yml

pod/foo-pod created
```

```bash
$ kubectl create -f ./kubernetes-manifests/foo-service.yml

service/foo-service created
```

<br>

### deploment

#### ・deploymentとは

ポッドを管理するレプリカセットを作成する。

#### ・-f

マニフェストファイルを指定し、```deployment```コマンドを実行する。

**＊実行例＊**

```bash
$ kubectl create deployment -f ./kubernetes-manifests/foo-deployment.yml
```

<br>

### get

#### ・getとは

オブジェクトを参照する。

#### ・node

構築済みのノードを表示する。

**＊実行例＊**

```bash
$ kubectl get nodes 

NAME             STATUS   ROLES                  AGE   VERSION
docker-desktop   Ready    control-plane,master   12h   v1.21.5 # マスターノード
```

#### ・pod

構築済みのポッドを表示する。

**＊実行例＊**

```bash
$ kubectl get pods

NAME       READY   STATUS             RESTARTS   AGE
foo-pod    0/2     ImagePullBackOff   0          7m52s
```

#### ・services

構築済みのサービスを表示する。

**＊実行例＊**

```bash
$ kubectl get services

NAME           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
foo-service    ClusterIP   nn.nnn.nnn.n   <none>        80/TCP    10s
kubernetes     ClusterIP   nn.nn.n.n      <none>        443/TCP   12h
```

<br>

### logs

#### ・logsとは

指定したオブジェクトのログを表示する。

#### ・オプション無し

**＊実行例＊**

コンテナのログを表示する。

```bash
$ kubectl logs <ポッド名> <コンテナ名>

2021/11/27 08:34:01 [emerg] *****
```

<br>

### proxy

#### ・proxyとは

Kubeプロキシを作成する。

参考：https://kubernetes.io/ja/docs/concepts/cluster-administration/proxies/

#### ・--address、--accept-hosts

```bash
$  kubectl proxy --address=0.0.0.0 --accept-hosts='.*'  

Starting to serve on [::]:8001
```

<br>

## 03. minikubeコマンド

### minikubeコマンドとは

仮想環境を構築し、また仮想環境下で単一のノードを持つクラスターを作成するコマンド。

参考：https://minikube.sigs.k8s.io/docs/commands/

<br>

### dashboard

#### ・dashboardとは

Kubernetesのダッシュボードを開発環境に構築する。

**＊実行例＊**

```bash
$ minikube dashboard

🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:55712/*****/ in your default browser...
```

<br>

### docker-env

#### ・docker-envとは

ホストPCでdockerコマンドを実行した時に、ホストPCのdockerデーモンでなく、minikubeの仮想環境のdockerデーモンをコールできるように、環境変数を設定する。イメージタグが```latest```であると、仮想環境外に対してイメージをプルしてしまうことに注意する。

参考：https://minikube.sigs.k8s.io/docs/commands/docker-env/

**＊実行例＊**

```bash
$ minikube docker-env

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://127.0.0.1:52838"
export DOCKER_CERT_PATH="/Users/***/.minikube/certs"
export MINIKUBE_ACTIVE_DOCKERD="minikube"

# To point your shell to minikube's docker-daemon, run:
# eval $(minikube -p minikube docker-env)
```

<br>

### ip

#### ・ipとは

minikubeの稼働するノードのIPアドレスを表示する。

#### ・オプションなし

```bash
$ minikube ip

192.168.49.2
```



<br>

### start

#### ・startとは

仮想環境をVMで構築し、VM内で単一のノードを作成する。

#### ・オプションなし

**＊実行例＊**

```bash
$ minikube start

😄  minikube v1.24.0 on Darwin 11.3.1
✨  Automatically selected the docker driver. Other choices: virtualbox, ssh
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.22.3 preload ...
    > preloaded-images-k8s-v13-v1...: 501.73 MiB / 501.73 MiB  100.00% 2.93 MiB
    > gcr.io/k8s-minikube/kicbase: 355.78 MiB / 355.78 MiB  100.00% 1.71 MiB p/
🔥  Creating docker container (CPUs=2, Memory=7911MB) ...
🐳  Preparing Kubernetes v1.22.3 on Docker 20.10.8 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

ノードが構築されていることを確認できる。

```bash
$ kubectl get nodes

NAME       STATUS   ROLES                  AGE   VERSION
minikube   Ready    control-plane,master   14m   v1.22.3
```

#### ・--driver

仮想環境の構築方法を指定し、```start```コマンドを実行する。

**＊実行例＊**

```bash
$ minikube start --driver docker
```
