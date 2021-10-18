# 可観測性

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. 可観測性

### 可観測性とは

『収集されたデータから，システムにおける想定外の不具合をどれだけ正確に推測できるか』を表す程度のこと．システムの想定内の不具合は『監視』や『テスト』によって検知できるが，想定外のものを検知できない．しかし，可観測性を高めることにより，想定外の不具合を表面化できる．

参考：

- https://blog.thundra.io/observability-driven-development-for-serverless
- https://sookocheff.com/post/architecture/testing-in-production/
- https://www.sentinelone.com/blog/observability-production-systems-why-how/

![observality_and_monitoring](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/observality_and_monitoring.png)

<br>

### 可観測性を高める方法

テレメトリーを十分に収集し，これらを関連付けて可視化する必要がある．

<br>

## 02. テレメトリー

### テレメトリーとは

可観測性を実現するために収集する必要のある３つのデータ要素（『メトリクス』『ログ』『分散トレース』）のこと．NewRelicやDatadogはテレメトリーの要素を全て持つ．また，AWSではCloudWatch（メトリクス＋ログ）とX-Ray（分散トレース）を両方利用すると，これらの要素を満たせたことになり，可観測性を実現できる．

参考：

- https://www.forbes.com/sites/andythurai/2021/02/02/aiops-vs-observability-vs-monitoringwhat-is-the-difference-are-you-using-the-right-one-for-your-enterprise/
- https://knowledge.sakura.ad.jp/26395/

<br>

## 02-02. メトリクス 

### メトリクスとは

とある分析にて，一定期間に発生した複数のデータポイントの集計値のこと．『平均』『合計』『最小／最大』『平方根』などを用いて，データポイントを集計する．

参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html#Metric

![metrics_namespace_dimension](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/metrics_namespace_dimension.png)

<br>

### データポイント

#### ・データポイントとは

分析対象から得られる最小単位の数値データのこと．データポイントは，絶対的に小さいわけではなく，相対的に小さいことに注意する．例えば，とある分析で一分ごとに対象が測定される場合，一分ごとに得られる数値データがデータポイントとなる．一方で，一時間ごとの測定の場合，一時間ごとに得られる数値データがデータポイントである．

参考：

- https://whatis.techtarget.com/definition/data-point
- https://aws.amazon.com/jp/about-aws/whats-new/2017/12/amazon-cloudwatch-alarms-now-alerts-you-when-any-m-out-of-n-metric-datapoints-in-an-interval-are-above-your-threshold/

<br>

### ４大シグナル

#### ・４大シグナルとは

特に重要なメトリクス（トラフィック，レイテンシー，エラー，サチュレーション）のこと．

#### ・トラフィック

サーバ監視対象のメトリクスに属する．

#### ・レイテンシー

サーバ監視対象のメトリクスに属する．

#### ・エラー

サーバ監視対象のメトリクスに属する．

| 種類         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| 明示的エラー | 400/500系のレスポンス                                        |
| 暗黙的エラー | SLOに満たない200/300系のレスポンス，API仕様に合っていないレスポンス |

#### ・サチュレーション

システム利用率（CPU利用率，メモリ理容室，ストレージ利用率，など）の飽和度のこと．例えば，以下の飽和度がある．60～70%で，警告ラインを設けておく必要がある．サーバ監視対象のメトリクスに属する．

<br>

## 02-03. ログ

### ログとは 

特定の瞬間に発生したイベントが記載されたデータのこと．

参考：https://newrelic.com/jp/blog/how-to-relic/metrics-events-logs-and-traces

<br>

### 構造からみた種類

#### ・非構造化ログ

イベントの値だけが表示されたログのこと．文字列データで定義される．

```log
192.168.0.1 [2021-01-01 12:00:00] GET /foos/1 200 
```

#### ・構造化ログ

イベントの項目名と値が表示されたログのこと．JSON型で定義されることが多い．

```bash
{
    "client_ip": "192.168.0.1",
    "timestamp": "2021-01-01 12:00:00",
    "method": "GET",
    "url": "/foos/1",
    "status_code": 200
}
```

<br>

### ロギング

#### ・Distributed logging（分散ロギング）

マイクロサービスアーキテクチャにおいて，各サービスから収集されたログを，バラバラに分析／管理する方法のこと．

参考：https://www.splunk.com/ja_jp/data-insider/what-is-distributed-tracing.html#centralized-logging

#### ・Centralized logging（集中ロギング）

マイクロサービスアーキテクチャにおいて，各サービスから収集されたログを，一元的に分析／管理する方法のこと．

参考：https://www.splunk.com/ja_jp/data-insider/what-is-distributed-tracing.html#centralized-logging

<br>

## 02-04. 分散トレース

### 分散トレースとは

マイクロサービスアーキテクチャにおいて，複数のサービスから収集されたスパンのセットのこと．スパンを紐づけることによって，異なるサービスを横断する処理を，一繋ぎなものとして認識できるようになる．

参考：

- https://www.dynatrace.com/news/blog/open-observability-part-1-distributed-tracing-and-observability/
- https://docs.newrelic.com/jp/docs/distributed-tracing/concepts/introduction-distributed-tracing/
- https://medium.com/nikeengineering/hit-the-ground-running-with-distributed-tracing-core-concepts-ff5ad47c7058

![distributed-trace](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/distributed-trace.png)

<br>

### 分散トレースの読み方

上から下に読むと，上流サービス（上位スパン）が下流サービス（下位スパン）を処理をコールしていることを確認できる．下から上に読むと，下流サービス（下位スパン）から上流サービス（上位スパン）に結果を返却していることを確認できる．

参考：https://cloud.google.com/architecture/using-distributed-tracing-to-observe-microservice-latency-with-opencensus-and-stackdriver-trace

![distributed-trace_reading](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/distributed-trace_reading.png)

<br>

### スパン

#### ・スパンとは

マイクロサービスアーキテクチャにおいて，特定のサービスで発生したデータのセットのこと．JSON型で定義されることが多い．SaaSツールによってJSON型の構造が異なる．

参考：

- https://opentracing.io/docs/overview/spans/

- https://docs.datadoghq.com/ja/tracing/guide/send_traces_to_agent_by_api/#%E3%83%A2%E3%83%87%E3%83%AB

- https://docs.newrelic.com/jp/docs/distributed-tracing/trace-api/report-new-relic-format-traces-trace-api/#new-relic-guidelines

  

#### ・スパン間の紐づけ

リクエストヘッダーやボディにIDを割り当て，異なるサービスのスパン間を紐づける．AWSを使用している場合，例えばALBが```X-Amzn-Trace-Id```ヘッダーにリクエストIDを付与してくれるため，アプリケーションでリクエストIDを実装せずに分散トレースを実現できる．

参考：https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-request-tracing.html

#### ・データポイント化

スパンが持つデータをデータポイントとして集計することにより，メトリクスを収集できる．

<br>

## 03. 可観測性に基づく意思決定

### SLI：Service Level Indicator（サービスレベル指標）

#### ・SLIとは

サービスレベルの指標とするメトリクスのこと．

#### ・SLIの例

- サーバ稼働率
- データベース稼働率
- レイテンシー
- レスポンスタイム
- レスポンスのステータスコード率
- スループット

<br>

### AWSで役立つメトリクス

#### ・SLIに関連するメトリクス

| 指標                           | AWSリリース | 関連するメトリクス                                           | 補足                                                         |
| ------------------------------ | ----------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| サーバ稼働率                   | ECS         | ・```RunningTaskCount```                                     | ターゲット追跡スケーリングポリシーのECSサービスメトリクスも参考にせよ． |
| データベース稼働率             | RDS         | ・```CPUUtilization```<br>・```FreeableMemory```             |                                                              |
| レイテンシー                   | API Gateway | ・```Latency```<br>・```IntegrationLatency```                |                                                              |
| レスポンスのステータスコード率 | API Gateway | ・```4XXError```<br/>・```5XXError```                        |                                                              |
|                                | ALB         | ・```HTTPCode_ELB_4XX_Count```<br>・```HTTPCode_ELB_5XX_Count```<br>・```HTTPCode_TARGET_4XX_Count```<br>・```HTTPCode_TARGET_5XX_Count```<br>・```RejectedConnectionCount```<br>・```HealthyHostCount```<br>・```TargetConnectionErrorCount```<br>・```TargetTLSNegotiationErrorCount``` | 参考：https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html |

#### ・パフォーマンスに関するメトリクス

| 名前                     | AWSリリース | 補足                                                         |
| ------------------------ | ----------- | ------------------------------------------------------------ |
| パフォーマンスインサイト | RDS         | RDSのパフォーマンスに関するメトリクスを収集し，SQLレベルで監視できるようになる．パラメータグループの```performance_schema```を有効化する必要がある．対応するエンジンバージョンとインスタンスタイプについては，以下のリンクを参考にせよ．<br>参考：https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_PerfInsights.Overview.Engines.htm |
| Container インサイト     | ECS／EKS    | ECS／EKSのパフォーマンスに関するメトリクスを収集し，ECS／EKSのクラスター，サービス，タスク，インスタンス，単位で監視できるようになる．また，コンテナ間の繋がりをコンテナマップで視覚化できるようになる．ECS／EKSのアカウント設定でContainerインサイトを有効化する必要がある． |
| Lambdaインサイト         | Lambda      | Lambdaのパフォーマンスに関するメトリクスを収集できるようになる． |

<br>

### SLO：Service Level Objective（サービスレベル目標）

#### ・SLOとは

SLIとして採用した指標の目標値のこと．99.9%の成功率を目標とすることが多い．

#### ・SLOの例

- サーバ稼働率（日当たり0.1%のダウンタイム）
- データベース稼働率（日当たり0.1%のダウンタイム）
- レイテンシー（日当たり0.1%までのレイテンシー）
- レスポンスのステータスコード率（日当たり99.9%の200ステータスコード
- スループット（日当たり0.1%のスループット低下）

<br>

### エラーバジェット

#### ・エラーバジェットとは

年月当たりで許容するエラーやダウンタイムの程度のこと．エラーやダウンタイムの発生によってビジネスに影響を与える可能性があったとしても，SLOの閾値を超えない限りはこれを許容し，技術を優先する．ビジネスより技術を優先する時に，素早く意思決定できる．

<br>

### SLA：Service Level Agreement

#### ・SLAとは

サービスレベル合意と訳せる．インターネットサービスに最低限のサービスのレベルを保証し，これを下回った場合には返金できるように合意するもの．SLAとして，例えば以下がある．

| 項目             | 説明                                 | レベル例    | 返金率 |
| ---------------- | ------------------------------------ | ----------- | ------ |
| サーバ稼働率     | サーバの時間当たりの稼働率           | 99.9%以上   | 10%    |
| 障害回復時間     | 障害が起こってから回復するまでの時間 | 2時間以内   | 10%    |
| 障害お問い合わせ | 障害発生時のお問い合わせ可能時間帯   | 24時間365日 | 10%    |

#### ・AWSのSLA

AWSではサービスレベルの項目として，サーバ稼働率を採用している．これに対して，ほとんどのAWSリソースで，以下のSLAが設定されている．

| 毎月の稼働率         | サービスクレジットの割合 |
| -------------------- | ------------------------ |
| 99.0％以上SLA未満    | 10%                      |
| 95.0％以上99.0％未満 | 25%                      |
| 95.0%未満            | 100%                     |

各リソースにSLAが定義されている．例として，EC2やECSのSLAを参考にせよ．

参考：https://d1.awsstatic.com/legal/AmazonComputeServiceLevelAgreement/Amazon%20Compute%20Service%20Level%20Agreement_Japanese_2020-07-22_Updated.pdf

<br>

## 04. 監視

### 監視とは

既知のメトリクスとログに基づいて，システムにおける想定内の不具合の発生を未然に防ぐこと．

参考：

- https://en.wikipedia.org/wiki/Website_monitoring
- https://blog.thundra.io/observability-driven-development-for-serverless

<br>

### フロントエンド監視

#### ・フロントエンド監視とは

ブラウザに関するトラフィックを監視する．

#### ・リアルユーザ監視（RUM）

ブラウザは，Webページのロード時に，Navigation-timing-APIに対してリクエストを送信し，Webページパフォーマンスに関するメトリクスを収集する．リアルユーザ監視では，このメトリクスを監視する．

参考：https://developer.mozilla.org/ja/docs/Web/API/Navigation_timing_API

#### ・合成監視（外部監視）

『外部監視』ともいう．SaaSは，実際のユーザの一連の操作を模したリクエストをアプリケーションに送信し，レスポンスに関するメトリクスを収集する．合成監視では，メトリクスを監視する．ユーザを模したリクエストを生成するという意味合いで，『合成』という．ユーザ視点で監視できる．

参考：

- https://takehora.hatenadiary.jp/entry/2019/07/05/012036
- https://www.manageengine.jp/products/Applications_Manager/solution_synthetic-monitoring.html

<br>

### アプリケーション監視（APM）

#### ・アプリケーション監視とは

『APM（アプリケーションパフォーマンス監視）』ともいう．アプリケーション内に常駐させたSaaSエージェントは，サーバ内で稼働中のアプリケーションのメトリクスやアプリケーションログを収集し，SaaSに送信する．アプリケーション監視では，これらのメトリクスやアプリケーションログを監視する．メトリクスの例は以下に示す．

- SQLにかかる時間  
- ビルドまたはデプロイの開始／終了時間  
- 外部APIコールにかかる時間  
- リクエストの受信数  
- ログイン数  

#### ・StatsDを用いたメトリクスの作成

サーバ内にStatsDを常駐させ，アプリケーションでStatsDライブラリを用いると，メトリクスを収集できる．このメトリクスをSaaSに送信する．

参考：https://github.com/statsd/statsd/wiki

CloudWatchではStatsDからのメトリクスの送信がサポートされている．

参考：

- https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-custom-metrics-statsd.html
- https://qiita.com/murata-tomohide/items/9bd1320865b2eba47538

<br>

### サーバ／コンテナ監視

#### ・サーバ／コンテナ監視とは

サーバ／コンテナのOSに関するメトリクスを収集し，これをSaaSに送信する．サーバ／コンテナ監視では，このメトリクスを監視する．メトリクスの例は以下に示す．

- CPU
- メモリ
- ロードアベレージ
- ネットワーク
- ディスク

<br>

### ネットワーク監視

<br>

### セキュリティ監視
