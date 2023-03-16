#!/bin/sh
days=864000

echo "Vnode      Time"
echo "==============="

lsof -p `pidof taosd`| grep REG|grep tsdb|awk '{print $NF}'|grep 'data$'| sort -n |while read ll
do
vn=$(echo $ll| awk -F 'vnode/' '{print $2}'|awk -F '/' '{print $1}')
tn=$(echo $ll| awk -F '/' '{print $NF}'|awk -F 'f' '{print $2}' |awk -F 'v' '{print $1}')
tt=$(($tn*$days))
dt=$(date -d @$tt +'%Y-%m-%d' )

echo "$vn $dt"

done |uniq|more