
|2.x||3.x||
|----|----|-----|-----|
|days|单位：天，默认10天|duration|单位：分钟(m)、小时(h)、天(d)，more10天|
|cache|vnode内存块大小，默认16MB|buffer|vnode内存池大小，默认96MB|
|blocks|vnode内存块数量，默认6|||
|keep|数据保留天数|keep|数据保存时间，支持分钟、小时、天|
|minRows|文件块中记录的最小条数|minRows|文件块中记录的最小条数|
|maxRows|文件块中记录的最大条数|maxRows|文件块中记录的最大条数|
|wallevel|wal级别，默认1|wal_level|wal级别，默认1|
|fsync|wallevel=2时，fsync时间，默认3秒|wal_fsync_period|wal_levle=2时，fsync时间，默认3秒|
|update|是否允许更新数据，默认0|无|全支持部分列更新，相当于2.x的update=2|
|cachelast|是否缓存最新数据，默认0|cachemodel|是否缓存最新数据，默认none|
|replica|副本数量，默认1|replica|副本数量,只支持1,3|
|comp|压缩级别，默认2|comp|压缩级别，默认2|
|precision|时间精度，支持纳米，默认毫秒|precision|时间精度，支持纳米，默认毫秒|

||可动态修改参数|
|--|--|
|2.x|blocks,keep,cachelast,comp,minRows,replica|
|3.0|cachemodel, cachesize, wal_level, wal_fsync_period, keep|