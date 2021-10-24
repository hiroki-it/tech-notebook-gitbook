# ログ収集

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Ec2におけるログ収集

### Datadogエージェント on EC2とは

#### ・Datadogエージェント on EC2とは

常駐プログラムであり，アプリケーションをログを収集し，Datadogに転送する．

参考：https://docs.datadoghq.com/ja/agent/amazon_ecs/?tab=awscli

![datadog-agent_on-server](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/datadog-agent_on-server.png)

#### ・ログ収集の有効化

ログの収集は標準で無効化されている．```/etc/datadog-agent/datadog.yaml```ファイルにて，これを有効化する．

```yaml
logs_enabled: true
```

<br>

## 02. Fargateにおけるログ収集

### FireLensコンテナ

#### ・FireLensコンテナとは

Datadogコンテナはコンテナからログを収集できないため，代わりにFireLensコンテナを用いる必要がある．以下のリンクを参考にせよ．

参考：

- https://docs.datadoghq.com/ja/integrations/ecs_fargate/?tab=fluentbitandfirelens
- https://hiroki-it.github.io/tech-notebook-gitbook/public/summary.html?q=firelens

<br>

### FireLensコンテナのベースイメージ

#### ・Datadogイメージ

DatadogコンテナのベースイメージとなるDatadogイメージがDatadog公式から提供されている．パブリックECRリポジトリからプルしたイメージをそのまま用いる場合と，プライベートECRリポジトリで再管理してから用いる場合がある．

#### ・パブリックECRリポジトリを用いる場合

ECSのコンテナ定義にて，パブリックECRリポジトリのURLを指定し，ECRイメージのプルを実行する．標準で内蔵されているyamlファイルの設定をそのまま用いる場合は，こちらを採用する．

参考：

- https://gallery.ecr.aws/datadog/agent
- https://github.com/DataDog/datadog-agent

#### ・プライベートECRリポジトリを用いる場合

あらかじめ，DockerHubからdatadogイメージをプルするためのDockerfileを作成し，プライベートECRリポジトリにイメージをプッシュしておく．ECSのコンテナ定義にて，プライベートECRリポジトリのURLを指定し，ECRイメージのプルを実行する．標準で内蔵されているyamlファイルの設定を上書きしたい場合は，こちらを採用する．

```dockerfile
FROM data/agent:latest
```

参考：https://hub.docker.com/r/datadog/agent

<br>

### 標準設定の上書き

参考：https://github.com/DataDog/datadog-agent/blob/main/pkg/config/config_template.yaml

<br>

## 03. ログの識別子

### attribute（属性）

#### ・予約済み属性

参考：https://docs.datadoghq.com/ja/logs/log_configuration/attributes_naming_convention/

| 属性名         | 説明                                           | 補足                                                         |
| -------------- | ---------------------------------------------- | ------------------------------------------------------------ |
| ```host```     | 送信元ホストを示す．                           | Datadogコンテナの環境変数にて，```DD_HOSTNAME```を用いてホストタグを設定する．これにより，ホストマップでホストを俯瞰できるようになるだけでなく，ログエクスプローラでホストタグが属性として付与される．<br>（例）```foo```，```bar-backend```，```baz-frontend``` |
| ```source```   | ログの生成元を示す．                           | ベンダー名を使用するとわかりやすい．<br>（例）```laravel```，```nginx```，```redis``` |
| ```status```   | ログのレベルを示す．                           |                                                              |
| ```service```  | ログの生成元のアプリケーションを示す．         | ログとAPM分散トレースを紐づけるため，両方に同じ名前を割り当てる必要がある．<br>（例）```foo```，```bar-backend```，```baz-frontend``` |
| ```trace_id``` | ログを分散トレースやスパンと紐づけるIDを示す． |                                                              |
| ```message```  | ログメッセージを示す．                         |                                                              |

#### ・標準属性

標準で用意された属性．

参考：https://docs.datadoghq.com/ja/logs/log_configuration/attributes_naming_convention/#%E6%A8%99%E6%BA%96%E5%B1%9E%E6%80%A7

**＊例＊**

Laravelの場合

```shell
{
  "container_id": "*****",
  "container_name": "/prd-foo-ecs-container",
  "date": 12345,
  "log_status": "NOTICE",
  "service": "foo",
  "source": "laravel",
  "timestamp": 12345
}
```

**＊例＊**

Nginxの場合

```bash
{
  "id": "*****",
  "content": {
    "timestamp": "2021-09-01T00:00:00.000Z",
    "tags": [
      "source:nginx",
      "env:prd"
    ],
    "service": "foo",
    "message": "nn.nnn.nn.nnn - - [01/Sep/2021:00:00:00 +0000] \"GET /healthcheck HTTP/1.1\" 200 17 \"-\" \"ELB-HealthChecker/2.0\"",
    "attributes": {
      "http": {
        "url_details": {
          "path": "/healthcheck"
        },
        "referer": "-",
        "method": "GET",
        "useragent_details": {
          "device": {
            "family": "Other",
            "category": "Other"
          },
          "os": {
            "family": "Other"
          },
          "browser": {
            "family": "Other"
          }
        },
        "status_category": "info",
        "url": "/healthcheck",
        "status_code": 200,
        "version": "1.1",
        "useragent": "ELB-HealthChecker/2.0"
      },
      "network": {
        "client": {
          "ip": "nn.nnn.nn.nnn"
        },
        "bytes_written": 17
      },
      "date_access": 12345,
      "timestamp": 12345,
      "service": "foo"
    }
  }
}
```

#### ・スタックトレース属性

スタックトレースログを構成する要素に付与される属性のこと．

参考：https://docs.datadoghq.com/ja/logs/log_collection/?tab=host#%E3%82%B9%E3%82%BF%E3%83%83%E3%82%AF%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B9%E3%81%AE%E5%B1%9E%E6%80%A7

| 属性名                   | 説明                                             |
| ------------------------ | ------------------------------------------------ |
| ```logger.name```        | ログライブラリの名前を示す．                     |
| ```logger.thread_name``` | スレッド名を示す．                               |
| ```error.stack```        | スタックトレースログ全体を示す．                 |
| ```error.message```      | スタックトレースログのメッセージ部分を示す．     |
| ```error.kind```         | エラーの種類（Exception，OSError，など）を示す． |

<br>

## 03. 収集されたログの送信

### EC2におけるログの送信

#### ・PHP Monologの場合

LogライブラリにMonologを使用している場合，```/etc/datadog-agent/conf.d/php.d```ディレクトリ下に```conf.yaml```ファイルを作成する．ここに，Datadogにログを送信するための設定を行う．

参考：https://docs.datadoghq.com/ja/logs/log_collection/php/?tab=phpmonolog#agent-%E3%81%AE%E6%A7%8B%E6%88%90

**＊実装例＊**

```yaml
init_config:

instances:

## Log section
logs:

  - type: file
    path: "/path/to/laravel.log"
    service: php
    source: php
    sourcecategory: sourcecode
```

<br>

### Fargateにおけるログの送信

FireLensコンテナで稼働するFluentBitが，Datadogにログを送信する．以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/observability/observability_fluentd_and_fluentbit.html

<br>

## 04. ログパイプライン

### ログパイプラインとは

Datadogに送信されたログのメッセージから値を抽出し，構造化ログの各属性に割り当てる．パイプラインのルールに当てはまらなかったされなかったログは，そのまま流入する．属性ごとにファセットに対応しており，各ファセットの値判定ルールに基づいて，ログコンソール画面に表示される．

<br>

### リマッパー

#### ・リマッパーとは

指定した属性に割り当てられた値を，Datadogにおけるログ指標に対応付ける．

#### ・ログステータスリマッパー

属性に割り当てられた値を，ルールに基づいて，ステータスファセットの各ステータス（```INFO```，```WARNING```，```ERROR```，など）にマッピングする．ログコンソール画面にて，ステータスファセットとして表示される．判定ルールについては，以下のリンクを参考にせよ．

参考：https://docs.datadoghq.com/ja/logs/processing/processors/?tab=ui#%E3%83%AD%E3%82%B0%E3%82%B9%E3%83%86%E3%83%BC%E3%82%BF%E3%82%B9%E3%83%AA%E3%83%9E%E3%83%83%E3%83%91%E3%83%BC

<br>

### ログパーサー

#### ・パーサーとは

非構造化ログを構造化する．

参考：https://docs.datadoghq.com/ja/logs/processing/processors/?tab=ui#%E6%A6%82%E8%A6%81

#### ・Grokパーサー

パースルール（```%{MATCHER:EXTRACT:FILTER}```）を用いて，属性にログ値を割り当てる．

参考：

- https://docs.datadoghq.com/ja/logs/processing/parsing/?tab=matcher
- https://docs.datadoghq.com/ja/logs/processing/processors/?tab=ui#grok-%E3%83%91%E3%83%BC%E3%82%B5%E3%83%BC

**＊例＊**

Laravelによって，以下のようなログが生成されるとする．

```log
[2021-01-01 00:00:00] staging.ERROR: ログのメッセージ
```

```log
[2021-01-01 00:00:00] production.ERROR: ログのメッセージ
```

以下のようなGrokパーサールールを定義する．```date```マッチャーを用いて，```date```属性にタイムスタンプ値を割り当てる．また，```word```マッチャーを用いて，```log_status```カスタム属性にステータス値を割り当てる．任意のルール名を設定できる．

```bash
FooRule \[%{date("yyyy-MM-dd HH:mm:ss"):date}\]\s+(production|staging).%{word:log_status}\:.+
```

これにより，構造化ログの各属性に値が割り当てられる．

```bash
{
  "date": 1630454400000,
  "log_status": "INFO"
}
```

#### ・Urlパーサー

構造化ログのURL値からパスパラメータやクエリパラメータを検出し，詳細な属性として新しく付与する．

参考：https://docs.datadoghq.com/ja/logs/processing/processors/?tab=ui#url-%E3%83%91%E3%83%BC%E3%82%B5%E3%83%BC

**＊例＊**

とあるソフトウェアによって，以下のようなログが生成されるとする．

```log
192.168.0.1 [2021-01-01 12:00:00] GET /users?paginate=10&fooId=1 200
```

以下のようなGrokパーサのルールを定義する．各マッチャーでカスタム属性に値を割り当てる．

```bash
FooRule %{ipv4:network.client.ip}\s+\[%{date("yyyy-MM-dd HH:mm:ss"):date}\]\s+%{word:http.method}\s+%{notSpace:http.url}\s+%{integer:http.status_code}
```

これにより，構造化ログの各属性に値が割り当てられる．

```bash
{
  "network": {
    "client": {
      "ip": "192.168.0.1"
    }
  },
  "date": 1609502400000,
  "http": {
    "method": "GET",
    "url": "/users?paginate=10&fooId=1",
    "status_code": 200
  }
}
```

これに対して，Urlパーサのルールを定義する．```http.url```属性からパスパラメータやクエリパラメータを検出し，```url_details```属性として新しく付与する．

```bash
{
  "network": {
    "client": {
      "ip": "192.168.0.1"
    }
  },
  "date": 1609502400000,
  "http": {
    "method": "GET",
    "url": "/users?paginate=10&fooId=1",
    "status_code": 200,
    "url_details": {
      "path": "/users",
      "queryString": {
        "paginate": 10,
        "fooId": 1
      }
    }
  }
}
```

#### ・カテゴリパーサー

検索条件に一致する属性を持つ構造化ログに対して，属性を新しく付与する．

**＊例＊**

Nginxによって，以下のようなログが生成されるとする．

```log
nn.nnn.nn.nn - - [01/Sep/2021:00:00:00 +0000] "GET /healthcheck HTTP/1.1" 200 17 "-" "ELB-HealthChecker/2.0"
```

以下のようなGrokパーサールールを定義する．```status_code```属性にステータスコード値を割り当てる．

```bash
access.common %{_client_ip} %{_ident} %{_auth} \[%{_date_access}\] "(?>%{_method} |)%{_url}(?> %{_version}|)" %{_status_code} (?>%{_bytes_written}|-)
access.combined %{access.common} (%{number:duration:scale(1000000000)} )?"%{_referer}" "%{_user_agent}"( "%{_x_forwarded_for}")?.*
error.format %{date("yyyy/MM/dd HH:mm:ss"):date_access} \[%{word:level}\] %{data:error.message}(, %{data::keyvalue(": ",",")})?
```

これにより，構造化ログの各属性に値が割り当てられる．

```bash
{
  "http": {
    "method": "GET",
    "referer": "-",
    "status_code": 200,
    "url": "/healthcheck",
    "useragent": "ELB-HealthChecker/2.0",
    "version": "1.1"
  },
  "network": {
    "bytes_written": 17,
    "client": {
      "ip": "nn.nnn.nnn.nn"
    }
  },
  "date_access": 12345
}
```

これに対して，以下のようなカテゴリパーサーのルールを定義する．```status_code```属性の値に応じて，異なるステータスコード値（```info```，```notice```，```warning```，```error```）の```http.status_category```属性を付与する．

```bash
info    @http.status_code:[200 TO 299]
notice  @http.status_code:[300 TO 399]
warning @http.status_code:[400 TO 499]
error   @http.status_code:[500 TO 599]
```

ステータスリマッパーを定義する．```http.status_category```属性のステータスコード値に応じて，ステータスファセットの各ステータス（```INFO```，```WARNING```，```ERROR```，など）にマッピングする．

#### ・ユーザエージェントパーサー

**＊例＊**

Nginxによって，以下のようなログが生成されるとする．

```log
nn.nnn.nn.nn - - [01/Sep/2021:00:00:00 +0000] "GET /healthcheck HTTP/1.1" 200 17 "-" "ELB-HealthChecker/2.0"
```

これに対して，以下のようなGrokパーサールールを定義する．```http.useragent```属性にユーザエージェント値を割り当てる．

```bash
access.common %{_client_ip} %{_ident} %{_auth} \[%{_date_access}\] "(?>%{_method} |)%{_url}(?> %{_version}|)" %{_status_code} (?>%{_bytes_written}|-)
access.combined %{access.common} (%{number:duration:scale(1000000000)} )?"%{_referer}" "%{_user_agent}"( "%{_x_forwarded_for}")?.*
error.format %{date("yyyy/MM/dd HH:mm:ss"):date_access} \[%{word:level}\] %{data:error.message}(, %{data::keyvalue(": ",",")})?
```

これにより，構造化ログの各属性に値が割り当てられる．

```bash
{
  "http": {
    "method": "GET",
    "referer": "-",
    "status_code": 200,
    "url": "/healthcheck",
    "useragent": "ELB-HealthChecker/2.0",
    "version": "1.1"
  },
  "network": {
    "bytes_written": 17,
    "client": {
      "ip": "nn.nnn.nnn.nn"
    }
  },
  "date_access": 12345
}
```

これに対して，ユーザエージェントパーサーのルールを定義する．```http.useragent```属性の値を分解し，```useragent_details```属性に振り分ける．これにより，構造化ログの各属性に値が割り当てられる．

```bash
{
  # ～ 中略 ～

  "useragent_details": {
    "device": {
      "family": "Other",
      "category": "Other"
    },
    "os": {
      "family": "Linux"
    },
    "browser": {
      "family": "Chrome"
    }
  },
  
  # ～ 中略 ～
}
```

<br>

### パースルールの構成

#### ・マッチャー

参考：https://docs.datadoghq.com/ja/logs/processing/parsing/?tab=matcher#%E3%83%9E%E3%83%83%E3%83%81%E3%83%A3%E3%83%BC%E3%81%A8%E3%83%95%E3%82%A3%E3%83%AB%E3%82%BF%E3%83%BC

#### ・フィルター

参考：https://docs.datadoghq.com/ja/logs/processing/parsing/?tab=filter#%E3%83%9E%E3%83%83%E3%83%81%E3%83%A3%E3%83%BC%E3%81%A8%E3%83%95%E3%82%A3%E3%83%AB%E3%82%BF%E3%83%BC

<br>

## 04-02. ログパイプラインの後処理

### 標準属性の付与

<br>

## 04-03. オプション処理

### ログのメトリクス

#### ・ログのメトリクスとは

パイプラインで処理を終えたログに関して，タグや属性に基づくメトリクスを作成する．メトリクスを作成しておくと，ログのレポートとして使用できる．

参考：https://www.amazon.co.jp/dp/1800568738

<br>

### インデックス

#### ・インデックスとは

パイプラインで処理を終えたログをグループ化し，ログの破棄ルールや保管期間をグループごとに定義できる．インデックスを使用すれば，Datadogのログ保管のネックになる保管料金を抑えられる．

参考：

- https://docs.datadoghq.com/ja/logs/indexes/
- https://tech-blog.abeja.asia/entry/why-datadog

<br>

### アーカイブ

<br>

### セキュリティルール

<br>

## 05. ログエクスプローラ

### Live Tail

### ・Live Tailとは

ログパイプライン処理後のログをリアルタイムで確認できる．

参考：https://docs.datadoghq.com/ja/logs/explorer/live_tail/

<br>

### ログクエリ

#### ・ログクエリ

構造化ログの属性名と値に基づいて，ログを絞り込める．

参考：https://docs.datadoghq.com/ja/logs/explorer/search_syntax/

#### ・オートコンプリート

入力欄右のアイコンで切り替える．検索条件として属性名と値を補完入力できる．オートコンプリートをの使用時は，小文字で入力した属性名の頭文字が画面上で大文字に変換される．

![log-query_auto-complete](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/log-query_auto-complete.png)

入力欄右のアイコンで切り替える．検索条件として属性名と値をそのまま入力する．

![log-query_non-auto-complete](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/log-query_non-auto-complete.png)
