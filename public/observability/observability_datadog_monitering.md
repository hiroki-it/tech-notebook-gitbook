# 監視

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. モニター

### モニターとは

メトリクス／ログを監視し，システムの予測可能な不具合の発生を未然に防ぐ．

<br>

### ログモニター

#### ・ログクエリの動作確認

ログモニターのクエリは，ログコンソールと同じ仕組みで機能する．そのため，最初はログコンソールで必要なログを絞り込めるかを確認し，問題なければログモニターのクエリを設定する．

参考：https://docs.datadoghq.com/ja/monitors/monitor_types/log/#%E6%A4%9C%E7%B4%A2%E3%82%AF%E3%82%A8%E3%83%AA%E3%82%92%E5%AE%9A%E7%BE%A9%E3%81%99%E3%82%8B

#### ・シングルアラート

#### ・マルチアラート

ログクエリで```group by```句を定義すると，選択できるようになる．

<br>

## 01-02. 通知内容の定義

### テンプレート変数

参考：https://docs.datadoghq.com/ja/monitors/notify/variables/?tab=is_alert#template-variables

<br>

### タグ変数

#### ・タグ変数とは

クエリの```group by```句に割り当てたタグやファセットを変数として出力できる．マルチアラートモニターを使用する場合のみ，使用できる．

参考：https://docs.datadoghq.com/ja/monitors/notify/variables/?tab=is_alert#tag-variables

#### ・ログファセット変数

クエリの```group by```句でファセットを割り当てた場合に使用できる．

参考：https://docs.datadoghq.com/ja/monitors/notify/variables/?tab=is_alert#log-facet-variables

#### ・コンポジットモニター変数とは

参考：https://docs.datadoghq.com/ja/monitors/notify/variables/?tab=is_alert#composite-monitor-variables

<br>

### 条件変数

参考：https://docs.datadoghq.com/ja/monitors/notify/variables/?tab=is_alert#conditional-variables

<br>

### メッセージの構成

#### ・タイトル

通知先にタイトルとして表示するテキストを定義する．タイトルに変数を出力できる．

```markdown
<!-- group by句に割り当てたタグを変数として出力する -->
【{{service.name}}】エラーを検知しました
```

#### ・本文

通知先とテキストを定義する．マークダウン記法を使用できる．

```markdown
<!-- Datadogに設定した通知先 -->
<!-- 復旧通知を転送しない場合，is_alert構文の外で定義する必要がある -->
@<通知先>

<!-- アラート状態の時に表示するテキスト -->
{{#is_alert}}

エラーメッセージです

{{/is_alert}}
```

<br>

## 02. リアルユーザ監視（RUM）

### ブラウザエラー

#### ・ブラウザエラーとは

以下で表示されるエラーのこと

参考：https://docs.datadoghq.com/real_user_monitoring/browser/collecting_browser_errors/?tab=npm

| エラーの場所         | エラーの例                     |
| -------------------- | ------------------------------ |
| ソースコード上       | ハンドリングされていないエラー |
| ブラウザコンソール上 |                                |
| カスタム             |                                |

<br>

## 03. グラフ

### 図の種類

### スケールの種類

#### ・log（対数）スケール

#### ・linear（線形）スケール

#### ・２の累乗スケール

#### ・sqrt（平方根）スケール

<br>







