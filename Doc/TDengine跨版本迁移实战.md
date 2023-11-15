# TDengine 跨版本升级实战

TDengine 3.0 已经退出了近一年，目前已经到了 3.2 版本。很遗憾的是 2.x 和 3.x 直接的数据文件不兼容。

如果向从 2.x 升级到 3.x 只能选择数据迁移的方式。 

目前数据迁移有三种方法：
1. 使用官方推荐工具 `taosx`。
2. 使用 `taosdump` 工具。
3. 自己写程序。
   
|迁移方式|优点|缺点|
|----|----|----|
|taosx|迁移速度快，不占用本地空间|只有企业版支持|
|taosdump|社区版具备|占用大量本地空间，导出速度慢，大数据量导出数据不全|
|自己写程序|灵活、可定制|费人力|

以下演示使用 Python 脚本跨版本迁移数据库，从 3.1 降级迁移到 2.6。

## 源数据库
|属性|内容|
|---|----|
|IP|10.7.7.14|
|版本|3.1|
|数据库|backtrade|

## 目标数据库
|属性|内容|
|---|----|
|IP|192.168.2.125|
|版本|2.6|
|数据库|backtrade|

## 迁移步骤
### 1. 获取元数据信息

```sql 

taos> show create database backtrade\G;
*************************** 1.row ***************************
       Database: backtrade
Create Database: CREATE DATABASE `backtrade` BUFFER 256 CACHESIZE 1 CACHEMODEL 'none' COMP 2 DURATION 14400m WAL_FSYNC_PERIOD 3000 MAXROWS 4096 MINROWS 100 STT_TRIGGER 1 KEEP 5256000m,5256000m,5256000m PAGES 256 PAGESIZE 4 PRECISION 'ms' REPLICA 1 WAL_LEVEL 1 VGROUPS 2 SINGLE_STABLE 0 TABLE_PREFIX 0 TABLE_SUFFIX 0 TSDB_PAGESIZE 4 WAL_RETENTION_PERIOD 0 WAL_RETENTION_SIZE 0
Query OK, 1 row(s) in set (0.000398s)
```

```sql

taos> show stables;
          stable_name           |
=================================
 btdata                         |
Query OK, 1 row(s) in set (0.001156s)

taos> show create stable btdata\G;
*************************** 1.row ***************************
       Table: btdata
Create Table: CREATE STABLE `btdata` (`ts` TIMESTAMP, `profit` DOUBLE) TAGS (`fcode` VARCHAR(6), `fname` NCHAR(20))
Query OK, 1 row(s) in set (0.001251s)
```
### 2. 创建目标数据库和超级表
运行迁移脚本前需要先在目标端创建数据库和超级表。

```sql
taos> CREATE DATABASE `backtrade` ;
Query OK, 0 of 0 row(s) in database (0.001749s)

taos> use backtrade;
Database changed.

taos> CREATE STABLE `btdata` (`ts` TIMESTAMP, `profit` DOUBLE) TAGS (`fcode` BINARY(6), `fname` NCHAR(20));
Query OK, 0 of 0 row(s) in database (0.001782s)
```

### 3.配置迁移参数

```json
{
    "exporUrl":"http://10.7.7.14:6041/rest/sql",
    "exportDBName":"backtrade",
    "exportUsername":"root",
    "exportPassword":"taosdata",
    "exportVersion":3,
    "importUrl":"http://192.168.2.125:6041/rest/sql",
    "importDBName":"backtrade",
    "importUsername":"root",
    "importPassword":"taosdata",
    "importVersion":2,
    "recodeOfPerSQL":1000,
    "tableonly":"false",
    "sqlheader":"select * from ",
    "startTime":943891200000,
    "endTime":1699939779000,
    "threadNum":4
}
```
参数说明：
- exportUrl 源数据库Restful接口地址
- exportDBName 源数据库名称
- exportUsername 源数据库用户名
- exportPassword 源数据库密码
- exportVersion 源数据库版本，近支持2/3，用于判断Restful返回值
- importUrl 目标库Restful接口地址
- importDBName 目标库名称
- importUSername 目标库用户名
- imortPassword 目标库密码
- importVersion 目标数据库版本，近支持2/3，用于判断Restful返回值
- recodeOfPerSQL 单条SQL记录数，需要根据表结构调整，保证单条SQL不超过1MB
- tableonly 是否只迁移表结构
- sqlheader 数据查询SQL头，可通过此项定制迁移内容，比如说只迁移某几列数据
- startTime 迁移数据起始实际
- endTime 迁移数据中止时间
- treadNum 并发线程/进程数量

注意：
- 如果目标数据库版本是 2.x，那么最好先创建好所有表，再导入数据。2.x 建表很慢，并发建表会失败。
- 如果目标数据库版本是 2.x，且 `tableonly` 设置为 `true`，那么 `threadNum` 应该设置为 1。 

### 4.运行迁移脚本

```bash
python3 datac_com23.py
```
脚本使用说明
- python3 datac_com23.py -h 查看文件帮助内容
- python3 datac_com23.py -f tbfile 从 `tbfile` 文件读取迁移列表（只限子表），默认会从数据库查询所有表
- python3 datac_com23.py -p 时间多进程方式，默认为多线程
- 如果表不存在，会自动创建


```bash
[2023-11-15 12:08:04,440] dataC/multi_thread(62652/MainThread) INFO - --------------------begin------------------
[2023-11-15 12:08:04,454] dataC/export_table(62652/Thread_0) INFO - Table Name:t_688287, Select Rows:3
[2023-11-15 12:08:04,454] dataC/export_table(62652/Thread_3) INFO - Table Name:t_516770, Select Rows:3
[2023-11-15 12:08:04,454] dataC/export_table(62652/Thread_1) INFO - Table Name:t_118015, Select Rows:3
[2023-11-15 12:08:04,454] dataC/export_table(62652/Thread_2) INFO - Table Name:t_831445, Select Rows:3
[2023-11-15 12:08:04,492] dataC/export_table(62652/Thread_0) INFO - Create table t_688287 success.
[2023-11-15 12:08:04,494] dataC/export_table(62652/Thread_2) INFO - Create table t_831445 success.
[2023-11-15 12:08:04,494] dataC/export_table(62652/Thread_3) INFO - Create table t_516770 success.
[2023-11-15 12:08:04,495] dataC/export_table(62652/Thread_1) INFO - Create table t_118015 success.
......
[2023-11-15 12:08:30,738] dataC/export_table(62652/Thread_1) INFO - Create table t_128033 success.
[2023-11-15 12:08:30,750] dataC/multi_thread(62652/MainThread) INFO - --------------------end------------------
[2023-11-15 12:08:30,750] dataC/multi_thread(62652/MainThread) INFO - ##############################
[2023-11-15 12:08:30,750] dataC/multi_thread(62652/MainThread) INFO - ## 9038/9038 Tables  and 27395 Rows are proceed.
[2023-11-15 12:08:30,750] dataC/multi_thread(62652/MainThread) INFO - ## 9038 tables created.
[2023-11-15 12:08:30,754] dataC/multi_thread(62652/MainThread) INFO - ##############################
```

脚本内容见[迁移脚本](https://download.csdn.net/download/weixin_43700866/88537389)
如果看不到，可能还没有通过审核，等两天就好。