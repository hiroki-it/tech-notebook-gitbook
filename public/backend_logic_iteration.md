

# 繰り返しロジック

## 01. foreach

### 文法

#### ・基本

![流れ図_foreach文](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/流れ図_foreach文.png)

```PHP
<?php
    
$a = [1, -1, 2];
$sum = 0;

foreach ($a as $x) {
    if ($x > 0) {
        $sum += $x;
    }
}
```

#### ・```continue```

配列の走査が特定の条件に当てはまったときに，この走査をスキップする．

<br>

### 走査（スキャン）

#### ・走査とは

配列内の要素を順に調べていくことを『走査（スキャン）』という．例えば，```foreach```は，配列内の全ての要素を走査する処理である．下図では，連想配列が表現されている．

![配列の走査](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/配列の走査.png)

#### ・内部ポインタと配列の関係

『内部ポインタ』とは，PHPの配列において，参照したい要素を位置で指定するためのカーソルのこと．Goにおけるポインタは，以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook_gitbook/public/infrastructure_go.html

**＊実装例＊**

```php
<?php
    
$array = array("あ", "い", "う");

// 内部ポインタが現在指定している要素を出力．
echo current($array); // あ

// 内部ポインタを一つ進め，要素を出力．
echo next($array); // い

// 内部ポインタを一つ戻し，要素を出力．
echo prev($array); // あ

// 内部ポインタを最後まで進め，要素を出力．
echo end($array); // う

// 内部ポインタを最初まで戻し，要素を出力
echo reset($array); // あ
```

#### ・配列の値へのアクセス

単に配列を作るだけでなく，要素にアクセスするためにも使われる．

```PHP
<?php

class Example
{
     /**
     * オプションを調べて，文字列を返却します．
     */
    public function printOption(array $options)
    {
        $result = "何も設定されていません．"
        
        // $options配列には，OptionA,B,Cエンティティのいずれかが格納されていると想定
        foreach ($options as $option) {
            
            if ($option->name() == "オプションA") {
                $result = "オプションAが設定されています．";
            }
            
            if ($option->name() == "オプションB") {
                $result = 'オプションBが設定されています．';
            }
            
            if ($option->name() == "オプションC") {
                $result = "オプションCが設定されています．";
            }
            
            return $result;
        }
        
        return $result;
    }
}
```

#### ・配列の値を加算代入

```php
<?php

// 以下の引数が渡されると想定
// ($K, $A) = (4, [1, 2, 3, 4, 1, 1, 3])
    
function iteration($K, $A)
{
    $topesNumber = 0;

    $currentLength = 0;

    for ($i = 0; $i < count($A); $i++) {
        
        // 前回の走査に今回のものを加算する．
        $currentLength += $A[$i];

        if ($currentLength >= $K) {
            // 加算代入
            $topesNumber++;

            // 長さを元に戻す．
            $currentLength = 0;
        }
    }
}

```

#### ・配列の値を固定

```php
<?php
    
// 以下の引数が渡されると想定
// ($M, $A) = (6, [3, 4, 5, 5, 2])
    
function iteration($M, $A) {

    $count = 0;
    
    foreach ($A as $key => $value) {
        
        // vを固定して，以降のvと比較する．
        for ($i = $key; $i < count($A); $i++) {
            if($value <= $A[$i]){
                // 加算代入
                $count++;
            }
        }
    }
    
    return $count;
}
```



<br>

### 多次元配列の走査

#### ・二次元配列を一次元配列に変換

コールバック関数の使用が必要になる．```call_user_func_array```メソッドの第一引数に，コールバック関数の```array_merge```メソッドの文字列を渡し，第二引数に二次元配列を渡す．その結果，平坦になって一次元配列になる．例えば，不要なインデックス（0）で入れ子になっている場合に役に立つ．

```PHP
<?php
    
$twoDimension = [
  [
    "date"  => "2015/11/1",
    "score" => 100,
    "color" => "red",
  ],
  [
    "date"  => "2015/11/2",
    "score" => 75,
    "color" => "blue",
  ]
];

$oneDimension = call_user_func_array(
  'array_merge',
  // 二次元配列
  $twoDimension
);
```

#### ・多次元配列でキー名から値を取得

例えば，以下のような多次元配列があったとする．

```PHP
<?php
    
$twoDimension = [
  [
    "date"  => "2015/11/1",
    "score" => 100,
    "color" => "red",
  ],
  [
    "date"  => "2015/11/2",
    "score" => 75,
    "color" => "blue",
  ]
];

// この配列のscoreキーから値を取り出し，一次元配列を生成する．
$oneDimension = array_column($twoDimension, "score");

// Array
// (
//     [0] => 100
//     [1] => 75
// )
```

<br>

## 02. while

### 文法

#### ・基本

![流れ図_while文](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/流れ図_while文.png)

```PHP
<?php
    
$a = [1, -1, 2];
$sum = 0;

// 反復数の初期値
$i = 0;

while ($i < 2) {
    $x = $a[$i];
    if ($x > 0) {
        $sum += $x;
    }
    $i += 1;
}
```

#### ・```break```

<br>

### 無限ループ

#### ・無限ループとは

反復処理では，何らかの状態になった時に反復処理を終えなければならない．しかし，終えることができないと，無限ループが発生してしまう．

<br>

## 03. for

### 文法

#### ・基本

![流れ図_for文](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/流れ図_for文.png)

```PHP
<?php
    
$a = [1, -1, 2];
$sum = 0;

for ($i = 0; $i < 2; $i++) {
    $x = $a[$i];
    if ($x > 0) {
        $sum += $x;
    }
}
```

