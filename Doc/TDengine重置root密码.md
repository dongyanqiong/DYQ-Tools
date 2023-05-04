# TDengine重置root密码

## 1.关闭数据库

```shell
systemcl stop taosd
```

## 2.手动启动数据库

```shell
taosd -A
```

## 3.手动关闭数据库

```shell
Ctrl+C
```

## 4.查看密码文件

在当前目录会生成文件auth.txt

```shell
user:     _root auth:YQou5ojNqeckiF4jzSz97nJvb3QAAAAAAAAAAAAAAAA=
user:     monitor auth:YQou5ojNqeckiF4jzSz97nJvb3QAAAAAAAAAAAAAAAA=
user:     root auth:/D/QCQI0ufQG/xJBZ2h7pHJvb3QAAAAAAAAAAAAAAAA=
```

## 5.启动数据库

```shell
systemctl start taosd
```

## 6.使用加密串登录数据库

```shell
taos -A /D/QCQI0ufQG/xJBZ2h7pHJvb3QAAAAAAAAAAAAAAAA=
```

## 7.修改root密码

```shell
taos> alter user root pass 'NEW_PASSWORD';
```

