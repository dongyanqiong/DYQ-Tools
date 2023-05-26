# CSV数据导出导入工具

- 支持将指定表导出为CSV文件，文件名与表名相同。
- 支持将CSV导入指定表，文件名必须与表名相同。
- 支持通过修改查询语句定制数据输出，如：指定列，指定时间范围

## 导出数据库下所有超级表和子表结构

```shell
./csvdump.sh -u root -p taosdata -o /tmp/ -d db01 -S
```

## 导出/tmp/tblist中指定表数据，输出为CSV

```shell
./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db01 -D
```
## 导入/tmp/tblist中指定表数据

```shell
./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db03 -I
```

## 参数说明

|参数|说明|
|---|----------|
|-u |用户名|
|-p |密码|
|-o |输出/输入文件目录|
|-f |导出表名列表文件|
|-d |数据库名称|
|-S |导出表结构|
|-D |导出表数据|
|-I |导入CSV|

## 初始参数

|参数|定义|默认值|
|---|----|----------|
|user|用户名|root|
|pass|密码|taosdata|
|outdir|输出/输入文件目录|/tmp|
|tblist|导出表名列表|/tmp/tblist|
|db|数据库名称||
|taos|客户端命令，适用于OEM|taos|
|sqlh|查询SQL前段，可定制|select * from |
|sqle|查询SQL后段，可定制| where _c0>0  |