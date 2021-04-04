# テスト

## 01. テスト全体の手順

### テスティングフレームワークによるテスト

1. テスティングフレームワークによる，静的解析を行う．
2. テスティングフレームワークによる，ユニットテストと機能テストを行う．

### テスト仕様書に基づくテスト

1. テスト仕様書に基づく，ユニットテスト，Integrationテスト，User Acceptanceテストを行う．
2. グラフによるテストの可視化

<br>

## 02.  モックオブジェクトとスタブ

### モックオブジェクトとは

コードにおいては，テスト対象のクラス以外のクラスやメソッドの詳細な処理は実装しない．クラスの一部または全体を，処理を持たないモックオブジェクトに置き換える．

<br>

### スタブとは

ユニットテストのように，特に一連の処理の一部分だけを検証するために頻繁に用いる．ただし，機能テストで用いることもある．ユニットテストと機能テストについては，以降の説明を参考にせよ．一連の処理の中で，テスト対象の処理以外の部分に実体があるように仮定したスタブとして定義しておく．これにより，テスト対象の処理のみが実体であっても一連の処理を再現できる．```verify```メソッドの実装例も参考にせよ．

<br>

### Phake

#### ・Phakeとは

モックオブジェクトとスタブを簡単に実装するライブラリ．

参考：https://github.com/mlively/Phake#phake

#### ・```mock```メソッド

クラス名（名前空間）を元に，モックオブジェクトを生成する．

```php
<?php

// クラスの名前空間を引数として渡す．
$mock = Phake::mock(Example::class);
```

#### ・```when```メソッド

モックオブジェクトに対して，スタブを生成する．

**＊実装例＊**

 モックオブジェクト（```mock```変数）に対して，```method```メソッドを定義する．これに```param```変数が渡された時に，空配列を返却する．

```php
<?php

\Phake::when($mock)
    ->method($param)
    ->thenReturn([]);
```

#### ・```verify```メソッド

メソッドがn回実行できたことを検証できる．一連の処理の中で最後に実行されるメソッドのスタブを対象とすることが多い．

**＊実装例＊**

一連の処理の中で，QueryObjectクラスが正しく初期化されるかを検証する．そのため，QueryObjectクラスは実体を用意する．それ以外の処理はスタブで定義する．実際はもう少し複雑な処理を検証するが，例のため簡単な処理をテストしている．

```php
<?php

class QueryObjectTest extends \PHPUnit_Framework_TestCase
{   
   /**
    * @test
    */    
    public function testNewQueryObject()
    {    
        // 対象以外の処理をモックオブジェクトとして定義する．
        $mock = Phake::mock(Example::class);
        
        // テストしたい処理
        $queryObject = new QueryObject();

        // モックオブジェクトに対してスタブを定義する．
        \Phake::when($mock)
            ->find($queryObject)
            ->thenReturn([]);

        // findメソッドを1回実行できたことを検証する．
        Phake::verify($mock, Phake::times(1))->find($queryObject);
    }
}
```

<br>

## 03. PHPUnit

### コマンド

#### ・事前準備

PHPunitの設定は，```phpunit.xml```ファイルで定義されている．標準の設定では，あらかじめルートディレクトリに```tests```ディレクトリを配置し，これを```Units```ディレクトリまたは```Feature```ディレクトリに分割しておく．また，```Test```で終わるphpファイルを作成しておく必要がある．テストのディレクトリ名やファイル名を追加変更したい場合は，```phpunit.xml```ファイルの```testsuites```タグを変更する．

```xml
<phpunit>
    
...
    
    <testsuites>
        <testsuite name="Unit">
            <directory suffix="Test.php">./tests/Unit</directory>
        </testsuite>
 
        <testsuite name="Feature">
            <directory suffix="Test.php">./tests/Feature</directory>
        </testsuite>
    </testsuites>
    
...
    
</phpunit>
```

#### ・オプション無し

全てのテストファイルに定義されたメソッドを実行する．

```shell
$ vendor/bin/phpunit
PHPUnit 9.5.0 by Sebastian Bergmann and contributors.

...                                                   3 / 3 (100%)
 
Time: 621 ms, Memory: 24.00 MB
 
OK (3 tests, 3 assertions)
```

#### ・--filter

特定のファイル名のテストファイルに定義されたメソッドを実行する．

```shell
$ vendor/bin/phpunit --filter Example
PHPUnit 9.5.0 by Sebastian Bergmann and contributors.

...                                                   1 / 1 (100%)
 
Time: 207 ms, Memory: 8.00 MB
 
OK (1 tests, 1 assertions)
```

#### ・--list-tests

テストファイルに定義されたメソッドのうち，実行されるものを一覧で表示する．

```shell
$ vendor/bin/phpunit --list-tests
PHPUnit 9.5.0 by Sebastian Bergmann and contributors.
 
Available test(s):
 - Tests\Unit\ExampleTest::testExampleMethod
 - Tests\Feature\ExampleTest::testExampleMethod
```

<br>

### ユニットテスト

#### ・ユニットテストとは

クラスやメソッドが単体で処理が正しく動作するかを検証する方法．テスト対象以外の処理はスタブとして定義する．以降のテスト例では，次のような通知クラスとメッセージクラスが前提にあるとする．

```php
<?php

use CouldNotSendMessageException;
    
class ExampleNotification
{
    private $httpClient;
        
    private $token;
    
    private $logger;
        
    public function __construct(Clinet $httpClient, string $token, LoggerInterface $logger)
    {
        $this->httpClient = $httpClient;        
        $this->token = $token;
        $this->logger = $logger;
    }
    
    public function sendMessage(ExampleMessage $exampleMessage)
    {
        if (empty($this->token)) {
            throw new CouldNotSendMessageException("API requests is required.");
        }
        
        if (empty($exampleMessage->channel_id)) {
            throw new CouldNotSendMessageException("Channnel ID is required.");
        }
        
        $json = json_encode($exampleMessage->message);
        
        try {
            $this->httpClient->request(
                "POST",
                "https://xxxxxxxx",
                [
                    "headers" => [
                        "Authorization" => $this->token,
                        "Content-Length" => strlen($json),
                        "Content-Type" => "application/json",
                    ],
                    "form_params" => [
                        "body" =>  $exampleMessage->message
                    ]
                ]
            );

        } catch (ClientException $exception) {

            $this->logger->error(sprintf(
                "ERROR: %s at %s line %s",
                $exception->getMessage(),
                $exception->getFile(),
                $exception->getLine()
            ));

            throw new CouldNotSendMessageException($exception->getMessage());
        } catch (\Exception $exception) {

            $this->logger->error(sprintf(
                "ERROR: %s at %s line %s",
                $exception->getMessage(),
                $exception->getFile(),
                $exception->getLine()
            ));

            throw new CouldNotSendMessageException($exception->getMessage());
        }
        
        return true;
    }
}
```

```php
<?php
 
class ExampleMessage
{
    private $channel_id;
    
    private $message;

    public function __construct(string $channel_id, string $message)
    {
        $this->channel_id = $channel_id;        
        $this->message = $message;
    }
}
```

#### ・正常系テスト例

メソッドのアノテーションで，```@test```を宣言する．

**＊実装例＊**

リクエストにて，チャンネルとメッセージを送信した時に，レスポンスとして```TRUE```が返信されるかを検証する．

```php
<?php

use ExampleMessage;
use ExampleNotifiation;

class ExampleNotificationTest extends \PHPUnit_Framework_TestCase
{
    private $logger;

    private $client;

    public function setUp()
    {
        // テスト対象外のクラスはモックとする．
        $this->client = \Phake::mock(Client::class);
        $this->logger = \Phake::mock(LoggerInterface::class);
    }
    
   /**
    * @test
    */
    public function testSendMessage()
    {
        $exampleNotification = new ExampleNotification(
            $this->client,
            "xxxxxxx",
            $this->logger
        );
        
        $exampleMessage = new ExampleMessage("test", "X-CHANNEL");
        
        $this->assertTrue(
            $exampleNotification->sendMessage($exampleMessage)
        );
    }
}
```

```shell
# Time: x seconds
# OK
```

#### ・異常系テスト例

メソッドのアノテーションで，```@test```と```@expectedException```を宣言する．

**＊実装例＊**

リクエストにて，メッセージのみを送信しようとした時に，例外を発生させられるかを検証する．

```php
<?php

use ExampleMessage;
use ExampleNotifiation;

class ExampleNotificationTest extends \PHPUnit_Framework_TestCase
{
    private $logger;

    private $client;

    public function setUp()
    {
        // テスト対象外のクラスはモックとする．
        $this->client = \Phake::mock(Client::class);
        $this->logger = \Phake::mock(LoggerInterface::class);
    }

   /**
    * @test
    * @expectedException
    */
    public function testCouldNotSendMessageException()
    {
        $exampleNotification = new ExampleNotification(
            $this->client,
            "xxxxxxx",
            $this->logger
        );
        
        $exampleMessage = new ExampleMessage("test", "");

        $exampleNotification->sendMessage($exampleMessage);
    }
}
```

```shell
# Time: x seconds
# OK
```

<br>

### 機能テスト

#### ・機能テストとは

アプリケーションのControllerに対してリクエストを送信し，正しくレスポンスを返信するかどうかを検証する方法．スタブを使用することは少ない．メソッドのアノテーションで，```@test```を宣言する必要がある．

**＊実装例＊**

```php
<?php

class ExampleControllerTest extends \PHPUnit_Framework_TestCase
{
   /**
    * @test
    */    
    public function testMethod()
    {
        // 何らかの検証
    }
}
```

#### ・```assert```メソッド

実際の値と期待値を比較し，結果に応じて```SUCCESS```または```FAILURES```を返却する．非staticまたはstaticとしてコールできる．

参考：https://phpunit.readthedocs.io/ja/latest/assertions.html

```php
$this->assertTrue();
```

```php
self::assertTrue()
```

#### ・テストケース例

| HTTPメソッド | 分類   | データの条件                                                 | ```assert```メソッドの検証内容例                             |
| ------------ | ------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| POST，PUT    | 正常系 | リクエストのボディにて，必須パラメータにデータが割り当てられている場合． | ・Controllerが200ステータスのレスポンスを返信すること．<br>・更新されたデータのIDが期待通りであること．<br>・レスポンスされたデータが期待通りであること． |
|              |        | リクエストのボディにて，任意パラメータにデータが割り当てられていない場合． | ・Controllerが200ステータスのレスポンスを返信すること．<br/>・更新されたデータのIDが期待通りであること．<br/>・レスポンスされたデータが期待通りであること． |
|              |        | リクエストのボディにて，空文字やnullが許可されたパラメータに，データが割り当てられていない場合． | ・Controllerが200ステータスのレスポンスを返信すること．<br/>・更新されたデータのIDが期待通りであること．<br/>・レスポンスされたデータが期待通りであること． |
|              | 異常系 | リクエストのボディにて，必須パラメータにデータが割り当てられていない場合． | ・Controllerが400ステータスのレスポンスを返信すること．<br/>・レスポンスされたデータが期待通りであること． |
|              |        | リクエストのボディにて，空文字やnullが許可されたパラメータに，空文字やnullが割り当てられている場合． | ・Controllerが400ステータスのレスポンスを返信すること．<br/>・レスポンスされたデータが期待通りであること． |
|              |        | リクエストのボディにて，パラメータのデータ型が誤っている場合． | ・Controllerが400ステータスのレスポンスを返信すること．<br/>・レスポンスされたデータが期待通りであること． |
| GET          | 正常系 | リクエストにて，パラメータにデータが割り当てられている場合． | Controllerが200ステータスのレスポンスを返信すること．        |
|              | 異常系 | リクエストのボディにて，パラメータに参照禁止のデータが割り当てられている場合（認可の失敗）． | Controllerが403ステータスのレスポンスを返信すること．        |
| DELETE       | 正常系 | リクエストのボディにて，パラメータにデータが割り当てられている場合． | ・Controllerが200ステータスのレスポンスを返信すること．<br/>・削除されたデータのIDが期待通りであること．<br/>・レスポンスされたデータが期待通りであること． |
|              | 異常系 | リクエストのボディにて，パラメータに削除禁止のデータが割り当てられている場合（認可の失敗）． | ・Controllerが400ステータスのレスポンスを返信すること．<br/>・レスポンスされたデータが期待通りであること． |
| 認証認可     | 正常系 | リクエストのヘッダーにて，認証されているトークンが割り当てられている場合（認証の成功）． | Controllerが200ステータスのレスポンスを返信すること．        |
|              | 異常系 | リクエストのヘッダーにて，認証されていないトークンが割り当てられている場合（認証の失敗）． | Controllerが401ステータスのレスポンスを返信すること．        |
|              |        | リクエストのボディにて，パラメータにアクセス禁止のデータが割り当てられている場合（認可の失敗）． | Controllerが403ステータスのレスポンスを返信すること．        |

#### ・正常系GET

Controllerが200ステータスのレスポンスを返信することを検証する．

**＊実装例＊**

```php
<?php
    
use GuzzleHttp\Client;    

class ExampleControllerTest extends \PHPUnit_Framework_TestCase
{
   /**
    * @test
    */    
    public function testGetPage()
    {
        // 外部サービスがクライアントの場合はモックを使用する．
        $client = new Client();

        // GETリクエスト
        $client->request(
            "GET",
            "/xxx/yyy/"
        );
        
        $response = $client->getResponse();

        // 200ステータスが返却されるかを検証する．
        $this->assertSame(200, $response->getStatusCode());
    }
}
```

#### ・正常系POST

Controllerが200ステータスのレスポンスを返信すること，更新されたデータのIDが期待通りであること，レスポンスされたデータが期待通りであることを検証する．

**＊実装例＊**

```php
<?php

use GuzzleHttp\Client;

class ExampleControllerTest extends \PHPUnit_Framework_TestCase
{
    /**
     * @test
     */
    public function testPostMessage()
    {      
        $client = new Client();

        // APIにPOSTリクエスト
        $client->request(
            "POST",
            "/xxx/yyy/",
            [
                "id"      => 1,
                "message" => "Hello World!"
            ],
            [
                "HTTP_X_API_Token" => "Bearer xxxxxx"
            ]
        );

        $response = $client->getResponse();

        // 200ステータスが返却されるかを検証する．
        $this->assertSame(200, $response->getStatusCode());

        // レスポンスデータを抽出する．
        $actual = json_decode($response->getContent(), true);

        // 更新されたデータのIDが正しいかを検証する．
        $this->assertSame(1, $actual["id"]);

        // レスポンスされたメッセージが正しいかを検証する．
        $this->assertSame(
            [
                "データを変更しました．"
            ],
            $actual["message"]
        );
    }
}
```

#### ・異常系POST

Controllerが400ステータスのレスポンスを返信すること，レスポンスされたデータが期待通りであること，を検証する．

**＊実装例＊**

```php
<?php

use GuzzleHttp\Client;

class ExampleControllerTest extends \PHPUnit_Framework_TestCase
{
    /**
     * @test
     */
    public function testErrorPostMessage()
    {     
        $client = new Client();

        // APIにPOSTリクエスト
        $client->request(
            "POST",
            "/xxx/yyy/",
            [
                "id"      => 1,
                "message" => ""
            ],
            [
                "HTTP_X_API_Token" => "Bearer xxxxxx"
            ]
        );

        $response = $client->getResponse();

        // 400ステータスが返却されるかを検証する．
        $this->assertSame(400, $response->getStatusCode());

        // レスポンスデータのエラーを抽出する．
        $actual = json_decode($response->getContent(), true);

        // レスポンスされたエラーメッセージが正しいかを検証する．
        $this->assertSame(
            [
                "IDは必ず入力してください．",
                "メッセージは必ず入力してください．"
            ],
            $actual["errors"]
        );
    }
}
```

<br>

### テストデータ

#### ・Data Provider

メソッドのアノテーションで，```@test```と```@dataProvider データプロバイダ名```を宣言する．データプロバイダの返却値として配列を設定し，配列の値の順番で，引数に値を渡すことができる．

```php
<?php

class ExampleControllerTest
{
    /* @test
     * @dataProvider provideData
     */
    public function testMethod($paramA, $paramB, $paramC)
    {
        // 何らかの処理 
    }
    
    public function provideData(): array
    {
        return [
            // 配列データは複数あっても良い，
            ["あ", "い", "う"],
            ["1", "2", "3"]
        ];
    }
}
```

<br>

### 事前準備と後片付け

#### ・```setUp```メソッド

テストクラスの中で，自動的に一番最初にコールされるメソッドである．例えば，モックオブジェクトなどを事前に準備するために用いられる．

**＊実装例＊**

```php
<?php

class ExampleTest extends \PHPUnit_Framework_TestCase
{
    protected $example;
    
    protected function setUp()
    {
        // 基本的には，一番最初に記述する．
        parent::setUp();
        
        $this->example = Phake::mock(Example::class);
    }
}
```

#### ・```tearDown```メソッド

テストクラスの中で，自動的に一番最後にコールされるメソッドである．例えば，グローバル変数やサービスコンテナにデータを格納する場合，後のテストでもそのデータが誤って使用されてしまわないように，サービスコンテナを破棄するために用いられる．

```php
<?php

class ExampleTest extends \PHPUnit_Framework_TestCase
{
    protected $container;
    
    protected function setUp()
    {
        // DIコンテナにデータを格納する．
        $this->container["option"];
    }
    
    // メソッドの中で，最後に自動実行される．
    protected function tearDown()
    {
        // 次に，DIコンテナにデータを格納する．
        $this->container = null;
    }
}
```

<br>

## 04. テスト仕様書に基づくユニットテスト

PHPUnitでのユニットテストとは意味合いが異なるので注意．

### ブラックボックステスト

実装内容は気にせず，入力に対して，適切な出力が行われているかを検証する．

![p492-1](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p492-1.jpg)

<br>

### ホワイトボックステスト

実装内容が適切かを確認しながら，入力に対して，適切な出力が行われているかを検証する．ホワイトボックステストには，以下の方法がある．何を検証するかに着目すれば，思い出しやすい．

![p492-2](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p492-2.jpg)

**＊実装例＊**

```php
if (A = 1 && B = 1) {
　return X;
}
```

上記のif文におけるテストとして，以下の４つの方法が考えられる．基本的には，複数条件網羅が用いられる．

#### ・命令網羅（『全ての処理』が実行されるかをテスト）

![p494-1](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p494-1.png)

全ての命令が実行されるかをテスト（ここでは処理は1つ）．

すなわち…

A = 1，B = 1 の時，```return X``` が実行されること．

#### ・判定条件網羅（『全ての判定』が実行されるかをテスト）

![p494-2](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p494-2.png)

全ての判定が実行されるかをテスト（ここでは判定は```TRUE```か```FALSE```の2つ）．

すなわち…

A = 1，B = 1 の時，```return X``` が実行されること．
A = 1，B = 0 の時，```return X``` が実行されないこと．

#### ・条件網羅（『各条件の取り得る全ての値』が実行されるかをテスト）

![p494-3](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p494-3.png)

各条件が，取り得る全ての値で実行されるかをテスト（ここでは，Aが0と1，Bが0と1になる組み合わせなので，2つ）

すなわち…

A = 1，B = 0 の時，```return X``` が実行されないこと．
A = 0，B = 1 の時，```return X``` が実行されないこと．

または，次の組み合わせでもよい．

A = 1，B = 1 の時，```return X``` が実行されること．
A = 0，B = 0 の時，```return X``` が実行されないこと．

#### ・複数条件網羅（『各条件が取り得る全ての値』，かつ『全ての組み合わせ』が実行されるかをテスト）

![p494-4](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p494-4.png)

各条件が，取り得る全ての値で，かつ全ての組み合わせが実行されるかをテスト（ここでは4つ）

すなわち…

A = 1，B = 1 の時，```return X``` が実行されること．
A = 1，B = 0 の時，```return X``` が実行されないこと．
A = 0，B = 1 の時，```return X``` が実行されないこと．
A = 0，B = 0 の時，```return X``` が実行されないこと．

 <br>

## 04-02. テスト仕様書に基づく結合テスト

単体テストの次に行うテスト．複数のモジュールを繋げ，モジュール間のインターフェイスが適切に動いているかを検証．

![結合テスト](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p491-1.jpg)

### Top-downテスト

上位のモジュールから下位のモジュールに向かって，結合テストを行う場合，下位には Stub と呼ばれるダミーモジュールを作成する．

![トップダウンテスト](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/トップダウンテスト.jpg)

<br>

### Bottom-upテスト

下位のモジュールから上位のモジュールに向かって，結合テストを行う場合，上位には Driver と呼ばれるダミーモジュールを作成する．

![ボトムアップテスト](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/ボトムアップテスト.jpg)

<br>

### Scenarioテスト

実際の業務フローを参考にし，ユーザが操作する順にテストを行う．

<br>


## 04-03. テスト仕様書に基づくシステムテスト

### システムテスト

#### ・システムテストとは

結合テストの次に行うテスト．システム全体が適切に動いているかを検証する．User Acceptanceテスト，また総合テストともいう．

#### ・テストケース例

以下の操作を対象として検証するとよい．

| 大分類 | 中分類           | テスト対象の操作                                             |
| ------ | ---------------- | ------------------------------------------------------------ |
| 機能   | 正常系           | 基本操作（登録，参照，更新，削除），画面遷移，状態遷移，セキュリティ，など |
|        | 異常系           | 基本操作（登録，参照，更新，削除），など                     |
|        | 組み合わせ       | 同時操作，割り込み操作，排他制御に関わる操作，など           |
|        | 業務シナリオ     | シナリオに沿ったユーザによる一連の操作                       |
|        | 開発者シナリオ   | シナリオに沿った開発者による一連の操作（手動コマンドなど）   |
|        | 外部システム連携 | 外部のAPIとの連携処理に関わる操作                            |
| 非機能 | 負荷耐性や性能   | 各種負荷テスト（性能テスト，限界テスト，耐久テスト）         |

<br>

### 機能テスト

機能要件を満たせているかを検証する．PHPUnitでの機能テストとは意味合いが異なるので注意．

<br>

### 負荷テスト

#### ・負荷テストとは

実際の運用時に，想定したリクエスト数に耐えられるか，を検証する．また，テスト結果から，運用時の監視で参考にするための，安全範囲（青信号），危険範囲（黄色信号），限界値（赤信号），を導く必要がある．

参考：https://www.oracle.com/jp/technical-resources/article/ats-tech/tech/useful-class-8.html

#### ・負荷テストのパラメータ

| 項目       | 説明                                                         |
| ---------- | ------------------------------------------------------------ |
| スレッド数 | ユーザ数に相当する．                                         |
| ループ数   | ユーザ当たりのリクエスト送信数に相当する．                   |
| RampUp秒   | リクエストを送信する期間に相当する．長くし過ぎすると，全てのリクエスト数を送信するまでに時間がかかるようになるため，負荷が小さくなる． |

#### ・性能テスト

![スループットとレスポンスタイム](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/スループットとレスポンスタイム.png)

一定時間内に，ユーザが一連のリクエスト（例：ログイン，閲覧，登録，ログアウト）を行った時に，システムのスループットとレスポンス時間にどのような変化があるかを検証する．具体的にはテスト時に，アクセス数を段階的に増加させて，その結果をグラフ化する．グラフ結果を元に，想定されるリクエスト数が現在の性能にどの程度の負荷をかけるのかを確認し，また性能の負荷が最大になる値を導く．これらを運用時の監視の参考値にする．

#### ・限界テスト

性能の限界値に達するほどのリクエスト数が送信された時に，障害回避処理（例：アクセスが込み合っている旨のページを表示）が実行されるかを検証する．具体的にはテスト時に，障害回避処理以外の動作（エラー，間違った処理，障害回復後にも復旧できない，システムダウン）が起こらないかを確認する．

#### ・耐久テスト

長時間の大量リクエストが送信された時に，短時間では検出できないどのような問題が存在するかを検証する．具体的にはテスト時に，長時間の大量リクエストを処理させ，問題（例：微量のメモリリークが蓄積してメモリを圧迫，セッション情報が蓄積してメモリやディスクを圧迫，ログが蓄積してディスクを圧迫，ヒープやトランザクションログがCPUやI/O処理を圧迫）

<br>

### 再現テスト

#### ・再現テストとは

障害発生後の措置としてスペックを上げる場合，そのスペックが障害発生時の負荷に耐えられるかを検証する．

#### ・テストケース例

開始からピークまでに，次のようにリクエスト数が増し，障害が起こったとする．その後，データを収集した．

| 障害発生期間                            | 合計閲覧ページ数<br>```(PV数/min)``` | 平均ユーザ数<br/>```(UA数/min)``` | ユーザ当たり閲覧ページ数<br/>```(PV数/UA数)``` |
| --------------------------------------- | ------------------------------------ | --------------------------------- | ---------------------------------------------- |
| ```13:00 ~```<br> ```13:05```（開始）   | ```300```                            | ```100```                         | ```3```                                        |
| ```13:05 ~```<br> ```13:10```           | ```600```                            | ```200```                         | ```3```                                        |
| ```13:10 ~```<br> ```13:15```（ピーク） | ```900```                            | ```300```                         | ```3```                                        |

| ランキング | URL              | 割合       |
| ---------- | ---------------- | ---------- |
| 1          | ```/aaa/bbb/*``` | 40 ```%``` |
| 2          | ```/ccc/ddd/*``` | 30 ```%``` |
| 3          | ```/eee/fff/*``` | 20 ```%``` |
| 4          | ```/ggg/hhh/*``` | 10 ```%``` |

**＊テスト例＊**

ユーザ当たりの閲覧ページ数はループ数に置き換えられるので，ループ数は「```3```回」になる．障害発生期間の閲覧ページ数はスレッド数に置き換えられるので，スレッド数は「```1800```個（```300 + 600 + 900```）」になる．障害発生期間は，Ramp-Upに置き換えられるので，Ramp-Up期間は「```900```秒（```15```分間）」

| スレッド数（個） | ループ数（回） | Ramp-Up期間```(sec)``` |
| ---------------- | -------------- | ---------------------- |
| ```1800```       | ```3```        | ```900```              |

<br>

## 05. Regressionテスト（退行テスト）

システムを変更した後，他のプログラムに悪影響を与えていないかを検証．

![p496](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p496.jpg)

<br>

## 06. グラフによるテストの可視化

### バグ管理図

プロジェクトの時，残存テスト数と不良摘出数（バグ発見数）を縦軸にとり，時間を横軸にとることで，バグ管理図を作成する．それぞれの曲線の状態から，プロジェクトの進捗状況を読み取ることができる．

![品質管理図](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/品質管理図.jpg)

不良摘出実績線（信頼度成長曲線）は，プログラムの品質の状態を表し，S字型でないものはプログラムの品質が良くないことを表す．

![信頼度成長曲線の悪い例](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/信頼度成長曲線の悪い例.jpg)



