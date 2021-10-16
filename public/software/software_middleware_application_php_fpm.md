# PHP-FPM：PHP FastCGI Process Manager

## はじめに

本サイトにつきまして，以下をご認識のほど宜しくお願いいたします．

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. CGIについて

#### ・CGIとは

![CGIの仕組み](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/CGIの仕組み.png)

<br>

### FastCGI：Fast Common Gateway Interface

#### ・FastCGIとは

CGIプロトコルのパフォーマンスを向上させたプロトコル仕様のこと．

<br>

### PHP-FPM

#### ・PHP-FPMとは

PHPのために実装されたFastCGIのこと．WebサーバとPHPファイルの間でデータ通信を行う．

参考：https://developpaper.com/shared-cgi-fastcgi-and-php-fpm-1/

![php-fpm](https://raw.githubusercontent.com/hiroki-it/tech-notebook/master/images/php-fpm.png)

<br>

## 02. コマンド

<br>

## 03. 設定

### ```/etc/php-fpm.d/www.conf```ファイル

PHP-FPMの設定を定義する．```php.ini```ファイルによって読み込まれる．```php.ini```ファイルよりも優先されるので，設定項目が重複している場合は，こちらを変更する．

**＊実装例＊**

```ini
[www]

# プロセスのユーザ名，グループ名
user = nginx
group = nginx

# Unixソケットのパス
listen = /run/php-fpm/www.sock

# PHP-FPMと組み合わせるミドルウェアを指定（apacheと組み合わせることも可能）
listen.owner = nginx
listen.group = nginx

# コメントアウト推奨 
;listen.acl_users = apache,nginx

# TCPソケットのIPアドレス
listen.allowed_clients = 127.0.0.1

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

# ログファイルの場所
slowlog = /var/log/php-fpm/www-slow.log
php_admin_value[error_log] = /var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on

# セッションの保存方法．ここではredisのキーとして保存（デフォルト値はfiles）
php_value[session.save_handler] = redis
# セッションの保存場所（デフォルト値は，/var/lib/php/session）
php_value[session.save_path]    = "tcp://xxxxx.r9ecnn.ng.0001.apne1.cache.amazonaws.com:6379"

# 
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
```

<br>

### ```/etc/php-fpm.d/zzz-www.conf```ファイル

参考：https://yoshinorin.net/2017/03/06/php-official-docker-image-trap/

```bash
# 元々の値をコメントアウトで示す
listen = /var/run/php-fpm/php-fpm.sock # 127.0.0.1:9000
listen.owner = foo # www
listen.group = foo # www
listen.mode = 0666

access.log = /dev/stdout
```

<br>

## 04. ログ

### ログの種類

### ・NOTICE

```log
[01-Sep-2021 00:00:00] NOTICE: fpm is running, pid 1
```

#### ・WARNING

```log
[01-Sep-2021 00:00:00] WARNING: [pool www] server reached pm.max_children setting (5), consider raising it
```

#### ・Fatal Error

```log
Fatal error: Allowed memory size of xxxxx bytes exhausted (tried to allocate 16 bytes)
```



