# Kubernetes

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. コマンド

### Kubectl

#### ・Kubectlとは

<br>

## 02. <任意の名前>.yml

### spec／statu

参考：https://kubernetes.io/ja/docs/concepts/overview/working-with-objects/kubernetes-objects/

<br>

### Node

#### ・Master Node

Kubernetesが実行されるホスト物理サーバを指す．

#### ・Worker Node

Dockerが実行されるホスト仮想サーバを指す．

![Kubernetesの仕組み](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Kubernetesの仕組み.png)

<br>

### Service

#### ・Serviceとは

Podにリクエストを転送するロードバランサーとして機能する．

参考：https://kubernetes.io/ja/docs/concepts/services-networking/service/

#### ・定義

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service # Service名
spec:
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80 # Service受信ポート
    targetPort: 9376 # 転送先のPod受信ポート
```

<br>

### Pod

#### ・Podとは

ホスト仮想サーバ上のコンテナを最小グループ単位のこと．Podを単位として，コンテナ起動／停止や水平スケールイン／スケールアウトを実行する．

参考：https://kubernetes.io/ja/docs/concepts/workloads/pods/

AWS ECSタスクにおける類似するessential機能やオートスケーリングについては，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/cloud_computing/cloud_computing_aws.html

**＊例＊**

PHP-FPMコンテナとNginxコンテナを稼働させる場合，これら同じPodに配置する．

![kubernetes_php-fpm_nginx](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/kubernetes_php-fpm_nginx.png)

#### ・定義

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  template: # Pod
    spec:
      containers:
      - name: hello # Pod内コンテナ名
        image: busybox # イメージ
        command: ['sh', '-c', 'echo "Hello, Kubernetes!" && sleep 3600'] # コンテナ起動時コマンド
      restartPolicy: OnFailure
```

<br>

### Secret

#### ・Secretとは

セキュリティに関するデータを管理し，コンテナに選択的に提供するもの．

<br>

### Replica Set

#### ・Replica Set（Replication Controller）とは

<br>

## 02. Istio

### Istioとは

ただし，Istioを必ずしも使用する必要はなく，Kubernetesの標準の機能でこれを実現してもよい．

参考：https://qiita.com/Ladicle/items/4ba57078128d6affadd5

- システムのコンポーネント間通信を制御しきれない．
- 障害時に何が起こるか分からない．
- 鍵と証明書を管理しきれない．
- システムの全体像が把握できない

#### ・依存関係の解決

マイクロサービスアーキテクチャの各アプリケーションを管理するソフトウェアのこと．機能『```A ---> B ---> C ---> D```』を持つモノリシックアプリケーションがあるとする．これをマイクロサービス化して，ABCDを別々のアプリケーションに分割する．それぞれのアプリケーションがPod上で稼働することになる．しかし，これだけではABCDが独立しておらず，各機能は一つ前の機能に依存している．この依存関係を解決する．

<br>

### Istiod

#### ・Istiodとは

Envoyを管理する機能のこと．Envoyは，各アプリケーションから通信を委譲され，アプリケーション間の通信を代理で行う．
