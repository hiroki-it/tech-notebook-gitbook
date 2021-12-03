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

ホストOSでdockerコマンドを実行した時に、ホストOSのdockerデーモンでなく、ゲスト仮想環境内のノードのdockerデーモンをコールできるように環境変数を設定する。イメージタグが```latest```であると、仮想環境外に対してイメージをプルしてしまうことに注意する。

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

ホストOSのファイルまたはディレクトリを、ゲスト仮想環境内のノードにマウントする。

#### ・オプション無し

```bash
❯ minikube mount /Users/h.hasegawa/projects/foo:/var/www/foo

📁  Mounting host path /Users/h.hasegawa/projects/foo into VM as /var/www/foo ...
    ▪ Mount type:   
    ▪ User ID:      docker
    ▪ Group ID:     docker
    ▪ Version:      9p2000.L
    ▪ Message Size: 262144
    ▪ Permissions:  755 (-rwxr-xr-x)
    ▪ Options:      map[]
    ▪ Bind Address: 127.0.0.1:61268
🚀  Userspace file server: ufs starting
✅  Successfully mounted /Users/h.hasegawa/projects/foo to /var/www/foo

📌  NOTE: This process must stay alive for the mount to be accessible ...
```

<br>

### ssh

#### ・sshとは

ゲスト仮想環境内のノードにSSH接続を行う。

参考：

- https://minikube.sigs.k8s.io/docs/commands/ssh/
- https://garafu.blogspot.com/2019/10/ssh-minikube-k8s-vm.html

#### ・オプション無し

```bash
❯ minikube ssh

docker@minikube:~$
```



<br>

### start

#### ・startとは

ゲスト仮想環境を構築し、仮想環境内にノードを作成する。

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

ゲスト仮想環境のドライバーを指定し、```start```コマンドを実行する。

**＊実行例＊**

```bash
$ minikube start --driver docker
```

<br>

## 02. マウント

### ノード-コンテナ間マウント

#### ・標準のノード-コンテナ間マウント

ゲスト仮想環境内のノードにて、以下のディレクトリに保存されたファイルは、ポッド内のコンテナにボリュームマウントされ、HostDirボリュームが作成される。

参考：https://minikube.sigs.k8s.io/docs/handbook/persistent_volumes/

- ```/data```
- ```/var/lib/minikube```
- ```/var/lib/docker```
- ```/var/lib/containerd```
- ```/var/lib/buildkit```
- ```/var/lib/containers```
- ```/tmp/hostpath_pv```
- ```/tmp/hostpath-provisioner```

#### ・ドライバー別のノード-コンテナ間マウント

ゲスト仮想環境内のノードにて、以下のディレクトリに保存されたファイルは、ポッド内のコンテナにバインドマウントされ、HostDirボリュームが作成される。

参考：https://minikube.sigs.k8s.io/docs/handbook/mount/#driver-mounts

| ドライバー名  | OS      | ホストOSのディレクトリ    | ゲスト仮想環境内のディレクトリ |
| ------------- | ------- | ------------------------- | ------------------------------ |
| VirtualBox    | Linux   | ```/home```               | ```/hosthome```                |
| VirtualBox    | macOS   | ```/Users```              | ```/Users```                   |
| VirtualBox    | Windows | ```C://Users```           | ```/c/Users```                 |
| VMware Fusion | macOS   | ```/Users```              | ```/mnt/hgfs/Users```          |
| KVM           | Linux   | なし                      |                                |
| HyperKit      | Linux   | なし（NFSマウントを参照） |                                |



<br>

### ホスト-ゲスト間マウント

ホストOSの```$MINIKUBE_HOME/files```ディレクトリに保存されたファイルは、ゲスト仮想環境のルート直下に配置される。

https://minikube.sigs.k8s.io/docs/handbook/filesync/

```bash
$ mkdir -p ~/.minikube/files/etc

$ echo nameserver 8.8.8.8 > ~/.minikube/files/etc/foo.conf

#  /etc/foo.conf に配置される
$ minikube start
```





