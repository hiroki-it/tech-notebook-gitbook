# manifest.yml

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. apiVersion

Kubernetes-APIのバージョンを設定する。

```yaml
apiVersion: v1
```

<br>

## 02. kind

作成されるオブジェクトの種類を設定する。

| オブジェクト名                  | 補足                                                         |
| --------------------- | ------------------------------------------------------------ |
| Deployment            |                                                              |
| Ingress               | 他のオブジェクトとはapiVersionが異なり、```networking.k8s.io/v1```を指定する必要がある。 |
| Namespace |  |
| PersistentVolume      |                                                              |
| PersistentVolumeClaim |                                                              |
| Pod                   | PodをDeploymentやReplicaSetに紐づけずに使用することは非推奨である。<br>参考：https://kubernetes.io/ja/docs/concepts/configuration/overview/#naked-pods-vs-replicasets-deployments-and-jobs |
| ReplicaController     | 旧Deployment。非推奨である。<br>参考：https://stackoverflow.com/questions/37423117/replication-controller-vs-deployment-in-kubernetes |
| ReplicaSet            |                                                              |
| Service               |                                                              |
| StatefulSet           |                                                              |

<br>

## 03. metadata

### name

オブジェクトを一意に識別するための名前を設定する。

```yaml
metadata:
  name: foo
```

<br>

## 04. spec（Deploymentの場合）

### replicas

ポッドの複製数を設定する。

```yaml
kind: Deployment
spec:
  replicas: 1
```

<br>

### revisionHistoryLimit

保存されるリビジョン番号の履歴数を設定する。もし依存のリビジョン番号にロールバックすることがあるのであれば、必要数を設定しておく。

```yaml
kind: Deployment
spec:
  revisionHistoryLimit: 5
```

<br>

### selector

#### ・matchLabels

デプロイメントで管理するポッドのラベルを指定する。ポッドに複数のラベルが付与されている時は、これらを全て指定する必要がある。

参考：https://cstoku.dev/posts/2018/k8sdojo-08/#label-selector

```yaml
kind: Deployment
metadata:
  name: foo-pod
  labels:
    app: foo
spec:
  selector:
    matchLabels:
      app: foo
      type: web
  template:
    metadata:
      labels: # ポッドのラベル
        app: foo
        type: web
```

<br>

### strategy

#### ・RollingUpdate

ローリングアップデートを用いて、新しいポッドをデプロイする。

参考：https://kakakakakku.hatenablog.com/entry/2021/09/06/173014

```yaml
kind: Deployment
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 100% # ポッドのレプリカ数と同じ数だけ新しいポッドをデプロイする。
      maxUnavailable: 0% # ポッドの停止数がレプリカ数を下回らないようにする。
```

もし```maxSurge```オプションを```100```%、また```maxUnavailable```オプションを```0```%とすると、ローリングアップデート時に、ポッドのレプリカ数と同じ数だけ新しいポッドをデプロイするようになる。また、ポッドの停止数がレプリカ数を下回らないようになる。

![kubernetes_deployment_strategy](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_deployment_strategy.png)

<br>

### template

スケーリング時に複製の鋳型とするポッドを設定する。

**＊実装例＊**

```yaml
kind: Deployment
spec:
  template:
    metadata:
      labels:
        app: foo
    spec:
      containers:
        - name: foo-lumen
          image: foo-lumen:latest
          ports:
            - containerPort: 9000
        - name: foo-nginx
          image: foo-nginx:latest
          ports:
            - containerPort: 8000
```

<br>

## 04-02. spec（Ingressの場合）

### rules

サービスへのルーティングルールを設定する。複数のサービスにリクエストを振り分けられる。

```yaml
kind: Ingress
spec:
  rules:
    - http:
        paths:
          - path: /foo
            pathType: Prefix
            backend:
              service:
                name: foo-service
                port:
                  number: 80
    - http:
        paths:
          - path: /bar
            pathType: Prefix
            backend:
              service:
                name: bar-service
                port:
                  number: 80
```

<br>

## 04-03. spec（Namespaceの場合）

### labels

他のオブジェクトの```label```とは異なり、何らかの機能を有効化するための設定値になることがある。

**＊実装例＊**

Istioを有効化する。

```yaml
kind: Namespace
metadata:
  labels:
    istio-injection: enabled
```

<br>

## 04-04. spec（PersistentVolumeの場合）

### accessModes


#### ・ReadWriteMany

複数ノードから読み出し/書き込みできる。ノード間でDBを共有したい場合に使用する。

**＊実装例＊**

```yaml
kind: PersistentVolume
spec:
  accessModes:
    - ReadWriteMany
```

#### ・ReadOnlyMany

複数ノードから読み出しでき、また単一ノードのみから書き込みできる。ノード間で読み出し処理のみDBを共有したい場合に使用する。

**＊実装例＊**

```yaml
kind: PersistentVolume
spec:
  accessModes:
    - ReadOnlyMany
```

#### ・ReadWriteOnce

単一ノードからのみ読み出し/書き込みできる。ノードごとにDBを分割したい場合に使用する。

**＊実装例＊**

```yaml
kind: PersistentVolume
spec:
  accessModes:
    - ReadWriteOnce
```

<br>

### capacity

**＊実装例＊**

```yaml
kind: PersistentVolume
spec:
  capacity:
    storage: 10G
```

<br>

### mountOptions

**＊実装例＊**

```yaml
kind: PersistentVolume
spec:
  mountOptions:
    - hard
```

<br>

### nfs

```yaml
kind: PersistentVolume
spec:
  nfs:
    server: nnn.nnn.nnn.nnn
    path: /nfs/foo
```

<br>

### persistentVolumeReclaimPolicy

#### ・Delete

PersistentVolumeを指定する```spec.persistentVolumeClaim```が削除された場合に、PersistentVolumeも自動的に削除する。

**＊実装例＊**

```yaml
kind: PersistentVolume
spec:
  persistentVolumeReclaimPolicy: Delete
```

#### ・Recycle

PersistentVolumeを指定する```spec.persistentVolumeClaim```が削除された場合に、PersistentVolume内のデータのみを削除し、PersistentVolume自体は削除しない。

**＊実装例＊**

```yaml
kind: PersistentVolume
spec:
  persistentVolumeReclaimPolicy: Recycle
```

#### ・Retain

PersistentVolumeを指定する```spec.persistentVolumeClaim```が削除されたとしても、PersistentVolumeは削除しない。

**＊実装例＊**

```yaml
kind: PersistentVolume
spec:
  persistentVolumeReclaimPolicy: Retain
```

<br>

### storageClassName

#### ・fast

SSDをPersistentVolumeとして使用する。

参考：https://kubernetes.io/ja/docs/concepts/storage/_print/#%E5%8B%95%E7%9A%84%E3%83%97%E3%83%AD%E3%83%93%E3%82%B8%E3%83%A7%E3%83%8B%E3%83%B3%E3%82%B0%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%99%E3%82%8B

**＊実装例＊**

```yaml
kind: PersistentVolume
spec:
  storageClassName: fast
```

#### ・slow

HDをPersistentVolumeとして使用する。

参考：https://kubernetes.io/ja/docs/concepts/storage/_print/#%E5%8B%95%E7%9A%84%E3%83%97%E3%83%AD%E3%83%93%E3%82%B8%E3%83%A7%E3%83%8B%E3%83%B3%E3%82%B0%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%99%E3%82%8B

**＊実装例＊**

```yaml
kind: PersistentVolume
spec:
  storageClassName: slow
```

<br>

## 04-05. spec（PersistentVolumeClaimの場合）

### accessModes

**＊実装例＊**

```yaml
kind: PersistentVolumeClaim
spec:
  accessModes:
    - ReadWriteMany
```

<br>

### resources

**＊実装例＊**

```yaml
kind: PersistentVolumeClaim
spec:
  resources:
    - ReadWriteMany
```

<br>

## 04-06. spec（Podの場合）

### containers

#### ・name、image、port

ポッドを構成するコンテナの名前、ベースイメージ、受信ポートを設定する。

**＊実装例＊**

```yaml
kind: Pod
spec:
  containers:
    - name: foo-lumen
      image: foo-lumen:latest
      ports:
        - containerPort: 9000
    - name: foo-nginx
      image: foo-nginx:latest
      ports:
        - containerPort: 8000
```

#### ・volumeMount

ボリュームマウントを実行する。```spec.volume```で設定されたボリュームのうちから、コンテナにマウントするボリュームを設定する。

**＊実装例＊**

```yaml
kind: Pod
spec:
  containers:
    - name: foo-lumen
      image: foo-lumen:latest
      ports:
        - containerPort: 9000
      volumeMounts:
         - name: foo-nginx
           mountPath: /var/www/foo
    - name: foo-lumen
      image: foo-lumen:latest
      ports:
        - containerPort: 9000
      volumeMounts:
         - name: foo-nginx
           mountPath: /var/www/foo           
```

<br>

### hostname

ポッドのホスト名を設定する。また、```spec.hostname```が設定されていない時は、```metadata.name```がホスト名として使用される。

参考：https://kubernetes.io/ja/docs/concepts/services-networking/dns-pod-service/#pod%E3%81%AEhostname%E3%81%A8subdomain%E3%83%95%E3%82%A3%E3%83%BC%E3%83%AB%E3%83%89

**＊実装例＊**

```yaml
kind: Pod
spec:
  hostname: foo-pod
```

<br>

### volume

#### ・name

要求によって作成するボリューム名を設定する。

#### ・persistentVolumeClaim.claimName

使用するPersistentVolumeClaimオブジェクトの名前を設定する。

参考：https://kubernetes.io/ja/docs/concepts/storage/persistent-volumes/

**＊実装例＊**

```yaml
kind: Pod
spec:
  volumes
    - name: foo-volume
      persistentVolumeClaim:
        claimName: foo-slow-volume-claim
```

persistentVolumeは別途作成しておく必要がある。

**＊実装例＊**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: foo-slow-volume-claim
  labels:
    app: foo
spec:
  storageClassName: slow
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

#### ・emptyDir

EmptyDirボリュームを作成する。そのため、『ポッド』が削除されるとこのボリュームも同時に削除される。

参考：

- https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
- https://qiita.com/umkyungil/items/218be95f7a1f8d881415

**＊実装例＊**

```yaml
kind: Pod
spec:
  volumes
    - name: foo-lumen
      emptyDir: {}
    - name: foo-nginx
      emptyDir: {}
```

#### ・hostPath

HostPathボリュームを作成する。そのため、『ノード』が削除されるとこのボリュームも同時に削除される。

参考：

- https://kubernetes.io/docs/concepts/storage/volumes/#hostpath
- https://qiita.com/umkyungil/items/218be95f7a1f8d881415

**＊実装例＊**

```yaml
kind: Pod
spec:
  volumes
  - name: foo-lumen
    hostPath:
      path: /data
      type: DirectoryOrCreate # コンテナ内にディレクトリがなければ作成する
```

<br>

## 04-07. spec（Serviceの場合）

### ports

#### ・protocol

サービスでリクエストを受信するために、受信プロトコルを設定する。

**＊実装例＊**

```yaml
kind: Service
spec:
  ports:
  - protocol: TCP
```

#### ・port

サービスでリクエストを受信するために、受信ポートを設定する。

**＊実装例＊**

```yaml
kind: Service
spec:
  ports:
  - port: 80
```

####  ・targetPort

ポッドに対してリクエストを転送するために、転送先ポートを設定する。ポッド内で最初にリクエストを受信するコンテナの```containerPort```の番号に合わせるようにする。

**＊実装例＊**

```yaml
kind: Service
spec:
  ports:
  - targetPort: 9376
```

<br>

### selector

リクエストの転送先とするポッドのラベルのキー名と値を設定する。

参考：https://v1-18.docs.kubernetes.io/ja/docs/concepts/overview/working-with-objects/labels/

**＊実装例＊**

```yaml
kind: Service
spec:
  selector:
    app: foo
```

<br>

### type

サービスのタイプを設定する。

参考：

- https://zenn.dev/smiyoshi/articles/c86fc3532b4f8a
- https://www.netone.co.jp/knowledge-center/netone-blog/20210715-01/

| 値                        | IPアドレスの公開範囲   |
| ------------------------- | ---------------------- |
| ClusterIP（デフォルト値） | クラスター内部からのみ |
| NodePort                  | クラスター外部/内部   |
| LoadBalancer              | クラスター外部/内部   |

<br>

## 04-08. spec（StatefulSetの場合）

### volumeClaimTemplates

PersistentVolumeClaimを作成する。設定の項目は```kind: PersistentVolumeClaim```の場合と同じである。StatefulSetが削除されても、これは削除されない。

**＊実装例＊**

```yaml
kind: StatefulSet
spec:
  volumeClaimTemplates:
    - metadata:
        name: foo-slow-volume-claim
        labels:
          app: foo
      spec:
        storageClassName: slow
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 2Gi
```


