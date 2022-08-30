# TDengine集群自动化部署

## 0.说明

本文示例环境如下：

```shell
##部署TDengine的6个节点
192.168.0.70 c0-70 
192.168.0.71 c0-71
192.168.0.72 c0-72 
192.168.0.75 c0-75 
192.168.0.76 c0-76 
192.168.0.78 c0-77 

##Ansible操作端
192.168.1.157 
```

a.以下配置文件以TDengine-enterprise-server-2.2.1.4-Linux-x64.tar.gz为例，使用时请修改为实际版本。

b.使用前请确保Ansible已正确配置。

## 1.创建所需文件夹

```shell
 mkdir -pv /etc/ansible/tdengine/roles/{install,update}/{tasks,files}
```

## 2.准备配置文件和安装文件

a.配置Ansible主机组

```shell
/etc/ansible/hosts
[td]
192.168.0.70
192.168.0.71
192.168.0.72
192.168.0.75
192.168.0.76
192.168.0.78
```
b.编辑域名解析文件

```shell
vi /etc/ansible/tdengine/roles/install/files/hosts
192.168.0.70 c0-70 
192.168.0.71 c0-71
192.168.0.72 c0-72 
192.168.0.75 c0-75 
192.168.0.76 c0-76 
192.168.0.78 c0-77 
```

c.编辑taos.cfg【参考《TDengine安装指南》】
```shell
vi /etc/ansible/tdengine/roles/install/files/taos.cfg

###集群第一个节点，必须能解析到
firstEp									c0-70:6030
###集群第二个节点，必须能解析到，该参数为客户端参数
secondEp								c0-71:6030
###arbitrator解决，必须能解析到
#arbitrator             arbi:6042
###本地服务启示端口
serverport      				6030
###设置数据文件目录
dataDir        					/taos/data
###设置日志文件目录
logDir         					/taos/log
###关闭动态负载均衡，高负载环境建议关闭
balance 								0
###管理节点数量，默认1，上限3且小于等于节点数
#numOfMnodes     				3
minTablesPerVnode       1000		
tableIncStepPerVnode    1000		
maxVgroupsPerDb         32      
minRows		   						100
blocks                  6
###超级表排序结果集最大记录数，上限100万
maxNumOfOrderedRes      100000	
###返回不重复值结果集最大记录数，上限1亿
maxNumOfDistinctRes     10000000     
###是否须在 RESTful url 中指定数据库名
httpDbNameMandatory     1            
###通配符前字符串最大长度，上限16384
maxWildCardsLength      100 
###打开cachelast，缓冲最后一条记录提高查询速度
cachelast       				1
###设置最大sql长度
maxSQLLength    				1048576
###设置时区和字符集
timezone        				Asia/Shanghai
locale  								en_US.UTF-8
charset 								UTF-8
###设置最大连接数
maxShellConns   				50000
maxConnections  				50000
###取消日志保存天数限制
logKeepDays     				-1
###打开监控模块
monitor 								1
###打开删除备份功能
vnodeBak        				1
###允许部分列更新数据
update 									2
###以下为默认建议配置
keepColumnName  				1
numOfThreadsPerCore     2.0
ratioOfQueryCores       2.0
numOfCommitThreads      4.0
```

d.将安装包文件复制到 /etc/ansible/tdengine/roles/install/files 文件下

```shell
#tree /etc/ansible/tdengine/roles/install/files
files
├── taos.cfg
├── hosts
└── TDengine-enterprise-server-2.2.1.4-Linux-x64.tar.gz
```

复制升级包文件到/etc/ansible/tdengine/roles/update/files 文件下

```shell
#tree /etc/ansible/tdengine/roles/update/files
files
└── TDengine-enterprise-server-2.2.1.4-Linux-x64.tar.gz
```

e.准备升级检测文件 

```shell
vi /etc/ansible/tdengine/roles/update/files/ucheck.sh

#!/bin/sh
while true
do
taos -s "show dnodes" |grep '6030' | grep -v 'version not match' |grep -i offline
RS=$?
if [ $RS -ne 0 ]
then
		break;
fi
done
```

## 3.配置安装和升级任务

```shell
###安装任务
vi /etc/ansible/tdengine/roles/install/tasks/main.yml 
###软件包名称要与实际相符
- name: cpfile
  copy: src=TDengine-enterprise-server-2.2.1.4-Linux-x64.tar.gz dest=/tmp
- name: uzip
  shell: tar xvzf /tmp/TDengine-enterprise-server-2.2.1.4-Linux-x64.tar.gz -C /tmp
- name: install
  shell: cd /tmp/TDengine-enterprise-server-2.2.1.4/; bash install.sh -e no
###目录路径要与配置文件中保持一致
- name: create dir
  shell: mkdir -p /taos/{data,log}
- name: config hosts
  copy: src=hosts dest=/etc
- name: config td
  copy: src=taos.cfg dest=/etc/taos
- name: start
  service: name=taosd enabled=yes state=started 

```

```shell
###升级任务
vi /etc/ansible/tdengine/roles/update/tasks/main.yml 
###软件包名称要与实际相符
- name: stop taosd
  service: name=taosd enabled=no state=stopped
- name: uinstall taosd
  shell: rmtaos
- name: cpfile
  copy: src=TDengine-enterprise-server-2.2.1.4-Linux-x64.tar.gz dest=/tmp
- name: cpsh
  copy: src=ucheck.sh dest=/tmp
- name: uzip
  shell: tar xvzf /tmp/TDengine-enterprise-server-2.2.1.4-Linux-x64.tar.gz -C /tmp
- name: install
  shell: cd /tmp/TDengine-enterprise-server-2.2.1.4/; bash install.sh -e no
- name: start
  service: name=taosd enabled=yes state=started 
###如果升级包不支持滚动升级，请注释以下内容
- name: check
  shell: bash /tmp/ucheck.sh
```

## 4.配置主控任务

```shell
vi /etc/ansible/tdengine/roles/install.yml
- name: TDengine
  hosts: td
  roles:
    - install
```

```shell
vi /etc/ansible/tdengine/roles/update.yml
- name: TDengine
  hosts: td
  serial: 1
  roles:
    - update
```

## 5.安装TDengine集群

启动单节点安装

```shell
ansible-playbook /etc/ansible/tdengine/roles/install.yml 
```

登录到任一节点，查看集群环境，并添加节点。

```shell
show dnodes;
create dnode "c0-71:6030";
create dnode "c0-72:6030";
create dnode "c0-75:6030";
create dnode "c0-76:6030";
create dnode "c0-77:6030";
show dnodes;
show mnodes;
```

## 6.升级TDengine集群

```shell
ansible-playbook /etc/ansible/tdengine/roles/update.yml 
```
