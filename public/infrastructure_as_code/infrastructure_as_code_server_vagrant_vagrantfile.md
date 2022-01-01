# Vagrant

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. Vagrantfileとは

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



```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "base"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
  
     # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y apache2
  SHELL
end
```



