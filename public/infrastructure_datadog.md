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

## EC2コンテナからのメトリクス／ログ収集

参考：https://docs.datadoghq.com/ja/agent/amazon_ecs/?tab=awscli

<br>

## Fargateコンテナからのメトリクス／ログ収集

### Datadogコンテナ

#### ・Datadogコンテナとは

Datadogが提供するdatadogイメージによって構築されるコンテナであり，Fargateコンテナのサイドカーコンテナとして配置される．コンテナ内で稼働するDatadogエージェントが，Fargateコンテナからメトリクスを収集し，Datadogにこれを転送する．

#### ・IAMロール

DatadogコンテナがFargateコンテナからメトリクスを収集できるように，ECSタスク実行ロールにポリシーを追加する必要がある．

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

### FireLensコンテナ

#### ・FireLensコンテナとは

DatadogコンテナはFargateコンテナからログを収集できないため，代わりにFireLensコンテナを使用する必要がある．以下のリンクを参考にせよ．

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

### メトリクス



