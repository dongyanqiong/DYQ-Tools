#!/bin/sh
curl -utest:Tbase125_check -m 10 127.0.0.1:6041/rest/sql -d "show databases" 1>/dev/null 2>/dev/null

if [ $? -ne 0 ]
then
        st=$(date +'%Y-%m-%d %H:%M:%S')
        echo "$st Restart Adapter" > /root/curl_restult
        systemctl restart taosadapter
fi