
```bash
curl -o /dev/null -s -w %{time_connect}:%{time_starttransfer}:%{time_namelookup}:%{time_total}\\n   192.168.3.60:6041/rest/sql -d "select server_version()"
```

-o表示输出结果到/dev/null，-s表示去除状态信息，-w表示列出后面的参数的结果。

curl命令支持的参数，有如下

time_connect        建立到服务器的 TCP 连接所用的时间，单位s

time_starttransfer  在发出请求之后,Web 服务器返回数据的第一个字节所用的时间，单位s

time_total          完成请求所用的时间，单位s

time_namelookup    DNS解析时间,从请求开始到DNS解析完毕所用时间(记得关掉 Linux 的 nscd 的服务测试)，单位s

speed_download      下载速度，单位-字节每秒。