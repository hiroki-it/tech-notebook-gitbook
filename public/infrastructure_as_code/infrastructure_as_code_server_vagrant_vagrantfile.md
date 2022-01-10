# Vagrantfile

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Vagrantfileとは

プロバイダーとプロビジョナーの一連の操作内容を設定する。チームメンバーが別々に仮想サーバー（仮想マシン）を構築する場合、プロバイダーとプロビジョナーの処理によって作られる仮想サーバーの環境に、違いが生じてしまう。Vagrantfileにプロバイダーとプロビジョナーの操作を設定しておけば、チームメンバーが同じソフトウェアの下で、仮想サーバーを構築し、ソフトウェアをインストールできる。

<br>

## 01. Vagrant.configure

### Vagrant.configureとは

Vagrantfileのバージョンを設定する。

参考：https://www.vagrantup.com/docs/vagrantfile/version

```bash
Vagrant.configure("2") do |config|

  # その他の全てのオプションを設定する。

end
```

<br>

## 02. config.vm

### config.vmとは

仮想サーバーの構成を設定する。

<br>

### box

#### ・boxとは

仮想サーバーの名前を設定する。

参考：https://www.vagrantup.com/docs/vagrantfile/machine_settings#config-vm-box

```bash
box = "foo"
```

<br>

### box_check_update

#### ・box_check_updateとは

Vagrantの更新通知を設定する。

```bash
config.vm.box_check_update = false
```

<br>

### network

#### ・networkとは

仮想サーバーのネットワークを設定する。

参考：https://www.vagrantup.com/docs/vagrantfile/machine_settings#config-vm-network

#### ・forwarded_port

ホストから仮想サーバーへポートフォワーディングを設定する。

参考；https://www.vagrantup.com/docs/networking/forwarded_ports

```bash
config.vm.network "forwarded_port", guest: 80, host: 8080
```

<br>

### provider

#### ・providerとは

プロバイダー固有のオプションを設定する。

参考：https://www.vagrantup.com/docs/vagrantfile/machine_settings#config-vm-provider

```bash
config.vm.provider "virtualbox" do |vb|
  vb.gui = true
  vb.memory = "1024"
end
```

<br>

### provision

#### ・provisionとは

仮想サーバーのプロビジョニングを設定する。

参考：https://www.vagrantup.com/docs/vagrantfile/machine_settings#config-vm-provision

```bash
config.vm.provision "shell", inline: <<-SHELL
  apt-get update
  apt-get install -y apache2
SHELL
```

<br>

### synced_folder

#### ・synced_folderとは

ホスト上のディレクトリを仮想サーバーにマウントする。

```bash
config.vm.synced_folder ".", "/var/www/foo"
```

