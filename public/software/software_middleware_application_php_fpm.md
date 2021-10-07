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

## 03. ログ

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



