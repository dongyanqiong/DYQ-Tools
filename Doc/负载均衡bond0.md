# 负载均衡bond0

使用负载均衡模式，需要交换机网口配置为Eth-Trunk

## 1.备份网卡配置

```shell
cd /etc/sysconfig/network-scripts
mkdir bak
mv ifcfg-* bak/
```

## 2.创建bond0

负载均衡模式

```shell
nmcli connection add type bond con-name bond0 ifname bond0 mode balance-rr
```

## 3.加入组成员

```shell
nmcli connection add type bond-slave con-name em1 ifname em1 master bond0
nmcli connection add type bond-slave con-name em2 ifname em2 master bond0
nmcli connection add type bond-slave con-name em3 ifname em4 master bond0
nmcli connection add type bond-slave con-name em4 ifname em4 master bond0
```

## 4.配置IP

```shell
vi /etc/sysconfig/network-scripts/ifcfg-bond0
##添加
BOOTPROTO="none"
IPADDR="192.168.0.236"
PREFIX="23"
GATEWAY="192.168.1.1"
DNS1="192.168.1.252"
```

## 5.重启网络

```shell
systemctl restart network
```

## 6.检查状态

```shell
 nmcli con show
```

