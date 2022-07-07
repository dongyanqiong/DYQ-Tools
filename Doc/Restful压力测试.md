# <center>Restful 压力测试 </center>

## 1.ab
ab 是 apachebench 命令的缩写，ab 是 apache 自带的压力测试工具。ab 可以对不同类型服务器进行压力测试。比如nginx、tomcat、IIS等。

ab 能够创建多个并发线程，占用的资源非常少。

### 1.1.安装
```bash
#CentOS
yum install httpd-tools

#Ubuntu
apt install apache2-utils

```

### 1.2.测试


```shell
##参数解读

-n requests
#执行的请求个数。 

-c concurrency
#一次产生的请求个数。

-H custom-header
#对请求附加额外的头信息。 

-p POST-file
#需要POST的数据的文件.

-k 
#启用HTTP KeepAlive功能，在一个HTTP会话中执行多个请求。

```


```bash
#query.sql
select last_row(*) from db01.meters ;
```

```bash
ab -n 10000 -c 10 -k -H "Authorization: Basic cm9vdDp0YW9zZGF0YQ==" -p query.sql  http://192.168.0.11:6041/rest/sql
```

```bash
Concurrency Level:      10
Time taken for tests:   46.756 seconds
Complete requests:      10000
Failed requests:        0
Write errors:           0
Total transferred:      3030000 bytes
Total body sent:        2140000
HTML transferred:       2000000 bytes
Requests per second:    213.88 [#/sec] (mean)
Time per request:       46.756 [ms] (mean)
Time per request:       4.676 [ms] (mean, across all concurrent requests)
Transfer rate:          63.29 [Kbytes/sec] received
                        44.70 kb/s sent
                        107.98 kb/s total

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0  14.2      0    1002
Processing:    10   46  12.8     45     198
Waiting:        9   41  11.9     40     175
Total:         10   47  19.0     45    1048

Percentage of the requests served within a certain time (ms)
  50%     45
  66%     50
  75%     53
  80%     55
  90%     61
  95%     67
  98%     77
  99%     88
 100%   1048 (longest request)

```





## 2.JMeter
Apache JMeter 是 Apache 组织基于 Java 开发的压力测试工具，用于对软件做压力测试。

JMeter 最初被设计用于 Web 应用测试，但后来扩展到了其他测试领域，可用于测试静态和动态资源，如静态文件、Java 小服务程序、CGI 脚本、Java 对象、数据库和 FTP 服务器等等。

### 2.1.安装
JMete 是基于 Java 开发的，使用前需求先安装 Java。

下载地址：https://jmeter.apache.org/download_jmeter.cgi

解压缩所安装包，执行运行可执行文件即可

```bash
tar xvzf apache-jmeter-5.4.3.tar.gz
cd apache-jmeter-5.4.3
sh jmeter.sh 
```


### 2.2.测试
按照以下顺序创建一个测试任务

```bash
├── 1 测试计划
    ├── 2 线程组
    │   └── 7 HTTP请求
    ├── 3 HTTP信息头管理
    ├── 4 汇总报告
    ├── 5 聚合报告
    └── 6 用表格查看结果

```

#### 参数设置
##### 线程组
线程数：10
Ramp-Up时间（秒）：1
循环测试：1000

```qutoa
如果要增加并发量，可以将 Ramp-Up 设置为 0（默认是1）。 
```

##### HTTP信息头管理器
名称：Authorization
值：Basic cm9vdDp0YW9zZGF0YQ==

##### HTTP请求
服务器或IP：192.168.0.11
端口：6041
HTTP请求：POST
路径：/rest/sql
消息体数据：select last_row(*) from db01.meters;

#### 进行测试
```bash
./jmeter -n -t test.jmx
```