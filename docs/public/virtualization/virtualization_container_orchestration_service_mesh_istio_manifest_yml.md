# manifest.yml

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## apiVersion

<br>

## kind

<br>

## spec（```kind: Gateway```の場合）

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

