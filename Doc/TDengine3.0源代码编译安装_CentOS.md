
从官方文档来看 TDengine3.0 的编译方法和 TDengine2.0 没有什么区别, 2.0 的编译见《通过源代码编译安装TDengine》。
以下为编译安装步骤。

官方文档：https://github.com/taosdata/TDengine/blob/main/README.md


## 1.下载源代码

```bash
git clone https://github.com/taosdata/TDengine.git
```

```bash
[root@c3-14 /]# git clone https://github.com/taosdata/TDengine.git
Cloning into 'TDengine'...
remote: Enumerating objects: 530742, done.
remote: Counting objects: 100% (337/337), done.
remote: Compressing objects: 100% (206/206), done.
remote: Total 530742 (delta 148), reused 308 (delta 130), pack-reused 530405
Receiving objects: 100% (530742/530742), 258.83 MiB | 237.00 KiB/s, done.
Resolving deltas: 100% (378702/378702), done.
```
切换到发行分支
因为代码一直处于开发状态，最新的代码不一定能编译成功，选择一个发行分支是比较妥当的做法。

```bash
[root@c3-14 /]# cd TDengine/
[root@c3-14 TDengine]# git branch
* main
[root@c3-14 TDengine]# git branch -a | grep release | grep 3.0
  remotes/origin/chore/sangshuduo/release-script-add-comp-for-taostools-for3.0.2.2
  remotes/origin/docs/release_ver_3.0.1.7_website
  remotes/origin/docs/xiaolei/TD-21986-release-ver3.0.2.4
  remotes/origin/docs/xiaolei/TD-21986-release-ver3.0.2.4-main
  remotes/origin/release/ver-3.0.1.5
  remotes/origin/release/ver-3.0.1.6
  remotes/origin/release/ver-3.0.1.7
  remotes/origin/release/ver-3.0.1.8
  remotes/origin/release/ver-3.0.2.2
  remotes/origin/release/ver-3.0.2.20221226
  remotes/origin/release/ver-3.0.2.3
  remotes/origin/release/ver-3.0.2.4
[root@c3-14 TDengine]# git checkout release/ver-3.0.2.4
Branch release/ver-3.0.2.4 set up to track remote branch release/ver-3.0.2.4 from origin.
Switched to a new branch 'release/ver-3.0.2.4'
[root@c3-14 TDengine]# git branch
  main
* release/ver-3.0.2.4
```

## 2.安装编译工具

```bash
sudo yum install epel-release -y
sudo yum update
sudo yum install -y gcc gcc-c++ make cmake3 git openssl-devel
sudo ln -sf /usr/bin/cmake3 /usr/bin/cmake
```
执行完 update 后建议重启，因为连内核都升级了。

安装go环境(用于编译taosAdapter)

```bash
sudo yum install -y golang

go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
```
如果没有安装go环境，编译时会报如下错误：

```bash
......
taosadapter no need cmake to config
[ 91%] Performing build step for 'taosadapter'
/bin/sh: go: command not found
make[2]: *** [tools/taosadapter/src/taosadapter-stamp/taosadapter-build] Error 127
make[1]: *** [tools/CMakeFiles/taosadapter.dir/all] Error 2
make: *** [all] Error 2

```


## 3.安装依赖包

```bash
sudo yum install -y zlib-devel zlib-static xz-devel snappy-devel jansson jansson-devel pkgconfig libatomic libatomic-static libstdc++-static openssl-devel
```




## 4.编译

```bash
mkdir debug
cd debug
cmake .. -DBUILD_HTTP=false  -DJEMALLOC_ENABLED=true
make
```

查看编译结果
```bash
[root@c3-14 debug]# ls build/bin/
asyncdemo     demo             jemalloc.sh  prepare  schemaless  stream_demo  taosadapter  tmq       tmq_sim       tsim
create_table  jemalloc-config  jeprof       runUdf   sml_test    taos         taosd        tmq_demo  tmq_taosx_ci  udfd
```

## 5.安装（非必要）
```bash
sudo make install
```

## 5.运行
如果没有执行 `make install`，要运行taosd，需要先将 libjemalloc.so 加入系统
```bash
[root@c3-14 debug]# cp build/lib/libjemalloc.so.2 /usr/local/lib/
[root@c3-14 debug]# echo "/usr/local/lib" > /etc/ld.so.conf.d/jemalloc.conf
[root@c3-14 debug]# ldconfig
```

### 5.1.配置taos
如果没有执行 `make install`，需要手动创建配置文件目录

```bash
[root@c3-14 debug]# mkdir /etc/taos
[root@c3-14 debug]# echo "fqdn   c3014" >>/etc/taos/taos.cfg
```
至少做个测试，仅配置一下FQDN即可。

### 5.2.运行服务端
```bash
[root@c3-14 debug]# cd build/bin/
[root@c3-14 bin]# ./taosd -V
community version: 3.0.2.4 compatible_version: 3.0.0.0
gitinfo: c534b3c755fad3b63e840bf3ac74e4677408ca80
buildInfo: Built at 2023-02-02 09:27:05
[root@c3-14 bin]# ./taosd 

......
02/02 09:51:34.188376 00028325 DND set local info, dnodeId:1 clusterId:5922813819038311320
02/02 09:51:34.197179 00028325 DND succeed to write dnode file:/var/lib/taos//dnode/dnode.json, dnodeVer:2
02/02 09:51:34.208412 00028325 DND succeed to write dnode file:/var/lib/taos//dnode/dnode.json, dnodeVer:2
```


### 5.3.运行客户端
```bash
[root@c3-14 bin]# ./taos
Welcome to the TDengine Command Line Interface, Client Version:3.0.2.4
Copyright (c) 2022 by TDengine, all rights reserved.

   ******************************  Tab Completion  **********************************
   *   The TDengine CLI supports tab completion for a variety of items,             *
   *   including database names, table names, function names and keywords.          *
   *   The full list of shortcut keys is as follows:                                *
   *    [ TAB ]        ......  complete the current word                            *
   *                   ......  if used on a blank line, display all valid commands  *
   *    [ Ctrl + A ]   ......  move cursor to the st[A]rt of the line               *
   *    [ Ctrl + E ]   ......  move cursor to the [E]nd of the line                 *
   *    [ Ctrl + W ]   ......  move cursor to the middle of the line                *
   *    [ Ctrl + L ]   ......  clear the entire screen                              *
   *    [ Ctrl + K ]   ......  clear the screen after the cursor                    *
   *    [ Ctrl + U ]   ......  clear the screen before the cursor                   *
   **********************************************************************************

Server is Community Edition.

taos> show dnodes;
     id      |            endpoint            | vnodes | support_vnodes |   status   |       create_time       |              note              |
=================================================================================================================================================
           1 | c3-14:6030                     |      0 |              8 | ready      | 2023-02-02 09:51:33.379 |                                |
Query OK, 1 row(s) in set (0.005992s)

```