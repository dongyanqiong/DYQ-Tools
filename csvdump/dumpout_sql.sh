#!/bin/sh
db=db01
user=root
pass=taosdata
taos=taos

${taos} -u${user} -p${pass} -s "show create database ${db}\G"|grep '^Create'|awk -F ':' '{print $NF}' >db.sql
echo "${db} dump out done."

dn=1
for stb in $(${taos} -u${user} -p${pass} -s "show ${db}.stables"|grep '|'|grep -v 'stable_name'|awk '{print $1}' )
do
        ${taos} -u${user} -p${pass} -s "show create stable ${db}.${stb} \G"|grep '^Create'|awk -F ':' '{print $NF}' >>stb.sql
        echo "$dn ${stb} dump out done."
        dn=$(($dn+1))
done
tn=1
for tb in $(${taos} -u${user} -p${pass} -s "show ${db}.tables"|grep '|'|grep -v 'table_name'|awk '{print $1}' )
do
        ${taos} -u${user} -p${pass} -s "show create table ${db}.${tb} \G"|grep '^Create'|awk -F ':' '{print $NF}' >>tb.sql
        echo "$tn ${tb} dump out done."
        tn=$(($tn+1))
done