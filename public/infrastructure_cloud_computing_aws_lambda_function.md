# Lambda関数

## Go

### aws-lambda-go

#### ・aws-lambda-goとは

Lambdaで稼働するGoにおいて，Lambdaの機能を使用するためのパッケージのこと．イベント駆動であり，他のAWSリソースのイベントをパラメータとして受信できる．contextパラメータについては以下を参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/golang-context.html

#### ・```Start```関数

Lamda関数を実行するための関数．```Start```関数に渡すパラメータには，必ず一つでもerrorインターフェースの実装が含まれている必要がある．もし含まれていない場合は，Lambdaで内部エラーが起こる．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/golang-handler.html

```go
package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
)

type MyEvent struct {
	Name string `json:"name"`
}

// HandleRequest リクエストをハンドリングします．
func HandleRequest(ctx context.Context, name MyEvent) (string, error) {
	return fmt.Sprintf("Hello %s!", name.Name), nil
}

func main() {
	// Lambda関数を実行します．
	lambda.Start(HandleRequest)
}
```

<br>

### イベントの種類

#### ・イベントの全種類

参考：https://github.com/aws/aws-lambda-go/tree/master/events#overview

#### ・SNSイベントの場合

```go
package main

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/lambdacontext"
)

/**
 * Lambdaハンドラー関数
 */
func HandleRequest(context context.Context, event events.SNSEvent) (string, error) {

}

func main() {
	lambda.Start(HandleRequest)
}
```

#### ・CloudWatchイベントの場合

```go
package main

import (
	"context"
    
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/lambdacontext"
)

/**
 * Lambdaハンドラー関数
 */
func HandleRequest(context context.Context, event events.CloudWatchEvent) (string, error) {

}

func main() {
	lambda.Start(HandleRequest)
}
```

#### ・APIGatewayイベントの場合

```go
package main

import (
	"context"
    
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/lambdacontext"
)

/**
 * Lambdaハンドラー関数
 */
func HandleRequest(context context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

}

func main() {
	lambda.Start(HandleRequest)
}
```

<br>

### レスポンス

#### ・正常系

正常系レスポンスの構成要素については以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/API_Invoke.html#API_Invoke_ResponseElements

文字列を返却すると，Lambdaはその文字列をそのまま返信する．また，JSONをレスポンスすることもできる．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/golang-handler.html#golang-handler-structs

#### ・異常系

Lambdaのエラーレスポンスのステータスコードについては以下のリンクを参考にせよ．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/API_Invoke.html#API_Invoke_Errors

エラーレスポンスのメッセージボディには以下のJSONが割り当てられる．

参考：https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/golang-exceptions.html#go-exceptions-createfunction

```json
{
  "errorMessage": "<エラーメッセージ>",
  "errorType": "<エラータイプ>"
}
```

errorsパッケージの```New```関数を使用すると，内部で発生したエラーメッセージをオーバーライドできる．

```go
package main

import (
	"errors"
	"github.com/aws/aws-lambda-go/lambda"
)

func HandleRequest() (string, error) {
	return "", errors.New("something went wrong!")
}

func main() {
	lambda.Start(OnlyErrors)
}

/* 結果
{
  "errorMessage": "something went wrong!",
  "errorType": "errorString"
}
*/
```

<br>

## Node.js

### aws-sdk-js

#### ・aws-sdk-jsとは

Lambdaで稼働するJavaScriptにおいて，Lambdaの機能を使用するためのパッケージのこと．イベント駆動であり，他のAWSリソースのイベントをパラメータとして受信できる．

#### ・標準で使用可能なモジュール

| モジュール名            | 補足                                                       |
| ----------------------- | ---------------------------------------------------------- |
| Node.jsの標準モジュール | 参考：https://nodejs.org/api/index.html                    |
| aws-sdk                 | 参考：https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/ |

<br>

### 関数

#### ・API Gateway & S3

**＊実装例＊**

API Gatewayでリクエストを受信し，それに応じて特定のデータをS3に保存する．LambdaがS3に対してアクションを実行できるように，事前に，AWS管理ポリシーの『```AWSLambdaExecute```』がアタッチされたロールをLambdaにアタッチしておく必要がある．

```javascript
"use strict";

const aws = require("aws-sdk");

const s3 = new aws.S3();

exports.handler = (event, context, callback) => {

    // API Gatewayとのプロキシ統合を意識したJSON構造にする	
    // レスポンスメッセージの初期値
    const response = {
        "statusCode": null,
        "body" : null
    };

    // 認証バリデーション
    if (event.headers["X-API-Key"] !== process.env.X_API_KEY) {
        response.statusCode = 401;
        response.body = "An API key is invalid.";
        return callback(null, response);
    }

    // リクエストメッセージバリデーション
    if (!event.headers || !event.body) {
        response.statusCode = 400;
        response.body = "Parameters are not found.";
        return callback(null, response);
    }

    s3.putObject({
            Bucket: "<バケット名>",
            Key: "<パスを含む保存先ファイル>",
            Body: "<保存データ>",
        },
        (err, data) => {
            if (err) {
                response.statusCode = 500;
                response.body = "[ERROR] " + err;
                return callback(null, response);
            }
            response.statusCode = 200;
            response.body = "OK";
            return callback(null, response);
        });
};
```

#### ・Amplify & EventBridge & SlackAPI

**＊実装例＊**

AmplifyのイベントをEventBridgeでキャッチし，これをLambdaに転送する．Lambdaでは，メッセージを構成し，SlackAPIに送信する．

```javascript
"use strict";

const aws = require("aws-sdk");
const https = require("https");
const {format} = require("util");

/**
 * 非同期ハンドラ関数
 *
 * @param event
 * @returns Promise<json>
 */
exports.handler = async (event) => {

    console.log(JSON.stringify({event}, null, 2));

    const amplify = new aws.Amplify({apiVersion: "2017-07-25"});

    const option = {
        appId: event.detail.appId,
        branchName: event.detail.branchName
    };

    let result;

    try {

        // Amplifyのブランチ情報を取得します．
        const app = await amplify.getBranch(option).promise();

        console.log(JSON.stringify({app}, null, 2));

        const message = await buildMessage(event, app);

        console.log(message);

        result = await postMessageToSlack(message);

        console.log(JSON.stringify({result}, null, 2));

    } catch (error) {

        console.error(error);

    }

    return result;
};

/**
 * メッセージを作成します．
 *
 * @param event
 * @param app
 * @returns string
 */
const buildMessage = (event, app) => {

    return JSON.stringify({
        channel: process.env.SLACK_CHANNEL_ID,
        text: "develop環境 通知",
        attachments: [{
            color: event.detail.jobStatus === "SUCCEED" ? "#00FF00" : "#ff0000",
            blocks: [
                {
                    type: "section",
                    text: {
                        type: "mrkdwn",
                        text: format(
                            "%s環境",
                            event.detail.appId === process.env.AMPLIFY_APP_ID_PC ? ":computer: PC" : ":iphone: SP"
                        )
                    }
                },
                {
                    type: "context",
                    elements: [{
                        type: "mrkdwn",
                        text: format(
                            "*結果*: %s",
                            event.detail.jobStatus === "SUCCEED" ? "成功" : "失敗",
                        )
                    }]
                },
                {
                    type: "context",
                    elements: [{
                        type: "mrkdwn",
                        text: format(
                            "*ブランチ名*: %s",
                            event.detail.branchName
                        )
                    }]
                },
                {
                    type: "context",
                    elements: [{
                        type: "mrkdwn",
                        text: format(
                            "*プルリクURL*: https://github.com/xxx-repository/compare/%s",
                            event.detail.branchName
                        )
                    }]
                },
                {
                    type: "context",
                    elements: [{
                        type: "mrkdwn",
                        text: format(
                            "*検証URL*: https://%s.%s.amplifyapp.com",
                            app.branch.displayName,
                            event.detail.appId
                        )
                    }]
                },
                {
                    type: "context",
                    elements: [{
                        type: "mrkdwn",
                        text: format(
                            ":amplify: <https://%s.console.aws.amazon.com/amplify/home?region=%s#/%s/%s/%s|*Amplifyコンソール画面はこちら*>",
                            event.region,
                            event.region,
                            event.detail.appId,
                            app.branch.displayName,
                            event.detail.jobId
                        )
                    }]
                },
                {
                    type: "divider"
                }
            ]
        }]
    });
};

/**
 * メッセージを送信します．
 *
 * @param message
 * @returns Promise<json>
 */
const postMessageToSlack = (message) => {

    return new Promise((resolve, reject) => {

        const options = {
            host: "slack.com",
            path: "/api/chat.postMessage",
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + process.env.SLACK_API_TOKEN,
                "Content-Length": Buffer.byteLength(message)
            }
        };

        const request = https.request(options, (response) => {

            console.info({response}, null, 2);

            let tmp;

            // 正常なレスポンスからデータを取り出します．
            response.on("data", (data) => {
                tmp = data;
            });

            // 異常なレスポンスからエラーを取り出します．
            response.on("error", (error) => {
                tmp = error;
            });

            //  data，error，end，の間でawaitの効力は横断できない．
            // そのため，できるだけendで事後処理を実装し，awaitを使用するようにする．
            response.on("end", async () => {
                tmp = await toStringWithPromise(tmp);
                const body = await jsonParseWithPromise(tmp);
                const result = {
                    statusCode: response.statusCode,
                    body: body
                };
                if (!response.statusCode === 200 || !body.ok) {
                    console.error("Failed");
                    return reject(result);
                }
                console.info("Succeeded");
                return resolve(result);
            });
        });

        request.on("error", (error) => {
            console.error(JSON.stringify({error}, null, 2));
        });

        // メッセージボディを設定して，リクエストを送信します．
        request.write(message);

        request.end();

        console.log(JSON.stringify({request}, null, 2));
    });
};

/**
 * toStringメソッドの結果をPromiseオブジェクトで返却します．
 *
 * @param param
 * @returns Promise<string>
 */
const toStringWithPromise = async (param) => {
    return param.toString()
}

/**
 * parseメソッドの結果をPromiseオブジェクトで返却します．
 *
 * @param param
 * @returns Promise<json>
 */
const jsonParseWithPromise = async (param) => {
    return JSON.parse(param)
}

```



