# 制御プログラム（カーネル）

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. 制御プログラム（カーネル）

  （例）カーネル、マイクロカーネル、モノリシックカーネル

<br>

## 02. 通信管理

### SELinux：Security Enhanced Linux

Linuxに標準で導入されているミドルウェア。ただし、アプリケーションと他のソフトウェアの通信を遮断してしまうことがあるため、基本的には無効にしておく。

1. SELinuxの状態を確認

```bash
$ getenforce

# 有効の場合
Enforcing
```

2. ```/etc/sellnux/config```を修正する。

```bash
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.

SELINUX=disabled # <---- disabledに変更

# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

3. OSを再起動

OSを再起動しないと設定が反映されない。

<br>

## 03 ジョブ管理

### ジョブ管理とは

クライアントは、マスタスケジュールに対して、ジョブを実行するための命令を与える。

<br>

### マスタスケジュラ、ジョブスケジュラ

![ジョブ管理とタスク管理の概要](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ジョブ管理とタスク管理の概要.jpg)

ジョブとは、プロセスのセットのこと。マスタスケジュラは、ジョブスケジュラにジョブの実行を命令する。データをコンピュータに入力し、複数の処理が実行され、結果が出力されるまでの一連の処理のこと。『Task』と『Job』の定義は曖昧なので、『process』と『set of processes』を使うべきとのこと。

引用：https://stackoverflow.com/questions/3073948/job-task-and-process-whats-the-difference/31212568

複数のジョブ（プログラムやバッチ）の起動と終了を制御したり、ジョブの実行と終了を監視報告するソフトウェア。ややこしいことに、タスクスケジューラとも呼ぶ。

#### ・Reader

ジョブ待ち行列に登録

#### ・Initiator

ジョブステップに分解

#### ・Terminator

出力待ち行列に登録

#### ・Writer

優先度順に出力の処理フローを実行

<br>

### Initiatorによるジョブのジョブステップへの分解

Initiatorによって、ジョブはジョブステップに分解される。

![ジョブからジョブステップへの分解](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ジョブからジョブステップへの分解.png)

<br>

## 04. タスク管理

### タスク管理とは

![ジョブステップからタスクの生成](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ジョブステップからタスクの生成.png)

タスクとは、スレッドに似たような、単一のプロセスのこと。Initiatorによるジョブステップから、タスク管理によって、タスクが生成される。タスクが生成されると実行可能状態になる。ディスパッチャによって実行可能状態から実行状態になる。

<br>

### 優先順方式

各タスクに優先度を設定し、優先度の高いタスクから順に、ディスパッチしていく方式。

<br>

### 到着順方式

待ち行列に登録されたタスクから順に、ディスパッチしていく方式。

![到着順方式_1](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/到着順方式_1.png)

**＊例＊**

以下の様に、タスクがCPUに割り当てられていく。

![到着順方式_2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/到着順方式_2.png)

<br>

### Round robin 方式

Round robinは、『総当たり』の意味。一定時間（タイムクウォンタム）ごとに、実行状態にあるタスクが強制的に待ち行列に登録される。交代するように、他のタスクがディスパッチされる。

![ラウンドロビン方式](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ラウンドロビン方式.png)

**＊例＊**

生成されたタスクの到着時刻と処理時間は以下のとおりである。強制的なディスパッチは、『20秒』ごとに起こるとする。

![優先順方式_1](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/優先順方式_1.png)

1. タスクAが0秒に待ち行列へ登録される。
2. 20秒間、タスクAは実行状態へ割り当てられる。
3. 20秒時点で、タスクAは実行状態から待ち行列に追加される。同時に、待ち行列の先頭にいるタスクBは、実行可能状態から実行状態にディスパッチされる。
4. 40秒時点で、タスクCは実行状態から待ち行列に追加される。同時に、待ち行列の先頭にいるタスクAは、実行可能状態から実行状態にディスパッチされる。

![優先順方式_2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/優先順方式_2.png)

<br>

## 05. 入出力管理

### 入出力管理とは

アプリケーションから低速な周辺機器へデータを出力する時、まず、CPUはスプーラにデータを出力する。Spoolerは、全てのデータをまとめて出力するのではなく、一時的に補助記憶装置（Spool）にためておきながら、少しずつ出力する（Spooling）。

![スプーリング](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/スプーリング.jpg)

