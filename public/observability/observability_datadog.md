# Datadog

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Datadog

### メトリクス収集

#### ・設定方法

いくつかの方法でメトリクスを収集できる．

参考：https://docs.datadoghq.com/ja/metrics/#datadog-%E3%81%B8%E3%81%AE%E3%83%A1%E3%83%88%E3%83%AA%E3%82%AF%E3%82%B9%E3%81%AE%E9%80%81%E4%BF%A1

#### ・インテグレーションのセットアップ

Datadogでインテグレーションを有効化すると同時に，アプリケーションにエージェントをインストールする．



<br>

## 02. メトリクス／ログ収集 on Ec2

### Datadogエージェント on EC2

#### ・Datadogエージェント on EC2とは

常駐プログラムであり，アプリケーションからメトリクスやログを収集し，Datadogに転送する．

参考：https://docs.datadoghq.com/ja/agent/amazon_ecs/?tab=awscli

![datadog-agent_on-server](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/datadog-agent_on-server.png)

<br>

## 03. メトリクス収集 on Fargate

### Datadogエージェント on Fargate

#### ・Datadogエージェント on Fargateとは

常駐プログラムであり，アプリケーションからメトリクスをDatadogに転送する．EC2用のDatadogエージェントとは異なり，ログは転送しない．

参考：https://docs.datadoghq.com/ja/integrations/ecs_fargate/?tab=fluentbitandfirelens#%E3%82%BB%E3%83%83%E3%83%88%E3%82%A2%E3%83%83%E3%83%97

#### ・環境変数

グローバルオプションとして役立つ環境変数を以下に示す．

参考：https://docs.datadoghq.com/ja/agent/docker/?tab=%E6%A8%99%E6%BA%96#%E3%82%B0%E3%83%AD%E3%83%BC%E3%83%90%E3%83%AB%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3

| 変数名            | 説明                                                         | 補足                                                         | DatadogコンソールURL                         |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------------------------------------------- |
| ```DD_API_KEY```  | DatadogコンテナがあらゆるデータをDatadogに送信するために必要である． |                                                              |                                              |
| ```DD_ENV```      | APMを用いる場合に，サービスやトレース画面にて，```env```タグに値を設定する． | サービス単位で絞り込めるように，```prd-foo```や```stg-foo```とした方が良い． | https://app.datadoghq.com/apm/services       |
| ```DD_HOSTNAME``` | ホストマップ                                                 |                                                              | https://app.datadoghq.com/infrastructure/map |
| ```ECS_FARGATE``` | Fargateを用いる場合に，これを宣言する．                      |                                                              |                                              |

任意で選択できるメトリクスの収集として役立つ環境変数を以下に示す．一部のメトリクスは，標準では収集しないようになっており，収集するためにエージェントを有効化する必要がある．

参考：https://docs.datadoghq.com/ja/agent/docker/?tab=%E6%A8%99%E6%BA%96#%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E5%8F%8E%E9%9B%86-agent

| 変数名                         | 説明                                                         | 補足                                                         | DatadogコンソールURL                 |
| ------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------ |
| ```DD_APM_ENABLED```           | APMエージェントを有効化する．                                | Fargateを使用している場合，APMエージェントを有効化するだけでなく，分散トレースを送信できるように，サービスにパッケージのインストールが必要である．<br>参考：<br>・https://app.datadoghq.com/apm/docs?architecture=host-based&framework=php-fpm&language=php<br>・https://docs.datadoghq.com/ja/tracing/#datadog-%E3%81%B8%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B9%E3%82%92%E9%80%81%E4%BF%A1 | https://app.datadoghq.com/apm/home   |
| ```DD_LOGS_ENABLED```          | -                                                            |                                                              |                                      |
| ```DD_PROCESS_AGENT_ENABLED``` | ライブプロセスを有効化し，実行中のプロセスを収集する．<br>参考：https://docs.datadoghq.com/ja/infrastructure/process/?tab=linuxwindows |                                                              | https://app.datadoghq.com/containers |

カスタムメトリクスの収集として役立つ環境変数を以下に示す．

参考：https://docs.datadoghq.com/ja/agent/docker/?tab=%E6%A8%99%E6%BA%96#dogstatsd-%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%A0%E3%83%A1%E3%83%88%E3%83%AA%E3%82%AF%E3%82%B9

| 変数名                               | 説明                                                    | DatadogコンソールURL |
| ------------------------------------ | ------------------------------------------------------- | -------------------- |
| ```DD_DOGSTATSD_NON_LOCAL_TRAFFIC``` | Datadogコンテナのカスタムメトリクスの受信を有効化する． |                      |

<br>

### トレースエージェント

#### ・トレースエージェントとは

Dockerエージェントにて，```DD_APM_ENABLED```の環境変数に```true```を割り当てると，トレースエージェントが有効になる．APMエージェントを有効化し，分散トレースを収集できる．APMでは，分散トレースを元にして，サービス間の依存関係をサービスマップとして確認できる．

参考：

- https://docs.datadoghq.com/ja/agent/docker/apm/?tab=linux
- https://docs.datadoghq.com/ja/tracing/#datadog-apm-%E3%81%AE%E7%A2%BA%E8%AA%8D

#### ・環境変数

一部の環境変数は，Dockerエージェントの環境変数と重なる．

参考：https://docs.datadoghq.com/ja/agent/docker/apm/?tab=linux#docker-apm-agent-%E3%81%AE%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0

| 変数名             | 説明                                | 補足 |
| ------------------ | ----------------------------------- | ---- |
| ```DD_LOG_LEVEL``` | APMに送信するログレベルを設定する． |      |

<br>

### Datadogコンテナ

#### ・Datadogコンテナとは

Datadogが提供するdatadogイメージによって構築されるコンテナであり，コンテナのサイドカーコンテナとして配置される．コンテナ内で稼働するDatadog Dockerエージェントが，コンテナからメトリクスを収集し，Datadogにこれを転送する．

参考：https://docs.datadoghq.com/ja/integrations/ecs_fargate/?tab=fluentbitandfirelens#%E6%A6%82%E8%A6%81

#### ・Datadogコンテナの配置

```bash
[
    {
        # laravelコンテナ
    },
    {
        # nginxコンテナ
    },
    {
        # datadogコンテナ
        "name": "datadog",
        "image": "datadog/agent:latest",
        "essential": false,
        "portMappings": [
            {
                "containerPort": 8126,
                "hostPort": 8126,
                "protocol": "tcp"
            }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/prd-foo/laravel/log",
                "awslogs-region": "ap-northeast-1"
                "awslogs-stream-prefix": "/container"
            }
        },
        "cpu": 10,
        "memory": 256,
        "environment": [
            {
                "name": "ECS_FARGATE",
                "value": "true"
            },
            {
                "name": "DD_PROCESS_AGENT_ENABLED",
                "value": "true"
            },
            {
                "name": "DD_DOGSTATSD_NON_LOCAL_TRAFFIC",
                "value": "true"
            },
            {
                "name": "DD_APM_ENABLED",
                "value": "true"
            },
            {
                "name": "DD_LOGS_ENABLED",
                "value": "true"
            },
            {
                # アプリケーションに対するenvタグ
                "name": "DD_ENV",
                "value": "foo"
            },            
            {
                # アプリケーションに対するserviceタグ
                "name": "DD_SERVICE",
                "value": "foo"
            },
            {
                # アプリケーションに対するversionタグ            
                "name": "DD_VERSION",
                "value": "latest"
            }
        ],
        "secrets": [
            {
                "name": "DD_API_KEY",
                "valueFrom": "/prd-foo/DD_API_KEY"
            }
        ],
        "dockerLabels": {
            # ECSコンテナに対するenvタグ
            "com.datadoghq.tags.env": "prd",
            # ECSコンテナに対するserviceタグ            
            "com.datadoghq.tags.service": "foo",
            # ECSコンテナに対するversionタグ            
            "com.datadoghq.tags.version": "1.0.0"
        }
    }
]
```

#### ・IAMロール

Datadogコンテナがコンテナからメトリクスを収集できるように，ECSタスク実行ロールにポリシーを追加する必要がある．

参考：https://docs.datadoghq.com/ja/integrations/ecs_fargate/?tab=fluentbitandfirelens#iam-%E3%83%9D%E3%83%AA%E3%82%B7%E3%83%BC%E3%81%AE%E4%BD%9C%E6%88%90%E3%81%A8%E4%BF%AE%E6%AD%A3

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecs:ListClusters",
        "ecs:ListContainerInstances",
        "ecs:DescribeContainerInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

<br>

## 03-02. トレーシングパッケージ

### トレーシングパッケージとは

APM機能を用いる時に，トレースエージェントが稼働するDatadogコンテナに分散トレースを送信できるよう，サービスのコンテナでトレーシングパッケージをインストールする必要がある．パッケージはアプリケーションによって読み込まれた後，『```http://localhost:8126```』を指定して，分散トレースを送信するようになる．

参考：https://docs.datadoghq.com/ja/tracing/#datadog-%E3%81%B8%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B9%E3%82%92%E9%80%81%E4%BF%A1

![datadog-tracer](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/datadog-tracer.png)

<br>

### パッケージ一覧

参考：https://docs.datadoghq.com/ja/developers/libraries/#apm-%E3%81%A8%E5%88%86%E6%95%A3%E5%9E%8B%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%B3%E3%82%B0%E3%82%AF%E3%83%A9%E3%82%A4%E3%82%A2%E3%83%B3%E3%83%88%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA

<br>

### PHPトレーシングパッケージ

#### ・インストール

各サービスのDockerfileにて，パッケージをインストールする．

参考：https://docs.datadoghq.com/tracing/setup_overview/setup/php/?tab=containers

```dockerfile
ENV DD_TRACE_VERSION=0.63.0

# GitHubからパッケージをダウンロード
RUN curl -Lo https://github.com/DataDog/dd-trace-php/releases/download/${DD_TRACE_VERSION}/datadog-php-tracer_${DD_TRACE_VERSION}_amd64.deb \
  # 解凍
  && dpkg -i datadog-php-tracer.deb \
  # 残骸ファイルを削除
  && rm datadog-php-tracer.deb
```

アプリケーションがパッケージを読み込んだか否かをコマンドで確認できる．

```bash
# 成功の場合
root@*****:/ php --ri=ddtrace

ddtrace


Datadog PHP tracer extension
For help, check out the documentation at https://docs.datadoghq.com/tracing/languages/php/
(c) Datadog 2020

... まだまだ続く
```

```bash
# 失敗の場合
root@*****:/ php --ri=ddtrace
Extension 'ddtrace' not present.
```

#### ・環境変数

環境変数を使用できる．分散トレースのタグ名に反映される．環境変数については，以下のリンクを参考にせよ．

参考：https://docs.datadoghq.com/ja/tracing/setup_overview/setup/php/?tab=%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A#%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0%E3%82%B3%E3%83%B3%E3%83%95%E3%82%A3%E3%82%AE%E3%83%A5%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3

| 変数名                                        | 説明                                                         | 画面                                   |
| --------------------------------------------- | ------------------------------------------------------------ | -------------------------------------- |
| ```DD_SERVICE_MAPPING```                      | 分散トレースにサービス名を設定する．サービス名は標準のでインテグレーション名になるが，これを上書きできる<br>（例）```laravel:foo-laravel,pdo:foo-pdo``` | https://app.datadoghq.com/apm/services |
| ```DD_SERVICE_NAME```                         | 分散トレースにサービス名を設定する．```DD_SERVICE_MAPPING```がnullの場合，この環境変数の値が代わりにサービス名になる（仕組みがよくわからん）． |                                        |
| ```DD_TRACE_<インテグレーション名>_ENABLED``` | 有効化するインテグレーション名を設定する．標準で全てのインテグレーションが有効化されているため，設定は不要である．Datadogのインテグレーションを無効化する場合は |                                        |
| ```DD_<インテグレーション名>_DISABLED```      | 無効化するインテグレーション名を設定する．                   |                                        |

トレーサーの設定の状態は，```php --ri=ddtrace```コマンドの結果得られるJSONを整形することで確認できる．

```bash
root@*****:/ php --ri=ddtrace

Datadog tracing support => enabled
Version => 0.57.0
DATADOG TRACER CONFIGURATION => { ..... } # <--- ここに設定のJSONが得られる

# 得られたJSONを整形
{
    "date": "2021-00-00T09:00:00Z",
    "os_name": "Linux ***** 5.10.25-linuxkit #1 SMP Tue Mar 23 09:27:39 UTC 2021 x86_64",
    "os_version": "5.10.25-linuxkit",
    "version": "0.64.1",
    "lang": "php",
    "lang_version": "8.0.8",
    "env": null,
    "enabled": true,
    "service": null,
    "enabled_cli": false,
    "agent_url": "http://localhost:8126", # datadogコンテナのアドレスポート
    "debug": false,
    "analytics_enabled": false,
    "sample_rate": 1.000000,
    "sampling_rules": null,
    "tags": {},
    "service_mapping": {},
    "distributed_tracing_enabled": true,
    "priority_sampling_enabled": true,
    "dd_version": null,
    "architecture": "x86_64",
    "sapi": "cli",
    "datadog.trace.request_init_hook": "/opt/datadog-php/dd-trace-sources/bridge/dd_wrap_autoloader.php",
    "open_basedir_configured": false,
    "uri_fragment_regex": null,
    "uri_mapping_incoming": null,
    "uri_mapping_outgoing": null,
    "auto_flush_enabled": false,
    "generate_root_span": true,
    "http_client_split_by_domain": false,
    "measure_compile_time": true,
    "report_hostname_on_root_span": false,
    "traced_internal_functions": null,
    "auto_prepend_file_configured": false,
    "integrations_disabled": "default",
    "enabled_from_env": true,
    "opcache.file_cache": null,
    "agent_error": "Failed to connect to localhost port 8126: Connection refused", # エラーメッセージ
    "DDTRACE_REQUEST_INIT_HOOK": "'DDTRACE_REQUEST_INIT_HOOK=/opt/datadog-php/dd-trace-sources/bridge/dd_wrap_autoloader.php' is deprecated, use DD_TRACE_REQUEST_INIT_HOOK instead."
}
```

<br>

### Node.jsトレーシングパッケージ

#### ・TypeScriptやモジュールバンドルを使っている場合

エントリポイントとなる```nuxt.config.js```ファイルにて，一番最初にDatadogのトレースパッケージを読み込み，初期化する．

参考：https://docs.datadoghq.com/ja/tracing/setup_overview/setup/nodejs/?tab=%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A#typescript-%E3%81%A8%E3%83%90%E3%83%B3%E3%83%89%E3%83%A9%E3%83%BC

```typescript
import 'dd-trace/init'

// フレームワークを含むパッケージのインポートが続く
```

また，初期化時に設定した環境変数を使用できる．APMのサービスのタグ名に反映される．

参考：https://docs.datadoghq.com/ja/tracing/setup_overview/setup/nodejs/?tab=%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A#%E3%82%B3%E3%83%B3%E3%83%95%E3%82%A3%E3%82%AE%E3%83%A5%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3

<br>

### サービスの識別

#### ・サービスタイプ

トレーシングパッケージによって，サービスは『Web』『DB』『Cache』『Cache』の４つに分類される．各サービスの```span.type```属性に割り当てられるタイプ名から自動的に割り振られる．タイプ名の種類については，以下のリンクを参考にせよ．

参考：

- https://github.com/DataDog/dd-trace-php/blob/master/src/api/Type.php
- https://docs.datadoghq.com/ja/tracing/visualization/services_list/#%E3%82%B5%E3%83%BC%E3%83%93%E3%82%B9%E3%82%BF%E3%82%A4%E3%83%97

#### ・タグ

トレーシングパッケージによって，サービスにタグを追加できる．PHPトレーサの各インテグレーションのソースコードについては以下のリンクを参考にせよ．ソースコードから，PHPトレーサーがアプリケーションからどのように情報を抜き出し，分散トレースのタグの値を決定しているかがわかる．

参考：

- https://github.com/DataDog/dd-trace-php/tree/master/src/DDTrace/Integrations
- https://github.com/DataDog/dd-trace-php/blob/master/src/api/Tag.php

<br>

### メトリクスの識別

#### ・メトリクスの識別子

分散トレースの各メトリクスは，『```trace.[スパン名].[メトリクスサフィックス]```』で識別できる．

参考：https://docs.datadoghq.com/ja/tracing/guide/metrics_namespace/

#### ・スパン名

識別子のスパン名は，```span.name```属性から構成される．```span```には，サービス名を割り当てる．トレーシングパッケージによって，```redis```，```laravel.request```，```rails```，```pdo```などが自動で割り当てられる．

#### ・メトリクスサフィックス

メトリクス名を割り当てる．トレーシングパッケージによって，```duration```，```hits```，```span_count```などが自動で割り当てられる．

<br>

## 04. ログ収集 on Fargate

### FireLensコンテナ

#### ・FireLensコンテナとは

Datadogコンテナはコンテナからログを収集できないため，代わりにFireLensコンテナを用いる必要がある．以下のリンクを参考にせよ．

参考：

- https://docs.datadoghq.com/ja/integrations/ecs_fargate/?tab=fluentbitandfirelens
- https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_fluentd_and_fluentbit.html

#### ・ログエクスプローラ

FireLensコンテナからDatadogに転送されたログは，ログエクスプローラで確認できる．

参考：https://app.datadoghq.com/logs

<br>

### ベースイメージ

#### ・Datadogイメージ

DatadogコンテナのベースイメージとなるDatadogイメージがDatadog公式から提供されている．パブリックECRリポジトリからプルしたイメージをそのまま用いる場合と，プライベートECRリポジトリで再管理してから用いる場合がある．

#### ・パブリックECRリポジトリを用いる場合

ECSのコンテナ定義にて，パブリックECRリポジトリのURLを指定し，ECRイメージのプルを実行する．標準で内蔵されているyamlファイルの設定をそのまま用いる場合は，こちらを採用する．

参考：

- https://gallery.ecr.aws/datadog/agent
- https://github.com/DataDog/datadog-agent

#### ・プライベートECRリポジトリを用いる場合

あらかじめ，DockerHubからdatadogイメージをプルするためのDockerfileを作成し，プライベートECRリポジトリにイメージをプッシュしておく．ECSのコンテナ定義にて，プライベートECRリポジトリのURLを指定し，ECRイメージのプルを実行する．標準で内蔵されているyamlファイルの設定を上書きしたい場合は，こちらを採用する．

```dockerfile
FROM data/agent:latest
```

参考：https://hub.docker.com/r/datadog/agent

<br>

### 標準設定の上書き

参考：https://github.com/DataDog/datadog-agent/blob/main/pkg/config/config_template.yaml

<br>

## 05. メトリクス／ログの識別子

### attribute（属性）

#### ・予約済み属性

参考：https://docs.datadoghq.com/ja/logs/log_configuration/attributes_naming_convention/

| 属性名         | 説明                                   | 補足                                                         |
| -------------- | -------------------------------------- | ------------------------------------------------------------ |
| ```host```     | 送信元ホストを示す．                   | Datadogコンテナの環境変数にて，```DD_HOSTNAME```を用いてホストタグを設定する．これにより，ホストマップでホストを俯瞰できるようになるだけでなく，ログエクスプローラでホストタグが属性として付与される．<br>（例）```foo```，```bar-backend```，```baz-frontend``` |
| ```source```   | ログの生成元を示す．                   | ベンダー名を使用するとわかりやすい．<br>（例）```laravel```，```nginx```，```redis``` |
| ```status```   | ログのレベルを示す．                   |                                                              |
| ```service```  | ログの生成元のアプリケーションを示す． | ログとAPM分散トレースを紐づけるため，両方に同じ名前を割り当てる必要がある．<br>（例）```foo```，```bar-backend```，```baz-frontend``` |
| ```trace_id``` | 分散トレースとログを紐づけるIDを示す． |                                                              |
| ```message```  | ログメッセージを示す．                 |                                                              |

#### ・標準属性

標準で用意された属性．

参考：https://docs.datadoghq.com/ja/logs/log_configuration/attributes_naming_convention/#%E6%A8%99%E6%BA%96%E5%B1%9E%E6%80%A7

**＊例＊**

Laravelの場合

```shell
{
  "container_id": "*****",
  "container_name": "/prd-foo-ecs-container",
  "date": 12345,
  "log_status": "NOTICE",
  "service": "foo",
  "source": "laravel",
  "timestamp": 12345
}
```

**＊例＊**

Nginxの場合

```bash
{
  "id": "*****",
  "content": {
    "timestamp": "2021-09-01T00:00:00.000Z",
    "tags": [
      "source:nginx",
      "env:prd"
    ],
    "service": "foo",
    "message": "nn.nnn.nn.nnn - - [01/Sep/2021:00:00:00 +0000] \"GET /healthcheck HTTP/1.1\" 200 17 \"-\" \"ELB-HealthChecker/2.0\"",
    "attributes": {
      "http": {
        "url_details": {
          "path": "/healthcheck"
        },
        "referer": "-",
        "method": "GET",
        "useragent_details": {
          "device": {
            "family": "Other",
            "category": "Other"
          },
          "os": {
            "family": "Other"
          },
          "browser": {
            "family": "Other"
          }
        },
        "status_category": "info",
        "url": "/healthcheck",
        "status_code": 200,
        "version": "1.1",
        "useragent": "ELB-HealthChecker/2.0"
      },
      "network": {
        "client": {
          "ip": "nn.nnn.nn.nnn"
        },
        "bytes_written": 17
      },
      "date_access": 12345,
      "timestamp": 12345,
      "service": "foo"
    }
  }
}
```

#### ・スタックトレース属性

スタックトレースログを構成する要素に付与される属性のこと．

参考：https://docs.datadoghq.com/ja/logs/log_collection/?tab=host#%E3%82%B9%E3%82%BF%E3%83%83%E3%82%AF%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B9%E3%81%AE%E5%B1%9E%E6%80%A7

| 属性名                   | 説明                                             |
| ------------------------ | ------------------------------------------------ |
| ```logger.name```        | ログライブラリの名前を示す．                     |
| ```logger.thread_name``` | スレッド名を示す．                               |
| ```error.stack```        | スタックトレースログ全体を示す．                 |
| ```error.message```      | スタックトレースログのメッセージ部分を示す．     |
| ```error.kind```         | エラーの種類（Exception，OSError，など）を示す． |

<br>

### タグ

<br>

### 各識別子の有効期間

変更前の識別子は，時間経過とともにDatadogから削除される．

参考：https://docs.datadoghq.com/ja/dashboards/faq/historical-data/

<br>

### テレメトリー間のタグの紐づけ

ログの統合タグ（```service```，```env```，```version```）と分散トレースの環境変数の値（サービス名，環境名，バージョン名）を全て同じ名前にすると，テレメトリー（ログ，メトリクス，分散トレース）間を紐づけることができる．ログと分散が有効になっているかどうかは，APMのサービスサブの『```Service Config```』から確認できる．

参考：https://docs.datadoghq.com/ja/tracing/connect_logs_and_traces/

<br>

## 06. ログパイプライン

### ログパイプラインとは

Datadogに流入するログのメッセージから値を抽出し，構造化ログの各属性に割り当てる．パイプラインのルールに当てはまらなかったされなかったログは，そのまま流入する．属性ごとにファセットに対応しており，各ファセットの値判定ルールに基づいて，ログコンソール画面に表示される．

<br>

### リマッパー

#### ・リマッパーとは

指定した属性に割り当てられた値を，Datadogにおけるログ指標に対応付ける．

#### ・ログステータスリマッパー

属性に割り当てられた値を，ルールに基づいて，ステータスファセットの各ステータス（```INFO```，```WARNING```，```ERROR```，など）にマッピングする．ログコンソール画面にて，ステータスファセットとして表示される．判定ルールについては，以下のリンクを参考にせよ．

参考：https://docs.datadoghq.com/ja/logs/processing/processors/?tab=ui#%E3%83%AD%E3%82%B0%E3%82%B9%E3%83%86%E3%83%BC%E3%82%BF%E3%82%B9%E3%83%AA%E3%83%9E%E3%83%83%E3%83%91%E3%83%BC

<br>

### ログパーサー

#### ・パーサーとは

ログに対して，何かしらの加工を実行する．

#### ・Grokパーサー

パースルール（```%{MATCHER:EXTRACT:FILTER}```）を用いて，属性にログ値を割り当てる．

参考：

- https://docs.datadoghq.com/ja/logs/processing/parsing/?tab=matcher
- https://docs.datadoghq.com/ja/logs/processing/processors/?tab=ui#grok-%E3%83%91%E3%83%BC%E3%82%B5%E3%83%BC

**＊例＊**

Laravelによって，以下のようなログが生成されるとする．

```log
[2021-01-01 00:00:00] staging.ERROR: ログのメッセージ
```

```log
[2021-01-01 00:00:00] production.ERROR: ログのメッセージ
```

以下のようなGrokパーサールールを定義する．```date```マッチャーを用いて，```date```属性にタイムスタンプ値を割り当てる．また，```word```マッチャーを用いて，```log_status```カスタム属性にステータス値を割り当てる．

```
FooRule \[%{date("yyyy-MM-dd HH:mm:ss"):date}\]\s+(production|staging).%{word:log_status}\:.+
```

これにより，構造化ログの各属性に値が割り当てられる．

```bash
{
  "date": 1630454400000,
  "log_status": "INFO"
}
```

#### ・カテゴリパーサー

検索条件に一致する属性を持つログ値に対して，属性を新しく付与する．

**＊例＊**

Nginxによって，以下のようなログが生成されるとする．

```log
nn.nnn.nn.nn - - [01/Sep/2021:00:00:00 +0000] "GET /healthcheck HTTP/1.1" 200 17 "-" "ELB-HealthChecker/2.0"
```

以下のようなGrokパーサールールを定義する．```status_code```属性にステータスコード値を割り当てる．

```
access.common %{_client_ip} %{_ident} %{_auth} \[%{_date_access}\] "(?>%{_method} |)%{_url}(?> %{_version}|)" %{_status_code} (?>%{_bytes_written}|-)
access.combined %{access.common} (%{number:duration:scale(1000000000)} )?"%{_referer}" "%{_user_agent}"( "%{_x_forwarded_for}")?.*
error.format %{date("yyyy/MM/dd HH:mm:ss"):date_access} \[%{word:level}\] %{data:error.message}(, %{data::keyvalue(": ",",")})?
```

これにより，構造化ログの各属性に値が割り当てられる．

```bash
{
  "http": {
    "method": "GET",
    "referer": "-",
    "status_code": 200,
    "url": "/healthcheck",
    "useragent": "ELB-HealthChecker/2.0",
    "version": "1.1"
  },
  "network": {
    "bytes_written": 17,
    "client": {
      "ip": "nn.nnn.nnn.nn"
    }
  },
  "date_access": 12345
}
```

以下のようなカテゴリパーサーを定義する．```status_code```属性の値に応じて，異なるステータスコード値（```info```，```notice```，```warning```，```error```）の```http.status_category```属性を付与する．

```
info    @http.status_code:[200 TO 299]
notice  @http.status_code:[300 TO 399]
warning @http.status_code:[400 TO 499]
error   @http.status_code:[500 TO 599]
```

ステータスリマッパーを定義する．```http.status_category```属性のステータスコード値に応じて，ステータスファセットの各ステータス（```INFO```，```WARNING```，```ERROR```，など）にマッピングする．

#### ・ユーザエージェントパーサー

**＊例＊**

Nginxによって，以下のようなログが生成されるとする．

```log
nn.nnn.nn.nn - - [01/Sep/2021:00:00:00 +0000] "GET /healthcheck HTTP/1.1" 200 17 "-" "ELB-HealthChecker/2.0"
```

以下のようなGrokパーサールールを定義する．```http.useragent```属性にユーザエージェント値を割り当てる．

```
access.common %{_client_ip} %{_ident} %{_auth} \[%{_date_access}\] "(?>%{_method} |)%{_url}(?> %{_version}|)" %{_status_code} (?>%{_bytes_written}|-)
access.combined %{access.common} (%{number:duration:scale(1000000000)} )?"%{_referer}" "%{_user_agent}"( "%{_x_forwarded_for}")?.*
error.format %{date("yyyy/MM/dd HH:mm:ss"):date_access} \[%{word:level}\] %{data:error.message}(, %{data::keyvalue(": ",",")})?
```

これにより，構造化ログの各属性に値が割り当てられる．

```bash
{
  "http": {
    "method": "GET",
    "referer": "-",
    "status_code": 200,
    "url": "/healthcheck",
    "useragent": "ELB-HealthChecker/2.0",
    "version": "1.1"
  },
  "network": {
    "bytes_written": 17,
    "client": {
      "ip": "nn.nnn.nnn.nn"
    }
  },
  "date_access": 12345
}
```

ユーザエージェントパーサーを定義する．```http.useragent```属性の値を分解し，```useragent_details```属性に振り分ける．これにより，構造化ログの各属性に値が割り当てられる．

```bash
{
  # ～ 中略 ～

  "useragent_details": {
    "device": {
      "family": "Other",
      "category": "Other"
    },
    "os": {
      "family": "Linux"
    },
    "browser": {
      "family": "Chrome"
    }
  },
  
  # ～ 中略 ～
}
```

<br>

### パースルールの構成

#### ・マッチャー

参考：https://docs.datadoghq.com/ja/logs/processing/parsing/?tab=matcher#%E3%83%9E%E3%83%83%E3%83%81%E3%83%A3%E3%83%BC%E3%81%A8%E3%83%95%E3%82%A3%E3%83%AB%E3%82%BF%E3%83%BC

#### ・フィルター

参考：https://docs.datadoghq.com/ja/logs/processing/parsing/?tab=filter#%E3%83%9E%E3%83%83%E3%83%81%E3%83%A3%E3%83%BC%E3%81%A8%E3%83%95%E3%82%A3%E3%83%AB%E3%82%BF%E3%83%BC

<br>

## 06-02. ログパイプラインの後処理

### Live Tail

### ・Live Tailとは

ログパイプライン処理後のログをリアルタイムで確認できる．

<br>

### 標準属性

<br>

## 06-03. オプション処理

### ログのメトリクス

#### ・ログのメトリクスとは

パイプラインで処理を終えたログに関して，タグや属性に基づくメトリクスを作成する．メトリクスを作成しておくと，ログのレポートとして使用できる．

参考：https://www.amazon.co.jp/dp/1800568738

<br>

### インデックス

#### ・インデックスとは

パイプラインで処理を終えたログをグループ化し，ログの破棄ルールや保管期間をグループごとに定義できる．インデックスを使用すれば，Datadogのログ保管のネックになる保管料金を抑えられる．

参考：

- https://docs.datadoghq.com/ja/logs/indexes/
- https://tech-blog.abeja.asia/entry/why-datadog

<br>

### アーカイブ

<br>

### セキュリティルール

<br>

## 07. モニター

### ログモニター

#### ・シングルアラート

#### ・マルチアラート

ログクエリで```group by```句を定義すると，選択できるようになる．

<br>

## 07-02. 通知

### テンプレート変数

参考：https://docs.datadoghq.com/ja/monitors/notify/variables/?tab=is_alert#template-variables

<br>

### タグ変数

#### ・タグ変数とは

クエリの```group by```句に割り当てたタグやファセットを変数として出力できる．マルチアラートモニターを使用する場合のみ，使用できる．

参考：https://docs.datadoghq.com/ja/monitors/notify/variables/?tab=is_alert#tag-variables

#### ・ログファセット変数

クエリの```group by```句でファセットを割り当てた場合に使用できる．

参考：https://docs.datadoghq.com/ja/monitors/notify/variables/?tab=is_alert#log-facet-variables

#### ・コンポジットモニター変数とは

参考：https://docs.datadoghq.com/ja/monitors/notify/variables/?tab=is_alert#composite-monitor-variables

<br>

### 条件変数

参考：https://docs.datadoghq.com/ja/monitors/notify/variables/?tab=is_alert#conditional-variables

<br>

### メッセージの構成

#### ・タイトル

通知先にタイトルとして表示するテキストを定義する．タイトルに変数を出力できる．

```markdown
<!-- group by句に割り当てたタグを変数として出力する -->
【{{service.name}}】エラーを検知しました
```

#### ・本文

通知先とテキストを定義する．マークダウン記法を使用できる．

```markdown
<!-- Datadogに設定した通知先 -->
<!-- 復旧通知を転送しない場合，is_alert構文の外で定義する必要がある -->
@<通知先>

<!-- アラート状態の時に表示するテキスト -->
{{#is_alert}}

エラーメッセージです

{{/is_alert}}
```

<br>


## 08. インテグレーション

### メトリクスインテグレーション

#### ・メトリクスインテグレーションとは

言語／フレームワーク／ツール，などに関して，専用のメトリクスを収集できるようになる．アプリケーションとして使用される言語／フレームワークの場合，Datadogエージェントがインテグレーション処理を持つため，サーバ／コンテナへのインストールは不要である．Datedogエージェントがコンテナ／サーバで稼働する言語／フレームワーク／ツールを自動で認識してくれる．

#### ・PHP-FPMインテグレーション

PHP-FPMインテグレーションを有効化した場合，以下の専用メトリクスを収集できるようになる．

参考：https://docs.datadoghq.com/ja/integrations/php_fpm/?tab=host#%E3%83%A1%E3%83%88%E3%83%AA%E3%82%AF%E3%82%B9

#### ・Nginxインテグレーション

Nginxインテグレーションを有効化した場合，以下の専用メトリクスを収集できるようになる．

参考：https://docs.datadoghq.com/ja/integrations/nginx/?tab=host#%E3%83%A1%E3%83%88%E3%83%AA%E3%82%AF%E3%82%B9

<br>

### 分散トレースインテグレーション

#### ・分散トレースインテグレーションとは

言語／フレームワーク／ツール，などに関して，専用の分散トレースを収集できるようになる．アプリケーションとして使用される言語／フレームワークの場合，トレースエージェントがインテグレーション処理を持つため，サーバ／コンテナへのインストールは不要である．については，以下のリンクを参考にせよ．

参考：https://github.com/DataDog/dd-trace-php/tree/master/src/DDTrace/Integrations

<br>

## 09. グラフ

### 図の種類

### スケールの種類

#### ・log（対数）スケール

#### ・linear（線形）スケール

#### ・２の累乗スケール

#### ・sqrt（平方根）スケール

<br>







