# VNODE手动迁移

当一个数据库的某个节点数据过热时或vnode不均衡时，可手动迁移该节点上vnode至指定的数据节点。
该操作仅在自动负载均衡选项关闭(balance=0)时方可执行。

1. 运行taos CLI登入集群，查看集群节点信息 > show dnodes;

2. 查看待数据库(mydb)虚拟节点组信息 > show db_name.vgroups;

3. 将当前节点(source-dnodeId)的vnode(vgId)，迁移至指定节点(dest-dnofeId) > ALTER DNODE <source-dnodeId> BALANCE "VNODE:<vgId>-DNODE:<dest-dnodeId>";

   示例：迁移3节点上的43号vgId对应的vnode到7节点：alter dnode 3 balance "VNODE:43-DNODE:7";

说明：

数据过热：类似于Oracle中的热块。在创建表的过程中，是按照顺序依次在各个节点创建的，创建时无法预测具体哪些表会被分配在哪个节点。当数据集中写入到某些表时，可能会造成某个节点被集中访问，负载过大。

vnode不均衡：初次创建表时，会按照各节点负载评分依次创建，不会出现vnode不均衡的状况。只有在增减副本数、增删节点、删除数据库的情况下，才可能出现节点间vnode不均衡的现象。



## 示例

### 当前vnode分布

| DB_NAME                       | node1 | NODE2 | NODE3 | NODE4 | NODE5 | NODE6 | NODE7 |
| ----------------------------- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| dataplatform_test_glpt_stream | 27    | 10    | 18    | 27    | 9     | 27    | 10    |
| dataplatform_test_0200        | 20    | 15    | 17    | 25    | 12    | 29    | 10    |
| dataplatform_test_0f3b        | 26    | 9     | 19    | 26    | 13    | 25    | 10    |
| dataplatform_test_glpt_obd    | 29    | 10    | 19    | 26    | 9     | 26    | 9     |

### 迁移方案

将vnode进行相邻节点迁移【1，4，6迁移到2，5，7】，平衡vnode数量。

注意事项：只能迁移slave角色的vnode，迁移过程业务不受影响。

**如果迁移master角色vnode，会造成业务中断，无法进行写入和查询，会报 "Database is syncing" 错误。**

