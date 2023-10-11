#!/bin/sh
days=864000

echo "Vnode      DateFile TimeRange"
echo "======    ========================"

lsof -p `pidof taosd`| grep REG|grep tsdb|awk '{print $NF}'|grep 'data$'| sort -n |while read ll
do
vn=$(echo $ll| awk -F 'vnode/' '{print $2}'|awk -F '/' '{print $1}')
tn=$(echo $ll| awk -F '/' '{print $NF}'|awk -F 'f' '{print $2}' |awk -F 'v' '{print $1}')
tt=$(($tn*$days))
te=$((($tn+1)*$days))
dt=$(date -d @$tt +'%Y-%m-%d' )
de=$(date -d @$te +'%Y-%m-%d' )
echo "$vn   \t$dt ~ $de"

done |sort -n|uniq|more