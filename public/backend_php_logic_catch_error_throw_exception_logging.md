# エラーキャッチ，例外スロー，ロギング

### エラーの種類

#### ・エラー

プログラムの実行が強制停止されるランタイムエラー，停止せずに続行される非ランタイムエラー，に分類される．

<br>

## エラーキャッチ，例外スロー，ロギングの意義

### データベースにとって

データベース更新系の処理の途中にエラーが発生すると，データベースが中途半端な更新状態になってしまう．そのため，エラーをキャッチし，これをきっかけにロールバック処理を実行する必要がある．なお，下流クラスのエラーの内容自体は握りつぶさずに，スタックトレースとして上層の上流クラスでロギングしておく．

<br>

### システム開発者にとって

エラーが画面上に返却されたとしても，これはシステム開発者にとってわかりにくい．そのため，エラーをキャッチし，システム開発者にわかる言葉に変換した例外としてスローする必要がある．なお，下流クラスのエラー自体は握りつぶさずに，スタックトレースとして上層の上流クラスでロギングしておく．

<br>

### ユーザにとって

エラーが画面上に返却されたとしても，ユーザにとっては何が起きているのかわからない．また，エラーをキャッチし，例外としてスローしたとしても，システム開発者にとっては理解できるが，ユーザにとっては理解できない．そのため，例外スローをさらに上流クラスに持ち上げ，最終的には，これをポップアップなどでわかりやすく通知する必要がある．これらは，サーバサイドのtry-catch-finally文や，フロントエンドのポップアップ処理で実現する．なお，下流クラスのエラー自体は握りつぶさずに，スタックトレースとして上層の上流クラスでロギングしておく．

<br>

## エラーキャッチ

### キャッチ方法の種類

#### ・if-throw文

特定の処理の中に，想定できる例外があり，それを例外クラスとしてするために用いる．ここでは，全ての例外クラスの親クラスである```Exception```クラスのインスタンスを投げている．

**＊実装例＊**

```php
<?php

function value(int $value) {
    
    if (empty($value)) {
        // 例外クラスを返却
        throw new Exception("Value is empty");
    }
    
    return "これは ${value} です．";
}
```

ただし，if-throwでは，都度例外を検証するがあり，様々な可能性を考慮しなければいけなくなる．

```php
<?php
    
function value() {
    
    if (...) {
        throw new ExternalApiException();
    }
    
    if (...) {
        throw new FooInvalidArgumentException();
    }
        
    return "成功です．"
}
```

#### ・try-catch-finally文とは

try-catch-finallyでは，特定の処理の中で起こる想定できない例外を捉えることができる．定義されたエラー文は，デバック画面に表示される．

**＊実装例＊**

```php
<?php

use \Exception\ExternalApiErrorException;
use \Exception\HttpRequestErrorException;

class Foo
{
    public function sendMessage(Message $message)
    {
        try {

            // ExternalApiErrorException，HttpRequestErrorException，Exceptionが起こる

        } catch (ExternalApiErrorException $exception) {

            // ExternalApiErrorExceptionが起こったときの処理

        } catch (HttpRequestErrorException $exception) {

            // HttpRequestErrorExceptionが起こったときの処理

        } catch (Exception $exception) {

            // その他（自社システムなど）のExceptionが起こっときの処理

        } finally {

            // どの例外をcatchした場合でも必ず行われる
            // try句やcatch句の返却処理や終了処理が行われる直前に実行される．

        }
    }
}

```

finally句は，try句やcatch句の返却処理が行われる直前に実行されるため，finally句では，```return```や```continue```を使用しないようにする．

```php
<?php

use Exception\ExternalApiErrorException;
use Exception\HttpRequestErrorException;

class Foo
{
    public function sendMessage(Message $message)
    {
        try {

            // （１）
            echo "Aの直前です";
            return "Aです．";
            
        } catch (ExternalApiErrorException $exception) {

            // （２）
            echo "Bの直前です";
            return "Bです．";
            
        } catch (HttpRequestErrorException $exception) {

            // （３）
            echo "Cの直前です";
            return "Cです．";
            
        } catch (Exception $exception) {

            // （４）
            echo "Dの直前です";
            return "Dです．";
            
        } finally {

            // returnやcontinueを使用しない
            echo "Eです．";

        }
    }
}
```


（１）～（４）のいずれかで返却される時，返却の直前にfinally句が実行されることがわかる．

```php
// （１）の場合
// Aの直前です．
// Eです．
// Aです．

// （２）の場合
// Bの直前です．
// Eです．
// Bです．

// （３）の場合
// Cの直前です．
// Eです．
// Cです．

// （４）の場合
// Dの直前です．
// Eです．
// Dです．
```

<br>

## 例外スロー

### 例外の種類

#### ・標準例外クラス

いずれもThrowableインターフェースを実装している．以下リンクを参考にせよ．

参考：https://www.php.net/manual/ja/reserved.exceptions.php

#### ・独自例外クラス

エラーの種類に合わせて，```Exception```クラスを継承した独自例外クラスを実装し，使い分けるとよい．

**＊実装例＊**

『Foo変数が見つからない』というエラーに対応する例外クラスを定義する．

```php
<?php

class FooNotFoundException extends Exception
{
    // 基本的に何も実装しない．
}
```

```php
<?php

use Exception\FooNotFound;

function foo(string $foo) {
    
    if (empty($foo)) {
        throw new FooNotFoundException("foo is not found.");
    }
    
    return "これは ${foo} です．";
}
```

<br>

### アーキテクチャにおける層別の例外スロー

層別の例外については，以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_architecture_domain_driven_design.html

<br>

## ロギング

### ロギング関数

#### ・```error_log```

参考：https://www.php.net/manual/ja/function.error-log.php

```php
error_log(
    "<エラーメッセージ>",
    "<メッセージの出力先（3の場合にファイル出力）>",
    "<ログファイルの場所>"
)
```

**＊実装例＊**

```php
<?php

class Notification
{
    public function sendMessage()
    {
        try {

            // 下流クラスによる例外スローを含む処理

        } catch (\exception $exception) {

            error_log(
                sprintf(
                    "ERROR: %s at %s line %s",
                    $exception->getMessage(),
                    $exception->getFile(),
                    $exception->getLine()
                ),
                3,
                __DIR__ . "/error.log"
            );
        }
    }
}
```

他に，Loggerインターフェースを使用することも多い．

参考：https://github.com/php-fig/log

```php
<?php

use Psr\Log\LoggerInterface;

class Notification
{
    private $logger;

    public function __construct(LoggerInterface $logger = null)
    {
        $this->logger = $logger;
    }

    public function sendMessage()
    {
        try {

            // 下流クラスによる例外スローを含む処理

        } catch (\exception $exception) {

            $this->logger->error(sprintf(
                "ERROR: %s at %s line %s",
                $exception->getMessage(),
                $exception->getFile(),
                $exception->getLine()
            ));
        }
    }
}
```

<br>

### ロギングの切り分け

#### ・例外スローごとのロギング

例えば，メッセージアプリのAPIに対してメッセージ生成のリクエストを送信する時，例外処理に合わせて，外部APIとの接続失敗によるエラーログを生成と，自社システムなどその他原因によるエラーログを生成を行う必要がある．

**＊実装例＊**

```php
<?php

use Exception\ExternalApiErrorException;
use Exception\HttpRequestErrorException;

class Foo
{
    public function sendMessage(Message $message)
    {
        try {

            // 外部APIのURL，送信方法，トークンなどのパラメータが存在するかを検証．
            // 外部APIのためのリクエストメッセージを生成．
            // 外部APIのURL，送信方法，トークンなどのパラメータを設定．

        } catch (\HttpRequestErrorException $exception) {
            
            // 下流クラスによる例外スローを含む処理

            // 外部APIとの接続失敗によるエラーをロギング
            $this->logger->error(sprintf(
                "ERROR: %s at %s line %s",
                $exception->getMessage(),
                $exception->getFile(),
                $exception->getLine()
            ));

        } catch (\ExternalApiErrorException $exception) {
            
            // 下流クラスによる例外スローを含む処理

            // 外部APIのシステムエラーをロギング
            $this->logger->error(sprintf(
                "ERROR: %s at %s line %s",
                $exception->getMessage(),
                $exception->getFile(),
                $exception->getLine()
            ));

        } catch (\Exception $exception) {
            
            // 下流クラスによる例外スローを含む処理

            // その他（自社システムなど）によるエラーをロギング
            $this->logger->error(sprintf(
                "ERROR: %s at %s line %s",
                $exception->getMessage(),
                $exception->getFile(),
                $exception->getLine()
            ));
        }

        // 問題なければTRUEを返却．
        return true;
    }
}
```

