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

#### ・転送先サービスの設定

ログを何らかの外部サービスに転送する場合，プラグインをインストールする必要がある．なお，Fluentbitは標準でdatadogに転送できるため，datadogのプラグインは不要である．なお，転送先のサービスのベンダーが提供するプラグイン込みのベースイメージを使用して，Fluentbitコンテナをビルドすれば，プラグインのインストールが不要である．

参考：

- Datadog：https://github.com/DataDog/fluent-plugin-datadog
- AWS：https://github.com/aws/aws-for-fluent-bit
- NewRelic：https://github.com/newrelic/newrelic-fluent-bit-output

<br>

### 設定ファイル

#### ・セクション一覧

参考：https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/configuration-file

#### ・SERVICEセクション

```shell
[SERVICE]
    Flush 1
    Grace 30
    Log_Level info
    Streams_File stream_processor.conf # Stream Processorを使用する場合，設定ファイルのパス
```

#### ・INPUTセクション

インプット元として，リンク先の領域から選択できる．

参考：https://docs.fluentbit.io/manual/pipeline/inputs

#### ・STREAM_TASKセクション

ログパイプラインにおいて，Filterプロセス後にログに対してクエリ処理を行い，ログにタグ付けを行う．タグ付けされたログは，Inputプロセスを再度経て，最終的にOutputプロセスへ渡される．

参考：https://docs.fluentbit.io/manual/stream-processing/overview#stream-processor

![fluent-bit_stream-task](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_stream-task.png)

#### ・OUTPUTセクション

アウトプット先として，リンク先のサービスから選択できる．

参考：https://docs.fluentbit.io/manual/pipeline/outputs

| アウトプット先 | 補足                                                         |
| -------------- | ------------------------------------------------------------ |
| Datadog        | 参考：https://docs.fluentbit.io/manual/pipeline/outputs/datadog |
| CloudWatch     | 参考：https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch |

<br>

### FireLensコンテナにおけるFluentbit

#### ・FireLensコンテナとは

ログをルーティングするサイドカーコンテナとして働く．

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/using_firelens.html

コンテナデザインパターンについては，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_virtualization_container_orchestration.html

![fluent-bit_aws-firelens](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_aws-firelens.png)

#### ・ベースイメージ

FireLensコンテナのベースイメージがAWSから提供されている．これには，AWSリソースにログを転送するためのプラグインがすでに含まれている．あらかじめ，バックエンドのCI/CDにベースイメージのビルドとデプロイを組み込んでおく．

参考：https://github.com/aws/aws-for-fluent-bit

```dockerfile
FROM amazon/aws-for-fluent-bit:2.15.1
```

#### ・```fluent-bit_custom.conf```ファイル

すでにベースイメージに設定ファイルが組み込まれているため，追加設定をオーバライドすることになる．設定ファイルは，『```/fluent-bit/etc/fluent-bit_custom.conf```』に置くようにする．

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
    log_group_name    <送信先のロググループ名>
    log_stream_name   <送信先のログストリーム名> # 『$(ecs_task_id)』『$(ecs_cluster)』
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

TerraformでFirelensコンテナを構築するために，コンテナ定義を実装する．メインコンテナからFirelensコンテナにログを送信できるように，ログドライバーのタイプとして『```awsfirelens```』を設定する．また，サイドカーのFirelesコンテナとして，log_routerコンテナを定義する．Firelensコンテナ自体のログは，CloudWatchログに送信するように設定し，メインコンテナから受信したログは監視ツール（Datadogなど）に転送する．コンテナ内の```fluent-bit.conf```ファイルに変数を出力できるように，コンテナの環境変数に値を定義する．

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
        "config-file-value": "<Firelensコンテナが読み込むfluent-bit.confファイルのパス>"
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





