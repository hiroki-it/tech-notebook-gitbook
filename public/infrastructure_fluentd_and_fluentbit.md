# Fluentd／FluentBit

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Fluentd／FluentBitとは

### 概要

アプリケーションからログを収集し，これをフィルタリングした後，複数の宛先に転送する．

参考：https://docs.fluentbit.io/manual/about/fluentd-and-fluent-bit

<br>

### Fluentd vs. FluentBit

|                  | Fluentd                                      | FluentBit                                  |
| ---------------- | -------------------------------------------- | ------------------------------------------ |
| スコープ         | コンテナ／サーバ                             | 組み込みLinux／コンテナ／サーバ            |
| 言語             | C & Ruby                                     | NS                                         |
| メモリ最大使用量 | 40MB                                         | 650KB                                      |
| 依存関係         | 標準プラグインで一定数のRuby gemに依存する． | 標準プラグインではライブラリに依存しない． |
| パフォーマンス   | 高                                           | 高                                         |
| プラグイン数     | 1000個以上                                   | 70個                                       |

<br>

## 02. ログの収集／転送の仕組み

### ログパイプライン

#### ・ログパイプラインとは

![fluent-bit-log-pipeline](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_log-pipeline.png)

#### ・設定ファイルのセクション一覧

参考：https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/configuration-file

#### ・設定ファイルのバリデーション

参考：https://cloud.calyptia.com/visualizer

<br>

### SERVICE

#### ・SERVICEセクションとは

パイプライン全体の設定やファイルの読み込みを定義する．各設定の頭文字は大文字とする．

```shell
[SERVICE]
    Flush 1
    # 猶予時間
    Grace 30
    # 転送対象の最低ログレベル
    Log_Level info
    # 読み込まれるParsers Multilineファイルの名前
    Parsers_File parsers_multiline.conf
    # 読み込まれるStream Processorファイルの名前
    Streams_File stream_processor.conf
```

<br>

### INPUT

#### ・INPUTセクションとは

ログの入力方法を定義する．

参考：

- https://docs.fluentbit.io/manual/pipeline/inputs
- https://docs.fluentbit.io/manual/concepts/data-pipeline/input

<br>

### PARSE

#### ・PARSEセクションとは



#### ・MULTILINE_PARSERセクション

参考：https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/multiline-parsing

```shell
[MULTILINE_PARSER]
    name          laravel
    # 解析タイプ
    type          regex
    flush_timeout 1000
    # 解析ルール．スタックトレースの文頭をstart_state，また以降に結合する文字列をcontで指定する．
    rule          "start_state" "\[%Y-%m-%d %H:%M:%S\]" "cont"
    rule          "cont"        "#*"                    "cont"
```

<br>

### FILTER

#### ・FILTERセクションとは

特定の文字列を持つログのみをBUFFERセクションに転送する．

```shell
[FILTER]
    Name  stdout
    Match *
```

<br>

### OUTPUT

#### ・OUTPUTセクションとは

ログの出力方法を定義する．設定可能な転送先の種類については，以下を参考にせよ．

参考：https://docs.fluentbit.io/manual/pipeline/outputs

| 転送先サービス | オプションのリンク                                           |
| -------------- | ------------------------------------------------------------ |
| Datadog        | 参考：https://docs.fluentbit.io/manual/pipeline/outputs/datadog |
| CloudWatch     | 参考：https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch |

#### ・プラグイン

ログを何らかの外部サービスに転送する場合，プラグインをインストールする必要がある．なお，FluentBitは標準でdatadogに転送できるため，datadogのプラグインは不要である．なお，転送先のサービスのベンダーが提供するプラグイン込みのベースイメージを使用して，FluentBitコンテナをビルドすれば，プラグインのインストールが不要である．

| 転送先サービス | ベースイメージのリンク                                       |
| -------------- | ------------------------------------------------------------ |
| Datadog        | https://github.com/DataDog/fluent-plugin-datadog             |
| AWS            | ・https://github.com/aws/aws-for-fluent-bit<br>・https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit<br>・https://github.com/aws/amazon-kinesis-streams-for-fluent-bit |
| NewRelic       | https://github.com/newrelic/newrelic-fluent-bit-output       |

<br>

### STORAGE

#### ・STREAM_TASKセクションとは

ログパイプラインにおいて，FILTERセクション後にログに対してクエリ処理を行い，ログにタグ付けを行う．タグ付けされたログは，INPUTセクションに再度取り込まれ，最終的にOUTPUTセクションまで渡される．

参考：https://docs.fluentbit.io/manual/stream-processing/overview#stream-processor

![fluent-bit_stream-task](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_stream-task.png)

<br>

## 03. Fargateコンテナからのログ収集

### FireLensコンテナ

#### ・FireLensコンテナとは

AWSが提供するFluentBit／Fluentdイメージによって構築されるコンテナであり，Fargateコンテナのサイドカーコンテナとして配置される．Fargateコンテナからログが送信されると，コンテナ内で稼働するFluentBit／Fluentdがこれを収集し，これを他のサービスに転送する．構築のための実装例については，以下のリンクを参考にせよ．

参考：

- https://github.com/aws-samples/amazon-ecs-firelens-examples
- https://aws.amazon.com/jp/blogs/news/announcing-firelens-a-new-way-to-manage-container-logs/

#### ・ログの転送先

FluentBit／Fluentdが対応する他のサービスにログを転送できる．

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

3. コンテナ内で稼働するFluentBitのログパイプラインのINPUTに渡され，FluentBitはログを処理する．

4. OUTPUTセクションに渡され，FluentBitは指定した外部サービスにログを転送する．

![fluent-bit_aws-firelens](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_aws-firelens.png)

#### ・ログ転送プロセス

FireLensコンテナでは，FluentBitまたはFlunetdがログ転送プロセスとして稼働する．FireLensコンテナを使用せずに，独自のコンテナを構築して稼働させることも可能であるが，FireLensコンテナを使用すれば，主要なセットアップがされているため，より簡単な設定でFluentBitまたはFlunetdを使用できる．FluentBitの方がより低負荷で稼働するため，FluentBitが推奨されている．

参考：

- https://aws.amazon.com/jp/blogs/news/under-the-hood-firelens-for-amazon-ecs-tasks/
- https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/using_firelens.html

<br>

### ベースイメージ

#### ・FluentBitイメージ

FireLensコンテナのベースイメージとなるFluentBitイメージがAWSから提供されている．これには，AWSリソースにログを転送するためのプラグインがすでに含まれている．パブリックECRリポジトリからプルしたイメージをそのまま使用する場合と，プライベートECRリポジトリで再管理してから使用する場合がある．

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/firelens-using-fluentbit.html

#### ・パブリックECRリポジトリを使用する場合

ECSのコンテナ定義にて，パブリックECRリポジトリのURLを指定し，ECRイメージのプルを実行する．標準で内蔵されているconfファイルの設定をそのまま使用する場合は，こちらを採用する．

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/firelens-using-fluentbit.html#firelens-image-ecr

#### ・プライベートECRリポジトリを使用する場合

あらかじめ，DockerHubからFluentBitイメージをプルするためのDockerfileを作成し，プライベートECRリポジトリにイメージをプッシュしておく．ECSのコンテナ定義にて，プライベートECRリポジトリのURLを指定し，ECRイメージのプルを実行する．標準で内蔵されているconfファイルの設定を上書きしたい場合は，こちらを採用する．

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
#########################
# Datadogへの転送
#########################
[OUTPUT]
    # 転送先名
    Name              datadog
    # 転送対象とするログのタグ
    Match             laravel
    # 転送先ホスト
    Host              http-intake.logs.datadoghq.com
    TLS               on
    compress          gzip
    # DatadogのAPIキー．コンテナの環境変数から参照し，割り当てる．
    apikey            <DatadogのAPIキー>
    # serviceタグ
    dd_service        <DatadogのログエクスプローラーにおけるService名>
    # sourceタグ
    dd_source         <DatadogのログエクスプローラーにおけるSource名>
    dd_message_key    log
    # 追加タグ（例）env:${DD_ENV}
    dd_tags           <タグ名>
    
#########################
# CloudWatchログへの転送
#########################
[OUTPUT]
    # 転送先名
    Name              cloudwatch
    # 転送対象とするログのタグ
    Match             laravel
    log_key           log
    region            ap-northeast-1
    # 予約変数あり．
    log_group_name    <ロググループ名>
    # ログストリーム名．予約変数あり．タスクIDなど出力できる．
    log_stream_name   container/laravel/$(ecs_task_id)
    
[OUTPUT]
    Name              cloudwatch
    Match             nginx
    log_key           log
    region            ap-northeast-1
    log_group_name    <ロググループ名>
    log_stream_name   container/nginx/$(ecs_task_id)
```

ちなみに，標準で組み込まれている設定ファイルには，INPUTセクションがすでに定義されているため，```fluent-bit_custom.conf```ファイルではINPUTセクションを定義する必要が無い．

参考：https://github.com/aws/aws-for-fluent-bit/blob/mainline/fluent-bit.conf

```shell
[INPUT]
    # Inputタイプ
    Name        forward
    Listen      0.0.0.0
    # プロセスのリッスンポート
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

FireLensコンテナのパイプラインでは，『<コンテナ名>-firelens-<タスクID>』という名前でログが処理されている．そのため，Stream Processorでログを抽出するためには，クエリで『```FROM TAG:'*-firelens-*'```』を指定する必要がある．これらのログにタグを付け，INPUTセクションからログを処理し直す．

参考：https://aws.amazon.com/jp/blogs/news/under-the-hood-firelens-for-amazon-ecs-tasks/

```shell
# appコンテナのログへのタグ付け
[STREAM_TASK]
    Name laravel
    Exec CREATE STREAM web WITH (tag='laravel') AS SELECT log FROM TAG:'*-firelens-*' WHERE container_name = 'laravel';

# webコンテナのログへのタグ付け
[STREAM_TASK]
    Name nginx
    Exec CREATE STREAM web WITH (tag='nginx') AS SELECT log FROM TAG:'*-firelens-*' WHERE container_name = 'nginx';

# 全てのコンテナのログへのタグ付け
[STREAM_TASK]
    Name containers
    Exec CREATE STREAM container WITH (tag='containers') AS SELECT * FROM TAG:'*-firelens-*';
```

<br>

### FireLensコンテナの構築

#### ・コンテナ定義

```shell
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
    # FireLensコンテナ名がlog_routerとなることは固定
    "name": "log_router",
    "image": "<ECRリポジトリのURL>",
    "essential": false,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        # FireLensコンテナ自体がCloudWatchログにログ出力
        "awslogs-group": "<ロググループ名>",
        "awslogs-region": "<リージョン>",
        "awslogs-stream-prefix": "<プレフィクス>"
      }
    },
    "firelensConfiguration": {
      # FireLensコンテナでFluentBitを稼働させる
      "type": "fluentbit",
      "options": {
        "config-file-type": "file",
        # 設定上書きのため読み込み
        "config-file-value": "/fluent-bit/etc/fluent-bit_custom.conf"
        # ECSの情報をFireLensに送信するかどうか
        "enable-ecs-log-metadata": "true"
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

#### ・name

FireLensコンテナをサイドカーとして構築するために，コンテナ定義を実装する．FireLensコンテナは『log_routeter』とする．

#### ・logConfiguration

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/firelens-example-taskdefs.html#firelens-example-forward

| 項目                                          | 説明                                                         |
| --------------------------------------------- | ------------------------------------------------------------ |
| ```type```                                    | メインコンテナからFireLensコンテナにログを送信できるように，ログドライバーのタイプとして『```fluentbit```』を設定する． |
| ```config-file-type```                        | FluentBitの設定ファイルを読み込むために，```file```とする．  |
| ```config-file-value```                       | ```options```キーにて，ログ転送時の設定が可能であるが，それらは```fluent-bit.conf```ファイルにも設定可能であるため，転送の設定はできるだけ```fluent-bit.conf```ファイルに実装する．FireLensコンテナ自体のログは，CloudWatchログに送信するように設定し，メインコンテナから受信したログは監視ツール（Datadogなど）に転送する． |
| ```enable-ecs-log-metadata```（標準で有効化） | 有効にした場合，Datadogのログコンソールで，例えば以下のようなタグが付けられる．<br>![ecs-meta-data_true](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ecs-meta-data_true.png)<br>反対に無効にした場合，以下のようなタグが付けられる．<br>![ecs-meta-data_false](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ecs-meta-data_false.png)<br>参考：https://tech.spacely.co.jp/entry/2020/11/28/173356 |
| ```environment```，```secrets```              | コンテナ内の```fluent-bit.conf```ファイルに変数を出力できるように，コンテナの環境変数に値を定義する． |

<br>

## 04. CloudWatchログ

以下のノートを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws.html

