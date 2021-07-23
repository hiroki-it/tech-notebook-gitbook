# オブジェクト指向分析／設計／プログラミング

## 01. アーキテクチャスタイル

### アーキテクチャスタイルと分析・設計手法

![アーキテクチャスタイルの種類](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/アーキテクチャスタイルの種類.png)

|                        | アーキテクチャスタイル | スタイルに基づく設計             |
| -------------------- | ---------------------- | -------------------------------- |
| **デプロイメント構成** | クライアント／サーバ   | クライアントサイド／サーバサイド |
|    **システム構成**    | オブジェクト指向       | オブジェクト指向分析・設計        |
|                        | Layeredアーキテクチャ  | Layeredアーキテクチャ設計        |
|                        | MVC                    | MVC設計                          |
|   **データ通信領域**   | REST                   | RESTful                          |
|  **ドメイン領域構成**  | ドメイン駆動           | ドメイン駆動設計                 |

<br>

## 01-02. オブジェクト指向分析・設計

### オブジェクト指向分析・設計を取り巻く歴史

![プログラミング言語と設計手法の歴史](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/プログラミング言語と設計手法の歴史.png)

<br>

## 02. オブジェクト指向分析

### オブジェクト指向分析

#### ・そもそもオブジェクトとは

互いに密接に関連するデータと手続き（処理手順）をオブジェクトと呼ばれる一つのまとまりとして定義する手法のこと．

#### ・オブジェクト指向分析とは

オブジェクト指向分析では，システム化の対象になる領域に存在する概念を，モデリングする．

#### ・モデリングの注意点

モデリングの方法として，実体の『状態』と『動作』を考える．  しかし，これは厳密ではない．  なぜなら，ビジネス領域を実装する時には，ほとんどの場合で，動作を持たない実体を表現することになるからである．  より厳密に理解するために，実体の『状態』と『状態の変更と表示』と考えるべき．  

<br>

### オブジェクト指向分析／設計で用いるダイアグラム図の種類

![複数視点のモデル化とUML](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/複数視点のモデル化とUML.jpg)

オブジェクト指向分析においては，ダイアグラム図を用いて，オブジェクトを表現することが必要になる．

#### ・機能の視点による分析／設計とは

システムの機能と処理の流れに注目し，分析／設計する方法．詳しくは，以降の説明を参照せよ．

#### ・振舞の視点による分析／設計とは

システムを実行する順番やタイミングに注目し，分析／設計する方法．詳しくは，以降の説明を参照せよ．シーケンス図は設計の段階で使用する．

参考：

- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_class.html
- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_method_data.html

#### ・構造の視点による分析／設計とは

システムの構成要素とそれぞれの関係に注目し，分析／設計する方法．詳しくは，以降の説明を参照せよ．クラス図は設計の段階で使用する．オブジェクト指向設計については，以下のリンクを参考にせよ．

参考：

- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_class.html
- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_method_data.html

<br>

### UML：Unified Modeling Language（統一モデリング言語）

#### ・UMLとは

オブジェクト指向分析・設計に用いられるダイアグラム図．ダイアグラム図のUMLには，構造図，振舞図に分類される．

（※ちなみ，UMLは，システム設計だけでなく，データベース設計にも使える）

#### ・分析に用いられるUMLダイアグラム

![UML-2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/UML-2.png)

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

**＊具体例＊**

オンラインショッピングにおけるユースケース

![ユースケース図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ユースケース図.png)

#### ・注意点

ユースケース図はシステムの複雑さを表現できないため，設計図としては役に立たない．そのため，ユースケース図は，設計図として作るのではなく，引き継ぎ時に最初に説明するドキュメントや非エンジニアのための資料として作るようにする．設計図としては，クラス図やシステムシーケンス図の方が適している．

<br>

###  アクティビティ図

#### ・アクティビティ図とは

ビジネスロジックや業務フローを手続き的に表記する方法．

**＊具体例＊**

![アクティビティ図](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/アクティビティ図.png)

## 02-03. 振舞の視点

###  システムシーケンス図

#### ・システムシーケンス図とは

アクターからアクターへの振舞の流れを，時間軸に沿って表記する方法．シーケンス図とは異なる．シーケンス図については，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_class.html

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

以下のリンクを参考にせよ．

- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_class.html
- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_phpobject_orientation_method_data.html

<br>

## 04. オブジェクト指向プログラミング

以下のリンクを参考にせよ．

- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_class.html
- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_method_data.html

