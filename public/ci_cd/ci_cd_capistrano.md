# Capistrano

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

### Capistranoとは

#### ・仕組み

1. 自身のパソコンからクラウドデプロイサーバにリモート接続する。
2. クラウドデプロイサーバの自動デプロイツール（例：Capistrano）が、クラウドデプロイサーバからクラウドWebサーバにリモート接続する。
3. 自動デプロイツールが、クラウドWebサーバのGitを操作し、```pull```あるいは```clone```を実行する。その結果、GitHubからクラウドデプロイサーバに指定のブランチの状態が取り込まれる。

![デプロイ](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/デプロイ.png)