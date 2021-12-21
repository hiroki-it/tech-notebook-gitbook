# Istio

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Istioとは

### 特徴

マイクロサービスアーキテクチャにおけるサービスメッシュを実装する。Istioを必ずしも用いる必要はなく、Kubernetesの機能でこれを実現してもよい。

参考：https://qiita.com/Ladicle/items/4ba57078128d6affadd5

<br>

### 依存関係の解決

機能『```A ---> B ---> C ---> D```』を持つモノリシックアプリケーションがあるとする。これをマイクロサービス化して、ABCDを別々のアプリケーションに分割する。それぞれのアプリケーションがPod上で稼働することになる。しかし、これだけではABCDが独立しておらず、各機能は1つ前の機能に依存している。この依存関係を解決する。

<br>

### minikubeのためのIstioをインストール

参考：https://istio.io/latest/docs/setup/getting-started/#download

（１）インストール先のディレクトリに移動する。

```bash
$ cd ${HOME}/projects/hiroki-it
```

（２）インストールする。

```bash
$ curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.12.1 - sh
```

（３）istioctlへのパスを環境変数に登録する。

```bash
$ cd istio-1.12.1
$ export PATH=$PWD/bin:$PATH
```

（４）設定ファイルをインストール

参考：https://istio.io/latest/docs/setup/additional-setup/config-profiles/

```bash
$ istioctl install --set profile=demo -y
```

（５）minikubeでIstioを使用できるようにする。Envoyコンテナをサイドカーコンテナとして自動的にデプロイできるようにする。

```bash
$ kubectl label namespace default istio-injection=enabled
```

<br>

## 02. Istio Mesh

### Istio Meshとは

参考：https://istio.io/latest/docs/ops/deployment/architecture/

![istio_overview](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/istio_overview.png)

<br>

### Destination Rule

<br>

### Gateway

#### ・Gatewayとは

参考：https://istio.io/latest/blog/2018/v1alpha3-routing/

![istio_gateway](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/istio_gateway.png)

#### ・Ingress Gateway

#### ・Mesh Gateway

#### ・Egress Gateway

<br>

### Istiod

#### ・Istiodとは

各マイクロサービスのプロキシサイドカーコンテナを統括的に管理する。

参考：

- https://istio.io/latest/docs/ops/deployment/architecture/
- https://speakerdeck.com/kurochan/ru-men-envoy?slide=34

#### ・Mixer

各マイクロサービスのデータをEnvoy経由で収集し、アクセス制御を実行する。

#### ・Pilot

サービスディスカバリやトラフィックの管理を行う。

#### ・Citadal

サービス間のリクエスト送受信に認可機能を提供する。

<br>

### Service Entry

<br>

### Vertual Service


