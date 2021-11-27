# TerraformのCICDフロー

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. CircleCIを用いたCICD

### 要素

#### ・環境

| env  | 説明                                                         |
| ---- | ------------------------------------------------------------ |
| dev  | プルリクのレビュー時に、コードの変更を検証するためのインフラ環境 |
| stg  | ステージング環境                                             |
| prd  | 本番環境                                                     |

#### ・ジョブ

| jobs       | 説明                                                         |
| ---------- | ------------------------------------------------------------ |
| plan       | aws-cliのインストールから```terraform plan -out```コマンドまでの一連の処理を実行する。 |
| 承認ジョブ |                                                              |
| apply      | stg環境またはprd環境にデプロイ                               |

#### ・ワークフロー

| workflows | 説明                                 |
| --------- | ------------------------------------ |
| feature   | featureブランチからdev環境にデプロイ |
| develop   | developブランチからstg環境にデプロイ |
| main      | mainブランチからprd環境にデプロイ    |

<br>

### ```config.yml```ファイル

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
    working_directory: ~/foo_infrastructure
    environment:
      ENV: << parameters.env >>

commands:
  # AWSにデプロイするための環境を構築します。
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

  # terraform initを行います。
  terraform_init:
    steps:
      - run:
          name: Terraform init
          command: |
            set -x
            source ./ops/terraform_init.sh

  # terraform fmtを行います。
  terraform_fmt:
    steps:
      - run:
          name: Terraform fmt
          command: |
            set -x
            source ./ops/terraform_fmt.sh
            
  # terraform validateを行います。
  terraform_validate:
    steps:
      - run:
          name: Terraform validate
          command: |
            set -x
            source ./export_aws_envs.sh
            source ./ops/terraform_validate.sh

  # terraform planを行います。
  terraform_plan:
    steps:
      - run:
          name: Terraform plan
          command: |
            set -x
            source ./export_aws_envs.sh
            source ./ops/terraform_plan.sh
            ls -la

  # terraform applyを行います。
  terraform_apply:
    steps:
      - run:
          name: Terraform apply
          command: |
            set -x
            ls -la
            source ./export_aws_envs.sh
            source ./ops/terraform_apply.sh

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

workflows:
  # Development env
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
              ignore: /.*/
            tags:
              only: /release\/.*/
      - hold_apply:
          name: hold_apply_prd
          type: approval
          requires:
            - plan_prd
          filters:
            branches:
              ignore: /.*/
            tags:
              only: /release\/.*/
      - apply:
          name: apply_prd
          exr:
            name: primary_container
            env: prd
          requires:
            - hold_apply_prd
          filters:
            branches:
              ignore: /.*/
            tags:
              only: /release\/.*/
```

<br>

### シェルスクリプト

#### ・```assume_role.sh```ファイル

参考：

<br>

#### ・```terraform_apply.sh```ファイル

```bash
#!/bin/bash

set -xeuo pipefail

# credentialsの情報を出力します。
source ./aws_envs.sh

terraform -chdir=./${ENV} apply \
  -parallelism=30 \
  ${ENV}.tfplan | ./ops/tfnotify --config ./${ENV}/tfnotify.yml apply
```

<br>

#### ・```terraform_fmt.sh```ファイル

```bash
#!/bin/bash

set -xeuo pipefail

terraform fmt \
  -recursive \
  -check
```

<br>

#### ・```terraform_init.sh```ファイル

```bash
#!/bin/bash

set -xeuo pipefail

# credentialsの情報を出力します。
source ./aws_envs.sh

terraform -chdir=./${ENV} init \
  -upgrade \
  -reconfigure \
  -backend=true \
  -backend-config="bucket=${ENV}-tfstate-bucket" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="encrypt=true"
```

<br>

#### ・```terraform_plan.sh```ファイル

```bash
#!/bin/bash

set -xeuo pipefail

# credentialsの情報を出力します。
source ./aws_envs.sh

terraform -chdir=./${ENV} plan \
  -var-file=./${ENV}/foo.tfvars \
  -out=${ENV}.tfplan \
  -parallelism=30 | ./ops/tfnotify --config ./${ENV}/tfnotify.yml plan
```

<br>

#### ・```terraform_validate.sh```ファイル

```bash
#!/bin/bash

set -xeuo pipefail

terraform -chdir=./${ENV} validate
```

<br>

## 02. tfnotify

### tfnotifyとは

terraformの```plan```または```apply```の処理結果を、POSTで送信するバイナリファイルのこと。URLや送信内容を設定ファイルで定義する。

<br>

### コマンド

CircleCIで利用する場合は、commandの中で、以下からダウンロードしたtfnotifyのバイナリファイルを実行する。環境別にtfnotifyを配置しておくとよい。

https://github.com/mercari/tfnotify/releases/tag/v0.7.0

```bash
#!/bin/bash

set -xeuo pipefail

terraform -chdir=./${ENV} plan | ./ops/tfnotify --config ./${ENV}/tfnotify.yml plan
```

<br>

### 設定ファイル

あらかじめ、GitHubのアクセストークンを発行し、CIツールの環境変数に登録しておく。

**＊実装例＊**

例として、GitHubの特定のリポジトリのプルリクエストにPOSTで送信する。

```yaml
# https://github.com/mercari/tfnotify
---
ci: circleci

notifier:
  github:
    # 環境変数に登録したパーソナルアクセストークン
    token: $GITHUB_TOKEN
    repository:
      # 送信先のユーザ名もしくは組織名
      owner: "foo-company"
      name: "foo-repository"

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

<br>

## 03. リリース

### リリースの粒度

#### ・既存のリソースに対して、新しいリソースを紐づける場合

既存のリソースに対して、新しいリソースを紐づける場合、新しいリソースの構築と紐づけを別々にリリースする。経験則でcreate処理やdestroy処理よりもupdate処理の方がエラーが少ないため、インフラのロールバックで問題が起こりにくい。また、Terraformで問題が起こったとしても、変更点が紐づけだけなので、原因を追究しやすい。

#### ・Terraformとプロバイダーの両方をアップグレードする場合

Terraformとプロバイダーの両方をアップグレードする場合、Teraformとプロバイダーを別々にリリースする。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/infrastructure_as_code/infrastructure_as_code_terraform.html

<br>

### リリース後のロールバック

Terraformには、インフラのバージョンのロールバック機能がない。そこで、一つ前のリリースタグをRerunすることで、バージョンのロールバックを実行する。今回のリリースのcreate処理が少ないほどRerunでdestroy処理が少なく、反対にdestroy処理が少ないほどcreate処理が少なくなる。もしリリース時に問題が起こった場合、インフラのバージョンのロールバックを行う必要があるが、経験則でcreate処理やdestroy処理よりもupdate処理の方がエラーが少ないため、ロールバックにもたつきにくい。そのため、Rerun時にどのくらいのcreate処理やdestroy処理が実行されるかと考慮し、一つ前のリリースタグをRerunするか否かを判断する。

