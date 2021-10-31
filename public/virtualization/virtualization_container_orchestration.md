# コンテナオーケストレーション

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. コンテナオーケストレーションの種類

### 単一ホストOS上のコンテナオーケストレーション

単一ホストOS上のコンテナが対象である．異なるDockerfileに基づいて，Dockerイメージのビルド，コンテナレイヤーの生成，コンテナの構築，コンテナの起動，を実行できる．

| ツール名                       | ベンダー |
| ------------------------------ | -------- |
| Docker Compose                 | Docker   |
| ECS：Elastic Container Service | Amazon   |

<br>

### 複数ホストOSに渡るコンテナオーケストレーション

複数ホストOS上のコンテナが対象である．どのホストOSのDockerデーモンに対して，どのコンテナに関する操作を行うのかを選択的に命令できる．

参考：https://www.techrepublic.com/article/simplifying-the-mystery-when-to-use-docker-docker-compose-and-kubernetes/

| ツール名                        | ベンダー |
| ------------------------------- | -------- |
| Docker Swarm                    | Docker   |
| Kubernetes                      | Google   |
| EKS：Elastic Kubernetes Service | Amazon   |

<br>

## 02. コンテナデザインパターン

### サイドカー・パターン

#### ・サイドカー・パターンとは

アプリケーションコンテナを補助するコンテナとして，同じECSタスクやPod内に配置する．

#### ・ロギングコンテナの配置

FluentBitコンテナをサイドカーコンテナとして稼働させ，アプリケーションコンテナから送信されたログを他にルーティングする．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_fluentd_and_fluentbit.html

#### ・メトリクス収集コンテナの配置

Datadogコンテナをサイドカーコンテナとして稼働させ，アプリケーションコンテナからメトリクスを収集する．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/observability_monitering/observability_datadog_metrics.html

<br>

### アンバサダー・パターン

<br>

### アダプター・パターン

