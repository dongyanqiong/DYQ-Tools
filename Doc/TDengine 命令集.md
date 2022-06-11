
# TDengine 命令集

本章节 SQL 语法遵循如下约定：
```list
< > 里的内容是用户需要输入的，但不要输入 <> 本身
[ ] 表示内容为可选项，但不能输入 [] 本身
| 表示多选一，选择其中一个即可，但不能输入 | 本身
大写字母为 TDengine 关键字
dbanme 数据库名
tbname 普通表名
stbname 超级表名
num 数字
keep 数据保留时间，格式：keep1,keep2,keep3
ep End_Point 节点名称，通过SHOW DNODES 查看
dnodeid 节点ID号，通过SHOW DNODES 查看
password 密码
vgid VNODE的ID号，通过SHOW VGROUPS 查看
```

## 1.集群命令

### 添加节点

CREATE DNODE <_"ep"_>;

### 删除节点

DROP DNODE [IF EXISTS] <_dnodeid|ep_>;

注意：

a.删除节点时必须保证剩余正常节点【状态为Ready】数量大于最大副本数。

b.删除节点是，该节点状态必须为Ready。

### 查询数据节点状态

SHOW DNODES;

### 查询管理节点状态

SHOW MNODES;

## 2.数据库命令

### 创建数据库

CREATE DATABASE [IF NOT EXISTS] <_dbname_> [BLOCKS _num_] [CACHELAST <1|2|3>] [COMP <0|1|2>] [KEEP _keep_] [PRECISION <_'ns'_>] [REPLICA <1|2|3>] [QUORUM <1|2>] [UPDATE <0|1|2>];

### 删除数据库

DROP DATABASE [IF EXISTS] <_dbname_>;

### 修改数据库参数

ALTER DATABASE <_dbname_> [BLOCKS _num_] [CACHELAST <1|2|3>] [COMP <0|1|2>] [KEEP _keep_] [REPLICA <1|2|3>] [QUORUM <1|2>];

### 查询vnode状态

SHOW [_dbname_.]VGROUPS;

## 3.超级表命令

### 创建超级表

CREATE STABLE [IF NOT EXISTS] <_[dbname.]stbname_> (timestamp __field_name_ TIMESTAMP, _field1_name data_type1_ [, _field2_name data_type2_ ...]) TAGS (_tag1_name tag_type1, tag2_name tag_type2_ [, _tag3_name tag_type3_]);

### 删除超级表

DROP STABLE [IF EXISTS] <_[dbname.]stbname_>;

### 修改超级表列

ALTER STABLE <_[dbname.]stbname_> ADD COLUMN <_field_name_> <_data_type_>;

ALTER STABLE <_[dbname.]stbname_> DROP COLUMN <_field_name_>;

ALTER STABLE <_[dbname.]stbname_> MODIFY COLUMN <_field_name_> <_data_type(length)_>;

### 修改超级表标签

ALTER STABLE <_[dbname.]stb_name_> ADD TAG <_new_tag_name tag_type_>;

ALTER STABLE <_[dbname.]stb_name_> CHANGE TAG <_old_tag_name new_tag_name_>;

ALTER STABLE <_[dbname.]stb_name_> DROP TAG <_tag_name_>;

注意：不能删除超级表的第一个标签

## 4.普通表命令

### 创建普通表

CREATE TABLE [IF NOT EXISTS] <_[dbname.]tbname_> (_timestamp_field_name_ TIMESTAMP, _field1_name data_type1_ [, _field2_name data_type2_ ...]);

### 删除普通表

DROP TABLE [IF EXISTS] <_[dbname.]tbname_>;

### 修改普通表列

ALTER TABLE <_[dbname.]tbname_> ADD COLUMN <_field_name_> <_data_type_>;

ALTER TABLE <_[dbname.]tbname_> DROP COLUMN <_field_name_>;

ALTER TABLE <_[dbname.]stbname_> MODIFY COLUMN <_field_name_> <_data_type(length)_>;

## 5.用户命令

### 创建用户

CREATE USER <*username*> PASS <'*password*'>;

### 修改用户密码

ALTER USER <_username_> PASS <_password_>;

### 修改用户权限

ALTER USER <_username_> PRIVILEGE <_write|read_>;

### 删除用户

DROP USER [IF EXISTS] <_username_>;

## 6.维护命令

### 迁移vnode

ALTER DNODE <_dondeid_> BALANCE "VNODE:<_vgid_>-DNODE:<_dnodeid_>";

### 压缩vnode

COMPACT VNODE IN (_vgid,vgid,vgid_);

## 7.TDengine工具

### 客户端

taos

### 导出导入工具

taosdump

### 压测工具

taosBenchmark

## 索引

### A

ALTER DATABASE <_dbname_> [BLOCKS _num_] [CACHELAST <1|2|3>] [COMP <0|1|2>] [KEEP _keep_] [REPLICA <1|2|3>] [QUORUM <1|2>];

ALTER DNODE <_dondeid_> BALANCE "VNODE:<_vgid_>-DNODE:<_dnodeid_>";

ALTER DNODE DEBUGFLAG <_131|135|143_>;

ALTER DNODE RESETLOG;

ALTER STABLE <_[dbname.]stbname_> ADD COLUMN <_field_name_> <_data_type_>;

ALTER STABLE <_[dbname.]stb_name_> ADD TAG <_new_tag_name tag_type_>;

ALTER STABLE <_[dbname.]stb_name_> CHANGE TAG <_old_tag_name new_tag_name_>;

ALTER STABLE <_[dbname.]stbname_> DROP COLUMN <_field_name_>;

ALTER STABLE <_[dbname.]stb_name_> DROP TAG <_tag_name_>;

ALTER STABLE <_[dbname.]stbname_> MODIFY COLUMN <_field_name_> <_data_type(length)_>;

ALTER TABLE <_[dbname.]stbname_> MODIFY COLUMN <_field_name_> <_data_type(length)_>;

ALTER TABLE <_[dbname.]tbname_> ADD COLUMN <_field_name_> <_data_type_>;

ALTER TABLE <_[dbname.]tbname_> DROP COLUMN <_field_name_>;

ALTER TABLE <_[dbname.]tbname_> MODIFY COLUMN <_field_name_> <_data_type(length)_>;

ALTER TABLE <_[dbname.]tbname_> SET TAG <_tag_name=new_tag_value_>;

ALTER USER <_username_> PASS <_password_>;

ALTER USER <_username_> PRIVILEGE <_write|read_>;

### C

COMPACT VNODE IN (_vgid,vgid,vgid_);

CREATE DATABASE [IF NOT EXISTS] <_dbname_> [BLOCKS _num_] [CACHELAST <1|2|3>] [COMP <0|1|2>] [KEEP _keep_] [PRECISION <_'ns'_>] [REPLICA <1|2|3>] [QUORUM <1|2>] [UPDATE <0|1|2>];

CREATE DNODE <_"ep"_>;

CREATE STABLE [IF NOT EXISTS] <_[dbname.]stbname_> (timestamp __field_name_ TIMESTAMP, _field1_name data_type1_ [, _field2_name data_type2_ ...]) TAGS (_tag1_name tag_type1, tag2_name tag_type2_ [, _tag3_name tag_type3_]);

CREATE TABLE [IF NOT EXISTS] <_[dbname.]tbname_> (_timestamp_field_name_ TIMESTAMP, _field1_name data_type1_ [, _field2_name data_type2_ ...]);

CREATE TABLE [IF NOT EXISTS] <_[dbname.]tbname_> USING _stb_name_ TAGS (_tag_value1_, ...);

CREATE USER <_username_> PASS <'_password_'>;

### D
DESCRIBE <_[dbname.]stbname_>;

DESCRIBE <_[dbname.]tbname_>;

DROP DNODE [IF EXISTS] <_dnodeid|ep_>;

DROP DATABASE [IF EXISTS] <_dbname_>;

DROP STABLE [IF EXISTS] <_[dbname.]stbname_>;

DROP TABLE [IF EXISTS] <_[dbname.]tbname_>;

DROP USER [IF EXISTS] <_username_>;

### I
INSERT INTO
    <_[dbname.]tbname_>
        [USING _stb_name_ [(_tag1_name_, ...)] TAGS (_tag1_value_, ...)]
        [(_field1_name_, ...)]
        VALUES (_field1_value_, ...) [(_field1_value2_, ...) ...] | FILE _csv_file_path_
    [ _[dbname.]tb2_name_
        [USING _stb_name_ [(_tag1_name_, ...)] TAGS (_tag1_value_, ...)]
        [(_field1_name_, ...)]
        VALUES (_field1_value_, ...) [(_field1_value2_, ...) ...] | FILE _csv_file_path_
    ...];

### K

KILL CONNECTION <_connection_id_>;

KILL QUERY <_query_id_>;

KILL STREAM <_stream_id_>;

### S

SET MAX_BINARY_DISPLAY_WIDTH <_num_>;

SELECT \_BLOCK_DIST() FROM <_[dbname.]stbname|[dbname.]tbname_>;

SELECT CLIENT_VERSION();

SELECT DATABASE();

SELECT SERVER_VERSION();

SELECT CURRENT_USER();

SHOW CREATE DATABASE <_dbname_>;

SHOW CREATE STABLE <_[dbname.]stbname_>;

SHOW CREATE TABLE <_[dbname.]tbname_>;

SHOW CONNECTIONS;

SHOW DATABASES;

SHOW DNODES;

SHOW QUERIES;

SHOW [_dbname._]STABLES [LIKE '_tbname_name_wildcar_'];

SHOW STREAMS;

SHOW [_dbname_.]TABLES [LIKE '_tbname_name_wildcar_'];

SHOW MNODES;

SHOW [_dbname_.]VGROUPS;

SHOW USERS;

SHOW VARIABLES;

### T

taos

taosd

taosdump

taosBenchmark

### U

USE <_dbname_>;
