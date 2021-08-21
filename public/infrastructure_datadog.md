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



