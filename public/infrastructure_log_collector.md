# ログ収集＆ルーティング

## CloudWatchログ

### CloudWatchログとは

以下のノートを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws.html

<br>

## Fluentbit

### Fluentbitとは

アプリケーションまたはインフラストラクチャから，メトリックやログなどのデータを収集し，これをフィルタリングした後，複数の宛先にルーティングする．

<br>

### ログパイプライン

#### ・ログパイプラインとは

![fluent-bit-log-pipeline](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_log-pipeline.png)

#### ・設定ファイルのセクション一覧

参考：https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/configuration-file

#### ・SERVICEセクション

```shell
[SERVICE]
    Flush 1
    Grace 30
    Log_Level info
    Streams_File stream_processor.conf # Stream Processorを使用する場合，設定ファイルのパス
```

<br>

### INPUT

#### ・INPUTセクションとは

指定したリソースからデータを収集する．

参考：

- https://docs.fluentbit.io/manual/pipeline/inputs
- https://docs.fluentbit.io/manual/concepts/data-pipeline/input

<br>

### OUTPUT

#### ・OUTPUTセクションとは

アウトプット先として，リンク先のサービスから選択できる．

参考：https://docs.fluentbit.io/manual/pipeline/outputs

| 転送先サービス | オプションのリンク                                           |
| -------------- | ------------------------------------------------------------ |
| Datadog        | 参考：https://docs.fluentbit.io/manual/pipeline/outputs/datadog |
| CloudWatch     | 参考：https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch |

#### ・プラグイン

ログを何らかの外部サービスに転送する場合，プラグインをインストールする必要がある．なお，Fluentbitは標準でdatadogに転送できるため，datadogのプラグインは不要である．なお，転送先のサービスのベンダーが提供するプラグイン込みのベースイメージを使用して，Fluentbitコンテナをビルドすれば，プラグインのインストールが不要である．

| 転送先サービス | ベースイメージのリンク                                       |
| -------------- | ------------------------------------------------------------ |
| Datadog        | https://github.com/DataDog/fluent-plugin-datadog             |
| AWS            | ・https://github.com/aws/aws-for-fluent-bit<br>・https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit<br>・https://github.com/aws/amazon-kinesis-streams-for-fluent-bit |
| NewRelic       | https://github.com/newrelic/newrelic-fluent-bit-output       |

<br>

### STORAGE

#### ・STREAM_TASKセクションとは

ログパイプラインにおいて，Filterプロセス後にログに対してクエリ処理を行い，ログにタグ付けを行う．タグ付けされたログは，Inputプロセスに再度取り込まれ，最終的にOutputプロセスまで渡される．

参考：https://docs.fluentbit.io/manual/stream-processing/overview#stream-processor

![fluent-bit_stream-task](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_stream-task.png)

<br>

## FireLens

### Firelensコンテナ

#### ・FireLensコンテナとは

メインコンテナからログを収集し，これをルーティングするコンテナとして機能する．サイドカーコンテナパターンで構築する．構築のための実装例については，以下のリンクを参考にせよ．

参考：https://github.com/aws-samples/amazon-ecs-firelens-examples

以下の順番でログの収集＆ルーティングを実行する．

参考：https://aws.amazon.com/jp/blogs/news/under-the-hood-firelens-for-amazon-ecs-tasks/

1. メインのコンテナは，Fluentdログドライバーを介して，ログをFirelensコンテナに送信する．Fluentdログドライバーについては，以下を参考にせよ．

   参考：https://docs.docker.com/config/containers/logging/fluentd/

2. Firelensコンテナは，これを受信する．

3. コンテナ内で稼働するFluentbitのログパイプラインのINPUTに渡され，Fluentbitはログを処理する．

4. OUTPUTプロセスに渡され，Fulentbitは指定した外部サービスにログを転送する．

![fluent-bit_aws-firelens](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_aws-firelens.png)

#### ・サイドカーコンテナパターン

サイドカーコンテナパターンを含むコンテナデザインパターンについては，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_virtualization_container_orchestration.html

#### ・ログルーティングプロセス

Firelensコンテナでは，FluentbitまたはFlunetdがログルーティングプロセスとして稼働する．Firelensコンテナを使用せずに，独自のコンテナを構築して稼働させることも可能であるが，Firelensコンテナを使用すれば，主要なセットアップがされているため，より簡単な設定でFluentbitまたはFlunetdを使用できる．Fluentbitの方がより低負荷で稼働するため，Fluentbitが推奨されている．

参考：

- https://aws.amazon.com/jp/blogs/news/under-the-hood-firelens-for-amazon-ecs-tasks/
- https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/using_firelens.html

<br>

### Fluentbitプロセス

#### ・ベースイメージ

FireLensコンテナのベースイメージがAWSから提供されている．これには，AWSリソースにログを転送するためのプラグインがすでに含まれている．あらかじめ，バックエンドのCI/CDにベースイメージのビルドとデプロイを組み込んでおく．

参考：https://github.com/aws/aws-for-fluent-bit

```dockerfile
FROM amazon/aws-for-fluent-bit:2.15.1
```

#### ・```fluent-bit_custom.conf```ファイル

すでにベースイメージに設定ファイル（```/fluent-bit/etc/fluent-bit.conf```）が組み込まれているため，追加設定をオーバライドすることになる．設定ファイルは，『```/fluent-bit/etc/fluent-bit_custom.conf```』に置くようにする．CloudWatchログがプラグインの場合に，設定ファイルに予約された変数を使用できる．以下のリンクを参考にせよ．

参考：https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit#templating-log-group-and-stream-names

```shell
[OUTPUT]
    Name              datadog # データの送信先名
    Match             *
    Host              http-intake.logs.datadoghq.com
    TLS               on
    compress          gzip
    apikey            <DatadogのAPIキー> # コンテナの環境変数から参照し，割り当てる．
    dd_service        <Datadogのログエクスプローラーにおけるservice名>
    dd_source         <Datadogのログエクスプローラーにおけるsource名>
    dd_message_key    log
    dd_tags           <タグ名> # （例）env:${DD_ENV}

[OUTPUT]
    Name              cloudwatch # データの送信先名
    Match             *
    log_key           log
    region            ap-northeast-1
    log_group_name    <ロググループ名> # 予約変数あり．
    log_stream_name   <ログストリーム名> # 予約変数あり．$(ecs_task_id) を使用して，タスクID別にログストリームを作成できる．
```

ちなみに，標準で組み込まれている設定ファイルには，INPUTセクションがすでに定義されているため，```fluent-bit_custom.conf```ファイルではINPUTセクションを定義する必要が無い．

参考：https://github.com/aws/aws-for-fluent-bit/blob/mainline/fluent-bit.conf

```shell
[INPUT]
    Name        forward # Forwardタイプ
    Listen      0.0.0.0
    Port        24224

[OUTPUT]
    Name cloudwatch
    Match   **
    region us-east-1
    log_group_name fluent-bit-cloudwatch
    log_stream_prefix from-fluent-bit-
    auto_create_group true
```

#### ・```stream_processor.conf```ファイル

Firelensコンテナのパイプラインでは，『<コンテナ名>-firelens-<タスクID>』という名前でログが処理されている．そのため，Stream Processorでログを抽出するためには，クエリで『```FROM TAG:'*-firelens-*'```』を指定する必要がある．

参考：https://aws.amazon.com/jp/blogs/news/under-the-hood-firelens-for-amazon-ecs-tasks/

```shell
# Laravelコンテナのログへのタグ付け
[STREAM_TASK]
    Name web
    Exec CREATE STREAM web WITH (tag='laravel') AS SELECT log FROM TAG:'*-firelens-*' WHERE container_name = 'laravel';

# Nginxコンテナのログへのタグ付け
[STREAM_TASK]
    Name web
    Exec CREATE STREAM web WITH (tag='nginx') AS SELECT log FROM TAG:'*-firelens-*' WHERE container_name = 'nginx';

# 全てのコンテナのログへのタグ付け
[STREAM_TASK]
    Name containers
    Exec CREATE STREAM container WITH (tag='containers') AS SELECT * FROM TAG:'*-firelens-*';
```

#### ・Terraformのコンテナ定義

TerraformでFirelensコンテナを構築するために，コンテナ定義を実装する．Firelensコンテナは『log_routeter』とし，メインコンテナからFirelensコンテナにログを送信できるように，ログドライバーのタイプとして『```awsfirelens```』を設定する．この時，『```options```』と```fluent-bit.conf```ファイルのどちらにもほとんど同じ設定が可能であるが，出来るだけ```fluent-bit.conf```ファイルに寄せるようにする．Firelensコンテナ自体のログは，CloudWatchログに送信するように設定し，メインコンテナから受信したログは監視ツール（Datadogなど）に転送する．コンテナ内の```fluent-bit.conf```ファイルに変数を出力できるように，コンテナの環境変数に値を定義する．

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/firelens-example-taskdefs.html#firelens-example-forward

```json
[
  {
    "name": "<メインコンテナ名>",
    "image": "<ECRリポジトリのURL>",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awsfirelens",
      "options": {
        "Name": "forward"
      }
    }
  },
  {
    "name": "log_router（Firekensコンテナ名のlog_routerは固定）",
    "image": "<ECRリポジトリのURL>",
    "essential": false,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "<ロググループ名>",
        "awslogs-region": "<リージョン>",
        "awslogs-stream-prefix": "<プレフィクス>"
      }
    },
    "firelensConfiguration": {
      "type": "fluentbit",
      "options": {
        "config-file-type": "file",
        "config-file-value": "/fluent-bit/etc/fluent-bit_custom.conf"
      }
    },
    "portMappings": [],
    "memoryReservation": 50,
    "secrets": [
      {
        "name": "DD_API_KEY",
        "valueFrom": "<SSMパラメータで管理する環境変数名>"
      },
      {
        "name": "DD_ENV",
        "valueFrom": "<SSMパラメータで管理する環境変数名>"
      }
    ]
  }
]

```





