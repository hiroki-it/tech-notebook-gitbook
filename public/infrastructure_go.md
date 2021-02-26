# Go

## Goとは

手続き型言語．構造体と関数を組み合わせて処理を実装する．言語としてオブジェクトという機能を持っていないが，構造体に関数を関連付けることで，擬似的にオブジェクトを表現することもできる．

<br>

## 組み込み型

### 独自データ型

#### ・定義

type宣言を使用して，組み込み型，パッケージの型，を元に独自データ型を定義する．

**＊実装例＊**

組み込み型のintを元に，Age型を定義する．

```go
type Age int
```

**＊実装例＊**

パッケージの型を元に，MyAppWriterを定義する．

```go
type MyAppWriter io.Writer
```

<br>

## 型リテラル

### struct（構造体）

#### ・定義

type宣言を使用して，struct型（構造体型）から独自の構造体を定義する．

**＊実装例＊**

```go
type Person struct {
    Name string
}
```

#### ・初期化

構造体を初期化する．いくつか記法があり，タグ付きリテラルが推奨される．まずは，タグ付きリテラル表記．

**＊実装例＊**

```go
package main
import "fmt"

type Person struct {
    Name string
}

func main () {
    
    // タグ付きリテラル表記
    person := Person {Name: "Hiroki"}
    
    fmt.Println(person.Name)
}
```

二つ目に，タグ無しリテラル表記．

**＊実装例＊**

```go
package main
import "fmt"

type Person struct {
    Name string
}

func main () {
    
    // タグ無しリテラル表記
    person := Person {"Hiroki"}
    
    fmt.Println(person.Name)
}
```

三つ目に，```new```関数を使用した初期化．

**＊実装例＊**

```go
package main
import "fmt"

type Person struct {
    Name string
}

func main(){
    
    // new関数を使用
    person := new(Person)
    person.Name = "Hiroki"
    fmt.Println(person.Name)
}
```

<br>

## 関数

### main関数

#### ・```main```関数

goのエントリポイントとなる．goのプログラムが起動したときに，各パッケージの```init```関数が実行された後，```main```関数が実行される．

**＊実装例＊**

```go
package main
import "fmt"

func main(){
    fmt.Println("Hello World!!")
}
```

当然，```main```パッケージや```main```関数が無いと，goのプログラムの起動時にエラーが発生する．

```sh
$ go run server.go

go run: cannot run non-main package
```

```sh
$ go run server.go

# command-line-arguments
runtime.main: call to external function main.main
runtime.main: main.main: not defined
runtime.main: undefined: main.main
```

<br>

### 独自関数

#### ・関数とは

構造体に関連付けられていない関数のこと．

**＊実装例＊**

```go
package main
import "fmt"

func example(word string) string {
    fmt.Println(word)
}

func main(){
    example("Hello World!!")
}
```

#### ・Closure（無名関数）とは

名前のない関数のこと．

#### ・即時関数とは

定義したその場でコールされる無名関数のこと．

**＊実装例＊**

main関数で即時関数を実行する．

```go 
package main
import "fmt"

func main() {
    
    result := func() string {
        return "Closure is working!!"
    }()
    
    fmt.Println(result)
}
```

**＊実装例＊**

即時関数に引数を設定できる．その場合，仮引数と引数の両方を設定する必要がある．

```go
package main
import "fmt"

func main() {

    // 仮引数を設定
    result := func(word string) string {
        
        return word
        
    // 引数に値を渡す
    }("Closure is working!!")
    
    fmt.Println(result)
}
```

<br>

### メソッド

#### ・メソッドとは

データ型や型リテラルに関連付けられている関数のこと．

#### ・レシーバによる関連付け

データ型や型リテラルなどを関数のレシーバとして渡すことによって，それに関数を関連づけられる．関連付け後，関数はメソッドと呼ばれるようになる．

**＊実装例＊**

int型を値レシーバとして渡し，構造体に関数を関連付ける．

```go
package main
import "fmt"

type Age int

func (age Age) printAge() string {
    return fmt.Sprintf("%dです．", age)
}

func main () {
    var age Age = 20
    fmt.Println(age.printAge())
}
```

**＊実装例＊**

構造体を値レシーバとして渡し，構造体に関数を関連付ける．

```go
package main
import "fmt"

// 構造体を定義
type Person struct {
    Name string
}

// 構造体に関数を関連付ける．
func (person Person) GetName() string {
    return person.Name
}

// 構造体から関数をコール
func main () {
    
    // 構造体を初期化
    person := Person {Name: "Hiroki"}
    
    fmt.Println(person.GetName()) // Hiroki
}
```

#### ・値レシーバ

レシーバとして渡された引数をメソッド内でコピーしてから使用する．構造体をイミュータブルにしたい場合は，値レシーバを使うと良い．関連付け後，関数はメソッドと呼ばれるようになる．

**＊実装例＊**

構造体を値レシーバとして渡し，構造体に関数を関連付ける．

```go
package main
import "fmt"

type Person struct {
	Name string
}

// 値レシーバ
func (person Person) SetName(name string) {
    // 引数の構造体をコピーしてから使用
	person.Name = name
}

func (person Person) GetName() string {
    return person.Name
}

func main() {

	person := Person{Name: "Gopher"}

	person.SetName("Hiroki")
    fmt.Println(person.GetName()) // Gopher
}
```

#### ・ポインタレシーバ

レシーバとして渡された引数をメソッド内でそのまま使用する．構造体をミュータブルにしたい場合は，ポインタレシーバを使うと良い．

**＊実装例＊**

```go
package main
import "fmt"

type Person struct {
	Name string
}

// ポインタレシーバ
func (person *Person) SetName(name string) {
    // 引数の構造体をそのまま使用
	person.Name = name
}

func (person *Person) GetName() string {
    return person.Name
}

func main() {

	person := Person{Name: "Gopher"}

	person.SetName("Hiroki")
	fmt.Println(person.GetName()) // Hiroki
}
```

<br>

## 変数

### 定義

#### ・明示的な定義

**＊実装例＊**

```go
// 一つの変数を定義
var number int
number = 5

// 複数の変数を定義
var x, y, z int
x, y, z = 1, 3, 5
```

#### ・暗黙的な定義（型推論）

**＊実装例＊**

```go
// データ型が自動的に認識される
w := 1
x := true
y := 3.14
z := "abc"

var w = 1

var (
    x = true
    y = 3.14
    z = "abc"
)
```

<br>

### 変数展開

<br>

## 標準パッケージ

### bytes

#### ・```Buffer```メソッド

渡された文字列を結合する．

**＊実装例＊**

```go
package main

import (
    "bytes"
    "fmt"
)

func main() {
    var buffer bytes.Buffer

    buffer.WriteString("Hello ")
    buffer.WriteString("World!!")

    fmt.Println(buffer.String()) // Hello World!! 
}
```

<br>

### strings

#### ・```Builder```メソッド

渡された文字列を結合する．

**＊実装例＊**

```go
package main

import (
    "fmt"
    "strings"
)

func main() {
    var builder strings.Builder
    
    builder.WriteString("Hello ")
    builder.WriteString("World!!")
    
    fmt.Println(builder.String()) // Hello World!! 
}
```

<br>

### fmt

<br>





