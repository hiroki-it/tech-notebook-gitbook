# Terraform

## 01. コマンド

### global option

参考：https://www.terraform.io/docs/cli/commands/index.html#switching-working-directory-with-chdir

<br>

### init

#### ・-backend=false

ローカルにstateファイルを作成する．

参考：https://www.terraform.io/docs/language/settings/backends/index.html

```shell
$ terraform init -backend=false
```

```shell
# ディレクトリを指定することも可能
$ terraform -chdir=<ルートモジュールのディレクトリへの相対パス> init -backend=false
```

#### ・-backend=true, -backend-config

リモートにstateファイルを作成する．代わりに，```terraform settings```ブロック内の```backend```で指定しても良い．

```shell
$ terraform init \
    -backend=true \
    -reconfigure \
    -backend-config="bucket=<バケット名>" \
    -backend-config="key=terraform.tfstate" \
    -backend-config="profile=<プロファイル名>" \
    -backend-config="encrypt=true"
```

#### ・-reconfigure

Terraformを初期化する．

参考：https://www.terraform.io/docs/cli/commands/init.html#backend-initialization

```shell
$ terraform init -reconfigure
```

#### ・-upgrade

現在のバージョンに基づいて，```lock```ファイル，モジュール，プラグインのアップグレード／ダウングレードを行う．

参考：https://www.terraform.io/docs/cli/commands/init.html#upgrade

```shell
$ terraform init -upgrade
```

<br>

### validate

#### ・オプション無し

設定ファイルの検証を行う．

```shell
$ terraform validate

Success! The configuration is valid.
```

```shell
# ディレクトリを指定することも可能
$ terraform -chdir=<ルートモジュールのディレクトリへの相対パス> validate
```

<br>

### fmt

#### ・-check

インデントを揃えるべき箇所が存在するかどうかを判定する．もし存在する場合「```1```」，存在しない場合は「```0```」を返却する．

```shell
$ terraform fmt -check
```

#### ・-recursive

設定ファイルのインデントを揃える．処理を行ったファイルが表示される．

```shell
# -recursive: サブディレクトリを含む全ファイルをフォーマット
$ terraform fmt -recursive

main.tf
```

<br>

### import

#### ・-var-file

terraformによる構築ではない方法で，すでにクラウド上にリソースが構築されている場合，これをterraformの管理下におく必要がある．リソースタイプとリソース名を指定し，stateファイルにリモートの状態を書き込む．現状，全てのリソースを一括して```import```する方法は無い．リソースIDは，リソースによって異なるため，リファレンスの「Import」または「Attributes Referenceの```id```」を確認すること（例えば，ACMにとってのIDはARNだが，S3バケットにとってのIDはバケット名である）．

```shell
$ terraform import \
    -var-file=config.tfvars \
    <リソースタイプ>.<リソース名> <AWS上リソースID>
```

モジュールを使用している場合，指定の方法が異なる．

```shell
$ terraform import \
    -var-file=config.tfvars \
    module.<モジュール名>.<リソースタイプ>.<リソース名> <AWS上リソースID>
```

例えば，AWS上にすでにECRが存在しているとして，これをterraformの管理下におく．

```shell
$ terraform import \
    -var-file=config.tfvars \
    module.ecr.aws_ecr_repository.www xxxxxxxxx
```

そして，ローカルのstateファイルとリモートの差分が無くなるまで，```import```を繰り返す．

````shell
$ terraform plan -var-file=config.tfvars

No changes. Infrastructure is up-to-date.
````

#### ・importを行わなかった場合のエラー

もし```import```を行わないと，すでにクラウド上にリソースが存在しているためにリソースを構築できない，というエラーになる．

（エラー例1）

```shell
Error: InvalidParameterException: Creation of service was not idempotent.
```

（エラー例2）

```shell
Error: error creating ECR repository: RepositoryAlreadyExistsException: The repository with name 'tech-notebook_www' already exists in the registry with id 'XXXXXXXXXXXX'
```

<br>

### refresh

#### ・-var-file

クラウドに対してリクエストを行い，現在のリソースの状態をtfstateファイルに反映する．

```shell
$ terraform refresh -var-file=config.tfvars
```

<br>

### plan

#### ・シンボルの見方

構築（```+```），更新（```~```），削除（```-```），再構築（```-/+```）で表現される．

```
+ create
~ update in-place
- destroy
-/+ destroy and then create replacement
```

#### ・出力内容の読み方

前半部分と後半部分に区別されている．前半部分は，Terraform管理外の方法（画面上，他ツール）による実インフラの変更について，その変更前後を検出する．ただの検出のため，applyによって変更される実インフラを表しているわけではない．そして後半部分は，Terraformのソースコードの変更によって，実インフラがどのように変更されるか，を表している．結果の最後に表示される対象リソースの数を確認しても，前半部分のリソースは含まれていないことがわかる．

```shell
Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the
last "terraform apply":

  # Terraform管理外の方法（画面上，他ツール）による実インフラの変更について，その変更前後を検出．

Unless you have made equivalent changes to your configuration, or ignored the
relevant attributes using ignore_changes, the following plan may include
actions to undo or respond to these changes.

─────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:
  
  # Terraformのソースコードの変更によって，実インフラがどのように変更されるか．
  
Plan: 0 to add, 1 to change, 0 to destroy.  
```

#### ・-var-file

クラウドに対してリクエストを行い，現在のリソースの状態をtfstateファイルには反映せずに，設定ファイルの記述との差分を検証する．スクリプト実行時に，変数が定義されたファイルを実行すると，```variable```で宣言した変数に，値が格納される．

```shell
$ terraform plan -var-file=config.tfvars
```

```shell
# ディレクトリを指定することも可能
# 第一引数で変数ファイルの相対パス，第二引数でをルートモジュールの相対パス
$ terraform plan -chdir=<ルートモジュールのディレクトリへの相対パス> \
    -var-file=<ルートモジュールのディレクトリへの相対パス>/config.tfvars
```

差分がなければ，以下の通りになる．

```shell
No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```

#### ・-target

特定のリソースに対して，```plan```コマンドを実行する．

```shell
$ terraform plan \
    -var-file=config.tfvars \
    -target=<リソースタイプ>.<リソース名>
```

モジュールを使用している場合，指定の方法が異なる．

```shell
$ terraform plan \
    -var-file=config.tfvars \
    -target=module.<モジュール名>.<リソースタイプ>.<リソース名>
```

#### ・-refresh

このオプションをつければ，```refresh```コマンドを同時に実行してくれる．ただ，デフォルトで```true```なので，不要である．

```shell
$ terraform plan \
    -var-file=config.tfvars \
    -refresh=true
```

https://github.com/hashicorp/terraform/issues/17311

#### ・-parallelism

並列処理数を設定できる．デフォルト値は```10```である．

```shell
$ terraform plan \
    -var-file=config.tfvars \
    -parallelism=30
```

#### ・-out

実行プランファイルを生成する．```apply```コマンドのために使用できる．

```shell
$ terraform plan \
    -var-file=config.tfvars \
    -out=<実行プランファイル名>.tfplan
```

<br>

### apply

#### ・-var-file

AWS上にクラウドインフラストラクチャを構築する．

```shell
$ terraform apply -var-file config.tfvars
```

```shell
# ディレクトリを指定することも可能
$ terraform -chdir=<ルートモジュールのディレクトリへの相対パス> apply \
    -var-file=<ルートモジュールのディレクトリへの相対パス>/config.tfvars
```

成功すると，以下のメッセージが表示される．

```shell
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

#### ・-target

特定のリソースに対して，```apply```コマンドを実行する．

```shell
$ terraform apply \
    -var-file=config.tfvars \
    -target=<リソースタイプ>.<リソース名>
```

モジュールを使用している場合，指定の方法が異なる．

```shell
$ terraform apply \
    -var-file=config.tfvars \
    -target=module.<モジュール名>.<リソースタイプ>.<リソース名>
```

#### ・-parallelism

並列処理数を設定できる．デフォルト値は```10```である．

```shell
$ terraform apply \
    -var-file=config.tfvars \
    -parallelism=30
```

#### ・実行プランファイル

事前に，```plan```コマンドによって生成された実行プランファイルを元に，```apply```コマンドを実行する．実行プランを渡す場合は，変数をオプションに設定する必要はない．

```shell
$ terraform apply <実行プランファイル名>.tfplan
```

<br>

### taint

#### ・-var-file <リソース>

stateファイルにおける指定されたリソースの```tainted```フラグを立てる．例えば，```apply```したが，途中でエラーが発生してしまい，リモートに中途半端はリソースが構築されてしまうことがある．ここで，```tainted```を立てておくと，リモートのリソースを削除したと想定した```plan```を実行できる．

```shell
$ terraform taint \
    -var-file=config.tfvars \
    module.<モジュール名>.<リソースタイプ>.<リソース名>
```

この後の```plan```コマンドのログからも，```-/+```で削除が行われる想定で，差分を比較していることがわかる．

```shell
$ terraform plan -var-file=config.tfvars

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

-/+ <リソースタイプ>.<リソース名> (tainted) (new resource required)
      id: '1492336661259070634' => <computed> (forces new resource)


Plan: 1 to add, 0 to change, 1 to destroy.
```

<br>

### state list

#### ・オプション無し

ファイル内で定義しているリソースの一覧を表示する．

```shell
$ terraform state list
```

以下の通り，モジュールも含めて，リソースが表示される．

```shell
aws_instance.www-1a
aws_instance.www-1c
aws_key_pair.key_pair
module.alb_module.aws_alb.alb
module.ami_module.data.aws_ami.amazon_linux_2
module.route53_module.aws_route53_record.r53_record
module.route53_module.aws_route53_zone.r53_zone
module.security_group_module.aws_security_group.security_group_alb
module.security_group_module.aws_security_group.security_group_ecs
module.security_group_module.aws_security_group.security_group_instance
module.vpc_module.aws_internet_gateway.internet_gateway
module.vpc_module.aws_route_table.route_table_public
module.vpc_module.aws_route_table_association.route_table_association_public_1a
module.vpc_module.aws_route_table_association.route_table_association_public_1c
module.vpc_module.aws_subnet.subnet_public_1a
module.vpc_module.aws_subnet.subnet_public_1c
module.vpc_module.aws_vpc.vpc
```

<br>

## 01-02. バージョン

### バージョン管理

#### ・```lock```ファイル

現在使用中のプロバイダーのバージョンが定義される．これにより，他の人がリポジトリを使用する時に，異なるバージョンのプロバイダーを宣言できないようにする．もし，異なるバージョンを使用したい場合は，コマンドを実行する．これにより，```lock```ファイルのアップグレード／ダウングレードが実行される．

<br>

### Terraform／プロバイダーのアップグレード

#### 1. 現在のTerraformのバージョンで```apply```コマンドを実行

アップグレードと同時に新しいAWSリソースをデプロイせずに，アップグレードのみに専念する．そのために，現在のTerraformのバージョンで```apply```コマンドを実行し，差分が無いようにしておく．

#### 2. アップグレード以外の作業を済ませておく

低いバージョンのTerraformに対して，より高いバージョンをデプロイすることは可能である．反対に，高いバージョンのTerraoformに対して，より低いバージョンをデプロイできない．そのため，アップグレードしてしまうと，それ以外のTeraformバージョンの異なる作業に影響が出る．

#### 3. メジャーバージョン単位でアップグレード

Terraformでは，メジャーバージョン単位でアップグレードを行うことが推奨されている．そのため，現在のバージョンと最新バージョンがどんなに離れていても，必ず一つずつメジャーバージョンをアップグレードするように気をつける．

参考：https://www.terraform.io/upgrade-guides/1-0.html 

#### 4. ```plan```コマンドの警告／エラーを解消

アップグレードに伴って，非推奨／廃止の機能がリリースされ，警告／エラーが出力される場合がある．警告／エラーを解消できるように，記法やオプション値を修正する．

#### 5. Terraformの後にプロバイダーをアップグレード

Terraformとプロバイダーのバージョンは独立して管理されている．プロバイダーはTerraformが土台になって稼働するため，一旦，Terraformのアップグレードを済ませてから，プロバイダーをアップグレードする．

<br>

##  01-03. ディレクトリ構成

### ルートモジュールの構成

#### ・稼働環境別

稼働環境別に，```config.tfvars```ファイルで値を定義する．

```shell
terraform_project/
├── modules
│   ├── route53 # Route53
│   │   ├── dev # 開発
│   |   ├── prd # 本番
│   |   └── stg # ステージング
│   | 
│   ├── ssm # SSM
|   |   ├── dev
│   |   ├── prd
│   |   └── stg
│   | 
│   └── waf # WAF
|       ├── dev
│       ├── prd
│       └── stg
|
├── dev # 開発環境ルートモジュール
│   ├── config.tfvars
│   ├── main.tf
│   ├── providers.tf
│   ├── tfnotify.yml
│   └── variables.tf
│
├── prd # 本番環境ルートモジュール
│   ├── config.tfvars
│   ├── main.tf
│   ├── providers.tf
│   ├── tfnotify.yml
│   └── variables.tf
│
└── stg # ステージング環境ルートモジュール
      ├── config.tfvars
      ├── main.tf
      ├── providers.tf
      ├── tfnotify.yml
      └── variables.tf
```

<br>

### リソースのモジュールの構成

####　・対象リソース別

一つのリソースの設定が対象のリソースごとに異なる場合，冗長性よりも保守性を重視して，リソースに応じたディレクトリに分割する．

```shell
terraform_project/
└── modules
    ├── cloudwatch # CloudWatch
    │   ├── alb        # ALB
    |   ├── cloudfront # CloudFront
    |   ├── ecs        # ECS
    |   ├── lambda     # Lambda
    |   └── rds        # RDS    
    |
    └── waf # WAF
        ├── alb         # ALB
        ├── api_gateway # API Gateway
        └── cloudfront  # CloudFront
```

#### ・稼働環境別

一つのリソースの設定が稼働環境ごとに異なる場合，冗長性よりも保守性を重視して，稼働環境に応じたディレクトリに分割する．

```shell
terraform_project/
└── modules
    ├── route53 # Route53
    │   ├── dev # 開発
    |   ├── prd # 本番
    |   └── stg # ステージング
    | 
    ├── ssm # SSM
    |   ├── dev
    |   ├── prd
    |   └── stg
    | 
    └── waf # WAF
        └── alb 
            ├── dev
            ├── prd
            └── stg
```

#### ・リージョン別

一つのリソースの設定がリージョンごとに異なる場合，冗長性よりも保守性を重視して，リージョンに応じたディレクトリに分割する．

```shell
terraform_project/
└── modules
    └── acm # ACM
        ├── ap-northeast-1 # 東京リージョン
        └── us-east-1      # バージニアリージョン  
```

#### ・共通セット別

WAFで使用するIPパターンセットと正規表現パターンセットには，CloudFrontタイプとRegionalタイプがある．Regionalタイプは，同じリージョンの異なるAWSリソース間で共通して使用できるため，共通セットとしてディレクトリ分割を行う．

```shell
terraform_project/
└── modules
    └── waf # WAF
        ├── alb
        ├── api_gateway
        ├── cloudfront       
        └── regional_sets # Regionalタイプのセット
            ├── ip_sets   # IPセット
            |   ├── prd
            |   └── stg
            |    
            └── regex_pattern_sets # 正規表現パターンセット
                ├── prd
                └── stg
```

#### ・ファイルの切り分け

ポリシーのためにJSONを定義する場合，Terraformのソースコードにハードコーディングせずに，切り分けるようにする．また，「カスタマー管理ポリシー」「インラインポリシー」「信頼ポリシー」も区別し，ディレクトリを分割している．なお，```templatefile```メソッドでこれを読みこむ時，```json```ファイルではなく，tplファイルとして定義しておく必要あるため，注意する．

``` shell
terraform_project/
└── modules 
    ├── ecr #ECR
    │   └── ecr_lifecycle_policy.tpl # ECRライフサイクル
    │
    ├── ecs # ECS
    │   └── container_definitions.tpl # コンテナ定義
    │
    ├── iam # IAM
    │   └── policies  
    |       ├── customer_managed_policies # カスタム管理ポリシー
    |       |   ├── aws_cli_executor_access_policy.tpl
    |       |   ├── aws_cli_executor_access_address_restriction_policy.tpl
    |       |   ├── cloudwatch_logs_access_policy.tpl
    |       |   └── lambda_edge_execution_policy.tpl
    |       |     
    |       ├── inline_policies # インラインポリシー
    |       |   └── ecs_task_policy.tpl
    |       |     
    |       └── trust_policies # 信頼ポリシー
    |           ├── cloudwatch_events_policy.tpl
    |           ├── ecs_task_policy.tpl
    |           ├── lambda_policy.tpl
    |           └── rds_policy.tpl
    |
    └── s3 # S3
        └── policies # バケットポリシー
            └── alb_bucket_policy.tpl
```

<br>

### CI/CDディレクトリ

#### ・opsディレクトリ

TerraformのCI/CDで必要なシェルスクリプトは，```ops```ディレクトリで管理する．

```shell
terraform_project/
├── .circleci # CI/CDツールの設定ファイル
└── ops # TerraformのCI/CDの自動化シェルスクリプト
```

<br>

## 02. ルートモジュールにおける実装

### tfstateファイル

#### ・tfstateファイルとは

リモートのインフラの状態が定義されたjsonファイルのこと．初回時，```apply```コマンドを実行し，成功もしくは失敗したタイミングで生成される．

<br>

### terraform  settings

#### ・terraform settingsとは

terraformの実行時に，エントリポイントとして機能するファイル．

#### ・required_providers

AWSやGCPなど，使用するプロバイダを定義する．プロバイダによって，異なるリソースタイプが提供される．一番最初に読みこまれるファイルのため，変数やモジュール化などが行えない．

**＊実装例＊**

```hcl
terraform {

  required_providers {
    # awsプロバイダを定義
    aws = {
      # グローバルソースアドレスを指定
      source  = "hashicorp/aws"
      
      # プロバイダーのバージョン変更時は initを実行
      version = "3.0" 
    }
  }
}
```

#### ・backend

stateファイルを管理する場所を設定する．S3などのリモートで管理する場合，アカウント情報を設定する必要がある．代わりに，```init```コマンド実行時に指定しても良い．デフォルト値は```local```である．

**＊実装例＊**

```hcl
terraform {

  # ローカルPCで管理するように設定
  backend "local" {
    path = "${path.module}/terraform.tfstate"
  }
}
```

```hcl
terraform {

  # S3で管理するように設定
  backend "s3" {
    bucket                  = "<バケット名>"
    key                     = "<バケット内のディレクトリ>"
    region                  = "ap-northeast-1"
    profile                 = "example"
    shared_credentials_file = "$HOME/.aws/<Credentialsファイル名>"
  }
}
```

どのユーザもバケット内のオブジェクトを削除できないように，ポリシーを設定しておくとよい．

**＊実装例＊**

```json
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:DeleteObject",
            "Resource": "arn:aws:s3:::<tfstateのバケット名>/*"
        }
    ]
}
```

<br>

### provider

#### ・providerとは

Terraformがリクエストを送信するプロバイダ（AWS，GCP，Azure，など）を選択し，そのプロバイダにおけるアカウント認証を行う．```terraform settings```で定義したプロバイダ名を指定する必要がある．

**＊実装例＊**

```hcl
terraform {
  required_version = "0.13.5"

  required_providers {
    # awsプロバイダを定義
    aws = {
      # 何らかの設定
    }
  }
  
  backend "s3" {
    # 何らかの設定
  }
}

# awsプロバイダを指定
provider "aws" {
  # アカウント認証の設定
}
```

<br>

### multiple providers

#### ・multiple providersとは

複数の```provider```を実装し，エイリアスを使用して，これらを動的に切り替える方法．

**＊実装例＊**

```hcl
terraform {
  required_version = "0.13.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.0"
    }
  }
}

provider "aws" {
  # デフォルト値とするリージョン
  region = "ap-northeast-1"
}

provider "aws" {
  # 別リージョン
  alias  = "ue1"
  region = "us-east-1"
}
```

#### ・子モジュールでproviderを切り替える

子モジュールで```provider```を切り替えるには，ルートモジュールで```provider```の値を明示的に渡す必要がある．

**＊実装例＊**

```hcl
module "route53" {
  source = "../modules/route53"

  providers = {
    aws = aws.ue1
  }
  
  # その他の設定値
}
```

さらに子モジュールで，```provider```の値を設定する必要がある．

**＊実装例＊**

```hcl
###############################################
# Route53
###############################################
resource "aws_acm_certificate" "example" {
  # CloudFrontの仕様のため，us-east-1リージョンでSSL証明書を作成します．
  provider = aws

  domain_name               = var.route53_domain_example
  subject_alternative_names = ["*.${var.route53_domain_example}"]
  validation_method         = "DNS"

  tags = {
    Name = "${var.environment}-${var.service}-example-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}
```

<br>

### アカウント情報の設定方法

#### ・ハードコーディングによる設定

リージョンの他，アクセスキーとシークレットキーをハードコーディングで設定する．誤ってコミットしてしまう可能性があるため，ハードコーディングしないようにする．

**＊実装例＊**

```hcl
terraform {
  required_version = "0.13.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.0"
    }
  }
  
  backend "s3" {
    bucket     = "<バケット名>"
    key        = "<バケット内のディレクトリ>"
    region     = "ap-northeast-1"
    access_key = "<アクセスキー>"
    secret_key = "<シークレットキー>"
  }
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = "<アクセスキー>"
  secret_key = "<シークレットキー>"
}
```

#### ・credentialsファイルによる設定

　AWSアカウント情報は，```~/.aws/credentials```ファイルに記載されている．

```
[default]
aws_access_key_id=<アクセスキー>
aws_secret_access_key=<シークレットキー>

[user1]
aws_access_key_id=<アクセスキー>
aws_secret_access_key=<シークレットキー>
```

credentialsファイルを読み出し，プロファイル名を設定することにより，アカウント情報を参照できる．

**＊実装例＊**

```hcl
terraform {
  required_version = "0.13.5"

  required_providers {
  
    aws = {
      source  = "hashicorp/aws"
      version = "3.0"
    }
  }
  
  # credentialsファイルから，アクセスキー，シークレットアクセスキーを読み込む
  backend "s3" {
    bucket                  = "<バケット名>"
    key                     = "<バケット内のディレクトリ>"
    region                  = "ap-northeast-1"
    profile                 = "example"
    shared_credentials_file = "$HOME/.aws/<Credentialsファイル名>"
  }
}

# credentialsファイルから，アクセスキー，シークレットアクセスキーを読み込む
provider "aws" {
  region                  = "ap-northeast-1"
  profile                 = "example"
  shared_credentials_file = "$HOME/.aws/<Credentialsファイル名>"
}
```

#### ・環境変数による設定

Credentialsファイルではなく，```export```を使用して，必要な情報を設定しておくことも可能である．参照できる環境変数名は決まっている．

```shell
# regionの代わり
$ export AWS_DEFAULT_REGION="ap-northeast-1"

# access_keyの代わり
$ export AWS_ACCESS_KEY_ID="<アクセスキー>"

# secret_keyの代わり
$ export AWS_SECRET_ACCESS_KEY="<シークレットキー>"

# profileの代わり
$ export AWS_PROFILE="<プロファイル名>"

#tokenの代わり（AmazonSTSを使用する場合）
$ export AWS_SESSION_TOKEN="<トークン>"
```

環境変数を設定した上でteraformを実行すると，値が```provider```に自動的に出力される．CircleCIのような，一時的に環境変数が必要になるような状況では有効な方法である．

```hcl
terraform {
  required_version = "0.13.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.0"
    }
  }
  
  # リージョン，アクセスキー，シークレットアクセスキーは不要
  backend "s3" {
    bucket  = "<バケット名>"
    key     = "<バケット内のディレクトリ>"
  }
}

# リージョン，アクセスキー，シークレットアクセスキーは不要
provider "aws" {}
```

<br>

### module

#### ・moduleとは

ルートモジュールで子モジュール読み込み，子モジュールに対して変数を渡す．

#### ・実装方法

**＊実装例＊**

```hcl
###############################
# ALB
###############################
module "alb" {
  # モジュールのResourceを参照
  source = "../modules/alb"
  
  # モジュールに他のモジュールのアウトプット値を渡す．
  acm_certificate_api_arn = module.acm.acm_certificate_api_arn
}
```

<br>

## 03. 変数

### tfvarsファイル

#### ・tfvarsファイルの用途

実行ファイルに入力したい値を定義する．各サービスの間で実装方法が同じため，VPCのみ例を示す．

**＊実装例＊**

```hcl
###############################
# VPC
###############################
vpc_cidr_block = "n.n.n.n/n" # IPv4アドレス範囲
```

#### ・値のデータ型

単一値，list型，map型で定義できる．AZ，サブネットのCIDR，RDSのパラメータグループ値，などはmap型として保持しておくとよい．また，IPアドレスのセット，ユーザエージェント，などはlist型として保持しておくとよい．なお，RDSのパラメータグループの適正値については，以下を参考にせよ．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_cloud_computing_aws.html

**＊実装例＊**

```hcl
###############################################
# RDS
###############################################
rds_parameter_group_values = {
  time_zone                = "asia/tokyo"
  character_set_client     = "utf8mb4"
  character_set_connection = "utf8mb4"
  character_set_database   = "utf8mb4"
  character_set_results    = "utf8mb4"
  character_set_server     = "utf8mb4"
  server_audit_events      = "connect,query,query_dcl,query_ddl,query_dml,table"
  server_audit_logging     = 1
  server_audit_logs_upload = 1
  general_log              = 1
  slow_query_log           = 1
  long_query_time          = 3
}

###############################################
# VPC
###############################################
vpc_availability_zones             = { a = "a", c = "c" }
vpc_cidr                           = "n.n.n.n/23"
vpc_subnet_private_datastore_cidrs = { a = "n.n.n.n/27", c = "n.n.n.n/27" }
vpc_subnet_private_app_cidrs       = { a = "n.n.n.n/25", c = "n.n.n.n/25" }
vpc_subnet_public_cidrs            = { a = "n.n.n.n/27", c = "n.n.n.n/27" }

###############################################
# WAF
###############################################
waf_blocked_global_ip_addresses = [
  "n.n.n.n/32",
  "n.n.n.n/32",
]

waf_blocked_user_agents = [
  "XXXXX",
  "YYYYY"
]
```

<br>

### variable 

#### ・variableとは

リソースで使用する変数のデータ型を定義する．

**＊実装例＊**

```hcl
###############################################
# ECS
###############################################
variable "ecs_container_laravel_port_http" {
  type = number
}

variable "ecs_container_nginx_port_http" {
  type = number
}

###############################################
# RDS
###############################################
variable "rds_auto_minor_version_upgrade" {
  type = bool
}

variable "rds_instance_class" {
  type = string
}

variable "rds_parameter_group_values" {
  type = map(string)
}
```

<br>

## 04. リソースの実装

### resource

#### ・resourceとは

AWSのAPIに対してリクエストを送信し，クラウドインフラの構築を行う．

#### ・実装方法

**＊実装例＊**

```hcl
###############################################
# ALB
###############################################
resource "aws_lb" "this" {
  name               = "${var.app_name}-alb"
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.subnet_public_ids
}
```

<br>

### data

#### ・dataとは

AWSのAPIに対してリクエストを送信し，クラウドインフラに関するデータを取得する．ルートモジュールに実装することも可能であるが，各モジュールに実装した方が分かりやすい．

#### ・実装方法

**＊実装例＊**

例として，タスク定義名を指定して，AWSから

```hcl
###############################################
# ECS task definition
###############################################
data "aws_ecs_task_definition" this {
  task_definition = aws_ecs_task_definition.this.family
}
```

**＊実装例＊**

例として，AMIをフィルタリングした上で，AWSから特定のAMIの値を取得する．

```hcl
###############################################
# AMI
###############################################
data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}
```

<br>

### output

#### ・outputとは

モジュールで構築されたリソースがもつ特定の値を出力する．

#### ・実装方法

**＊実装例＊**

例として，ALBを示す．```resource```ブロックと```data```ブロックでアウトプットの方法が異なる．

```hcl
###############################################
# ALB
###############################################
output "alb_zone_id" {
  value = aws_lb.this.zone_id
}

output "elb_service_account_arn" {
  value = data.aws_elb_service_account.this.arn
}
```
#### ・count関数のアウトプット

後述の説明を参考にせよ．

#### ・for_each関数のアウトプット

後述の説明を参考にせよ．

<br>

## 05. メタ引数

### メタ引数とは

全てのリソースで使用できるオプションのこと．

<br>

### depends_on

#### ・depends_onとは

リソース間の依存関係を明示的に定義する．Terraformでは，基本的にリソース間の依存関係が暗黙的に定義されている．しかし，複数のリソースが関わると，リソースを適切な順番で構築できない場合があるため，そういったときに使用する．

#### ・ALB target group vs. ALB，ECS

例として，ALB target groupを示す．ALB Target groupとALBのリソースを適切な順番で構築できないため，ECSの構築時にエラーが起こる．ALBの後にALB target groupを構築する必要がある．

**＊実装例＊**

```hcl
###############################################
# ALB target group
###############################################
resource "aws_lb_target_group" "this" {
  name                 = "${var.environment}-${var.service}-alb-tg"
  port                 = var.ecs_nginx_port_http
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = "60"
  target_type          = "ip"
  slow_start           = "60"

  health_check {
    interval            = 30
    path                = "/healthcheck"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }

  depends_on = [aws_lb.this]
}
```

#### ・Internet Gateway vs. EC2，Elastic IP，NAT Gateway

例として，NAT Gatewayを示す．NAT Gateway，Internet Gateway，のリソースを適切な順番で構築できないため，Internet Gatewayの構築後に，NAT Gatewayを構築するように定義する必要がある．

```hcl
###############################################
# EC2
###############################################
resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami_amazon_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [var.ec2_bastion_security_group_id]
  subnet_id                   = var.public_a_subnet_id
  key_name                    = "${var.environment}-${var.service}-bastion"
  associate_public_ip_address = true
  disable_api_termination     = true

  tags = {
    Name = "${var.environment}-${var.service}-bastion"
  }

  depends_on = [var.internet_gateway]
}
```

```hcl
###############################################
# Elastic IP
###############################################
resource "aws_eip" "nat_gateway" {
  for_each = var.vpc_availability_zones

  vpc = true

  tags = {
    Name = format(
      "${var.environment}-${var.service}-ngw-%s-eip",
      each.value
    )
  }

  depends_on = [aws_internet_gateway.this]
}
```

```hcl
###############################################
# NAT Gateway
###############################################
resource "aws_nat_gateway" "this" {
  for_each = var.vpc_availability_zones

  subnet_id     = aws_subnet.public[each.key].id
  allocation_id = aws_eip.nat_gateway[each.key].id

  tags = {
    Name = format(
      "${var.environment}-${var.service}-%s-ngw",
      each.value
    )
  }

  depends_on = [aws_internet_gateway.this]
}
```

#### ・S3バケットポリシー vs. パブリックアクセスブロックポリシー

例として，S3を示す．バケットポリシーとパブリックアクセスブロックポリシーを同時に構築できないため，構築のタイミングが重ならないようにする必要がある．

```hcl
###############################################
# S3
###############################################

# Example bucket
resource "aws_s3_bucket" "example" {
  bucket = "${var.environment}-${var.service}-example-bucket"
  acl    = "private"
}

# Public access block
resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.example.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy attachment
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id
  policy = templatefile(
    "${path.module}/policies/example_bucket_policy.tpl",
    {
      example_s3_bucket_arn                        = aws_s3_bucket.example.arn
      s3_cloudfront_origin_access_identity_iam_arn = var.s3_cloudfront_origin_access_identity_iam_arn
    }
  )

  depends_on = [aws_s3_bucket_public_access_block.example]
}
```

<br>

### count

#### ・countとは

指定した数だけ，リソースの構築を繰り返す．```count.index```でインデックス数を出力する．

**＊実装例＊**

```hcl
###############################################
# EC2
###############################################
resource "aws_instance" "server" {
  count = 4
  
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"

  tags = {
    Name = "ec2-${count.index}"
  }
}
```

#### ・list型でアウトプット

リソースの構築に```count```関数を使用した場合，そのリソースはlist型として扱われる．そのため，キー名を指定してアウトプットできる．この時，アウトプットはlist型になる．ちなみに，```for_each```関数で構築したリソースはアスタリスクでインデックス名を指定できないので，注意．

**＊実装例＊**

例として，VPCのサブネットを示す．ここでは，パブリックサブネット，applicationサブネット，datastoreサブネット，を```count```関数で構築したとする．

```hcl
###############################################
# Public subnet
###############################################
resource "aws_subnet" "public" {
  count = 2
  
  # ～ 省略 ～
}

###############################################
# Private subnet
###############################################
resource "aws_subnet" "private_app" {
  count = 2
  
  # ～ 省略 ～
}

resource "aws_subnet" "private_datastore" {
  count = 2
  
  # ～ 省略 ～
}
```

```hcl
###############################################
# Output VPC
###############################################
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}

output "private_datastore_subnet_ids" {
  value = aws_subnet.private_datastore[*].id
}
```

<br>

### for_each

#### ・for_eachとは

事前に```for_each```に格納したmap型の```key```の数だけ，リソースを繰り返し実行する．繰り返し処理を行う時に，```count```とは違い，要素名を指定して出力できる．

**＊実装例＊**

例として，subnetを繰り返し構築する．

```hcl
###############################################
# Variables
###############################################
vpc_availability_zones             = { a = "a", c = "c" }
vpc_cidr                           = "n.n.n.n/23"
vpc_subnet_private_datastore_cidrs = { a = "n.n.n.n/27", c = "n.n.n.n/27" }
vpc_subnet_private_app_cidrs       = { a = "n.n.n.n/25", c = "n.n.n.n/25" }
vpc_subnet_public_cidrs            = { a = "n.n.n.n/27", c = "n.n.n.n/27" }
```

```hcl
###############################################
# Public subnet
###############################################
resource "aws_subnet" "public" {
  for_each = var.vpc_availability_zones

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.vpc_subnet_public_cidrs[each.key]
  availability_zone       = "${var.region}${each.value}"
  map_public_ip_on_launch = true

  tags = {
    Name = format(
      "${var.environment}-${var.service}-pub-%s-subnet",
      each.value
    )
  }
}
```

#### ・冗長化されたAZにおける設定

冗長化されたAZで共通のルートテーブルを構築する場合，そこで，```for_each```関数を使用すると，少ない実装で構築できる．```for_each```関数で構築されたリソースは```apply```中にmap構造として扱われ，リソース名の下層にキー名でリソースが並ぶ構造になっている．これを参照するために，『```<リソースタイプ>.<リソース名>[each.key].<attribute>```』とする

**＊実装例＊**

パブリックサブネット，プライベートサブネット，プライベートサブネットに紐づくNAT Gatewayの設定が冗長化されたAZで共通の場合，```for_each```関数で構築する．

```hcl
###############################################
# Variables
###############################################
vpc_availability_zones = { a = "a", c = "c" }
```

```hcl
###############################################
# Internet Gateway
###############################################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-${var.service}-igw"
  }
}

###############################################
# Route table (public)
###############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.environment}-${var.service}-pub-rtb"
  }
}

###############################################
# Route table (private)
###############################################
resource "aws_route_table" "private_app" {
  for_each = var.vpc_availability_zones

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = {
    Name = format(
      "${var.environment}-${var.service}-pvt-%s-app-rtb",
      each.value
    )
  }
}

###############################################
# NAT Gateway
###############################################
resource "aws_nat_gateway" "this" {
  for_each = var.vpc_availability_zones

  subnet_id     = aws_subnet.public[each.key].id
  allocation_id = aws_eip.nat_gateway[each.key].id

  tags = {
    Name = format(
      "${var.environment}-${var.service}-%s-ngw",
      each.value
    )
  }

  depends_on = [aws_internet_gateway.this]
}
```



#### ・単一値でアウトプット

リソースの構築に```for_each```関数を使用した場合，そのリソースはmap型として扱われる．そのため，キー名を指定してアウトプットできる．

```hcl
###############################################
# Variables
###############################################
vpc_availability_zones = { a = "a", c = "c" }
```

```hcl
###############################################
# Output VPC
###############################################
output "public_a_subnet_id" {
  value = aws_subnet.public[var.vpc_availability_zones.a].id
}

output "public_c_subnet_id" {
  value = aws_subnet.public[var.vpc_availability_zones.c].id
}
```

#### ・map型でアウトプット

**＊実装例＊**

```hcl
###############################################
# Variables
###############################################
vpc_availability_zones = { a = "a", c = "c" }
```

```hcl
###############################################
# Output VPC
###############################################
output "public_subnet_ids" {
  value = {
    a = aws_subnet.public[var.vpc_availability_zones.a].id,
    c = aws_subnet.public[var.vpc_availability_zones.c].id
  }
}

output "private_app_subnet_ids" {
  value = {
    a = aws_subnet.private_app[var.vpc_availability_zones.a].id,
    c = aws_subnet.private_app[var.vpc_availability_zones.c].id
  }
}

output "private_datastore_subnet_ids" {
  value = {
    a = aws_subnet.private_datastore[var.vpc_availability_zones.a].id,
    c = aws_subnet.private_datastore[var.vpc_availability_zones.c].id
  }
}
```

```hcl
###############################################
# ALB
###############################################
resource "aws_lb" "this" {
  name                       = "${var.environment}-${var.service}-alb"
  subnets                    = values(private_app_subnet_ids)
  security_groups            = [var.alb_security_group_id]
  internal                   = false
  idle_timeout               = 120
  enable_deletion_protection = true

  access_logs {
    enabled = true
    bucket  = var.alb_s3_bucket_id
  }
}
```

<br>

### dynamic

#### ・dynamicとは

指定したブロックを繰り返し構築する．

**＊実装例＊**

例として，RDSパラメータグループの```parameter```ブロックを，map型変数を使用して繰り返し構築する．

```hcl
###############################################
# Variables
###############################################
rds_parameter_group_values = {
  time_zone                = "asia/tokyo"
  character_set_client     = "utf8mb4"
  character_set_connection = "utf8mb4"
  character_set_database   = "utf8mb4"
  character_set_results    = "utf8mb4"
  character_set_server     = "utf8mb4"
  server_audit_events      = "connect,query,query_dcl,query_ddl,query_dml,table"
  server_audit_logging     = 1
  server_audit_logs_upload = 1
  general_log              = 1
  slow_query_log           = 1
  long_query_time          = 3
}

###############################################
# RDS Cluster Parameter Group
###############################################
resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${var.environment}-${var.service}-cluster-pg"
  description = "The cluster parameter group for ${var.environment}-${var.service}-rds"
  family      = "aurora-mysql5.7"

  dynamic "parameter" {
    for_each = var.rds_parameter_group_values

    content {
      name  = parameter.key
      value = parameter.value
    }
  }
}
```

**＊実装例＊**

例として，WAFの正規表現パターンセットの```regular_expression```ブロックを，list型変数を使用して繰り返し構築する．

```hcl
###############################################
# Variables
###############################################
waf_blocked_user_agents = [
  "ExampleCrawler",
  "EXampleSpider",
  "ExampleBot",
]

###############################################
# WAF Regex Pattern Sets
###############################################
resource "aws_wafv2_regex_pattern_set" "cloudfront" {
  name        = "blocked-user-agents"
  description = "Blocked user agents"
  scope       = "CLOUDFRONT"

  dynamic "regular_expression" {
    for_each = var.waf_blocked_user_agents

    content {
      regex_string = regular_expression.value
    }
  }
}
```

<br>

### lifecycle

#### ・lifecycleとは

リソースの構築，更新，そして削除のプロセスをカスタマイズする．

#### ・create_before_destroy

リソースを新しく構築した後に削除するように，変更できる．通常時，Terraformの処理順序として，リソースの削除後に構築が行われる．しかし，他のリソースと依存関係が存在する場合，先に削除が行われることによって，他のリソースに影響が出てしまう．これに対処するために，先に新しいリソースを構築し，紐づけし直してから，削除する必要がある．

**＊実装例＊**

例として，ACM証明書を示す．ACM証明書は，ALBやCloudFrontに関連付いており，新しい証明書に関連付け直した後に，既存のものを削除する必要がある．

```hcl
###############################################
# For example domain
###############################################
resource "aws_acm_certificate" "example" {
  domain_name               = var.route53_domain_example
  subject_alternative_names = ["*.${var.route53_domain_example}"]
  validation_method         = "DNS"

  tags = {
    Name = "${var.environment}-${var.service}-example-cert"
  }

  # 新しい証明書を構築した後に削除する．
  lifecycle {
    create_before_destroy = true
  }
}
```

**＊実装例＊**

例として，RDSのクラスターパラメータグループとサブネットグループを示す．クラスターパラメータグループとサブネットグループは，RDSに関連付いており，新しいクラスターパラメータグループに関連付け直した後に，既存のものを削除する必要がある．

```hcl
###############################################
# RDS Cluster Parameter Group
###############################################
resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${var.environment}-${var.service}-rds-cluster-param-gp"
  description = "The cluster parameter group for ${var.environment}-${var.service}-rds"
  family      = "aurora-mysql5.7"

  dynamic "parameter" {
    for_each = var.rds_parameter_group_values

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

###############################################
# RDS Subnet Group
###############################################
resource "aws_db_subnet_group" "this" {
  name        = "${var.service}-${var.environment}-rds-subnet-gp"
  description = "The subnet group for ${var.environment}-${var.service}-rds"
  subnet_ids  = [var.private_a_datastore_subnet_id, var.private_c_datastore_subnet_id]

  lifecycle {
    create_before_destroy = true
  }
```

**＊実装例＊**

例として，Redisのパラメータグループとサブネットグループを示す．ラメータグループとサブネットグループは，RDSに関連付いており，新しいパラメータグループとサブネットグループに関連付け直した後に，既存のものを削除する必要がある．

```hcl
###############################################
# Redis Parameter Group
###############################################
resource "aws_elasticache_parameter_group" "redis" {
  name        = "${var.environment}-${var.service}-redis-v5-param-gp"
  description = "The parameter group for ${var.environment}-${var.service}-redis 5.0"
  family      = "redis5.0"

  lifecycle {
    create_before_destroy = true
  }
}

###############################################
# Redis Subnet Group
###############################################
resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.environment}-${var.service}-redis-subnet-gp"
  description = "The redis subnet group for ${var.environment}-${var.service}-rds"
  subnet_ids  = [var.private_a_app_subnet_id, var.private_c_app_subnet_id]

  lifecycle {
    create_before_destroy = true
  }
}
```

#### ・ignore_changes

リモートのみで起こったリソースの構築・更新・削除を無視し，```hclstate```ファイルに反映しないようにする．基本的に使用することはないが，リモート側のリソースが動的に変更される可能性があるリソースでは，設定が必要である．

**＊実装例＊**

例として，ECSを示す．ECSでは，AutoScalingによってタスク数が増減し，またアプリケーションのデプロイでリビジョン番号が増加する．そのため，これらを無視する必要がある．

```hcl
###############################################
# ECS Service
###############################################
resource "aws_ecs_service" "this" {
  name                               = "${var.environment}-${var.service}-ecs-service"
  cluster                            = aws_ecs_cluster.this.id
  launch_type                        = "Fargate"
  platform_version                   = "1.4.0"
  task_definition                    = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"
  desired_count                      = var.ecs_service_desired_count
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 300

  network_configuration {
    security_groups  = [var.aws_security_group_ecs_id]
    subnets          = var.subnet_private_app_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = "${var.environment}-${var.service}-nginx"
    container_port   = var.ecs_container_nginx_port_http
  }

  lifecycle {
    ignore_changes = [
      # AutoScalingによるタスク数の増減を無視．
      desired_count,
      # アプリケーションのデプロイによるリビジョン番号の増加を無視．
      task_definition,
    ]
  }
}
```

**＊実装例＊**

例として，Redisを示す．Redisでは，AutoScalingによってプライマリ数とレプリカ数が増減する．そのため，これらを無視する必要がある．


```hcl
###############################################
# Redis Cluster
###############################################
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.environment}-${var.service}-redis-cluster"
  replication_group_description = "The cluster of ${var.environment}-${var.service}-redis"
  engine_version                = "5.0.6"
  port                          = var.redis_port_ssm_parameter_value
  parameter_group_name          = aws_elasticache_parameter_group.redis.name
  node_type                     = var.redis_node_type
  number_cache_clusters         = 2
  availability_zones            = ["${var.region}${var.vpc_availability_zones.a}", "${var.region}${var.vpc_availability_zones.c}"]
  subnet_group_name             = aws_elasticache_subnet_group.redis.id
  security_group_ids            = [var.redis_security_group_id]
  automatic_failover_enabled    = true
  maintenance_window            = "sun:17:00-sun:18:00"
  snapshot_retention_limit      = 0
  snapshot_window               = "19:00-20:00"
  apply_immediately             = true

  lifecycle {
    ignore_changes = [
      # プライマリ数とレプリカ数の増減を無視します．
      number_cache_clusters
    ]
  }
}
}
```

**＊実装例＊**

使用例はすくないが，ちなみにリソース全体を無視する場合は```all```を設定する．

```hcl
resource "aws_example" "example" {

  # 何らかの設定

  lifecycle {
    ignore_changes = all
  }
}
```

<br>

## 06. tpl形式の切り出しと読み出し

### templatefile関数

#### ・templatefile関数とは

第一引数でポリシーが定義されたファイルを読み出し，第二引数でファイルに変数を渡す．ファイルの拡張子はtplとするのがよい．

**＊実装例＊**

例として，S3を示す．

```hcl
###############################################
# S3 bucket policy
###############################################
resource "aws_s3_bucket_policy" "alb" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = templatefile(
    "${path.module}/policies/alb_bucket_policy.tpl",
    {
      aws_elb_service_account_arn = var.aws_elb_service_account_arn
      aws_s3_bucket_alb_logs_arn  = aws_s3_bucket.alb_logs.arn
    }
  )
}
```

バケットポリシーを定義するtpl形式ファイルでは，string型で出力する場合は```"${}"```で，int型で出力する場合は```${}```で出力する．ここで拡張子をjsonにしてしまうと，int型の出力をjsonの構文エラーとして扱われてしまう．

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_elb_service_account_arn}/*"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket_alb_logs_arn}/*"
    }
  ]
}
```

<br>

### ポリシーのアタッチ

<br>

### containerDefinitionsの設定

#### ・containerDefinitionsとは

タスク定義のうち，コンテナを定義する部分のこと．

**＊実装例＊**

```json
{
  "ipcMode": null,
  "executionRoleArn": "<ecsTaskExecutionRoleのARN>",
  "containerDefinitions": [
    
  ],

   ~ ~ ~ その他の設定 ~ ~ ~

}
```

#### ・設定方法

**＊実装例＊**

例として，SSMのパラメータストアの値を参照できるように，```secrets```を設定している．int型を変数として渡せるように，拡張子をjsonではなくtplとするのが良い．

```hcl
###############################################
# ECS Task Definition
###############################################
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.environment}-${var.service}-ecs-task-definition"
  task_role_arn            = var.ecs_task_iam_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_task_execution_iam_role_arn
  memory                   = var.ecs_task_memory
  cpu                      = var.ecs_task_cpu
  container_definitions = templatefile(
    "${path.module}/container_definitions.tpl",
    {
      environment                                     = var.environment
      region                                          = var.region
      service                                         = var.service
      ecs_container_laravel_cloudwatch_log_group_name = var.ecs_container_laravel_cloudwatch_log_group_name
      ecs_container_nginx_cloudwatch_log_group_name   = var.ecs_container_nginx_cloudwatch_log_group_name
      laravel_ecr_repository_url                      = var.laravel_ecr_repository_url
      nginx_ecr_repository_url                        = var.nginx_ecr_repository_url
      ecs_container_laravel_port_http                 = var.ecs_container_laravel_port_http
      ecs_container_nginx_port_http                   = var.ecs_container_nginx_port_http
    }
  )
}
```

ログ分割の目印を設定する```awslogs-datetime-format```キーでは，タイムスタンプを表す```\\[%Y-%m-%d %H:%M:%S\\]```を設定すると良い．これにより，同じ時間に発生したログを一つのログとしてまとめることができるため，スタックトレースが見やすくなる．

```json
[
  {
    "name": "<コンテナ名>",
    "image": "<ECRリポジトリのURL>",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "secrets": [
      {
        "name": "<アプリケーションの環境変数名>",
        "valueFrom": "<SSMのパラメータ名>"
      },
      {
        "name": "DB_HOST",
        "valueFrom": "/ecs/DB_HOST"
      },
      {
        "name": "DB_DATABASE",
        "valueFrom": "/ecs/DB_DATABASE"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "/ecs/DB_PASSWORD"
      },
      {
        "name": "DB_USERNAME",
        "valueFrom": "/ecs/DB_USERNAME"
      },
      {
        "name": "REDIS_HOST",
        "valueFrom": "/ecs/REDIS_HOST"
      },
      {
        "name": "REDIS_PASSWORD",
        "valueFrom": "/ecs/REDIS_PASSWORD"
      },
      {
        "name": "REDIS_PORT",
        "valueFrom": "/ecs/REDIS_PORT"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "<ロググループ名>",
        "awslogs-datetime-format": "\\[%Y-%m-%d %H:%M:%S\\]",
        "awslogs-region": "<リージョン>",
        "awslogs-stream-prefix": "<ログストリーム名のプレフィクス>"
      }
    }
  }
]
```

<br>

## 07. 命名規則

### 変数の命名

#### ・単数形と複数形の命名分け

複数の値をもつlist型の変数であれば複数形で命名する．一方で，string型など値が一つしかなければ単数形とする．

**＊実装例＊**

例として，VPCを示す．

```hcl
###############################################
# VPC variables
###############################################
vpc_availability_zones             = { a = "a", c = "c" }
vpc_cidr                           = "n.n.n.n/23"
vpc_subnet_private_datastore_cidrs = { a = "n.n.n.n/27", c = "n.n.n.n/27" }
vpc_subnet_private_app_cidrs       = { a = "n.n.n.n/25", c = "n.n.n.n/25" }
vpc_subnet_public_cidrs            = { a = "n.n.n.n/27", c = "n.n.n.n/27" }
```

<br>

### リソースとデータリソースの命名

#### ・リソース名で種類を表現

リソース名において，リソースタイプを繰り返さないようにする．もし種類がある場合，リソース名でその種類を表現する．

**＊実装例＊**

例として，VPCを示す．

```hcl
###############################################
# VPC route table
###############################################

# 良い例
resource "aws_route_table" "public" {

}

resource "aws_route_table" "private" {

}
```

```hcl
###############################################
# VPC route table
###############################################

# 悪い例
resource "aws_route_table" "route_table_public" {

}

resource "aws_route_table" "route_table_private" {

}
```

#### ・this

一つのリソースタイプに，一つのリソースしか種類が存在しない場合，```this```で命名する．

**＊実装例＊**

```hcl
resource "aws_internet_gateway" "this" {

}
```

#### ・AWSリソース名

1. `<接頭辞>-<種類>-<接尾辞>`とする．
2. 接頭辞は， `<稼働環境>-<サービス名>`とする．
3. 接尾辞は，AWSリソース名とする．

**＊実装例＊**

例として，CloudWatchを示す．この時，他のresourceと比較して，種類はALBのHTTPCode_TARGET_4XX_Countメトリクスに関するアラームと見なせる．そのため，`alb_httpcode_4xx_count`と名付けている．

```hcl
resource "aws_cloudwatch_metric_alarm" "alb_httpcode_target_4xx_count" {

  alarm_name = "${var.environment}-${var.service}-alb-httpcode-target-4xx-count-alarm"
  
}
```

#### ・設定の順序，行間

最初に`count`や`for_each`を設定し改行する．その後，各リソース別の設定を行間を空けずに記述する（この順番にルールはなし）．最後に共通の設定として，`tags`，`depends_on`，`lifecycle`，の順で配置する．ただし実際，これらの全ての設定が必要なリソースはない．

**＊実装例＊**

```hcl
###############################################
# EXAMPLE
###############################################
resource "aws_example" "this" {
  for_each = var.vpc_availability_zones # 最初にfor_each
  # スペース
  subnet_id = aws_subnet.public[*].id # 各設定（順番にルールなし）
  # スペース
  tags = {
    Name = format(
      "${var.environment}-${var.service}-%d-example",
      each.value
    )
  }
  # スペース
  depends_on = []
  # スペース
  lifecycle {
    create_before_destroy = true
  }
}
```

<br>

### アウトプット値の命名

#### ・基本ルール

アウトプット値の名前は，『```<リソース名>_<リソースタイプ>_<attribute名>```』で命名する．

**＊実装例＊**

例として，CloudWatchを示す．リソース名は`ecs_container_nginx`，リソースタイプは`aws_cloudwatch_log_group`，attributeは`name`オプションである．

```hcl
output "ecs_container_nginx_cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.ecs_container_nginx.name
}
```

**＊実装例＊**

例として，IAM Roleを示す．

```hcl
###############################################
# Output IAM Role
###############################################
output "ecs_task_execution_iam_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "lambda_execute_iam_role_arn" {
  value = aws_iam_role.lambda_execute.arn
}

output "rds_enhanced_monitoring_iam_role_arn" {
  value = aws_iam_role.rds_enhanced_monitoring.arn
}
```

#### ・thisは省略

リソース名が```this```である場合，アウトプット値名ではこれを省略してもよい．

**＊実装例＊**

例として，ALBを示す．

```hcl
###############################################
# Output ALB
###############################################
output "alb_zone_id" {
  value = aws_lb.this.zone_id
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}
```

#### ・冗長なattribute名は省略

**＊実装例＊**

例として，ECRを示す．

```hcl
###############################################
# Output ECR
###############################################
output "laravel_ecr_repository_url" {
  value = aws_ecr_repository.laravel.repository_url
}

output "nginx_ecr_repository_url" {
  value = aws_ecr_repository.nginx.repository_url
}
```

<br>

## 08. 各リソースタイプ独自の仕様

### AMI

#### ・まとめ

**＊実装例＊**

```
###############################################
# For bastion
###############################################
data "aws_ami" "bastion" {
  # 後述の説明を参考にせよ．（１）
  most_recent = false
  
  # 後述の説明を参考にせよ．（１）
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2018.03.0.20201028.0-x86_64-gp2"]
  }

  filter {
    name   = "image-id"
    values = ["ami-040c9333a9c90b2b6"]
  }
}
```

#### （１）取得するAMIのバージョンを固定

取得するAMIが常に最新になっていると，EC2が再構築されなねない．そこで，特定のAMIを取得できるようにしておく．```most_recent```は無効化しておき，特定のAMをフィルタリングする．

<br>

### API Gateway

#### ・まとめ

**＊実装例＊**

```
###############################################
# REST API
###############################################
resource "aws_api_gateway_rest_api" "example" {
  name        = "${var.environment}-${var.service}-api-for-example"
  description = "The API that enables two-way communication with ${var.environment}-example"
  
  # VPCリンクのプロキシ統合のAPIを定義したOpenAPI仕様
  # 後述の説明を参考にせよ．（１）
  body = templatefile(
    "${path.module}/open_api.yaml",
    {
      api_gateway_vpc_link_example_id = aws_api_gateway_vpc_link.example.id
      nlb_dns_name                          = var.nlb_dns_name
    }
  )

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  lifecycle {
    ignore_changes = [
      policy
    ]
  }
}

###############################################
# Deployment
###############################################
resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  # 後述の説明を参考にせよ．（１）
  triggers = {
    redeployment = sha1(aws_api_gateway_rest_api.example.body)
  }

  lifecycle {
    create_before_destroy = true
  }
}

###############################################
# Stage
###############################################
resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = var.environment
}
```

#### （１）OpenAPI仕様のインポートと差分認識

あらかじめ用意したOpenAPI仕様のYAMLファイルを```body```オプションのパラメータとし，これをインポートすることにより，APIを定義できる．YAMLファイルに変数を渡すこともできる．APIの再デプロイのトリガーとして，```redeployment```パラメータに```body```パラメータのハッシュ値を渡すようにする．これにより，インポート元のYAMLファイルに差分があった場合に，Terraformが```redeployment```パラメータの値の変化を認識できるようになり，再デプロイを実行できる．

<br>

### CloudFront

#### ・まとめ

**＊実装例＊**

```
resource "aws_cloudfront_distribution" "this" {

  price_class      = "PriceClass_200"
  web_acl_id       = var.cloudfront_wafv2_web_acl_arn
  aliases          = [var.route53_domain_example]
  comment          = "${var.environment}-${var.service}-cf-distribution"
  enabled          = true
  
  # 後述の説明を参考にせよ．（１）
  retain_on_delete = true

  viewer_certificate {
    acm_certificate_arn      = var.example_acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  logging_config {
    bucket          = var.cloudfront_s3_bucket_regional_domain_name
    include_cookies = true
  }

  restrictions {

    geo_restriction {
      restriction_type = "none"
    }
  }
  
  # ～ 省略 ～
  
}
```

#### （１）削除保持機能

Terraformでは，```retain_on_delete```で設定できる．固有の設定で，AWSに対応するものは無い．

#### ・originブロック

Origins画面に設定するオリジンを定義する．

**＊実装例＊**

```hcl
resource "aws_cloudfront_distribution" "this" {

  # ～ 省略 ～  

  # オリジン（ここではS3としている）
  origin {
    domain_name = var.s3_bucket_regional_domain_name
    origin_id   = "S3-${var.s3_bucket_id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_example.cloudfront_access_identity_path
    }
  }
  
  # ～ 省略 ～  
  
}
```

```hcl
resource "aws_cloudfront_distribution" "this" {

  # ～ 省略 ～  

  # オリジン（ここではALBとしている）
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "ELB-${var.alb_name}"

    custom_origin_config {
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_protocol_policy   = "match-viewer"
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
      http_port                = var.alb_listener_port_http
      https_port               = var.alb_listener_port_https
    }
  }
  
  # ～ 省略 ～
}
```

#### ・ordered_cache_behaviorブロック

Behavior画面に設定するオリジンにルーティングするパスを定義する．

**＊実装例＊**

```hcl
resource "aws_cloudfront_distribution" "this" {

  # ～ 省略 ～

  ordered_cache_behavior {
    path_pattern           = "/images/*"
    target_origin_id       = "S3-${var.s3_bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = 0
    max_ttl                = 31536000
    default_ttl            = 86400
    compress               = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  # ～ 省略 ～
  
}
```

#### ・default_cache_behavior

Behavior画面に設定するオリジンにルーティングするデフォルトパスを定義する．

**＊実装例＊**

```hcl
resource "aws_cloudfront_distribution" "this" {

  default_cache_behavior {
    target_origin_id       = "ELB-${var.alb_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = 0
    max_ttl                = 31536000
    default_ttl            = 86400
    compress               = true

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }
  }
  
  # ～ 省略 ～
  
}
```

<br>

### ECR

#### ・ライフサイクルポリシー

ECRにアタッチされる，イメージの有効期間を定義するポリシー．コンソール画面から入力できるため，基本的にポリシーの実装は不要であるが，TerraformなどのIaCツールでは必要になる．

```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images untagged",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep last 10 images any",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

<br>

### ECS

#### ・まとめ

**＊実装例＊**

```hcl
###############################################
# ECS Service
###############################################
resource "aws_ecs_service" "this" {
  name                               = "${var.environment}-${var.service}-ecs-service"
  cluster                            = aws_ecs_cluster.this.id
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  desired_count                      = var.ecs_service_desired_count
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  # 後述の説明を参考にせよ．（１）
  health_check_grace_period_seconds = 330

  # 後述の説明を参考にせよ．（２）
  task_definition = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"

  network_configuration {
    security_groups  = [var.ecs_security_group_id]
    subnets          = [var.private_a_app_subnet_id, var.private_c_app_subnet_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "nginx"
    container_port   = var.ecs_container_nginx_port_http
  }

  load_balancer {
    target_group_arn = var.nlb_target_group_arn
    container_name   = "nginx"
    container_port   = var.ecs_container_nginx_port_http
  }

  depends_on = [
    # 後述の説明を参考にせよ．（３）
    var.alb_listener_https,
    var.nlb_listener
  ]

  lifecycle {
    ignore_changes = [
      # ※後述の説明を参考にせよ（４）
      desired_count,
    ]
  }
}
```

#### （１）ヘルスチェック猶予期間

タスクの起動が完了する前にサービスがロードバランサ－のヘルスチェックを検証し，Unhealthyと誤認してしまうため，タスクの起動完了を待機する．例えば，ロードバランサ－が30秒間隔でヘルスチェックを実行する場合は，30秒単位で待機時間を増やし，適切な待機時間を見つけるようにする．

#### （２）リモートのリビジョン番号の追跡

アプリケーションのデプロイによって，リモートのタスク定義のリビジョン番号が増加するため，これを追跡できるようにする．

参考：https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition

#### （３）ALB/NLBリスナーの構築を待機

Teraformは，特に依存関係を実装しない場合に，『ターゲットグループ → ALB/NLB → リスナー』の順でリソースを構築する．問題として，ALB/NLBやリスナーの構築が終わる前に，ECSサービスの構築が始まってしまう．ALB/NLBの構築（※リスナーも含む可能性）が完全に完了しない状態では，ターゲットグループはECSサービスに関連付けらず，これが完了する前にECSサービスがターゲットグループを参照しようとするため，エラーになる．リスナーの後にECSサービスを構築するようにし，『ターゲットグループ → ALB/NLB → リスナー → ECSサービス』の順でリソースを構築できるようにする．

参考：https://github.com/hashicorp/terraform/issues/12634#issuecomment-313215022

#### （４）AutoScalingによるタスク数の増減を無視

AutoScalingによって，タスク数が増減するため，これを無視する．

#### （※）タスク定義の更新

Terraformでタスク定義を更新すると，現在動いているECSで稼働しているタスクはそのままに，新しいリビジョン番号のタスク定義が作成される．コンソール画面の「新しいリビジョンの作成」と同じ挙動である．実際にタスクが増えていることは，サービスに紐づくタスク定義一覧から確認できる．次のデプロイ時に，このタスクが用いられる．

#### （※）サービスのデプロイの削除時間

ECSサービスの削除には『ドレイニング』の時間が発生する．約2分30秒かかるため，気長に待つこと．

<br>

### EC2

#### ・まとめ

**＊実装例＊**

```
###############################################
# For bastion
###############################################
resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami_amazon_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [var.ec2_bastion_security_group_id]
  subnet_id                   = var.public_a_subnet_id
  associate_public_ip_address = true

  # ※後述の説明を参考にせよ（１）
  key_name = "${var.environment}-${var.service}-bastion"

  disable_api_termination = true

  tags = {
    Name = "${var.environment}-${var.service}-bastion"
  }

  # ※後述の説明を参考にせよ（２）
  depends_on = [var.internet_gateway]
}
```

#### （１）キーペアはコンソール上で設定

誤って削除しないように，またソースコードに機密情報をハードコーディングしないように，キーペアはコンソール画面で作成した後，```key_name```でキー名を指定するようにする．

#### （２）インターネットゲートウェイの後に構築

インターネットゲートウェイの後にEC2を構築できるようにする．

参考：https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway#argument-reference

<br>

### IAMユーザ

#### ・カスタマー管理ポリシーを持つロール

事前に，tpl形式のカスタマー管理ポリシーを定義しておく．構築済みのIAMロールに，```aws_iam_policy```リソースを使用して，AWS管理ポリシーをIAMユーザにアタッチする．

**＊実装例＊**

ローカルからAWS CLIコマンドを実行する必要がある場合に，コマンドを特定の送信元IPアドレスを特定のものに限定する．事前に，list型でIPアドレスを定義する．

```hcl
###############################################
# IP addresses
###############################################
global_ip_addresses = [
  "nn.nnn.nnn.nnn/32",
  "nn.nnn.nnn.nnn/32"
]
```

また事前に，指定した送信元IPアドレス以外を拒否するカスタマー管理ポリシーを定義する．

```json
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Deny",
    "Action": "*",
    "Resource": "*",
    "Condition": {
      "NotIpAddress": {
        "aws:SourceIp": ${global_ip_addresses}
      }
    }
  }
}
```


コンソール画面で作成済みのIAMユーザの名前を取得する．tpl形式のポリシーにlist型の値を渡す時，```jsonencode```関数を使用する必要がある．

```hcl
###############################################
# For IAM User
###############################################
data "aws_iam_user" "aws_cli_command_executor" {
  user_name = "aws_cli_command_executor"
}

resource "aws_iam_policy" "aws_cli_command_executor_ip_address_restriction" {
  name        = "${var.environment}-aws-cli-command-executor-ip-address-restriction-policy"
  description = "Allow global IP addresses"
  policy = templatefile(
    "${path.module}/policies/customer_managed_policies/aws_cli_command_executor_ip_address_restriction_policy.tpl",
    {
      global_ip_addresses = jsonencode(var.global_ip_addresses)
    }
  )
}
```

#### ・AWS管理ポリシー

IAMユーザにAWS管理ポリシーをアタッチする．

**＊実装例＊**

```hcl
###############################################
# For IAM User
###############################################
resource "aws_iam_user_policy_attachment" "aws_cli_command_executor_s3_read_only_access" {
  user       = data.aws_iam_user.aws_cli_command_executor.user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
```

<br>

### IAMロール

#### ・信頼ポリシーを持つロール

コンソール画面でロールを作成する場合は意識することはないが，特定のリソースにロールをアタッチするためには，ロールに信頼ポリシーを組み込む必要がある．事前に，tpl形式の信頼ポリシーを定義しておく．```aws_iam_role```リソースを使用して，IAMロールを構築すると同時に，これに信頼ポリシーをアタッチする．

**＊実装例＊**

事前に，ECSタスクのための信頼ポリシーを定義する．

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

ECSタスクロールとECSタスク実行ロールに信頼ポリシーアタッチする．

```hcl
###############################################
# IAM Role For ECS Task Execution
###############################################
resource "aws_iam_role" "ecs_task_execution" {
  name        = "${var.environment}-${var.service}-ecs-task-execution-role"
  description = "The role for ${var.environment}-${var.service}-ecs-task"
  assume_role_policy = templatefile(
    "${path.module}/policies/trust_policies/ecs_task_policy.tpl",
    {}
  )
}

###############################################
# IAM Role For ECS Task
###############################################
resource "aws_iam_role" "ecs_task" {
  name        = "${var.environment}-${var.service}-ecs-task-role"
  description = "The role for ${var.environment}-${var.service}-ecs-task"
  assume_role_policy = templatefile(
    "${path.module}/policies/trust_policies/ecs_task_policy.tpl",
    {}
  )
}
```

**＊実装例＊**

事前に，Lambda@Edgeのための信頼ポリシーを定義する．

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Lambda実行ロールに信頼ポリシーアタッチする．

```hcl
###############################################
# IAM Role For Lambda@Edge
###############################################

# ロールに信頼ポリシーをアタッチします．
resource "aws_iam_role" "lambda_execute" {
  name = "${var.environment}-${var.service}-lambda-execute-role"
  assume_role_policy = templatefile(
    "${path.module}/policies/lambda_execute_role_trust_policy.tpl",
    {}
  )
}
```

#### ・インラインポリシーを持つロール

事前に，tpl形式のインラインポリシーを定義しておく．```aws_iam_role_policy```リソースを使用して，インラインポリシーを構築すると同時に，これにインラインポリシーをアタッチする．

**＊実装例＊**

事前に，ECSタスクに必要最低限の権限を与えるインラインポリシーを定義する．

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
```

ECSタスクロールとECSタスク実行ロールにインラインポリシーアタッチする．

```hcl
###############################################
# IAM Role For ECS Task
###############################################
resource "aws_iam_role_policy" "ecs_task" {
  name = "${var.environment}-${var.service}-ssm-read-only-access-policy"
  role = aws_iam_role.ecs_task_execution.id
  policy = templatefile(
    "${path.module}/policies/inline_policies/ecs_task_policy.tpl",
    {}
  )
}
```

#### ・AWS管理ポリシーを持つロール

事前に，tpl形式のAWS管理ポリシーを定義しておく．```aws_iam_role_policy_attachment```リソースを使用して，リモートにあるAWS管理ポリシーを構築済みのIAMロールにアタッチする．ポリシーのARNは，AWSのコンソール画面を確認する．

**＊実装例＊**

```hcl
###############################################
# IAM Role For ECS Task Execution
###############################################
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
```

#### ・カスタマー管理ポリシーを持つロール

事前に，tpl形式のインラインポリシーを定義しておく．```aws_iam_role_policy```リソースを使用して，カスタマー管理ポリシーを構築する．```aws_iam_role_policy_attachment```リソースを使用して，カスタマー管理ポリシーを構築済みのIAMロールにアタッチする．

**＊実装例＊**

事前に，ECSタスクに必要最低限の権限を与えるカスタマー管理ポリシーを定義する．

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
```

ECSタスクロールにカスタマー管理ポリシーアタッチする．

```hcl
###############################################
# IAM Role For ECS Task
###############################################
resource "aws_iam_policy" "ecs_task" {
  name        = "${var.environment}-${var.service}-cloudwatch-logs-access-policy"
  description = "Provides access to CloudWatch Logs"
  policy = templatefile(
    "${path.module}/policies/customer_managed_policies/cloudwatch_logs_access_policy.tpl",
    {}
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}
```

#### ・サービスリンクロール

サービスリンクロールは，AWSリソースの構築時に自動的に作成され，アタッチされる．そのため，Terraformの管理外である．```aws_iam_service_linked_role```リソースを使用して，手動で構築することが可能であるが，数が多く実装の負担にもなるため，あえて管理外としても問題ない．

**＊実装例＊**

サービス名を指定して，Application Auto Scalingのサービスリンクロールを構築する．

```hcl
###############################################
# IAM Role For ECS Service
###############################################
# Service Linked Role
resource "aws_iam_service_linked_role" "ecs_service_auto_scaling" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
}
```

```hcl
###############################################
# Output IAM Role
###############################################
output "ecs_service_auto_scaling_iam_service_linked_role_arn" {
  value = aws_iam_service_linked_role.ecs_service_auto_scaling.arn
}
```

Application Auto Scalingにサービスリンクロールをアタッチする．手動で設定することも可能であるが，Terraformの管理外で自動的にアタッチされるため，あえて妥協しても良い．

```hcl
#########################################
# Application Auto Scaling For ECS
#########################################
resource "aws_appautoscaling_target" "ecs" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.auto_scaling_ecs_task_max_capacity
  min_capacity       = var.auto_scaling_ecs_task_min_capacity
  
  # この設定がなくとも，サービスリンクロールが自動的に構築され，AutoScalingにアタッチされる．
  role_arn           = var.ecs_service_auto_scaling_iam_service_linked_role_arn
}
```

<br>

### LBリスナーとターゲットグループ

#### ・まとめ

**＊実装例＊**

```hcl
###############################################
# NLB target group
###############################################
resource "aws_lb_target_group" "this" {
  name                 = "${var.environment}-${var.service}-nlb-tg"
  port                 = var.ecs_container_nginx_port_http
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  deregistration_delay = "60"
  target_type          = "ip"

  # ※後述の説明を参考にせよ（１）
  slow_start = "0"

  # ※後述の説明を参考にせよ（２）
  health_check {
    protocol          = "HTTP"
    healthy_threshold = 3
    path              = "/healthcheck"
  }

  # stickiness ※後述の説明を参考にせよ（３）
  # https://registry.terraform.io/providers/hashicorp/aws/3.16.0/docs/resources/lb_target_group#stickiness

  lifecycle {
    create_before_destroy = false
  }
}
```

#### （１）NLBはスロースタートに非対応

NLBに紐づくターゲットグループはスロースタートに非対応のため，これを明示的に無効化する必要がある．

#### （２）NLBヘルスチェックには設定可能な項目が少ない

ターゲットグループの転送プロトコルがTCPの場合は，設定できないヘルスチェックオプションがいくつかある．ヘルスチェックプロトコルがHTTPまたはHTTPSの時のみ，パスを設定できる．

参考：https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#health_check

#### （３）NLBスティッキーネスは明示的に無効化

スティッキネス機能を無効化する場合，AWSプロバイダーのアップグレード時に問題が起こらないように，このブロックを実装しないようにする．リンク先のNOTE文を参考にせよ．

参考：https://registry.terraform.io/providers/hashicorp/aws/3.16.0/docs/resources/lb_target_group#stickiness

#### （※）ターゲットグループの削除時にリスナーを先に削除できない．

LBリスナーがターゲットグループに依存しているが，Terraformがターゲットグループの削除時にリスナーを先に削除しようとしないため，以下のようなエラーが発生する．

```shell
Error deleting Target Group: ResourceInUse: Target group 'arn:aws:elasticloadbalancing:ap-northeast-1:123456789:targetgroup/xxxxx-tg/xxxxx' is currently in use by a listener or a rule
	status code: 400, request id: xxxxx
```

このエラーが発生した場合，コンソール画面上でLBリスナーを削除したうえで，もう一度applyする．

参考：https://github.com/hashicorp/terraform-provider-aws/issues/1315#issuecomment-415423529

<br>

### RDS

#### ・まとめ

**＊実装例＊**

```hcl
#########################################
# RDS Cluster
#########################################
resource "aws_rds_cluster" "this" {
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.mysql_aurora.2.08.3"
  cluster_identifier              = "${var.environment}-${var.service}-rds-cluster"
  
  # 後述の説明を参考にせよ．（１）
  master_username                 = var.rds_db_master_username_ssm_parameter_value
  master_password                 = var.rds_db_master_password_ssm_parameter_value
  port                            = var.rds_db_port_ssm_parameter_value
  database_name                   = var.rds_db_name_ssm_parameter_value
  
  vpc_security_group_ids          = [var.rds_security_group_id]
  db_subnet_group_name            = aws_db_subnet_group.this.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.id
  storage_encrypted               = true
  backup_retention_period         = 7
  preferred_backup_window         = "00:00-00:30"
  copy_tags_to_snapshot           = true
  final_snapshot_identifier       = "final-db-snapshot"
  skip_final_snapshot             = false
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  preferred_maintenance_window    = "sun:01:00-sun:01:30"
  
  # 後述の説明を参考にせよ．（２）
  apply_immediately = true

  # 後述の説明を参考にせよ．（３）
  availability_zones = ["${var.region}${var.vpc_availability_zones.a}", "${var.region}${var.vpc_availability_zones.c}"]

  deletion_protection = true

  lifecycle {
    ignore_changes = [
      # 後述の説明を参考にせよ．（４）
      availability_zones
    ]
  }
}

###############################################
# RDS Cluster Instance
###############################################
resource "aws_rds_cluster_instance" "this" {
  for_each = var.vpc_availability_zones

  engine                       = "aurora-mysql"
  engine_version               = "5.7.mysql_aurora.2.08.3"
  identifier                   = "${var.environment}-${var.service}-rds-instance-${each.key}"
  cluster_identifier           = aws_rds_cluster.this.id
  instance_class               = var.rds_instance_class
  db_subnet_group_name         = aws_db_subnet_group.this.id
  db_parameter_group_name      = aws_db_parameter_group.this.id
  monitoring_interval          = 60
  monitoring_role_arn          = var.rds_iam_role_arn
  auto_minor_version_upgrade   = var.rds_auto_minor_version_upgrade
  preferred_maintenance_window = "sun:01:00-sun:01:30"
  apply_immediately            = true

  # 後述の説明を参考にせよ．（５）
  # preferred_backup_window
}
```

#### （１）SSMパラメータストア

Terraformに値をハードコーディングしたくない場合は，SSMパラメータストアで値を管理し，これをデータリソースで取得するようにする．

#### （２）メンテナンスウインドウ時に変更適用

メンテナンスウインドウ時の変更適用をTerraformで行う場合，一段階目に```apply_immediately```オプションを```false```に変更してapplyし，二段階目に修正をapplyする．

#### （３）クラスターにはAZが３つ必要

クラスターでは，レプリケーションのために，３つのAZが必要である．そのため，指定したAZが２つであっても，コンソール画面上で３つのAZが自動的に設定される．Terraformがこれを認識しないように，```ignore_changes```でAZを指定しておく必要がある．

参考：

- https://github.com/hashicorp/terraform-provider-aws/issues/7307#issuecomment-457441633
- https://github.com/hashicorp/terraform-provider-aws/issues/1111

#### （４）インスタンスを配置するAZは選べない

事前にインスタンスにAZを表す識別子を入れたとしても，Terraformはインスタンスを配置するAZを選べない．そのため，AZと識別子の関係が逆になってしまうことがある．多くの場合， Cゾーンのインスタンスが最初に構築されるため，インスタンスのゾーン名と配置されるA/Cゾーンが逆になる．その場合は，デプロイ後に手動で名前を変更すればよい．この変更は，Terraformが差分として認識しないので問題ない．

#### （５）インスタンスにバックアップウインドウは設定しない

クラスターとインスタンスの両方に，```preferred_backup_window```を設定できるが，RDSインスタンスに設定してはいけない．

<br>

### Route53

#### ・まとめ

**＊実装例＊**

```hcl
###############################################
# For example domain
###############################################
resource "aws_route53_zone" "example" {
  name = var.route53_domain_example
}

resource "aws_route53_record" "example" {
  zone_id = aws_route53_zone.example.id
  name    = var.route53_domain_example
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}
```

<br>

### Route Table

#### ・メインルートテーブルは自動構築

Terraformを用いてVPCを構築した時，メインルートテーブルが自動的に構築される．そのため，これはTerraformの管理外である．

<br>

### S3

#### ・バケットポリシー

S3アタッチされる，自身へのアクセスを制御するためにインラインポリシーのこと．詳しくは，AWSのノートを参照せよ．定義したバケットポリシーは，```aws_s3_bucket_policy```でロールにアタッチできる．

#### ・ALBアクセスログ

ALBがバケットにログを書き込めるように，『ELBのサービスアカウントID』を許可する必要がある．

**＊実装例＊**

```hcl
###############################################
# S3 bucket policy
###############################################

# S3にバケットポリシーをアタッチします．
resource "aws_s3_bucket_policy" "alb" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = templatefile(
    "${path.module}/policies/alb_bucket_policy.tpl",
    {}
  )
}
```

ALBのアクセスログを送信するバケット内には，自動的に『/AWSLogs/<アカウントID>』の名前でディレクトリが生成される．そのため，『```arn:aws:s3:::<バケット名>/*```』の部分を最小権限として，『```arn:aws:s3:::<バケット名>/AWSLogs/<アカウントID>/;*```』にしてもよい．東京リージョンのELBサービスアカウントIDは，『582318560864』である．

参考：https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::582318560864:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::<バケット名>/*"
    }
  ]
}
```

#### ・NLBアクセスログ

ALBがバケットにログを書き込めるように，『```delivery.logs.amazonaws.com```』からのアクセスを許可する必要がある．

**＊実装例＊**

```hcl
###############################################
# S3 bucket policy
###############################################

# S3にバケットポリシーをアタッチします．
resource "aws_s3_bucket_policy" "nlb" {
  bucket = aws_s3_bucket.nlb_logs.id
  policy = templatefile(
    "${path.module}/policies/nlb_bucket_policy.tpl",
    {}
  )
}
```

NLBのアクセスログを送信するバケット内には，自動的に『/AWSLogs/<アカウントID>』の名前でディレクトリが生成される．そのため，『```arn:aws:s3:::<バケット名>/*```』の部分を最小権限として，『```arn:aws:s3:::<バケット名>/AWSLogs/<アカウントID>/;*```』にしてもよい．

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSLogDeliveryWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::<バケット名>/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Sid": "AWSLogDeliveryAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::<バケット名>"
    }
  ]
}
```

<br>

### WAF

#### ・ruleブロック

**＊実装例＊**

API Gateway用のWAFに，特定のユーザエージェントを拒否するルールを設定する．

```hcl
resource "aws_wafv2_web_acl" "api_gateway" {

  rule {
    name     = "block-user-agents"
    priority = 0

    statement {

      regex_pattern_set_reference_statement {
        # 別ディレクトリのmain.tfファイルに分割した正規表現パターンセットを参照する．      
        arn = var.wafv2_regex_pattern_set_regional_block_user_agents_arn

        field_to_match {
          # ヘッダーを検証する．
          single_header {
            name = "user-agent"
          }
        }

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "APIGatewayWAFBlockUserAgentsRule"
      sampled_requests_enabled   = true
    }
  }
  
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "APIGatewayALBWAFRules"
    sampled_requests_enabled   = true
  }  
  
  # ～ 省略 ～  
  
}  
```
**＊実装例＊**

API Gateway用のWAFに，特定のグローバルIPアドレスを拒否するルールを設定する．

```hcl
resource "aws_wafv2_web_acl" "api_gateway" {

  rule {
    name     = "block-global-ip-addresses"
    priority = 0

    statement {

      ip_set_reference_statement {
        # 別ディレクトリのmain.tfファイルに分割したIPアドレスセットを参照する．
        arn = var.waf_blocked_global_ip_addresses
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "APIGatewayWAFBlockGlobalIPAddressesRule"
      sampled_requests_enabled   = true
    }
   
  }
  
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "APIGatewayWAFRules"
    sampled_requests_enabled   = true
  }  
  
  # ～ 省略 ～
  
}  
```
**＊実装例＊**

API Gateway用のWAFに，SQLインジェクションを拒否するマネージドルールを設定する．

```hcl
resource "aws_wafv2_web_acl" "api_gateway" {

  rule {
    name     = "block-sql-injection"
    priority = 0

    statement {

      # マネージドルールを使用する．
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }

    override_action {
      count {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "APIGatewayWAFBlockSQLInjectionRule"
      sampled_requests_enabled   = true
    }
  }
  
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "APIGatewayWAFRules"
    sampled_requests_enabled   = true
  }  
  
  # ～ 省略 ～
  
}
```

**＊実装例＊**

ALB用のWAFに，APIキーまたはBearerトークンをOR条件ルールを設定する．あくまで例としてで，本来であれば，別々のルールとした方が良い．

```hcl
resource "aws_wafv2_web_acl" "api_gateway" {

  # x-api-keyヘッダーにAPIキーを含むリクエストを許可します．
  rule {
    name     = "allow-request-including-api-key"
    priority = 3

    statement {

      or_statement {

        # APIキーを持つのリクエストを許可します．
        statement {

          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = var.waf_api_key_ssm_parameter_value

            field_to_match {

              single_header {
                name = "x-api-key"
              }
            }

            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }

        # Bearerトークンを持つリクエストを許可します．        
        statement {

          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = var.waf_bearer_token_ssm_parameter_value

            field_to_match {

              single_header {
                name = "authorization"
              }
            }

            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }

    action {
      allow {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "APIGatewayWAFAllowRequestIncludingAPIKeyRule"
      sampled_requests_enabled   = true
    }
  }
  
  # ～ 省略 ～  
  
}  
```

#### ・IPセットの依存関係

WAFのIPセットと他設定の依存関係に癖がある．新しいIPセットへの付け換えと古いIPセットの削除を同時にデプロイしないようにする．もし同時に行った場合，Terraformは古いIPセットの削除処理を先に実行するが，これはWAFに紐づいているため，ここでエラーが起こってしまう．そのため，IPセットを新しく設定し直す場合は，以下の通り二つの段階に分けてデプロイするようにする．ちなみに，IPセットの名前を変更する場合は，更新処理ではなく削除を伴う再構築処理が実行されるため注意する．

1. 新しいIPセットのresourceを実装し，ACLに関連付け，デプロイする．
2. 古いIPセットのresourceを削除し，デプロイする．

もし，これを忘れてしまった場合は，画面上で適当なIPセットに付け換えて，削除処理を実行できるようにする．

<br>

### 共通の設定

#### ・Terraform管理外のAWSリソース

以下のAWSリソースはTerraformで管理しない方が便利である．また，AWSの仕様上の理由で，管理外になってしまうものもある．Terraformの管理外のリソースには，コンソール画面上から，「```Not managed by = Terraform```」というタグをつけた方が良い．

| AWSリソース                  | 管理外の部分                                     | 管理外の理由                                                 |
| ---------------------------- | ------------------------------------------------ | ------------------------------------------------------------ |
| API Gateway，紐づくVPCリンク | 全て                                             | バックエンドチームがスムーズにAPIを構築できるようにするため． |
| Chatbot                      | 全て                                             | AWSがAPIを公開していないため，Terraformで構築できない．      |
| EC2                          | 秘密鍵                                           | Terraformで構築する時にGitHubで秘密鍵を管理する必要があるため，セキュリティ上の理由で却下する． |
| Global Accelerator           | セキュリティグループ                             | リソースを構築するとセキュリティグループが自動生成されるため，セキュリティグループのみTerraformで管理できない． |
| IAMユーザ                    | 全て                                             |                                                              |
| IAMユーザグループ            | 全て                                             |                                                              |
| IAMロール                    | ・ユーザに紐づくロール<br>・サービスリンクロール | サービスリンクロールは，AWSリソースの構築に伴って，自動的に作られるため，Terraformで管理できない．ただし，数が多いためあえて行わないが，Terraformで構築してAWSリソースに関連付けることもことも可能である． |
| Network Interface            | 全て                                             | 他のAWSリソースの構築に伴って，自動的に構築されるため，Terraformで管理できない． |
| RDS                          | admin以外のユーザ                                | 個別のユーザ作成のために，mysql providerという機能を使用する必要がある．しかし，使用する上でディレクトリ構成戦略と相性が悪い． |
| Route53                      | ネームサーバーレコード                           | ホストゾーンを作成すると，レコードとして，ネームサーバレコードの情報が自動的に設定される．これは，Terraformの管理外である． |
| S3                           | tfstateの管理バケット                            | tfstateファイルを格納するため，Terraformのデプロイより先に存在している必要がある． |
| SSMパラメータストア          | 全て                                             | ECSに機密な環境変数を出力するため．                          |

#### ・削除保護機能のあるAWSリソース

削除保護設定のあるAWSリソースに癖がある．削除保護の無効化とリソースを削除を同時にデプロイしないようにする．もし同時に行った場合，削除処理を先に実行するが，削除は保護されたままなので，エラーになる．エラーになる．そのため，このAWSリソースを削除する時は，以下の通り二つの段階に分けてデプロイするようにする．

1. 削除保護を無効化（`false`）に変更し，デプロイする．
2. ソースコードを削除し，デプロイする．

もし，これを忘れてしまった場合は，画面上で削除処理を無効化し，削除処理を実行できるようにする．

| AWSリソース名 | Terraform上での設定名            |
| ------------- | -------------------------------- |
| ALB           | ```enable_deletion_protection``` |
| EC2           | ```disable_api_termination```    |
| RDS           | ```deletion_protection```        |

<br>

## 09. CircleCIとの組み合わせ

### circleci

#### ・設定ファイル

CI/CDの構成は以下の通りとした．

| env  | 説明                                                         |
| ---- | ------------------------------------------------------------ |
| dev  | プルリクのレビュー時に，コードの変更を検証するためのインフラ環境 |
| stg  | ステージング環境                                             |
| prd  | 本番環境                                                     |

| jobs        | 説明                                                         |
| ----------- | ------------------------------------------------------------ |
| plan        | aws-cliのインストールから```terraform plan -out```コマンドまでの一連の処理を実行する． |
| 承認ジョブ  |                                                              |
| apply       | stg環境またはprd環境にデプロイ                               |
| destroy_dev | プルリクでdev環境にデプロイしたインフラを削除する．          |

| workflows | 説明                                 |
| --------- | ------------------------------------ |
| feature   | featureブランチからdev環境にデプロイ |
| develop   | developブランチからstg環境にデプロイ |
| main      | mainブランチからprd環境にデプロイ    |

```yaml
version: 2.1

executors:
  primary_container:
    parameters:
      env:
        type: enum
        enum: [ "dev", "stg", "prd" ]
    docker:
      - image: hashicorp/terraform:x.xx.x
    working_directory: ~/example_infrastructure
    environment:
      ENV: << parameters.env >>

commands:
  # AWSにデプロイするための環境を構築します．
  aws_setup:
    steps:
      - run:
          name: Install jq
          command: |
            apk add curl
            curl -o /usr/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
            chmod +x /usr/bin/jq
      - run:
          name: Install aws-cli
          command: |
            apk add python3
            apk add py-pip
            pip3 install awscli
            aws --version
      - run:
          name: Assume role
          command: |
            set -x
            source ./ops/assume.sh

  # terraform initを行います．
  terraform_init:
    steps:
      - run:
          name: Terraform init
          command: |
            set -x
            source ./ops/terraform_init.sh

  # terraform fmtを行います．
  terraform_fmt:
    steps:
      - run:
          name: Terraform fmt
          command: |
            set -x
            source ./ops/terraform_fmt.sh
            
  # terraform validateを行います．
  terraform_validate:
    steps:
      - run:
          name: Terraform validate
          command: |
            set -x
            source ./ops/terraform_validate.sh

  # terraform planを行います．
  terraform_plan:
    steps:
      - run:
          name: Terraform plan
          command: |
            set -x
            source ./ops/terraform_plan.sh
            ls -la

  # terraform applyを行います．
  terraform_apply:
    steps:
      - run:
          name: Terraform apply
          command: |
            set -x
            ls -la
            source ./ops/terraform_apply.sh

  # dev環境に対して，terraform destroyを行います．
  terraform_destroy_dev:
    steps:
      - run:
          name: Terraform destroy dev
          command: |
            set -x
            source ./ops/terraform_destroy_dev.sh

jobs:
  plan:
    parameters:
      exr:
        type: executor
    executor: << parameters.exr >>
    steps:
      - checkout
      - aws_setup
      - terraform_init
      - terraform_fmt
      - terraform_validate
      - terraform_plan
      - persist_to_workspace:
          root: .
          paths:
            - .

  apply:
    parameters:
      exr:
        type: executor
    executor: << parameters.exr >>
    steps:
      - attach_workspace:
          at: .
      - terraform_apply

  destroy_dev:
    parameters:
      exr:
        type: executor
    executor: << parameters.exr >>
    steps:
      - checkout
      - aws_setup
      - terraform_init
      - terraform_destroy_dev

workflows:
  # Dev env
  feature:
    jobs:
      - plan:
          name: plan_dev
          exr:
            name: primary_container
            env: dev
          filters:
            branches:
              only:
                - /feature.*/
      - apply:
          name: apply_dev
          exr:
            name: primary_container
            env: dev
          requires:
            - plan_dev

  # Staging env
  develop:
    jobs:
      - plan:
          name: plan_stg
          exr:
            name: primary_container
            env: stg
          filters:
            branches:
              only:
                - develop
      - hold_apply:
          name: hold_apply_stg
          type: approval
          requires:
            - plan_stg
      - apply:
          name: apply_stg
          exr:
            name: primary_container
            env: stg
          requires:
            - hold_apply_stg
      - hold_destroy_dev:
          type: approval
          requires:
            - apply_stg
      - destroy_dev:
          exr:
            name: primary_container
            env: dev
          requires:
            - hold_destroy_dev

  # Production env
  main:
    jobs:
      - plan:
          name: plan_prd
          exr:
            name: primary_container
            env: prd
          filters:
            branches:
              only:
                - main
      - hold_apply:
          name: hold_apply_prd
          type: approval
          requires:
            - plan_prd
      - apply:
          name: apply_prd
          exr:
            name: primary_container
            env: prd
          requires:
            - hold_apply_prd
```

<br>

### シェルスクリプト

#### ・assume_role.sh

AWSのノートを参照せよ．

#### ・terraform_apply.sh

```shell
#!/bin/bash

set -xeuo pipefail

# credentialsの情報を出力します．
source ./aws_envs.sh

terraform -chdir=./${ENV} apply \
  -parallelism=30 \
  ${ENV}.tfplan | ./ops/tfnotify --config ./${ENV}/tfnotify.yml apply
```

#### ・terraform_destroy_dev.sh

```shell
#!/bin/bash

set -xeuo pipefail

if [ $ENV = "dev" ]; then
    # credentialsの情報を出力します．
    source ./aws_envs.sh
    terraform -chdir=./${ENV} destroy -var-file=config.tfvars
else
    echo "The parameter ${ENV} is invalid."
    exit 1
fi

```

#### ・terraform_fmt.sh

```shell
#!/bin/bash

set -xeuo pipefail

terraform fmt \
  -recursive \
  -check
```

#### ・terraform_init.sh

```shell
#!/bin/bash

set -xeuo pipefail

# credentialsの情報を出力します．
source ./aws_envs.sh

terraform -chdir=./${ENV} init \
  -upgrade \
  -reconfigure \
  -backend=true \
  -backend-config="bucket=${ENV}-tfstate-bucket" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="encrypt=true"
```

#### ・terraform_plan.sh

```shell
#!/bin/bash

set -xeuo pipefail

# credentialsの情報を出力します．
source ./aws_envs.sh

terraform -chdir=./${ENV} plan \
  -var-file=./${ENV}/config.tfvars \
  -out=${ENV}.tfplan \
  -parallelism=30 | ./ops/tfnotify --config ./${ENV}/tfnotify.yml plan
```

#### ・terraform_validate.sh

```shell
#!/bin/bash

set -xeuo pipefail

terraform -chdir=./${ENV} validate
```

<br>

### tfnotify

#### ・tfnotifyとは

terraformの```plan```または```apply```の処理結果を，POSTで送信するバイナリファイルのこと．URLや送信内容を設定ファイルで定義する．

#### ・コマンド

CircleCIで利用する場合は，commandの中で，以下からダウンロードしたtfnotifyのバイナリファイルを実行する．環境別にtfnotifyを配置しておくとよい．

https://github.com/mercari/tfnotify/releases/tag/v0.7.0

```shell
#!/bin/bash

set -xeuo pipefail

terraform -chdir=./${ENV} plan | ./ops/tfnotify --config ./${ENV}/tfnotify.yml plan
```

#### ・設定ファイル

**＊実装例＊**

例として，GitHubの特定のリポジトリのプルリクエストにPOSTで送信する．

```yaml
# https://github.com/mercari/tfnotify
---
ci: circleci

notifier:
  github:
    token: <環境変数に登録したGitHubToken>
    repository:
      owner: "<送信先のユーザ名もしくは組織名>"
      name: "<送信先のリポジトリ名>"

terraform:
  plan:
    template: |
      {{ .Title }} for staging <sup>[CI link]( {{ .Link }} )</sup>
      {{ .Message }}
      {{if .Result}}
      <pre><code> {{ .Result }}
      </pre></code>
      {{end}}
      <details><summary>Details (Click me)</summary>

      <pre><code> {{ .Body }}
      </pre></code></details>
  apply:
    template: |
      {{ .Title }}
      {{ .Message }}
      {{if .Result}}
      <pre><code>{{ .Result }}
      </pre></code>
      {{end}}
      <details><summary>Details (Click me)</summary>

      <pre><code>{{ .Body }}
      </pre></code></details>
```

