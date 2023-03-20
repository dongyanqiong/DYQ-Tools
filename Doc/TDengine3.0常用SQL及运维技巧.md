TDengine 3.0 引入了 information_schema 和 performance_schema 两个临时表，这意味着之前很多能 SHOW 处理的信息必须通过 SQL 查询了，同时也使得查询更加方便。
如果不会使用，就不能就抱怨 TDengine 坑多了。
以下就是整理的运维中常用的 SQL。

```sql
taos> show databases;
              name              |
=================================
 information_schema             |
 performance_schema             |
 test                           |
Query OK, 3 row(s) in set (0.026800s)
```

## 0.按标签过滤查询子表数量
将这个语句放在第一条，是因为 3.0 区别和 2.6 太大了，很多人都会踩 KENG 里面。
```sql
taos> select distinct tbname,groupid from test.meters where groupid=10;
             tbname             |   groupid   |
===============================================
 d2                             |          10 |
 d5008                          |          10 |
 d8755                          |          10 |
......
 d6672                          |          10 |
 d4177                          |          10 |

 Notice: The result shows only the first 100 rows.
         You can use the `LIMIT` clause to get fewer result to show.
           Or use '>>' to redirect the whole set of the result to a specified file.

         You can use Ctrl+C to stop the underway fetching.

Query OK, 1047 row(s) in set (0.017102s)
```



## 1. 查询数据库或超级表下有多少子表

```sql
taos> select count(*) from information_schema.ins_tables where db_name="test";
       count(*)        |
========================
                 10000 |
Query OK, 1 row(s) in set (0.012780s)

taos> select count(*) from information_schema.ins_tables where db_name="test" and stable_name="meters";
       count(*)        |
========================
                 10000 |
Query OK, 1 row(s) in set (0.011303s)

```

## 2.查询数据库下有多少普通表

```sql
taos> select count(*) from information_schema.ins_tables where db_name="test" and type="NORMAL_TABLE" ;
       count(*)        |
========================
                     4 |
Query OK, 1 row(s) in set (0.025889s)

```

## 3.查询数据库参数

```sql
taos> select * from information_schema.ins_databases where name='test'\G;
*************************** 1.row ***************************
                name: test
         create_time: 2023-03-20 08:11:33.716
             vgroups: 4
             ntables: 10004
             replica: 1
              strict: on
            duration: 14400m
                keep: 5256000m,5256000m,5256000m
              buffer: 256
            pagesize: 4
               pages: 256
             minrows: 100
             maxrows: 4096
                comp: 2
           precision: ms
              status: ready
          retentions: NULL
       single_stable: false
          cachemodel: none
           cachesize: 1
           wal_level: 1
    wal_fsync_period: 3000
wal_retention_period: 0
  wal_retention_size: 0
     wal_roll_period: 0
    wal_segment_size: 0
         stt_trigger: 1
        table_prefix: 0
        table_suffix: 0
       tsdb_pagesize: 4
Query OK, 1 row(s) in set (0.009516s)
```
效果和 `show create database test \G;` 相同

## 4.查询每个vnode下缓存的子表数量(last/last_row)

```sql
taos> select vgroup_id,`tables`,cacheload,`cacheTables` from information_schema.ins_vgroups where db_name='test';
  vgroup_id  |   tables    |  cacheload  | cacheTables |
========================================================
           2 |        2485 |      694960 |        2482 |
           3 |        2523 |      706160 |        2522 |
           4 |        2520 |      705600 |        2520 |
           5 |        2476 |      693280 |        2476 |
Query OK, 4 row(s) in set (0.006786s)
```
注意：部分列名为关键词，需要加反引号！！

## 5.查询耗时长的查询

```sql
taos> select `user`,`exec_usec`/1000000 cost_time,sql from performance_schema.perf_queries;
           user           |         cost_time         |              sql               |
========================================================================================
 root                     |               0.777875000 | select count(*) from test.m... |
 root                     |               0.799425000 | select count(*) from test.m... |
 root                     |               0.811605000 | select count(*) from test.m... |
 root                     |               0.793454000 | select count(*) from test.m... |
Query OK, 4 row(s) in set (0.110338s)
```
### 扩展：杀死所有对 meters 表的查询
有时某些 SQL 写的不合理，大批量打到数据库，会让整个数据库卡住，这是需要快速的将查询找到并 kill。
以下命令可以将所有对表 meters 的查询一次性杀死。慎用！！！

```shell
taos -uroot -ptaosdata -s "select kill_id from performance_schema.perf_queries where sql like '%meters%';" | \
grep '|' |grep -v ' kill_id '| awk '{print "kill query \""$1"\";"}' > kill.sql && taos -uroot -ptaosdata -f kill.sql

```
注：也可以对用户进行过滤

## 6.锁定用户
运维中，我们经常需要暂时锁定用户，3.0 终于支持了。
```sql
taos> alter user test enable 0;
Query OK, 0 row(s) affected (0.008728s)

taos> q
[root@test1 ~]# taos -utest -ptst
Welcome to the TDengine Command Line Interface, Client Version:3.0.3.0
Copyright (c) 2022 by TDengine, all rights reserved.

failed to connect to server, reason: User is disabled
```
```sql
taos> alter user test enable 1;
Query OK, 0 row(s) affected (0.005976s)

taos> q
[root@test1 ~]# taos -utest -ptest
Welcome to the TDengine Command Line Interface, Client Version:3.0.3.0
Copyright (c) 2022 by TDengine, all rights reserved.

   ******************************  Tab Completion  **********************************
   *   The TDengine CLI supports tab completion for a variety of items,             *
  *   including database names, table names, function names and keywords.              *
  *   The full list of shortcut keys is as follows:                                    *
  *    [ TAB ]        ......  complete the current word                                *
  *                   ......  if used on a blank line, display all supported commands  *
  *    [ Ctrl + A ]   ......  move cursor to the st[A]rt of the line                   *
  *    [ Ctrl + E ]   ......  move cursor to the [E]nd of the line                     *
  *    [ Ctrl + W ]   ......  move cursor to the middle of the line                    *
  *    [ Ctrl + L ]   ......  clear the entire screen                                  *
  *    [ Ctrl + K ]   ......  clear the screen after the cursor                        *
  *    [ Ctrl + U ]   ......  clear the screen before the cursor                       *
  **************************************************************************************

Server is Enterprise trial Edition, ver:3.0.3.0 and will expire at 2023-05-20 10:36:32.

```


## 7.查询用户权限

```sql
taos> select * from information_schema.ins_user_privileges where user_name='test';
        user_name         | privilege  |          object_name           |
=========================================================================
 test                     | read       | test                           |
 test                     | write      | test                           |
Query OK, 2 row(s) in set (0.006765s)

```

### 授权和回收权限
和关系库一样，不赘述，看示例：
```sql
taos> select * from information_schema.ins_user_privileges where user_name='test';
        user_name         | privilege  |          object_name           |
=========================================================================
 test                     | read       | test                           |
 test                     | write      | test                           |
Query OK, 2 row(s) in set (0.005283s)

taos> revoke write on test.* from test;
Query OK, 0 row(s) affected (0.004754s)

taos> select * from information_schema.ins_user_privileges where user_name='test';
        user_name         | privilege  |          object_name           |
=========================================================================
 test                     | read       | test                           |
Query OK, 1 row(s) in set (0.004692s)

taos> grant write on test.* to test;
Query OK, 0 row(s) affected (0.008323s)

taos> select * from information_schema.ins_user_privileges where user_name='test';
        user_name         | privilege  |          object_name           |
=========================================================================
 test                     | read       | test                           |
 test                     | write      | test                           |
Query OK, 2 row(s) in set (0.004149s)
```

## 8.查看 SQL 执行计划
这个算是比较实用的功能了。
```sql
taos> explain select _wstart as ts,count(*) from test.meters interval(1h) order by ts desc\G;
*************************** 1.row ***************************
QUERY_PLAN: -> Merge Aligned Interval on Column #expr_1 (functions=2 width=16)
*************************** 2.row ***************************
QUERY_PLAN:    -> SortMerge (columns=2 width=16)
*************************** 3.row ***************************
QUERY_PLAN:       -> Data Exchange 1:1 (width=16)
*************************** 4.row ***************************
QUERY_PLAN:          -> Interval on Column ts (functions=2 width=16 input_order=asc output_order=desc)
*************************** 5.row ***************************
QUERY_PLAN:             -> Table Scan on meters (columns=1 width=8 order=[asc|1 desc|0])
*************************** 6.row ***************************
QUERY_PLAN:       -> Data Exchange 1:1 (width=16)
*************************** 7.row ***************************
QUERY_PLAN:          -> Interval on Column ts (functions=2 width=16 input_order=asc output_order=desc)
*************************** 8.row ***************************
QUERY_PLAN:             -> Table Scan on meters (columns=1 width=8 order=[asc|1 desc|0])
*************************** 9.row ***************************
QUERY_PLAN:       -> Data Exchange 1:1 (width=16)
*************************** 10.row ***************************
QUERY_PLAN:          -> Interval on Column ts (functions=2 width=16 input_order=asc output_order=desc)
*************************** 11.row ***************************
QUERY_PLAN:             -> Table Scan on meters (columns=1 width=8 order=[asc|1 desc|0])
*************************** 12.row ***************************
QUERY_PLAN:       -> Data Exchange 1:1 (width=16)
*************************** 13.row ***************************
QUERY_PLAN:          -> Interval on Column ts (functions=2 width=16 input_order=asc output_order=desc)
*************************** 14.row ***************************
QUERY_PLAN:             -> Table Scan on meters (columns=1 width=8 order=[asc|1 desc|0])
Query OK, 14 row(s) in set (0.001709s)
```
