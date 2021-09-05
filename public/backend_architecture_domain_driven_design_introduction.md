# ドメイン駆動設計概論

## 01. MVC

### MVCとは

ドメイン駆動設計が考案される以前，MVCの考え方が主流であった．

![MVCモデル](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/MVCモデル.png)

<br>

### MVCからドメイン駆動設計への発展

#### ・MVCの問題点

しかし，特にModelの役割が抽象的過ぎたため，開発規模が大きくなるにつれて，Modelに役割を集中させ過ぎてしまうことがあった．

#### ・MVCからドメイン駆動設計への移行

ドメイン駆動設計が登場したことによって，MVCは発展し，M・V・Cそれぞれの役割がより具体的で精密になった．Modelの肥大化は，Modelがもつビジネスロジックをドメイン層，またCRUD処理をインフラストラクチャ層として分割することによって，対処された．

![ドメイン駆動設計](https://user-images.githubusercontent.com/42175286/58724663-2ec11c80-8418-11e9-96e9-bfc6848e9374.png)

<br>

## 02. ドメイン駆動設計の手順

### ドメイン駆動設計の要素

#### ・戦略的設計の手順

戦略的設計では，ドメイン全体から境界付けられたコンテキストを明確にする．

1. ドメインエキスパートと話し合い，ドメイン全体の中の境界線を見つけ，それぞれを境界づけられたコンテキストとする．
2. コンテキストマップを作成し，境界付けられたコンテキスト間の関係を明らかにする．

#### ・戦術的設計の手順

戦術的設計では，境界付けられたコンテキストをアーキテクチャやデザインパターンに落とし込む．

1. ドメインエキスパートと話し合い，境界付けられたコンテキストに含まれる要件をヒアリングを行う．この時，ビジネスのルール／制約を十分にヒアリングする．
2. 要件からユースケース図を作成する．この時，『システムが，〇〇を△△する．』と考えるとよい．
3. 通常のオブジェクト指向分析／設計では，ユースケース図の後にクラス図を作成する．しかしドメイン駆動設計では，クラス図作成よりも先に集約の粒度を明確化するために，ユースケース図から『名詞』を抽出し，これを一つのドメインモデルとしたドメインモデル図を作成する．ドメインモデル図では，ビジネスのルール／制約を吹き出しに書き込む．各モデルのルール／制約に依存関係があり，データをセットで扱う必要があるような場合，これらを一つの集約として定義づけるとよい．
4. 必要であればドメインエキスパートに再ヒアリングを行い，ドメインモデル図を改善する．
5. ドメインモデル図を元に，クラス図を作成する．この時，モデルをエンティティや値オブジェクトを切り分けるようにする．
6. アーキテクチャ（レイヤード型，ヘキサゴナル型，オニオン型，クリーンアーキテクチャ）を決め，クラス図を元にドメイン層を実装する．
7. 運用後に問題が起こった場合，モデリングを修正する．場合によっては，デザインパターンに切り分ける．

なお，オブジェクト指向分析／設計／プログラミングについては，以下のリンクを参考にせよ．

参考：

- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_analysis_design_programming.html
- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_class.html
- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_method_data.html

<br>

### 戦略的設計にまつわる用語

#### ・ドメインエキスパート，ユビキタス言語とは

ドメインエキスパート（現実世界のビジネスルールに詳しく，また実際にシステムを使う人）と，エンジニアが話し合いながら，ビジネスルールに対して，オブジェクト指向分析と設計を行っていく．この時，ドメインエキスパートとエンジニアの話し合いに齟齬が生まれぬように，ユビキタス言語（業務内容について共通の用語）を設定しておく．

![domain-model](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/domain-model.png)

#### ・境界づけられたコンテキストとは

コアドメインやサブドメインの内部を詳細にグループ化する時，ビジネスの関心事の視点で分割されたまとまりのこと．コンテキストの中は，さらに詳細なコンテキストにグループ化できる．両方のコンテキストで関心事が異なっていても，対象は同じドメインであることもある．

参考：https://little-hands.hatenablog.com/entry/2017/11/28/bouded-context-concept

![core-domain_sub-domain_bounded-context](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/core-domain_sub-domain_bounded-context.png)

**＊具体例＊**

仕事仲介サイトでは，仕事の発注者のドメインに注目した時，発注時の視点で分割された仕事募集コンテキストと，同じく契約後の視点で分割された契約コンテキストにまとめることができる．モデリングされた『仕事』は，コンテキスト間で視点が異なるため，意味合いが異なる．

![bounded-context_example](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/bounded-context_example.png)

#### ・コンテキストマップとは

広義のドメイン全体の俯瞰する図のこと．コアドメイン，サブドメイン，境界づけられたコンテキストを定義した後，これらの関係性を視覚化する．

![context-map](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/context-map.png)

<br>

### 戦術的設計にまつわる用語

#### ・レイヤードアーキテクチャ

最初に考案された実現方法．

参考：https://www.amazon.co.jp/dp/4798121967/ref=cm_sw_r_tw_dp_ZD0VGXSNQMNZF7K1ME8J?_encoding=UTF8&psc=1

![layered-architecture](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/layered-architecture.png)

#### ・ヘキサゴナルアーキテクチャ

別名『ポートアンドアダプターアーキテクチャ』という．レイヤードアーキテクチャのインフラストラクチャ層に対して，依存性逆転を組み込んだもの．ドメイン層のオブジェクトは，ドメイン層の他のオブジェクトに依存する以外，何のオブジェクトにも外部ライブラリにも依存しない．逆に考えれば，これらに依存するものはドメイン層に置くべきではないと判断できる．本質的には，他の『オニオンアーキテクチャ』『クリーンアーキテクチャ』に同じであり，実現方法の中ではオニオンアーキテクチャがおすすめである．

参考：https://www.amazon.co.jp/dp/B00UX9VJGW/ref=cm_sw_r_tw_dp_S20HJ24MHWTSED7T0ZCP

#### ・オニオンアーキテクチャ

レイヤードアーキテクチャのインフラストラクチャ層に対して，依存性逆転を組み込んだもの．ドメイン層のオブジェクトは，ドメイン層の他のオブジェクトに依存する以外，何のオブジェクトにも外部ライブラリにも依存しない．逆に考えれば，これらに依存するものはドメイン層に置くべきではないと判断できる．本質的には，他の『ヘキサゴナルアーキテクチャ』『クリーンアーキテクチャ』に同じである．

参考：

- https://jeffreypalermo.com/2008/07/the-onion-architecture-part-1/
- https://little-hands.hatenablog.com/entry/2017/10/11/075634

![onion-architecture](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/onion-architecture.png)

#### ・クリーンアーキテクチャ

レイヤードアーキテクチャのインフラストラクチャ層に対して，依存性逆転を組み込んだもの．ドメイン層のオブジェクトは，ドメイン層の他のオブジェクトに依存する以外，何のオブジェクトにも外部ライブラリにも依存しない．逆に考えれば，これらに依存するものはドメイン層に置くべきではないと判断できる．本質的には，他の『ヘキサゴナルアーキテクチャ』『オニオンアーキテクチャ』に同じである．

参考：https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

![clean-architecture](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/clean-architecture.jpeg)

#### ・ドメインモデル図

クラス図よりも先に作成し，オブジェクト間のAggregation（集約）の粒度を明確にする．ユースケース図から『名詞』を抽出し，これをドメインモデルとして，クラス図と同じようにドメインモデル間の関係を表現する．ただし，クラス図とは異なり，クラスのメソッドは省略し，保持するデータのみに注目する．ドメインモデルを日本語で表現してよい．クラス図におけるクラス間の関係については，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_php_object_orientation_class.html

ドメインモデル図の作成手順については，以下を参考にせよ．

参考：

- https://www.eureka-moments-blog.com/entry/2018/12/29/145802
- https://github.com/ShisatoYano/PlantUML/blob/master/DomainModelDiagram/DomainModelDiagram.pdf
