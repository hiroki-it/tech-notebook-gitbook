# ログ収集ツール

## CloudWatchログ

### CloudWatchログとは

以下のノートを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws.html

<br>

## Fluentbit

### Fluentbitとは

アプリケーションまたはインフラストラクチャから，メトリックやログなどのデータを収集し，これをフィルタリングした後，複数の宛先に転送する．

<br>

### ログパイプライン

#### ・ログパイプラインとは

![fluent-bit-log-pipeline](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_log-pipeline.png)

<br>

### 設定ファイル

#### ・セクション一覧

参考：https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/configuration-file

#### ・Serviceセクション

```shell
[SERVICE]
    Flush 1
    Grace 30
    Log_Level info
    Streams_File stream_processor.conf # Stream Processorを使用する場合，設定ファイルのパス
```

#### ・Inputセクション

インプット元として，リンク先の領域から選択できる．

参考：https://docs.fluentbit.io/manual/pipeline/inputs

#### ・Outputセクション

アウトプット先として，リンク先のサービスから選択できる．

参考：https://docs.fluentbit.io/manual/pipeline/outputs

| アウトプット先 | 補足                                                         |
| -------------- | ------------------------------------------------------------ |
| Datadog        | 参考：https://docs.fluentbit.io/manual/pipeline/outputs/datadog |
| CloudWatch     | 参考：https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch |

<br>

### FireLensコンテナ上での稼働

#### ・FireLensコンテナとは

![fluent-bit_aws-firelens](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_aws-firelens.png)

#### ・エージェント

FireLensコンテナでfluentbitのエージェントを稼働させるために，AWSからイメージが提供されている．

参考：https://github.com/aws/aws-for-fluent-bit

#### ・設定ファイル

すでにベースイメージに設定ファイルが組み込まれているため，追加設定をオーバライドすることになる．

参考：https://github.com/aws/aws-for-fluent-bit/blob/mainline/fluent-bit.conf

```shell
[OUTPUT]
    Name              datadog # データの送信先名
    Match             *
    Host              http-intake.logs.datadoghq.com
    TLS               on
    compress          gzip
    apikey            <DatadogのAPIキー>
    dd_service        <Datadogのログエクスプローラーにおけるservice名>
    dd_source         <Datadogのログエクスプローラーにおけるsource名>
    dd_message_key    log
    dd_tags           <タグ名>

[OUTPUT]
    Name              cloudwatch # データの送信先名
    Match             *
    log_key           log
    region            ap-northeast-1
    log_group_name    <送信先のロググループ名>
    log_stream_name   <送信先のログストリーム名>
```





