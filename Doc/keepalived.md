## 概述

|fqdn|角色|
|---|----|
|td1|taosd+taosadapter+keepalived|
|td2|taosd+taosadapter+keepalived|
|td3|taosd+taosadapter+keepalived|

每个节点安装keepalived，Restful/WebSocket 访问VIP，原生方式访问RealIP。


## 安装

```bash
yum install -y keepalived
```

```bash
wget https://keepalived.org/software/keepalived-2.2.8.tar.gz
tar xzf keepalived-2.2.8.tar.gz

./configure --prefix=/usr/local/keepalived
make
make install

```

## 配置

### keepalived.service
```bash
[Unit]
Description=LVS and VRRP High Availability Monitor
After=syslog.target network-online.target

[Service]
Type=forking
PIDFile=/var/run/keepalived.pid
KillMode=process
EnvironmentFile=-/etc/sysconfig/keepalived
ExecStart=/usr/local/keepalived/sbin/keepalived $KEEPALIVED_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
StartLimitInterval=0
RestartSec=30

[Install]
WantedBy=multi-user.target
```

### keepalived.conf
```bash
! Configuration File for keepalived

global_defs {
   router_id c3-60  ## 主机名
}

vrrp_script chk_adapter {
        script "/etc/taos/adapter_check.sh"
        interval 2
        weight -50
}

vrrp_instance VI_1 {
    state BACKUP
    interface ens192
    virtual_router_id 51
    priority 60
    nopreempt
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 6041
    }
    track_script {
        chk_adapter
    }
    virtual_ipaddress {
        192.168.3.59
    }
}
```
### adapter_check.sh
```bash
#!/bin/sh
acheck() 
{
        curl http://127.0.0.1:6041/-/ping
        if [ $? -ne 0 ]
        then
                pkill keepalived
                exit 1
        else
                exit 0
        fi
}

acheck
```

## 启动
```bash
systemctl start keepalived
```