# Istio

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Istio

### 特徴

マイクロサービスアーキテクチャにおけるサービスメッシュを実装する。Istioを必ずしも用いる必要はなく、KubernetesやOpenShiftの機能でこれを実現してもよい。

参考：https://qiita.com/Ladicle/items/4ba57078128d6affadd5

<br>

### 依存関係の解決

機能『```A ---> B ---> C ---> D```』を持つモノリシックアプリケーションがあるとする。これをマイクロサービス化して、ABCDを別々のアプリケーションに分割する。それぞれのアプリケーションがPod上で稼働することになる。しかし、これだけではABCDが独立しておらず、各機能は1つ前の機能に依存している。この依存関係を解決する。

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

クラスター内外間の通信を制御する。

参考：https://istio.io/latest/blog/2018/v1alpha3-routing/

![istio_gateway](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/istio_gateway.png)

#### ・Ingress Gateway

クラスター外部から受信されるインバウンド通信をフィルタリングする。

参考：https://knowledge.sakura.ad.jp/20489/

#### ・Mesh Gateway

#### ・Egress Gateway

クラスター内部から送信されるアウトバウンド通信をフィルタリングする。

参考：https://knowledge.sakura.ad.jp/20489/

<br>

### Istiod

#### ・Istiodとは

各マイクロサービスのプロキシサイドカーコンテナを統括的に管理する。

参考：

- https://istio.io/latest/docs/ops/deployment/architecture/
- https://speakerdeck.com/kurochan/ru-men-envoy?slide=34

#### ・Citadal

暗号鍵やSSL証明書を管理する。

参考：https://knowledge.sakura.ad.jp/20489/

#### ・Galley

#### ・sidecar-injector

Envoyコンテナをサイドカーとして稼働させる。

#### ・Mixer

認証やデータ収集を行う。

#### ・Pilot

サービスディスカバリやトラフィックの管理を行う。

<br>

### Service Entry

<br>

### Vertual Service

Gatewayによって受信したインバウンド通信をサービスにルーティングする。

参考：https://knowledge.sakura.ad.jp/20489/

```yaml
apiVersion: networking.k8s.io/v1
kind: VirtualService
metadata:
  name: foo-virtual-service
spec:
  hosts:
    - "*"
  gateway:
    - ingress-gateway
  http:
    - route:
        - destination:
            host: foo-service
            port:
              number: 80
```

