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

## 03. Tips

### ```php.ini```ファイル

#### ・開発環境用

元々の値をコメントアウトで示す

```bash
zend.exception_ignore_args = off
expose_php = on
max_execution_time = 30
max_input_vars = 1000
upload_max_filesize = 64M # 2M
post_max_size = 128M # 8M
memory_limit = 256M # 128M
error_reporting = E_ALL # NULL
display_errors = on
display_startup_errors = on
log_errors = on # 0(off)
error_log = /dev/stderr # NULL
default_charset = UTF-8

[Date]
date.timezone = ${TZ} # GMT

[mysqlnd]
mysqlnd.collect_memory_statistics = on # off

[Assertion]
zend.assertions = 1

[mbstring]
mbstring.language = Neutral
```

#### ・本番環境用

元々の値をコメントアウトで示す

```bash
zend.exception_ignore_args = on
expose_php = off
max_execution_time = 30
max_input_vars = 1000
upload_max_filesize = 64M
post_max_size = 128M
memory_limit = 256M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = off
display_startup_errors = off
log_errors = on
error_log = /var/log/php/php-error.log
default_charset = UTF-8

[Date]
date.timezone = Asia/Tokyo

[mysqlnd]
mysqlnd.collect_memory_statistics = off

[Assertion]
zend.assertions = -1

[mbstring]
mbstring.language = Japanese

[opcache]
opcache.enable = 1
opcache.memory_consumption = 128
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 4000
opcache.validate_timestamps = 0
opcache.huge_code_pages = 0
opcache.preload = /var/www/preload.php
opcache.preload_user = www-data
```

<br>

### ```zzz-www.conf```ファイル

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



