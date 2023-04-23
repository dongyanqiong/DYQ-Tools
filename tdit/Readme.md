巡检脚本使用方法：
1.在客户环境执行tdit.sh, 将压缩包上传至公司。

2.执行tdit.sh, 压缩包里面会保存采集到的数据。
如在/tmp 目录下执行，当前日期为2021年5月1日，则生成的压缩包名称为：TD_20210501_2628.gz

3.采集数据库信息时必须使用root用户，如果root用户密码已修改，需要在脚本中进行修改。

4.使用dnode参数，可以不检查数据库相关内容，用于集群非主节点环境检查。例：./tdit.sh dnode

I 更新记录
--20220527
优化Markdown输出

--20220127
添加dnode参数，防止集群环境重复检查。 
使用dnode参数，不会检查DB，Mnode，Dnode，Vnode等信息。
使用方法：./tdit.sh dnode  

--20220126
添加jannsson和snappy 检查

--20211209
将report操作添加到主程序中。

--20211208
将文件夹前后添加说明，防止误删除。
将文件名称从main.sh 修该为tdit.sh (TDengine Inspection Tools)
添加采集taosd服务的limit信息

--20211117
添加配置信息采集
添加ClusterId


