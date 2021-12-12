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

### kubernetesクライアント

#### ・kubernetesクライアントとは

kubernetesクライアントは、kubectlコマンドを使用して、kubernetesマスターAPIをコールできる。

<br>

### kubernetesマスター（マスターノード）

#### ・kubernetesマスターとは

ワーカーノードの操作を担う。『マスターノード』ともいう。クライアントがkubectlコマンドの実行すると、kube-apiserverがコールされ、コマンドに沿ってワーカーノードが操作される。

参考：https://kubernetes.io/ja/docs/concepts/#kubernetes%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC

#### ・cloud-controller-manager

kub-apiserverとクラウドインフラを仲介し、Kubernetesがクラウドインフラを操作できるようにする。

![kubernetes_cloud-controller-manager](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_cloud-controller-manager.png)

#### ・etcd

クラスターの様々な設定値を保持し、冗長化されたオブジェクト間にこれを共有する。

参考：https://thinkit.co.jp/article/17453

![kubernetes_etcd](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_etcd.png)

#### ・kube-apiserver

kubernetesクライアントにkueneretes-APIを公開する。クライアントがkubernetesコマンドを実行すると、kubernetes-APIがコールされ、コマンドに沿ってオブジェクトが操作される。

参考：https://thinkit.co.jp/article/17453

![kubernetes_kube-apiserver](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_kube-apiserver.png)

#### ・kube-controller-manager

様々なコントローラを統括的に実行する。

参考：https://thinkit.co.jp/article/17453

#### ・kuebe-scheduler

ワーカーノードとポッドのスペックに基づいて、ワーカーノードに配置される適切なポッド数を決定する。

参考：https://thinkit.co.jp/article/17453

![kubernetes_kube-scheduler](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_kube-scheduler.png)

<br>

### クラスター

#### ・クラスターとは

ワーカーノードの管理単位のこと。

<br>

### ワーカーノード

#### ・ワーカーノードとは

ポッドが稼働するサーバ単位こと。

参考：https://kubernetes.io/ja/docs/concepts/architecture/nodes/

#### ・コンテナランタイム（コンテナエンジン）

イメージのプル、コンテナ構築削除、コンテナ起動停止、などを行う。

参考：https://thinkit.co.jp/article/17453

#### ・kubelet

kube-apiserverからコールされる。ワーカーノードのコンテナランタイムを操作し、ポッドを作成する。

参考：https://thinkit.co.jp/article/17453

![kubernetes_kubelet](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_kubelet.png)

#### ・kube-proxy

ワーカーノード外からのリクエストをポッドに転送する。モードごとに、ポッドの名前解決の方法が異なる。

参考：https://qiita.com/tkusumi/items/c2a92cd52bfdb9edd613

| モード    | 説明                                                         | 補足                                                         |
| --------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| iptables  | ![kubernetes_kube-proxy_iptables](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_kube-proxy_iptables.png) | 参考：https://kubernetes.io/ja/docs/concepts/services-networking/service/#proxy-mode-iptables |
| userspace | ![kubernetes_kube-proxy_userspace](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_kube-proxy_userspace.png) | 参考：https://kubernetes.io/ja/docs/concepts/services-networking/service/#proxy-mode-userspace |
| ipvs      | ![kubernetes_kube-proxy_ipvs](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_kube-proxy_ipvs.png) | 参考：https://kubernetes.io/ja/docs/concepts/services-networking/service/#proxy-mode-ipvs |

#### ・ポッド

コンテナの最小グループ単位のこと。Podを単位として、コンテナ起動／停止や水平スケールイン／スケールアウトを実行する。

参考：https://kubernetes.io/ja/docs/concepts/workloads/pods/

AWS ECSタスクにおける類似するessential機能やオートスケーリングについては、以下のリンクを参考にせよ。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/cloud_computing/cloud_computing_aws.html

同じポッド内のコンテナ間は、『```localhost:<ポート番号>```』で通信できる。

参考：https://www.tutorialworks.com/kubernetes-pod-communication/#how-do-containers-in-the-same-pod-communicate

異なるポッドのコンテナ間は、サービスを経由して通信できる。

参考：https://kubernetes.io/docs/concepts/cluster-administration/networking/

**＊例＊**

PHP-FPMコンテナとNginxコンテナを稼働させる場合、これら同じPodに配置する。

![kubernetes_pod_php-fpm_nginx](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_pod_php-fpm_nginx.png)

<br>

### サービス

#### ・サービスとは

サービスタイプごとに、特定のネットワーク範囲にポッドを公開する。マイクロサービスアーキテクチャのコンポーネントである『サービス』とは区別する。

参考：https://kubernetes.io/ja/docs/concepts/services-networking/service/

#### ・ClusterIPサービス

クラスターのIPアドレスを返却し、サービスに対するリクエストをポッドに転送する。クラスター内部からのみアクセスできる。

参考：https://thinkit.co.jp/article/18263

#### ・LoadBalancerサービス

ロードバランサーのみからアクセスできるIPアドレスを返却し、サービスに対するリクエストをポッドに転送する。クラスター外部／内部の両方からアクセスできる。本番環境をクラウドインフラ上で稼働させ、AWS ALBからリクエストを受信する場合に使用する。ロードバランサーから各サービスにリクエストを転送することになるため、通信数が増え、金銭的負担が大きい。

参考：

- https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0
- https://thinkit.co.jp/article/18263

#### ・NodePortサービス

ノードのIPアドレスを返却し、サービスの指定したポートに対するリクエストをポッドに転送する。クラスター外部／内部の両方からアクセスできる。１つのポートから１つのサービスにしか転送できない。サービスノードのIPアドレスは別に確認する必要があり、ノードのIPアドレスが変わるたびに、これに合わせて他の設定を変更しなければならず、本番環境には向いていない。AWSのAurora RDSのクラスターエンドポイントには、NodePortの概念が取り入れられている。

参考：

- https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0
- https://thinkit.co.jp/article/18263

#### ・ExternalNameサービス

ポッドのCNAMEを返却し、サービスに対するリクエストをポッドに転送する。

参考：https://thinkit.co.jp/article/13739

#### ・Headlessサービス

ポッドのIPアドレスを返却し、サービスに対するリクエストをポッドに転送する。ポッドが複数ある場合は、DNSラウンドロビンのルールでIPアドレスが返却される。

参考：https://thinkit.co.jp/article/13739

<br>

### イングレス

#### ・イングレスとは

![kubernetes_ingress](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_ingress.png)

クラスター外部からのリクエストを受信し、サービスに転送する。NodePortサービスやLoadBalancerサービスと同様に、外部からのリクエストを受信する方法の１つである。

参考：

- https://kubernetes.io/docs/concepts/services-networking/ingress/#what-is-ingress
- https://thinkit.co.jp/article/18263

<br>

### シークレット

#### ・シークレットとは

セキュリティに関するデータを管理し、コンテナに選択的に提供する。

<br>

### レプリカセット

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

#### ・HostPath（本番では非推奨）

ノードのストレージを使用したボリュームのこと。ホストとポッド内コンテナ間のバインドマウントによって作成され、ノード上のポッド間でボリュームを共有できる。

参考：https://qiita.com/umkyungil/items/218be95f7a1f8d881415

以下の通り、HostPathではバインドマウントが使用されていることを確認できる。

```bash
# ノード内でdockerコマンドを実行
$ docker inspect c38b90c9c9e9

        # 〜 中略 〜

        "HostConfig": {
            "Binds": [
                "/data:/var/www/foo",
                "/var/lib/kubelet/pods/*****/volumes/kubernetes.io~projected/kube-api-access-*****:/var/run/secrets/kubernetes.io/serviceaccount:ro",
                "/var/lib/kubelet/pods/*****/etc-hosts:/etc/hosts",
                "/var/lib/kubelet/pods/*****/containers/foo/*****:/dev/termination-log"
            ],
            
            # 〜 中略 〜
        },
        
        # 〜 中略 〜
        
        "Mounts": [
        
            # 〜 中略 〜
            
            {
                "Type": "bind", # バインドマウントが使用されている。
                "Source": "/data",
                "Destination": "/var/www/foo",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },

            # 〜 中略 〜
```

#### ・EmptyDir

ポッドのストレージを使用したボリュームのこと。そのため、ポッドが削除されると、このボリュームも同時に削除される。ボリュームマウントによって作成され、ノード上のポッド間でボリュームを共有できない。

参考：https://qiita.com/umkyungil/items/218be95f7a1f8d881415

#### ・外部ボリューム

Kubernetes外のストレージを使用したボリュームのこと。クラウドベンダー、NFS、などがある。

参考：https://zenn.dev/suiudou/articles/31ab107f3c2de6#%E2%96%A0kubernetes%E3%81%AE%E3%81%84%E3%82%8D%E3%82%93%E3%81%AA%E3%83%9C%E3%83%AA%E3%83%A5%E3%83%BC%E3%83%A0

<br>

## 02. コマンド

### apply

#### ・applyとは

同じ識別子（オブジェクト名）のオブジェクトが存在しない場合はオブジェクトを作成し、存在する場合はマニフェストファイルの差分を更新する。全ての項目を更新できるわけでない。

参考：https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply

**＊実行例＊**

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

#### ・configとは

kubernetesコマンドに関するパラメータを操作する。

参考：https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#config

#### ・view

パラメータのデフォルト値が設定された```~/.kude/config```ファイルを表示する。

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

#### ・cpとは

ホストPCのファイルまたはディレクトリを指定したポッド内のコンテナにコピーする。

参考：https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#cp

#### ・オプション無し

```bash
$kubectl cp <ホストPCのファイルパス> <名前空間>/<ポッドID>:<コンテナのファイルパス>
```

```bash
$kubectl cp <ホストPCのファイルパス> <名前空間>/<ポッドID>:<コンテナのディレクトリパス>/
```

<br>

### create

#### ・createとは

様々なオブジェクトを作成する。```expose```コマンドと```run```コマンドで作成できるオブジェクトを含む様々なものを作成できるが、オプションが少ない。そのため、```f```オプションでマニフェストファイルを指定し、おぶえジェクトを作成した方が良い。同じ識別子（オブジェクト名）のオブジェクトが存在する場合は重複エラーになる。

参考：https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create

**＊実行例＊**

マニフェストファイルを指定し、```create```コマンドを実行する。

```bash
$ kubectl create -f ./kubernetes-manifests/foo-pod.yml

pod/foo-pod created
```

```bash
$ kubectl create -f ./kubernetes-manifests/foo-service.yml

service/foo-service created
```

#### ・deployment

ポッド数を維持管理するレプリカセットを作成する。ポッドを削除するためには、デプロイメント自体を削除しなければならない。

**＊実行例＊**

```bash
$ kubectl create deployment -f ./kubernetes-manifests/foo-deployment.yml
```

<br>

### exec

#### ・execとは

指定したポッド内のコンテナでコマンドを実行する。

参考：https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec

**＊実行例＊**

コンテナを指定して、 ```exec```コマンドを実行する。コンテナを指定しない場合は、デフォルトのコンテナが選ばれる。ポッドのラベル名ではなく、ポッド名であることに注意する。

```bash
$ kubectl exec -it <ポッド名> -c <コンテナ名> -- bash
```

```bash
$ kubectl exec -it <ポッド名> -- bash

Defaulted container "foo-container" out of: foo-container, bar-container
```

デタッチモードを用いて、起動中コンテナ内でコマンドを実行する。

```bash
$ kubectl exec -it <ポッド名> -- bash
```

<br>

### expose

#### ・exposeとは

サービスを作成する。

参考：

- https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#expose
- https://qiita.com/sourjp/items/f0c8c8b4a2a494a80908

**＊実行例＊**

ClusterIPサービスを作成する。

```bash
$ kubectl expose <サービス名> --type=ClusterIP --port=<受信ポート番号> --target-port=<転送先ポート番号>
```

NodePortサービスを作成する。

```bash
$ kubectl expose <サービス名> --type=NodePort --port=<受信ポート番号> --target-port=<転送先ポート番号>
```

LoadBalancerサービスを作成する。

```bash
$ kubectl expose <サービス名> --type=LoadBalancer --port=<受信ポート番号> --target-port=<転送先ポート番号>
```



<br>

### get

#### ・getとは

オブジェクトを参照する。

参考：https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get

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

参考：https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs

#### ・オプション無し

**＊実行例＊**

ポッド名とコンテナ名を指定し、コンテナのログを表示する。

```bash
$ kubectl logs -n <名前空間> <ポッド名> -c <コンテナ名>

2021/11/27 08:34:01 [emerg] *****
```

名前空間、ポッド名、コンテナ名を指定し、kube-proxyのログを確認する。

```bash
kubectl logs -n kube-system <ポッド名> -c kube-proxy

I1211 05:34:22.262955       1 node.go:172] Successfully retrieved node IP: nnn.nnn.nn.n
I1211 05:34:22.263084       1 server_others.go:140] Detected node IP nnn.nnn.nn.n
W1211 05:34:22.263104       1 server_others.go:565] Unknown proxy mode "", assuming iptables proxy
I1211 05:34:22.285367       1 server_others.go:206] kube-proxy running in dual-stack mode, IPv4-primary
I1211 05:34:22.285462       1 server_others.go:212] Using iptables Proxier.
I1211 05:34:22.285484       1 server_others.go:219] creating dualStackProxier for iptables.
W1211 05:34:22.285508       1 server_others.go:495] detect-local-mode set to ClusterCIDR, but no IPv6 cluster CIDR defined, , defaulting to no-op detect-local for IPv6
I1211 05:34:22.286807       1 server.go:649] Version: v1.22.3
I1211 05:34:22.289459       1 config.go:315] Starting service config controller
I1211 05:34:22.289479       1 shared_informer.go:240] Waiting for caches to sync for service config
I1211 05:34:22.289506       1 config.go:224] Starting endpoint slice config controller
I1211 05:34:22.289525       1 shared_informer.go:240] Waiting for caches to sync for endpoint slice config
I1211 05:34:22.389800       1 shared_informer.go:247] Caches are synced for endpoint slice config 
I1211 05:34:22.389956       1 shared_informer.go:247] Caches are synced for service config 
```

<br>

### port-forward

#### ・port-forwardとは

ホストのポートから指定したオブジェクトのポートに対して、ポートフォワーディングを実行する。開発環境にて、サービスを経由せずに直接ポッドにリクエストを送信したい場合や、SQLクライアントを用いてポッド内のDBコンテナにTCP/IP接続したい場合に使用する。

参考：

- https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/#forward-a-local-port-to-a-port-on-the-pod
- https://stackoverflow.com/questions/53898627/mysql-remote-connect-over-ssh-to-a-kubernetes-pod

**＊実行例＊**

```bash
$ kubectl port-forward <ポッド名> <ホストポート>:<ポッドポート>
```

<br>

### proxy

#### ・proxyとは

ローカルホストとkube-apiserverの間にプロキシとして機能するオブジェクトを作成する。kube-proxyとは異なるオブジェクトであることに注意する。

参考：https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#proxy

**＊実行例＊**

```bash
$ kubectl proxy --address=0.0.0.0 --accept-hosts='.*'  

Starting to serve on [::]:8001
```

<br>

### run

#### ・runとは

デプロイメント、ポッド、ジョブを作成する。

参考：https://qiita.com/sourjp/items/f0c8c8b4a2a494a80908

**＊実行例＊**

もし```restart```オプションが```Always```なら、デプロイメントが作成される。


```bash
$ kubectl run <デプロイメント名> --restart=Always --image=<イメージ名>:<タグ名> --port=<ポート番号>
```

もし```restart```オプションが```Never```なら、ポッドが作成される。

```bash
$ kubectl run <ポッド名> --restart=Never --image=<イメージ名>:<タグ名> --port=<ポート番号>
```

もし```restart```オプションが```OnFailure```なら、ジョブが作成される。

```bash
$ kubectl run <ジョブ名> --restart=OnFailure --image=<イメージ名>:<タグ名> --port=<ポート番号>
```

