# マイクロサービスアーキテクチャ

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

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

### サービス

#### ・サービスとは

マイクロサービスアーキテクチャにおけるコンポーネントのこと．サービスのロジックの粒度は，境界付けられたコンテキストになるようにする．特定のサービスが他のサービスに侵食され，コンテキストの凝集度が低くならないようにするために，ACL：Anti Corruption Layer（腐食防止レイヤー）を設ける必要がある．腐食防止レイヤーは，異なるコンテキストから受信したデータを，そのサービスのコンテキストにあったデータ形式に変換する責務を持つ．CQRSでは，これはプロセスマネージャパターンとして知られている．一方でSagaパターンとも呼ばれるが，分散トランザクションでも同一の用語があるため，混乱を避けるためにプロセスマネージャパターンとする．

参考：

- https://github.com/czeslavo/process-manager
- https://www.oreilly.com/library/view/what-is-domain-driven/9781492057802/ch04.html
- https://docs.microsoft.com/ja-jp/previous-versions/msp-n-p/jj591569(v=pandp.10)?redirectedfrom=MSDN

![anti-corruption-layer](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/anti-corruption-layer.png)

#### ・境界付けられたコンテキスト間の通信

境界付けられたコンテキストを粒度とするサービス間では，RESTfulAPIを用いた同期通信，またはメッセージキューを用いた非同期通信を行う．メッセージキューはPub／Subデザインパターンを使用して実現する．境界付けられたコンテキストは，ビジネスのドメインによってその実装内容は異なるものの，コンテキスト名は同じになることが多い．そのため，よくある境界付けられたコンテキストを知識として持っておくことで，新しいドメインで境界付けられたコンテキストを考える時の指針になる．

**＊例：株式会社ハコジム＊**

認証コンテキスト，予約コンテキスト，顧客管理コンテキスト，銀行支払いコンテキスト，クレジットカード支払いコンテキスト

参考：https://zenn.dev/hsshss/articles/e11efefc7011ab

![hacogym_bounded-context](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/hacogym_bounded-context.png)

#### ・各サービスのアーキテクチャ

各サービスのアーキテクチャは自由である．この時，ドメイン駆動設計のアーキテクチャに基づいて実装することが可能である．

**＊例＊**

参考：https://little-hands.hatenablog.com/entry/2017/12/07/bouded-context-implementation

販売コンテキストと配送コンテキストがあるとする．

![bounded-context_example_2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/bounded-context_example_2.png)

それぞれをドメイン駆動設計のアーキテクチャに落とし込む．アーキテクチャ間で同期通信／非同期通信を行う．

![bounded-context_example_2_onion-architecture](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/bounded-context_example_2_onion-architecture.png)

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

## 02. バックエンドのマイクロサービス化

### サービス間の処理連携

#### ・コレオグラフィとは

分散型システムとも言う．オーケストレーションとしてのプログラムは存在せず，各サービスで下流サービスに連携する責務を持たせる設計方法．一つのリクエストが送信された時に，サービスからサービスに処理が繋がっていく．サービス間のインターフェースとして，キューを設置する．このノートでは，コレオグラフィを用いたアプリケーション層の連携を説明する．

![choreography](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/choreography.png)

#### ・オーケストレーションとは

中央集権型システムとも言う．全てのサービスを制御する責務を持ったオーケストレーションプログラムを設置する設計方法．一つのリクエストが送信された時に，オーケストレーションプログラムは各サービスをコールしながら処理の結果を繋いでいく．

![orchestration](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/orchestration.png)

<br>

### トランザクション

#### ・ローカルトランザクションとは

各サービスに独立したトランザクション処理が存在しており，一つのトランザクション処理によって，特定のサービスのデータベースのみを操作する設計方法．推奨である．このノートでは，ローカルトランザクションを用いたインフラストラクチャ層の連携を説明する．

#### ・グローバルトランザクションとは

分散トランザクションとも言う．一つのトランザクション処理が各サービスに分散しており，一つのトランザクション処理によて，各サービスのデータベースを連続的に操作する設計方法．非推奨である．

#### ・Sagaパターンとは

ローカルトランザクションの時に，インフラストラクチャ層を実現する設計方法．上流サービスのデータベースの操作完了をイベントとして，下流サービスのデータベースの操作処理を連続的にコールする．ロールバック時には補償トランザクションが実行され，逆順にデータベースの状態が元に戻される．

![saga-pattern](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/saga-pattern.png)

<br>

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

### 横断的なテスト

#### ・CDCテスト：Consumer Drive Contract

サービスのコントローラがコールされてから，データベースの操作が完了するまでを，テストする．下流サービスのコールはモック化またはスタブ化する．

<br>

## 03. フロントエンドのマイクロサービス化

### UI部品合成

#### ・UI部品合成とは

フロントエンドのコンポーネントを，各サービスに対応するように分割する設計方法．

![composite-ui](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/composite-ui.png)

<br>

### BFFパターン：Backends  For Frontends

#### ・BFFパターンとは

クライアントの種類（モバイル，Web，デスクトップ）に応じたAPIを構築し，このAPIから各サービスにルーティングする設計方法．BFFパターンを実装は可能であるが，AWSでいうAPI Gatewayで代用するとより簡単に実現できる．

![bff-pattern](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/bff-pattern.png)