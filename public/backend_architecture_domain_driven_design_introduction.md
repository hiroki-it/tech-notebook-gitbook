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

#### ・ドメイン

ビジネスモデル全体で見た時に，システム化の対象となる部分領域のこと．ビジネスモデル全体をいくつかのドメインを分割する方法として，一連の業務フローの中で，業務の担当者の属性が変化するタイミングに着目すると良い．

**＊例＊**

インターネット広告代理店の例．ビジネスモデルに基づく複数のドメインを示す．業務フローの担当者の変化として，まず問い合わせで注文を受けて広告アカウントを作成する『営業担当者』，制作した広告をアカウントに入稿する『制作担当者』，入稿された広告を運用して広告効果を高める『マーケティング担当者』，最後に広告の依頼者に料金を請求する『経理担当者』が挙げられる．これにより，インターネット広告代理店のビジネスモデルは，各担当者に対応するドメインに分割できる．

参考：https://labs.septeni.co.jp/entry/2021/04/15/130000

![internet_advertising_agency_subdomain](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/internet_advertising_agency_domain.png)

**＊例＊**

![hacogym_business_model](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/hacogym_business_model.png)

完全個室ジムを運営するハコジムの例．ビジネスモデルに基づく複数のドメインを示す．業務フローの担当者の変化として，まず個室ジムに適する物件を探す『物件担当者』，ジムのトレーナーを採用して会員に紹介する『採用担当者』，個室ジムの利用会員を獲得する『営業担当者』が挙げられる．これにより，ハコジムのビジネスモデルは，各担当者に対応するドメインに分割できる．

参考：

- https://hacogym.jp/
- https://zenn.dev/hsshss/articles/e11efefc7011ab

![hacogym_domain](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/hacogym_domain.png)

#### ・コアドメイン，サブドメイン，ドメインエキスパートとは

各ドメインのドメインエキスパート（ビジネスルールに詳しい人）と，エンジニアが話し合いながら，ドメイン内の主要業務をコアドメイン，補助的な業務をサブドメインに分類する．

参考：

- https://qiita.com/crossroad0201/items/875c5f76ed3794ed56c4
- https://labs.septeni.co.jp/entry/2021/04/15/130000

![core-domain_sub-domain_bounded-context](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/core-domain_sub-domain_bounded-context.png)

**＊例＊**

完全個室ジムを運営するハコジムの例．ドメインのうちで，個室ジムドメインに基づくコアドメインとサブドメインを示す．コアドメインは予約ドメイン，それ以外はサブドメインとしている．

参考：

- https://hacogym.jp/
- https://zenn.dev/hsshss/articles/e11efefc7011ab

![hacogym_subdomain](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/hacogym_subdomain.png)

**＊例＊**

ECサイトを運営するアスクルの例．ドメインのうちで，個人向け販売ドメイン（サイト名はLOHACO）に基づくサブドメインを示す．配送／注文／商品／ユーザ管理／在庫／受注をそれぞれサブドメインとしている（コアドメインは明言されていない）．

参考：https://speakerdeck.com/askul/ddd-and-clean-architecture-at-lohaco?slide=28

#### ・ユビキタス言語とは

ドメインエキスパート間で，特定の『単語』や『動詞』の意味合い／定義づけが異なる場合，これを別々の名前からなるユビキタス言語として定義づける．

参考：https://qiita.com/kmdsbng/items/bf415afbeec239a7fd63

![domain-model](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/domain-model.png)

#### ・境界付けられたコンテキストとは

ドメインエキスパートの業務フローの立ち位置が異なれば，同じ『単語』や『動詞』であっても，異なる意味合い／定義づけのユビキタス言語が使用される．異なるユビキタス言語を元にして，境界付けられたコンテキストを定義する．この時，ユビキタス言語は，他の境界付けられたコンテキストでは通じないものであればあるほどよい．境界付けられたコンテキストそれぞれのユビキタス言語に合わせて，異なる名前でモデリングしていく．境界付けられたコンテキストを定義しない場合，異なるユビキタス言語をコアドメインやサブドメイン間で共有することとなり，それぞれの関心に無関係なデータを保持することになってしまう．

**＊例＊**

本を販売するECサイトの例．コアドメインとサブドメインに基づいたユビキタス言語と境界付けられたコンテキストを示す．バイヤー（仕入れ）部，マーケティング部，在庫管理部のドメインエキスパートは，『本（商品）』という単語に対する意味合い／定義づけが異なる．そのため，それぞれを『本』『クーポン』『在庫』というユビキタス言語として定義でき，モデル名／データ名はそれぞれのユビキタス言語に合わせた名前になる．例えば，マーケの境界付けられたコンテキストでは，モデル名はCouponとなり，割引期間データを保持する必要があるが，仕入部や在庫部ではこのデータは不要である．一方，ISBNは全ての境界付けられたコンテキストのモデルに必要なデータである．境界付けられたコンテキストを定義しない場合，一つの商品モデルが全てのデータを保持することとなり，それぞれのドメインエキスパートが関心を持たないデータも保持することになってしまう．

参考：https://kenta-kosugi.medium.com/%E3%83%9E%E3%82%A4%E3%82%AF%E3%83%AD%E3%82%B5%E3%83%BC%E3%83%93%E3%82%B9%E3%81%AE%E4%B8%8A%E6%89%8B%E3%81%AA%E5%88%86%E5%89%B2-ff5bb01d1062

![book_ec_ubiquitous_language](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/book_ec_ubiquitous_language.png)

**＊例＊**

完全個室ジムを運営するハコジムの例．個室ジムドメインのコアドメインとサブドメインに基づく境界付けられたコンテキスト．認証コンテキスト，予約コンテキスト，顧客管理コンテキスト，銀行支払いコンテキスト，クレジットカード支払いコンテキストがある．

参考：

- https://hacogym.jp/
- https://zenn.dev/hsshss/articles/e11efefc7011ab

![hacogym_bounded-context](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/hacogym_bounded-context.png)

**＊例＊**

契約請求管理アプリを提供するアルプの例．コアドメインとサブドメインに基づいたユビキタス言語と境界付けられたコンテキストを示す．契約管理コンテキスト，商品管理コンテキスト，請求管理コンテキスト，がある．取り組みとして，週次でユビキタス言語の更新を行っている．

参考：

- https://note.com/alpinc/n/nab47ab9273c6
- https://thealp.co.jp/

![contract_billing_management_ubiquitous_language](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/contract_billing_management_ubiquitous_language.png)

#### ・コンテキストマップとは

広義のドメイン全体の俯瞰する図のこと．コアドメイン，サブドメイン，境界付けられたコンテキストを定義した後，これらの関係性を視覚化する．異なるサブドメインの間で異なるユビキタス言語を使用する場合，境界付けられたコンテキストはサブドメインをまたがない．一方で，同じユビキタス言語を使用する場合，境界付けられたコンテキストは複数のサブドメインにまたがる．可能な限り，各境界付けられたコンテキストでは異なるユビキタス言語を使用し，境界付けられたコンテキストが複数のサブドメインにまたがないようにした方が良い（これ重要）．

参考：https://qiita.com/crossroad0201/items/875c5f76ed3794ed56c4

![context-map](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/context-map.png)

#### ・コアドメインとサブドメインのモデル化

コアドメインとサブドメインを対象として，境界付けられたコンテキスト内のユビキタス言語に基づいてドメインモデルを設計する．コアドメインのシステムは内製である必要があるが，サブドメインのシステムは外製／内製のいずれでも問題ない．

参考：https://qiita.com/crossroad0201/items/875c5f76ed3794ed56c4

![core-domain_sub-domain_bounded-context_modeling](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/core-domain_sub-domain_bounded-context_modeling.png)

**＊例＊**

完全個室ジムを運営するハコジムの例．個室ジムドメインのそれぞれの境界付けられたコンテキストに基づくモデリング．コアドメインの予約コンテキストとスマートロックコンテキストは，一つのマイクロサービスとして内製化している．一方で，それ以外の境界付けられたコンテキストは外製化している．

![hacogym_subdomain_modeling](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/hacogym_subdomain_modeling.png)

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

