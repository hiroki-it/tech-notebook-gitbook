# Datadog

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Datadogとは

### 概要

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

| 変数名      | 説明                                                         | 補足                                                         | DatadogコンソールURL                         |
| ----------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------------------------------------------- |
| DD_API_KEY  | DatadogコンテナがあらゆるデータをDatadogに送信するために必要である． |                                                              |                                              |
| DD_ENV      | APMを用いる場合に，サービスやトレース画面にて，```env```タグに文字列を設定する． | サービス単位で絞り込めるように，```prd-foo```や```stg-foo```とした方が良い． | https://app.datadoghq.com/apm/services       |
| DD_HOSTNAME | ホストマップ                                                 |                                                              | https://app.datadoghq.com/infrastructure/map |
| ECS_FARGATE | Fargateを用いる場合に，これを宣言する．                      |                                                              |                                              |

任意で選択できるメトリクスの収集として役立つ環境変数を以下に示す．一部のメトリクスは，標準では収集しないようになっており，収集するためにエージェントを有効化する必要がある．

参考：https://docs.datadoghq.com/ja/agent/docker/?tab=%E6%A8%99%E6%BA%96#%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E5%8F%8E%E9%9B%86-agent

| 変数名                   | 説明                                                         | 補足                                                         | DatadogコンソールURL                 |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------ |
| DD_APM_ENABLED           | APMエージェントを有効化する．                                | Fargateを使用している場合，APMエージェントを有効化するだけでなく，分散トレースを送信できるように，サービスにパッケージのインストールが必要である．<br>参考：<br>・https://app.datadoghq.com/apm/docs?architecture=host-based&framework=php-fpm&language=php<br>・https://docs.datadoghq.com/ja/tracing/#datadog-%E3%81%B8%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B9%E3%82%92%E9%80%81%E4%BF%A1 | https://app.datadoghq.com/apm/home   |
| DD_LOGS_ENABLED          | -                                                            |                                                              |                                      |
| DD_PROCESS_AGENT_ENABLED | ライブプロセスを有効化し，実行中のプロセスを収集する．<br>参考：https://docs.datadoghq.com/ja/infrastructure/process/?tab=linuxwindows |                                                              | https://app.datadoghq.com/containers |

カスタムメトリクスの収集として役立つ環境変数を以下に示す．

参考：https://docs.datadoghq.com/ja/agent/docker/?tab=%E6%A8%99%E6%BA%96#dogstatsd-%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%A0%E3%83%A1%E3%83%88%E3%83%AA%E3%82%AF%E3%82%B9

| 変数名                         | 説明                                                    | DatadogコンソールURL |
| ------------------------------ | ------------------------------------------------------- | -------------------- |
| DD_DOGSTATSD_NON_LOCAL_TRAFFIC | Datadogコンテナのカスタムメトリクスの受信を有効化する． |                      |

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

| 変数名       | 説明                                | 補足 |
| ------------ | ----------------------------------- | ---- |
| DD_LOG_LEVEL | APMに送信するログレベルを設定する． |      |

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

| 変数名             | 説明                                                         | 画面                                   |
| ------------------ | ------------------------------------------------------------ | -------------------------------------- |
| DD_SERVICE         | アプリケーション                                             |                                        |
| DD_SERVICE_MAPPING | APMにて，標準で設定されるサービス名を上書きする．<br>（例）```laravel:foo-laravel,pdo:foo-pdo``` | https://app.datadoghq.com/apm/services |

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

トレーシングパッケージによって，サービスにタグを追加できる．

参考：https://github.com/DataDog/dd-trace-php/blob/master/src/api/Tag.php

<br>

### メトリクスの識別

#### ・メトリクスの識別子

分散トレースの各メトリクスは，『```trace.<スパン名>.<メトリクスサフィックス>```』で識別できる．

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

### ログと分散トレースの接続

ログとトレーシングパッケージによるタグに同じタグ名を付与すると，ログと分散トレースを紐づけることができる．

https://docs.datadoghq.com/ja/tracing/connect_logs_and_traces/

<br>

## 05. ログエクスプローラ

### attribute（属性）

#### ・予約済み属性

参考：https://docs.datadoghq.com/ja/logs/log_configuration/attributes_naming_convention/

| 属性名         | 説明                                       | 補足                                                         |
| -------------- | ------------------------------------------ | ------------------------------------------------------------ |
| ```host```     | 送信元ホストを識別する．                   | Datadogコンテナの環境変数にて，```DD_HOSTNAME```を用いてホストタグを設定する．これにより，ホストマップでホストを俯瞰できるようになるだけでなく，ログエクスプローラでホストタグが属性として付与される．<br>（例）```foo```，```bar-backend```，```baz-frontend``` |
| ```source```   | ログの生成元を識別する．                   | ベンダー名を使用するとわかりやすい．<br>（例）```laravel```，```nginx```，```redis``` |
| ```status```   | ログのレベルを識別する．                   |                                                              |
| ```service```  | ログの生成元のアプリケーションを識別する． | ログとAPM分散トレースを紐づけるため，両方に同じ名前を割り当てる必要がある．<br>（例）```foo```，```bar-backend```，```baz-frontend``` |
| ```trace_id``` | 分散トレースとログを紐づけるIDを識別する． |                                                              |
| ```message```  | ログメッセージを識別する．                 |                                                              |

#### ・標準属性

標準で用意された属性．

参考：https://docs.datadoghq.com/ja/logs/log_configuration/attributes_naming_convention/#%E6%A8%99%E6%BA%96%E5%B1%9E%E6%80%A7

```shell
{
  "container_id": "*****",
  "container_name": "/prd-foo-ecs-container",
  "date": 1632949140000,
  "log_status": "NOTICE",
  "service": "foo",
  "source": "laravel",
  "timestamp": 1632916740240
}
```



#### ・スタックトレース属性

スタックトレースログを構成する要素に付与される属性のこと．

参考：https://docs.datadoghq.com/ja/logs/log_collection/?tab=host#%E3%82%B9%E3%82%BF%E3%83%83%E3%82%AF%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B9%E3%81%AE%E5%B1%9E%E6%80%A7

<br>

### ログパーサー

#### ・パーサーとは

ログに対して，何かしらの加工を実行する．

#### ・Grokパーサー

パースルール（```%{MATCHER:EXTRACT:FILTER}```）を用いて，ログの値を属性に割り当てる．

参考：

- https://docs.datadoghq.com/ja/logs/processing/parsing/?tab=matcher
- https://docs.datadoghq.com/ja/logs/processing/processors/?tab=ui#grok-%E3%83%91%E3%83%BC%E3%82%B5%E3%83%BC

**＊例＊**

アプリケーションによって，以下のようなログが生成されるとする．

```log
[2021-01-01 00:00:00] staging.ERROR: ログのメッセージ
```

```log
[2021-01-01 00:00:00] production.ERROR: ログのメッセージ
```

以下のようなルールを定義する．ここでは，```date```マッチャーと```word```マッチャーを用いている．また，```log_status```というカスタム属性に対して，```word```マッチャーによって検出された文字列を付与している．

```
FooRule \[%{date("yyyy-MM-dd HH:mm:ss"):date}\]\s+(production|staging).%{word:log_status}\:.+
```

これにより，ログの値が属性に割り当てられる．

```bash
{
  "date": 1630454400000,
  "log_status": "INFO"
}
```

#### ・Categoryパーサー

検索条件に一致する属性を持つログに対して，属性を新しく付与する．

**＊例＊**

ログに対してGrokパーサを実行し，属性にログの値を割り当てる．```status_code```属性を持つログに対して，```status_category```属性を付与する．この時，```status_code```属性の数値に応じて，```status_category```属性にステータスを表す文字列を割り当てる．その後，```status_category```属性に対してステータスリマッパーを実行する．これにより，```status_category```属性に割り当てられた文字列に応じて，ログレベルがマッピングされる．

<br>

### パースルールの構成

#### ・マッチャー

参考：https://docs.datadoghq.com/ja/logs/processing/parsing/?tab=matcher#%E3%83%9E%E3%83%83%E3%83%81%E3%83%A3%E3%83%BC%E3%81%A8%E3%83%95%E3%82%A3%E3%83%AB%E3%82%BF%E3%83%BC

#### ・フィルター

参考：https://docs.datadoghq.com/ja/logs/processing/parsing/?tab=filter#%E3%83%9E%E3%83%83%E3%83%81%E3%83%A3%E3%83%BC%E3%81%A8%E3%83%95%E3%82%A3%E3%83%AB%E3%82%BF%E3%83%BC

<br>

### リマッパー

#### ・リマッパーとは

指定した属性に割り当てられた値を，Datadogにおけるログ指標に対応付ける．

#### ・ログステータスリマッパー

属性に割り当てられた文字列を，ルールに基づいて，特定のログレベル（```INFO```，```WARNING```，```ERROR```，など）にマッピングする．判定ルールについては，以下のリンクを参考にせよ．

参考：https://docs.datadoghq.com/ja/logs/processing/processors/?tab=ui#%E3%83%AD%E3%82%B0%E3%82%B9%E3%83%86%E3%83%BC%E3%82%BF%E3%82%B9%E3%83%AA%E3%83%9E%E3%83%83%E3%83%91%E3%83%BC

<br>

### インデックス

#### ・インデックスとは

転送されたログをグループ化し，グループ別に異なる処理を実行する．

参考：https://docs.datadoghq.com/ja/logs/indexes/



<br>

## 06. APM

### 図の種類

### スケールの種類

#### ・log（対数）スケール

#### ・linear（線形）スケール

#### ・２の累乗スケール

#### ・sqrt（平方根）スケール

<br>

### 07. その他

### 各識別子の有効期間

変更前の識別子は，時間経過とともにDatadogから削除される．

参考：https://docs.datadoghq.com/ja/dashboards/faq/historical-data/









