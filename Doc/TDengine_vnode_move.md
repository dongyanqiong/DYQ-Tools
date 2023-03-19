当一个数据库的某个节点数据过热时或vnode不均衡时，可手动迁移该节点上vnode至指定的数据节点。 该操作仅在自动负载均衡选项关闭(balance=0)时方可执行。

运行taos CLI登入集群，查看集群节点信息 > show dnodes;

查看待数据库(mydb)虚拟节点组信息 > show db_name.vgroups;

自动化统计vnode工具 vcalc.sh

将当前节点(source-dnodeId)的vnode(vgId)，迁移至指定节点(dest-dnofeId) > ALTER DNODE <source-dnodeId> BALANCE "VNODE:<vgId>-DNODE:<dest-dnodeId>";

示例：迁移3节点上的43号vgId对应的vnode到7节点：alter dnode 3 balance "VNODE:43-DNODE:7";

说明：

数据过热：类似于Oracle中的热块。在创建表的过程中，是按照顺序依次在各个节点创建的，创建时无法预测具体哪些表会被分配在哪个节点。当数据集中写入到某些表时，可能会造成某个节点被集中访问，负载过大。

vnode不均衡：初次创建表时，会按照各节点负载评分依次创建，不会出现vnode不均衡的状况。只有在增减副本数、增删节点、删除数据库的情况下，才可能出现节点间vnode不均衡的现象。

## 时间预估
迁移数据量 / min{NetIO,DiskIO}