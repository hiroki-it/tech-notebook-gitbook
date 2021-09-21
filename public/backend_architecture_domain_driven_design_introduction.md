# ドメイン駆動設計概論

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

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

### 戦略的設計にまつわる用語

#### ・コアドメイン，サブドメイン，境界付けられたコンテキストとは

ビジネスのドメインは，コアドメインとサブドメインに分類できる．最初ドメインを定義し，ここから中心的なビジネスであるコアドメインと，補助的なビジネスであるサブドメインを切り分ける必要がある．また，異なるユビキタス言語から境界付けられたコンテキストを定義づける．

参考：

- https://little-hands.hatenablog.com/entry/2017/11/28/bouded-context-concept
- https://qiita.com/crossroad0201/items/875c5f76ed3794ed56c4

![core-domain_sub-domain_bounded-context](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/core-domain_sub-domain_bounded-context.png)

#### ・ドメインエキスパート，ユビキタス言語とは

ドメインエキスパート（現実世界のビジネスルールに詳しく，また実際にシステムを使う人）と，エンジニアが話し合いながら，ビジネスルールに対して，ドメインからコアドメインとサブドメインを切り分けていく．この時，ドメインエキスパート間で，特定の『単語』や『動詞』の意味合い／定義づけが異なる場合，これを別々の名前からなるユビキタス言語として定義づける．ユビキタス言語の違いは，異なる境界付けられたコンテキストとして定義づけられ，ユビキタス言語は他の境界付けられたコンテキストでは通じないものでなければならない．

参考：https://qiita.com/kmdsbng/items/bf415afbeec239a7fd63

![domain-model](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/domain-model.png)

#### ・境界付けられたコンテキストにおけるユビキタス言語に基づくモデリング

ドメインエキスパートの部署や業務フローの立ち位置が異なれば，同じ『単語』や『動詞』であっても，異なる意味合い／定義づけのユビキタス言語が使用される．異なるユビキタス言語を元にして，境界付けられたコンテキストを定義する．この時，ユビキタス言語は，他の境界付けられたコンテキストでは通じないものであればあるほどよい．境界付けられたコンテキストそれぞれのユビキタス言語に合わせて，異なる名前でモデリングしていく．境界付けられたコンテキストを定義しない場合，異なるユビキタス言語をコアドメインやサブドメイン間で共有することとなり，それぞれの関心に無関係なデータを保持することになってしまう．

参考：https://qiita.com/crossroad0201/items/875c5f76ed3794ed56c4

![core-domain_sub-domain_bounded-context_modeling](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/core-domain_sub-domain_bounded-context_modeling.png)

**＊例＊**

バイヤー（仕入れ）部，マーケティング部，在庫管理部のドメインエキスパートは，『本（商品）』という単語に対する意味合い／定義づけが異なる．そのため，それぞれを『本』『クーポン』『在庫』というユビキタス言語として定義でき，モデル名／データ名はそれぞれのユビキタス言語に合わせた名前になる．例えば，マーケの境界付けられたコンテキストでは，モデル名はCouponとなり，割引期間データを保持する必要があるが，仕入部や在庫部ではこのデータは不要である．一方，ISBNは全ての境界付けられたコンテキストのモデルに必要なデータである．境界付けられたコンテキストを定義しない場合，一つの商品モデルが全てのデータを保持することとなり，それぞれのドメインエキスパートが関心を持たないデータも保持することになってしまう．

参考：https://kenta-kosugi.medium.com/%E3%83%9E%E3%82%A4%E3%82%AF%E3%83%AD%E3%82%B5%E3%83%BC%E3%83%93%E3%82%B9%E3%81%AE%E4%B8%8A%E6%89%8B%E3%81%AA%E5%88%86%E5%89%B2-ff5bb01d1062

![ddd_strategic_design_flow_detail](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ddd_strategic_design_flow_detail.png)

#### ・コンテキストマップとは

広義のドメイン全体の俯瞰する図のこと．コアドメイン，サブドメイン，境界付けられたコンテキストを定義した後，これらの関係性を視覚化する．異なるサブドメインの間で異なるユビキタス言語を使用する場合，境界付けられたコンテキストはサブドメインをまたがない．一方で，同じユビキタス言語を使用する場合，境界付けられたコンテキストは複数のサブドメインにまたがる．可能な限り，各境界付けられたコンテキストでは異なるユビキタス言語を使用し，境界付けられたコンテキストが複数のサブドメインにまたがないようにした方が良い（これ重要）．

参考：https://qiita.com/crossroad0201/items/875c5f76ed3794ed56c4

![context-map](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/context-map.png)

<br>

### 戦術的設計にまつわる用語

#### ・DDDデザインパターン集

参考：https://www.ogis-ri.co.jp/otc/hiroba/technical/DDDEssence/chap1.html

#### ・レイヤードアーキテクチャ

最初に考案された実現方法．

参考：https://www.amazon.co.jp/dp/4798121967/ref=cm_sw_r_tw_dp_ZD0VGXSNQMNZF7K1ME8J?_encoding=UTF8&psc=1

![layered-architecture](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/layered-architecture.png)

#### ・ヘキサゴナルアーキテクチャ

別名『ポートアンドアダプターアーキテクチャ』という．レイヤードアーキテクチャのインフラストラクチャ層に対して，依存性逆転を組み込んだもの．ドメイン層のオブジェクトは，ドメイン層の他のオブジェクトに依存する以外，何のオブジェクトにも外部ライブラリにも依存しない．逆に考えれば，これらに依存するものはドメイン層に置くべきではないと判断できる．本質的には，他の『オニオンアーキテクチャ』『クリーンアーキテクチャ』に同じである．

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

<br>

## 03. ドメイン駆動設計の手順まとめ

### 戦略的設計の手順

![ddd_strategic_design_flow](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ddd_strategic_design_flow.png)

戦略的設計では，ドメイン全体から境界付けられたコンテキストを明確にする．

参考：https://qiita.com/crossroad0201/items/875c5f76ed3794ed56c4

1. ドメインエキスパートと話し合い，ドメイン全体の中からコアドメインとサブドメインを切り分ける．
2. ドメインエキスパートの部署や業務フローの立ち位置によっては，同じ『単語』や『動詞』であっても，意味合い／定義づけが異なる場合がある．この時，それぞれを別々の名前からなるユビキタス言語として定義づける．
3. ユビキタス言語を元に，境界付けられたコンテキストを定義づける．
4. コンテキストマップを作成し，境界付けられたコンテキスト間の関係を明らかにする．

<br>

### 戦術的設計の手順

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

