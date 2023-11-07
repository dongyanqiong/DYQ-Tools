#!/bin/sh
user='root'
pass='taosdata'

nprint()
{
        for i in $(seq $1)
        do
                echo -n "$2"
        done
}

file=$$.tmp
taos -u${user} -p${pass} -s "show vnodes"|grep -E "follower|leader"|awk -F '|' '{print $1"\t"$4}' >>$file
echo "DnodeID  Followert  Leader"
echo "======================================="
for did in $(cat $file |awk '{print $1}'|sort -n|uniq)
do
        f_c=$(grep -w ${did} $file |grep follower|wc -l)
        l_c=$(grep -w ${did} $file |grep leader|wc -l)
        #echo -n "dnode:$did \t follower:${f_c} \t leader:${l_c}"
        echo -n "$did        ${f_c}          ${l_c}     "
        nprint ${l_c} '+'
        nprint ${f_c} '-'
        echo ""
done
rm $file