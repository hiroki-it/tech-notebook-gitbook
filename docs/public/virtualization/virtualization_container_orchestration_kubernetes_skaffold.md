# skaffold

## 01. コマンド

### build

#### ・buildとは

イメージをビルドする。

参考：https://skaffold.dev/docs/references/cli/#skaffold-build

#### ・--cache-artifacts

キャッシュを無効化し、```build```コマンドを実行する。

```bash
$ skaffold build --cache-artifacts=false
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

