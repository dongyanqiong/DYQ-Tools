#!/bin/sh

curl -utest:Tbase125_check -m 10 127.0.0.1:6041/rest/sql -d "show databases"|grep succ 1>/dev/null 2>/dev/null

if [ $? -eq 0 ]
then
        st=$(date +%s)
        echo $st > /root/curl_restult
else
        echo "ERROR!"
fi