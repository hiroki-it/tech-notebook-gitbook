#  フロントエンドアーキテクチャ

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. フロントエンドアーキテクチャの種類

### SPA：Single Page Application

#### ・SPAとは

| ブラウザレンダリングのステップ | 実行者   |
| ------------------------------ | -------- |
| Loading                        | ブラウザ |
| Scripting                      | ブラウザ |
| Rendering                      | ブラウザ |
| Paiting                        | ブラウザ |

1つのWebページの中で，サーバとデータを非同期通信し，ブラウザ側で部分的に静的ファイルを生成する方法のこと．クライアント側でレンダリングを行うため，SSRと比較してCSR：Client Server side Renderingともいう．非同期通信は，Ajaxの手法を用いて実現される．また，静的ファイルの部分的な生成は，MVVMアーキテクチャによって実現する．SPAでは，ページ全体の静的ファイルをリクエストするのは最初のみで，それ以降はページ全体をリクエストすることはない．２回目以降は，ページ部分的にリクエストを行い，サーバ側からJSONを受け取っていく．

参考：https://developers.google.com/analytics/devguides/collection/analyticsjs/single-page-applications?hl=ja

![SPアプリにおけるデータ通信の仕組み](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/SPアプリにおけるデータ通信の仕組み.png)

#### ・MVVMアーキテクチャとは

Vue.jsでは，意識せずにMVVMアーキテクチャで実装できるようになっている．詳しくは，Vue.jsのノートを参考にせよ．

#### ・MPAとSPAの処理速度の違い

MPAと比較して，データを非同期的に通信できるため，1つのWebページの中で必要なデータだけを通信すればよく，レンダリングが速い．

![従来WebアプリとSPアプリの処理速度の違い](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/従来WebアプリとSPアプリの処理速度の違い.png)

<br>

### SSR：Server Side Rendering

#### ・狭義のSSRとは

1つのWebページの中で，サーバとデータを非同期通信し，サーバ側で静的ファイルを生成する方法のこと．

参考：

- https://ja.nuxtjs.org/docs/2.x/concepts/server-side-rendering
- https://tadtadya.com/summary-of-the-web-site-display-process-flow/#index-list-8

| ブラウザレンダリングのステップ | 実行者   |
| ------------------------------ | -------- |
| Loading                        | サーバ   |
| Scripting                      | サーバ   |
| Rendering                      | サーバ   |
| Paiting                        | ブラウザ |

#### ・広義のSSR

フレームワークには，バックエンド側のテンプレートエンジンによって静的ファイルを生成する機能を持つものがある．広義のSSRにはこれも含まれる．

<br>

### SSG：Static Site Generation

#### ・SSGとは

事前にビルドを行って静的ファイルを生成しておく．そして，これをレンダリングし，静的サイトとして稼働させる．動的な要素（例：ランダム表示）を含む静的ファイルについては，該当の部分でAjaxを使用できるようにしておく．

<br>

### ISR：Incremental Static Regeneration

#### ・ISRとは

SSGの発展型．SSGとは異なり，事前にビルドせず，静的ファイルを生成しない．その代わり，クライアントからリクエストがあって初めて，そのページのみビルドが実行され，レンダリングされる．クライアントから一回でもリクエストがあったページでは，初回時にビルドされた静的ファイルがその都度レンダリングされる．

参考：https://nextjs.org/docs/basic-features/data-fetching#incremental-static-regeneration
