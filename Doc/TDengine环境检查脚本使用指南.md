# TDengine环境检查脚本使用指南

目前仅支持CentoOS/RHEL/Ubuntu 环境

## 1.使用方法

以root权限用户执行执行，该脚本基于BASH。

```shell
bash preCheck.sh
```

## 2.检查项说明

检查脚本共检查5大项内存

### 2.1.TDengine依赖包检查

通过检查所需lib文件是否存在来进行判断。软件包及lib文件如下：

软件包：glibc

libdl.so libm.so librt.so libpthread.so libc.so 

软件包：libstdc++

libstdc++.so 

软件包：libgcc

libgcc_s.so

### 2.2.操作系统配置检查

#### 2.2.1.SELinux

通过检查配置文件和当前状态判断

#### 2.2.2.域名解析

检查当前主机名是否在/etc/hosts中配置

#### 2.2.3.Core设置

检查core file size 是否为0

#### 2.2.4.防火墙

检查防火墙是否开启

#### 2.2.5.NTP

检查ntp服务是否启动

### 2.3.辅助软件检查

检查以下工具是否存在：

curl gdb tmux fio iperf3 iostat netstat

### 2.4.磁盘检查

检查个挂载点可用空间是否大于10GB

### 2.5.其他配置

输出操作系统资源使用限制。