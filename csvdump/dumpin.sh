#!/bin/sh
db=db02
user=root
pass=taosdata
taos=taos
tblist=$1

num=1
for tb in $(cat $tblist)
do
${taos} -u${user} -p${pass} -s "insert into ${db}.${tb} file '${tb}.csv'" 1>/dev/null 2>/dev/null

echo "$num ${tb} dump out done!"
num=$(($num+1))
done