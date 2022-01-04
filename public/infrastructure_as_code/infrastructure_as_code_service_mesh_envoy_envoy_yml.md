# envoy.yml

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. 導入方法

### Dockerイメージに組み込む場合

Dockerfileにて、独自の```envoy.yml```ファイルを組み込む。

参考：https://www.envoyproxy.io/docs/envoy/latest/start/docker

```dockerfile
FROM envoyproxy/envoy:1.20
COPY envoy.yml /etc/envoy/envoy.yml
```

<br>

### annotationsに組み込む場合

Kubernetesオブジェクトの```annotations```の```proxy.istio.io/config```にて、独自の```envoy.yml```ファイルを組み込む。または、オプションを設定する。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_as_code/infrastructure_as_code_service_mesh_istio_manifest_yml.html

<br>

## 02. admin

### adminとは

参考：https://www.envoyproxy.io/docs/envoy/latest/start/quick-start/admin#admin

<br>

## 02-02. admin.address

### addressとは

<br>

### socket_address

#### ・protocol

受信するインバウンド通信のプロトコルを設定する。

```yaml
admin:
  address:
    socket_address:
      protocol: TCP
```

#### ・address

受信するインバウンド通信のIPアドレスを設定する。『```0.0.0.0```』とすると、全てのIPアドレスを指定できる。

```yaml
admin:
  address:
    socket_address:
      address: 0.0.0.0
```

#### ・port_value

受信するインバウンド通信のポート番号を設定する。

```yaml
admin:
  address:
    socket_address:
      port_value: 9901
```

<br>

## 03. static_resources

### static_resourcesとは

固定値を設定する。

参考：https://www.envoyproxy.io/docs/envoy/latest/start/quick-start/configuration-static#static-resources

<br>

## 03-02. static_resources.listeners

### listenersとは

受信するインバウンド通信のリスナーを設定する。

参考：https://www.envoyproxy.io/docs/envoy/latest/start/quick-start/configuration-static#listeners

<br>

### address

#### ・protocol

受信可能なインバウンド通信のプロトコルを設定する。

```yaml
static_resources:
  listeners:
  - address:
      socket_address:
        protocol: TCP
```

#### ・address

受信可能なインバウンド通信の送信元IPアドレスを設定する。

```yaml
static_resources:
  listeners:
  - address:
      socket_address:
        address: 0.0.0.0
```

#### ・port_value

受信可能なインバウンド通信のポート番号を設定する。


```yaml
static_resources:
  listeners:
  - address:
      socket_address:
        port_value: 80
```

<br>

### filter_chains.filters

#### ・name

特定のインバウンド通信を処理するフィルターの名前を設定する。

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - name: foo-filter
```

#### ・config.access_log

アクセスログの出力先を設定する。

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - config:
          access_log:
          - name: foo-access-log
            config:
              path: "/dev/stdout"
```

#### ・config.stat_prefix

統計ダッシュボードのメトリクスのプレフィクスを設定する。

参考：

- https://www.envoyproxy.io/docs/envoy/latest/start/quick-start/admin#stat-prefix
- https://i-beam.org/2019/02/03/envoy-static-load-balancer/

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - config:
          stat_prefix: foo-stat
```

#### ・config.route_config

特定のルーティング先に関する処理を設定する。

参考：https://blog.kamijin-fanta.info/2020/12/consul-with-envoy/

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - config:
          route_config:
            name: foo-route
            virtual_hosts:
            - name: foo-service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: foo-cluster
```

#### ・config.http_filters

参考：

- https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/http/router/v3/router.proto#envoy-v3-api-msg-extensions-filters-http-router-v3-router
- https://i-beam.org/2019/02/03/envoy-static-load-balancer/

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - config:
          http_filters:
          - name: envoy.router
```

<br>

### name

インバウンド通信を受信するリスナーの名前を設定する。

```yaml
static_resources:
  listeners:
  - name: foo-listener
```

<br>

## 04. static_resources.clusters

### clustersとは

インバウンド通信のルーティング対象のマイクロサービスをグループ化する。

参考：https://www.envoyproxy.io/docs/envoy/latest/start/quick-start/configuration-static#clusters

<br>

### connect_timeout

タイムアウトまでの時間を設定する。

```yaml
static_resources:  
  clusters:
  - connect_timeout: 0.25s
```

<br>

### dns_lookup_family

```yaml
static_resources:  
  clusters:
  - dns_lookup_family: V4_ONLY
```

<br>

### lb_policy

ルーティングのアルゴリズムを設定する。

```yaml
static_resources:  
  clusters:
  - lb_policy: ROUND_ROBIN
```

<br>

### load_assignment

#### ・endpoints

ルーティング対象のIPアドレスとポート番号のリストを設定する。

参考：https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/http/router/v3/router.proto#envoy-v3-api-msg-extensions-filters-http-router-v3-router

```yaml
static_resources:  
  clusters:
  - load_assignment:
      endpoints:
        - lb_endpoints:
          - endpoint:
              address: 192.168.0.1
              port_value: 80
          - endpoint:
              address: 192.168.0.1
              port_value: 81
```

#### ・cluster_name

ルーティング対象のグループの名前を設定する。

```yaml
static_resources:  
  clusters:
  - load_assignment:
      cluster_name: foo-cluster
```

<br>

### name

ルーティング対象のグループの名前を設定する。

```yaml
static_resources:  
  clusters:
  - name: foo-cluster
```

<br>

### transport_socket

#### ・name

```yaml
static_resources:  
  clusters:
  - transport_socket:
      name: envoy.transport_sockets.tls
```

#### ・config

```yaml
static_resources:  
  clusters:
  - transport_socket:
      config:
        sni: www.envoyproxy.io
```

<br>

### type

```yaml
static_resources:  
  clusters:
  - type: LOGICAL_DNS
```

