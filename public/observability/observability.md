# 可観測性

## 01. 可観測性

### 可観測性とは

『収集されたデータから，システムにおける予測不可能な不具合をどれだけ正確に推測できるか』を表す程度のこと．システムの予測可能な不具合は『監視』や『テスト』によって検知できるが，予測不可能なものを検知する必要がある．システムをより詳細に可視化し，予測できるものだけでなく，予測できない不具合を浮かび上がらせる必要性がある．

参考：

- https://blog.thundra.io/observability-driven-development-for-serverless
- https://sookocheff.com/post/architecture/testing-in-production/
- https://www.sentinelone.com/blog/observability-production-systems-why-how/

![observality_and_monitoring](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/observality_and_monitoring.png)

<br>

## 02. テレメトリー

### テレメトリーとは

可観測性を実現するために収集する必要のある３つのデータ要素（『メトリクス』『ログ』『分散トレース』）のこと．NewRelicやDatadogはテレメトリーの要素を全て持つ．また，AWSではCloudWatch（メトリクス＋ログ）とX-Ray（分散トレース）を両方利用すると，これらの要素を満たせたことになり，可観測性を実現できる．

参考：

- https://www.forbes.com/sites/andythurai/2021/02/02/aiops-vs-observability-vs-monitoringwhat-is-the-difference-are-you-using-the-right-one-for-your-enterprise/
- https://knowledge.sakura.ad.jp/26395/

<br>

### メトリクス

#### ・メトリクスとは

一定期間に収集されたデータポイントの集計数値のこと．特に重要なメトリクス（トラフィック，レイテンシー，エラー，サチュレーション）を４大シグナルという

参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html#Metric

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

### ログ

#### ・ログとは 

特定の時間に発生したイベントの記録のこと．

#### ・非構造化ログ

テキストのログのこと．

**＊例＊**

FluentBitのログ例

```log
<6>Feb 28 12:00:00 192.168.0.1 fluentd[11111]: [error] Syslog test
```

#### ・構造化ログ

JSON型のログのこと．

**＊例＊**

FluentBitのログ例

```bash
{
  "jsonPayload": {
    "pri": "6",
    "host": "192.168.0.1",
    "ident": "fluentd",
    "pid": "11111",
    "message": "[error] Syslog test"
  }
}
```

<br>

### 分散トレース

#### ・分散トレース

マイクロサービスアーキテクチャにて，個々のリクエストによって起こるイベントを追跡した記録のこと．分散システムに渡った一連の処理を，イベントの因果関係の繋がりと見ることができる．この一連の処理で発生する連続的なデータを追跡記録として収集する．リクエストヘッダーやボディにIDを割り当て，これを追跡する．AWSを使用している場合，例えばALBが```X-Amzn-Trace-Id```ヘッダーにリクエストIDを付与してくれるため，アプリケーションでリクエストIDを実装せずに分散トレースを実現できる．

参考：https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-request-tracing.html

<br>

## 02. 監視

### 監視とは

既知のメトリクス／ログに基づいて，システムにおける予測可能な不具合の発生を未然に防ぐこと．

参考：

- https://en.wikipedia.org/wiki/Website_monitoring
- https://blog.thundra.io/observability-driven-development-for-serverless

<br>

### フロントエンド監視

#### ・フロントエンド監視とは

ブラウザに関するトラフィックを監視する．

#### ・リアルユーザ監視

ブラウザは，Webページのロード時に，Navigation-timing-APIに対してリクエストを送信し，Webページパフォーマンスに関するメトリクスを収集する．リアルユーザ監視では，このメトリクスを監視する．

参考：https://developer.mozilla.org/ja/docs/Web/API/Navigation_timing_API

#### ・合成監視（外部監視）

『外部監視』ともいう．監視ツールは，実際のユーザの一連の操作を模したリクエストをアプリケーションに送信し，レスポンスに関するメトリクスを収集する．合成監視では，メトリクスを監視する．ユーザを模したリクエストを生成するという意味合いで，『合成』という．ユーザ視点で監視できる．

参考：

- https://takehora.hatenadiary.jp/entry/2019/07/05/012036
- https://www.manageengine.jp/products/Applications_Manager/solution_synthetic-monitoring.html

<br>

### アプリケーション監視（APM）

#### ・アプリケーション監視とは

『APM（アプリケーションパフォーマンス監視）』ともいう．アプリケーション内に常駐させた監視ツールエージェントは，サーバ内で稼働中のアプリケーションに関するメトリクスを収集する．また，ログ保管ツールを用いてアプリケーションログを収集する．アプリケーション監視では，これらのメトリクスやアプリケーションログを監視する．メトリクスの例は以下に示す．

| メトリクス例                         | 単位             |      |
| ------------------------------------ | ---------------- | ---- |
| SQLにかかる時間                      | 回数当たりの時間 |      |
| ビルドまたはデプロイの開始／終了時間 | 回数当たりの時間 |      |
| 外部APIコールにかかる時間            | 時間当たり回数   |      |
| リクエストの受信数                   | 時間当たり回数   |      |
| ログイン数                           | 時間当たり回数   |      |

#### ・StatsDを用いたメトリクスの作成

サーバ内に常駐するメトリクス送信プログラム．アプリケーションでStatsDライブラリを用いると，メトリクスを生成できる．このメトリクスを指定した監視ツールに送信する．

参考：https://github.com/statsd/statsd/wiki

CloudWatchではStatsDからのメトリクスの送信がサポートされている．

参考：

- https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-custom-metrics-statsd.html
- https://qiita.com/murata-tomohide/items/9bd1320865b2eba47538

<br>

### サーバ監視

<br>

### ネットワーク監視

<br>

### セキュリティ監視

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