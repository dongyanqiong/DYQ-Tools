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
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    server {
        listen 6041;
        location /{
        proxy_pass http://taosdata;
        proxy_read_timeout  300s;  //web-socker时设置为600s
        proxy_http_version 1.1; //web-socker
        proxy_set_header Upgrade $http_upgrade; //web-socker
        proxy_set_header Connection "upgrade"; //web-socker
        proxy_next_upstream error timeout http_502 http_500  non_idempotent;
        }
    }
 
    upstream taosdata {
        least_conn;
        server 192.168.0.11:6041 max_fails=2 fail_timeout=1s;
        server 192.168.0.12:6041 max_fails=2 fail_timeout=1s;
        server 192.168.0.13:6041 max_fails=2 fail_timeout=1s;
    }
    access_log off;
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

## IP HASH
```bash
ip_hash
```


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

## WebSocket
http://nginx.org/en/docs/http/websocket.html

## 安全加固

### CORS 设置
```bash
server{
set $flag 0;
if ( $http_Origin ~* 127.0.0.1|192.168.1.121 ) {
       set $flag '1';
}
if ( $http_Origin ~* '^$'){
    set $flag '1';
}
if ( $flag = "0") {
    return 403;
}
proxy_set_header Host $host;
proxy_set_header Origin $host;
proxy_pass_request_headers  on;
server_tokens off;
}
```

## 限制IP访问
```bash
http{
include blocksip.conf;
}
```
allow 10.122.166.201;
allow 10.122.28.232;
allow 10.122.6.53;
allow 10.59.173.32;
deny all;
```bash

```
## 均衡策略
hash $binary_remote_addr consistent 和 ip_hash都是NGINX中负载均衡的方式，但它们的工作原理有些差异。

ip_hash：这种方式是针对每个客户端IP地址进行哈希计算，并依据哈希结果将来自同一IP的客户端请求分配给同一台后端服务器。这主要用于处理需要会话保持（session persistence）的应用，比如购物车应用、某些需要登录的网站等。

hash $binary_remote_addr consistent：这是NGINX提供的一种更灵活的哈希负载均衡方式，有一致性哈希（Consistent hashing）的特性。它使用的哈希键（key）是二进制形式的客户端IP地址（$binary_remote_addr）。一致性哈希的特点是，当增加或减少后端服务器时，只需重新分配一小部分请求，而不是所有请求，这有利于缓存命中率（Cache hit ratio）的维持和热点数据的控制。这种方式在负载均衡分配、数据分布和复制等方面有很好的应用。

总结，虽然ip_hash和hash $binary_remote_addr consistent 都是使用客户端IP为基础进行哈希负载均衡，但它们的应用场景和工作原理有所不同，并且hash $binary_remote_addr consistent 相比ip_hash具有更高的灵活性。