# Fluentd／FluentBit

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

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

```bash
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

ログのパイプラインへの入力方法を定義する．

参考：https://docs.fluentbit.io/manual/concepts/data-pipeline/input

プラグインを用いて，ログの入力方法を指定する．

参考：https://docs.fluentbit.io/manual/pipeline/inputs

#### ・forwardプラグイン

転送されたログを指定されたポートでリッスンし，パイプラインに入力する．

参考：https://docs.fluentbit.io/manual/pipeline/inputs/forward

```bash
[INPUT]
    # プラグイン名
    Name        forward
    Listen      0.0.0.0
    # プロセスのリッスンポート
    Port        24224
```

#### ・tailプラグイン

複数行のログを結合し，パイプラインに入力する．```v1.8```を境にオプションが変わっていることに注意する．

参考：https://docs.fluentbit.io/manual/pipeline/inputs/tail

```bash
[INPUT]
    # プラグイン名
    Name              tail
    # ログの場所．ワイルドカードを使用できる．
    Path              /var/log/*.log
    # 使用するパーサー名
    multiline.parser  laravel
```

<br>

### PARSE

#### ・PARSEセクションとは

#### ・MULTILINE_PARSERセクション

参考：https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/multiline-parsing

```bash
[MULTILINE_PARSER]
    # パーサー名
    name          laravel
    # パーサータイプ
    type          regex
    flush_timeout 1000
    # パーサールール．スタックトレースの文頭をstart_state，また以降に結合する文字列をcontで指定する．
    rule          "start_state" "\[%Y-%m-%d %H:%M:%S\]" "cont"
    rule          "cont"        "#*"                    "cont"
```

<br>

### FILTER

#### ・FILTERセクションとは

特定の文字列を持つログのみをBUFFERセクションに転送する．

#### ・multilineプラグイン

参考：https://docs.fluentbit.io/manual/pipeline/filters/multiline-stacktrace

```shell
[FILTER]
    # プラグイン名
    name                  multiline
    match                 *
    multiline.key_content log
    # 使用するパーサー名
    multiline.parser      laravel
```

#### ・stdoutプラグイン

参考：https://docs.fluentbit.io/manual/pipeline/filters/standard-output

```bash
[FILTER]
    # プラグイン名
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

| 転送先サービス | ベースイメージのリンク                                       | 補足                                                         |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| NewRelic       | https://github.com/newrelic/newrelic-fluent-bit-output       | NewRelicプラグインがインストールされている．                 |
| AWS            | https://github.com/aws/aws-for-fluent-bit                    | AWSから提供される他の全てのFluentBitイメージを束ねたものであり，AWSの各種リソースに転送するためのプラグインがインストールされている． |
|                | https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit | CloudWatchログプラグインがインストールされている．           |
|                | https://github.com/aws/amazon-kinesis-streams-for-fluent-bit | Kinesis Streamsプラグインがインストールされている．          |
|                | https://github.com/aws/amazon-kinesis-firehose-for-fluent-bit | Kinesis Firehoseプラグインがインストールされている．         |

ログを何らかの外部サービスに転送する場合，プラグインをインストールする必要がある．なお，FluentBitは標準でdatadogプラグインがインストールされているため，datadogプラグインのインストールは不要である．Datadogプラグインについては以下のリンクを参考にせよ．

参考：https://github.com/DataDog/fluent-plugin-datadog

#### ・datadogプラグイン

```bash
#########################
# Datadogへの転送
#########################
[OUTPUT]
    # プラグイン名
    Name              datadog
    # 転送対象とするログのタグ
    Match             laravel
    # 転送先ホスト
    Host              http-intake.logs.datadoghq.com
    TLS               on
    compress          gzip
    # DatadogのAPIキー．
    apikey            *****
    # DatadogログエクスプローラーにおけるService名
    dd_service        prd-foo
    # DatadogログエクスプローラーにおけるSource名
    dd_source         prd-foo
    dd_message_key    log
    # 追加タグ
    dd_tags           env:prd-foo
    
[OUTPUT]
    Name              datadog
    Match             nginx
    Host              http-intake.logs.datadoghq.com
    TLS               on
    compress          gzip
    apikey            *****
    dd_service        prd-foo
    dd_source         prd-foo
    dd_message_key    log
    dd_tags           env:prd-foo
```

代わりに，同じ設定をFireLensの```logConfiguration```キーとしても適用することもできる．

参考：https://github.com/aws-samples/amazon-ecs-firelens-examples/blob/mainline/examples/fluent-bit/datadog/README.md

```bash
"logConfiguration": {
	"logDriver":"awsfirelens",
	"options": {
	   "Name": "datadog",
	   "Host": "http-intake.logs.datadoghq.com",
	   "TLS": "on",
	   "apikey": "<DATADOG_API_KEY>",
	   "dd_service": "prd-foo",
	   "dd_source": "prd-foo",
	   "dd_tags": "env:prd-foo",
	   "provider": "ecs"
   }
},
```

#### ・cloudwatch_logsプラグイン

設定ファイルに予約されたAWS変数を使用できる．以下のリンクを参考にせよ．

参考：https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit#templating-log-group-and-stream-names

```bash
#########################
# CloudWatchログへの転送
#########################
[OUTPUT]
    # プラグイン名
    Name              cloudwatch_logs
    # 転送対象とするログのタグ
    Match             laravel
    # アウトプットJSONのうち，宛先に転送するキー名
    log_key           log
    region            ap-northeast-1
    # 予約変数あり．
    log_group_name    /prd-foo-ecs-container/laravel/log
    # ログストリーム名．予約変数あり．タスクIDなど出力できる．
    log_stream_name   container/laravel/$(ecs_task_id)
    
[OUTPUT]
    Name              cloudwatch_logs
    Match             nginx
    log_key           log
    region            ap-northeast-1
    log_group_name    /prd-foo-ecs-container/nginx/log
    log_stream_name   container/nginx/$(ecs_task_id)
```

CloudWatchログに送信されるデータはJSONになっている．```log```キーに全てのログのテキストが割り当てられている．特定のキーの値のみをCloudWatchログに送信する場合，log_keyオプションでキー名を指定する．例えば，```log```キーのみを送信する場合，『```log```』と指定する．

参考：https://blog.msysh.me/posts/2020/07/split_logs_into_multiple_target_with_firelens_and_rewrite_tag.html

```bash
{
    "container_id": "*****",
    "container_name": "prd-foo-ecs-container",
    "ecs_cluster": "prd-foo-ecs-cluster",
    "ecs_task_arn": "arn:aws:ecs:ap-northeast-1:****:task/cluster-name/*****",
    "ecs_task_definition": "prd-foo-ecs-task-definition:1",
    "log": "<ログのテキスト>",
    "source": "stdout",
    "ver": "1.5"
}
```

<br>

### BUFFERセクションとは

#### ・BUFFERセクションとは

参考：https://docs.fluentbit.io/manual/administration/buffering-and-storage

#### ・STREAM_TASKセクションとは

![fluent-bit_stream-task](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/fluent-bit_stream-task.png)

ログパイプラインにおいて，FILTERセクション後にログに対してクエリ処理を行い，ログにタグ付けを行う．タグ付けされたログは，INPUTセクションに再度取り込まれ，最終的にOUTPUTセクションまで渡される．

参考：https://docs.fluentbit.io/manual/stream-processing/overview#stream-processor

STREAM_TASKセッションは，ログSQLで定義される．

参考：https://docs.fluentbit.io/manual/stream-processing/getting-started/fluent-bit-sql

```bash
[STREAM_TASK]
    Name foo
    Exec CREATE STREAM foo AS SELECT * FROM TAG:'foo';
```

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

FireLensコンテナのベースイメージとなるFluentBitイメージがAWSから提供されている．AWSリソースにログを転送するためのプラグインがすでに含まれている．なお，DatadogプラグインはFluentBit自体にインストール済みである．パブリックECRリポジトリからプルしたイメージをそのまま使用する場合と，プライベートECRリポジトリで再管理してから使用する場合がある．

参考：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/firelens-using-fluentbit.html

```bash
[/fluent-bit]$ ls -la

-rw-r--r-- 1 root root 26624256 Sep  1 18:04 cloudwatch.so # 旧cloudwatch_logsプラグイン
-rw-r--r-- 1 root root 26032656 Sep  1 18:04 firehose.so   # kinesis_firehoseプラグイン 
-rw-r--r-- 1 root root 30016544 Sep  1 18:03 kinesis.so    # kinesis_streamsプラグイン 
...
```

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

#### ・標準設定ファイルの種類

aws-for-fluent-bitイメージの```/fluent-bit/etc```ディレクトリには標準で設定ファイルが用意されている．追加設定を実行するファイルはここに配置する．

```bash
[/fluent-bit/etc]$ ls -la

-rw-r--r-- 1 root root  251 Sep  1 17:57 fluent-bit.conf
-rw-r--r-- 1 root root 1564 Sep 27 02:15 fluent-bit_custom.conf # 追加設定用
-rw-r--r-- 1 root root 4664 Sep  1 18:07 parsers.conf
-rw-r--r-- 1 root root  584 Sep  1 18:07 parsers_ambassador.conf
-rw-r--r-- 1 root root  226 Sep  1 18:07 parsers_cinder.conf
-rw-r--r-- 1 root root 2798 Sep  1 18:07 parsers_extra.conf
-rw-r--r-- 1 root root  240 Sep  1 18:07 parsers_java.conf
-rw-r--r-- 1 root root  845 Sep  1 18:07 parsers_mult.conf
-rw-r--r-- 1 root root  291 Sep 27 02:15 parsers_multiline.conf
-rw-r--r-- 1 root root 2954 Sep  1 18:07 parsers_openstack.conf
-rw-r--r-- 1 root root  579 Sep 27 02:15 stream_processor.conf # 追加設定用
```

FireLensコンテナの```/fluent-bit/etc/fluent-bit.conf```ファイルは以下の通りとなり，ローカルPCでFluentBitコンテナを起動した場合と異なる構成になっていることに注意する．

参考：https://dev.classmethod.jp/articles/check-fluent-bit-conf/

```bash
[INPUT]
    Name tcp
    Listen 127.0.0.1
    Port 8877
    Tag firelens-healthcheck

[INPUT]
    Name forward
    unix_path /var/run/fluent.sock

[INPUT]
    Name forward
    Listen 127.0.0.1
    Port 24224

[FILTER]
    Name record_modifier
    Match *
    Record ecs_cluster sample-test-cluster
    Record ecs_task_arn arn:aws:ecs:ap-northeast-1:123456789012:task/sample-test-cluster/d4efc1a0fdf7441e821a3683836ad69a
    Record ecs_task_definition sample-test-webapp-taskdefinition:15

[OUTPUT]
    Name null
    Match firelens-healthcheck
```

#### ・```fluent-bit_custom.conf```ファイル

FireLensコンテナの```/fluent-bit/etc/fluent-bit.conf```ファイルを，コンテナ定義の```config-file-value```キーで指定し，追加設定を実行する．これにより，FireLensコンテナにINCLUDE文が挿入される．

参考：https://dev.classmethod.jp/articles/check-fluent-bit-conf/

```bash
[INPUT]
    Name tcp
    Listen 127.0.0.1
    Port 8877
    Tag firelens-healthcheck
    
[INPUT]
    Name forward
    unix_path /var/run/fluent.sock
    
[INPUT]
    Name forward
    Listen 127.0.0.1
    Port 24224
    
[FILTER]
    Name record_modifier
    Match *
    Record ecs_cluster prd-foo-ecs-cluster
    Record ecs_task_arn arn:aws:ecs:ap-northeast-1:<アカウントID>:task/prd-foo-ecs-cluster/*****
    Record ecs_task_definition prd-foo-ecs-task-definition:1
    
@INCLUDE /fluent-bit/etc/fluent-bit_custom.conf # INCLUDE文が挿入される．

[OUTPUT]
    Name laravel
    Match laravel-firelens*
    
[OUTPUT]
    Name nginx
    Match nginx-firelens*    
```

ちなみに，標準の設定ファイルには，INPUTセクションがすでに定義されているため，```fluent-bit_custom.conf```ファイルではINPUTセクションを定義しなくても問題ない．

参考：https://github.com/aws/aws-for-fluent-bit/blob/mainline/fluent-bit.conf

```bash
[INPUT]
    Name        forward
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

STREAM_TASKセクションにて，ログのタグ付けを定義する．FireLensコンテナのパイプラインでは，『<コンテナ名>-firelens-<タスクID>』という名前でログが処理されている．そのため，Stream Processorでログを抽出するためには，クエリで『```FROM TAG:'*-firelens-*'```』を指定する必要がある．ちなみに，STREAM_TASKセクションでタグ付けされたログは，INPUTセクションから再び処理し直される．

参考：https://aws.amazon.com/jp/blogs/news/under-the-hood-firelens-for-amazon-ecs-tasks/

```bash
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

```bash
[SERVICE]
    Flush 1
    Grace 30
    Log_Level info
    # ファイルを読み込む
    Parsers_File parsers_multiline.conf
    Streams_File stream_processor.conf
```

#### ・```parsers_multiline.conf```ファイル

MULTILINE_PARSERセクションにて，スタックトレースログの各行の結合を定義する．

参考：https://github.com/aws-samples/amazon-ecs-firelens-examples/blob/mainline/examples/fluent-bit/filter-multiline/README.md

```bash
[MULTILINE_PARSER]
    name          laravel
    type          regex
    flush_timeout 1000
    rule          "start_state"   "/(Dec \d+ \d+\:\d+\:\d+)(.*)/"  "cont"
    rule          "cont"          "/^\s+at.*/"                     "cont"
```

```bash
[SERVICE]
    flush                 1
    log_level             info
    parsers_file          /parsers_multiline.conf
    
[FILTER]
    name                  multiline
    match                 *
    multiline.key_content log
    # ファイルを読み込む．組み込みパーサ（goなど）を使用することも可能．
    multiline.parser      go, laravel
```

<br>

### FireLensコンテナのコンテナ定義

#### ・全体

```bash
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

