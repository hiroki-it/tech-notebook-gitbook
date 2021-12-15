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

### サービスメッシュ

![service-mesh](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/service-mesh.png)

従来のマイクロサービスアーキテクチャでは、マイクロサービス間で直接リクエストを送受信していた。しかし、以下のような問題が起こる。

- ソフトウェアのコンポーネント間通信を制御しきれない。
- 障害時に何が起こるか分からない。
- 鍵と証明書を管理しきれない。
- ソフトウェアの全体像が把握できない

そこで、マイクロサービス間で直接リクエストを送受信するのではなく、これをプロキシ機能を持つサイドカーコンテナ経由で行う。また、各サイドカーコンテナをコントロールプレーンで統括的に管理する。

参考：https://www.ibm.com/blogs/think/jp-ja/cloud-native-concept-03/#servicemesh

<br>

### 依存関係の解決

機能『```A ---> B ---> C ---> D```』を持つモノリシックアプリケーションがあるとする。これをマイクロサービス化して、ABCDを別々のアプリケーションに分割する。それぞれのアプリケーションがPod上で稼働することになる。しかし、これだけではABCDが独立しておらず、各機能は１つ前の機能に依存している。この依存関係を解決する。

<br>

## 01-02. Istioの構成要素

### 全体像

参考：https://istio.io/latest/docs/ops/deployment/architecture/

![istio_overview](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/istio_overview.png)

<br>

### Envoy

#### ・Envoyとは

マイクロサービスのプロキシ機能コンテナとして稼働し、マイクロサービス間のリクエスト送受信に関する機能を提供する。アンバサダーパターンに基づいている。マイクロサービスからネットワークに関する責務を分離することを目標としており、各マイクロサービスはリクエスト送信先のマイクロサービスのIPアドレスを知らなくとも、これをEnvoyが解決してくれる。

参考：

- https://blog.linkode.co.jp/entry/2020/07/06/162915
- https://openstandia.jp/oss_info/envoy/
- https://speakerdeck.com/kurochan/ru-men-envoy?slide=33

#### ・サービスディスカバリ
#### ・ 負荷分散
#### ・ TLS終端
#### ・ HTTP/2、gRPCのプロキシ
#### ・ サーキットブレイカー
#### ・ ヘルスチェック
#### ・ A/Bテスト
#### ・ フォールとインジェクション
#### ・ メトリクスの収集

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
