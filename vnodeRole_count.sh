#!/bin/sh
file=$$.tmp
taos -s "show vnodes"|grep -E "follower|leader"|awk -F '|' '{print $1"\t"$4}' >>$file
for did in $(cat $file |awk '{print $1}'|sort -n|uniq)
do
        f_c=$(grep -w ${did} $file |grep follower|wc -l)
        l_c=$(grep -w ${did} $file |grep leader|wc -l)
        echo "dnode:$did \t follower:${f_c} \t leader:${l_c}"
done
rm $file