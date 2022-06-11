# 中油瑞飞K3S Basics for TDengine Enterprise



此次部署的生产网、办公网两套k3s系统，部署的版本均为v2.2.0.2企业版。

**【以下以生产网为例，说明部署步骤及相关信息。办公网请替换相应参数】**

## 部署目录

所需要的部署文件放在26/31上的deploy文件夹

- 办公网环境目录为 `/home/sysadmin/software/deploy`
- 生产网目录为 `/home/sysadmin/deploy/`

此文档中称其为部署目录。

## 初始安装

本次部署使用`helm`工具实施。配置文件参数保存在部署目录下的 `values.yaml` 文件中。初次部署命令为：

```sh
helm install -n iot tdengine-enterprise chart/ -f values.yaml
```

其中 `-n iot` 制定部署到k3s/k8s集群的命名空间，`chart` 为当前使用的Helm Chart定义文件，`-f values.yaml` 用于指定配置文件。

## 删除

删除集群的操作如下：

```sh
helm delete tdengine-enterprise -n iot
```

## 启动和停止

`helm` 安装后自动启动2 taosd 节点 + 1 arbitrator节点TDengine集群。

如有维护需要停止集群，命令如下：

```sh
helm upgrade -n iot tdengine-enterprise chart -f values.yaml --set replicaCount=0
```

再次启动，命令如下：

```sh
helm upgrade -n iot tdengine-enterprise chart -f values.yaml
```

## 文件路径

数据文件夹：/ssd/nfsroot/ifs/kubenetes/iot-tdengine-enterprise-taosdata*

日志文件夹：/ssd/nfsroot/ifs/kubenetes/iot-tdengine-enterprise-taoslog*

## 应用从k3s外部访问TDengine

运行 `bin/k2c` 将生成 `taos.cfg` 并在标准输出打印 hosts 映射信息。

外部应用使用taosc访问时，需要将 `taos.cfg` 配置文件放在 `/etc/taos/` 目录下【Windows: C:\TDengine\cfg】，并在 `/etc/hosts` 添加映射信息。

`taos.cfg`:

```conf
firstEp tdengine-enterprise-0.tdengine-enterprise.iot.svc.cluster.local
secondEp tdengine-enterprise-1.tdengine-enterprise.iot.svc.cluster.local
```

配置生产网hosts：服务端与客户端的/etc/hosts【Windows: C:\Windows\system32\drivers\etc\hosts】：

```hosts
12.0.1.32 tdengine-enterprise-0.tdengine-enterprise.iot.svc.cluster.local
12.0.1.33 tdengine-enterprise-1.tdengine-enterprise.iot.svc.cluster.local
```

## 限制

当前Chart配置使用HostPort形式对外部开放访问。受HostPort运行方式的影响，集群的使用限制如下：

1. 集群节点单个节点发生故障后，运行Node可能发生改变，造成该节点访问不到的情况。故firstEp/secondEp均需要配置才能保证集群可用。
2. 若发生运行节点迁移，需要重新配置/etc/hosts 中的fqdn映射。

## 问题排查

使用如下命令查看各节点状态：

```sh
kubectl get pod -n iot -l app=taosd
```

两节点同时为 `Runing 1/1` 状态时节点处于运行状态。

使用如下命令查看节点日志：

```sh
kubectl logs -n iot tdengine-enterprise-0
kubectl logs -n iot tdengine-enterprise-1
kubectl logs -n iot -l app=taosd
```

使用如下命令进入节点内部shell:

```sh
kubectl exec -it -n iot tdengine-enterprise-0 -- bash
```

或直接进入taos shell：

```sh
kubectl exec -it -n iot tdengine-enterprise-0 -- taos
```

或直接执行taos shell 命令：

```sh
kubectl exec -n iot tdengine-enterprise-0 -- taos -s "show mnodes; show dnodes; show databases;"
```
