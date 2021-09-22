# Command Query Responsibility Segregation

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. CQRS

### CQRSとは

『Command Query Responsibility Segregation（コマンドクエリ責務分離）』の略．DBへのアクセス処理を書き込みと読み出しに分離する設計のこと．DDDに部分的に組み込むことができる．```N+1```問題にも，対処できる．

参考：https://vaadin.com/learn/tutorials/ddd/tactical_domain_driven_design

![cqrs](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/cqrs.png)

<br>

### Command（書き込み）

#### ・Commandとは

CREATE，UPDATE，DELETE処理を実行するオブジェクトのこと．今回，クリーンアーキテクチャを前提としてCQRSを説明する．概念や実装方法は以下のリンクを参考にせよ．

参考：

- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_architecture_domain_driven_design_clean_architecture.html
- https://github.com/hiroki-it/ddd-api-with-laravel#ddd-api-with-laravel

#### ・処理順序

1. インターフェース層のコントローラにて，リクエストモデルを作成する．
2. ユースケース層のインターラクターにて，リクエストモデルからデータを取り出し，ドメインモデルを作成する．これをインフラ層のリポジトリに渡す．
3. インフラ層の書き込み／読み出しリポジトリにて，IDモデルのデータを使用して，読み出し／書き込みリポジトリでSELECT文を実行し，DBからレコードを配列として取得する．続けて，ドメインモデルからデータを取り出し，配列の値を上書きする．この配列でINSERT／UPDATE文を実行する．インフラ層の実装は，全てを自前で実装せずにORMで代用できる．void型をユースケース層のインターラクターに渡す．
4. ユースケース層のインターラクターにて，リクエストモデルから作成した時に使用したドメインモデルを用いて，レスポンスモデルを作成する．レスポンスモデルをインタフェース層のコントローラに渡す．
5. インターフェース層のコントローラにて，レスポンスモデルをJSONに変換し，レスポンスを返信する．

<br>

### Query（読み出し）

#### ・Queryとは

READ処理を実行するオブジェクトのこと．今回，クリーンアーキテクチャを前提としてCQRSを説明する．概念や実装方法は以下のリンクを参考にせよ．

参考：

- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_architecture_domain_driven_design_clean_architecture.html
- https://github.com/hiroki-it/ddd-api-with-laravel#ddd-api-with-laravel

#### ・処理順序

1. インターフェース層のコントローラにて，リクエストモデルを作成する．
2. ユースケース層のインターラクターにて，リクエストモデルからデータを取り出し，IDモデルやCriteriaモデルを作成する．これをインフラ層のリポジトリに渡す．
3. インフラ層の読み出し専用リポジトリにて，IDモデルやCriteriaモデルのデータを用いて，DBからレコードを配列として取得する．配列からDTOを作成し，DTOをドメインモデルに変換する．ドメインモデルをユースケース層のインタラクターに渡す．
4. ユースケース層のインターラクターにて，ドメインモデルからデータを取り出し，レスポンスモデルを作成する．レスポンスモデルをインタフェース層のコントローラに渡す．
5. インターフェース層のコントローラにて，レスポンスモデルをJSONに変換し，レスポンスを返信する．

<br>

## 02. CQRSに基づくイベント駆動アーキテクチャ

### CQRSとイベントソーシングの関係

イベントソーシングの実装方法は様々あるが，CQRSとこれは相性がよい．

参考：https://postd.cc/using-cqrs-with-event-sourcing/