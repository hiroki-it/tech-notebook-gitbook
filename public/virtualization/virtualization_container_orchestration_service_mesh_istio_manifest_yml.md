# manifest.yml

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. istioctl

### インストール

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

<br>

### Istioの有効化

（１）設定ファイルをインストール

参考：https://istio.io/latest/docs/setup/additional-setup/config-profiles/

```bash
$ istioctl install --set profile=demo -y
```

（２）minikubeでIstioを使用できるように、```istio-injection```ラベルの値に```enabled```を設定する。Envoyコンテナをサイドカーコンテナとして自動的にデプロイできるようになる。

```bash
$ kubectl label namespace default istio-injection=enabled
```

<br>

## 02. apiVersion

<br>

## 03. kind

<br>

## 04. spec（```kind: Gateway```の場合）

### http

#### ・route

インバウンド通信のルーティング先のサービスを設定する。

```yaml
spec:
  http:
    - route:
        - destination:
            host: foo-service # または、サービスの完全修飾ドメイン名でもよい。
            port:
              number: 80
```

```yaml
spec:
  servers:
  - port:
      protocol: HTTP
      number: 80
    hosts:
      - "*" 
```

