

# TDengine 缩容操作

## ###不能删除firstEP 所在节点。

## 一、3节点3副本缩容为2节点2副本

### 1.修改数据库副本数

alter database 数据库名 replica 2;

### 2.确认副本状态

show 数据库名.vgroups;
等所有状态为master或slave，则操作完成。

### 3.删除节点

drop dnode "节点名:6030";

### 4.确定节点状态

show dnodes;
显示正确节点数后，操作完成。

### 5.停止删除节点的taosd服务

systemctl stop taosd