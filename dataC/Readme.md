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
> 支持多线程

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
python datac.py -p process
```
### 查看帮助
```shell
python datac.py -h
```


## 配置文件说明
{

    "exporUrl":"http://127.0.0.1:6041/rest/sql",  #导出数据库 Restful接口

    "exportDBName":"test",  #导出数据库名称

    "exportUsername":"root",    #导出数据库用户名

    "exportPassword":"prodb",   #导出数据库密码

    "importUrl":"http://127.0.0.1:6041/rest/sql",   #导入数据Restful接口

    "importDBName":"test3", #导入数据库名称

    "importUsername":"test",    #导入数据库用户名

    "importPassword":"test",    #导入数据库密码

    "recodeOfPerSQL":100,       #单条SQL包含记录数

    "startTime":1321946822000,  #查询起始时间

    "threadNum":10              #并发线程数
    
}



## 设置定时任务
如果想设置定时任务，定时同步数据，可以将起始时间修改为动态值。
如：
将起始时间设置为
```python
stime = str(int(time.time()*1000-86400000))
```
则会同步24小时内数据。