# <center>Nginx配置</center>

```bash
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;

events {
    use epoll;
    worker_connections 1024;
}

http {
    server {
        listen 6041;
        location /{
        proxy_pass http://taosdata;
        proxy_next_upstream http_500 | http_502 | http_503 | http_504 |http_404;
        }
    }
 
    upstream taosdata {
        least_conn;
        server 192.168.0.11:6041 max_fails=2 fail_timeout=3s;
        server 192.168.0.12:6041 max_fails=2 fail_timeout=3s;
        server 192.168.0.13:6041 max_fails=2 fail_timeout=3s;
    }
}
```
## 参数解读：
### 线程数
```bash
worker_processes auto
```

### 连接池
```bash
worker_connections 1024;
```

### 负载均衡协议
```bash
http
```

### 监听端口
```bash
listen 6041;
```

### 负载均衡策略
```bash
#最小连接数
least_conn;
```
在实际测试中发现采用轮询方式，每个节点分配的连接数并不均匀。

## 操作系统参数
```bash
sysctl -w net.core.somaxconn=10240
sysctl -w net.ipv4.tcp_max_syn_backlog=10240
sysctl -w net.core.netdev_max_backlog=20480
sysctl -w net.ipv4.tcp_retries2=5
sysctl -w net.ipv4.tcp_syn_retries=2
sysctl -w net.ipv4.tcp_synack_retries=2
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_tw_recycle=1
sysctl -w net.ipv4.tcp_keepalive_time=600
sysctl -w net.ipv4.tcp_max_tw_buckets=5000

sysctl -w net.core.wmem_default = 212992
sysctl -w net.core.wmem_max = 212992
sysctl -w net.core.rmem_default = 212992
sysctl -w net.core.rmem_max = 212992
```