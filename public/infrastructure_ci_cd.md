# CI & CD

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. CICDパイプライン

#### ・CICDパイプラインとは

Commitから本番環境へのDeployまでのプロセスを『継続的に』行うことを，CI：Continuous Integration』という．また，変更内容をステージング環境などに自動的に反映し，『継続的に』リリースすることを，CD：Continuous Deliveryという．

![CICDパイプライン](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/CICDパイプライン.png)

####  ・自動化できるプロセスとできないプロセス

| プロセス                       | 自動化の可否 | 説明                                             |
| ------------------------------ | ------------ | ------------------------------------------------ |
| Build                          | 〇           | CI/CDツールとIaCツールで自動化可能               |
| Unitテスト，Functionalテスト   | 〇           | CI/CDツールとテストフレームワークで自動化可能．  |
| Integrationテスト              | ✕            | テスト仕様書を作成し，動作を確認する必要がある． |
| コーディング規約に関するReview | 〇           | CI/Cdツールと静的解析ツール                      |
| 仕様に関するReview             | ✕            | GitHub上でレビューする必要がある．               |
| ステージング環境へのデプロイ   | 〇           | CI/CDツールで自動化可能．                        |
| 本番環境へのデプロイ           | 〇           | CI/CDツールで自動化可能．                        |
