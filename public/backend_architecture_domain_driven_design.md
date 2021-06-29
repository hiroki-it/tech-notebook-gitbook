# ドメイン駆動設計

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

<br>

## 02. ドメイン駆動設計の手順

### ドメイン駆動設計の要素

#### ・戦略的設計の手順

戦略的設計では，ドメイン全体から境界付けられたコンテキストを明確にする．

1. ドメインエキスパートと話し合い，ドメイン全体の中の境界線を見つけ，それぞれを境界づけられたコンテキストとする．
2. コンテキストマップを作成し，境界付けられたコンテキスト間の関係を明らかにする．

#### ・戦術的設計の手順

戦術的設計では，境界付けられたコンテキストをアーキテクチャに落とし込む．

1. ドメインエキスパートと話し合い，境界付けられたコンテキストに含まれる要件をヒアリングを行う．この時，ビジネスのルール／制約を十分にヒアリングする．
2. 要件からユースケース図を作成する．この時，『システムが，〇〇を△△する．』と考えるとよい．
3. 通常のオブジェクト指向分析／設計では，ユースケース図の後にクラス図を作成する．しかしドメイン駆動設計では，クラス図作成よりも先に集約の粒度を明確化するために，ユースケース図から『名詞』を抽出し，これを一つのドメインモデルとしたドメインモデル図を作成する．ドメインモデル図では，ビジネスのルール／制約を吹き出しに書き込む．各モデルのルール／制約に依存関係があり，整合性を保つ必要があるような場合，これらを一つの集約として定義づけるとよい．
4. 必要であればドメインエキスパートに再ヒアリングを行い，ドメインモデル図を改善する．
5. ドメインモデル図を元に，クラス図を作成する．この時，モデルをエンティティや値オブジェクトを切り分けるようにする．
6. アーキテクチャ（レイヤード型，ヘキサゴナル型，オニオン型，クリーンアーキテクチャ）を決め，クラス図を元にドメイン層を実装する．
7. 運用後に問題が起こった場合，モデリングを修正する．

なお，オブジェクト指向分析／設計／プログラミングについては，以下のリンクを参考にせよ．

参考：

- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_object_orientation_analysis_design_programming.html
- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_object_orientation_class.html
- https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_object_orientation_method_data.html

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

![ドメイン駆動設計](https://user-images.githubusercontent.com/42175286/58724663-2ec11c80-8418-11e9-96e9-bfc6848e9374.png)

#### ・ヘキサゴナルアーキテクチャ

別名『ポートアンドアダプターアーキテクチャ』という．レイヤードアーキテクチャのインフラストラクチャ層に対して，依存性逆転を組み込んだもの．ドメイン層のオブジェクトは，ドメイン層の他のオブジェクトに依存する以外，何のオブジェクトにも外部ライブラリにも依存しない．逆に考えれば，これらに依存するものはドメイン層に置くべきではないと判断できる．本質的には，他の『オニオンアーキテクチャ』『クリーンアーキテクチャ』に同じであり，実現方法の中ではオニオンアーキテクチャがおすすめである．

参考：https://www.amazon.co.jp/dp/B00UX9VJGW/ref=cm_sw_r_tw_dp_S20HJ24MHWTSED7T0ZCP

#### ・オニオンアーキテクチャ

レイヤードアーキテクチャのインフラストラクチャ層に対して，依存性逆転を組み込んだもの．ドメイン層のオブジェクトは，ドメイン層の他のオブジェクトに依存する以外，何のオブジェクトにも外部ライブラリにも依存しない．逆に考えれば，これらに依存するものはドメイン層に置くべきではないと判断できる．本質的には，他の『ヘキサゴナルアーキテクチャ』『クリーンアーキテクチャ』に同じであり，実現方法の中では本アーキテクチャがおすすめである．

参考：

- https://jeffreypalermo.com/2008/07/the-onion-architecture-part-1/
- https://little-hands.hatenablog.com/entry/2017/10/11/075634

![onion-architecture](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/onion-architecture.png)

#### ・クリーンアーキテクチャ

レイヤードアーキテクチャのインフラストラクチャ層に対して，依存性逆転を組み込んだもの．ドメイン層のオブジェクトは，ドメイン層の他のオブジェクトに依存する以外，何のオブジェクトにも外部ライブラリにも依存しない．逆に考えれば，これらに依存するものはドメイン層に置くべきではないと判断できる．本質的には，他の『ヘキサゴナルアーキテクチャ』『オニオンアーキテクチャ』に同じであり，実現方法の中ではオニオンアーキテクチャがおすすめである．

参考：https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

![clean-architecture](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/clean-architecture.jpeg)

#### ・アーキテクチャとコンテキストの関係

境界づけられたコンテキストを単位として，一つのアーキテクチャを考える．そのため，アーキテクチャ間では同期通信／非同期通信を行う必要がある．この時，同期通信はRESTAPI，また非同期通信はメッセージキューよPub／Subデザインパターンを使用して実現する．

**＊例＊**

販売コンテキストと配送コンテキストがあった時，それぞれをアーキテクチャに落とし込む．アーキテクチャ間で同期通信／非同期通信を行う．

参考：https://little-hands.hatenablog.com/entry/2017/12/07/bouded-context-implementation

![bounded-context_example_2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/bounded-context_example_2.png)

![bounded-context_example_2_onion-architecture](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/bounded-context_example_2_onion-architecture.png)

#### ・ドメインモデル図

クラス図よりも先に作成し，オブジェクト間のAggregation（集約）の粒度を明確にする．ユースケース図から『名詞』を抽出し，これをドメインモデルとして，クラス図と同じようにドメインモデル間の関係を表現する．ただし，クラス図とは異なり，クラスのメソッドは省略し，保持するデータのみに注目する．ドメインモデルを日本語で表現してよい．クラス図におけるクラス間の関係については，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_object_orientation_class.html

ドメインモデル図の作成手順については，以下を参考にせよ．

参考：

- https://www.eureka-moments-blog.com/entry/2018/12/29/145802
- https://github.com/ShisatoYano/PlantUML/blob/master/DomainModelDiagram/DomainModelDiagram.pdf

 <br>

## 03. プレゼンテーション層

### コントローラ

#### ・コントローラとは

ユーザインターフェース層から出力されたデータのフォーマットを検証し，ユースケース層に入力できる構造に変換する．また反対に，ユースケース層から出力されたデータを，ユーザインターフェース層に入力できる構造に変換する．この時，ユースケース層を超えてドメイン層に依存しないようにする．他に，『書式変換』，『表示する文言の生成』，『レンダリング』，『JSON構造の定義』，『バリデーション』などのロジックもコントローラの責務である．コントローラのこれらの責務を，デザインパターンとして切り分けると，よりスッキリする．

<br>

### Validationパターン

#### ・Validationパターンとは

デザインパターンの一つ．責務として，プレゼンテーション層にて，ユーザインターフェース層から出力されたデータのフォーマットを検証する．

**＊実装例＊**

日時データのフォーマットを検証する．

```php
<?php

// Validationのライブラリ
use Respect\Validation\Validator;

class FormatValidator
{
    /**
     * 日時データのフォーマットを検証します．
     */
    public function validateFormat($dateTime)
    {
        if (empty($dateTime)) {
            return false;
        }

        if (!Validator::date(\DateTime::ATOM)->validate($dateTime)) {
            return false;
        }

        return true;
    }
}
```

<br>

### Converterパターン

#### ・Converterパターンとは

デザインパターンの一つ．責務として，プレゼンテーション層にて，ユースケース層から出力されたデータを，ユーザインターフェース層に入力できる構造に変換する．

**＊実装例＊**

ユーザインターフェース層に渡すエンティティを連想配列に変換する．

```php
<?php
    
namespace App\Converter;
    
class Converter
{
   /**
    * オブジェクトを連想配列に詰め替えます．
    */
    public function convertToArray(XxxEntity $xxxEntity)
    {
        $xxxArray["id"] = $xxxEntity->id;
        $xxxArray["name"] = $xxxEntity->name;
        $xxxArray["email"] = $xxxEntity->email;
    }
}  
```

<br>

## 04. ユースケース層（アプリケーション層）

### ユースケース

#### ・ユースケースとは

ドメイン層のロジックを組み合わせて，ユーザの要求に対するシステムの振舞（ユースケース）を具現化する．また，インフラストラクチャ層のロジックを組み合わせて，データを永続化する．ユースケースごとに異なるUseCaseクラスを定義する方法と，全てのユースケースを責務としてもつUseCaseクラスを定義する方法がある．

**＊実装例＊**

```php
<?php

namespace App\UseCase;        
    
/**
 * 受注作成ユースケース
 * ※ユースケースごとにクラスを定義する方法
 */
class OrdersCreateUseCase
{
    public function createOrders()
    {
    
    }
}  
```

```php
<?php

namespace App\UseCase;        
    
/**
 * 受注ユースケース
 * ※CURD全てのユースケースを，一つのクラスを定義する方法
 */
class OrdersUseCase
{
    public function createOrders()
    {
    
    }
    
    public function readOrders()
    {
    
    }
    
    public function updateOrders()
    {
    
    }
    
    public function deleteOrders()
    {
    
    }
}  
```

#### ・ユースケース図

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_object_orientation_analysis_design_programming.html

<br>

### アプリケーションサービス

#### ・アプリケーションサービスとは

ユースケース層の中で，ドメイン層のオブジェクトを使用する汎用的なロジックが切り分けられたもの．ドメイン層のドメインサービスとは異なり，あくまでユースケース層のロジックが切り分けられたものである．

**＊実装例＊**

Slackへの通知処理をアプリケーションサービスとして切り分ける．

```php
<?php

namespace App\Service;

class SlackNotificationService
{
    private $message;

    public function __construct(Message $message)
    {
        $this->message = $message;
    }

    public function notify()
    {
        // SlackのAPIにメッセージを送信する処理
    }
}
```

これを，ユースケース層でコールするようにする．

```php
<?php

namespace App\UseCase;

use App\Service\SlackNotificationService;

class ExampleUseCase
{
    public function example()
    {
        $message = new Message(/* メッセージに関するデータを渡す */)
        $slackNotificationService = new SlackNotificationService($message)
        $slackNotificationService->notify();
    }
}  
```

<br>


## 05. ドメイン層

### エンティティ

#### ・エンティティとは

後述の説明を参照せよ．

<br>

### 値オブジェクト

#### ・値オブジェクトとは

後述の説明を参照せよ．

<br>

### ドメインイベント

#### ・ドメインイベントとは

ドメイン層の中で，ビジネス的な『出来事』をモデリングしたもの．エンティティや値オブジェクトは『物』をモデリングするため，着眼点が異なる．エンティティデザインパターンの一つである『Pub／Subパターン』の概念を用いて，ドメインイベントと処理の紐付きを表現する．

<br>

### Type Code（標準型）

#### ・Type Codeとは

Type Codeは概念的な呼び名で，実際は，標準的なライブラリとして利用できるEnumクラスに相当する．一意に識別する必要がないユビキタス言語の中でも，特に『区分』や『種類』などは，値オブジェクトとしてではなく，Enumクラスとしてモデリング／実装する．ただし，類似するパターンとして値オブジェクトのディレクトリ内に配置しても良い．

#### ・色

**＊実装例＊**

```php
<?php

namespace App\Domain\ValueObject\Type;

/**
 * 色のタイプコード
 */
class ColorType
{
    const RED = "1";
    const BLUE = "2";

    /**
     * 『self::定数名』で，定義の値へアクセスします．
     */
    private $set = [
        self::RED  => ["name" => "レッド"],
        self::BLUE => ["name" => "ブルー"]
    ];

    /**
     * 値 
     */
    private $value;

    /**
     * 色名
     */
    private $name;

    // インスタンス化の時に，『色の区分値』を受け取る．
    public function __construct(string $value)
    {
        // $kbnValueに応じて，色名をnameデータにセットする．
        $this->value = $value;
        $this->name = static::$set[$value]["name"];
    }

    /**
     * 値を返却します．
     */
    public function value(): int
    {
        return $this->value;
    }


    /**
     * 色名を返却します．
     */
    public function name(): string
    {
        return $this->name;
    }
}
```

#### ・性別

**＊実装例＊**

```php
<?php

namespace App\Domain\ValueObject\Type;

/**
 * 性別のタイプコード
 */
class SexType
{
    const MAN     = 1;
    const WOMAN   = 2;
    const UNKNOWN = 3;

    private static $set = [
        self::MAN     => ["name" => "男性"],
        self::WOMAN   => ["name" => "女性"],
        self::UNKNOWN => ["name" => "不明"],
    ];

    /**
     * 値
     */
    private $value;
    
    /**
     * 名前
     */
    private $name;

    public function __construct($value)
    {
        $this->value = $value;
        $this->name = static::$set[$value]["name"];
    }
    
    /**
     * 値を返却します．
     */
    public function value(): int
    {
        return $this->value;
    }    
    /**
     * 名前を返却します．
     */
    public function name()
    {
        return $this->name;
    }
}
```

#### ・年号

**＊実装例＊**

```php
<?php

namespace App\Domain\ValueObject\Type;

/**
 * 年月日のタイプコード
 */
class YmdType extends Type
{
    const MEIJI   = "1"; // 明治
    const TAISHO  = "2"; // 大正
    const SHOWA   = "3"; // 昭和
    const HEISEI  = "4"; // 平成
    const REIWA   = "5"; // 令和
    const SEIREKI = "9"; // 西暦

    private static $set = [
        self::MEIJI   => ["name" => "明治"],
        self::TAISHO  => ["name" => "大正"],
        self::SHOWA   => ["name" => "昭和"],
        self::HEISEI  => ["name" => "平成"],
        self::REIWA   => ["name" => "令和"],
        self::SEIREKI => ["name" => "西暦"],
    ];

    private static $ymd = [
        self::MEIJI  => [
            "start" => [ "year" => 1868, "month" => 1, "day" => 25, ],
            "end"   => [ "year" => 1912, "month" => 7, "day" => 29, ],
        ],
        self::TAISHO => [
            "start" => [ "year" => 1912, "month" => 7,  "day" => 30, ],
            "end"   => [ "year" => 1926, "month" => 12, "day" => 24, ],
        ],
        self::SHOWA  => [
            "start" => [ "year" => 1926, "month" => 12, "day" => 25, ],
            "end"   => [ "year" => 1989, "month" => 1,  "day" => 7, ],
        ],
        self::HEISEI => [
            "start" => [ "year" => 1989, "month" => 1,  "day" => 8, ],
            "end"   => [ "year" => 2019, "month" => 4, "day" => 30, ],
        ],
        self::REIWA => [
            "start" => [ "year" => 2019, "month" => 5,  "day" => 1, ],
            "end"   => [ "year" => 9999, "month" => 12, "day" => 31, ],
        ],
    ];

    /**
     * 値
     * 
     * @var string
     */
    private $value;

    /**
     * 年号名
     * 
     * @var string 
     */
    private $name;

    /**
     * 値を返却します
     *
     * @return string
     */
    public function value(): string
    {
        return $this->value;
    }

    /**
     * @param $value
     */
    public function __construct($value)
    {
        $this->value = $value;
        $this->name = static::$set[$value]["name"];
    }

    /**
     * 年号名を返却します
     * 
     * @return string
     */
    public function name()
    {
        return $this->name;
    }
}
```

<br>

### ドメインサービス

#### ・ドメインサービスとは

ドメイン層の中で，汎用的なロジックがメソッドとして切り分けられたもの．ドメイン層にメソッドを提供する．ドメイン層の例外処理をまとめたDomainExceptionクラスもこれに当てはまる．

<br>

### Specificationパターン

#### ・Specificationパターンとは

デザインパターンの一つ．ビジネスルールの検証，検索条件オブジェクトの生成は、エンティティや値オブジェクトのメソッド内部に持たせた場合，肥大化の原因となり，また埋もれてしまうため，可読性と保守性が悪い．そこで，こういったビジネスルールをSpecificationオブジェクトとして切り分けておく．

#### ・入力データに対するビジネスルールのValidation

真偽値メソッド（```isXxxx```メソッド）のように，オブジェクトのデータを検証して、仕様を要求を満たしているか、何らかの目的のための用意ができているかを調べる処理する．

**＊実装例＊**

```php
<?php

namespace App\Specification;

class ExampleSpecification
{
    /**
     * ビジネスルールを判定します．
     */
    public function isSatisfiedBy(Entity $entity): bool
    {
        if (!$entity->isX) return false;
        if (!$entity->isY) return false;
        if (!$entity->isZ) return false;

        return true;
    }
} 
```

#### ・検索条件オブジェクトの生成

リクエストのパスパラメータとクエリパラメータを引数として，検索条件のオブジェクトを生成する．ビジネスルールのValidationを行うSpecificationクラスと区別するために，Criteriaオブジェクトという名前としても用いられる．

**＊実装例＊**

```php
<?php

namespace App\Criteria;

class XxxCriteria
{
    private $id;

    private $name;

    private $email;

    /**
     * 検索条件のオブジェクトを生成します．
     */
    public function build(array $array)
    {
        // 自身をインスタンス化．
        $criteria = new static();

        if (isset($array["id"])) {
            $criteria->id = $array["id"];
        }

        if (isset($array["name"])) {
            $criteria->id = $array["name"];
        }

        if (isset($array["email"])) {
            $criteria->id = $array["email"];
        }

        return $criteria;
    }
}
```

<br>

### リポジトリ（インターフェース）

#### ・リポジトリ（インターフェース）とは

![Repository](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/Repository.png)

依存性逆転の原則を導入する場合に，ドメイン層にインターフェースリポジトリを配置する．インフラストラクチャ層の実装リポジトリクラスと対応関係にある．実装リポジトリについては，後述の説明を参考にせよ．

**＊実装例＊**

```php
<?php

namespace App\Domain\Repository;    
    
interface DogToyRepository
{
    /**
     * 具象メソッドはインフラストラクチャ層のリポジトリに実装．
     */
    function findAllDogToys();
}
```

<br>

### ドメイン貧血症

#### ・ドメイン貧血症とは

ドメイン層に配置されながらも，ビジネスロジックをほとんど持たないオブジェクトのこと．

#### ・ドメインサービスにおける注意点

ドメイン層のロジックをドメインサービスに切り分けすぎると，ドメイン層のオブジェクトがゲッターとセッターしか持たないオブジェクトになってしまう．これは，ドメイン貧血症の状態である．そのため，ドメインサービス層の構築は控えめにし，可能な限りエンティティ／値オブジェクトとして実装する．

<br>

## 05-02. エンティティ

### エンティティとは

責務として，ビジネスのルールや制約の定義を持ち，値オブジェクトとは区別される．エンティティの責務をデザインパターンとして切り分けると，よりスッキリする．

![ドメイン駆動設計_エンティティ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ドメイン駆動設計_エンティティ.jpg)

<br>

### 識別子あり

#### ・識別子ありとは

オブジェクトが識別子（例：IDなど）を持ち，他のオブジェクトと同じ属性をもっていても，区別される．この識別子は，データベースのプライマリキーに対応している．

```php
<?php

namespace App\Domain\ValueObject;

use App\Domain\Core\Entity;
use App\Domain\Core\Id;
use App\Domain\ValueObject\ToyName;
use App\Domain\ValueObject\Number;
use App\Domain\ValueObject\PriceVO;
use App\Domain\ValueObject\ColorVO;

/**
 * 犬用おもちゃのエンティティ
 */
class DogToy extends Entity
{
    /**
     * 犬用おもちゃID
     *
     * @var Id
     */
    private $id;

    /**
     * 犬用おもちゃタイプ
     *
     * @var ToyType
     */
    private $type;

    /**
     * 犬用おもちゃ商品名
     *
     * @var ToyName
     */
    private $name;

    /**
     * 数量
     *
     * @var Number
     */
    private $number;

    /**
     * 価格の値オブジェクト
     *
     * @var PriceVO
     */
    private $priceVO;

    /**
     * 色の値オブジェクト
     *
     * @var ColorVO
     */
    private $colorVO;

    /**
     *
     * @param ToyType $type
     * @param ToyName $name
     * @param Number  $number
     * @param PriceVO $priceVO
     * @param ColorVO $colorVO
     */
    public function __construct(ToyType $type, ToyName $name, Number $number, PriceVO $priceVO, ColorVO $colorVO)
    {
        $this->type = $type;
        $this->name = $name;
        $this->number = $number;
        $this->priceVO = $priceVO;
        $this->colorVO = $colorVO;
    }

    /**
     * 犬用おもちゃ名（色）を返却します．
     *
     * @return string
     */
    public function nameWithColor()
    {
        return sprintf(
            "%s（%s）",
            $this->name->value(),
            $this->colorVO->name()
        );
    }
}
```

<br>

### 識別子による等価性検証

#### ・識別子による等価性検証とは

等価性検証用の```equals```メソッドを持つ．保持する識別子が，対象のエンティティと同じ場合，同一のものと見なされる．

#### ・等価性の検証方法

全てのエンティティに等価性の検証メソッドを持たせると可読性が低い．そこで，全てのエンティティに等価性検証用の```equals```メソッドを持たせることをやめ，継承元の抽象クラスのエンティティにこれを定義するとよい．

```php
<?php

namespace App\Domain\Core;

/**
 * エンティティ抽象クラス
 */
abstract class Entity
{
    /**
     * IDクラス
     *
     * @var Id
     */
    protected Id $id;

    /**
     * エンティティの等価性を検証します．
     *
     * @param Entity $entity
     * @return bool
     */
    public function equals(Entity $entity): bool
    {
        return ($entity instanceof $this || $this instanceof $entity) // エンティティのデータ型の等価性
            && $this->id->equals($entity->id()); // IDオブジェクトの等価性
    }

    /**
     * IDクラスを返却します．
     */
    public function id(): Id
    {
        return $this->id;
    }
}
```

#### ・複合主キーへの対応（PHPでは不要）

以降の説明はJavaについて適用されるため，PHPでは不要である．複合主キーを持つオブジェクトに対応するために，主キーとなる方のオブジェクト側に，```equals```メソッドと```hash```メソッドを定義する．これにより，言語標準搭載の```equals```メソッドと```hash```メソッドをオーバーライドし，異なるセッションに渡ってオブジェクトを比較できるようにする．これらを定義しないと，オーバーライドされずに標準搭載のメソッドが使用される．標準搭載のメソッドでは，異なるセッションに渡ったオブジェクトの比較では，必ず異なるオブジェクトであると判定してしまう．

**＊実装例＊**

PHPでは不要であるが，参考までに，PHPで実装した．

```php
<?php

namespace App\Domain\Core;

/**
 * ID抽象クラス
 */
abstract class Id
{
    /**
     * ID
     *
     * @var string
     */
    private $id;

    /**
     * @param string $id
     */
    public function __construct(string $id)
    {
        $this->id = $id;
    }

    /**
     * ハッシュ値を返却します．
     *
     * NOTE: 複合主キーを持つオブジェクトの等価性を正しく検証するために，標準の関数をオーバーライドします．
     *
     * @return string
     */
    public function hash(): string
    {
        return $this->id;
    }

    /**
     * オブジェクトの等価性を検証します．
     *
     * NOTE: 複合主キーを持つオブジェクトの等価性を正しく検証するために，標準の関数をオーバーライドします．．
     *
     * @param Id $id
     * @return bool
     */
    public function equals(Id $id): bool
    {
        return ($id instanceof $this || $this instanceof $id) // IDオブジェクトのデータ型の等価性
            && $this->hash() == $id->hash(); // ハッシュ値の等価性
    }
}
```

<br>

### データの可変性／不変性

#### ・可変性／不変性の実現方法（Mutable／Immutable）

エンティティは可変的／不変的であり，インスタンスとして生成されて以降，データは変更されてもされなくともよい．オブジェクトの可変性を実現するために，セッターを使用する．また，不変性を実現するために```constructor```メソッドを使用する．不変性の実現方法については，後述の説明を参考にせよ．

<br>

## 05-03. 値オブジェクト

### 値オブジェクトとは

責務として，ビジネスのルールや制約の定義を持ち，エンティティと区別される．金額，数字，電話番号，文字列，日付，氏名，色などのユビキタス言語に関するデータと，一意で識別できるデータ（例えば，```$id```データ）を持つ．

![ドメイン駆動設計_バリューオブジェクト](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ドメイン駆動設計_バリューオブジェクト.jpg)

<br>

### 識別子なし

#### ・識別子なしとは

一意に識別できるデータをもたず，対象のユビキタス言語に関するデータをメソッドを持つ

#### ・金額

金額データの計算をUseCase内処理やエンティティ内メソッドで行うのではなく，金額計算を行う値オブジェクトのメソッドとして分割する．

**＊実装例＊**

```php
<?php

namespace App\Domain\ValueObject;

/**
 * 金額の値オブジェクト
 */
class MoneyVO extends ValueObject
{
    /**
     * 金額
     * 
     * @var float 
     */
    private $amount;

    /**
     *
     * @param int $amount
     */
    public function __construct(int $amount = 0)
    {
        $this->amount = (float) $amount;
    }

    /**
     * 金額を返却します
     * 
     * @return float
     */
    public function amount()
    {
        return $this->amount;
    }

    /**
     * 単位を返却します
     * 
     * @return string
     */
    public function unit()
    {
        return "円";
    }

    /**
     * 足し算の結果を返却します
     * 
     * @param Money $price
     * @return $this
     */
    public function add(Money $price)
    {
        return new static($this->amount + $price->amount);
    }

    /**
     * 引き算の結果を返却します
     * 
     * @param Money $price
     * @return $this
     */
    public function substract(Money $price)
    {
        return new static($this->amount - $price->amount);
    }

    /**
     * 掛け算の結果を返却します
     *
     * @param Money $price
     * @return $this
     */
    public function multiply(Money $price)
    {
        return new static($this->amount * $price);
    }
}
```

#### ・所要時間

所要時間データの計算をUseCaseクラス内処理やエンティティ内メソッドで行うのではなく，所要時間計算を行う値オブジェクトのメソッドとして分割する．

**＊実装例＊**

```php
<?php
    
namespace App\Domain\ValueObject;

/**
 * 所要時間の値オブジェクト
 */
class RequiredTime extends ValueObject
{
    /**
     * 判定値，歩行速度の目安，車速度の目安，を定数で定義する．
     */
    const JUDGMENT_MINUTE = 21;
    const WALKING_SPEED_PER_MINUTE = 80;
    const CAR_SPEED_PER_MINUTE = 400;

    /**
     * 距離
     * 
     * @var int 
     */
    private $distance;

    /**
     * @param int $distance
     */
    public function __construct(int $distance)
    {
        $this->distance = $distance;
    }

    /**
     * 徒歩または車のどちらを使用するかを判定します
     * 
     * @return bool
     */
    public function isMinuteByWalking(): bool
    {
        if ($this->distance * 1000 / self::WALKING_SPEED_PER_MINUTE < self::JUDGMENT_MINUTE) {
            return true;
        }

        return false;
    }

    /**
     * 徒歩での所要時間を計算します
     * 
     * @return float
     */
    public function minuteByWalking(): float
    {
        $minute = $this->distance * 1000 / self::WALKING_SPEED_PER_MINUTE;
        return ceil($minute);
    }

    /**
     * 車での所用時間を計算します
     * 
     * @return float
     */
    public function minuteByCar(): float
    {
        $minute = $this->distance * 1000 / self::CAR_SPEED_PER_MINUTE;
        return ceil($minute);
    }
}
```

#### ・住所

郵便番号データとその処理を値オブジェクトとして分割する．

**＊実装例＊**

```php
<?php

namespace App\Domain\ValueObject;

/**
 * 住所の値オブジェクト
 */
class Address extends ValueObject
{
    /**
     * 住所の文字数上限
     */
    const ADDRESS_MAX_LENGTH = 512;

    /**
     * 郵便番号
     *
     * @var string
     */
    private $zip;

    /**
     * 住所 (番地など)
     *
     * @var string
     */
    private $address;

    /**
     * 市区町村
     *
     * @var string
     */
    private $city;

    /**
     * @param string $city
     * @param string $zip
     * @param string $address
     * @param string $kana
     */
    public function __construct(string $city, string $zip, string $address, string $kana)
    {
        $this->city = $city;
        $this->zip = $zip;
        $this->address = $address;
    }

    /**
     * 郵便番号を生成し，返却します
     * 
     * @return string
     */
    public function zip()
    {
        return sprintf(
            "〒%s-%s",
            substr($this->zip, 0, 3),
            substr($this->zip, 3)
        );
    }

    /**
     * 住所を生成し，返却します
     * 
     * @return string
     */
    public function address(): string
    {
        return sprintf(
            "%s%s%s",
            $this->city->prefecture->name ?? '',
            $this->city->name ?? '',
            $this->address ?? ''
        );
    }
}
```

#### ・氏名

氏名，性別，データとその処理を値オブジェクトとして分割する．

**＊実装例＊**

```php
<?php

namespace App\Domain\ValueObject;

/**
 * 氏名クラスの値オブジェクト
 */
class Name extends ValueObject
{
    /**
     * 名前の文字数上限下限
     */
    const MIN_NAME_LENGTH = 1;
    const MAX_NAME_LENGTH = 64;

    /**
     * 姓
     * 
     * @var
     */
    private $lastName;

    /**
     * 名
     * 
     * @var string 
     */
    private $firstName;

    /**
     * セイ
     * 
     * @var string 
     */
    private $lastKanaName;

    /**
     * メイ
     * 
     * @var string 
     */
    private $firstKanaName;

    /**
     * @param string $lastName
     * @param string $firstName
     * @param string $lastKanaName
     * @param string $firstKanaName
     */
    public function __construct(string $lastName, string $firstName, string $lastKanaName, string $firstKanaName)
    {
        $this->lastName = $lastName;
        $this->firstName = $firstName;
        $this->lastKanaName = $lastKanaName;
        $this->firstKanaName = $firstKanaName;

    }

    /**
     * 氏名を作成します．
     */
    public function fullName(): string
    {
        return $this->lastName . $this->firstName;
    }

    /**
     * カナ氏名を作成します．
     */
    public function fullKanaName(): string
    {
        return $this->lastKanaName . $this->firstKanaName;
    }
}
```

<br>

### データの不変性（Immutable）

#### ・不変性の実現方法

値オブジェクトは不変的であり，インスタンスとして生成されて以降，データは変更されない．オブジェクトの不変性を実現するために，オブジェクトにセッターを定義しないようにし，データの設定には```construct```メソッドだけを使用するようにする．

**＊実装例＊**

```php
<?php

namespace App\Domain\ValueObject;

/**
 * 値オブジェクト
 */
class ExampleVO extends ValueObject
{
    /**
     * @var 
     */
    private $propertyA;

    /**
     * @var 
     */
    private $propertyB;

    /**
     * @var 
     */
    private $propertyC;

    /**
     * ExampleVO constructor.
     *
     * @param $propertyA
     * @param $propertyB
     * @param $propertyC
     */
    public function __construct($propertyA, $propertyB, $propertyC)
    {
        $this->propertyA = $propertyA;
        $this->propertyB = $propertyB;
        $this->propertyC = $propertyC;
    }
}
```

#### ・セッターでは不変的にならない理由

**＊実装例＊**

Test01クラスインスタンスの```$property01```データに値を設定するためには，インスタンスからセッターを呼び出す．セッターは何度でも呼び出せ，その度にデータの値を上書きできてしまう．

```php
<?php

$test01 = new Test01;

$test01->setProperty01("データ01の値");

$test01->setProperty01("新しいデータ01の値");
```

Test02クラスインスタンスの```$property02```データに値を設定するためには，インスタンスを作り直さなければならない．つまり，以前に作ったインスタンスの```$property02```の値は上書きできない．セッターを持たせずに，```construct```メソッドだけを持たせれば，不変的なオブジェクトとなる．

```php
<?php

$test02 = new Test02("データ02の値");

$test02 = new Test02("新しいデータ02の値");
```

<br>

### 概念的な統一体

```php
<?php

// ここに実装例
```

<br>

### 交換可能性

オブジェクトが新しくインスタンス化された場合，以前に同一オブジェクトから生成されたインスタンスから新しく置き換える必要がある．

<br>

### 属性による等価性

#### ・属性による等価性検証とは

等価性を検証するメソッドを持つ．保持する全ての属性が，対象の値オブジェクトと同じ場合，同一のものと見なされる．

#### ・等価性の検証方法

**＊実装例＊**

属性を一つだけ保持する場合，一つの属性のみを検証すれば良いため，以下の通りとなる．

```php
<?php

namespace App\Domain\ValueObject;   

/**
 * 連絡先メールアドレスの値オブジェクト
 */
final class ContactMail extends ValueObject
{
    /**
     * @var string
     */
    private string $value;

    /**
     * @param string $value
     */
    public function __constructor(string $value)
    {
        $this->value = $value;
    }

    /**
     * @return string
     */
    public function value(): string
    {
        return $this->value;
    }

    /**
     * 値オブジェクトの等価性を検証します．
     *
     * @param ValueObject $VO
     * @return bool
     */
    public function equals(ValueObject $VO): bool
    {
        // 単一の属性を対象とする．
        return $this->value() === $VO->value();
    }
}
```

属性を複数保持する値オブジェクトの場合，全ての属性を検証する必要があるため，以下の通りとなる．

```php
<?php

namespace App\Domain\ValueObject;

/**
 * 支払情報の値オブジェクト
 */
final class PaymentInfoVO extends ValueObject
{
    /**
     * 支払い方法
     *
     * @var PaymentType
     */
    private $paymentType;

    /**
     * 連絡先メールアドレス
     *
     * @var ContactMail
     */
    private $contactMail;

    /**
     * 金額
     *
     * @var Money
     */
    private $price;

    /**
     * @param PaymentType $paymentType
     * @param ContactMail $contactMail
     * @param Money       $price
     */
    public function __constructor(PaymentType $paymentType, ContactMail $contactMail, Money $price)
    {
        $this->paymentType = $paymentType;
        $this->contactMail = $contactMail;
        $this->price = $price;
    }

    /**
     * 値オブジェクトの等価性を検証します．
     *
     * @param ValueObject $VO
     * @return bool
     */
    public function equals(ValueObject $VO): bool
    {
        // 複数の属性を対象とする．
        return $this->paymentType->value() === $VO->paymentType->value()
            && $this->contactMail->value() === $VO->contactMail->value()
            && $this->price->value() === $VO->price->value();
    }
}
```

全ての値オブジェクトに等価性の検証メソッドを持たせると可読性が低い．そこで，継承元の抽象クラスの値オブジェクトに定義するとよい．その時は，保持している属性を反復的に検証できるように実装するとよい．

```php
<?php

namespace App\Domain;

/**
 * 値オブジェクト抽象クラス
 */
abstract class ValueObject
{
    /**
     * 値オブジェクトの等価性を検証します．
     *
     * @param ValueObject $VO
     * @return bool
     */
    public function equals(ValueObject $VO): bool
    {
        // 全ての属性を反復的に検証します．
        foreach (get_object_vars($this) as $key => $value) {
            if ($this->__get($key) !== $VO->__get($key)) {
                return false;
            }
        }
        
        return true;
    }
}
```

<br>

## 05-04. ルートエンティティとトランザクション

### ルートエンティティ

#### ・ルートエンティティとは

![ドメイン駆動設計_集約関係](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ドメイン駆動設計_集約関係.jpg)

エンティティや値オブジェクトからなる集約の中で，最終的にユースケース層へレスポンスされる集約を，『ルートエンティティ』という．

**＊実装例＊**

```php
<?php

namespace App\Domain\Entity;

use App\Domain\Core\Entity;
use App\Domain\Core\Id;
use App\Domain\Entity\DogToy;
use App\Domain\Entity\DogFood;

/**
 * 犬用注文エンティティ
 */
class DogOrder
{
    /**
     * 犬用商品コンボID
     *
     * @var Id
     */
    private $id;

    /**
     * 犬用おもちゃ
     *
     * @var DogToy
     */
    private $dogToy;

    /**
     * 犬用えさ
     *
     * @var DogFood
     */
    private $dogFood;

    /**
     * @param DogToy  $dogToy
     * @param DogFood $dogFood
     */
    public function __construct(DogToy $dogToy, DogFood $dogFood)
    {
        $this->dogToy = $dogToy;
        $this->dogFood = $dogFood;
    }

    /**
     * 犬用おもちゃを返却します．
     *
     * @return DogToy
     */
    public function getDogToy(): DogToy
    {
        return $this->dogToy;
    }

    /**
     * 犬えさを返却します．
     *
     * @return DogFood
     */
    public function getDogFood(): DogFood
    {
        return $this->dogFood;
    }
}
```

#### ・集約とは

データに整合性が必要なエンティティのまとまりのこと．依存関係の観点からみた集約については，以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_object_orientation_class.html

<br>

### トランザクションとの関係性

インフラストラクチャ層のリポジトリでは，ルートエンティティの単位で，データの書き込み／読み出しのトランザクション処理を実行する．ルートエンティティを定義づける時の注意点として，集約の単位が大き過ぎると，一部分のエンティティのみトランザクションの対象とすれば良い処理であるのにも関わらず，ルートエンティティ全体まで対象としなければならなくなる．そのため，ビジネスロジックとしてのまとまりと，トランザクションとしてのまとまりの両方から，ルートエンティティの単位を定義づけるとよい．

<br>

## 06. インフラストラクチャ層

### インフラストラクチャ層の依存性逆転

#### ・DIP（依存性逆転の原則）とは

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_object_orientation_class.html

#### ・依存性を逆転させる方法

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_object_orientation_class.html

![ドメイン駆動設計_逆転依存性の原則](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ドメイン駆動設計_依存性逆転の原則.jpg)

<br>

### リポジトリ（実装クラス）

#### ・リポジトリ（実装クラス）とは

責務として，DBに対してデータの書き込み／読み出しのトランザクション処理を実行する．トランザクションはルートエンティティを単位として構成する必要があるため，リポジトリも同じくルートエンティティを単位として定義づけることになる．ルートエンティティとトランザクションの関係性については，前述の説明を参考にせよ．

#### ・DBに対する書き込み責務（Create，Update，Delete）

![ドメイン駆動設計_リポジトリ_データ更新](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ドメイン駆動設計_リポジトリ_データ更新.png)

DBに対する書き込み操作を行う．

1. GET／POSTによって，ユースケース層から値が送信される．

2. ファクトリによって，送信された値からエンティティや値オブジェクトを構成する．さらに，それらから集約を構成する．

3. リポジトリによって，最終的な集約を構成する．

4. リポジトリによって，集約を連想配列に分解する．

5. ```add()```によって，リポジトリのデータに，集約を格納する．

6. ```store()```によって，Transactionクラスのデータに，リポジトリを格納する．

7. DBに対して，書き込みを行う．


参考：

https://www.doctrine-project.org/projects/doctrine-orm/en/2.8/reference/query-builder.html

https://github.com/doctrine/dbal/blob/2.12.x/lib/Doctrine/DBAL/Query/QueryBuilder.php

**＊実装例＊**

CREATE処理のため，DoctrineのQueryBuilderクラスの```insert```メソッドを実行する．

```php
<?php
    
namespace App\Infrastructure\Repositories;    
    
use App\Domain\Entity\DogToy;
use Doctrine\DBAL\Query\QueryBuilder;

/**
 * 犬用おもちゃリポジトリ
 */
class DogToyRepository
{
    /**
     * ルートエンティティを書き込みます．
     */
    public function create(DogToy $dogToy)
    {
        // クエリビルダ生成
        $query = $this->createQueryBuilder();
        
        // SQLを定義する．
        $query->insert("dog_toy_table")
            ->values([
                // ルートエンティティの要素をカラム値として設定する．（IDはAutoIncrement）
                "name"  => $dogToy->getName()->value(),
                "type"  => $dogToy->getType()->value(),
                "price" => $dogToy->getPriceVO()->value(),
                "color" => $dogToy->getColorVO()->value(),
        ]);
    }
}
```

UPDATE処理のため，DoctrineのQueryBuilderクラスの```update```メソッドを実行する．

```php
<?php

namespace App\Infrastructure\Repositories;

use App\Domain\Entity\DogToy;
use Doctrine\DBAL\Query\QueryBuilder;

/**
 * 犬用おもちゃリポジトリ
 */
class DogToyRepository
{
    /**
     * ルートエンティティを書き込みます．
     */
    public function create(DogToy $dogToy)
    {
        // クエリビルダ生成
        $query = $this->createQueryBuilder();
        
        // SQLを定義する．
        $query->update("dog_toy_table", "dog_toy")
            // ルートエンティティの要素をカラム値として設定する．
            ->set("dog_toy.name", $dogToy->getName()->value())
            ->set("dog_toy.type", $dogToy->getType()->value())
            ->set("dog_toy.price", $dogToy->getPriceVO()->value())
            ->set("dog_toy.color", $dogToy->getColorVO()->value())
            ->where("dog_toy.id", $dogToy->getId()->value();
    }
}
```

DELETE処理（論理削除）のため，DoctrineのQueryBuilderクラスの```update```メソッドを実行する．

```php
<?php

namespace App\Infrastructure\Repositories;    

use App\Constants\FlagConstant;
use App\Domain\Entity\DogToy;
use Doctrine\DBAL\Query\QueryBuilder;

/**
 * 犬用おもちゃリポジトリ
 */
class DogToyRepository
{
    /**
     * ルート Entityを書き込みます．
     */
    public function create(DogToy $dogToy)
    {
        // クエリビルダ生成
        $query = $this->createQueryBuilder();
        
        // SQLを定義する．
        $query->update("dog_toy_table", "dog_toy")
            // 論理削除
            ->set("dog_toy.is_deleted", FlagConstant::IS_ON)
            ->where("dog_toy.id", $dogToy->getId()->value();
    }
}
```

#### ・DBに対する読み出し責務（Read）

![ドメイン駆動設計_リポジトリ_データ取得](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ドメイン駆動設計_リポジトリ_データ取得.jpg)

DBに対する書き込み操作を行う．

1. ユースケース層から集約がリクエストされる．
2. DBに対して，読み出しを行う．
3. ファクトリによって，送信された値からエンティティや値オブジェクトを構成する．さらに，それらから集約を構成する．
4. リポジトリによって，最終的な集約を構成する．
5. 再構成された集約をユースケース層にレスポンス．

参考：

https://www.doctrine-project.org/projects/doctrine-orm/en/2.8/reference/query-builder.html

https://github.com/doctrine/dbal/blob/2.12.x/lib/Doctrine/DBAL/Query/QueryBuilder.php

**＊実装例＊**

READ処理のため，DoctrineのQueryBuilderクラスの```select```メソッドを実行する．

```php
<?php
    
namespace App\Infrastructure\Repositories;

use App\Constants\FlagConstant;
use App\Domain\Entity\DogToy;
use Doctrine\DBAL\Query\QueryBuilder;

/**
 * 犬用おもちゃリポジトリ
 */
class DogToyRepository
{   
     /**
     * ルートエンティティのセットを生成します．
     */
    public function findAllDogToys(): array
    {
        $dogToys = [];
        
        foreach($this->fetchAllDogToy() as $fetched){
            $dogToys[] = $this->aggregateDogToy($fetched);
        }
        
        return $dogToys;
    }
    
    /**
    * Entityを全て読み出します．
    */
    private function fetchAllDogToy(): array
    {
        // クエリビルダ生成
        $query = $this->createQueryBuilder();
        
        // SQLを設定する．
        $query->select(
            "dog_toy.id    AS dog_toy_id",
            "dog_toy.name  AS dog_toy_name",
            "dog_toy.type  AS dog_toy_type",
            "dog_toy.price AS dog_toy_price",
            "dog_toy.color AS dog_toy_color"
        )
        ->from("dog_toy_table", "dog_toy")
        // 論理削除されていないもののみ
        ->where("dog_toy.is_deleted", FlagConstant::IS_OFF)
        ->getQuery();    
        
        // SQLを実行する．
        $query->getResult();
    }

    /**
     * ルートエンティティを生成します．
     */
    private function aggregateDogToy(array $fetched): DogToy
    {
        $dogToy = new DogToy(
            $fetched["dog_toy_id"],
            $fetched["dog_toy_name"],
            $fetched["dog_toy_type"],
            new PriceVO($fetched["dog_toy_price"],
            new ColorVO($fetched["dog_toy_color"]
        );
        
        return $dogToy;
    }
}
```

<br>

### ファクトリ

#### ・責務

責務として，新たな集約の構成や，既存の集約の再構成を実行する．

**＊実装例＊**

```php
<?php
    
namespace App\Infrastructure\Factories;

use App\Domain\Entity\DogToy;
use App\Domain\Entity\DogFood;
use App\Domain\Entity\DogCombo;

/**
 * 犬用コンボファクトリ
 */
class DogComboFactory
{   
    /**
     * 新たな集約を構成します．
     */
    public static function createDogCombo($data): DogItem
    {
        return new DogCombo(
            new DogToy(
                $data["dog_toy_id"],
                $data["dog_toy_name"],
                $data["dog_toy_type"],
                $data["dog_toy_price"],
                $data["dog_toy_color"],
            ),
            new DogFood(
                $data["dog_food_id"],
                $data["dog_food_name"],
                $data["dog_food_type"],
                $data["dog_food_price"],
                $data["dog_food_flavor"],
            )
        );
    } 
}
```

<br>

### インフラストラクチャサービス

#### ・インフラストラクチャサービスとは

インフラストラクチャ層の中で，汎用的なロジックが切り分けられたもの．また，ロギングやファイル出力のロジックもこの層に配置する．リポジトリと同様にして，ドメイン層にインターフェースを設け，依存性逆転の原則を満たせるようにする．

<br>

## 07. アーキテクチャにおける層別の例外スロー

### スローされた例外の扱い

各層では例外をスローするだけに留まり，スローされた例外を対処する責務は，より上層に持たせる．より上層では，その層に合った例外に詰め替えて，これをスローする．最終的には，ユーザーインターフェース層まで持ち上げ，画面上のポップアップで警告文としてこれを表示する．例外スローの意義については，以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_logic_catch_error_throw_exception_logging.html

<br>

### プレゼンテーション層

#### ・例外

```php
final class PresentationException extends Exception
{
    
}
```

<br>

### ユースケース層

#### ・例外

```php
final class UseCaseException extends Exception
{
    
}
```

<br>

### ドメイン層

#### ・例外

```php
final class DomainException extends Exception
{
    
}
```

<br>

### インフラストラクチャ層

#### ・例外

```php
final class InfrastructureException extends Exception
{
    
}
```

