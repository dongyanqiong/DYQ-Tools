#!/bin/sh
## 必须使用业务账号进行连通性测试，taosAdapter每个账号使用独立连接池
curl -utest:Tbase125_check -m 10 127.0.0.1:6041/rest/sql -d "show databases" 1>/dev/null 2>/dev/null

if [ $? -ne 0 ]
then
        st=$(date +'%Y-%m-%d %H:%M:%S')
        echo "$st Restart Adapter" > /root/curl_restult
        systemctl restart taosadapter
fi