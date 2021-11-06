# オブジェクト指向分析設計

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01 オブジェクト指向

### オブジェクト指向を取り巻く歴史

参考：https://umtp-japan.org/event-seminar/4233

![プログラミング言語と設計手法の歴史](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/プログラミング言語と設計手法の歴史.png)

<br>

### オブジェクト指向とは

互いに密接に関連するデータと手続き（処理手順）を，オブジェクトと呼ばれる一つのまとまりとして捉えること．

<br>

## 01-02. オブジェクト指向分析設計の手順まとめ

### オブジェクト指向分析の手順

システム化の対象になる領域にオブジェクト指向を適用し，モデリングを行う．モデリングを行いやすくするために，ダイアグラムを作成する．

参考：https://ja.wikipedia.org/wiki/%E3%82%AA%E3%83%96%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E6%8C%87%E5%90%91%E5%88%86%E6%9E%90%E8%A8%AD%E8%A8%88#%E3%82%AA%E3%83%96%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E6%8C%87%E5%90%91%E5%88%86%E6%9E%90

<br>

### オブジェクト指向設計の手順

#### 1. クラス図による設計

オブジェクト指向分析によるダイアグラム図を参考にして，クラス図を作る．ただし，クラス図ではオブジェクトの『振舞』を設計できないため，シーケンス図にこれを託す．

#### 2. シーケンス図による設計

オブジェクト指向分析によるダイアグラム図を参考にして，シーケンス図を作成する．システムシーケンス図とシーケンス図の違いについて，以下を参考にせよ．

参考：

- https://stackoverflow.com/questions/16889028/difference-between-sequence-diagram-sd-and-a-system-sequence-diagram-ssd
- https://en.wikipedia.org/wiki/Sequence_diagram

#### 3. 設計のレビュー

システムの静的な構造を設計するクラス図と，動的な振舞を設計するシーケンス図の間の整合性から，設計を妥当性をレビューする．

参考：https://www.sparxsystems.jp/bin/docs/ClassAndSeq.pdf

#### 4. デザインパターンの導入

クラス図に，デザインパターンを基にしたクラスを導入する．

#### 5. フレームワークのコンポーネントの導入

クラス図に，フレームワークのコンポーネントを導入する．

<br>

## 01-03. ダイアグラム

### ダイアグラムとは

オブジェクト指向分析設計において，システムをモデリングしやすくするための図のこと．

<br>

### ダイアグラムの種類

UML，概念データモデリング，構造化分析，リアルタイム分析，がある．

参考：https://home.jeita.or.jp/page_file/20151221161211_Pkr0lJhRIV.pd

![diagrams](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/diagrams.png)
<br>

### 視点による分類

#### ・機能の視点

システムの機能と処理の流れに注目するダイアグラムが属する．

#### ・振舞の視点

システムを実行する順番やタイミングに注目するダイアグラムが属する．シーケンス図には，分析に使用するシステムシーケンス図と，設計に使用するシーケンス図があることに注意する．

#### ・構造の視点

システムの構成要素とそれぞれの関係に注目するダイアグラムが属する．クラス図は設計のために使用することに注意する．

<br>

## 02. オブジェクト指向分析

### 機能の視点

DFD，ユースケース図，アクティビティ図，などがある．

<br>

### 振舞の視点

システムシーケンス図，状態遷移図，などがある．

<br>

## 02-02. DFD：Data Flow Diagram（データフロー図）

### DFDとは

![データフロー図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/データフロー図.jpg)

<br>

## 02-03. ユースケース図

### ユースケース図とは

アクターとユースケースと関係性に基づいて，アクターの要求に対するシステムの機能を表現する．『システムが，〇〇を△△する．』と考えるとよい．

<br>

### 記法

| 記号名                   | 説明                                                         | 補足                              |
| ------------------------ | ------------------------------------------------------------ | --------------------------------- |
| A ```<< invokes >>``` B  | ユースケースAの実行中に、ユースケースBが実行される           | ```<< include >>```と同じである． |
| A ```<< precedes >>``` B | ユースケースAが先に実行完了してから、ユースケースBが実行される |                                   |

**＊例＊**

オンラインショッピングにおけるユースケース図．

![ユースケース図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ユースケース図.png)

<br>

### 注意点

ユースケース図はシステムの複雑さを表現できないため，設計図としては役に立たない．そのため，ユースケース図は，設計図として作るのではなく，引き継ぎ時に最初に説明するドキュメントや非エンジニアのための資料として作るようにする．設計図としては，クラス図やシステムシーケンス図の方が適している．

<br>

## 02-04. アクティビティ図

### アクティビティ図とは

ビジネスロジックや業務フローを手続き的に表記する方法．

**＊例＊**

![アクティビティ図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/アクティビティ図.png)

## 02-05. システムシーケンス図

### システムシーケンス図とは

![system-sequence-diagram](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/system-sequence-diagram.png)

アクターとシステムの出入力に基づいて，ユーザの要求に対するシステムの動的な振舞を表現する．オブジェクト間の関係性に基づくシーケンス図とは異なり，図式化の目的としてはユースケース図と似ている．

参考：

- https://stackoverflow.com/questions/16889028/difference-between-sequence-diagram-sd-and-a-system-sequence-diagram-ssd
- https://digitalgyan.org/difference-between-sequence-diagram-and-a-system-sequence-diagram/
- https://katzn.hatenablog.com/entry/2013/05/08/235531

<br>

## 02-06. 状態遷移図

### 状態遷移図とは

状態（丸）と⁠遷移（矢印）の関係性に基づいて，システムの動的な振舞を表現する．矢印の横の説明は，遷移のきっかけとなる『イベント（入力）⁠／アクション（出力）⁠』を示す．

![状態遷移図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ストップウォッチ状態遷移図.jpg)

<br>

### 状態遷移表とは

状態遷移図から作成した表．状態遷移表を作成してみると，状態遷移図では，9つあるセルのうち4つのセルしか表現できておらず，残り5つのセルは表現されていないことに気づくことができる．

![状態遷移表](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ストップウォッチ状態遷移表.jpg)

**＊例題＊**

12.2 という状態

1. 初期の状態を『a』として，最初が数字なので，a行の『b』へ移動．
2. 現在の状態『b』から，次は数字なので，b行の『b』へ移動．
3. 現在の状態『b』から，次は小数点なので，b行の『d』へ移動．
4. 現在の状態『d』から，次は数字なので，b行の『e』へ移動．

![状態遷移表](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/状態遷移表.png)

<br>

## 02-07. オブジェクト図（インスタンス図）

### オブジェクト図とは

『インスタンス図』ともいう．特定の状態にある具体的なオブジェクト間の関係性に基づいて，ソフトウェアの静的な構造を表現する．

<br>

### 記法

| 記号名           | 説明                                                         |
| ---------------- | ------------------------------------------------------------ |
| インスタンス指定 | 特定の状態にあるオブジェクト（インスタンス）の具体例を表す． |
| スロット         | インスタンスが保持する具体的なデータを表す．                 |
| リンク           | インスタンス間の関係性を表す．何かしらの関係性があれば，全てリンクとして定義する． |

参考：https://thinkit.co.jp/article/40/3/3.html

![object-diagram](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/object-diagram.png)

<br>

## 03. オブジェクト指向設計

### 構造の視点

クラス図，ER図がある．

<br>

### 振舞の視点

シーケンス図．

<br>

## 03-02. クラス図

### クラス図とは

クラス間の関係性に基づいて，ソフトウェアの静的な構造を表現するダイアグラムのこと．

<br>

### クラス図の種類

#### ・関係性の判断

オブジェクト図のリンクを参考にして，クラス間の関係性がいずれのものに属するかを判断する．

#### ・データとして保持する関係性

Association（関連），Aggregation（集約），Composition（合成）が用いられる．

![データとして保持する関係性](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/データとして保持する関係性.png)

#### ・親子の関係性

Generalization（汎化），Realization（実現）が用いられる．

![親子の関係性](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/親子の関係性.png)

#### ・引数型／返却値型と使用する関係性

Dependency（依存）が用いられる．

![引数型または返却値型として使用する関係性](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/引数型または返却値型として使用する関係性.png)

<br>

### クラスの多重度

#### ・多重度とは

クラス間が，何個と何個で関係しているかを表記する方法．

**＊例＊**

社員は１つの会社にしか所属できない場合

『会社クラス』から見て，対する『社員クラス』の数は1つである．逆に，『社員クラス』から見て，対する『会社クラス』の数は0以上であるという表記．

![多重度](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/多重度.png)

| 表記  |    対するクラスがいくつあるか    |
| :---: | :------------------------------: |
|   1   |              必ず1               |
| 0.. 1 |  0以上1以下（つまり、0または1）  |
| 0.. n |            0以上n以下            |
| m.. n |            m以上n以下            |
|   *   | 0以上無限大以下（つまり、0以上） |
| 0.. * | 0以上無限大以下（つまり、0以上） |

**＊例＊**

【 営業部エンティティ 】

```
<-【 1課エンティティ 】

<-【 2課エンティティ 】

<-【 3課エンティティ 】

```

親エンティティなし

```
<-【 経営企画課エンティティ 】
```


というクラスの継承関係があった時，これを抽象的にまとめると，



【 部エンティティ(0.. *) 】

```
<-【 (0.. 1)課エンティティ 】
```


部エンティティから見て，対する課エンティティは0個以上である．

課エンティティから見て，対する部エンティティは0または1個である．

<br>

## 03-03. ER図：Entity Relation Diagram

### ER図とは

DBテーブルのカラム間の関係性に基づいて，DBの構造を表現する．『IE 記法』と『IDEF1X 記法』が一般的に用いられる．

<br>

### IE記法

![ER図（IE記法）](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ER図（IE記法）.png)

#### ・エンティティ，属性

![エンティティとアトリビュート](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/エンティティとアトリビュート.png)

#### ・リレーション，カーディナリティ（多重度）

  エンティティ間の関係を表す．

![リレーションとカーディナリティ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/リレーションとカーディナリティ.png)

#### ・1：1

![1対1](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/1対1.png)

#### ・1：多（リレーションが曖昧な状態）

オブジェクト指向分析が進むにつれ，『1：0 以上の関係』『1：1 以上の関係』のように具体化しく．

![1対1以上](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/1対1以上.png)

#### ・1：1 以上

![1対1以上](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/1対1以上.png)

<br>

## 03-04. シーケンス図

### シーケンス図とは

オブジェクト間の時系列的な関係性に基づいて，システムの動的な振舞を表現するダイアグラムのこと．

**＊例＊**

1. 5つのライフライン（店員オブジェクト，管理画面オブジェクト，検索画面オブジェクト，商品DBオブジェクト，商品詳細画面オブジェクト）を設定する．
2. 各ライフラインで実行される実行仕様間の命令内容を，メッセージや複合フラグメントで示す．

![シーケンス図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/シーケンス図.png)

**＊例＊**

1. 3つのライフラインを設定する．
2. 各ライフラインで実行される実行仕様間の命令内容を，メッセージや複合フラグメントで示す．

![シーケンス図_2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/シーケンス図_2.png)

