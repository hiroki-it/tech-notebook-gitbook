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

#### ・確認方法

```bash
# ポッドに接続する
kubectl exec -it foo-pod-***** -c foo-container -- bash

# ストレージを表示する
[root@*****:/var/www/html] df -h

Filesystem      Size  Used Avail Use% Mounted on
overlay          59G   36G   20G  65% /
tmpfs            64M     0   64M   0% /dev
tmpfs           3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/vda1        59G   36G   20G  65% /etc/hosts
shm              64M     0   64M   0% /dev/shm
overlay          59G   36G   20G  65% /var/www/foo # 作成したボリューム
tmpfs           7.8G   12K  7.8G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs           3.9G     0  3.9G   0% /proc/acpi
tmpfs           3.9G     0  3.9G   0% /sys/firmware
```

#### ・PersistentVolume

ノードのストレージを使用したボリュームのこと。ボリュームマウントによって作成され、ノード上のポッド間でボリュームを共有できる。ポッドがPersistentVolumeを使用するためには、PersistentVolumeClaimオブジェクトにPersistentVolumeを要求させておき、ポッドでこのPersistentVolumeClaimオブジェクトを指定する必要がある。

参考：https://thinkit.co.jp/article/14195

#### ・EmptyDir

ポッドのストレージを使用したボリュームのこと。ボリュームマウントによって作成され、ノード上のポッド間でボリュームを共有できない。ポッドのストレージをボリュームとして使用するため、ポッドが削除されると、このボリュームも同時に削除される。

参考：https://zenn.dev/suiudou/articles/31ab107f3c2de6#%E2%96%A0kubernetes%E3%81%AE%E3%81%84%E3%82%8D%E3%82%93%E3%81%AA%E3%83%9C%E3%83%AA%E3%83%A5%E3%83%BC%E3%83%A0

#### ・HostPath

ノードのストレージを使用したボリュームのこと。ホストOSとポッド内コンテナ間のボリュームマウントによって作成され、ノード上のポッド間でボリュームを共有できる。非推奨であり、ホストOSとノード間でボリュームマウントを実行する```mount```コマンドが推奨である。

参考：https://zenn.dev/suiudou/articles/31ab107f3c2de6

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

### exec

#### ・execとは

指定したポッド内のコンテナでコマンドを実行する。

#### ・-c

コンテナを指定して、 ```exec```コマンドを実行する。コンテナを指定しない場合は、デフォルトのコンテナが選ばれる。ポッドのラベル名ではなく、ポッド名であることに注意する。

＊実行例＊

```bash
$ kubectl exec -it <ポッド名> -c <コンテナ名> -- bash
```

```bash
$ kubectl exec -it <ポッド名> -- bash

Defaulted container "foo-container" out of: foo-container, bar-container
```

#### ・-it

デタッチモードを用いて、起動中コンテナ内でコマンドを実行する。

```bash
$ kubectl exec -it <ポッド名> -- bash
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
$ kubectl proxy --address=0.0.0.0 --accept-hosts='.*'  

Starting to serve on [::]:8001
```

