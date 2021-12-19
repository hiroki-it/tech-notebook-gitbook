# ネットワーク

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. ネットワークの全体像

### インターネット、WAN、LAN

ネットワークには、『インターネット』『WAN』『LAN』がある。家庭内LAN、学内LAN、企業内LAN、企業WANなど、さまざまなネットワークがあり、インターネットは、それぞれのネットワークを互いに接続しているネットワークである。

![インターネットとWANとLAN](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/インターネットとWANとLAN.png)

<br>

### WAN、LANの例

例えば、LANとしてEthernet、WANとしてデジタル専用線を用いる。

![WAN、wan_lan](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/wan_lan.png)

<br>

### WANの種類と歴史

![WANの歴史](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/WANの種類と歴史.png)

<br>

### グローバルネットワークとプライベートネットワーク

ルータを境に、プライベートネットワークとグローバルネットワークに分けられる。ややこしいが、ルータにはグローバルIPアドレスが割り当てられている。

![グローバルネットワークとプライベートネットワーク](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/グローバルネットワークとプライベートネットワーク.PNG)

<br>

## 02. プライベートネットワークへのデータ送信

### データ通信方法の種類

#### ・回線交換方式

  少数対少数でデータ通信を行うため、送信時に、送信者と受信者の宛先情報は必要ない。

![回線交換方式](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/回線交換方式.png)

#### ・パケット交換方式

  通信するデータをパケット化する。多数対多数でデータ通信を行うため、送信時に、送信者と受信者の宛先情報が必要になる。

![パケット交換方式](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/パケット交換方式.png)

<br>

### URLとメールアドレス

#### ・構造

URLとメールアドレスは完全修飾ドメイン名を持つ。

![URLと電子メールの構造](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/URLと電子メールの構造.png)

また、完全修飾ドメイン名は、ドメイン名の子関係にあるサブドメイン名を持てる。ホスト名（以下では省略されている）と、ドメイン名の間につける。

![サブドメイン](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/サブドメイン.png)

#### ・完全修飾ドメイン名によるサーバ指定

完全修飾ドメイン名は、所属ネットワークを指すドメイン名と、そのネットワークにおける具体的なサーバを指すホスト名からなる。ただし、サーバのホスト名が『www』である場合、クライアントはURLの指定時にホスト名を省略できる。例えば、『```www.example.co.jp```』という完全修飾ドメイン名をURLで指定する場合、『```example.co.jp```』としてもよい。

![domain_namespace](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/domain_namespace.png)

<br>

### セグメント

#### ・セグメントの種類

プライベートネットワークは、外部公開用ネットワーク、非武装地帯、内部ネットワークに分類される。

![internal_dmz_external](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/internal_dmz_external.png)

#### ・非武装地帯のサーバの種類

攻撃の影響が内部ネットワークに広がる可能性を防ぐために、外部から直接リクエストを受ける。そのため、『DNSサーバ』『プロキシサーバ』『Webサーバ』『メールサーバ』は、非武装地帯に設置される。

#### ・内部ネットワークのサーバの種類

外部から直接リクエストを受けない。そのため、『DBサーバ』は、内部ネットワークに設置される。

<br>

## 03. Webシステムを構成する主要な3層構造

### Webシステムとは

Webサーバ、Appサーバ、DBサーバによるネットワークの仕組みをWebシステムという。ソフトウェアとハードウェアのノートも参考にせよ。

![web-server_app-server_db-server](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/web-server_app-server_db-server.png)

### Webサーバ

#### ・Webサーバの役割

ミドルウェア（Apache、Nginxなど）がインストールされている。また、Web兼Appサーバのミドルウェアとして機能する（NGINX Unit）がインストールされていることもある。

![NginxとPHP-FPMの組み合わせ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/NginxとPHP-FPMの組み合わせ.png)

|                                | Webサーバ |  →   | Appサーバ |  →   |  DBサーバ  |
| ------------------------------ | :-------: | :--: | :-------: | :--: | :--------: |
| 静的コンテンツ                 | 静的レス  |      |    ー     |      |     ー     |
| 静的コンテンツ＋動的コンテンツ | 静的レス  |      | 動的レス  |      | データ管理 |

ブラウザから静的コンテンツのみのリクエストがあった場合、静的コンテンツをレスポンスする。また、静的コンテンツと動的コンテンツの両方のリクエストがあった場合、アプリケーションサーバに動的コンテンツのリクエストを行う。アプリケーションサーバからレスポンスを受け取り、ブラウザにレスポンスを行う。

<br>

### Appサーバ

#### ・Appサーバの役割

ミドルウェア（PHPならPHP-FPM、JavaならTomcat）がインストールされている。

|                                | Webサーバ |  →   | Appサーバ |  →   |  DBサーバ  |
| ------------------------------ | :-------: | :--: | :-------: | :--: | :--------: |
| 静的コンテンツ                 | 静的レス  |      |    ー     |      |     ー     |
| 静的コンテンツ＋動的コンテンツ | 静的レス  |      | 動的レス  |      | データ管理 |


Webサーバから動的コンテンツのリクエストがあった場合、プログラミング言語を言語プロセッサで翻訳し、DBサーバにリクエストを行う。DBサーバからのレスポンスを受け取り、Webサーバに動的なコンテンツのレスポンスを行う。

<br>

### DB管理システムを持つDBサーバ

#### ・DBサーバの役割

DB管理システムがインストールされている。DBの情報が保存されている。

<br>

### サーバの処理能力向上

#### ・垂直スケーリング（スケールアップ ⇔ スケールダウン）

  サーバ自体のスペックをより高くすることで、サーバ当たりの処理能力を向上させる。その逆は、スケールダウン。設定で、仮想サーバのスペックを上げることも、これに該当する。

![スケールアップ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/スケールアップ.png)

#### ・水平スケーリング（スケールアウト ⇔ スケールイン）

  サーバの台数を増やすことで、サーバ全体の処理能力を向上させる。その逆は、スケールイン。

![スケールアウト](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/スケールアウト.png)

<br>

## 03-02. Webシステムの構成方法

### Dualシステム

同じ処理を行う2つのシステムからなるシステム構成のこと。随時、処理結果を照合する。いずれかが故障した場合、異常が発生したシステムを切り離し、残る片方で処理を続けることによって、故障を乗り切る。

![デュアルシステム](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/デュアルシステム.png)

<br>

### Duplexシステム

オンライン処理を行う主系システムと、バッチ処理を行う従系システムからなるシステム構成のこと。主系システムが故障した場合、主系システムのオンライン処理を従系システムに引き継ぎ、処理を続けることによって、故障を乗り切る。

![デュプレックスシステム](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/デュプレックスシステム.png)

従系システムの待機方法には2つの種類がある。

#### ・ホットスタンバイ

![p613-1](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/p613-1.png)

#### ・コールドスタンバイ

![p613-2](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/p613-2.png)

<br>

### システムの稼働率

並列システムの場合、両方の非稼働率をかけて、全体から引く。

**＊例＊**

１－(1－0.81) × (1－0.64) = 0.9316

![稼働率の計算](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/稼働率の計算.jpg)

<br>

## 04. フォワード／リバースプロキシサーバ

### 役割

#### ・代理リクエスト機能（セキュリティのノートも参照）

代理でリクエストを送るフォワードプロキシサーバと、レスポンスを送るリバースプロキシサーバに分類できる。

![フォワードプロキシサーバーとリバースプロキシサーバ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/フォワードプロキシサーバーとリバースプロキシサーバ.png)

#### ・キャッシュ機能

リバースプロキシサーバに、Webページのコンテンツのキャッシュを作成することによって、Webサーバのアクセス負荷を抑える。ちなみに、ブラウザもキャッシュ機能を持っている。

![プロキシサーバのキャッシュ機能](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/プロキシサーバのキャッシュ機能.png)

<br>

### 設置場所

#### ・物理サーバの場合

フォワードプロキシサーバはプロバイダの会社に、リバースプロキシサーバはリクエスト先の社内ネットワークに設置されている。

![プロキシサーバの設置場所](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/プロキシサーバの設置場所.png)

#### ・クラウド上の場合

クラウドの場合も、サーバが仮想的に構築される違いだけで、設置場所は同じである。

<br>

### リバースプロキシサーバの実現方法

#### ・Nginx

Webサーバとしてではなく、リバースプロキシサーバとして使用し、代理リクエストやキャッシュ作成を行える。

![リバースプロキシサーバとしてのNginx](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/リバースプロキシサーバとしてのNginx.png)

<br>

## 04-02.  プロキシサーバ、DNSサーバによる名前解決

![名前解決の仕組み](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/名前解決の仕組み.png)

### （1）完全修飾ドメイン名に対応するIPアドレスのレスポンス

#### ・仕組み

1. クライアントPCは、完全修飾ドメイン名を、フォワードプロキシサーバ（キャッシュDNSサーバ）にリクエスト。

2. フォワードプロキシサーバは、完全修飾ドメイン名を、リバースプロキシサーバに代理リクエスト。

3. リバースプロキシサーバは、完全修飾ドメイン名を、DNSサーバ（ネームサーバ）に代理リクエスト。

4. DNSサーバは、完全修飾ドメインにマッピングされるIPv4アドレスを取得し、リバースプロキシサーバにレスポンス。

   |      完全修飾ドメイン名      |  ⇄   |     IPv4アドレス      |
   | :--------------------------: | :--: | :-------------------: |
   | ```http://www.example.com``` |      | ```203.142.205.139``` |

5. リバースプロキシサーバは、IPv4アドレスを、フォワードプロキシサーバに代理レスポンス。（※NATによるIPv4アドレスのネットワーク間変換が起こる）

6. フォワードプロキシサーバは、IPv4アドレスを、クライアントPCに代理レスポンス。

#### ・プロキシサーバ（キャッシュDNSサーバ）におけるDNSキャッシュ

ルートサーバは世界に13機しか存在しておらず、世界中の名前解決のリクエストを全て処理することは現実的に不可能である。そこで、IPアドレスとドメイン名の関係をキャッシュするプロキシサーバ（キャッシュDNSサーバ）が使用されている。基本的には、プロキシサーバとDNSサーバは区別される。ただし、Amazon Route53のように、プロキシサーバとDNSサーバの機能を両立しているものもある。

<br>

### （2）IPアドレスに対応するWebページのレスポンス

#### ・仕組み

1. クライアントPCは、レスポンスされたIPv4アドレスを基に、Webページを、リバースプロキシサーバにリクエスト。
2. リバースプロキシサーバは、Webページを、Webサーバに代理リクエスト。
3. Webサーバは、Webページを、リバースプロキシサーバにレスポンス。
4. リバースプロキシサーバは、Webページを、クライアントPCに代理レスポンス。

<br>

## 06. ネットワーク速度の指標

### 一覧

|                             |                                                              |                                                              |
| --------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| レスポンスタイム            | リクエストを送信してから、サーバが処理を実行し、レスポンスが返信されるまでに要する時間のこと。 |                                                              |
| レイテンシー                | リクエストを送信してから、レスポンスが返信されるまで要する時間のこと。サーバの処理時間は含まない。 |                                                              |
| Connection Time（接続時間） | リクエストを送信する前に、サーバとのTCP接続の確立に要する時間のこと。 | リクエストとレスポンスの送受信の前後に行われるTCP接続の確立を『スリーウェイハンドシェイク』という。 |
| Bandwidth（帯域幅）         | 一度に送受信できるデータの最大容量のこと。                   |                                                              |
| スループット（伝送速度）    | 単位時間当たりの送信できる最大のデータ容量のこと。           | 他からの影響を受けた実際のスループットを『実効スループット』という。 |

<br>

###  スループット（伝送速度）

#### ・伝送とは

サーバからクライアントPCにデータを送信すること。相互の送信は、通信と呼ぶ。

#### ・スループットとは

単位時間当たりの送信できる最大のデータ容量のこと。実際には、スループットは、『プロバイダ』、『光回線』、『自宅の有線／無線』の三つに影響されるため、スループットで期待されるデータ容量を満たせないことが多い。実際のスループットを『実効スループット』という。

![伝送速度](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/伝送速度.png)

#### ・伝送秒数の求め方

```
(伝送秒数)
= データ容量(bit) ÷ スループット(bit/s) × 伝送効率
```

#### ・トラフィックとは

とあるネットワーク地点でのスループットのこと。

参考：https://xtech.nikkei.com/it/article/Keyword/20070222/262872/

![トラフィック](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/トラフィック.png)

総務省のデータで、日本のブロードバンド大手5社の総トラフィックを年次でグラフ化したものがある。

参考：https://xtech.nikkei.com/atcl/nxt/column/18/00525/112900001/

![トラフィックのグラフ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/トラフィックのグラフ.png)



### 
