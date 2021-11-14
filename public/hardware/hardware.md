# ハードウェア

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. ハードウェアとは

### ハードウェアの種類

#### ・ユーザの操作が、ソフトウェアを介して、ハードウェアに伝わるまで

![ソフトウェアとハードウェア](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ソフトウェアとハードウェア.png)

#### ・CPU（プロセッサ）

CPUは制御と演算を行う。CPUの制御部分は、プログラムの命令を解釈して、コンピュータ全体を制御。CPUの演算部分は、計算や演算処理を行う。特に、『**算術論理演算装置（ALU：Arithmetic and Logic Unit）**』とも呼ぶ。

#### ・RAM（メインメモリ＋キャッシュメモリ）

プログラムやデータを一時的に記憶し、コンピュータの電源を切るとこれらは消える。

#### ・ROM

プログラムやデータを長期的に記憶し、コンピュータの電源を切ってもこれらは消えない。

#### ・ストレージ（HDD vs SSD）

HDD：Hard Disk DriveとSSD：Solid State Driveがある。

#### ・入力装置

コンピュータにデータを入力。キーボード、マウス、スキャナなど。

#### ・出力装置

コンピュータからデータを出力。ディスプレイ、プリンタなど。

<br>

## 02. CPU（プロセッサ）

### IntelとAMDにおけるCPUの歴史（※2009年まで）

![IntelとAMDにおけるCPUの歴史](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/IntelとAMDにおけるCPUの歴史.png)

<br>

### クロック周波数

CPUの回路が処理と歩調を合わせるために用いる信号を、『クロック』と言う。一定時間ごとにクロックが起こる時、１秒間にクロックが何回起こるかを『クロック周波数』という。これは、Hzで表される。ちなみに、ワイのパソコンのクロック周波数は2.60GHzでした。

（例1）
```
3Hz
= 3 (クロック数／秒)
```
（例2）
```
2.6GHz
= 2.6×10^9  (クロック数／秒)
```
![クロック数比較](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/クロック数比較.png)

<br>

### MIPS：Million Instructions Per Second（×10^6 命令数／秒）

CPUが1秒間に何回命令を実行するかを表す。

（例題）

```
(命令当たりの平均クロック数) 
= (4×0.3)＋(8×0.6)＋(10×0.1) = 7

(クロック周波数) ÷ (クロック当たりの命令数)
= 700Hz (×10^6 クロック数／秒) ÷ 7 (クロック数／命令) 
= 100 (×10^6 命令数／秒)
```

![MIPSの例題](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/MIPSの例題.png)

#### ・1命令当たりの実行時間 (秒／命令) の求め方

```
1 ÷ 100 (×10^6 命令／秒) = 10n (秒／命令)
```

<br>

## 03. メモリ

参考：https://hiroki-it.github.io/tech-notebook-gitbook/public/hardware/hardware_memory.html

<br>

## 04. ディスクメモリ

CPU、メインメモリ、ストレージ間には、読み込みと書き出しの処理速度に差がある。（※再度記載）

![p169](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/p169.png)

<br>

### ディスクメモリの機能

メインメモリとストレージの間に、ディスクキャッシュを設置し、読み込みと書き出しの処理速度の差を緩和させる。

![ディスクキャッシュ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/ディスクキャッシュ.gif)



## 05. HDD

### Defragmentation

断片化されたデータ領域を整理整頓する。

![p184-1](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/p184-1.png)

![p184-2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/p184-2.png)

<br>

### RAID：Redundant Arrays of Inexpensive Disks

複数のHDDを仮想的に一つのHDDであるかのようにして、データを管理する技術。

#### ・RAID0（Striping）

  データを、複数のHDDに分割して書き込む。

#### ・RAID1（Mirroring）

  データを、複数のHDDに同じように書き込む。

#### ・RAID5（Striping with parity）

  データとパリティ（誤り訂正符号）を、3つ以上のHDDに書き込む。

![RAIDの種類](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/RAIDの種類.png)

<br>

## 06. GPUとVRAM

GPUとVRAMの容量によって、扱うことのできる解像度と色数が決まる。

![VRAM](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/VRAM.jpg)

富士通PCのGPUとVRAMの容量は、以下の通り。

![本パソコンのVRAMスペック](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/本パソコンのVRAMスペック.jpg)

色数によって、１ドット当たり何ビットを要するが異なる。

![p204](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/p204.jpg)

