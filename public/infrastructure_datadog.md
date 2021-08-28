# Datadog

## Datadogとは

### 概要

<br>

## メトリクス／ログ収集の仕組み

### Datadogエージェント

#### ・Datadogエージェント

常駐プログラムであり，アプリケーションからメトリクスを収集し，Datadogに転送する．

![datadog-agent_on-server](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/datadog-agent_on-server.png)

<br>

## メトリクス／ログ収集 on Ec2

参考：https://docs.datadoghq.com/ja/agent/amazon_ecs/?tab=awscli

<br>

## メトリクス収集 on Fargate

### Datadogコンテナ

#### ・Datadogコンテナとは

Datadogが提供するdatadogイメージによって構築されるコンテナであり，コンテナのサイドカーコンテナとして配置される．コンテナ内で稼働するDatadog Dockerエージェントが，コンテナからメトリクスを収集し，Datadogにこれを転送する．

参考：https://docs.datadoghq.com/ja/agent/docker/?tab=%E6%A8%99%E6%BA%96#%E7%B5%B1%E5%90%88

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
                "awslogs-group": "/prd-/laravel/log",
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

### Dockerエージェント環境変数

#### ・必須

| 変数名      | 説明                                    | DatadogコンソールURL |
| ----------- | --------------------------------------- | -------------------- |
| ECS_FARGATE | Fargateを実行環境とすることを宣言する． |                      |



#### ・オプションメトリクス収集

参考：https://docs.datadoghq.com/ja/agent/docker/?tab=%E6%A8%99%E6%BA%96#%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E5%8F%8E%E9%9B%86-agent

| 変数名                   | 説明                                                         | DatadogコンソールURL                        | 補足                                                         |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------- | ------------------------------------------------------------ |
| DD_APM_ENABLED           | APMエージェントを有効化し，分散トレースを収集する．APMでは，分散トレースを元にして，サービス間の関係がグラフ化される．<br>参考：<br>・https://docs.datadoghq.com/ja/getting_started/tracing/<br>・https://docs.datadoghq.com/ja/tracing/#datadog-apm-%E3%81%AE%E7%A2%BA%E8%AA%8D | https://app.datadoghq.com/apm/home?env=none | Fargateを使用している場合，アプリケーション側では，分散トレースを送信できるように，ライブラリのインストールが必要である．<br>参考：<br>・https://docs.datadoghq.com/ja/integrations/ecs_fargate/?tab=fluentbitandfirelens#%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B9%E3%81%AE%E5%8F%8E%E9%9B%86<br>・https://docs.datadoghq.com/ja/tracing/setup/ |
| DD_LOGS_ENABLED          | -                                                            |                                             |                                                              |
| DD_PROCESS_AGENT_ENABLED | ライブプロセスを有効化し，実行中のプロセスを収集する．<br>参考：https://docs.datadoghq.com/ja/infrastructure/process/?tab=linuxwindows | https://app.datadoghq.com/containers        |                                                              |

#### ・カスタムメトリクス収集

参考：https://docs.datadoghq.com/ja/agent/docker/?tab=%E6%A8%99%E6%BA%96#dogstatsd-%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%A0%E3%83%A1%E3%83%88%E3%83%AA%E3%82%AF%E3%82%B9

| 変数名                         | 説明                                                    | DatadogコンソールURL |
| ------------------------------ | ------------------------------------------------------- | -------------------- |
| DD_DOGSTATSD_NON_LOCAL_TRAFFIC | Datadogコンテナのカスタムメトリクスの受信を有効化する． |                      |

<br>

### APMエージェント環境変数

Dockerエージェントにて，```DD_APM_ENABLED```の環境変数に```true```を割り当てると，APMエージェントが有効になる．

参考：https://docs.datadoghq.com/ja/agent/docker/apm/?tab=linux#docker-apm-agent-environment-variables



<br>

## ログ収集 on Fargate

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

## メトリクスのグラフ化

### 図の種類

### スケールの種類

#### ・log（対数）スケール

#### ・linear（線形）スケール

#### ・２の累乗スケール

#### ・sqrt（平方根）スケール





