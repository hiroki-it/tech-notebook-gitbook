# Kubernetes

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. 概念

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
    app: MyApp # Pod名
  ports:
  - protocol: TCP
    port: 80 # 受信ポート
    targetPort: 9376 # 転送先ポート
```

<br>

### Pod

#### ・Podとは

ホスト仮想サーバ上のコンテナを最小グループ単位のこと．Podを単位として，コンテナ起動／停止や水平スケールイン／スケールアウトを実行する．

参考：https://kubernetes.io/ja/docs/concepts/workloads/pods/

AWS ECSタスクにおける類似するessential機能やオートスケーリングについては，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws.html

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
  template:
    # これがPodテンプレートです
    spec:
      containers:
      - name: hello
        image: busybox
        command: ['sh', '-c', 'echo "Hello, Kubernetes!" && sleep 3600']
      restartPolicy: OnFailure
    # Podテンプレートはここまでです
```

<br>

### Secret

#### ・Secretとは

セキュリティに関するデータを管理し，コンテナに選択的に提供するもの．

<br>

### Replica Set

#### ・Replica Set（Replication Controller）とは

<br>

### Kubectl

#### ・Kubectlとは

<br>

### Istio

#### ・Istioとは

マイクロサービスの各アプリケーションを管理するソフトウェアのこと．機能『A ---> B ---> C ---> D』を持つモノリシックアプリケーションがあるとする．これをマイクロサービス化して，ABCDを別々のアプリケーションに分割する．それぞれのアプリケーションがPod上で稼働することになる．しかし，これだけではABCDが独立しておらず，各機能は一つ前の機能に依存している．この依存関係を解決するのがIstioである．

#### ・Istiod

Envoyを管理する機能のこと．Envoyは，各アプリケーションから通信を委譲され，アプリケーション間の通信を代理で行う．
