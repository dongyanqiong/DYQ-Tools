TDengine 的 interp 函数是用来查询时间截面数据。

单独介绍这个函数，是因为这个函数的用法和其他函数太 TMD 不同了。

官方说明：https://docs.taosdata.com/taos-sql/function/#

# 语法示例

```sql
select _irowts,interp(COLUNM_NAME) 
from TABLE_NAME 
[where _c0 >= STARTIME and _c0 <= ENDTIME] 
range（'STARTTIME','ENDTIME'）
every(INTERVAL) 
fill(prev|next|null|linear|value); 

```
# 测试用数据

```sql

taos> select * from test3;
           ts            |     v1      |
========================================
 2023-01-01 00:00:01.000 |           1 |
 2023-01-01 00:00:02.000 |           2 |
 2023-01-01 00:00:04.000 |           4 |
 2023-01-01 00:00:06.000 |           6 |
 2023-01-01 00:00:07.000 |           7 |
 2023-01-01 00:00:11.000 |          11 |
Query OK, 6 row(s) in set (0.001900s)          

```

# 语法说明

## fill

prev 填充上一个值
```sql
taos> select _irowts,interp(v1) from test3  range('2023-01-01 00:00:01.000','2023-01-01 00:00:05.000') every(1s) fill(prev);
         _irowts         | interp(v1)  |
========================================
 2023-01-01 00:00:01.000 |           1 |
 2023-01-01 00:00:02.000 |           2 |
 2023-01-01 00:00:03.000 |           2 |
 2023-01-01 00:00:04.000 |           4 |
 2023-01-01 00:00:05.000 |           4 |
Query OK, 5 row(s) in set (0.002293s)
```

next 填充下一个值
```sql
taos> select _irowts,interp(v1) from test3  range('2023-01-01 00:00:01.000','2023-01-01 00:00:05.000') every(1s) fill(next);
         _irowts         | interp(v1)  |
========================================
 2023-01-01 00:00:01.000 |           1 |
 2023-01-01 00:00:02.000 |           2 |
 2023-01-01 00:00:03.000 |           4 |
 2023-01-01 00:00:04.000 |           4 |
 2023-01-01 00:00:05.000 |           6 |
Query OK, 5 row(s) in set (0.002175s)
```

null 填充为null
```sql

taos> select _irowts,interp(v1) from test3  range('2023-01-01 00:00:01.000','2023-01-01 00:00:05.000') every(1s) fill(null);
         _irowts         | interp(v1)  |
========================================
 2023-01-01 00:00:01.000 |           1 |
 2023-01-01 00:00:02.000 |           2 |
 2023-01-01 00:00:03.000 |        NULL |
 2023-01-01 00:00:04.000 |           4 |
 2023-01-01 00:00:05.000 |        NULL |
Query OK, 5 row(s) in set (0.002191s)
```

linear 根据线性计算进行填充
```sql
taos> select _irowts,interp(v1) from test3  range('2023-01-01 00:00:01.000','2023-01-01 00:00:05.000') every(1s) fill(linear);
         _irowts         | interp(v1)  |
========================================
 2023-01-01 00:00:01.000 |           1 |
 2023-01-01 00:00:02.000 |           2 |
 2023-01-01 00:00:03.000 |           3 |
 2023-01-01 00:00:04.000 |           4 |
 2023-01-01 00:00:05.000 |           5 |
Query OK, 5 row(s) in set (0.002216s)
```

value 使用固定值进行填充
```sql

taos> select _irowts,interp(v1) from test3  range('2023-01-01 00:00:01.000','2023-01-01 00:00:05.000') every(1s) fill(value,100);
         _irowts         | interp(v1)  |
========================================
 2023-01-01 00:00:01.000 |           1 |
 2023-01-01 00:00:02.000 |           2 |
 2023-01-01 00:00:03.000 |         100 |
 2023-01-01 00:00:04.000 |           4 |
 2023-01-01 00:00:05.000 |         100 |
Query OK, 5 row(s) in set (0.001976s)
```


# range
range 限定的是查询结果的输出范围，如果没有在 where 中做时间范围限定，则默认为表中所有数据。
说明如下：

```sql
taos> select _irowts,interp(v1) from test3  range('2023-01-01 00:00:01.000','2023-01-01 00:00:05.000') every(1s) fill(next);
         _irowts         | interp(v1)  |
========================================
 2023-01-01 00:00:01.000 |           1 |
 2023-01-01 00:00:02.000 |           2 |
 2023-01-01 00:00:03.000 |           4 |
 2023-01-01 00:00:04.000 |           4 |
 2023-01-01 00:00:05.000 |           6 |
Query OK, 5 row(s) in set (0.002175s)
```
在原始数据集中 `2023-01-01 00:00:03.000` 和 `2023-01-01 00:00:05.000` 都没有值，都是根据 next 规则进行填值。`2023-01-01 00:00:03.000` 填充的是 `2023-01-01 00:00:04.000` 的值，而 `2023-01-01 00:00:05.000` 填充的是 `2023-01-01 00:00:06.000` 的值。

`2023-01-01 00:00:06.000` 虽然不在range范围内，但如上描述，在没有 where 限定的条件，整个表的数据都作为输入。

如果用 where 限定时间范围后如何呢？

```sql
taos> select _irowts,interp(v1) from test3 where ts>='2023-01-01 00:00:01.000' and ts<='2023-01-01 00:00:05.000'  range('2023-01-01 00:00:01.000','2023-01-01 00:00:05.000') every(1s) fill(next);
         _irowts         | interp(v1)  |
========================================
 2023-01-01 00:00:01.000 |           1 |
 2023-01-01 00:00:02.000 |           2 |
 2023-01-01 00:00:03.000 |           4 |
 2023-01-01 00:00:04.000 |           4 |
 2023-01-01 00:00:05.000 |           6 |
Query OK, 5 row(s) in set (0.002064s)
```
看结果貌似是一致的，where 没有生效。难道是bug？？

再做个测试验证一下。将数据集放大，看是否影响查询效率。
先用taosBenchmark写入200w条数据。
```shell
{
"filetype":"insert",
"cfgdir":"/etc/taos",
"host":"c3-28",
"port":6030,
"user":"root",
"password":"taosdata",
"thread_count":6,
"thread_count_create_tbl":4,
"num_of_records_per_req":1000,
"result_file":"r512.txt",
"confirm_parameter_prompt":"no",
"databases":[{
"dbinfo":{
"name":"interptest",
"drop":"yes"
},
"super_tables":[{
"name":"stb",
"child_table_exists":"no",
"childtable_count":1,
"childtable_prefix":"tb",
"auto_create_table":"no",
"batch_create_tbl_num":200,
"data_source":"rand",
"insert_mode":"stmt",
"insert_interval":200,
"insert_rows":2000000,
"interlace_rows":2000,
"max_sql_len":1048576,
"disorder_ratio":0,
"disorder_range":1000,
"timestamp_step":2000,
"start_timestamp":"2022-01-01 00:00:00.000",
"sample_format":"csv",
"sample_file":"",
"tags_file":"",
"columns": [{"type":"TIMESTAMP","count":1},{"type":"INT","count":1}],
"tags":[{"type":"INT","count":1}]
}]
}]
}
```

```sql
taos> use interptest;
Database changed.

taos> show tables;
           table_name           |
=================================
 tb0                            |
Query OK, 1 row(s) in set (0.003788s)

taos> select count(*) from tb0;
       count(*)        |
========================
               2000000 |
Query OK, 1 row(s) in set (0.018702s)
```

```sql
taos> select _irowts,interp(c1) from tb0  range('2022-01-30 00:00:00.000','2022-01-30 00:00:10.000') every(1s) fill(next);
         _irowts         | interp(c1)  |
========================================
 2022-01-30 00:00:00.000 |  -302286447 |
 2022-01-30 00:00:01.000 |  -889820100 |
 2022-01-30 00:00:02.000 |  -889820100 |
 2022-01-30 00:00:03.000 |  -743803074 |
 2022-01-30 00:00:04.000 |  -743803074 |
 2022-01-30 00:00:05.000 |   308649021 |
 2022-01-30 00:00:06.000 |   308649021 |
 2022-01-30 00:00:07.000 |  -787675400 |
 2022-01-30 00:00:08.000 |  -787675400 |
 2022-01-30 00:00:09.000 |  -682749733 |
 2022-01-30 00:00:10.000 |  -682749733 |
Query OK, 11 row(s) in set (0.003133s)

taos> select _irowts,interp(c1) from tb0 where ts>='2022-01-30 00:00:00.000' and ts<='2022-01-30 00:01:00.000' range('2022-01-30 00:00:00.000','2022-01-30 00:00:10.000') every(1s) fill(next);
         _irowts         | interp(c1)  |
========================================
 2022-01-30 00:00:00.000 |  -302286447 |
 2022-01-30 00:00:01.000 |  -889820100 |
 2022-01-30 00:00:02.000 |  -889820100 |
 2022-01-30 00:00:03.000 |  -743803074 |
 2022-01-30 00:00:04.000 |  -743803074 |
 2022-01-30 00:00:05.000 |   308649021 |
 2022-01-30 00:00:06.000 |   308649021 |
 2022-01-30 00:00:07.000 |  -787675400 |
 2022-01-30 00:00:08.000 |  -787675400 |
 2022-01-30 00:00:09.000 |  -682749733 |
 2022-01-30 00:00:10.000 |  -682749733 |
Query OK, 11 row(s) in set (0.003166s)
```

where 貌似没啥卵用, 真是让人迷惑的功能。


