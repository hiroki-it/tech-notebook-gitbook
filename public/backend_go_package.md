# Goパッケージ

## 01. ビルトインパッケージ

以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_go_logic.html

<br>

## 02. 外部パッケージ

### aws-sdk-go-v2

#### ・aws-sdk-go-v2とは

参考：https://pkg.go.dev/github.com/aws/aws-sdk-go-v2?tab=versions

#### ・aws

汎用的な関数が同梱されている．

参考：https://pkg.go.dev/github.com/aws/aws-sdk-go-v2/aws?tab=versions

ポインタ型から文字列型に変換する```ToString```関数や，反対に文字列型からポインタ型に変換する```String```関数をよく使う．

参考：

- https://pkg.go.dev/github.com/aws/aws-sdk-go-v2/aws#String
- https://pkg.go.dev/github.com/aws/aws-sdk-go-v2/aws#ToString

#### ・serviceパッケージ

参考：https://pkg.go.dev/github.com/aws/aws-sdk-go-v2/service/amplify?tab=versions

<br>

### aws-lambda-go

以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws_lambda_function.html

<br>

### validator

#### ・validatorとは

#### ・バリデーションとエラーメッセージ

```go
package validators

import (
	"fmt"

	"github.com/go-playground/validator"
)

type FoobarbazValidator struct {
	Foo string `json:"foo" validate:"required"`
	Bar string `json:"bar" validate:"required"`
	Baz string `json:"baz" validate:"required"`
}

// NewValidator コンストラクタ
func NewValidator() *Validator {

	return &Validator{}
}

// Validate バリデーションを実行します．
func (v *FoobarbazValidator) Validate() map[string]string {

	err := validator.New().Struct(v)

	var errorMessages = make(map[string]string)

	if err != nil {
		for _, err := range err.(validator.ValidationErrors) {
			switch err.Field() {
			// フィールドごとにマップ形式でバリデーションメッセージを構成します．
			case "foo":
				errorMessages["foo"] = v.stringValidation(err)
				errorMessages["foo"] = v.requiredValidation(err)
			case "bar":
				errorMessages["bar"] = v.stringValidation(err)
			case "baz":
				errorMessages["baz"] = v.stringValidation(err)
				errorMessages["baz"] = v.requiredValidation(err)
			}
		}
	}

	return errorMessages
}

// stringValidation 文字列型指定のメッセージを返却します．
func (v *FoobarbazValidator) stringValidation(err validator.FieldError) string {
	return fmt.Sprintf("%s は文字列のみ有効です", err.Field())
}

// requiredValidation 必須メッセージを返却します．
func (v *FoobarbazValidator) requiredValidation(err validator.FieldError) string {
	return fmt.Sprintf("%s は必須です", err.Field())
}
```

```go
package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/foobarbaz_repository/validators"
)

func main() {
	v := NewFoobarbazValidator()

	// JSONを構造体にマッピングします．
	err := json.Unmarshal([]byte(`{"foo": "test", "bar": "test", "baz": "test"}`), v)

	if err != nil {
		log.Println("JSONエンコードに失敗しました。")
	}

	// バリデーションを実行します．
	errorMessages := v.Validate()

	if len(errorMessages) > 0 {
		// マップをJSONに変換します．
		byteJson, _ := json.Marshal(errorMessages)
		fmt.Printf("%#v\n", byteJson)
	}

	// エンコード結果を出力します．
	fmt.Println("データに問題はありません．")
}
```

<br>

### testify

#### ・testifyとは

モック，スタブ，アサーションメソッドを提供するライブラリ．Goではオブジェクトの概念がないため，モックオブジェクトとは言わない．モックとスタブについては，以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_testing.html

#### ・モック化

| よく使うメソッド | 説明                                                         |
| ---------------- | ------------------------------------------------------------ |
| なし             | データとして，構造体に```Mock```を設定すれば，その構造体はモック化される． |

**＊実装例＊**

AWSクライアントをモック化する．

```go
package amplify

import (
	"github.com/stretchr/testify/mock"
)

/**
 * AWSクライアントをモック化します．
 */
type MockedAwsClient struct {
	mock.Mock
}
```

#### ・スタブ化

参考：https://pkg.go.dev/github.com/stretchr/testify/mock?tab=versions

| よく使うメソッド              | 説明                                                         |
| ----------------------------- | ------------------------------------------------------------ |
| ```Mock.Called```メソッド     | 関数の一部の処理をスタブ化する時に使用する．関数に値が渡されたことをモックに伝える． |
| ```Arguments.Get```メソッド   | 関数の一部の処理をスタブ化する時に使用する．引数として，返却値の順番を渡す．独自のデータ型を返却する処理を定義する． |
| ```Arguments.Error```メソッド | 関数の一部の処理をスタブ化する時に使用する．引数として，返却値の順番を渡す．エラーを返却する処理を定義する． |

**＊実装例＊**

関数の一部の処理をスタブ化し，これをAWSクライアントのモックに関連付ける．

```go
package amplify

import (
	aws_amplify "github.com/aws/aws-sdk-go-v2/service/amplify"
	"github.com/stretchr/testify/mock"
)

type MockedAmplifyAPI struct {
	mock.Mock
}

/**
 * AmplifyのGetBranch関数の処理をスタブ化します．
 */
func (mock *MockedAmplifyAPI) GetBranch(ctx context.Context, params *aws_amplify.GetBranchInput, optFns ...func(*aws_amplify.Options)) (*aws_amplify.GetBranchOutput, error) {
	arguments := mock.Called(ctx, params, optFns)
	return arguments.Get(0).(*aws_amplify.GetBranchOutput), arguments.Error(1)
}
```

#### ・アサーションメソッドによる検証

参考：

- https://pkg.go.dev/github.com/stretchr/testify/mock?tab=versions

- https://pkg.go.dev/github.com/stretchr/testify/assert?tab=versions

| よく使うメソッド                      | 説明                                                         |
| ------------------------------------- | ------------------------------------------------------------ |
| ```Mock.On```メソッド                 | 関数の検証時に使用する．関数内部のスタブに引数として渡される値と，その時の返却値を定義する． |
| ```Mock.AssertExpectations```メソッド | 関数の検証時に使用する．関数内部のスタブが正しく実行されたかどうかを検証する． |
| ```assert.Exactly```メソッド          | 関数の検証時に使用する．期待値と実際値の整合性を検証する．値だけでなく，データ型も検証できる． |

#### ・前処理と後処理

テスト関数を実行する直前に，前処理を実行する．モックの生成のために使用するとよい．PHPUnitにおける前処理と後処理については，以下のリンクを参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/backend_testing.html

前処理と後処理については，以下のリンクを参考にせよ．

参考：https://github.com/google/go-github/blob/master/github/github_test.go#L36-L66

| よく使う関数        | 実行タイミング | 説明                                                         |
| ------------------- | -------------- | ------------------------------------------------------------ |
| ```SetupSuite```    | 1              | テストスイート内の全てのテストの前処理として，一回だけ実行する． |
| ```SetupTest```     | 2              | テストスイート内の各テストの前処理として，テストの度に事前に実行する．```BeforeTest```関数よりも前に実行されることに注意する． |
| ```BeforeTest```    | 3              | テストスイート内の各テストの直前の前処理として，テストの度に事前に実行する．必ず，『```suiteName```』『```testName```』を引数として設定する必要がある． |
| ```AfterTest```     | 4              | テストスイート内の各テストの直後の後処理として，テストの度に事後に実行する．必ず，『```suiteName```』『```testName```』を引数として設定する必要がある． |
| ```TearDownTest```  | 5              | テストスイート内の各テストの後処理として，テストの度に事後に実行する．```BeforeTest```関数よりも後に実行されることに注意する． |
| ```TearDownSuite``` | 6              | テストスイート内の全てのテストの後処理として，一回だけ実行する． |

**＊実装例＊**

事前にモックを生成するために，```BeforeTest```関数を使用する．

```go
package foo

import (
	"testing"
)

/**
 * ユニットテストのテストスイートを構成する．
 */
type FooSuite struct {
	suite.Suite
	fooMock *FooMock
}

/**
 * ユニットテストの直前の前処理を実行する．
 */
func (suite *FooSuite) BeforeTest(suiteName string, testName string) {

	// モックを生成する．
	suite.fooMock = &FooMock{}
}

/**
 * ユニットテストのテストスイートを実行する．
 */
func TestFooSuite(t *testing.T) {
	suite.Run(t, &FooSuite{})
}
```

```go
package foo

import (
	"github.com/stretchr/testify/assert"
)

/**
 * Methodメソッドが成功することをテストする．
 */
func (suite *FooSuite) TestMethod() {

	suite.T().Helper()

	// 前処理で生成したモックを使用する．
	fooMock := suite.fooMock

	// 以降にテスト処理
}
```

<br>

## 03. 外部パッケージの管理

### コマンド

#### ・```go mod tidy```

インポートされているパッケージに合わせて，```go.mod```ファイルと```go.sum```ファイルを更新する．

```shell
$ go mod tidy
```

<br>

### go.modファイル

#### ・```go.mod```ファイルとは

PHPにおける```composer.json```ファイルに相当する．インターネット上における自身のパッケージ名とGoバージョンを定義するために，全てのGoアプリケーションで必ず必要である．インストールしたい外部パッケージも定義できる．

```
module github.com/hiroki-it/foo_repository

go 1.16
```

#### ・インターネットからインポート

パッケージ名とバージョンタグを用いて，インターネットからパッケージをインポートする．```go mod tidy```コマンドによって```indirect```コメントのついたパッケージが実装される．これは，使用しているパッケージではなく，インポートしているパッケージが依存しているパッケージである．なお，パッケージ名は，使用したいパッケージの```go.mod```ファイルを参照すること．

参考：https://github.com/golang/go/wiki/Modules#should-i-commit-my-gosum-file-as-well-as-my-gomod-file

```
module github.com/hiroki-it/repository

go 1.16

require (
    <パッケージ名> <バージョンタグ>
    github.com/foo v1.3.0
    github.com/bar v1.0.0
    github.com/baz // indirect
)
```

```go
import "github.com/bar"

func main() {
    // 何らかの処理
}
```

#### ・ローカルPCからインポート

ローカルPCでのみ使用する独自共有パッケージは，インターネット上での自身のリポジトリからインポートせずに，```replace```関数を使用してインポートする必要がある．独自共有の全パッケージでパッケージ名を置換する必要はなく，プロジェクトのルートパスについてのみ定義すればよい．パス実際，```unknown revision```のエラーで，バージョンを見つけられない．

参考：https://qiita.com/hnishi/items/a9217249d7832ed2c035

```
module foo.com/hiroki-it/repository

go 1.16

replace github.com/hiroki-it/foo_repository => /
```

また，ルートディレクトリだけでなく，各パッケージにも```go.mod```ファイルを配置する必要がある．

```shell
foo_repository
├── cmd
│   └── hello.go
│ 
├── go.mod
├── go.sum
└── local-pkg
    ├── go.mod # 各パッケージにgo.modを配置する．
    └── module.go
```

```
module foo.com/hiroki-it/foo_repository/local-pkg

go 1.16
```

これらにより，ローカルのパッケージをインポートできるようになる．

```go
import "local.packages/local-pkg"

func main() {
    // 何らかの処理
}
```

<br>

### go.sumファイル

#### ・```go.sum```ファイルとは

PHPにおける```composer.lock```ファイルに相当する．```go.mod```ファイルによって実際にインストールされたパッケージが自動的に実装される．パッケージごとのチェックサムが記録されるため，前回のインストール時と比較して，ライブラリに変更があるかどうかを検知できる．