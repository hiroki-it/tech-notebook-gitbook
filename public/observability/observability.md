# 可観測性

## 01. 可観測性

### 可観測性とは

『収集されたデータから，システムの予測できない問題をどれだけ正確に推測できるか』を表す程度のこと．システムの予測可能な不具合は『監視』や『テスト』によって検知できるが，予測不可能なものを検知する必要がある．システムをより詳細に可視化し，予測できるものだけでなく，予測できない不具合を浮かび上がらせる必要性がある．

参考：

- https://blog.thundra.io/observability-driven-development-for-serverless
- https://laredoute.io/blog/observability-at-la-redoute/
- https://www.sentinelone.com/blog/observability-production-systems-why-how/

![observality_and_monitoring](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/observality_and_monitoring.png)

<br>

### テレメトリー

#### ・テレメトリーとは

可観測性を実現するために収集する必要のある３つのデータ要素（『メトリクス』『ログ』『分散トレース』）のこと．

参考：

- https://www.forbes.com/sites/andythurai/2021/02/02/aiops-vs-observability-vs-monitoringwhat-is-the-difference-are-you-using-the-right-one-for-your-enterprise/
- https://knowledge.sakura.ad.jp/26395/

| 種類         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| メトリクス   | 一定期間に収集されたデータポイントの集計数値のこと．<br>参考：https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html#Metric |
| ログ         | 特定の時間に発生したイベントの記録のこと．                   |
| 分散トレース | マイクロサービスアーキテクチャにて，個々のリクエストの追跡記録のこと．分散システムに渡った一連の処理を，イベントの因果関係の繋がりと見ることができる．この一連の処理で発生する連続的なデータを追跡記録として収集する．リクエストにIDを割り当て，これを追跡する． |

#### ・テレメトリー搭載ツール

NewRelicやDatadogはテレメトリーの要素を全て持つ．また，AWSではCloudWatch（メトリクス＋ログ）とX-Ray（分散トレース）を両方利用すると，これらの要素を満たせたことになり，可観測性を実現できる．

<br>

### メトリクスの４大シグナル

#### ・レイテンシー

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_network_internet.html

#### ・トラフィック

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_network_internet.html

#### ・エラー

| 種類         | 説明                                                         |
| ------------ | ------------------------------------------------------------ |
| 明示的エラー | 400/500系のレスポンス<                                       |
| 暗黙的エラー | SLOに満たない200/300系のレスポンス，API仕様に合っていないレスポンス |

#### ・サチュレーション

システム利用率（CPU利用率，メモリ理容室，ストレージ利用率，など）の飽和度のこと．例えば，以下の飽和度がある．60～70%で，警告ラインを設けておく必要がある．

<br>

## 02. 監視

### 監視とは

システムが正常に稼働することを継続的に見守り，予測できる問題の発生を未然に防ぐこと．

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

『APM（アプリケーションパフォーマンス監視）』ともいう．アプリケーション内に常駐させた監視ツールエージェントは，稼働中のアプリケーションに関する様々なメトリクスを収集する．アプリケーション監視では，このメトリクスを監視する．Datadogにおけるアプリケーション監視については，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/observability/observability_datadog.html

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