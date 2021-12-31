# manifest.yml

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. apiVersion

Istio-APIのバージョンを設定する。Kubernetesとは異なることに注意する。

```yaml
apiVersion: networking.istio.io/v1beta1
```

<br>

## 02. kind

| オブジェクト名  | 補足 |
| --------------- | ---- |
| DestinationRule |      |
| Gateway         |      |
| VirtualService  |      |

<br>

## 03. spec（DestinationRuleの場合）

### host

いずれのサービスへの転送時に、DestinationRuleを適用するかを設定する。

参考：https://istio.io/latest/docs/reference/config/networking/destination-rule/#DestinationRule

**＊実装例＊**

```yaml
kind: DestinationRule
spec:
  host: foo-service # 完全修飾ドメイン名でも良い。
```

<br>

### subnets

サブネットの名前に基づいて、条件分岐ルールを適用する。

参考：https://istio.io/latest/docs/reference/config/networking/destination-rule/#Subset

**＊実装例＊**

サブネット名が```v1```の時には、```version```タグが```v1```であるサービスに転送する。```v2```も同様である。

```yaml
kind: DestinationRule
spec:
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

<br>

## 04. spec（Gatewayの場合）

### servers

#### ・port

受信するインバウンド通信のプロトコルを設定する。プロトコルに応じて、自動的に

参考：https://istio.io/latest/docs/reference/config/networking/gateway/#Port

**＊実装例＊**

```yaml
kind: Gateway
spec:
  servers:
  - port:
      name: http
      protocol: HTTP
      number: 80
```

#### ・hosts

Gatewayに紐づけれたVirtualServiceのドメイン名を設定する。ワイルドカードを使用できる。

参考：https://istio.io/latest/docs/reference/config/networking/gateway/#Port

**＊実装例＊**

```yaml
kind: Gateway
spec:
  servers:
  - hosts:
      - "*" 
```

#### ・tls

受信するインバウンド通信がHTTPS、またはVirtualServiceへの転送でHTTPからHTTPSにリダイレクトする場合に、SSL/TLS証明書を設定する。

参考：https://istio.io/latest/docs/reference/config/networking/gateway/#Port

**＊実装例＊**

```yaml
kind: Gateway
spec:
  servers:
  - tls:
      mode: SIMPLE
      serverCertificate: /etc/certs/server.pem
      privateKey: /etc/certs/privatekey.pem
```

<br>

## 05. spec（VirtualServiceの場合）

### gateways

インバウンド通信をいずれのGatewayから受信するかを設定する。

```yaml
kind: VirtualService
spec:
  gateways:
  - foo-gateway
```

<br>

### http

#### ・httpとは

HTTP/1.1、HTTP/2、gRPC、のプロトコルによるインバウンド通信をサービスにルーティングする。ルーティング先のサービスを厳格に指定するために、サービスの```appProtocol```キーまたはプロトコル名をIstioのルールに沿ったものにする必要がある。

参考：https://istio.io/latest/docs/ops/configuration/traffic-management/protocol-selection/#explicit-protocol-selection

#### ・match

受信するインバウンド通信のうち、ルールを適用するもののメッセージ構造を設定する。

**＊実装例＊**

インバウンド通信のうち、```x-foo```ヘッダーに```bar```が割り当てられたものだけにルールを適用する。

```yaml
kind: VirtualService
spec:
  http:
  - match:
    - headers:
        x-foo:
          exact: bar
```

インバウンド通信のうち、URLのプレフィクスが```/foo```のものだけにルールを適用する。

```yaml
kind: VirtualService
spec:
  http:
  - match:
    - headers:
        uri:
          prefix: /foo
```

#### ・route

受信するインバウンド通信のルーティング先のサービスやポートを設定する。

**＊実装例＊**

```yaml
kind: VirtualService
spec:
  http:
    - route:
        - destination:
            host: foo-service # または、サービスの完全修飾ドメイン名でもよい。
            port:
              number: 80
```

<br>

### tcp

#### ・tcpとは

TCP/IPのプロトコルによるインバウンド通信をサービスにルーティングする。

