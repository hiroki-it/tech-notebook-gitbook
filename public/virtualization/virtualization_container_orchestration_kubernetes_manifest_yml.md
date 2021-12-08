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

オブジェクトの種類を設定する。

```yaml
kind: Service
```

| 種類                  | 補足                                                         |
| --------------------- | ------------------------------------------------------------ |
| Deployment            |                                                              |
| Service               |                                                              |
| PersistentVolume      |                                                              |
| PersistentVolumeClaim |                                                              |
| Pod                   | PodをDeploymentやReplicaSetに紐づけずに使用することは非推奨である。<br>参考：https://kubernetes.io/ja/docs/concepts/configuration/overview/#naked-pods-vs-replicasets-deployments-and-jobs |
| ReplicaController     | 旧Deployment。非推奨である。<br>参考：https://stackoverflow.com/questions/37423117/replication-controller-vs-deployment-in-kubernetes |
| ReplicaSet            |                                                              |

<br>

## 03. metadata

### name

オブジェクトを一意に識別するための名前を設定する。

```yaml
metadata:
  name: foo-service
```

<br>

## 05. spec（Deploymentの場合）

### template

スケーリング時に複製の鋳型とするポッドを設定する。

```yaml
spec:
  template:
    metadata:
      labels:
        app: foo
    spec:
      containers:
        - name: foo-lumen
          image: foo-lumen:dev
          ports:
            - containerPort: 9000
        - name: foo-nginx
          image: foo-nginx:dev
          ports:
            - containerPort: 8000
```

<br>

## 05-02. spec（PersistentVolumeの場合）

### accessModes


#### ・ReadWriteMany

複数ノードから読み出し／書き込みできる。ノード間でDBを共有したい場合に使用する。

```yaml
spec:
  accessModes:
    - ReadWriteMany
```

#### ・ReadOnlyMany

複数ノードから読み出しでき、また単一ノードのみから書き込みできる。ノード間で読み出し処理のみDBを共有したい場合に使用する。

```yaml
spec:
  accessModes:
    - ReadOnlyMany
```

#### ・ReadWriteOnce


単一ノードからのみ読み出し／書き込みできる。ノードごとにDBを分割したい場合に使用する。

```yaml
spec:
  accessModes:
    - ReadWriteOnce
```



<br>

### capacity

```yaml
spec:
  capacity:
    storage: 10G
```

<br>

### mountOptions

```yaml
spec:
  mountOptions:
    - hard
```

<br>

### nfs

```yaml
spec:
  nfs:
    server: nnn.nnn.nnn.nnn
    path: /nfs/foo
```

<br>

### persistentVolumeReclaimPolicy

#### ・Delete

PersistentVolumeを指定する```spec.persistentVolumeClaim```が削除された場合に、PersistentVolumeも自動的に削除する。

```yaml
spec:
  persistentVolumeReclaimPolicy: Delete
```

#### ・Recycle

PersistentVolumeを指定する```spec.persistentVolumeClaim```が削除された場合に、PersistentVolume内のデータのみを削除し、PersistentVolume自体は削除しない。

```yaml
spec:
  persistentVolumeReclaimPolicy: Recycle
```

#### ・Retain

PersistentVolumeを指定する```spec.persistentVolumeClaim```が削除されたとしても、PersistentVolumeは削除しない。

```yaml
spec:
  persistentVolumeReclaimPolicy: Retain
```

<br>

### storageClassName

#### ・fast

SSDをPersistentVolumeとして使用する。

参考：https://kubernetes.io/ja/docs/concepts/storage/_print/#%E5%8B%95%E7%9A%84%E3%83%97%E3%83%AD%E3%83%93%E3%82%B8%E3%83%A7%E3%83%8B%E3%83%B3%E3%82%B0%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%99%E3%82%8B

```yaml
spec:
  storageClassName: fast
```

#### ・slow

HDをPersistentVolumeとして使用する。

参考：https://kubernetes.io/ja/docs/concepts/storage/_print/#%E5%8B%95%E7%9A%84%E3%83%97%E3%83%AD%E3%83%93%E3%82%B8%E3%83%A7%E3%83%8B%E3%83%B3%E3%82%B0%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%99%E3%82%8B

```yaml
spec:
  storageClassName: slow
```

<br>

## 05-03. spec（PersistentVolumeClaimの場合）

### accessModes

```yaml
spec:
  accessModes:
    - ReadWriteMany
```

<br>

### resources

```yaml
spec:
  resources:
    - ReadWriteMany
```

<br>

## 05-04. spec（Podの場合）

### containers

#### ・name、image、port

ポッドを構成するコンテナの名前、ベースイメージ、受信ポートを設定する。

```yaml
spec:
  containers:
    - name: foo-lumen
      image: foo-lumen:dev
      ports:
        - containerPort: 9000
    - name: foo-nginx
      image: foo-nginx:dev
      ports:
        - containerPort: 8000
```

#### ・volumeMount

ボリュームマウントを実行する。```spec.volume```で設定されたボリュームのうちから、コンテナにマウントするボリュームを設定する。

```yaml
spec:
  containers:
    - name: foo-lumen
      image: foo-lumen:dev
      ports:
        - containerPort: 9000
      volumeMounts:
         - name: foo-nginx
           mountPath: /var/www/foo
    - name: foo-lumen
      image: foo-lumen:dev
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

```yaml
spec:
  hostname: foo-pod
```

<br>

### volume

#### ・name

ボリューム名を設定する。

#### ・persistentVolumeClaim.claimName

使用するPersistentVolumeClaimオブジェクトの名前を設定する。persistentVolumeは別途作成しておく必要がある。

参考：https://kubernetes.io/ja/docs/concepts/storage/persistent-volumes/

```yaml
spec:
  volumes
    - name: foo-db
      persistentVolumeClaim:
        claimName: foo-persistent-volume
```

#### ・emptyDir

EmptyDirボリュームを作成する。そのため、『ポッド』が削除されるとこのボリュームも同時に削除される。

参考：

- https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
- https://qiita.com/umkyungil/items/218be95f7a1f8d881415

```yaml
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

```yaml
  volumes:
  - name: foo-lumen
    hostPath:
      path: /data
      type: DirectoryOrCreate # コンテナ内にディレクトリがなければ作成する
```

<br>

## 05-05. spec（Serviceの場合）

### ports

#### ・protocol

サービスでリクエストを受信するために、受信プロトコルを設定する。

```yaml
spec:
  ports:
  - protocol: TCP
```

#### ・port

サービスでリクエストを受信するために、受信ポートを設定する。

```yaml
spec:
  ports:
  - port: 80
```

####  ・targetPort

ポッドに対してリクエストを転送するために、転送先ポートを設定する。

```yaml
spec:
  ports:
  - targetPort: 9376
```

<br>

### selector

リクエストの転送先とするポッドのラベルのキー名と値を設定する。

参考：https://v1-18.docs.kubernetes.io/ja/docs/concepts/overview/working-with-objects/labels/

```yaml
spec:
  selector:
    app: foo
```

<br>

### type

ポッドの公開方法の種類を設定する。

参考：

- https://zenn.dev/smiyoshi/articles/c86fc3532b4f8a
- https://www.netone.co.jp/knowledge-center/netone-blog/20210715-01/

| 値           | ポッドへのリクエスト転送方法                                 | IPアドレスの公開範囲   |
| ------------ | ------------------------------------------------------------ | ---------------------- |
| ClusterIP    | クラスターにIPアドレスを割り当て、これに対するリクエストをポッドに転送する。 | クラスター内部からのみ |
| NodePort     | ノードのIPアドレスにおける特定のポートに対するリクエストをポッドに転送する。ノードのIPアドレスは別に確認する必要がある。 | クラスター外部／内部   |
| LoadBalancer | ロードバランサーからアクセスできるIPアドレスを割り当て、これに対するリクエストをポッドに転送する。 | クラスター外部／内部   |

<br>
