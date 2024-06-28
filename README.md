# DYQ-Tools
实用小工具。

## ansible
Ansible自动部署

## tdit
### tdit.sh
巡检脚本
### tdinstall.sh
自动部署脚本

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

## install
支持非root用户安装 TDengine 到任意目录

## dataC
数据传输工具，通过Restful方式，实现表到表的数据传输。

## compact_pr.sh
查看3.0 compact 进度。
```shell
./compact_pr.sh
```

## csvdump
CSV导入导出工具

使用方法：
```shell
./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db01 -S
./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db01 -D
./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db03 -I
```

## AdapterMonitor

taosAdapter 检查脚本，用于检查TD2.6版本taosAdapter卡住问题。

需要提前创建test用户。

使用方法：
```shell
chmod 755 adapter_check.sh
crontab -e
* * * * * /root/adapter_check.sh
```

## swapCount.sh

统计进程使用SWAP的总量。

使用方法：
```shell
sh swapCount.sh
```
## DataCompare

对比两个数据库数据量，通过对指定时间的超级表进行 `group by tbname` 查询，逐个子表对比数量。
如果数量不同，则打印子表名称。可以通过修改程序变量或参数传递的方式指定时间范围。

```shell
python3 datacompare.py 2023-01-01T00:00:00Z 2023-10-01T00:00:00Z
```

## dbsize.sh

统计所在节点所有数据的大小。脚本通过`show databases`和`show vgroups` 获取数据库和vgroups信息，遍历所有dataDir，
统计vnode的大小（包含WAL）。

```shell
sh dbsize.sh
```

## google_code.py

Google身份验证器

```shell
python google_code.py   key
```