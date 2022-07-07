# <center>Nginx配置</center>

```bash
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    server {
        listen 6041;
        location /{
        proxy_pass http://taosdata;
        }
    }
 
    upstream taosdata {
        least_conn;
        server 192.168.0.11:6041;
        server 192.168.0.12:6041;
        server 192.168.0.13:6041;
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