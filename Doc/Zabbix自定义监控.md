# Zabbix 自定义监控
## Zabbix 打开自定义配置
/usr/local/etc/zabbix_agentd.conf
```shell
UnsafeUserParameters=1
```
## 添加自定义脚本
```shell
UserParameter=<key>,<command>
```

# 示例

## 监控进程状态

### 脚本 /root/check_process.sh
```shell
#!/bin/sh
pname=$1
ps -ef | grep -w $pname |grep -Ev "grep|$0" |grep -c $pname 1>/dev/null 2>/dev/null 
if [ $? -eq 0 ]
then
        echo "0"
else
        echo "1"
fi
```
脚本通过查询 `ps -ef` 的输出结果，检查进程是否存在。进程名通过参数传递。
如果进程存在，返回`0`，如果进程不存在，则返回`1`。


## Zabbix 配置
```shell
UserParameter=check_process[*],/bin/bash /root/check_process.sh $1
```
配置监控项时，Key 中添加 `check_process['taosd']` 即可实现对`taosd`进程的监控。

## 监控内存使用

### 脚本 /root/check_vm.sh
```shell
#!/bin/sh

mtotal=$(free -m|grep '^Mem:' |awk '{print $2}')
mused=$(free -m|grep '^Mem:' |awk '{print $3}')

echo "$(($mused*100/$mtotal))"
```
脚本通过 `free -m` 的输出获取内存的总大小和已使用大小，返回已使用内存的百分比。

## Zabbix 配置
```shell
UserParameter=check_vm,/bin/bash /root/check_vm.sh
```

内存输出不需要传入参数，因此 Key 中直接填写 `check_vm` 即可。

# 参考链接
https://blog.csdn.net/qq_36690579/article/details/117072731
https://kaikai136.blog.csdn.net/article/details/111309497
https://www.zabbix.com/documentation/6.2/en/manual/config/items/userparameters
https://www.zabbix.com/documentation/6.2/en/manual/config/items/userparameters/extending_agent


# 写在最后

大部分自定义监控都可以通过返回`0` 和 `1` 来实现状态判断，具体阈值可以直接写在脚本中。
例如，如果想实现内存使用率超过 `80%` 进行告警，可以将脚本修改如下：

```shell
#!/bin/sh

mtotal=$(free -m|grep '^Mem:' |awk '{print $2}')
mused=$(free -m|grep '^Mem:' |awk '{print $3}')

upert=$(($mused*100/$mtotal))

if [ $upert -gt 80 ]
then
    echo "1"
else
    echo "0"
```
则当内存使用率超过 `80%` 时，会返回`1`, 当内存使用率小于 `80%` 时返回 `0` 值。

# 触发器配置
触发器配置需要采用 Zabbix 语法 https://www.zabbix.com/documentation/6.2/en/manual/config/triggers/expression

## 示例
### 进程监控
`taosd` 进程不存在
```shell
{linux:check_process['taosd'].last()}=1
```
linux：监控模版
check_process['taosd']：监控项
last()：最新值

### 内存监控
内存使用率大于 `80%`
```shell
{linux:check_vm.last()}>80
```
linux：监控模版
check_vm：监控项
last()：最新值


