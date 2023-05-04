# TDengine 网络测试

当出现客户端应用无法访问服务端时，需要确认客户端与服务端之间网络的各端口连通情况，以便有针对性地排除故障。

目前网络连接诊断支持在：Linux 与 Linux，Linux 与 Windows 之间进行诊断测试。

测试步骤如下：

## 1.服务端关闭taosd服务

```shell
systemctl stop taosd
```

## 2.服务端启动监听进程

```shell
taos -n server
```

正常输出如下：

![image-20220308090250557](TDengine 网络测试.assets/image-20220308090250557.png)

## 3.客户端修改配置文件

在/etc/taos/taos.cfg中添加

```shell
rpcForceTcp 1
```

## 4.客户端发起测试

```shell
 taos -n client -h 服务端IP
```

正常输出如下：

![image-20220308090338345](TDengine 网络测试.assets/image-20220308090338345.png)