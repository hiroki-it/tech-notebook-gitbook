# マイクロサービスアーキテクチャ

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. イントロダクション

### 特徴

#### ・ビジネスのスケーリングに強い

ビジネスがスケーリングする時，サービスの新規実装または削除を行えば良いため，ドメイン層の激しい変化に強い．

#### ・コンウェイの法則が働く

マイクロサービスアーキテクチャにより，組織構造が小さなチームの集まりに変化することを期待できる．

#### ・高頻度でリリース可能

各サービスを独立してデプロイできるため，高頻度でリリースできる．

#### ・障害の影響が部分的

いずれかのサービスに障害が起こったとして，サーキットブレイカーを用いることにより，上流サービスへの障害の波及を食い止められる．そのため，障害の影響が部分的となり，アプリケーション全体が落ちてしまうことがない．

#### ・複数の開発言語を使用可能

サービス間で，共通のデータ記述言語を使用してデータ通信を行えば，各サービスの開発言語が異なっていても問題ない．

<br>

### リポジトリの粒度

#### ・モノリポジトリ

全てのサービスを一つのリポジトリで管理する．Googleではモノリポジトリによるマイクロサービスアーキテクチャが採用されている．

参考：https://www.fourtheorem.com/blog/monorepo

![monorepo](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/monorepo.png)

#### ・ポリレポジトリ

各サービスを異なるリポジトリで管理する．

![polyrepo](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/polyrepo.png)

<br>

## 02. 各分散システムの粒度

### サービス

#### ・サービスとは

マイクロサービスアーキテクチャにおけるバックエンドの分散システムのコンポーネントのこと．特定のサービスが他のサービスに侵食され，サービスの凝集度が低くならないようにするために，ACL：Anti Corruption Layer（腐食防止レイヤー）を設ける必要がある．腐食防止レイヤーは，異なるコンテキストから受信したデータを，そのサービスのコンテキストにあったデータ形式に変換する責務を持つ．CQRSでは，これはプロセスマネージャパターンとして知られている．一方でSagaパターンとも呼ばれるが，分散トランザクションでも同一の用語があるため，混乱を避けるためにプロセスマネージャパターンとする．

参考：

- https://github.com/czeslavo/process-manager
- https://www.oreilly.com/library/view/what-is-domain-driven/9781492057802/ch04.html
- https://docs.microsoft.com/ja-jp/previous-versions/msp-n-p/jj591569(v=pandp.10)?redirectedfrom=MSDN

![anti-corruption-layer](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/anti-corruption-layer.png)

#### ・各サービスのアーキテクチャ

各サービスのアーキテクチャは自由である．この時，ドメイン駆動設計のアーキテクチャに基づいて実装することが可能である．

**＊例＊**

参考：https://little-hands.hatenablog.com/entry/2017/12/07/bouded-context-implementation

ECサイトがあり，これの商品販売ドメインを販売サブドメインと配送サブドメインに分割できるとする．この時，それぞれのサブドメインの問題を解決する販売コンテキストと配送コンテキストをサービスの粒度となり，オニオンアーキテクチャのアプリケーション間で同期通信／非同期通信を行う．

![microservice-architecuture_onion-architecture](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/microservice-architecuture_onion-architecture.png)

<br>

### サービスの分割手法

#### ・サービスの分割例

| アプリケーション | リンク                                                    | 分割方法           | サービスの種類                                               |
| ---------------- | --------------------------------------------------------- | ------------------ | ------------------------------------------------------------ |
| Eコマース        | https://github.com/GoogleCloudPlatform/microservices-demo | ルートエンティティ | カート，商品検索とインデックス，通貨の変換，クレジットカード，送料と発送，注文確認メール，注文フロー，レコメンド，広告，合成監視 |
| Eコマース        | https://github.com/DataDog/ecommerce-workshop             | ルートエンティティ | 広告，割引                                                   |

<br>

#### ・サブドメイン，境界付けられたコンテキストを単位とした分割

サブドメインをサービスの粒度とする．ここでは，解決領域となる境界付けられたコンテキストがサブドメインの中に一つしか含まれていない場合を指しており，代わりに，境界付けられたコンテキストをサービスの粒度して考えても良い．サブドメインを粒度とすることを第一段階として，さらに小さな粒度に分割するために，次の段階としてルートエンティティを粒度とするとよい．

参考：

- https://microservices.io/patterns/decomposition/decompose-by-subdomain.html
- https://www.amazon.co.jp/dp/4873119316/ref=cm_sw_em_r_mt_dp_PVDKB4F74K7S07E4CTFF

![context-map](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/context-map.png)

#### ・ルートエンティティを単位とした分割

境界付けられたコンテキストを構成するルートエンティティをサービスの単位とする．ただし，イベント駆動方式でアプリケーションを連携した場合に限り，従来のリクエスト方式でアプリケーションを連携する場合のルートエンティティを使用することはアンチパターンである．最良な解決策として，サービスのオブジェクトの状態管理方式として，従来のデータに着目したステートソーシングではなく，振る舞いに着目したイベントソーシングを使用する必要がある．また，各サービスを名詞ではなく動詞で命名するとよい．その他，各サービスでDBを完全に独立させることや，SAGAパターンを使用すること，がある．

参考：

- https://www.koslib.com/posts/entity-services-anti-pattern/
- https://www.michaelnygard.com/blog/2018/01/services-by-lifecycle/
- https://medium.com/transferwise-engineering/how-to-avoid-entity-services-58bacbe3ee0b

<br>

## 03. 分散システム間の連携

### サービスオーケストレーション方式

#### ・オーケストレーションとは

中央集権型システムとも言う．全てのサービスを制御する責務を持ったオーケストレーションプログラムを設置する設計方法．個々のサービス間の連携方式では，リクエストリプライ方式を採用する．一つのリクエストが送信された時に，オーケストレーションプログラムは各サービスをコールしながら処理の結果を繋いでいく．マイクロサービスアーキテクチャだけでなく，サービス指向アーキテクチャでも使用される．

参考：

- https://news.mynavi.jp/itsearch/article/devsoft/1598
- https://blogs.itmedia.co.jp/itsolutionjuku/2019/08/post_729.html

![orchestration](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/orchestration.png)

#### ・コレオグラフィとは

分散型システムとも言う．オーケストレーションとしてのプログラムは存在せず，各サービスで下流サービスに連携する責務を持たせる設計方法である．個々のサービス間の連携方式では，イベント駆動方式を採用する．一つのリクエストが送信された時に，サービスからサービスに処理が繋がっていく．サービス間のインターフェースとして，キューを設置する．マイクロサービスアーキテクチャでは，コレオグラフィによる連携が推奨されている．

参考：https://blogs.itmedia.co.jp/itsolutionjuku/2019/08/post_729.html

![choreography](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/choreography.png)

<br>

### サービス間連携方式

#### ・イベント駆動方式

サービス間では，メッセージキューを用いた非同期通信を行う．メッセージキューはPub／Subデザインパターンで実装するか，またはAWS-SQSなどのツールを使用する．

![service_event_driven](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/service_event_driven.png)

#### ・リクエストリプライ方式

サービス間では，RESTfulAPIを用いた同期通信を実行する．

![service_request_reply](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/service_request_reply.png)

<br>

## 04. データ永続化方式

### ローカルトランザクション

#### ・ローカルトランザクションとは

各サービスに独立したトランザクション処理が存在しており，一つのトランザクション処理によって，特定のサービスのデータベースのみを操作する設計方法．推奨である．このノートでは，ローカルトランザクションを用いたインフラストラクチャ層の連携を説明する．

#### ・Sagaパターンとは

ローカルトランザクションの時に，インフラストラクチャ層を実現する設計方法．上流サービスのデータベースの操作完了をイベントとして，下流サービスのデータベースの操作処理を連続的にコールする．ロールバック時には補償トランザクションが実行され，逆順にデータベースの状態が元に戻される．

![saga-pattern](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/saga-pattern.png)

<br>

### グローバルトランザクション

#### ・グローバルトランザクションとは

分散トランザクションとも言う．一つのトランザクション処理が各サービスに分散しており，一つのトランザクション処理によて，各サービスのデータベースを連続的に操作する設計方法．非推奨である．

<br>

## 05. オブジェクトモデリング方式

### イベントソーシング

#### ・イベントソーシングとは

ビジネスの出来事をモデリングし，データとして永続化する．現在の状態を取得する場合は，初期のデータに全ての出来事を適用する．CQRSと相性が良い．

参考：

- https://qiita.com/suin/items/f559e3dcde7c811ed4e1
- https://martinfowler.com/articles/201701-event-driven.html

<br>

### ステートソーシング

#### ・ステートソーシングとは

ビジネスの現在の状態をモデリングし，データとして永続化する．過去の状態は上書きされる．

参考：http://masuda220.jugem.jp/?eid=435

<br>

## 06. 分散システムにおけるテスト

### CDCテスト：Consumer Drive Contract

#### ・CDCテストとは

サービスのコントローラがコールされてから，データベースの操作が完了するまでを，テストする．下流サービスのコールはモック化またはスタブ化する．

<br>

## 07. 運用

### 障害対策

#### ・サーキットブレイカーとは

サービス間に設置され，他のサービスに連鎖する障害を吸収するプログラムのこと．下流サービスに障害が起こった時に，上流サービスにエラーを返してしまわないよう，直近の成功時の処理結果を返信する．

![circuit-breaker](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/circuit-breaker.png)

<br>

### 横断的な監視

#### ・分散トレーシングとは

サービス間で分散してしまう各ログを，一意なIDで紐づける方法．

![distributed-tracing](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/distributed-tracing.png)

#### ・モニタリングサービス

Datadogによる分散トレースの監視については，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_datadog.html

<br>

## 08. フロントエンドのマイクロサービス化

### UI部品合成

#### ・UI部品合成とは

フロントエンドのコンポーネントを，各サービスに対応するように分割する設計方法．

![composite-ui](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/composite-ui.png)

<br>

### BFFパターン：Backends  For Frontends

#### ・BFFパターンとは

クライアントの種類（モバイル，Web，デスクトップ）に応じたAPIを構築し，このAPIから各サービスにルーティングする設計方法．BFFパターンを実装は可能であるが，AWSでいうAPI Gatewayで代用するとより簡単に実現できる．

![bff-pattern](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/bff-pattern.png)