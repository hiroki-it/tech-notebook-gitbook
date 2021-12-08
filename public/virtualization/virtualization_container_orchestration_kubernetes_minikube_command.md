# minikubeコマンド

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. minikubeコマンド

### minikubeコマンドとは

ゲスト仮想環境を構築し、また仮想環境下で単一のノードを持つクラスターを作成するコマンド。

参考：https://minikube.sigs.k8s.io/docs/commands/

<br>

### config

#### ・configとは

minikubeコマンドに関するパラメータを操作する。

#### ・set

パラメータのデフォルト値を設定する。

**＊実行例＊**

```bash
$ minikube config set driver virtualbox
```

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

ホストでdockerコマンドを実行した時に、ホスト側のdockerデーモンでなく、ゲスト仮想環境内のノードのdockerデーモンをコールできるように環境変数を設定する。イメージタグが```latest```であると、仮想環境外に対してイメージをプルしてしまうことに注意する。

参考：https://minikube.sigs.k8s.io/docs/commands/docker-env/

**＊実行例＊**

```bash
$ minikube docker-env

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://127.0.0.1:52838"
export DOCKER_CERT_PATH="/Users/*****/.minikube/certs"
export MINIKUBE_ACTIVE_DOCKERD="minikube"

# To point your shell to minikube's docker-daemon, run:
# eval $(minikube -p minikube docker-env)

$ eval $(minikube -p minikube docker-env)
```

<br>

### ip

#### ・ipとは

ゲスト仮想環境内のノードのIPアドレスを表示する。

#### ・オプションなし

```bash
$ minikube ip

192.168.49.2
```

<br>

### mount

#### ・mountとは

ホスト側のファイルまたはディレクトリを、ゲスト仮想環境の指定したディレクトリにマウントする。

参考：https://minikube.sigs.k8s.io/docs/handbook/mount/

#### ・オプション無し

```bash
❯ minikube mount /Users/hiroki-it/projects/foo:/data

📁  Mounting host path /Users/hiroki-it/projects/foo into VM as /data ...
    ▪ Mount type:   
    ▪ User ID:      docker
    ▪ Group ID:     docker
    ▪ Version:      9p2000.L
    ▪ Message Size: 262144
    ▪ Permissions:  755 (-rwxr-xr-x)
    ▪ Options:      map[]
    ▪ Bind Address: 127.0.0.1:61268
🚀  Userspace file server: ufs starting
✅  Successfully mounted /Users/hiroki-it/projects/foo to /data

📌  NOTE: This process must stay alive for the mount to be accessible ...
```

<br>

### ssh

#### ・sshとは

仮想環境内のノードにSSH接続を行う。デフォルトでは、マスターノードに接続する。

参考：

- https://minikube.sigs.k8s.io/docs/commands/ssh/
- https://garafu.blogspot.com/2019/10/ssh-minikube-k8s-vm.html

ノードの中では```docker```コマンドを実行でき、イメージのデバッグも可能である。

```bash
$ minikube ssh  

# ノードの中
$ docker run --rm -it <ビルドに失敗したイメージID> /bin/bash

# コンテナの中
root@xxxxxxxxxx: 
```

#### ・オプション無し

```bash
# Dockerドライバーによる仮想環境の場合
$ minikube ssh  

docker@minikube:~$ pwd
/home/docker
```

```bash
# VirtualBoxドライバーによる仮想環境の場合
$ minikube ssh
                         _             _            
            _         _ ( )           ( )           
  ___ ___  (_)  ___  (_)| |/')  _   _ | |_      __  
/' _ ` _ `\| |/' _ `\| || , <  ( ) ( )| '_`\  /'__`\
| ( ) ( ) || || ( ) || || |\`\ | (_) || |_) )(  ___/
(_) (_) (_)(_)(_) (_)(_)(_) (_)`\___/'(_,__/'`\____)

$ pwd
/home/docker
```

```bash
# HyperKitドライバーによる仮想環境の場合
$ minikube ssh   
                         _             _            
            _         _ ( )           ( )           
  ___ ___  (_)  ___  (_)| |/')  _   _ | |_      __  
/' _ ` _ `\| |/' _ `\| || , <  ( ) ( )| '_`\  /'__`\
| ( ) ( ) || || ( ) || || |\`\ | (_) || |_) )(  ___/
(_) (_) (_)(_)(_) (_)(_)(_) (_)`\___/'(_,__/'`\____)

$ pwd
/home/docker
```

<br>

### start

#### ・startとは

ゲスト仮想環境を構築し、仮想環境内にノードを作成する。

参考：https://minikube.sigs.k8s.io/docs/commands/start/

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

ゲスト仮想環境のドライバーを指定し、```start```コマンドを実行する。ホストごとに標準の仮想環境が異なり、MacOSはDockerドライバーがデフォルトである。ドライバーの使用前に、これをインストールしておく必要があることに注意する。

参考：https://minikube.sigs.k8s.io/docs/drivers/

**＊実行例＊**

```bash
# 事前にVirtualBoxのダウンロードが必要。
$ minikube start --driver=virtualbox
```

#### ・--mount、--mount--string

ホストとゲスト仮想環境間のマウントディレクトリを指定しつつ、```start```コマンドを実行する。

**＊実行例＊**

```bash
$ minikube start --mount=true --mount-string="/Users/hiroki-it/projects/foo:/data"
```

#### ・--nodes

作成するノード数を指定し、```start```コマンドを実行する。

**＊実行例＊**

```bash
$ minikube start --nodes 3

$ kubectl get nodes
NAME           STATUS   ROLES                  AGE   VERSION
minikube       Ready    control-plane,master   76s   v1.20.2
minikube-m02   Ready    <none>                 42s   v1.20.2
minikube-m03   Ready    <none>                 19s   v1.20.2
```

<br>

## 02. マウント

### ホスト-ノード間マウント

#### ・標準のホスト-ノード間マウント

ホスト側の```$MINIKUBE_HOME/files```ディレクトリに保存されたファイルは、ゲスト仮想環境内のノードのルート直下にマウントされる。

参考：https://minikube.sigs.k8s.io/docs/handbook/filesync/

```bash
$ mkdir -p ~/.minikube/files/etc

$ echo nameserver 8.8.8.8 > ~/.minikube/files/etc/foo.conf

#  /etc/foo.conf に配置される
$ minikube start
```

#### ・仮想化ドライバー別のホスト-ノード間マウント

ホスト以下のディレクトリに保存されたファイルは、ゲスト仮想環境内のノードの決められたディレクトリにマウントされる。

参考：https://minikube.sigs.k8s.io/docs/handbook/mount/#driver-mounts

| ドライバー名  | OS      | ホスト側のディレクトリ    | ゲスト仮想環境内のノードのディレクトリ |
| ------------- | ------- | ------------------------- | -------------------------------------- |
| VirtualBox    | Linux   | ```/home```               | ```/hosthome```                        |
| VirtualBox    | macOS   | ```/Users```              | ```/Users```                           |
| VirtualBox    | Windows | ```C://Users```           | ```/c/Users```                         |
| VMware Fusion | macOS   | ```/Users```              | ```/mnt/hgfs/Users```                  |
| KVM           | Linux   | なし                      |                                        |
| HyperKit      | Linux   | なし（NFSマウントを参照） |                                        |

<br>

### ノード-コンテナ間マウント

#### ・標準のノード-コンテナ間マウント

ゲスト仮想環境内のノードでは、以下のディレクトリからPersistentVolumeが自動的に作成される。そのため、ポッドでは作成されたPersistentVolumeをPersistentVolumeClaimで指定しさえすればよく、わざわざノードのPersistentVolumeを作成する必要がない。ただし、DockerドライバーとPodmanドライバーを使用する場合は、この機能がないことに注意する。

参考：https://minikube.sigs.k8s.io/docs/handbook/persistent_volumes/

- ```/data```
- ```/var/lib/minikube```
- ```/var/lib/docker```
- ```/var/lib/containerd```
- ```/var/lib/buildkit```
- ```/var/lib/containers```
- ```/tmp/hostpath_pv```
- ```/tmp/hostpath-provisioner```

<br>

### ホスト-ノード-コンテナ間

#### ・ホストをコンテナにマウントする方法

minikubeでは、```mount```コマンド、ホスト側の```$MINIKUBE_HOME/files```ディレクトリ、仮想化ドライバーごとのを用いて、ホスト側のディレクトリをゲスト仮想環境内のノードのディレクトリにマウントできる。またノードでは、決められたディレクトリからPersistentVolumeを自動的に作成する。ここで作成されたPersistentVolumeを、ポッドのPersistentVolumeClaimで指定する。このように、ホストからノード、ノードからポッドへマウントを実行することにより、ホスト側のディレクトリをポッド内のコンテナに間接的にマウントできる。

参考：https://stackoverflow.com/questions/48534980/mount-local-directory-into-pod-in-minikube

#### ・HyperKitドライバーを使用する場合

**＊実行例＊**

（１）HyperKitドライバーを使用する場合、ホストとノード間のマウント機能がない。そこで```mount```コマンドを使用して、ホスト側のディレクトリをノードのボリュームにマウントする。

```bash
$ minikube start --driver=hyperkit --mount=true --mount-string="/Users/h.hasegawa/projects/foo:/data"
```

（２）ノードのボリュームをポッド内のコンテナにマウントする。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: foo-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: foo-pod
  template:
    metadata:
      labels:
        app: foo-pod
    spec:
      containers:
        - name: foo-lumen
          image: foo-lumen:dev
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 9000
          volumeMounts:
            - name: foo-lumen
              mountPath: /var/www/foo
          workingDir: /var/www/foo
        - name: foo-nginx
          image: foo-nginx:dev
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
      volumes:
        - name: foo-lumen
          hostPath:
            path: /data
            type: DirectoryOrCreate
```





