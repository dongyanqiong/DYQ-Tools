# TDengine 安装--普通用户

在实际情况下，可能需要只用普通用户安装和使用 TDengine，安装部署步骤如下：

## 0.环境规划

运行TDengine 用户：tdengine

```shell
useradd tdengine
passwd  tdengine

chown -R tdengine:tdengine /data
```

软件安装位置：/data/taos

| 变量    | 值         |
| ------- | ---------- |
| dataDir | /data/data |
| logDir  | /data/log  |
| tempDir | /data/tmp  |

```shell
mkdir -p /data/{taos,data,log,tmp}
```

安装依赖包

```shell
##CentOS
yum install -y snappy
yum install -y jansson
```

```shell
##Ubuntu
apt install -y libsnappy-dev
apt install -y libjansson-dev
```



## 1.TDengine 安装

解压缩安装包，并复制到相应目录

```shell
tar xvzf TDengine-enterprise-server-2.4.0.14-Linux-x64.tar.gz
cd TDengine-enterprise-server-2.4.0.14
tar xvzf taos.tar.gz -C /data/taos/
cp -r driver /data/taos/
cp -r examples /data/taos/
```

## 2.设置环境变量

```shell
vi ~/.bash_profile
###ubuntu ~/.profile 

TD_HOME=/data/taos
PATH=$PATH:$TD_HOME/bin:$TD_HOME/jemalloc/bin
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TD_HOME/driver:$TD_HOME/jemalloc/lib
C_INCLUDE_PATH=$TD_HOME/inc:$TD_HOME/jemalloc/include

export TD_HOME
export C_INCLUDE_PATH
export LD_LIBRARY_PATH
export PATH

```

```shell
source ~/.bash_profile
```

## 3.创建lib文件

```shell
ln -s /data/taos/driver/libtaos.so.2.4.0.14 /data/taos/driver/libtaos.so.1
```

## 4.修改配置文件

添加目录设置  /data/taos/cfg/taos.cfg

```shell
dataDir /data/data
logDir /data/log
tempDir /data/tmp
```

## 5.启动TDengine

```shell
nohup /data/taos/bin/taosd -c /data/taos/cfg 1>/dev/null 2>/dev/null &
```

## 6.taosAdapter

修改配置文件

```shell
vi /data/taos/cfg/taosadapter.toml

[log]
path = "/data/log"
```

启动 taosAdapter

```shell
 nohup /data/taos/bin/taosadapter -c /data/taos/cfg/taosadapter.toml > /dev/null 2> /dev/null &
```

## 7.配置资源限制

由于使用的是普通用户，因此需要配置资源使用，此步骤需要管理员权限。

```shell
/etc/security/limits.conf

* soft nproc  65535
* soft nofile 65535
* soft stack  65535
* hard nproc  65535
* hard nofile 65535
* hard stack  65535
```

