#!/bin/sh
ntime=$(date +%s)
ctime=$(cat /root/curl_restult)

dtime=$(($ntime-$ctime))

if [ $dtime -gt 150 ]
then
        echo $(date) >>/root/restult.txt
        echo "ctime: $ctime diff: $dtime" >>/root/restult.txt
        echo "systemctl execute!" >>/root/restult.txt
        echo "" >> /root/restult.txt
        systemctl restart taosadapter
fi