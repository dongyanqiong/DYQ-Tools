# TDengine部署环境准备



**部署TDengine需要干净的基础环境**

**如果之前安装过其他产品，强烈建议按本文重新安装操作系统，再部署TDengine**。



建议的操作系统及对应的版本：

 - RedHat企业版 7.9
 - CentOS 7.9
 - Ubuntu 20.04

## 1.环境准备

### 1.0 操作系统安装

1. 采用最小化安装

2. 安装时设置 SWAP、时区、主机名

SWAP SIZE 设置参考

| 内存大小 | swap大小                |      |
| -------- | ----------------------- | ---- |
| <2GB     | 4GB                     |      |
| 2GB-8GB  | Equal to the amount RAM |      |
| >8GB     | >4GB                    |      |

3. 磁盘初始化及文件系统
   如条件允许，建议选取两款容量相同的固态盘或SAS盘，设置为RAID1，做为系统盘。用于存放数据的磁盘，**不建议设置为RAID5**，建议作为独立的磁盘进行初始化。
   可选的挂载方案有：单独挂载、LVM、软RAID。
   数据盘文件系统建议选用ext4，格式化是建议配置 【lazy_itable_init=0,lazy_journal_init=0】，挂载时加上【data=ordered】参数。

```shell
mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 /dev/sda1
```

```shell
##/etc/fstab
/dev/sda1 /data    ext4   defaults,data=ordered        0 0
```

4. 手动设置SWAP【仅限于安装操作系统时未配置SWAP】

设置 SWAP 可以有效降低程序被 OOM 的概率，在操作系统安装时可设置SWAP分区，如果当时没有设置，或设置的过小，可以通过以下方法手动设置：

```shell
dd if=/dev/zero of=/data/swapfile bs=1M count=4096 
mkswap /data/swapfile 
swapon /data/swapfile 

vi /etc/fstab 
/data/swapfile swap     swap    defaults        0 0
```

### 1.1 安装软件包

为方便 TDengine 运维及 debug，建议安装以下辅助工具包。

```shell
###CentOS/RedHat
yum install -y screen
yum install -y tmux  
yum install -y gdb  
yum install -y fio  
yum install -y iperf3  
yum install -y sysstat  
yum install -y net-tools  
yum install -y ntp 
yum install -y tree 
yum install -y wget 
wget https://repos.baslab.org/rhel/7/bpftools/bpftools.repo -O /etc/yum.repos.d/bpftools.repo --no-check-certificate 
yum install -y bpftrace
```

```shell
###Ubuntu
apt install -y screen
apt install -y tmux  
apt install -y gdb  
apt install -y fio  
apt install -y iperf3  
apt install -y sysstat  
apt install -y net-tools  
apt install -y ntp 
apt install -y tree 
apt install -y wget 
apt install -y bpftrace
```

### 1.2 关闭 SELinux

SELinux 是 RedHat 开发的一套安全增强工具，建议关闭以防出现未知问题。

**此操作仅限CentOS/RedHat。**

```shell
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
```

### 1.3 关闭防火墙

TDengine 节点间通信采用 TCP 和 UDP 协议，并使用 6030~6040 端口，同时使用 6041 和 6060 对外提供 RESTful 和 Web 管理服务。

建议关闭防火墙，关闭防火墙命令如下：

```shell
###CentOS/RedHat
systemctl stop firewalld 
systemctl disable firewalld
```

```shell
###Ubuntu
ufw stop
ufw disable
```

### 1.4 配置资源限制

为保证 TDengine 运行时获取到足够的系统资源，需要对配置相应的资源限制。

```shell
echo "fs.nr_open = 1048576" >>/etc/sysctl.conf 
sysctl -p

echo "* soft nproc  65536" >>/etc/security/limits.conf
echo "* soft nofile 65536" >>/etc/security/limits.conf
echo "* soft stack  65536" >>/etc/security/limits.conf
echo "* hard nproc  65536" >>/etc/security/limits.conf
echo "* hard nofile 65536" >>/etc/security/limits.conf
echo "* hard stack  65536" >>/etc/security/limits.conf

```

### 1.5.配置时区

如果在配置文件 taos.cfg 中没有配置时区，TDengine 默认采用操作系统设置，建议操作系统和 TDengine 时区保持一致。

操作系统时区设置：以东八区为例

```shell
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

### 1.6 配置 NTP

TDengine 节点间时间必须保证同步，否则会造成节点间状态异常，建议配置 NTP 服务。

如无法连接互联网，建议在局域网内部部署 NTP 服务器。

```shell
systemctl start ntpd 
systemctl enable ntpd
```

### 1.7 设置 coredump 目录

TDengine 运行异常时，会生成 coredump 文件，该文件可以帮助快速定位问题。但通常 coredump 文件体积较大，建议放置在单独目录下。

```shell
echo "ulimit -c unlimited" >>/etc/profile 
echo "kernel.core_pattern=/data/taos/core/core-%e-%p" >>/etc/sysctl.conf 
sysctl -p
```

### 1.8 关闭 NUMA

NUMA 是一种新型的 CPU 使用内存的架构模型，不适用于 TDengine 应用场景，建议关闭。

**以下操作具有一定风险性，请在主机工程师指导下进行。**

在启动配置文件添加 numa=off，以关闭 NUMA。

```shell
###CentOS/RedHat
vi /etc/default/grub 
GRUB_CMDLINE_LINUX="... numa=off" 

grub2-mkconfig -o /etc/grub2.cfg
```

### 1.9 重启服务器

以上多个配置项的修改需要重启服务器才能生效。

```shell
reboot
```

## 2.环境验证

### 2.1 配置验证

服务器重启完成后，对如上修改进行验证。验证命令如下：

```shell
###检查时区
date -R 
###检查目录结构
tree /data 
###检查SELinux
getenforce   
###检查防火墙状态
systemctl status firewalld
###检查CORE设置
sysctl -a | grep -E "nr_open|core_pattern" 
ulimit -a | grep core 
###检查预安装软件包
rpm -qa| grep -E -w "tmux|gdb|fio|iper3|sysstat|net-tools|ntp|tree|bpftrace" 
###检查SWAP
free -m 
###检查NUMA
lscpu| grep 'NUMA node(s):'
```

标准输出如下：

```shell
[root@td1 ~]# date -R 
Fri, 29 Apr 2022 13:28:57 +0800
[root@td1 ~]# tree /data 
/data
└── taos
    ├── core
    ├── data
    ├── dump
    ├── log
    ├── soft
    └── tmp

7 directories, 0 files
[root@td1 ~]# getenforce 
Disabled

[root@td1 ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)

[root@td1 ~]# sysctl -a | grep -E "nr_open|core_pattern" 
fs.nr_open = 1048576
kernel.core_pattern = /root/core-%e-%p

[root@td1 ~]# ulimit -a | grep core   
core file size          (blocks, -c) unlimited

[root@td1 ~]# rpm -qa| grep -E -w "tmux|gdb|fio|iper3|sysstat|net-tools|ntp|tree|bpftrace" 
ntp-4.2.6p5-29.el7.centos.2.x86_64
bpftrace-0.13.0-2.el7.x86_64
sysstat-10.1.5-19.el7.x86_64
fio-3.7-2.el7.x86_64
gdb-7.6.1-120.el7.x86_64
tree-1.6.0-10.el7.x86_64
devtoolset-8-gcc-gdb-plugin-8.3.1-3.2.el7.x86_64
devtoolset-8-gdb-8.2-3.el7.x86_64
tmux-1.8-4.el7.x86_64
net-tools-2.0-0.25.20131004git.el7.x86_64

[root@td1 ~]# free -m 
              total        used        free      shared  buff/cache   available
Mem:          15884         422       14784           8         677       15122
Swap:          5119           0        5119
[root@td1 ~]# lscpu| grep 'NUMA node(s):'
NUMA node(s):          1
```

建议执行环境检查脚本 preCheck.sh ，输出如下：

```shell
----------------------BEGIN---------------------

 Libray Check .....................................
 libdl.so ......................................... OK 
 libm.so .......................................... OK 
 librt.so ......................................... OK 
 libpthread.so .................................... OK 
 libc.so .......................................... OK 
 libstdc++.so ..................................... OK 
 libgcc_s.so ...................................... OK 

 OS Config Check ..................................
 SELinux .......................................... OK 
 Hostname ......................................... OK 
 Core ............................................. OK 
 Firewall ......................................... OK 
 NTP .............................................. OK 

 Software Check ...................................
 curl ............................................. OK 
 gdb .............................................. OK 
 tmux ............................................. OK 
 fio .............................................. OK 
 iperf3 ........................................... OK 
 iostat ........................................... OK 
 netstat .......................................... OK 
 bpftrace ......................................... OK 

 Disk Usage Check .................................
 / ................................................ OK 

 Other Config Check ...............................

OS Configs..............

 nr_hugepages ..................................... OK 
 swappiness ....................................... OK 
 overcommit_memory ................................ OK 
 overcommit_ratio ................................. OK 
 dirty_background_ratio ........................... OK 
 dirty_ratio ...................................... OK 

TimeZone................
 timezone CST +0800


OS Limits..............
##/etc/systemd/system.conf

##sysctl
fs.nr_open = 1048576
kernel.pid_max = 32768
net.core.rmem_max = 212992
net.core.wmem_max = 212992
```

### 2.2.基础性能验证

网络健康状态检查，iperf 工具可以检查带宽和丢包率，需要在网络两端分别启动服务端和客户端。

```shell
iperf3 -s  ###启动iperf服务端
iperf3 -c  ###启动iperf客户端
```

磁盘读写性能检查

```shell
fio -ioengine=libaio -direct=1 --iodepth=32 -thread -rw=randwrite -filename=/data/test -runtime=60 -numjobs=4 -filesize=20g -bsrange=480k-500k -loop 1000 -name="Test" 
```

