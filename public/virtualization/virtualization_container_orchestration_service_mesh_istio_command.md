# istioctlコマンド

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. セットアップ

### インストール

#### ・brew経由

```bash
$ brew install istioctl
```

#### ・curl経由

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

### プロファイル

#### ・プロファイルとは

Istioの機能のセットを提供する。

参考：https://istio.io/latest/docs/setup/additional-setup/config-profiles/

#### ・インストール

参考：https://istio.io/latest/docs/setup/additional-setup/config-profiles/

```bash
$ istioctl install --set profile=<プロファイル名> -y
```

#### ・各プロファイルの違い

参考：

- https://atmarkit.itmedia.co.jp/ait/articles/2111/05/news005.html
- https://betterprogramming.pub/getting-started-with-istio-on-kubernetes-e582800121ea

| ユースケース         | default  | demo     | external | empty                         | minimal              | openshift | preview | remote |
| :------------------- | :------- | :------- | -------- | :---------------------------- | :------------------- | --------- | ------- | ------ |
| 概要                 | 本番環境 | 開発環境 | -        | Istioを全てカスタマイズしたい | 最小限の機能が欲しい | ？        | -       | ？     |
| istio-egressgateway  | -        | ○        | -        | -                             | -                    | ？        | -       | ？     |
| istio-ingressgateway | ○        | ○        | -        | -                             | -                    | ？        | ○       | ？     |
| istiod               | ○        | ○        | -        | -                             | ○                    | ？        | ○       | ？     |
| grafana              | -        | -        | -        | -                             | -                    | -         | -       | -      |
| istio-tracing        | -        | -        | -        | -                             | -                    | -         | -       | -      |
| kiali                | -        | -        | -        | -                             | -                    | -         | -       | -      |
| prometheus           | -        | -        | -        | -                             | -                    | -         | -       | -      |

<br>

### KubernetesにおけるIstioの有効化

KubernetesでIstioを使用できるように、```istio-injection```ラベルの値に```enabled```を設定する。Envoyコンテナをサイドカーコンテナとして自動的にデプロイできるようになる。```default```以外の名前空間名をつける場合は、コマンドではなく、マニフェストファイル上でこれを設定できる。

**＊実行例＊**

```bash
$ kubectl label namespace default istio-injection=enabled
```

<br>

## 02. コマンド

### analyze

#### ・analyzeとは

Istioが正しく機能しているかどうかを検証する。

**＊実行例＊**

成功した場合を以下に示す。

```bash
$ istioctl analyze

✔ No validation issues found when analyzing namespace: default.
```

失敗した場合を以下に示す。

```bash
$ istioctl analyze

Info [IST0118] (Service default/foo-service) Port name  (port: 80, targetPort: 80) doesn't follow the naming convention of Istio port.
```

#### ・-n

名前空間を指定しつつ、```analyze```コマンドを実行する。

**＊実行例＊**

```bash
$ istioctl analyze -n foo-namespace
```

<br>

### profile

#### ・profile

Istioのプロファイルを操作する。

#### ・list

利用可能なプロファイルを表示する。

**＊実行例＊**

```bash
$ istioctl profile list

Istio configuration profiles:
    default
    demo
    empty
    external
    minimal
    openshift
    preview
    remote
```

<br>

### proxy-status

#### ・proxy-statusとは

Ingress Gateway、Egress Gateway、プロキシコンテナのステータスを表示する。

**＊実行例＊**

```bash
$ istioctl proxy-status  

NAME                                      CDS        LDS        EDS        RDS          ISTIOD           VERSION
istio-egressgateway-*****.istio-system    SYNCED     SYNCED     SYNCED     NOT SENT     istiod-*****     1.12.1
istio-ingressgateway-*****.istio-system   SYNCED     SYNCED     SYNCED     NOT SENT     istiod-*****     1.12.1
foo-pod.default                           SYNCED     SYNCED     SYNCED     SYNCED       istiod-*****     1.12.1
bar-pod.default                           SYNCED     SYNCED     SYNCED     SYNCED       istiod-*****     1.12.1
baz-pod.default                           SYNCED     SYNCED     SYNCED     SYNCED       istiod-*****     1.12.1
```

<br>

### verify-install

#### ・verify-installとは

Istioのインストールが正しく実行されたかを検証する。

**＊実行例＊**

```bash
$ istioctl verify-install

1 Istio control planes detected, checking --revision "default" only
✔ ClusterRole: istiod-istio-system.istio-system checked successfully
✔ ClusterRole: istio-reader-istio-system.istio-system checked successfully

# 〜 中略 〜

✔ Service: istio-egressgateway.istio-system checked successfully
✔ ServiceAccount: istio-egressgateway-service-account.istio-system checked successfully
Checked 14 custom resource definitions
Checked 3 Istio Deployments
✔ Istio is installed and verified successfully
```

