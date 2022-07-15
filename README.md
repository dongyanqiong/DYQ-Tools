# DYQ-Tools
实用小工具。

## ansible
Ansible自动部署

## tdit
巡检脚本

## tdmanager
python编写的集群管理工具。

## preCheck.sh
安装环境预检查 
使用方法：
```shell
./preCheck.sh
```

## econvert.sh
错误代码转换
使用方法：
```shell
./econvert.sh -217363882
```

## ipconvert.sh
IP地址转换
使用方法：
```shell
./ipconvert.sh  0x2a90123
```

## vcalc.sh
统计vnode在不同节点的分布.
使用方法：
```shell
./valc.sh
```

## wal.pl
用来查看mnode的wal日志
使用方法：
```shell
perl wal.pl < {dataDir}/dnode/mnode/wal/wal0
```

## wal_change
用来将2.2的wal文件升到到2.4版本
使用方法：
```shell
./wal_change wal0
```

## cprint.sh
用来读取current文件
使用方法：
```shell
./cprint.sh current
```

## hcache
查看cache占用
使用方法：
```shell
./hcache --top 10
./hcache --pid `pidof taosd`
```

## mulbackup.sh
多级存储备份current 
使用方法：
```shell
./mulbackup.sh
```
建议放到计划任务中，定期执行。

