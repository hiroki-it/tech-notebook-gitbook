# envoy.yml

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. 導入方法

### Istioを用いない場合

Istioを用いてEnvoyを導入する場合、Envoyのオプションは```envoy.yml```ファイルから設定する。

参考：https://www.envoyproxy.io/docs/envoy/latest/start/docker

```dockerfile
FROM envoyproxy/envoy:1.20
COPY envoy.yml /etc/envoy/envoy.yml
```

<br>

### Istioを用いる場合

Istioを用いてEnvoyを導入する場合、EnvoyのオプションはIstioOperatorオブジェクトの```spec.meshConfig```キーから設定する。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_as_code/infrastructure_as_code_service_mesh_istio_manifest_yml.html

<br>

## 02. admin

### adminとは

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

### name

```yaml
static_resources:
  listeners:
  - name: listener_0
```

<br>

### address

#### ・protocol

```yaml
static_resources:
  listeners:
  - address:
      socket_address:
        protocol: TCP
```

#### ・address

```yaml
static_resources:
  listeners:
  - address:
      socket_address:
        port_value: 10000
```

#### ・port_value


```yaml
static_resources:
  listeners:
  - address:
      socket_address:
        port_value: 10000
```

<br>

### filter_chains.filters

#### ・name

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
```

#### ・typed_config."@type"

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.stdout
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  host_rewrite_literal: www.envoyproxy.io
                  cluster: service_envoyproxy_io
          http_filters:
          - name: envoy.filters.http.router
```

#### ・typed_config.stat_prefix

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - typed_config:
          stat_prefix: ingress_http
```

#### ・typed_config.access_log

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - typed_config:
          access_log:
          - name: envoy.access_loggers.stdout
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog
```

#### ・typed_config.route_config

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - typed_config:
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  host_rewrite_literal: www.envoyproxy.io
                  cluster: service_envoyproxy_io
```

#### ・typed_config.http_filters

```yaml
static_resources:
  listeners:
  - filter_chains:
    - filters:
      - typed_config:
          http_filters:
          - name: envoy.filters.http.router
```

<br>

## 04. static_resources.clusters

### clustersとは

参考：https://www.envoyproxy.io/docs/envoy/latest/start/quick-start/configuration-static#clusters

<br>

### name

```yaml
static_resources:  
  clusters:
  - name: service_envoyproxy_io
```

<br>

### type

```yaml
static_resources:  
  clusters:
  - type: LOGICAL_DNS
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

```yaml
static_resources:  
  clusters:
  - lb_policy: ROUND_ROBIN
```

<br>

### load_assignment

#### ・cluster_name

```yaml
static_resources:  
  clusters:
  - load_assignment:
      cluster_name: service_envoyproxy_io
```

#### ・endpoints

```yaml
static_resources:  
  clusters:
  - load_assignment:
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: www.envoyproxy.io
                port_value: 443
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

#### ・typed_config

```yaml
static_resources:  
  clusters:
  - transport_socket:
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        sni: www.envoyproxy.io
```

