巡检脚本使用方法：
1.在客户环境执行tdit.sh, 将压缩包上传至公司。

2.执行tdit.sh, 压缩包里面会保存采集到的数据。
如在/tmp 目录下执行，当前日期为2021年5月1日，则生成的压缩包名称为：TD_20210501_2628.gz



I 更新记录
--20211117
添加配置信息采集
添加ClusterId

--20211208
将文件夹前后添加说明，防止误删除。
将文件名称从main.sh 修该为tdit.sh (TDengine Inspection Tools)
添加采集taosd服务的limit信息

--20211209
将report操作添加到主程序中。

--20220126
添加jannsson和snappy 检查