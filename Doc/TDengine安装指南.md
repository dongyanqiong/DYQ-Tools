# TDengine安装指南

## 1.软硬件选择

TDengine支持多种硬件平台和操作系统。

### 1.1.硬件支持

目前TDengine可以运行多个平台上：【涛思建议采用Intel x64 平台，其他平台请联系涛思商务团队】

因内容实时更新，以官方文档为准https://www.taosdata.com/cn/documentation/

### 1.2.操作系统选择

建议选择能提供企业级服务支持的操作系统，涛思建议采用以下操作系统：

| OS     | 版本   |
| ------ | ------ |
| RHEL   | 7.9    |
| CentOS | 7.9    |
| Ubuntu | 18、20 |

### 1.3.操作系统安装参考

a.虽然TDengine运行需要的依赖包非常少【最小化安装即可满足】，但建议安装开发工具包以便于故障处理。

b.为防止程序被OOM，建议配置SWAP，SWAP大小请参考相应官方文档。以下为建议配置：

| 物理内存 | 建议swap       |
| -------- | -------------- |
| <=2GB    | 两倍物理孽畜   |
| 2GB-8GB  | 与物理内存一致 |
| 8GB-64GB | >=4GB          |
| >64GB    | >=4GB          |

## 2.安装前准备

操作系统安装完成后需要对操作系统进行相应配置，以满足TDengine安装运行条件。

### 2.1.关闭SELinux

SELinux对权限的划分要求非常高，除非已了解相应配置，否则请关闭该功能。

查看当前SELinux状态

```shell
getenforce
```

```shell
##永久关闭【需重启生效】
vi /etc/selinux/config 
SELINUX=disabled

##如无法重启，可使用以下命令临时关闭SELinux
setenforce 0
```

### 2.2.关闭防火墙

如对网络安全无特别要求，请关闭防火墙。不同操作系统采用的防火墙软件不同，请按实际情况处理。

```shell
##CentOS7/8
systemctl stop firewalld
systemctl disable firewalld

##Ubuntu 20
sudo ufw stop
sudo ufw disable
```
如果需要启用防火墙，请保证TDengine通信畅通。下表为TDengine使用的端口与协议：


![image-20211106151118376](TDengine安装指南.assets/image-20211106151118376.png)

### 2.3.配置域名解析

TDengine支持使用DNS和本地进行域名解析，在配置集群前，必须保证各个节点均能解析所有节点域名。

```shell
##示例
/etc/hosts
172.16.216.4 test3
172.16.216.3 test2
172.16.216.2 test1
```

如果已配置了DNS解析，可以不配置/etc/hosts。

### 2.4.配置coredump

TDengine安装时会在启动文件中启动core设置，为方便记录客户端core文件和指定文件位置请进行如下设置：

```shell
echo "ulimit -c unlimited" >>/etc/profile
echo "kernel.core_pattern=<path>/core-%e-%p" >>/etc/sysctl.conf
sysctl -p
```

coredump位置要保证有足够空间，防止产生大量coredump后影响操作系统运行，建议放置在TDengine数据目录下。

TDengine安装完成后，提供 set_core 命令，可以帮助设置coredump。

### 2.5.配置时间同步

TDengine集群间节点要求时间同步，如时间相差较大会造成集群状态异常以及数据同步异常，建议配置时间同步服务。

不同操作系统NTP软件不同，请已实际为准，示例如下：

```shell
##CentOS
yum install -y ntp
systemctl start ntpd
##Ubuntu
apt install -y ntp
systemctl start ntpd
```

<!--TDengine要求节点间及客户端与服务端时间保持同步，对时间同步工具不要求。-->

### 2.6.安装维护软件

为方便排查问题，建议安装以下辅助软件：

tmux --终端会话管理软件，在远程管理时可以放置因为网络终端造成命令运行失败。

gdb --调试工具，用于调试程序，排查问题必备。

fio --磁盘IO测试工具

iperf3 --网络性能测试工具，用于测试网络带宽和健康度。

sysstat --监控工具，可以监控操作系统资源使用情况。

net-tools --网络工具，用于配置和监控网络。

iotop --IO分析工具，可以快速定位高负载进程。

iptraf-ng --网络流量监控工具

nethogs --网络IO分析工具

bpftrace --跟踪调试工具

```shell
##示例 CentOS
yum install -y tmux gdb fio iperf3 sysstat net-tools iotop iptraf-ng nethogs
yum -y install kernel-headers
wget https://repos.baslab.org/rhel/7/bpftools/bpftools.repo -O /etc/yum.repos.d/bpftools.repo  --no-check-certificate
yum -y install bpftrace
```

### 2.7.设置时区

TDengine默认会采用系统时区，请正确设置系统时区。

```shell
###示例 将时区设置为东八区
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

### 2.8.设置系统资源限制

为保证TDengine稳定运行，在运行TDengine前，需要对其资源使用限制进行修改。具体数值请以实际应用场景为准。

优先级如下：sysctl.conf>taosd.service>system.conf>limits.conf

```shell
/etc/security/limits.conf
*	soft nproc 	65535
*	soft nofile	65535
*	soft stack 	65535
*	hard nproc 	65535
*	hard nofile	65535
*	hard stack 	65535

/etc/security/limits.d/90-nproc.conf
* - proc 65535

/etc/sysctl.conf
fs.nr_open = 1048576

/etc/systemd/system.conf
DefaultLimitNOFILE=1048576
DefaultLimitNPROC=1048576
```

### 2.9.内存优化【可选配置】

调整SWAP调用的优先级和系统保留内存。

```shell
/etc/sysctl.conf
##swap优先级，数值越大优先级越高
vm.swappiness=10
##为操作系统保留的内存
vm.min_free_kbytes=102400
##脏页比例
vm.dirty_background_ratio = 5
vm.dirty_ratio = 40

sysctl -p
```

### 2.10.关闭NUMA【可选配置】

查看是否支持NUMA

```shell
dmesg|grep -i NUMA
```

关闭NUMA属于高危操作，请在主机工程师指导下完成。

### 2.11.调整磁盘调度模式【可选配置】

请检查磁盘的调度模式，建议设置为deadline[nvme接口设置为mq-deadline]。

查看方法

```shell
cat /sys/block/DEVICE_NAME/queue/scheduler
```

调整调度模式对磁盘性能影响较大，请在主机工程师指导下完成。

## 3.环境评估

在安装TDengine前，可提前进行测试，对运行环境的性能状态进行初步评估。在CPU、内存、磁盘、网络等因素中，磁盘和网络极大影响了TDengine的性能和稳定性。磁盘的读写性能决定了TDengine性能的上限。在以往的测试中，网络丢包率达到2%时，写入性能衰减50%，网络丢包率达到5%时，集群基本不可用。

### 3.1.磁盘性能测试

测试前需要关闭不必要的应用系统，选择要部署TDengine的磁盘目录，如/taos，指定测试文件名称，如test。

```shell
fio -ioengine=sync -direct=0 -thread -rw=randwrite -filename=/taos/test -runtime=600 -numjobs=1 -filesize=20g -bsrange=400k-500k -loop 1000 -name="Test"
```

####  fio参数说明

```shell
-ioengine=sync fio存储引擎，sync为系统默认落盘模式。TDengine直接调用write()和fsync()函数进行落盘，不会使用其他引擎。
-direct=0 是否直接写入磁盘。1 直接写入，0 不直接写，使用OS_buffer。TDengine使用的落盘函数均使用OS buffer。
-rw=randwrite 使用随机写模式。TDengine落盘是会写wal日志、data、last等多个文件，因此采用随机写更符合TDengine的实际写入。
-numjobs=1 并行进程数。在不使用异步io时，多进程不会对写入速度产生影响。
-filesize=20g 测试文件大小，如果设置了runtime，则在到期前反复写入。该值应接近可用存储空间大小。
-bsrange=400k-500k 单次IO块大小，IO块大小随机在400k-500k内选择。
-runtime=600 测试时间单位秒（s）。测试时间越长越接近于真实环境，要求不低于10分钟。
-loop 1000 单次写入完成后循环1000次，受runtime控制。
-name="Test" 测试名称
```

### 3.2.网络性能测试

#### 测试步骤

A.在服务端启动iperf 

```shell
iperf3 -s
```

B.测试网络带宽

```shell
iperf3 -c SERVER 
```

C.测试UDP丢包率

```shell
iperf3 -c SERVER -u -b BandWith -t 1000
```

​	<!--BandWith为上一步测试得到的带宽-->

TDengine集群间很多通信采用UDP通信，如果UDP丢包率超过5%，需要关闭UDP强制启用TCP。在配置文件taos.cfg 中设置【rpcForceTcp 1】

D.测试TCP丢包率

```shell
iperf3 -c SERVER -w 87380 -t 1000
或
ping SERVER -c 1000 -i 0.1
```

E.报错

```shell
error - unable to connect stream :connection refused
```

造成问题的原因基本基于以下几点：

a.iperf权限不足

b.防火墙屏蔽

c.未知问题--可重启尝试

#### iperf参数说明

```shell
-s 启动服务端
-c 启动客户端
-f 指定显示单位K,M,G
-t 指定时间
-u 使用UDP
-b 指定带宽
-w TCP 窗口大小/Socket Buffer
```

TCP窗口的大小直接决定了网络传输速度，在Linux中TCP窗口受以下参数影响：

```shell
net.ipv4.tcp_timestamps
net.core.rmem_max
net.ipv4.tcp_rmem
net.ipv4.tcp_adv_win_scale
net.ipv4.tcp_window_scaling
net.ipv4.tcp_workaround_signed_windows
```

net.ipv4.tcp_rmem参数中分别指定最小值、默认值、最大值。如下：

net.ipv4.tcp_rmem = 4096        87380   6291456

我们采用net.ipv4.tcp_rmem中的默认值进行测试。

## 4.安装TDengine

以下为TDengine集群安装简易步骤，具体请参考官方文档。

### 4.1.单节点安装

```shell
##解压安装包
tar xvzf TDengine-enterprise-server-<version>-Linux-x64.tar.gz
##运行安装文件
cd TDengine-enterprise-server-<version>
./install.sh
##安装过程不需要输入参数，按回车即可。
```

### 4.2.修改配置文件

```shell
###集群第一个节点，必须能解析到
firstEp									test1:6030
###集群第二个节点，必须能解析到，该参数为客户端参数
#secondEp								test2:6030
###本地节点的fqdn，必须能解析到
fqdn										test1
###arbitrator解决，必须能解析到
#arbitrator             arbi:6042
###本地服务启示端口
serverport      				6030
###设置数据文件目录，目录必须存在
dataDir        					/taos/data
###设置日志文件目录，目录必须存在
logDir         					/taos/log
###关闭动态负载均衡，高负载环境建议关闭
balance 								0
###管理节点数量，默认1，上限3且小于等于节点数
#numOfMnodes     				3
###每个Vnode最小表数量
minTablesPerVnode       1000		
###建表时Vnode间步长
tableIncStepPerVnode    1000		
###每个数据库最大Vnode数量
maxVgroupsPerDb         32      
###最小落盘记录数
minRows		   						100
###每个Vnode的内存块个数
blocks                  6
###超级表排序结果集最大记录数，上限100万
maxNumOfOrderedRes      100000	
###返回不重复值结果集最大记录数，上限1亿
maxNumOfDistinctRes     10000000     
###是否须在 RESTful url 中指定数据库名
httpDbNameMandatory     1            
###通配符前字符串最大长度，上限16384
maxWildCardsLength      100 
###打开cachelast，缓冲最后一条记录提高查询速度
cachelast       				1
###设置最大sql长度
maxSQLLength    				1048576
###设置时区和字符集
timezone        				Asia/Shanghai
locale  								en_US.UTF-8
charset 								UTF-8
###单个节点最大连接数，最大 50000000
maxShellConns   				50000
###单个数据库节点最大连接数，最大100000
maxConnections  				50000
###取消日志保存天数限制
logKeepDays     				-1
###打开监控模块
monitor 								1
###打开删除备份功能
vnodeBak        				1
###允许部分列更新数据
update 									2
###以下为默认建议配置
keepColumnName  				1
numOfThreadsPerCore     2.0
ratioOfQueryCores       2.0
numOfCommitThreads      4.0
```

### 4.3.启动TDengine

```shell
systemctl start taosd
##设置开启自启动
systemctl enable taosd
##取消开启自启动
systemctl disable taosd
```

```shell
##启动arbitrator
systemctl start tarbitratord
##设置开机自启动
systemctl enable tarbitratord
```

### 4.3.配置集群

**配置集群前必须保证每个节点的firstEP和fqdn已正确配置，且服务已启动。**

```shell
taos

###查看节点信息
taos> show dnodes;
###查看管理节点信息
taos> show mnodes;

###给集群添加一个节点
taos> create dnode "test2:6030";
```

