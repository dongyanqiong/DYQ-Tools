# Arbitrator 部署

Arbitrator 模拟一个 vnode 或 mnode 在工作，但只简单的负责网络连接，不处理任何数据插入或访问，主要用于防止 2 副本数据库出现脑裂，保证集群的高可用。详细介绍见[官方文档](https://www.taosdata.com/docs/cn/v2.0/cluster#arbitrator)。

> 当副本数为偶数时，系统将自动连接配置的 Arbitrator。如果副本数为奇数，即使配置了 Arbitrator，系统也不会去建立连接。

## 0.注意

Arbitrator 的执行程序名为 tarbitrator，占用资源极少，可在任一 Linux 上运行，

**建议部署在集群外服务器上**。

**如果：**没有额外的资源部署Arbitrator，也可以部署在集群上任意一个节点。

**但是，建议按如下建议部署：**

假设原集群环境如下：

```shell
192.168.101.11 node1
192.168.101.12 node2
192.168.101.13 node3
```

要在节点 node1 上部署 Arbitrator，则需要为 Arbitrator 单独创建 FQDN，如下：

```shell
192.168.101.11 node1
192.168.101.12 node2
192.168.101.13 node3
192.168.101.11 arb
```

taos.cfg 配置如下

```shell
arbitrator                arb:6042
```

当部署 Arbitrator 节点意外宕机时，可以通过修改其他节点的地址解析，来启用额外的 Arbitrator，以保证集群的高可用。

如：节点 node1 意外宕机，则可以在 node2 上启动 Arbitrator 进程，同时修改 node2，node3 节点地址解析如下：

```shell
192.168.101.11 node1
192.168.101.12 node2
192.168.101.13 node3
192.168.101.12 arb
```

**必须保证所有节点连接的是同一个 Arbitrator！！！**

**以上方案只是一个折中的方法，需要运维人员的手动干预，建议将 Arbitrator 单独部署。**

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

在每个节点 taos.cfg 中添加

```shell
arbitrator                Arbitrator_FQDN:6042
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

