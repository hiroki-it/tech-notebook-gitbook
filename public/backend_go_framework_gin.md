# Gin

## Context

### Bind

リクエストメッセージからデータを取得し，構造体に関連づける．Cotent-TypeヘッダーのMIMEタイプに応じて，バインド関数をコールし分ける．

参考：https://pkg.go.dev/github.com/gin-gonic/gin?utm_source=godoc#Context.Bind

<br>

### BindJSON

Content-TypeヘッダーのMIMEタイプが```application/json```であることが前提である．リクエストメッセージからJSONデータを取得し，構造体に関連づける．

参考：https://pkg.go.dev/github.com/gin-gonic/gin?utm_source=godoc#Context.BindJSON

<br>

### BindQuery

クエリパラメータからデータを取得し，構造体に関連づける．

<br>

### Get

同一のリクエストにて```Set```関数でセットされたマップ型データから，値を取得する．値が存在しない場合は，第二返却値で```false```を返却する．

参考：https://pkg.go.dev/github.com/gin-gonic/gin#Context.Get

<br>

### ShouldBindQuery（= ShouldBindWith）

クエリパラメータからデータを取得し，指定したバインディングツールを使用して，構造体に関連づける．

<br>

### JSON

JSONデータとして，レスポンスを返信する．第二引数の引数型がインターフェースになっているため，様々なデータ型を渡せる．

 **＊実装例＊**

マップ型データを渡す．

```go
c.JSON(200, gin.H{
    "id": 1,
    "name": "hiroki hasegawa",
})
```

構造体型データを渡す．

```go
type Foo struct {
	id int json:"id"
	name string json:"name"
}

c.JSON(200, &Foo{
    id: 1,
    name: "hiroki hasegawa",
})
```



<br>

### MustGet

同一のリクエストにて```Set```関数でセットされたマップ型データから，値を取得する．値が存在しない場合は，ランタイムエラーとなる．

参考：https://pkg.go.dev/github.com/gin-gonic/gin#Context.MustGet

<br>

### Param

クエリパラメータからデータを取得する．この後，構造体に関連づける場合は，```BindQuery```関数を使用した方が良い．

<br>

### Set

当該のリクエストで利用できるマップ型データに，値を保存する．

参考：https://pkg.go.dev/github.com/gin-gonic/gin#Context.Set

<br>

## Util

### H

マップ型の変数のエイリアスとして働く．

```go
type H map[string]interface{}
```

```go
c.JSON(200, gin.H{
    "id": 1,
    "name": "hiroki hasegawa",
})
```

```go
c.JSON(400, gin.H{
    "errors": []string{
        "Fooエラーメッセージ",
        "Barエラーメッセージ",
    }
})
```

<br>

## Validator

### tag

#### ・binding

バリデーションのルールを定義する．標準のルールの一覧は，以下のリンクを参考にせよ．

参考：https://github.com/go-playground/validator/blob/65bb1236771df9bc1630c78a43b0bfea10fe7122/baked_in.go#L70





