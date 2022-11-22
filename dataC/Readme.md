## 数据传输工具
通过Restful 表到表传输数据。

> 支持同步整个数据库，或从文件读取表。
> 支持多条拼SQL （配置 offnum）。
> 支持导入导出表异构，但表名必须相同。
> 支持指定数据起始时间
> 提供 python2 和 python3 两个版本

## 示例
### 同步tblist中的表
```python
python3 data_python3.py tblist
```
### 同步整个数据库（如果未指定表文件，则同步整个数据库）
```python
python3 data_python3.py
```



可采用多进程调用达到并发效果，如：
```shell
for i in $(ls list_0*)
do 
    python3 datac.py $i & 
done

```