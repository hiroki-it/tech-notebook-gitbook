# Fluentd／Fluentbit

## Fluentd／Fluentbitとは

### 概要

アプリケーションまたはインフラストラクチャから，メトリックやログなどのデータを収集し，これをフィルタリングした後，複数の宛先に転送する．

参考：https://docs.fluentbit.io/manual/about/fluentd-and-fluent-bit

<br>

### FluentdとFluentbitの比較

|                  | Fluentd                                      | Fluentbit                                  |
| ---------------- | -------------------------------------------- | ------------------------------------------ |
| スコープ         | コンテナ／サーバ                             | 組み込みLinux／コンテナ／サーバ            |
| 言語             | C & Ruby                                     | NS                                         |
| メモリ最大使用量 | 40MB                                         | 650KB                                      |
| 依存関係         | 標準プラグインで一定数のRuby gemに依存する． | 標準プラグインではライブラリに依存しない． |
| パフォーマンス   | 高                                           | 高                                         |
| プラグイン数     | 1000個以上                                   | 70個                                       |

<br>

## ログの収集／転送の仕組み

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

他サービスにログを転送する．転送先の種類については，以下を参考にせよ．

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

## Fargateコンテナからのログ収集

### FireLensコンテナ

#### ・FireLensコンテナとは

AWSが提供するFluentbit／Fluentdイメージによって構築されるサイドカーコンテナであり，Fargateコンテナのログを収集し，これを他のサービスに転送する．構築のための実装例については，以下のリンクを参考にせよ．

参考：

- https://github.com/aws-samples/amazon-ecs-firelens-examples
- https://aws.amazon.com/jp/blogs/news/announcing-firelens-a-new-way-to-manage-container-logs/

#### ・ログの転送先

Fluentbit／Fluentdが対応する他のサービスにログを転送できる．

参考：https://docs.fluentbit.io/manual/pipeline/outputs

<br>

### サイドカーコンテナパターン

#### ・サイドカーコンテナパターンとは

サイドカーコンテナパターンを含むコンテナデザインパターンについては，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_virtualization_container_orchestration.html

#### ・ログの収集／転送の仕組み

以下の順番でログの収集／転送を実行する．

参考：https://aws.amazon.com/jp/blogs/news/under-the-hood-firelens-for-amazon-ecs-tasks/

1. メインのコンテナは，Fluentdログドライバーを介して，ログをFireLensコンテナに送信する．Fluentdログドライバーについては，以下を参考にせよ．

   参考：https://docs.docker.com/config/containers/logging/fluentd/

2. FireLensコンテナは，これを受信する．

3. コンテナ内で稼働するFluentbitのログパイプラインのINPUTに渡され，Fluentbitはログを処理する．

4. OUTPUTプロセスに渡され，Fulentbitは指定した外部サービスにログを転送する．

![fluent-bit_aws-firelens](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_aws-firelens.png)

#### ・ログ転送プロセス

FireLensコンテナでは，FluentbitまたはFlunetdがログ転送プロセスとして稼働する．FireLensコンテナを使用せずに，独自のコンテナを構築して稼働させることも可能であるが，FireLensコンテナを使用すれば，主要なセットアップがされているため，より簡単な設定でFluentbitまたはFlunetdを使用できる．Fluentbitの方がより低負荷で稼働するため，Fluentbitが推奨されている．

参考：

- https://aws.amazon.com/jp/blogs/news/under-the-hood-firelens-for-amazon-ecs-tasks/
- https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/using_firelens.html

<br>

### ベースイメージ

#### ・fluentbitイメージ

FireLensコンテナのベースイメージとなるfluentbitイメージがAWSから提供されている．これには，AWSリソースにログを転送するためのプラグインがすでに含まれている．パブリックECRリポジトリからプルしたイメージをそのまま使用する場合と，プライベートECRリポジトリで再管理してから使用する場合がある．

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/firelens-using-fluentbit.html

#### ・パブリックECRリポジトリを使用する場合

ECSのコンテナ定義にて，パブリックECRリポジトリのURLを指定し，ECRイメージのプルを実行する．標準で内蔵されているconfファイルの設定をそのまま使用する場合は，こちらを採用する．

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/firelens-using-fluentbit.html#firelens-image-ecr

#### ・プライベートECRリポジトリを使用する場合

あらかじめ，DockerHubからfluentbitイメージをプルするためのDockerfileを作成し，プライベートECRリポジトリにイメージをプッシュしておく．ECSのコンテナ定義にて，プライベートECRリポジトリのURLを指定し，ECRイメージのプルを実行する．標準で内蔵されているconfファイルの設定を上書きしたい場合は，こちらを採用する．

```dockerfile
FROM amazon/aws-for-fluent-bit:latest
```

参考：

- https://hub.docker.com/r/amazon/aws-for-fluent-bit
- https://github.com/aws/aws-for-fluent-bit
- https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/firelens-using-fluentbit.html#firelens-image-dockerhub

<br>

### 標準設定の上書き

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

<br>

### Fire Lensコンテナの構築

#### ・コンテナ定義

Firelensコンテナをサイドカーとして構築するために，コンテナ定義を実装する．Firelensコンテナは『log_routeter』とし，メインコンテナからFireLensコンテナにログを送信できるように，ログドライバーのタイプとして『```awsfirelens```』を設定する．この時，『```options```』と```fluent-bit.conf```ファイルのどちらにもほとんど同じ設定が可能であるが，出来るだけ```fluent-bit.conf```ファイルに寄せるようにする．FireLensコンテナ自体のログは，CloudWatchログに送信するように設定し，メインコンテナから受信したログは監視ツール（Datadogなど）に転送する．コンテナ内の```fluent-bit.conf```ファイルに変数を出力できるように，コンテナの環境変数に値を定義する．

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
    "name": "log_router（FireLensコンテナ名がlog_routerとなることは固定）",
    "image": "<ECRリポジトリのURL>",
    "essential": false,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "<ロググループ名（FireLensコンテナ自体がCloudWatchログにログ出力）>",
        "awslogs-region": "<リージョン>",
        "awslogs-stream-prefix": "<プレフィクス>"
      }
    },
    "firelensConfiguration": {
      "type": "fluentbit（FireLensコンテナでFluentbitを稼働させる）",
      "options": {
        "config-file-type": "file",
        "config-file-value": "/fluent-bit/etc/fluent-bit_custom.conf（設定上書きのため読み込み）"
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

<br>

## CloudWatchログ

以下のノートを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws.html

