# InfluxDB 参数配置

https://docs.influxdata.com/influxdb/v2.2/reference/config-options/

## 1.InfluxDB 2.2 参数设置

InfluxDB 支持3中设置参数的方式：

- 设置环境变量
- 在配置文件中设置参数
- 通过命令行传递参数

### 1.1. 环境变量

例：设置InfluxDB 配置文件路径

```shell
export INFLUXD_CONFIG_PATH=/path/to/custom/config/directory
```

### 1.2. 配置文件

InfluxDB 支持的配置文件格式

- YAML  (config.yaml)
- TOML  (config.toml)
- JSON  (config.json)

#### YAML

```shell
parameter: value
```

#### TOML

```shell
parameter = value
```

#### JSON

```shell
{
"parameter":value
}
```

### 1.3. 命令行

```shell
influxd ----engine-path=/etc/influxdb
```



## 2.InfluxDB 2.2 重要参数

### 2.1.engine-path

数据目录，默认值：~/.influxdbv2/engine

| 命令行        | 环境变量            | 值   |
| ------------- | ------------------- | ---- |
| --engine-path | INFLUXD_ENGINE_PATH | 路径 |

### 2.2.flux-log-enabled

开启详细日志记录，默认值：false

| 命令行             | 环境变量                 | 值          |
| ------------------ | ------------------------ | ----------- |
| --flux-log-enabled | INFLUXD_FLUX_LOG_ENABLED | ture\|false |

### 2.3.http-bind-address

http监听端口，默认值：8086

| 命令行              | 环境变量                  | 值   |
| ------------------- | ------------------------- | ---- |
| --http-bind-address | INFLUXD_HTTP_BIND_ADDRESS | 端口 |

### 2.4.http-idle-timeout

http保持连接时间，默认值：3m0s

| 命令行              | 环境变量                  | 值   |
| ------------------- | ------------------------- | ---- |
| --http-idle-timeout | INFLUXD_HTTP_IDLE_TIMEOUT | 时间 |

### 2.5.http-read-timeout

http最大读取请求时间，默认值：0 不限制。建议设置为合理值，防止产生大量连接。

| 命令行              | 环境变量                  | 值   |
| ------------------- | ------------------------- | ---- |
| --http-read-timeout | INFLUXD_HTTP_IDLE_TIMEOUT | 时间 |

### 2.6.http-write-timeout

http最大写请求时间，默认值：0 不限制。建议设置为合理值，防止产生大量连接。

| 命令行               | 环境变量                  | 值   |
| -------------------- | ------------------------- | ---- |
| --http-write-timeout | INFLUXD_HTTP_IDLE_TIMEOUT | 时间 |

### 2.7.influxql-max-select-buckets

一个查询最大groupby 的buckets 数量，默认值：0 不限制。

| 命令行                        | 环境变量                            | 值   |
| ----------------------------- | ----------------------------------- | ---- |
| --influxql-max-select-buckets | INFLUXD_INFLUXQL_MAX_SELECT_BUCKETS | 数量 |

### 2.8.influxql-max-select-point

一个查询所允许的最大point，默认值：0 不限制。

| 命令行                      | 环境变量                          | 值   |
| --------------------------- | --------------------------------- | ---- |
| --influxql-max-select-point | INFLUXD_INFLUXQL_MAX_SELECT_POINT | 数量 |

### 2.9.influxql-max-select-series

一个查询所允许的最大时间线，默认值：0 不限制。

| 命令行                       | 环境变量                           | 值   |
| ---------------------------- | ---------------------------------- | ---- |
| --influxql-max-select-series | INFLUXD_INFLUXQL_MAX_SELECT_SERIES | 数量 |

### 2.10.log-level

log级别，默认值：info。

| 命令行      | 环境变量          | 值                 |
| ----------- | ----------------- | ------------------ |
| --log-level | INFLUXD_LOG_LEVEL | debug\|info\|error |

### 2.11.no-tasks

禁用任务，默认值：flase。当错误的计划任务导致 InfluxDB无法启动时，可以通过此参数禁止计划任务。

| 命令行     | 环境变量         | 值          |
| ---------- | ---------------- | ----------- |
| --no-tasks | INFLUXD_NO_TASKS | false\|ture |

### 2.12.query-concurrency

并发查询数量，默认值：10

| 命令行              | 环境变量                  | 值   |
| ------------------- | ------------------------- | ---- |
| --query-concurrency | INFLUXD_QUERY_CONCURRENCY | 数量 |

### 2.13.query-initial-memory-bytes

单个查询初始使用的内存大小，默认值：query-memory-bytes

| 命令行                       | 环境变量                           | 值   |
| ---------------------------- | ---------------------------------- | ---- |
| --query-initial-memory-bytes | INFLUXD_QUERY_INITIAL_MEMORY_BYTES | 数量 |

### 2.14.query-max-memory-bytes

查询使用的内存最大值，默认值：query-concurrency × query-memory-bytes

| 命令行                   | 环境变量                       | 值   |
| ------------------------ | ------------------------------ | ---- |
| --query-max-memory-bytes | INFLUXD_QUERY_MAX_MEMORY_BYTES | 数量 |

### 2.15.query-memory-bytes

单个查询使用的内存最大值，默认值：unlimited

| 命令行               | 环境变量                   | 值   |
| -------------------- | -------------------------- | ---- |
| --query-memory-bytes | INFLUXD_QUERY_MEMORY_BYTES | 数量 |

### 2.16.query-queue-size

查询队列长度，默认值：10。

| 命令行             | 环境变量                 | 值   |
| ------------------ | ------------------------ | ---- |
| --query-queue-size | INFLUXD_QUERY_QUEUE_SIZE | 数量 |

### 2.17.reporting-disabled

禁止向InfluxDB上报数据，默认值：false。

| 命令行               | 环境变量                   | 值          |
| -------------------- | -------------------------- | ----------- |
| --reporting-disabled | INFLUXD_REPORTING_DISABLED | true\|false |

### 2.18.secret-store

使用密码或token进行安全存储，默认值：bolt。

| 命令行         | 环境变量             | 值          |
| -------------- | -------------------- | ----------- |
| --secret-store | INFLUXD_SECRET_STORE | bolt\|vault |

### 2.19.session-length

会话保持时间TTL，单位分钟，默认值：60。

| 命令行           | 环境变量               | 值   |
| ---------------- | ---------------------- | ---- |
| --session-length | INFLUXD_SESSION_LENGTH | 时间 |

### 2.20.storage-cache-max-memory-size

最大写入缓存，单位bytes，默认值 (1GB)：1073741824。超过该值，会拒绝写入。

| 命令行                          | 环境变量                              | 值   |
| ------------------------------- | ------------------------------------- | ---- |
| --storage-cache-max-memory-size | INFLUXD_STORAGE_CACHE_MAX_MEMORY_SIZE | 数量 |

### 2.21.storage-cache-snapshot-memory-size

最大落盘缓存，单位bytes，默认值 (25MB)：26214400。

| 命令行                               | 环境变量                                   | 值   |
| ------------------------------------ | ------------------------------------------ | ---- |
| --storage-cache-snapshot-memory-size | INFLUXD_STORAGE_CACHE_SNAPSHOT_MEMORY_SIZE | 数量 |

### 2.22.storage-cache-snapshot-write-cold-duration

最大缓存时间，超时写入TSM。单位bytes，默认值：10m0s

| 命令行                                       | 环境变量                                           | 值   |
| -------------------------------------------- | -------------------------------------------------- | ---- |
| --storage-cache-snapshot-write-cold-duration | INFLUXD_STORAGE_CACHE_SNAPSHOT_WRITE_COLD_DURATION | 数量 |

### 2.23.storage-compact-full-write-cold-duration

最大TSM缓存时间，超时落盘。单位bytes，默认值：10m0s

| 命令行                                     | 环境变量                                         | 值   |
| ------------------------------------------ | ------------------------------------------------ | ---- |
| --storage-compact-full-write-cold-duration | INFLUXD_STORAGE_COMPACT_FULL_WRITE_COLD_DURATION | 数量 |

### 2.24.storage-compact-throughput-burst

写入速率bytes/second。单位bytes，默认值(28M)：50331648

| 命令行                             | 环境变量                                 | 值   |
| ---------------------------------- | ---------------------------------------- | ---- |
| --storage-compact-throughput-burst | INFLUXD_STORAGE_COMPACT_THROUGHPUT_BURST | 数量 |

### 2.25.storage-max-index-log-file-size

最大索引落盘大小，太小会导致频繁落盘。单位bytes，默认值(1M)：1048576

| 命令行                            | 环境变量                                | 值   |
| --------------------------------- | --------------------------------------- | ---- |
| --storage-max-index-log-file-size | INFLUXD_STORAGE_MAX_INDEX_LOG_FILE_SIZE | 数量 |

### 2.26.storage-series-id-set-cache-size

索引换成大小，当标签数量较多时，建议增大该值。单位bytes，默认值：100

| 命令行                             | 环境变量                                 | 值   |
| ---------------------------------- | ---------------------------------------- | ---- |
| --storage-series-id-set-cache-size | INFLUXD_STORAGE_SERIES_ID_SET_CACHE_SIZE | 数量 |

### 2.27.storage-wal-fsync-delay

WAL写入(fsync)延时。默认值：0s

| 命令行                    | 环境变量                        | 值   |
| ------------------------- | ------------------------------- | ---- |
| --storage-wal-fsync-delay | INFLUXD_STORAGE_WAL_FSYNC_DELAY | 时间 |

### 2.28.storage-wal-max-concurrent-writes

最大并发写入线程数。默认值：0（cpu数量x2）

| 命令行                              | 环境变量                                  | 值   |
| ----------------------------------- | ----------------------------------------- | ---- |
| --storage-wal-max-concurrent-writes | INFLUXD_STORAGE_WAL_MAX_CONCURRENT_WRITES | 数量 |

### 2.29.storage-wal-max-write-delay

最大并发写入延时。默认值：0（禁用）

| 命令行                        | 环境变量                            | 值   |
| ----------------------------- | ----------------------------------- | ---- |
| --storage-wal-max-write-delay | INFLUXD_STORAGE_WAL_MAX_WRITE_DELAY | 数量 |

### 2.30.storage-write-timeout

写入超时。默认值：10s

| 命令行                  | 环境变量                      | 值   |
| ----------------------- | ----------------------------- | ---- |
| --storage-write-timeout | INFLUXD_STORAGE_WRITE_TIMEOUT | 时间 |

### 2.31.ui-disabled

禁用UI。默认值：false

| 命令行        | 环境变量            | 值          |
| ------------- | ------------------- | ----------- |
| --ui-disabled | INFLUXD_UI_DISABLED | true\|false |

