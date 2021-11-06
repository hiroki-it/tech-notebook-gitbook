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

システム化の対象になる領域にオブジェクト指向を適用し，モデリングを行う．モデリングを行いやすくするために，ダイアグラム図を作成する．

参考：https://ja.wikipedia.org/wiki/%E3%82%AA%E3%83%96%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E6%8C%87%E5%90%91%E5%88%86%E6%9E%90%E8%A8%AD%E8%A8%88#%E3%82%AA%E3%83%96%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E6%8C%87%E5%90%91%E5%88%86%E6%9E%90

<br>

### オブジェクト指向設計の手順

#### 1. クラス図による設計

オブジェクトの『構造』を設計するために，オブジェクト指向分析によるユースケース図をもとにクラス図を作る．ただし，クラス図ではオブジェクトの『振舞』を設計できないため，シーケンス図にこれを託す．

#### 2. シーケンス図による設計

オブジェクトの『振舞』を設計するために，シーケンス図を作成する．システムシーケンス図とシーケンス図の違いについて，以下を参考にせよ．

参考：

- https://stackoverflow.com/questions/16889028/difference-between-sequence-diagram-sd-and-a-system-sequence-diagram-ssd
- https://en.wikipedia.org/wiki/Sequence_diagram

#### 3. 設計のレビュー

構造を設計するクラス図と，振舞を設計するシーケンス図の間の整合性から，設計を妥当性をレビューする．

参考：https://www.sparxsystems.jp/bin/docs/ClassAndSeq.pdf

#### 4. デザインパターンの導入

クラス図に，デザインパターンを基にしたクラスを導入する．

#### 5. フレームワークのコンポーネントの導入

クラス図に，フレームワークのコンポーネントを導入する．

<br>

## 02. オブジェクト指向分析

### 分析ダイアグラム

#### ・分析ダイアグラムとは

オブジェクト指向分析において，システムをモデリングしやすくするための図のこと．

<br>

#### ・ダイアグラムの種類

UML，概念データモデリング，構造化分析，リアルタイム分析，がある．

参考：https://home.jeita.or.jp/page_file/20151221161211_Pkr0lJhRIV.pdf

![複数視点のモデル化とUML](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/複数視点のモデル化とUML.jpg)

<br>

### UML：Unified Modeling Language（統一モデリング言語）

#### ・UMLとは

オブジェクト指向分析に用いられるダイアグラム図．ダイアグラム図のUMLには，構造図，振舞図に分類される．

（※ちなみ，UMLは，システム設計だけでなく，データベース設計にも使える）

#### ・UMLの種類

![UML-2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/UML-2.png)



#### ・機能の視点

システムの機能と処理の流れに注目する．

#### ・振舞の視点

システムを実行する順番やタイミングに注目する．なお，シーケンス図は設計の段階で使用する．

#### ・構造の視点

システムの構成要素とそれぞれの関係に注目する．なお，クラス図は設計の段階で使用する．

<br>



<br>

## 02-02. 機能の視点

### DFD：Data Flow Diagram（データフロー図）

#### ・データフロー図とは

![データフロー図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/データフロー図.jpg)

<br>

### ユースケース図

#### ・ユースケース図とは

ユーザの要求に対するシステムの振舞のこと．『システムが，〇〇を△△する．』と考えるとよい．

| ユースケース間の関係     | 説明                                                         | 補足                            |
| ------------------------ | ------------------------------------------------------------ | ------------------------------- |
| A ```<< invokes >>``` B  | ユースケースAの実行中に、ユースケースBが実行される           | ```<<include>>```と同じである． |
| A ```<< precedes >>``` B | ユースケースAが先に実行完了してから、ユースケースBが実行される |                                 |

**＊例＊**

オンラインショッピングにおけるユースケース

![ユースケース図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ユースケース図.png)

#### ・注意点

ユースケース図はシステムの複雑さを表現できないため，設計図としては役に立たない．そのため，ユースケース図は，設計図として作るのではなく，引き継ぎ時に最初に説明するドキュメントや非エンジニアのための資料として作るようにする．設計図としては，クラス図やシステムシーケンス図の方が適している．

<br>

###  アクティビティ図

#### ・アクティビティ図とは

ビジネスロジックや業務フローを手続き的に表記する方法．

**＊例＊**

![アクティビティ図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/アクティビティ図.png)

## 02-03. 振舞の視点

###  システムシーケンス図

#### ・システムシーケンス図とは

アクターからアクターへの振舞の流れを，時間軸に沿って表記する方法．シーケンス図とは異なる．シーケンス図については，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/software/software_application_object_oriented_language_php_class_based.html

<br>

### 状態遷移図

#### ・状態遷移図とは

『状態』を丸，『⁠遷移』を矢印で表現した分析モデル．矢印の横の説明は，遷移のきっかけとなる『イベント（入力）⁠／アクション（出力）⁠』を示す．

![状態遷移図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ストップウォッチ状態遷移図.jpg)

#### ・状態遷移表とは

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

## 02-04. 構造の視点

### ER図：Entity Relation Diagram

#### ・ER図：Entity Relation Diagramとは

データベースの設計に用いられるダイアグラム図．オブジェクトが保持するデータの関係性を表す．『IE 記法』と『IDEF1X 記法』が一般的に用いられる．

![ER図（IE記法）](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ER図（IE記法）.png)

#### ・Entity と Attribute

![エンティティとアトリビュート](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/エンティティとアトリビュート.png)

#### ・Relation と Cardinality（多重度）

  エンティティ間の関係を表す．

![リレーションとカーディナリティ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/リレーションとカーディナリティ.png)

#### ・1：1

![1対1](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/1対1.png)

#### ・1：多（Relation が曖昧な状態）

オブジェクト指向分析が進むにつれ，『1：0 以上の関係』『1：1 以上の関係』のように具体化しく．

![1対1以上](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/1対1以上.png)

#### ・1：1 以上

![1対1以上](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/1対1以上.png)

<br>

## 03. オブジェクト指向設計

### 設計ダイアグラム

#### ・設計ダイアグラムとは

オブジェクト指向設計において，分析ダイアグラムに基づいてシステムを設計しやすくするための図のこと．

![UML-1](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/UML-1.png)

<br>

## 03-02. クラス図

### 種類

#### ・データとして保持する関係性

Association（関連），Aggregation（集約），Composition（合成）が用いられる．詳しくは，後述の説明を参照せよ．

![データとして保持する関係性](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/データとして保持する関係性.png)

#### ・親子の関係性

Generalization（汎化），Realization（実現）が用いられる．詳しくは，後述の説明を参照せよ．

![親子の関係性](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/親子の関係性.png)

#### ・引数型／返却値型と使用する関係性

Dependency（依存）が用いられる．詳しくは，後述の説明を参照せよ．

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

## 03-03. シーケンス図

**＊例＊**

1. 5つのライフライン（店員オブジェクト，管理画面オブジェクト，検索画面オブジェクト，商品DBオブジェクト，商品詳細画面オブジェクト）を設定する．
2. 各ライフラインで実行される実行仕様間の命令内容を，メッセージや複合フラグメントで示す．

![シーケンス図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/シーケンス図.png)

**＊例＊**

1. 3つのライフラインを設定する．
2. 各ライフラインで実行される実行仕様間の命令内容を，メッセージや複合フラグメントで示す．

![シーケンス図_2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/シーケンス図_2.png)

