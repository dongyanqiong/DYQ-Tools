## TDengine 2.x 版本升级到 2.4.x.x 步骤



### 特别说明：

1. 从2.x升级到2.4后，不能回退。务必先做好测试、验证，避免出现不可预期的问题
2. 2.4版企业版安装包集成了taosd/taosAdapter/taosdump/taosBenchmark/TDinsight/taosKeeper
3. httpd从taosd分离出来，成为独立的服务进程：taosadapter
4. 新增了TDinsight和taosKeeper，详细信息参见用户手册
   TDinsight需先安装Grafana 7.5以上版本，是一个轻量的、一体化的TDengine监控系统
   taosKeeper可与Promethus、Zabbix等第三方监控平台集成，使得现有的企业级监控平台可以监控TDengine集群的运行状态
5. taosdump/taosBenchmark(原taosdemo)分离出来，成为taosTool。客户端如需部署taosdump/taosBenchmark，可以按需安装taosTool
6. taosAdapter的配置文件为 /etc/taos/taosadapter.toml。需要说明的是，日志路径需要单独配置，与taos.cfg独立
7. taosAdapter启停，需要通过systemd。如需restful服务，需手动启动taosAdapter服务：`systemctl start taosadapter`



### 升级步骤及注意事项：

0. 2.4.x.x 版本对应的 taos-jdbcdriver 版本为 2.0.37，请在应用代码中进行调整。建议先在测试环境中进行升级测试，并检查业务应用各方面是否正常，再升级生产环境
1. 确保集群状态正常（`show dnodes; show mnodes; show vgroups;`），读写无问题
2. 所有节点停止数据库服务： `systemctl stop taosd`
3. 检查各个节点的数据文件目录（`grep dataDir /etc/taos/taos.cfg`）下的wal日志大小。假如数据文件目录为 /var/lib/taos ，可以使用 `ll /var/lib/taos/vnode/vnode*/wal/*`  命令检查所有vnode目录下的wal日志大小是否为0。如果不全为0，启动各节点数据库服务，然后重复 1-2 步骤
4. 备份每个节点数据文件目录下的所有内容到数据文件目录之外的位置，可以使用 `cp`  命令。如果企业版使用多级存储，在备份前需要先建立好每级存储对应的目录， 然后将数据拷贝到对应的目录下
5. 在数据库服务 taosd 停止的状态下，分别在所有节点执行 `rmtaos`（卸载不会删除数据文件和 taos.cfg ），然后每个节点安装新版本(运行`./install.sh`)
6. 如果使用了 taosc 客户端方式，请一同升级所有的客户端到对应的 2.4 版本。Linux环境先执行 `rmtaos` 命令卸载旧版本客户端，安装新版本(运行`./install_client.sh`)。Windows环境同样先卸载旧版本再安装新版本
7. 分别启动所有节点的 taosd 服务：`systemctl start taosd` ，可以使用 `taos -n startup` 检测 taosd 启动是否完成
8. 2.4 版本新增 taosAdapter 服务（之前版本的 httpd 从 taosd 分离出来，成为独立的服务进程：taosadapter），配置文件为 /etc/taos/taosadapter.toml。taosAdapter 日志路径需要单独配置（默认 path 为 /var/log/taos）。如需restful服务，启动所有节点 taosAdapter 服务 ： `systemctl start taosadapter`（restful 的6041端口未变），并设置开机自启动： `systemctl enable taosadapter`
9. 所有节点 taosd 启动完成后，检查集群状态（`show dnodes; show mnodes; show vgroups;`），读写无问题
10. 检查业务应用系统是否正常

