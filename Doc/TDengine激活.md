# TDengine激活

## 一、说明

1、TDengine企业版本需要激活才能正常使用，初次安装后可以试用2个月。授权到期后重启taosd服务可以延期一天。

2、软件激活原理是根据服务器的硬件配置生成一组唯一的【机器码】，根据机器码加密计算生成一组【激活码】。因此【激活码】与服务器硬件是强绑定的，如果服务器硬件发生变化，可能会造成【机器码】变更，从而造成【激活码】失效，需要重新激活。

## 二、机器码获取

在TDengine集群的每个节点执行以下语句：

```shell
taosd -k
```

将生成的机器码发生给涛思数据。

【该命令会读取硬件信息，因此需要管理员权限。】

示例：

```shell
[root@jf01 taos]# taosd -k
machine code: 4ezRacKFdZWN2NVS+Vktp088 
```

## 三、激活

对于TDengine集群，每个节点都需要激活处理。

将获取的激活码写入到taos.cfg配置文件中，格式如下：

```shell
activeCode 激活码
```

示例：

```shell
[root@jf01 taos]# cat /etc/taos/taos.cfg
activeCode 8hBjrqcPEvlJWl7OxrPZ2ElaXs7Gs9nYSVpezsaz2dhJWl7OxrPZ2ElaXs7Gs9nYSVpezsaz2djGIj5StnQ3ZvMOtcNhQ7rJ
firstEp									jf01:6030
fqdn 										jf01
```

修改配置文件后，有两种方法可是使激活生效：

#### 1、重启taosd服务

```shell
systemctl restart taosd
```

#### 2、在线激活

可以通过RESTful接口进行在线激活，RESTful默认端口6041

```shell
curl -u root:taosdata <node1>:<port1>/admin/grant
```

示例：

```shell
[root@jf01 taos]# curl -u root:taosdata jf01:6041/admin/grant
{"status":"succ","code":0,"desc":"official version 2100-01-01 00:00:00"}
```

如果不想泄露用户名密码，可以使用数字签名token

```shell
curl -H 'Authorization: <auth info>' <node2>:<port2>/admin/grant
```

示例：

```shell
[root@jf01 taos]# curl -H 'Authorization: Basic cm9vdDp0YW9zZGF0YQ==' jf01:6041/admin/grant                                                                
{"status":"succ","code":0,"desc":"official version 2100-01-01 00:00:00"}
```

数字签名获取请参考TDengine官网

[RESTful Connector](https://www.taosdata.com/cn/documentation/connector#restful)

