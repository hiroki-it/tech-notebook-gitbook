# テレメトリー間の紐付け

## 01. タグ

### タグの種類

| タグ名        | 説明   |
| ------------- | ------ |
| ```host```    | ホスト |
| ```device```  |        |
| ```source```  |        |
| ```env```     |        |
| ```version``` |        |

<br>

## 02. 構造化ログと他テレメトリー間の紐付け

### 分散トレース全体との紐付け

スパンと構造化ログの統合タグ（```service```，```env```，```version```）に同じ値を割り当てると，分散トレース全体と構造化ログ間を紐付けることができる．

参考：https://docs.datadoghq.com/ja/tracing/connect_logs_and_traces/

<br>

### スパンとの紐付け

スパンと構造化ログに，同じトレースIDとスパンIDを割り当てると，スパンと構造化ログ間を紐付けることができる．これにより，その構造化ログが，いずれのサービスで，またどのタイミングで発生したものかを確認できる．

参考：https://docs.datadoghq.com/tracing/visualization/trace/?tab=logs

![datadog_trace-viewer](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/datadog_trace-viewer.png)

<br>

## 03. メトリクスと他テレメトリー間の紐付け

### サーバ／コンテナのメトリクスとの紐付け

スパンとコンテナのDockerLabelの統合タグ（```service```，```env```，```version```）に，同じ値を割り当てると，分散トレースとサーバ／コンテナのOSに関するメトリクスを紐付けることができる．



<br>

