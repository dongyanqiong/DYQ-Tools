# TDengine 备份与恢复

TDengine 通过 taosTools 工具包中的 taosdump 工具实现数据的备份与恢复功能。

以下操作默认环境如下：

```shell
##服务端：td1.taosdata.com
##用户名：root
##密码：taosdata
##数据库名称：db01
##超级表名称：stb1
##普通表名称：tb1
##TDengine 版本：2.4.0.7
##环境创建：
CREATE DATABASE db01;
CREATE STABLE db01.stb1 (ts TIMESTAMP,  v1 INT) TAGS(t1 INT);
CREATE TABLE db01.tb1 USING stb1 TAGS(1);
##插入1000条数据
for i in {1..1000}
do
taos -s "INSERT INTO db01.tb1 VALUES(NOW,$i);"
done
```

## 1、taosdump 简介

taosdump 支持备份数据库、超级表、普通表。它使用 Apache AVRO 作为数据文件格式来存储备份数据，也仅支持通过 taosdump 导出的数据进行导入。

```shell
taosdump --help
Usage: taosdump [OPTION...] dbname [tbname ...]
  or:  taosdump [OPTION...] --databases db1,db2,... 
  or:  taosdump [OPTION...] --all-databases
  or:  taosdump [OPTION...] -i inpath
  or:  taosdump [OPTION...] -o outpath

  -h, --host=HOST            Server host dumping data from. Default is
                             localhost.
  -p, --password             User password to connect to server. Default is
                             taosdata.
  -P, --port=PORT            Port to connect
  -u, --user=USER            User name used to connect to server. Default is
                             root.
  -c, --config-dir=CONFIG_DIR   Configure directory. Default is /etc/taos
  -i, --inpath=INPATH        Input file path.
  -o, --outpath=OUTPATH      Output file path.
  -r, --resultFile=RESULTFILE   DumpOut/In Result file path and name.
  -a, --allow-sys            Allow to dump system database
  -A, --all-databases        Dump all databases.
  -D, --databases=DATABASES  Dump inputted databases. Use comma to separate
                             databases' name.
  -N, --without-property     Dump database without its properties.
  -s, --schemaonly           Only dump tables' schema.
  -y, --answer-yes           Input yes for prompt. It will skip data file
                             checking!
  -d, --avro-codec=snappy    Choose an avro codec among null, deflate, snappy,
                             and lzma.
  -S, --start-time=START_TIME   Start time to dump. Either epoch or
                             ISO8601/RFC3339 format is acceptable. ISO8601
                             format example: 2017-10-01T00:00:00.000+0800 or
                             2017-10-0100:00:00:000+0800 or '2017-10-01
                             00:00:00.000+0800'
  -E, --end-time=END_TIME    End time to dump. Either epoch or ISO8601/RFC3339
                             format is acceptable. ISO8601 format example:
                             2017-10-01T00:00:00.000+0800 or
                             2017-10-0100:00:00.000+0800 or '2017-10-01
                             00:00:00.000+0800'
  -B, --data-batch=DATA_BATCH   Number of data per insert statement. Default
                             value is 16384.
  -T, --thread_num=THREAD_NUM   Number of thread for dump in file. Default is
                             5.
  -g, --debug                Print debug info.
  -?, --help                 Give this help list
      --usage                Give a short usage message
  -V, --version              Print program version

Mandatory or optional arguments to long options are also mandatory or optional
for any corresponding short options.

Report bugs to <support@taosdata.com>.
```

常用参数介绍

```shell
-h 要连接的 TDengine 所在节点
-u 用户名
-p 密码
-o 备份输出路径
-i 导入数据路径
-B 导入数据库时，单条件语句包含记录数
-T 导出、导入时进程数

```

## 2.数据备份

### 2.1.备份数据库

创建备份目标目录

```shell
mkdir -p /tmp/dump/db01
```

备份数据库 db01

```shell
taosdump -h td1.taosdata.com -u root -ptaosdata -o /tmp/dump/db01 -T 8 -D db01 
```

### 2.2.备份超级表/普通表

超级表和普通表的备份方式基本相同。

```shell
##导出超级表
taosdump -h td1.taosdata.com -u root -ptaosdata -o /tmp/dump/stb1 -T 8  db01 stb1

##导出普通表
taosdump -h td1.taosdata.com -u root -ptaosdata -o /tmp/dump/tb1 -T 8  db01 tb1
```

## 3.数据恢复

### 3.1.恢复数据库

```shell
taosdump -h td1.taosdata.com -u root -ptaosdata -i /tmp/dump/db01 -T 8 
```

### 3.2.恢复超级表/普通表

超级表和普通表的恢复方式基本相同。

```shell
##导入超级表
taosdump -h td1.taosdata.com -u root -ptaosdata -i /tmp/dump/stb1 -T 8  

##导入普通表
taosdump -h td1.taosdata.com -u root -ptaosdata -i /tmp/dump/tb1 -T 8  
```

## 4.使用 CSV 导出导入

除 taosdump 外，TDengine 支持将终端输出数据保存为 CSV 文件，同时支持导入 CSV 文件。因此我们可以进行手动的逻辑备份和恢复。

此方法适用于导出导入普通表数据，对于超级表和数据库来讲，此方法较于复杂。

操作步骤如下：

### 4.1.获取建库建表语句

```sql
SHOW CREATE DATABASE db01\G;
SHOW CREATE STABELE stb1\G;
SHOW CREATE TABLE tb1\G;
```

使用 \G 可以获得更好的输出显示效果。

### 4.2.导出数据导 CSV 文件

```sql
SELECT * FROM tb1 >> /tmp/dmp/tb1.csv ;
```

### 4.3.在目标库创建相关数据库、超级表、表

```sql
##创建数据库
CREATE DATABASE db01 REPLICA 1 QUORUM 1 DAYS 7 KEEP 3650 CACHE 16 BLOCKS 9 MINROWS 100 MAXROWS 4096 WAL 1 FSYNC 3000 COMP 2 CACHELAST 0 PRECISION 'ms' UPDATE 0;
##创建超级表
CREATE STABLE `stb1` (`ts` TIMESTAMP,`v1` INT) TAGS (`t1` INT);
##创建普通表
CREATE TABLE `tb1` USING `stb1` TAGS (1);
```

### 4.4.处理 CSV 文件

由于导出的 CSV 文件带有列名，而导入的数据必须为数据文件，因此需要删除第一行。

```shell
sed -i '1d' /tmp/dmp/tb1.csv
```

### 4.5.导入 CSV 文件

```sql
INSERT INTO db01.tb1 FILE '/tmp/dmp/tb1.csv';
```

## 5.验证数据完整性

数据迁移后，必须验证数据的完整性。