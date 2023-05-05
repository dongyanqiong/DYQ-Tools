# Arbitrator 部署

Arbitrator 模拟一个 vnode 或 mnode 在工作，但只简单的负责网络连接，不处理任何数据插入或访问，主要用于防止 2 副本数据库出现脑裂，保证集群的高可用。详细介绍见[官方文档](https://www.taosdata.com/docs/cn/v2.0/cluster#arbitrator)。

> 当副本数为偶数时，系统将自动连接配置的 Arbitrator。如果副本数为奇数，即使配置了 Arbitrator，系统也不会去建立连接。

## 0.注意

Arbitrator 的执行程序名为 tarbitrator，占用资源极少，可在任一 Linux 上运行，

**建议部署在集群数据节点以外的服务器上**。

**如果：**没有额外单独的资源部署Arbitrator，可以部署在集群节点以外的任意一个节点上，与其他应用/服务共享节点资源，但需要保证该节点与集群节点在同一网络下。

**但是，建议按如下建议部署：**

假设原集群环境如下：

```shell
192.168.101.11 node1
192.168.101.12 node2
192.168.101.13 node3
```

要在节点 othernode 上部署 Arbitrator，则需要为 Arbitrator 单独创建 FQDN，如下：

```shell
192.168.101.11 node1
192.168.101.12 node2
192.168.101.13 node3
192.168.101.14 othernode
```

taos.cfg 配置如下

```shell
arbitrator                othernode:6042
```

**必须保证所有节点连接的是同一个 Arbitrator！！！**

## 1.安装

安装 Server 服务端时 Arbitrator 已经默认安装了。

如果要单独部署 Arbitrator，可以使用独立安装包  

TDengine-enterprise-arbitrator-2.4.0.12-Linux-x64.tar.gz

安装方法如下：

```shell
##解压缩文件
tar xvzf TDengine-enterprise-arbitrator-2.4.0.12-Linux-x64.tar.gz
##进入目录
cd TDengine-enterprise-arbitrator-2.4.0.12
##运行安装脚本
./install_arbi.sh
```

## 2.配置

Arbitrator 自身只是一个监听进程不需要配置。Arbitrator 安装完成后，需要在 Server 端添加 Arbitrator，让每个节点可以连接到 Arbitrator。

在集群每个节点 taos.cfg 中添加

```shell
arbitrator                <Arbitrator_FQDN>:6042
```

**此配置需要在每个节点上配置，并重启集群后才能生效。**

## 3.启动和停止

```shell
##启动
systemctl start tarbitratord
##停止
systemctl stop tarbitratord
##设置开机自启
systemctl enable tarbitratord
```

