# TDengine部署前环境测试

要实现TDengine的高速写入，对网络和磁盘的性能有较高要求。磁盘的写入速度与TDengine的写入速度正相关。TDengine要求网络丢包率不能超过5%，延时小于5ms。

## 1.测试软件安装

环境测试需要用到两个软件：

Fio 磁盘读写性能测试

Iperf3 网络传输性能测试

CentOS/RHEL

```shell
yum -y install iperf3 fio
```

Ubuntu

```shell
apt-get install iperf3
apt-get install fio
```

## 2.磁盘性能测试

测试前需要关闭不必要的应用系统，选择要部署TDengine的磁盘目录，如/taosdata，指定测试文件名称，如test。

```shell
fio -ioengine=sync -direct=0 -thread -rw=randwrite -filename=/taos/test -runtime=600 -numjobs=1 -filesize=20g -bsrange=480k-500k -loop 1000 -name="Test"
```

####  fio参数说明

```shell
-ioengine=sync fio存储引擎，sync为系统默认落盘模式。TDengine直接调用write()和fsync()函数进行落盘，不会使用其他引擎。
-direct=0 是否直接写入磁盘。1 直接写入，0 不直接写，使用OS_buffer。TDengine使用的落盘函数均使用OS buffer。
-rw=randwrite 使用随机写模式。TDengine落盘是会写wal日志、data、last等多个文件，因此采用随机写更符合TDengine的实际写入。
-numjobs=1 并行进程数。在不使用异步io时，多进程不会对写入速度产生影响。
-filesize=20g 测试文件大小，如果设置了runtime，则在到期前反复写入。该值应接近可用存储空间大小。
-bsrange=480k-500k 单次IO块大小，IO块大小随机在480k-500k内选择。块大小选择见下表。
-runtime=600 测试时间单位秒（s）。测试时间越长越接近于真实环境，要求不低于10分钟。
-loop 1000 单次写入完成后循环1000次，受runtime控制。
-name="Test" 测试名称
```

## 3.网络性能测试

在数据库所在服务器启动iperf服务端 `iperf3 -s`

​	在客户端进行测试

```shell
iperf3 -c SERVER  -f M -w 87380
```

​	<!--SERVER为数据库所在服务端地址-->

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

#### 测试步骤

A.在服务端启动iperf 

```shell
iperf3 -s
```

B.测试网络带宽

```shell
iperf3 -c SERVER 
```

C.测试UDP

```shell
iperf3 -c SERVER -u -b BandWith -t 1000
```

​	<!--BandWith为上一步测试得到的带宽-->

D.测试TCP

```shell
iperf3 -c SERVER -w 87380 -t 1000
```

E.报错

```shell
error - unable to connect stream :connection refused
```

造成问题的原因基本基于以下几点：

a.iperf权限不足

b.防火墙屏蔽

c.未知问题--可重启尝试