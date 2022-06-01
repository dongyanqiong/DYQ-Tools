# 高可用测试脚本
## 前提
运行脚本前需保证：
1.本地测试端与服务端已配置好 SSH 互信。
2.本地测试端 taosc 可连接到任一服务端。
3.本地需配置好 firstEp 和 secondEp。

## 使用说明
### 配置初始化参数
在脚本开头配置相关参数：

```shell
#配置节点FQDN
tdnodes=(c0-11 c0-12)
#配置Tdengine root用户密码
password=taosdata
###初始数据副本数
repl=2
###初始数据表数量
tnum=100

```
### 运行检查脚本
```shell
/bin/bash HACheck.sh
```

## 脚本说明

脚本处理流程

#### 1.检查 SSH 互信
如果互信不通过，直接报错退出。

#### 2.写入初始数据 Init_Demo_Data
如果初始化数据失败，直接报错退出。

#### 3.对数据节点进行轮询处理
以下任何步骤出错，直接报错退出。

##### 3.1 关闭 taosd 服务
##### 3.2 确认节点是否 offline
##### 3.3 查询表数据是否准确
##### 3.4 创建表并写入数据
##### 3.5 查询新写数据是否准确
##### 3.6 启动 taosd 服务
##### 3.7 确认所有节点上线

#### 4.轮询结束退出