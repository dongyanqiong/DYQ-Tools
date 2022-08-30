# TDengine Operation Tools(beta)
# tops.py
## 1.工具说明
该工具提供对多个TDengine集群和节点管理及状态检查，使用工具前，需要将TDengine相关信息配置到host.cfg中

## 2.配置文件
### 2.1.格式说明
{
    "集群名称":[
        ["节点1IP","用户名","密码",RESTFul端口],
        ["节点2IP","用户名","密码",RESTFul端口]，
    ]
}

### 2.2.示例
{
    "cluster1":[
    ["192.168.1.60","root","taosdata",6041],
    ["192.168.1.61","root","taosdata",6041],
    ["192.168.1.62","root","taosdata",6041]],
    "cluster138":[
    ["192.168.1.138","root","taosdata",6041]]
}

## 3.操作说明
### 3.1.1.TDengine Cluster Status View
该模块提供对TDengine集群Dnode、Mnode、Databases、授权信息的查看。
选择“ALL”，会显示配置文件中所有集群信息

### 3.2.TDengine Cluster Mangement
该模块提供对TDengine集群的管理功能，具体实现方式为通过RESTFul将操作命令发送给相关节点，
并对返回值进行格式化处理。

选择“Custom”，可以手动输入节点地址、用户名、密码、端口，可以用来管理配置文件中没有的节点或集群。

### 3.3.TDengine Cluster Heathly Check
该模块提供对TDengine集群或节点的健康状态检查，目前仅支持Dnode、Mnode和Database。
如果该集群以上状态正常，则以绿底白字显示集群名称；如果该集群以上状态异常，则以红底白字显示集群名称，并打印异常信息。

# ptaos.py 
基于RESTFul的客户端，可替代taosc。

ptaos-win.py  适用于Windows 平台。