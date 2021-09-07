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
| DD_ENV      | APMを使用する場合に，サービスやトレース画面にて，```env```タグに文字列を設定する． | サービス単位で絞り込めるように，```prd-foo```や```stg-foo```とした方が良い． | https://app.datadoghq.com/apm/services       |
| DD_HOSTNAME | ホストマップ                                                 |                                                              | https://app.datadoghq.com/infrastructure/map |
| DD_SERVICE  | インフラストラクチャ画面にて，```service```タグに文字列を設定する． |                                                              | https://app.datadoghq.com/containers         |
| ECS_FARGATE | Fargateを使用する場合に，これを宣言する．                    |                                                              |                                              |

任意で選択できるメトリクスの収集として役立つ環境変数を以下に示す．一部のメトリクスは，標準では収集しないようになっており，収集するためにエージェントを有効化する必要がある．

参考：https://docs.datadoghq.com/ja/agent/docker/?tab=%E6%A8%99%E6%BA%96#%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E5%8F%8E%E9%9B%86-agent

| 変数名                   | 説明                                                         | 補足                                                         | DatadogコンソールURL                 |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------ |
| DD_APM_ENABLED           | APMエージェントを有効化し，分散トレースを収集する．APMでは，分散トレースを元にして，サービス間の関係がグラフ化される．<br>参考：<br>・https://docs.datadoghq.com/ja/getting_started/tracing/<br>・https://docs.datadoghq.com/ja/tracing/#datadog-apm-%E3%81%AE%E7%A2%BA%E8%AA%8D | Fargateを使用している場合，アプリケーション側では，分散トレースを送信できるように，ライブラリのインストールが必要である．<br>参考：<br>・https://app.datadoghq.com/apm/docs?architecture=host-based&framework=php-fpm&language=php<br>・https://docs.datadoghq.com/ja/tracing/#datadog-%E3%81%B8%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B9%E3%82%92%E9%80%81%E4%BF%A1 | https://app.datadoghq.com/apm/home   |
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

Dockerエージェントにて，```DD_APM_ENABLED```の環境変数に```true```を割り当てると，トレースエージェントが有効になる．

参考：https://docs.datadoghq.com/ja/agent/docker/apm/?tab=linux

#### ・環境変数

一部の環境変数は，Dockerエージェントの環境変数と重なる．

参考：https://docs.datadoghq.com/ja/agent/docker/apm/?tab=linux#docker-apm-agent-%E3%81%AE%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0

| 変数名       | 説明                                |      |
| ------------ | ----------------------------------- | ---- |
| DD_LOG_LEVEL | APMに送信するログレベルを設定する． |      |

<br>

### トレーシングライブラリ

#### ・トレーシングライブラリとは

トレースエージェントが稼働するDatadogコンテナに分散トレースを送信できるよう，アプリケーションコンテナでトレーシングライブラリをインストールする必要がある．

参考：

- https://docs.datadoghq.com/ja/developers/libraries/#apm-%E3%81%A8%E5%88%86%E6%95%A3%E5%9E%8B%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%B3%E3%82%B0%E3%82%AF%E3%83%A9%E3%82%A4%E3%82%A2%E3%83%B3%E3%83%88%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA
- https://docs.datadoghq.com/ja/tracing/#datadog-%E3%81%B8%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B9%E3%82%92%E9%80%81%E4%BF%A1

#### ・PHPの場合

**＊実装例＊**

Dockerfileにて，パッケージをインストールする．

参考：https://docs.datadoghq.com/tracing/setup_overview/setup/php/?tab=containers

```dockerfile
ENV DD_TRACE_VERSION=0.63.0

# GitHubからパッケージをダウンロード
RUN curl -Lo datadog-php-tracer.tar.gz https://github.com/DataDog/dd-trace-php/releases/download/${DD_TRACE_VERSION}/datadog-php-tracer-${DD_TRACE_VERSION}.x86_64.tar.gz \
  # 解凍
  && tar -zxvf datadog-php-tracer.tar.gz \
  # 残骸ファイルを削除
  && rm datadog-php-tracer.tar.gz
```

また，環境変数を使用できる．APMのサービスのタグ名に反映される．

参考：https://docs.datadoghq.com/ja/tracing/setup_overview/setup/php/?tab=%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A#%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0%E3%82%B3%E3%83%B3%E3%83%95%E3%82%A3%E3%82%AE%E3%83%A5%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3

#### ・Node.jsの場合

**＊実装例（TypeScriptやモジュールバンドルを使っている場合）＊**

エントリポイントとなる```nuxt.config.js```ファイルにて，一番最初にDatadogのトレースライブラリを読み込み，初期化する．

参考：https://docs.datadoghq.com/ja/tracing/setup_overview/setup/nodejs/?tab=%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A#typescript-%E3%81%A8%E3%83%90%E3%83%B3%E3%83%89%E3%83%A9%E3%83%BC

```typescript
import 'dd-trace/init'

// フレームワークを含むパッケージのインポートが続く
```

また，初期化時に設定した環境変数を使用できる．APMのサービスのタグ名に反映される．

参考：https://docs.datadoghq.com/ja/tracing/setup_overview/setup/nodejs/?tab=%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A#%E3%82%B3%E3%83%B3%E3%83%95%E3%82%A3%E3%82%AE%E3%83%A5%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3

<br>

### Datadogコンテナ

#### ・Datadogコンテナとは

Datadogが提供するdatadogイメージによって構築されるコンテナであり，コンテナのサイドカーコンテナとして配置される．コンテナ内で稼働するDatadog Dockerエージェントが，コンテナからメトリクスを収集し，Datadogにこれを転送する．

参考：https://docs.datadoghq.com/ja/integrations/ecs_fargate/?tab=fluentbitandfirelens#%E6%A6%82%E8%A6%81

#### ・Datadogコンテナの配置

```shell
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
                "name": "DD_SERVICE",
                "value": "foo"
            },
            {
                "name": "DD_VERSION",
                "value": "latest"
            },
            {
                "name": "DD_HOSTNAME",
                "value": "foo"
            }
        ],
        "secrets": [
            {
                "name": "DD_API_KEY",
                "valueFrom": "/prd-foo/DD_API_KEY"
            }
        ],
        "dockerLabels": {
            "com.datadoghq.tags.env": "prd",
            "com.datadoghq.tags.service": "foo",
            "com.datadoghq.tags.version": "1.0.0"
        }
    }
]
```

#### ・IAMロール

Datadogコンテナがコンテナからメトリクスを収集できるように，ECSタスク実行ロールにポリシーを追加する必要がある．

参考：https://docs.datadoghq.com/ja/integrations/ecs_fargate/?tab=fluentbitandfirelens#iam-%E3%83%9D%E3%83%AA%E3%82%B7%E3%83%BC%E3%81%AE%E4%BD%9C%E6%88%90%E3%81%A8%E4%BF%AE%E6%AD%A3

```shell
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

## 03-02. ログ収集 on Fargate

### FireLensコンテナ

#### ・FireLensコンテナとは

Datadogコンテナはコンテナからログを収集できないため，代わりにFireLensコンテナを使用する必要がある．以下のリンクを参考にせよ．

参考：

- https://docs.datadoghq.com/ja/integrations/ecs_fargate/?tab=fluentbitandfirelens
- https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_fluentd_and_fluentbit.html

<br>

### ベースイメージ

#### ・Datadogイメージ

DatadogコンテナのベースイメージとなるDatadogイメージがDatadog公式から提供されている．パブリックECRリポジトリからプルしたイメージをそのまま使用する場合と，プライベートECRリポジトリで再管理してから使用する場合がある．

#### ・パブリックECRリポジトリを使用する場合

ECSのコンテナ定義にて，パブリックECRリポジトリのURLを指定し，ECRイメージのプルを実行する．標準で内蔵されているyamlファイルの設定をそのまま使用する場合は，こちらを採用する．

参考：

- https://gallery.ecr.aws/datadog/agent
- https://github.com/DataDog/datadog-agent

#### ・プライベートECRリポジトリを使用する場合

あらかじめ，DockerHubからdatadogイメージをプルするためのDockerfileを作成し，プライベートECRリポジトリにイメージをプッシュしておく．ECSのコンテナ定義にて，プライベートECRリポジトリのURLを指定し，ECRイメージのプルを実行する．標準で内蔵されているyamlファイルの設定を上書きしたい場合は，こちらを採用する．

```dockerfile
FROM data/agent:latest
```

参考：https://hub.docker.com/r/datadog/agent

<br>

### 標準設定の上書き

参考：https://github.com/DataDog/datadog-agent/blob/main/pkg/config/config_template.yaml

<br>

## 04. メトリクスのグラフ化

### 図の種類

### スケールの種類

#### ・log（対数）スケール

#### ・linear（線形）スケール

#### ・２の累乗スケール

#### ・sqrt（平方根）スケール





