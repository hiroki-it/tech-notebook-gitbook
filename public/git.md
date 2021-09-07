# Gitの豆知識

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. トラブルシューティング

### 基点ブランチから二回派生するブランチマージする時の注意点

1. 基点ブランチから，一つ目のブランチにマージし，これをpushする．ここでpushしないと，2番目のブランチが一つ目のブランチとの差分を検出してしまい，大量の差分コミットがgithubに表示されてしまう．
2. 一つ目のブランチから二つ目のブランチにマージし．これをpushする．

<br>

### Conflictの解決方法とマージコミットの作成

1. ```git status```を行い，特定のファイルでのコンフリクトが表示される．

```shell
Unmerged paths:
  (use "git restore --staged <file>..." to unstage)
  (use "git add <file>..." to mark resolution)
        both modified:   XXX/YYY.twig
```

2. コンフリクトしていたコード行を取捨選択する．

```php
<?php
/// Phpstromにて，コンフリクトしていたコード行を取捨選択する．
```

3. 一度```add```を行い，コンフリクトの修正をGitに認識させる．

```shell
$ git add XXX/YYY.twig
```

4. ```git status```を行い，以下が表示される．コンフリクトが解決されたが，マージされていないと出力される．差分のファイルがたくさん表示される場合があるが，問題ない．

```shell
All conflicts fixed but you are still merging.

Changes to be committed:
        modified:   XXX
        modified:   XXX
```

5. ```git commit```（```-m```はつけてはいけない）を行い，vimエディタが表示される．

```shell
 Merge branch "ブランチ名" into ブランチ名
```

7. ```:wq```でエディタを終了すれば，コンフリクトを解消したマージコミットが作成される．

8. ```git status```を行う．場合によっては，差分のコミット数が表示されるが問題ない．

```shell
Your branch is ahead of "origin/feature/XXXX" by 10 commits.

```

9. pushする．この時，マージコミットを作成する時，基点ブランチ以外からマージしていると，差分のコミットが一つにまとまらず，

参考：http://www-creators.com/archives/1938

<br>

### Commitの粒度

データベースからフロント出力までに至る実装をCommitする場合，以下の3つを意識する．

1. データベースからCommit
2. 関連性のある実装をまとめてCommit
3. 一回のCommitがもつコード量が少なくなるようにCommit

<br>

### 誤って作成したプルリクの削除

不可能．
犯した罪は背負って生きていかなければならない．
参照：https://stackoverflow.com/questions/18318097/delete-a-closed-pull-request-from-github

<br>

## 02. Gitの準備

### clone：

#### ・```clone <HTTPS接続>```

一番，クローンの速度が速く，コマンドの引数も簡単．

```shell
$ git clone https://github.com/<組織名>/<リポジトリ名>.git
```

#### ・```clone <SSH接続>```

サーバ接続名は，，SSH接続の設定ファイル（```~/.ssh/config```）に記載されている．デフォルトでは，Githubの接続名は，「```github.com```」になっている．

```shell
$ git clone git@<ssh-configファイルでのサーバ接続名>:<組織名>/<リポジトリ名>.git
```

<br>

### config：

#### ・ 設定の影響範囲の種類

| 影響範囲 | 意味                           | 上書き順 | 設定ファイルの場所               |
| :------- | :----------------------------- | -------- | :------------------------------- |
| system   | 全PCユーザの全リポジトリ       | 1        | ```/etc/gitconfig```             |
| global   | 現在のPCユーザーの全リポジトリ | 2        | ```~/.gitconfig```               |
| local    | 現在のリポジトリ               | 3        | ```{リポジトリ名}/.git/config``` |

#### ・```config --<影響範囲> --list```

指定した影響範囲で適用されている設定値を表示する．```--local```で設定されていない項目は，```--global```の設定値が適用される．

```shell
$ git config --local --list
```

Macでは，一つのPCで二つのGutHubアカウントを使用する場合に，キーチェーンという機能で設定が必要になる．

リンク：https://sy-base.com/myrobotics/others/git-push_403error/

#### ・```config --<影響範囲> user.name```

AuthorとCommitterの名前を設定する．```local```が一番最後に上書きされ，適用される．

```shell
$ git config --local user.name "hiroki-it"
```


#### ・```config --<影響範囲> user.email```

AuthorとCommitterのメールアドレスを設定する．```local```が一番最後に上書きされ，適用される．

```shell
$ git config --local user.email "hasegawafeedshop@gmail.com"
```

Authorの情報は，コミット時に反映される．（Committerは表示されない）

```shell
$ git log

commit ee299250a4741555eb5027ad3e56ce782fe90ccb
Author: hiroki-it <xxxxx@gmail.com>
Date:   Sat Sep 12 00:00:00 2020 +0900

    add ◯◯を実装した．
```

#### ・```config --global core.autocrlf```

改行コードを，特定のタイミングで自動変換するように設定する．```input```としておくのが良い．

```shell
$ git config --global core.autocrlf <値>
```

| 設定値 | チェックアウト時 | コミット時 |
| :----: | :--------------: | :--------: |
| input  |    変換しない    | CRLF -> LF |
|  true  |    LF -> CRLF    | CRLF -> LF |
| false  |    変換しない    | 変換しない |

#### ・```config --global core.editor```

gitのデフォルトエディタを設定する．ここでは，Vimをデフォルトとする．

```shell
$ git config --global core.editor "vim -c "set fenc=utf-8""
```

<br>

### remote：

#### ・```remote set-url origin <SSH URL>```

プライベートリポジトリに接続する．```config```ファイルに記述されたユーザ名と接続名を設定する．一つのPCで複数のGitHubアカウントを使用している場合，設定が必須である．

```shell
$ git remote set-url origin <ユーザ名>@<接続名>:<組織名>/<リポジトリ名>.git
```

```
# リポジトリ１
Host <接続名1>
    User <リポジトリ１のユーザ名>
    Port 22
    HostName <リポジトリ１のホスト名>
    IdentityFile <秘密鍵へのパス>

# リポジトリ２
Host <接続名２>
    User <リポジトリ２のユーザ名>
    Port 22
    HostName <リポジトリ２のホスト名>
    IdentityFile <秘密へのパス>
```

<br>

## 03. Gitのコマンドメモ

### add：

#### ・```add --all```

変更した全てのファイルをaddする．

<br>

### branch：

#### ・```branch --all```
作業中のローカルブランチとリモート追跡ブランチを表示．

#### ・```branch --delete --force <ローカルブランチ名>```
プッシュとマージの状態に関係なく，ローカルブランチを削除．

#### ・```branch --move <新しいローカルブランチ名>```
作業中のローカルブランチの名前を変更．

#### ・```branch --delete --remote origin/<ローカルブランチ名>```
リモート追跡ブランチを削除．
（１）まず，```branch --all```で作業中のローカルブランチとリモート追跡ブランチを表示．

```shell
$ git branch --all
* master
  remotes/origin/2019/Symfony_Nyumon/master
  remotes/origin/master
```

（２）```remotes/origin/2019/Symfony_Nyumon/master```を削除．

```shell
$ git branch -d -r origin/2019/Symfony_Nyumon/master
Deleted remote-tracking branch origin/2019/Symfony_Nyumon/master (was 18a31b5).
```

（３）再び，```branch --all```で削除されたことを確認．

```shell
$ git branch --all
* master
  remotes/origin/master
```

#### ・```branch checkout -b <新しいローカルブランチ名> <コミット番号>```

```shell
$ git checkout -b feature/3 d7e49b04
```

指定のコミットから新しいブランチを生やすことができる．

<br>

### stash：

#### ・```stash```とは

ファイルが，『インデックス』（=```add```）あるいは『HEAD』（=```commit```）に存在している状態で，異なるローカルブランチを```checkout```しようとすると，以下のエラーが出る．

```shell
$ git checkout 2019/Symfony2_Ny
umon/master
error: Your local changes to the following files would be overwritten by checkout:
        app/config/config.yml
        src/AppBundle/Entity/Inquiry.php
Please commit your changes or stash them before you switch branches.
Aborting
```

この場合，一度```stash```を行い，『インデックス』（=```add```）あるいは『HEAD』（=```commit```）を横に置いておく必要がある．

#### ・```stash -u --include-untracked```
トラッキングされていないファイルも含めて，全てのファイルを退避．
```git status```をしたところ，修正ファイルが３つ，トラックされていないファイルが１つある．

```shell
$ git status
On branch 2019/Symfony2_Nyumon/feature/6
Your branch is up to date with "origin/2019/Symfony2_Nyumon/feature/6".

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/Resources/views/Inquiry/index.html.twig
        modified:   app/config/config.yml
        modified:   src/AppBundle/Entity/Inquiry.php

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        app/Resources/views/Toppage/menu.html.twig

no changes added to commit (use "git add" and/or "git commit -a")
```

これを，```stash -u```する

```shell
$ git stash -u
Saved working directory and index state WIP on 2019/Symfony2_Nyumon/feature/6: 649995e update #6 xxx
```

これらのファイルの変更点を一時的に退避できる．

#### ・```stash -- <パス> ```

特定のディレクトリやファイルのみ```stash```することができる．

```shell
git stash -- src/...
```

#### ・```stash list```
退避している『ファイル番号：ブランチ：親コミットとコミットメッセージ』を一覧で表示．

```shell
$ git stash list
stash@{0}: WIP on 2019/Symfony2_Nyumon/feature/6: 649995e update #6 xxx
```

#### ・```stash pop stash@{<番号>}```
退避している指定のファイルを復元．

```shell
$ git stash pop stash@{0}
On branch 2019/Symfony2_Nyumon/feature/8
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   app/Resources/views/Inquiry/index.html.twig
        modified:   app/config/config.yml
        modified:   src/AppBundle/Entity/Inquiry.php

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        app/Resources/views/Toppage/menu.html.twig

no changes added to commit (use "git add" and/or "git commit -a")
```

#### ・```stash drop stash@{<番号>}```
退避している指定のファイルを復元せずに削除．

```shell
$ git stash drop stash@{0}
Dropped refs/stash@{0} (1d0ddeb9e52a737dcdbff7296272080e9ff71815)
```

#### ・```stash clear```
退避している全てのファイルを復元せずに削除．

```shell
$ git stash clear
```

<br>

### revert：

#### ・```revert```とは

作業中のローカルブランチにおいて，指定の履歴を削除．

![revert.png](https://qiita-image-store.s3.amazonaws.com/0/292201/995d8f16-0a3e-117f-945f-c20a511edeaf.png)

#### ・```revert <コミットID> --no-edit```

指定したコミットのみを打ち消す新しいコミットを作成する．コミットメッセージは，打ち消すコミットと同じものになる．リリース後に元に戻したい時に役立つ．

```shell
$ git revert <コミットID> --no-edit
```

#### ・```revert <コミットID> --edit```

指定したコミットのみを打ち消す新しいコミットを作成する．vimが起動するので，コミットメッセージを新しいものに変更する．

```shell
$ git revert <コミットID> --edit
```

#### ・```revert -m <マージナンバー> <マージコミットID>```

指定したマージコミットのみを打ち消す新しいコミットを作成する．コミットメッセージは，打ち消すコミットと同じものになる．マージナンバーを事前に確認しておく必要がある．

```shell
$ git show
commit xyz
Merge: 1a1a1a 2b2b2b    #ここに注目
Author: xxxx xxxx
Date:   Thu Jul 13 09:00:00 2017 +0000

    Merge commit
    
$ git revert -m 1 xyz
```

<br>

### reset：

#### ・```reset```とは

作業中のローカルブランチにおいて，指定の履歴まで戻し，それ以降を削除．

![reset.png](https://qiita-image-store.s3.amazonaws.com/0/292201/e96468c4-57cc-bf2b-941a-d179ac829627.png)

#### ・```reset HEAD <ファイル名／ファイルパス>```
インデックスから，指定したファイルを削除．

```shell
$ git reset HEAD <ファイル名／ファイルパス>
```

#### ・```reset --soft <コミットID>```
作業中のローカルブランチにおいて，最新のHEAD（=```commit```後）を指定の履歴まで戻し，それ以降を削除する．```commit```のみを取り消したい場合はこれ．

```shell
$ git reset --soft <コミットID>
```

#### ・```reset --mixed <コミットID>```
作業中のローカルブランチにおいて，インデックス（=```add```後），HEAD（=```commit```後）を指定の履歴まで戻し，それ以降を削除．```add```と```commit```を取り消したい場合はこれ．

```shell
$ git reset --mixed <コミットID>
```

#### ・```reset --hard <コミットID>```
作業中のローカルブランチにおいて，最新のワークツリー（=フォルダ），インデックス（=```add```後），HEAD（=```commit```後）を指定の履歴まで戻し，それ以降を削除．
<font color="red">**ワークツリー（=フォルダ）内のファイルの状態も戻ってしまうので，取り扱い注意！！**</font>

```shell
$ git reset --hard <コミットID>
```

#### ・```reset```の使用例

1. まず，```log ```コマンドで，作業中のローカルブランチにおけるコミットIDを確認．

```shell
$ git log
commit f17f68e287b7d84318b4c49e133b2d1819f6c3db (HEAD -> master, 2019/Symfony2_Nyumon/master)
Merge: 41cc21b f81c813
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 22:56:32 2019 +0900

    Merge remote-tracking branch "refs/remotes/origin/master"

commit 41cc21bb53a8597270b5deae3259751df18bce81
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 20:54:34 2019 +0900

    add #0 xxxさんのREADME_2を追加

commit f81c813a1ead9a968c109671e6d83934debcab2e
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 20:54:34 2019 +0900

    add #0 xxxさんのREADME_1を追加
```

2. 指定のコミットまで履歴を戻す．

```shell
$ git reset --soft f81c813a1ead9a968c109671e6d83934debcab2e
```

3. ```log ```コマンドで，正しく変更されているか確認．

```shell
$ git log
commit f81c813a1ead9a968c109671e6d83934debcab2e (HEAD -> master)
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 20:54:34 2019 +0900

    add 新しいREADMEを追加
```

4. ```push --force```でローカルリポジトリの変更をリモートリポジトリに強制的に反映．
   <font color="red">**『強制的にpushした』というログも，リモート側には残らない．**</font>

```shell
$ git push --force
Total 0 (delta 0), reused 0 (delta 0)
To github.com:hiroki-it/Symfony2_Nyumon.git
 + f0d8b1a...f81c813 master -> master (forced update)
```

### rebase：

#### ・```rebase```とは（注意点あり）

作業中のローカルブランチにおいて，ブランチの派生元を変更．リモートブランチにpushした後は使ってはならず，他のコマンドを使う．

#### ・```rebase --interactive <コミットID>```

派生元を変更する機能を応用して，過去のコミットのメッセージ変更，削除，統合などを行う．

**＊コマンド例（コミットメッセージの変更）＊**

1. まず，```log ```コマンドで，作業中のローカルブランチにおけるコミットIDを確認．

```shell
$ git log
commit f17f68e287b7d84318b4c49e133b2d1819f6c3db (HEAD -> master, 2019/Symfony2_Nyumon/master)
Merge: 41cc21b f81c813
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 22:56:32 2019 +0900

    Merge remote-tracking branch "refs/remotes/origin/master"

commit 41cc21bb53a8597270b5deae3259751df18bce81
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 20:54:34 2019 +0900

    add #0 xxxさんのREADME_2を追加

commit f81c813a1ead9a968c109671e6d83934debcab2e
Author: Hiroki Hasegawa <xxx@gmail.com>
Date:   Wed Mar 20 20:54:34 2019 +0900

    add #0 xxxさんのREADME_1を追加
```

2. 指定した履歴の削除

```shell
$ git rebase --interactive 41cc21bb53a8597270b5deae3259751df18bce81
```
とすると，タブが表示され，指定のコミットIDの履歴が表示される

```shell
pick b1b5c0f add #0 xxxxxxxxxx
```

『挿入モード』に変更し，この一行の```pick```を```edit```に変更．その後，

```shell
:w
```

として保存．その後，エディタ上で『Ctrl+C』を押し，

```shell
:qa!
```

で終了．

3. ```commit --amend```に```m```オプションを付けて，メッセージを変更．

```shell
$ git commit --amend -m="<変更後のメッセージ>"
```

4. ```rebase --continue```を実行し，変更を反映させる．

```shell
$ git rebase --continue
Successfully rebased and updated refs/heads/develop.
```

5. ```push```しようとすると，```![rejected] develop -> develop (non-fast-forward)```とエラーが出るので，

```shell
$ git merge <ブランチ名> --allow-unrelated-histories
```
で解決し，```push```する．

**＊コマンド例（Author名とCommiter名の変更）＊**

1. ハッシュ値を指定して，```rebase```コマンドを実行する．

```shell
$ git rebase --interactive 41cc21bb53a8597270b5deae3259751df18bce81
```

2. ```commit --amend```に```reset-author```オプションを付けて，configで設定した名前をAuthor名とComitter名に適用する．

```shell
$ git commit --amend --reset-author
```

3. ```rebase --continue```を実行し，変更を反映させる．

```shell
$ git rebase --continue
Successfully rebased and updated refs/heads/develop.
```

過去の全てのコミットに対して，Author名とCommitter名を適用するコマンドもある．しかし，危険な方法であるため，個人利用のリポジトリのみで使用するようにするべきである．

```shell
#!/bin/bash

git filter-branch -f --env-filter "
    # Author名かCommitter名のいずれかが誤っていれば適用します．
    if [ ${GIT_AUTHOR_NAME}="Hiroki-Hasegawa" -o ${GIT_COMMITTER_NAME}="Hiroki-Hasegawa" ] ; then
    export GIT_AUTHOR_NAME="hiroki-it"
    export GIT_AUTHOR_EMAIL="hasegawafeedshop@gmail.com"
    export GIT_COMMITTER_NAME="hiroki-it"
    export GIT_COMMITTER_EMAIL="hasegawafeedshop@gmail.com"
fi"
```

#### ・```rebase --onto <派生元にしたいローカルブランチ名> <誤って派生元にしたローカルブランチ名> <派生元を変更したいローカルブランチ名>```

作業中のローカルブランチの派生元を変更．

```shell
$ git rebase --onto <派生元にしたいローカルブランチ名> <誤って派生元にしたローカルブランチ名> <派生元を変更したいローカルブランチ名>
```

#### ・```rebase --interactive --root```
一番古い，最初の履歴を削除．

（１）変更タブの表示

```shell
$ git rebase --interactive --root
```
とすると，最初の履歴が記述されたタブが表示される

```shell
pick b1b5c0f add #0 xxxxxxxxxx
```

（２）```pick b1b5c0f add #0 xxxxxxxxxx```の行を削除して保存し，タブを閉じ，エディタ上で『Ctrl+C』を押す．

```shell
:qa!
```

ここで未知のエラー

```shell
CONFLICT (modify/delete): README.md deleted in HEAD and modified in 37bee65... update #0 README.mdに本レポジトリのタイトルと引用を記載
した. Version 37bee65... update #0 README.mdに本レポジトリのタイトルと引用を記載した of README.md left in tree.
error: could not apply 37bee65... update #0 README.mdに本レポジトリのタイトルと引用を記載した

Resolve all conflicts manually, mark them as resolved with
"git add/rm <conflicted_files>", then run "git rebase --continue".
You can instead skip this commit: run "git rebase --skip".
To abort and get back to the state before "git rebase", run "git rebase --abort".

Could not apply 37bee65... update #0 README.mdに本レポジトリのタイトルと引用を記載した
```

#### ・```rebase --abort```

やりかけの```rebase```を取り消し．
作業中のローカルブランチにおける```(master|REBASE-i)```が，``` (master)```に変更されていることからも確認可能．

```shell
hasegawahiroki@Hiroki-Fujitsu MINGW64 /c/Projects/Symfony2_Nyumon
$ git rebase --interactive

hasegawahiroki@Hiroki-Fujitsu MINGW64 /c/Projects/Symfony2_Nyumon (master|REBASE-i)
$ git rebase --abort

hasegawahiroki@Hiroki-Fujitsu MINGW64 /c/Projects/Symfony2_Nyumon (master)
$
```

<br>

### pull：

#### ・コマンド組み合わせ

全てのリモートブランチをpullする．

```shell
$ git branch -r | grep -v "\->" | grep -v main | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
$ git fetch --all
$ git pull --all
```

<br>

### push ：

#### ・```push -u origin <作成したブランチ名>```

ローカルで作成したブランチを，リモートにpushする．コミットは無くても良い．

#### ・```push origin <コミットID>:master```

トラウマコマンド

#### ・```push --delete origin <タグ名>```

リモートブランチのタグを削除する．

```shell
$ git push --delete origin v1.0.0
```

なお，ローカルのタグは別に削除する必要がある．

```shell
$ git tag -d v1.0.0
```

#### ・```push --tags```

ローカルのコミットに付与したタグをリモートにpushする．

<br>

### show-branch：

作業ブランチの派生元になっているブランチを確認．

```shell
$ git show-branch | grep "*" | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -1 | awk -F"[]~^[]" "{print $2}"
```

<br>

### filter-branch：

#### ・```filter-branch -f --env-filter```

全てのコミットの名前とメールアドレスを上書きする．

```shell
$ git filter-branch -f --env-filter \
    "GIT_AUTHOR_NAME="hiroki-it"; \
     GIT_AUTHOR_EMAIL="hasegawafeedshop@gmail.com"; \
     GIT_COMMITTER_NAME="hiroki-it"; \
     GIT_COMMITTER_EMAIL="hasegawafeedshop@gmail.com";" \
    HEAD
```

#### ・```filter-branch -f --tree-filter```

全てのコミットに対して，指定した処理を実行する．

**＊具体例＊**

全てのコミットに対して，特定のファイルを削除する処理を実行する．加えて，ローカルリポジトリに対してガーベジコレクションを実行すると，ローカルリポジトリから完全に削除できる．

```shell
$ git filter-branch -f --tree-filter \
    'rm -f <ファイルパス>' HEAD

# ガベージコレクションを実行
$ git gc --aggressive --prune=now
```
