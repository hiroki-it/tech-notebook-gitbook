# Vagrant

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Vagrantとは

### Vagrantfile

![vagrant_provider_provisioner](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/vagrant_provider_provisioner.png)

プロバイダーとプロビジョナーの一連の操作を設定する。チームメンバーが別々に仮想サーバー（仮想マシン）を構築する場合、プロバイダーとプロビジョナーの処理によって作られる仮想サーバーの環境に、違いが生じてしまう。Vagrantfileにプロバイダーとプロビジョナーの操作を設定しておけば、チームメンバーが同じソフトウェアの下で、仮想サーバーを構築し、ソフトウェアをインストールできる。

参考：https://computationalmodelling.bitbucket.io/tools/vagrant.html

<br>

### プロバイダー

基本ソフトウェアにおける制御プログラムや一連のハードウェアを仮想的に構築できる。これを、仮想サーバー（仮想マシンとも）という。構築方法の違いによって、『ホスト型』、『ハイパーバイザ型』に分類できる。

<br>

### プロビジョナー

プロバイダーによって構築された仮想サーバーに、Web開発のためのソフトウェアをインストールできる（構成管理できる）。具体的には、プログラミング言語やファイアウォールをインストールする。

<br>