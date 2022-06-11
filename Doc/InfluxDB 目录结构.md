# InfluxDB 目录结构详解

## 1.目录路径

InfluxDB 包含以下目录：

| 目录         | 默认                         | 用途                   |
| ------------ | ---------------------------- | ---------------------- |
| Engine Path  | ~/.influxdbv2/engine/        | 存储时序数据           |
| BOLT Path    | ~/.influxdbv2/influxd.bolt   | 存储关系型数据，如用户 |
| SQLite Path  | ~/.influxdbv2/influxd.sqlite | 存储notebooks 数据     |
| Configs Path | ~/.influxdbv2/configs        | 存储配置文件           |
|              |                              |                        |

查看当前使用的目录

```shell
##查询服务配置
influx server-config
```

```shell
# influx server-config | grep '-path'
        "assets-path": "",
        "bolt-path": "/root/.influxdbv2/influxd.bolt",
        "engine-path": "/data/influndb/data",
        "sqlite-path": "/root/.influxdbv2/influxd.sqlite",
```

## 2.非时序数据目录

以下目录存储的为非时序性数据，属于InfluxDB的辅助功能。

```shell
# tree ~/.influxdbv2/
/root/.influxdbv2/
├── configs
├── influxd.bolt
└── influxd.sqlite
```

## 3.时序数据目录

为了方便的解读数据文件目录，我们先查询一下当前的buckts

```shell
# influx bucket list
ID                      Name            Retention       Shard group duration    Organization ID         Schema Type
74091a2d2a220be1        _monitoring     168h0m0s        24h0m0s                 d781e1ab6a34faad        implicit
5175f85981b38eef        _tasks          72h0m0s         24h0m0s                 d781e1ab6a34faad        implicit
493461b293cb9760        db01            infinite        168h0m0s                d781e1ab6a34faad        implicit
1b50453093dc429b        db02            240h0m0s        24h0m0s                 d781e1ab6a34faad        implicit
```

```shell
# tree /data/influndb/data/
/data/influndb/data/
├── data
│   ├── 1b50453093dc429b
│   │   ├── autogen
│   │   │   └── 2
│   │   │       ├── 000000001-000000001.tsm
│   │   │       ├── fields.idx
│   │   │       └── index
│   │   │           ├── 0
│   │   │           │   ├── L0-00000001.tsl
│   │   │           │   └── MANIFEST
│   │   │           ├── 1
│   │   │           │   ├── L0-00000001.tsl
│   │   │           │   └── MANIFEST
│   │   │           ├── 2
│   │   │           │   ├── L0-00000001.tsl
│   │   │           │   └── MANIFEST
│   │   │           ├── 3
│   │   │           │   ├── L0-00000002.tsl
│   │   │           │   ├── L1-00000001.tsi
│   │   │           │   └── MANIFEST
│   │   │           ├── 4
│   │   │           │   ├── L0-00000001.tsl
│   │   │           │   └── MANIFEST
│   │   │           ├── 5
│   │   │           │   ├── L0-00000001.tsl
│   │   │           │   └── MANIFEST
│   │   │           ├── 6
│   │   │           │   ├── L0-00000001.tsl
│   │   │           │   └── MANIFEST
│   │   │           └── 7
│   │   │               ├── L0-00000001.tsl
│   │   │               └── MANIFEST
│   │   └── _series
│   │       ├── 00
│   │       │   └── 0000
│   │       ├── 01
│   │       │   └── 0000
│   │       ├── 02
│   │       │   └── 0000
│   │       ├── 03
│   │       │   └── 0000
│   │       ├── 04
│   │       │   └── 0000
│   │       ├── 05
│   │       │   └── 0000
│   │       ├── 06
│   │       │   └── 0000
│   │       └── 07
│   │           └── 0000
│   └── 493461b293cb9760
│       ├── autogen
│       │   └── 1
│       │       ├── 000000003-000000002.tsm
│       │       ├── fields.idx
│       │       └── index
│       │           ├── 0
│       │           │   ├── L0-00000001.tsl
│       │           │   └── MANIFEST
│       │           ├── 1
│       │           │   ├── L0-00000001.tsl
│       │           │   └── MANIFEST
│       │           ├── 2
│       │           │   ├── L0-00000001.tsl
│       │           │   └── MANIFEST
│       │           ├── 3
│       │           │   ├── L0-00000002.tsl
│       │           │   ├── L1-00000001.tsi
│       │           │   └── MANIFEST
│       │           ├── 4
│       │           │   ├── L0-00000001.tsl
│       │           │   └── MANIFEST
│       │           ├── 5
│       │           │   ├── L0-00000001.tsl
│       │           │   └── MANIFEST
│       │           ├── 6
│       │           │   ├── L0-00000001.tsl
│       │           │   └── MANIFEST
│       │           └── 7
│       │               ├── L0-00000002.tsl
│       │               ├── L1-00000001.tsi
│       │               └── MANIFEST
│       └── _series
│           ├── 00
│           │   └── 0000
│           ├── 01
│           │   └── 0000
│           ├── 02
│           │   └── 0000
│           ├── 03
│           │   └── 0000
│           ├── 04
│           │   └── 0000
│           ├── 05
│           │   └── 0000
│           ├── 06
│           │   └── 0000
│           └── 07
│               └── 0000
├── replicationq
└── wal
    ├── 1b50453093dc429b
    │   └── autogen
    │       └── 2
    │           └── _00003.wal
    └── 493461b293cb9760
        └── autogen
            └── 1
                └── _00005.wal
```

数据目录下包含三个文件夹：

- data 存储TSM相关文件
- wal  存储WAL日志
- replicationq  存储流计算相关文件

### 3.1.data

TSM数据目录下有两个文件夹：

- autogen
- _series

[autogen]下一级[2]为自动生成的递增顺序号

- 000000004-000000002.tsm  压缩后时序数据文件
- fields.idx 数据文件索引
- [index] 索引目录

[_series]包含00-07八个目录



```shell
/data/influndb/data/data
├── [4.0K]  1b50453093dc429b
│   ├── [4.0K]  autogen
│   │   ├── [4.0K]  2
│   │   │   ├── [1005]  000000004-000000002.tsm
│   │   │   ├── [  38]  fields.idx
│   │   │   └── [4.0K]  index
│   │   │       ├── [4.0K]  0
│   │   │       │   ├── [   0]  L0-00000001.tsl
│   │   │       │   └── [ 419]  MANIFEST
│   │   │       ├── [4.0K]  1
│   │   │       │   ├── [   0]  L0-00000001.tsl
│   │   │       │   └── [ 419]  MANIFEST
│   │   │       ├── [4.0K]  2
│   │   │       │   ├── [   0]  L0-00000001.tsl
│   │   │       │   └── [ 419]  MANIFEST
│   │   │       ├── [4.0K]  3
│   │   │       │   ├── [   0]  L0-00000002.tsl
│   │   │       │   ├── [ 608]  L1-00000001.tsi
│   │   │       │   └── [ 442]  MANIFEST
│   │   │       ├── [4.0K]  4
│   │   │       │   ├── [   0]  L0-00000002.tsl
│   │   │       │   ├── [ 673]  L1-00000001.tsi
│   │   │       │   └── [ 442]  MANIFEST
│   │   │       ├── [4.0K]  5
│   │   │       │   ├── [   0]  L0-00000001.tsl
│   │   │       │   └── [ 419]  MANIFEST
│   │   │       ├── [4.0K]  6
│   │   │       │   ├── [   0]  L0-00000001.tsl
│   │   │       │   └── [ 419]  MANIFEST
│   │   │       └── [4.0K]  7
│   │   │           ├── [   0]  L0-00000001.tsl
│   │   │           └── [ 419]  MANIFEST
│   │   └── [4.0K]  3
│   │       ├── [1.3K]  fields.idx
│   │       └── [4.0K]  index
│   │           ├── [4.0K]  0
│   │           │   ├── [   0]  L0-00000002.tsl
│   │           │   ├── [1.9K]  L1-00000001.tsi
│   │           │   └── [ 442]  MANIFEST
│   │           ├── [4.0K]  1
│   │           │   ├── [   0]  L0-00000002.tsl
│   │           │   ├── [4.7K]  L1-00000001.tsi
│   │           │   └── [ 442]  MANIFEST
│   │           ├── [4.0K]  2
│   │           │   ├── [   0]  L0-00000002.tsl
│   │           │   ├── [3.9K]  L1-00000001.tsi
│   │           │   └── [ 442]  MANIFEST
│   │           ├── [4.0K]  3
│   │           │   ├── [   0]  L0-00000002.tsl
│   │           │   ├── [2.7K]  L1-00000001.tsi
│   │           │   └── [ 442]  MANIFEST
│   │           ├── [4.0K]  4
│   │           │   ├── [   0]  L0-00000002.tsl
│   │           │   ├── [3.9K]  L1-00000001.tsi
│   │           │   └── [ 442]  MANIFEST
│   │           ├── [4.0K]  5
│   │           │   ├── [   0]  L0-00000002.tsl
│   │           │   ├── [3.5K]  L1-00000001.tsi
│   │           │   └── [ 442]  MANIFEST
│   │           ├── [4.0K]  6
│   │           │   ├── [   0]  L0-00000002.tsl
│   │           │   ├── [4.3K]  L1-00000001.tsi
│   │           │   └── [ 442]  MANIFEST
│   │           └── [4.0K]  7
│   │               ├── [   0]  L0-00000002.tsl
│   │               ├── [2.3K]  L1-00000001.tsi
│   │               └── [ 442]  MANIFEST
│   └── [4.0K]  _series
│       ├── [4.0K]  00
│       │   └── [4.0M]  0000
│       ├── [4.0K]  01
│       │   └── [4.0M]  0000
│       ├── [4.0K]  02
│       │   └── [4.0M]  0000
│       ├── [4.0K]  03
│       │   └── [4.0M]  0000
│       ├── [4.0K]  04
│       │   └── [4.0M]  0000
│       ├── [4.0K]  05
│       │   └── [4.0M]  0000
│       ├── [4.0K]  06
│       │   └── [4.0M]  0000
│       └── [4.0K]  07
│           └── [4.0M]  0000
```



### 3.2.wal

wal目录下有3级：

- 第一级为bucket-id；
- 第二级为默认；
- 第三级是wal顺序号自动递增。

```shell
└── wal
    ├── 1b50453093dc429b 
    │   └── autogen
    │       └── 2
    │           └── _00003.wal
```



### 3.3.replicationq

见流计算。