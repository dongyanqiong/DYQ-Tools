## 数据传输工具
通过Restful 表到表传输数据。

> 支持同步整个数据库，或从文件读取表。
> 
> 支持多条拼SQL （配置 recodeOfPerSQL）。
> 
> 支持导入导出表异构，但表名必须相同。
> 
> 支持指定数据起始时间
> 
> 兼容 python2 和 python3 两个版本
> 
> 支持多线程和多进程
>
> 如果子表不存在会自动创建子表，如果超级表不存在会直接报错。
>
> 使用datac_init.py 会同步创建所有超级表和子表，但不会创建数据库。

## 参数说明
-c filename  指定配置文件，默认datac.cfg

-p 采用多进程模式，默认多线程

-f filename  表清单，默认同步所有表。


## 示例
### 从文件读取表清单
```python
python datac.py -f tblist
```
### 同步整个数据库（如果未指定表文件，则同步整个数据库）
```shell
python datac.py
```

### 多进程模式（默认为多线程）
```shell
python datac.py -p 
```
### 查看帮助
```shell
python datac.py -h
```
### 初始化数据库
创建所有超级表和子表
```shell
python datac_init.py
```



## 配置文件说明
{

    "exporUrl":"http://127.0.0.1:6041/rest/sqlt",  #导出数据库 Restful接口

    "exportDBName":"test",  #导出数据库名称

    "exportUsername":"root",    #导出数据库用户名

    "exportPassword":"prodb",   #导出数据库密码

    "exportVersion":2,          #数据库版本

    "importUrl":"http://127.0.0.1:6041/rest/sql",   #导入数据Restful接口

    "importDBName":"test3", #导入数据库名称

    "importUsername":"test",    #导入数据库用户名

    "importPassword":"test",    #导入数据库密码

    "importVersion":3,          #数据库版本

    "tableonly":"false",        #是否只导表结构

    "sqlheader":"select * from ",   #查询SQL头，可根据实际需求定制

    "recodeOfPerSQL":100,       #单条SQL包含记录数

    "startTime":1321946822000,  #查询起始时间

    "threadNum":10              #并发线程数
    
}

对于 2.x 版本建议采用  sqlt 接口。


## 设置定时任务
如果想设置定时任务，定时同步数据，可以将起始时间修改为动态值。
如：
将起始时间设置为
```python
stime = str(int(time.time()*1000-86400000))
```
则会同步24小时内数据。