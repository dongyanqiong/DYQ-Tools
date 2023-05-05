## 1.简介
使用Python bottle 框架做的线上授权系统。

支持通过数据库的产品信息库来判断产品ID的合法性；

支持将授权记录写入数据库；

支持多个机器码的传入。


### 1.1.grant.sh
模拟授权系统，根据提供的机器码返回一个MD5校验码，
并记录到grantlog.log文件中

### 1.2.index.py
web接口，监听80端口，读取http请求中参数。
校验完成后调用grant 生成激活码，并返回给客户端。

## 2.环境准备
### 2.1.安装依赖包
pip3 install bottle

pip3 install taospy

### 2.2.安装TDengine
见官方文档

### 2.3.配置数据库
创建数据库 grant_log

CREATE DATABASE grant_log REPLICA 1 QUORUM 1 DAYS 10 KEEP 36500,36500,36500 CACHE 16 BLOCKS 6 MINROWS 100 MAXROWS 4096 WAL 2 FSYNC 3000 COMP 2 CACHELAST 1 PRECISION 'ms' UPDATE 0;
 
创建授权日志表 url_log

CREATE TABLE `grant_log.url_log` (`ts` TIMESTAMP,`activity` BINARY(200),`businessid` BINARY(200),`chargingmode` BINARY(200),`customerid` BINARY(200),`customername` BINARY(200),`expiretime` BINARY(200),`orderid` BINARY(200),`periodnumber` BINARY(200),`periodtype` BINARY(200),`productid` BINARY(200),`provisiontype` BINARY(200),`saasextendparams` BINARY(200),`testflag` BINARY(200),`time_stamp` BINARY(200),`userid` BINARY(200),`username` BINARY(200),`authtoken` BINARY(200),`license` BINARY(200));

创建产品信息表 product_info

CREATE TABLE `grant_log.product_info` (`ts` TIMESTAMP,`productid` BINARY(200),`snum` BIGINT);

写入一条测试用产品信息，产品ID：00301-666666-0--0，测点数：100000

insert into product_info values(now,'00301-666666-0--0',100000);

## 3.使用方法
python3 index.py