# skaffoldコマンド

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

アプリケーションのソースコードを監視し、変更が検出された時に、イメージの再ビルド/プッシュ/デプロイを実行する。

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

バックグラウンドで、イメージのビルド/デプロイを実行する。

#### ・--no-prune、--cache-artifacts

イメージをキャッシュせず、また後処理で全てのイメージを削除しつつ、```run```コマンドを実行する。

```bash
$ skaffold run --no-prune=false --cache-artifacts=false
```

#### ・--tail

フォアグラウンドで```run```コマンドを実行する。

```bash
$ skaffold run --tail
```

