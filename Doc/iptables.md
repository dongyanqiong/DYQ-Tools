## 常用操作
```bash
## 查看规则
iptables -nvL --line-number

## 添加规则
iptables -A INPUT -s 12.0.1.6  -p tcp --dport 6041 -j ACCEPT -m comment --comment "allow ZhongShi to Restful"

## 修改规则
iptables -R INPUT 11 -s 12.0.1.6  -p tcp --dport 6041 -j REJECT -m comment --comment "deny ZhongShi to Restful"

## 保存规则
iptables-save > /etc/sysconfig/iptables

## 删除规则
iptables -D INPUT 1

## 清空规则
iptables -F 
```

## 参数说明
```bash
iptables [-t table] COMMAND [chain] CRETIRIA -j ACTION
```

|选项|功能|
|---|----|
|-A|添加规则|
|-D|删除规则|
|-I|插入规则|
|-F|清空规则|
|-L|列出规则|
|-R|替换规则|
|-Z|清空统计数据|


|参数|功能|
|-----|------|
|[!]-p|匹配协议，!表示取反|
|[!]-s|匹配源地址|
|[!]-d|匹配目标地址|
|[!]-i|匹配入站网卡接口|
|[!]-o|匹配出站网卡接口|
|[!]--sport|匹配源端口|
|[!]--dport|匹配目标端口|
|[!]--src-range|匹配源地址范围|
|[!]--dst-range|匹配目标地址范围|
|[!]--limit|四配数据表速率|
|[!]--mac-source|匹配源MAC地址|
|[!]--sports|匹配源端口|
|[!]--dports|匹配目标端口|
|[!]--stste|匹配状态（INVALID、ESTABLISHED、NEW、RELATED)|
|[!]--string|匹配应用层字串|

|选项|功能|
|---|----|
|ACCEPT|允许|
|DROP|丢弃|
|REJECT|拒绝|
|LOG|记录到syslog日志|
|DNAT|目标地址转换|
|SNAT|源地址转换|
|MASQUERADE|地址欺骗|
|REDIRECT|重定向|



## 端口转发

将本地7777端口转发到22端口。可用于22端口不允许访问的场景。
```bash
iptables -t nat -A PREROUTING -p tcp --dport 6060 -j REDIRECT --to-port 22
```
清理NAT规则
```bash
iptables -F -t nat
```

查看NAT规则
```bash
iptables -t nat -nvL
```

## TDengine常用规则

```bash
iptables -A INPUT -s 10.59.55.0/28 -j ACCEPT --comment "allow all dnodes"
iptables -A INPUT -s 10.78.2.111 -p tcp --dport 6041 -j ACCEPT --comment "allow nginx"
iptables -A INPUT -s 10.78.2.111 -p tcp --dport 6060 -j ACCEPT --comment "allow nginx"
iptables -A INPUT -s 10.78.2.112 -p tcp --dport 6041 -j ACCEPT --comment "allow monitor"
iptables -A INPUT -p tcp --dport 22 -j ACCEPT --comment "allow SSH"
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -j REJECT 
```