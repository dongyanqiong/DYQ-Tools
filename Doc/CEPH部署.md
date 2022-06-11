#CEPH部署
##一.ceph简介
###本文仅涉及ceph支持三种接口的部署方法，原理方面不在本文涉及：
1 Object：有原生的API，而且也兼容Swift和S3的API;
2 Block：支持精简配置、快照、克隆;
3 File：Posix接口，支持快照。
##二.环境介绍
18.04.5 LTS (Bionic Beaver)
192.168.1.189 ceph01
192.168.1.188 ceph02
ceph: 
pacific 16.2.4
##三.系统资源
CPU: Intel(R) Xeon(R) Gold 6230R CPU @ 2.10GHz 8核
MEM: 15G
磁盘：sda 50g sdb1 200g
系统：ubuntu18.04虚拟机
##四.基础环境准备(root下进行即可)
###4.1 关闭防火墙

```
ufw status
ufw disable
```

###4.2 每台主机设置主机名

```
#192.168.1.189:
hostnamectl set-hostname ceph01
#192.168.1.188:
hostnamectl set-hostname ceph02
root@ceph01:~$ cat /etc/hosts
...
192.168.1.189 ceph01
192.168.1.188 ceph02
...
```

###4.3 添加Ceph pacific版本源
系统源更换成ustc源，并更新文件缓存

```
wget -q -O- 'http://mirrors.ustc.edu.cn/ceph/keys/release.asc' | sudo apt-key add -
echo deb http://mirrors.ustc.edu.cn/ceph/debian-pacific/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
apt-get update
```
###4.4 时间同步(多种方法均可)
修改时区

```
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate ntp3.aliyun.com 
echo "*/3 * * * * ntpdate ntp3.aliyun.com  &> /dev/null" > /tmp/crontab
crontab /tmp/crontab
```
###4.5 免密配置
####4.5.1 生成密钥
```
root@ceph01:~# ssh-keygen
enerating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
...
```
####4.5.2 将密钥复制到每个Ceph节点
注：该步可能需要配置/etc/ssh/sshd_config允许root登陆，将PermitRootLogin修改为yes即可
```
ssh-copy-id -o StrictHostKeyChecking=no root@ceph01
ssh-copy-id -o StrictHostKeyChecking=no root@ceph02
```
验证，不需要输入密码即为成功

```
ssh root@ceph01
ssh root@ceph02
```

##五.ceph安装与配置
###5.1 创建ceph部署用户（所有节点）
Ceph-deploy必须作为具有无密码sudo特权的用户登录到Ceph节点，因为它需要在不提示密码的情况下安装软件和配置文件;
这里我们需要创建一个用户专门用来给ceph-deploy部署，使用ceph-deploy部署的时候只需要加上--username选项即可指定用户，需要注意的是：

- 不建议使用root
- 不能使用ceph为用户名，因为后面的部署中需要用到该用户名，如果系统中已存在该用户则会先删除掉该用户，然后就会导致部署失败
- 该用户需要具备超级用户权限（sudo），并且不需要输入密码使用sudo权限
- 所有的节点均需要创建该用户
- 该用户需要在ceph集群中的所有机器之间免密ssh登录

创建新用户

```
sudo useradd -d /home/cephdeploy -m cephdeploy
sudo passwd cephdeploy
```
配置sudo权限并设置免密:
```
echo "cephdeploy ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephdeploy
sudo chmod 0440 /etc/sudoers.d/cephdeploy
```

如果我们的节点已经设置了ssh免密登录，可以直接把免密登录用户的ssh文件夹复制到新建的用户目录下，这里以root用户为例:

```
sudo cp -R /root/.ssh/ /home/cephdeploy/
sudo chown cephdeploy:cephdeploy /home/cephdeploy/.ssh/ -R
```

###5.2 创建并配置ceph集群
####5.2.1 创建ceph配置目录和集群
创建集群目录，用于维护ceph-deploy为集群生成的配置文件和密钥:

```
su - cephdeploy
mkdir ~/cephcluster
cd ~/cephcluster
```
注意点:
ceph-deploy会将文件输出到当前目录，如果在执行ceph-deploy时，一定要确保您在这个目录中。

####5.2.2 安装ceph-deploy

```
sudo apt-get install python3 python3-pip -y
#二选一，第一个国内加速下载地址，第二个为原地址慢:
git clone https://github.com.cnpmjs.org/ceph/ceph-deploy.git
git clone https://github.com/ceph/ceph-deploy.git
cd ceph-deploy
#如果要使用ceph-deploy直接部署ceph那么需要修改以下这个文件:
#vim /home/cephdeploy/cephcluster/ceph-deploy/ceph_deploy/install.py
#将args.release = 'nautilus' 修改成 args.release = 'pacific'
pip3 install setuptools
python3 setup.py install
```
####5.2.3 在cephcluster目录下执行创建集群

```
cephdeploy@ceph01:~/cephcluster$ ceph-deploy new ceph01 ceph02
```
####5.2.4 ceph配置文件修改

```
#创建公共访问的网络
vim /home/cephdeploy/cephcluster/ceph.conf
[global]
fsid = f4332ff7-6406-47f5-86fb-71ffc41eaf18
mon_initial_members = ceph01, ceph02
mon_host = 192.168.1.189,192.168.1.188
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
#设置副本数
osd_pool_default_size = 1
#设置最小副本数
osd_pool_default_min_size = 2
#设置时钟偏移0.5s
mon_clock_drift_allowed = .50
```
####5.2.5 各节点安装基础包

安装ceph相关包，每台执行
```
sudo apt-get install -y ceph ceph-osd ceph-mds ceph-mon radosgw
```

####5.2.6 部署初始mon并生成密钥:

初始化mon，执行过程无报错即可
```
ceph-deploy mon create-initial
```

这时候目录底下应该会多以下的key

```
cephdeploy@ceph01:~/cephcluster$ ll
total 68
drwxrwxr-x  3 cephdeploy cephdeploy  4096 Jul  2 20:01 ./
drwxr-xr-x  7 cephdeploy cephdeploy  4096 Jul  2 19:57 ../
-rw-------  1 cephdeploy cephdeploy   113 Jul  2 20:01 ceph.bootstrap-mds.keyring
-rw-------  1 cephdeploy cephdeploy   113 Jul  2 20:01 ceph.bootstrap-mgr.keyring
-rw-------  1 cephdeploy cephdeploy   113 Jul  2 20:01 ceph.bootstrap-osd.keyring
-rw-------  1 cephdeploy cephdeploy   113 Jul  2 20:01 ceph.bootstrap-rgw.keyring
-rw-------  1 cephdeploy cephdeploy   151 Jul  2 20:01 ceph.client.admin.keyring
-rw-rw-r--  1 cephdeploy cephdeploy   368 Jul  2 19:57 ceph.conf
drwxrwxr-x 10 cephdeploy cephdeploy  4096 Jul  2 19:55 ceph-deploy/
-rw-rw-r--  1 cephdeploy cephdeploy 27867 Jul  2 20:01 ceph-deploy-ceph.log
-rw-------  1 cephdeploy cephdeploy    73 Jul  2 19:56 ceph.mon.keyring
```
####5.2.7 使用Ceph -deploy将配置文件和管理密钥复制到您的管理节点和Ceph节点

```
ceph-deploy admin ceph01 ceph02
```
####5.2.8 部署mgr服务
创建mgr，执行过程无报错即可

```
ceph-deploy mgr create ceph01 ceph02
```

检查状态

```
cephdeploy@ceph01:~/cephcluster$ systemctl status ceph-mgr@ceph01
● ceph-mgr@ceph01.service - Ceph cluster manager daemon
   Loaded: loaded (/lib/systemd/system/ceph-mgr@.service; indirect; vendor preset: enabled)
   Active: active (running) since Fri 2021-07-02 20:03:09 CST; 42s ago
 Main PID: 32031 (ceph-mgr)
    Tasks: 62 (limit: 4915)
   CGroup: /system.slice/system-ceph\x2dmgr.slice/ceph-mgr@ceph01.service
           └─32031 /usr/bin/ceph-mgr -f --cluster ceph --id ceph01 --setuser ceph --setgroup ceph
```
####5.2.9 添加OSD
已提前将500G sdb分区200G sdb1
```
ceph-deploy osd create --data /dev/sdb1 ceph01
ceph-deploy osd create --data /dev/sdb1 ceph02
```
####5.2.10 验证集群状态

```
cephdeploy@ceph01:~/cephcluster$ sudo ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME        STATUS  REWEIGHT  PRI-AFF
-1         0.39059  root default
-3         0.19530      host ceph01
 0    hdd  0.19530          osd.0        up   1.00000  1.00000
-5         0.19530      host ceph02
 1    hdd  0.19530          osd.1        up   1.00000  1.00000
```
###5.3 扩展集群的服务 - 请根据需求开启
####5.3.1 添加元数据服务器（mds）

```
ceph-deploy mds create ceph01
```

####5.3.2 添加监控端（mon）

```
ceph-deploy mon add ceph01
ceph-deploy mon add ceph02
```

一旦您添加了新的Ceph监视器，Ceph将开始同步监视器并形成一个quorum，您可以通过执行以下操作来检查仲裁状态:

```
sudo ceph quorum_status --format json-pretty
```

####5.3.3 增加守护进程（mgr）
Ceph Manager守护进程以活动/备用模式操作，部署其他管理器守护进程可以确保，如果一个守护进程或主机失败，另一个守护进程可以接管，而不会中断服务。

```
ceph-deploy mgr create ceph01
```

验证

```
ceph -s
```

####5.3.4 增加对象存储网关（rgw）

```
ceph-deploy rgw create ceph01 ceph02
```

默认情况下，RGW实例将监听端口7480，这可以通过在运行RGW的节点上编辑ceph.conf来改变，如下所示:
```
[client]
rgw frontends = civetweb port=80
```

修改完端口需要重启服务

```
systemctl restart ceph-radosgw.service
```
##六.存储部署
###6.1 启用CephFS
####6.1.1 请确认至少有一台节点启用了mds服务，pg数是有算法的，可以使用官网计算器去计算！
PG数量的预估 集群中单个池的PG数计算公式如下：PG 总数 = (OSD 数 * 100) / 最大副本数 / 池数 (结果必须舍入到最接近2的N次幂的值)
在ceph集群，其中一台执行命令即可，这里用ceph01

```
sudo ceph osd pool create cephfs_data 16
sudo ceph osd pool create cephfs_metadata 16
sudo ceph fs new cephfs_storage cephfs_metadata cephfs_data
sudo ceph df
```
####6.1.2 挂载cephfs
在客户端创建密码文件

```
cephdeploy@ceph01:~/cephcluster$ sudo cat /etc/ceph/ceph.client.admin.keyring
[client.admin]
	key = AQDeDt9goLtNFxAAYZk0BFiiXZzvOyPipA/UNQ==
	caps mds = "allow *"
	caps mgr = "allow *"
	caps mon = "allow *"
	caps osd = "allow *"
	
echo "AQDeDt9goLtNFxAAYZk0BFiiXZzvOyPipA/UNQ==" >admin.secret

mkdir /mnt/cephfs_storage

sudo mount -t ceph 192.168.1.189:6789:/ /mnt/cephfs_storage -o name=admin,secretfile=admin.secret

df -h | grep mnt
```
###6.2 启用块存储
####6.2.1 在ceph集群，其中一台执行命令即可，这里用ceph133
初始化rbd池
PG数量的预估 集群中单个池的PG数计算公式如下：PG 总数 = (OSD 数 * 100) / 最大副本数 / 池数 (结果必须舍入到最接近2的N次幂的值)
```
sudo ceph osd pool create rbd_storage 16 16 replicated
```
创建一个块设备
```
sudo rbd create --size 40960 rbd_image1 -p rbd_storage
sudo rbd ls rbd_storage
```
删除命令
```
sudo rbd rm rbd_storage/rbd_image1
```
####6.2.2 挂载rbd块设备

将块设备映射到系统内核

```
sudo rbd feature disable rbd_storage/rbd_image1 object-map fast-diff deep-flatten
sudo rbd map rbd_storage/rbd_image1
/dev/rbd0
```

格式化rbd设备

```
sudo mkfs.ext4 -m0 /dev/rbd/rbd_storage/rbd_image1
```

挂载rbd设备

```
sudo mkdir /mnt/rbd_storage
sudo mount /dev/rbd0 /mnt/rbd_storage
```

取消内核挂载

```
sudo rbd unmap /dev/rbd0
```

###6.3 启用RGW对象存储
请确认至少有一台节点启用了rgw服务
启用rgw见5.3.4
使用浏览器，查看 http://192.168.1.189:7480/，说明已经启用成功

```
This XML file does not appear to have any style information associated with it. The document tree is shown below.
<ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<Owner>
<ID>anonymous</ID>
<DisplayName/>
</Owner>
<Buckets/>
</ListAllMyBucketsResult>
```
##7 启用ceph dashboard
###7.1 启用dashboard
Ceph仪表板是一个内置的基于web的Ceph管理和监视应用程序，用于管理集群;节点默认没有安装mgr-dashboard程序，因此要先安装;

```
sudo apt install ceph-mgr-dashboard -y
```

任一节点启用dashboard，没有提示

```
sudo ceph mgr module enable dashboard
```

配置登陆认证

```
sudo ceph dashboard create-self-signed-cert
Self-signed certificate created
```

配置登陆账户
由于16版本创建用户有变化，需要先创建密码文件，这里密码用admin123456

```
echo "admin123456" > passwd
```

用户名为admin，加入administrator组，-i 后面跟着前面创建的密码文件

```
sudo ceph dashboard ac-user-create admin  administrator -i passwd
{"username": "admin", "password": "$2b$12$/3QmcgXQQYS381f3YHdYaO1KMw7IMuIrKXWW2jJAQ6x8buFTTeOCO", "roles": ["administrator"], "name": null, "email": null, "lastUpdate": 1625234075, "enabled": true, "pwdExpirationDate": null, "pwdUpdateRequired": false}
```

测试登陆，浏览器查看：https://192.168.1.189:8443/ 用户名：admin 密码：admin123456

```
cephdeploy@ceph01:~/cephcluster$ sudo ceph mgr services
{
    "dashboard": "https://ceph01:8443/"
}
```
###7.2 启用dashboard

创建rgw的用户

```
sudo radosgw-admin user create --uid=rgwadmin --display-name=rgwadmin --system
{
    "user_id": "rgwadmin",
    "display_name": "rgwadmin",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [],
    "keys": [
        {
            "user": "rgwadmin",
            "access_key": "CDX8QRL1OGTKPIRP6LKI",
            "secret_key": "J96SOefa4LyuZ1Vl1VldCKgQEPHGT9P7IMFRGxJw"........
            
```


```
#设置凭证，取创建用户生成的key
#先创建key文件，再更新
echo "CDX8QRL1OGTKPIRP6LKI" > rgw-api-access-key
echo "J96SOefa4LyuZ1Vl1VldCKgQEPHGT9P7IMFRGxJw" > rgw-api-secret-key
sudo ceph dashboard set-rgw-api-access-key -i rgw-api-access-key
sudo ceph dashboard set-rgw-api-secret-key -i rgw-api-secret-key
#禁用SSL
ceph dashboard set-rgw-api-ssl-verify False
```

```
#启用rgw的dashboard

sudo ceph dashboard set-rgw-api-host 192.168.1.189
sudo ceph dashboard set-rgw-api-port 7480
sudo ceph dashboard set-rgw-api-scheme http
sudo ceph dashboard set-rgw-api-admin-resource admin
sudo ceph dashboard set-rgw-api-user-id rgwadmin
sudo systemctl restart ceph-radosgw.target
sudo systemctl status ceph-radosgw.target
● ceph-radosgw.target - ceph target allowing to start/stop all ceph-radosgw@.service instances at once
   Loaded: loaded (/lib/systemd/system/ceph-radosgw.target; enabled; vendor preset: enabled)
   Active: active since Fri 2021-07-02 22:01:10 CST; 5s ago
```
至此，dashboard中Object Gateway中可以获取到对象存储

