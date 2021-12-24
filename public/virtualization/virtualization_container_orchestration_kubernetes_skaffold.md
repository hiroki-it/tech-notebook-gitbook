# skaffold

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. コマンド

### build

#### ・buildとは

全てのイメージをビルドする。

参考：https://skaffold.dev/docs/references/cli/#skaffold-build

#### ・--cache-artifacts

キャッシュを無効化し、```build```コマンドを実行する。

```bash
$ skaffold build --cache-artifacts=false
```

<br>

### dev

#### ・dev

アプリケーションのソースコードを監視し、変更が検出された時に、イメージの再ビルド／プッシュ／デプロイを実行する。

#### ・--trigger

一定間隔でソースコードの変更を監視しつつ、```dev```コマンドを実行する。

```bash
$ skaffold dev --trigger=polling
```

#### ・--no-prune、--cache-artifacts

イメージをキャッシュせず、また後処理で全てのイメージを削除しつつ、```dev```コマンドを実行する。

```bash
$ skaffold dev --no-prune=false --cache-artifacts=false
```

<br>

#### ・run

バックグラウンドで、イメージのビルド／デプロイを実行する。

#### ・--tail

フォアグラウンドで```run```コマンドを実行する。

```bash
$ skaffold run --tail
```

<br>

## 02. apiVersion

参考：https://skaffold.dev/docs/references/yaml/#apiVersion

```yaml
apiVersion: skaffold/v2beta1
```

<br>

## 03. build

### artifacts

#### ・image

ビルドされるイメージの名前を設定する。

参考：https://skaffold.dev/docs/references/yaml/#build-artifacts-image

```yaml
build:
  artifacts:
    - image: foo-app
    - image: foo-web
    - image: bar-app
    - image: bar-web
```

#### ・context

マイクロサービスのルートまでのファイルパスを設定する。

参考：https://skaffold.dev/docs/references/yaml/#build-artifacts-context

```yaml
build:
  artifacts:
    - image: foo-app
      context: ./src/foo
    - image: foo-web
      context: ./src/foo
    - image: bar-app
      context: ./src/bar
    - image: bar-web
      context: ./src/bar    
```

<br>

#### ・docker

| 項目       | 説明                                                         | 補足                                                         |
| ---------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| dockerfile | マイクロサービスのルートからDockerfileまでのファイルパスを設定する。 | https://skaffold.dev/docs/references/yaml/#build-artifacts-docker-dockerfile |
| target     | ビルドするイメージのステージを設定する。                     | https://skaffold.dev/docs/references/yaml/#build-artifacts-docker-target |

```yaml
build:
  artifacts:
    - image: foo-app
      context: ./src/foo
      docker:
        dockerfile: ./docker/app/Dockerfile
    - image: foo-web
      context: ./src/foo
      docker:
        dockerfile: ./docker/web/Dockerfile
        target: development
    - image: bar-app
      context: ./src/bar
      docker:
        dockerfile: ./docker/app/Dockerfile
    - image: bar-web
      context: ./src/bar
      docker:
        dockerfile: ./docker/web/Dockerfile
        target: development
```

<br>

### local

#### ・useBuildkit

BuildKit機能の有効化を設定する。BuildKitではイメージレイヤーが並列的に構築されるため、ビルド時間を従来よりも短縮できる。

参考：https://genzouw.com/entry/2021/07/17/100615/2724/

```yaml
build:
  local:
    useBuildkit: false
```

<br>

### tagPolicy

#### ・gitCommit

コミットIDをイメージタグとして設定する。

参考：https://skaffold.dev/docs/pipeline-stages/taggers/#gitcommit-uses-git-commitsreferences-as-tags

```yaml
build:
  tagPolicy:
    gitCommit: {}
```

#### ・sha256

sha256ハッシュ値と```latest```タグをイメージタグとして設定する。

参考：https://skaffold.dev/docs/pipeline-stages/taggers/#sha256-uses-latest-to-tag-images

```yaml
build:
  tagPolicy:
    sha256: {}
```

<br>

## 04. deploy

### kubectl

#### ・manifests

```yaml
deploy:
  kubectl:
    manifests:
      - ./kubernetes-manifests/**/**.yml
```

<br>

## 05. kind

```yaml
kind: Config
```

