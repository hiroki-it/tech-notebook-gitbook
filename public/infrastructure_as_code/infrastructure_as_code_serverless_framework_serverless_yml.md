# serverless.yml

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. configValidationMode

### configValidationModeとは

設定ファイルのバリデーションの実行時に、エラーを出力するレベルを設定する。

参考：https://www.serverless.com/framework/docs/providers/aws/guide/serverless.yml

```yaml
configValidationMode: warn
```

<br>

## 02. custom

### customとは

参考：https://www.serverless.com/framework/docs/providers/aws/guide/variables

```yaml
custom:
  foo: foo
```

<br>

## 03. frameworkVersion

### frameworkVersionとは

参考：https://www.serverless.com/framework/docs/providers/aws/guide/serverless.yml

```yaml
frameworkVersion: '2'
```

<br>

## 04. functions

### functionsとは

参考：https://www.serverless.com/framework/docs/providers/aws/guide/functions

<br>

### description

```yaml
functions:
  main:
    description: The function that do foo
```

<br>

### environment

```yaml
functions:
  main:
    environment:
      FOO: foo
      BAR: bar
      BAz: baz      
```

<br>

### events

参考：https://www.serverless.com/framework/docs/providers/aws/guide/events

#### ・eventBridge

```yaml
functions:
  main:
    events:
      - eventBridge:
          pattern: ${file(./event_bridge/patterns/pattern.json)}  
```

<br>

### image

#### ・name

使用するイメージのエイリアスを指定する。

```yaml
functions:
  main:
    image:
      name: base
```

<br>

### maximumRetryAttempts

```yaml
functions:
  main:
    maximumRetryAttempts: 1
```

<br>

### memorySize

```yaml
functions:
  main:
    memorySize: 512
```

<br>

### name

```yaml
functions:
  main:
    name: <Lambda関数名>
```

<br>

### role

```yaml
functions:
  main:
    role: !GetAtt LambdaRole.Arn
```

<br>

### runtime

```yaml
functions:
  main:
    runtime: <使用する言語バージョン>
```

<br>

## 05. package

### packageとは

参考：https://www.serverless.com/framework/docs/providers/aws/guide/packaging

<br>

### patterns

```yaml
package:
  patterns:
    - ./bin/**
```

<br>

## 06. provider

### providerとは

### ecr

#### ・scanOnPush

```yaml
provider:
  ecr:
    scanOnPush: true
```

#### ・images

使用するベースイメージを指定し、エイリアスの名前を設定する。名前は全て小文字である必要がある。

```yaml
provider:
  ecr:
    images:
      base:
        uri: <AWSアカウントURL>/<ECRリポジトリ名>@<ECRイメージタグ>
```

<br>

### eventBridge

#### ・useCloudFormation

```yaml
provider:
  eventBridge:
    useCloudFormation: true
```

<br>

### lambdaHashingVersion

```yaml
provider:
  lambdaHashingVersion: 20201221
```

<br>

### name

```yaml
provider:
  name: aws
```

<br>

### region

```yaml
provider:
  region: ap-northeast-1
```

<br>

### stackName

```yaml
provider:
  stackName: <CloudFormationスタック名>
```

<br>

### stage

```yaml
provider:
  stage: <ステージ名>
```

<br>

## 07. resources

参考：https://www.serverless.com/framework/docs/providers/aws/guide/resources

```yaml
resources:
```

<br>

## 08. service

### serviceとは

参考：https://www.serverless.com/framework/docs/providers/aws/guide/services

```yaml
service: foo-service
```

<br>

## 09. useDotenv

### useDotenvとは

```yaml
useDotenv: true
```

<br>

## 10. variablesResolutionMode

### variablesResolutionModeとは

```yaml
variablesResolutionMode: null
```

<br>

