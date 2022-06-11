# TDengine FQDN修改方法

## 1.停止TDengine服务

```shell
systemctl stop taosd
```

## 2.备份TDengine数据

备份TDenine整个数据目录。如果空间不足，可只备份dnode和mnode文件夹。

## 3.修改/etc/hosts

修改/etc/hosts中记录。

```shell
10.10.68.11  tdengine_v2_node2 
10.10.68.10  tdengine_v2_node1 
10.10.68.12  tdengine_v2_node3 
```

## 4.修改TDengine配置文件

修改taos.cfg中的

```shell
firstEp 
fqdn
```

| 节点 | 原值                     | 修改后值                       |
| ---- | ------------------------ | ------------------------------ |
| 1    | firstEp 10.10.68.10:6030 | firstEp tdengine_v2_node1:6030 |
| 1    | fqdn 10.10.68.10 | fqdn tdengine_v2_node1 |
| 2    | firstEp 10.10.68.10:6030 | firstEp tdengine_v2_node1:6030 |
| 2    | firstEp 10.10.68.11 | fqdn tdengine_v2_node2 |
| 3    | firstEp 10.10.68.10:6030 | firstEp tdengine_v2_node1:6030 |
| 3    | firstEp 10.10.68.12 | fqdn tdengine_v2_node3 |

## 5.修改TDengine节点文件

修改$dataDir/dnode/dnodeEps.json 文件

将dnodeFqdn 修改为相应值

| 原值        | 修改后值          |
| ----------- | ----------------- |
| 10.10.68.11 | tdengine_v2_node2 |
| 10.10.68.10 | tdengine_v2_node1 |
| 10.10.68.12 | tdengine_v2_node3 |

## 6.启动数据库

```shell
systemctl start taosd
```

## 7.修改log库dn表的标签

```shell
alter table log.dn1 set tag fqdn="tdengine_v2_node1";
alter table log.dn2 set tag fqdn="tdengine_v2_node2";
alter table log.dn3 set tag fqdn="tdengine_v2_node3";
```

## 8.验证业务

```shell
taos
taos> show dnodes;
taos> show mnodes;
taos> show databases;
```

