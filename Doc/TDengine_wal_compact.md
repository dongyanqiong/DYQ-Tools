## 功能说明
该功能需要停止集群服务后，在mnode master节点上运行taosd --compact-mnode-wal来实现离线压缩。压缩后的mnode wal仍存放在原路径下mnode/wal，压缩前的wal移至mnode_tmp。

操作步骤说明：

查看mnode节点信息，确认master、slave所在的服务器
停集群所有节点
1. 【可选】移出mnode master/slave所有节点上的mnode_tmp
2. 在mnode master服务器上，以root权限，执行 taosd --compact-mnode-wal 。该命令运行时间与压缩前集群启动时间基本相同
3. 将mnode master压缩后的mnode/wal/*文件复制到其他两个slave节点对应目录
4. 重启集群

时间预估：
集群启动时间 x 2