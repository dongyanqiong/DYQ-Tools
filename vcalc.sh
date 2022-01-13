#!/bin/sh
user=root
pass=taosdata
 
 
for i in $(taos -u $user -p$pass -s "show databases;" | grep '|' | grep -vw 'update'|grep -vw log|sed -e 's/ //g'|awk -F '|' '{print $1"+"$4*$5"+"$5}')
do
        db=$(echo $i|awk -F '+' '{print $1}')
        vg=$(echo $i|awk -F '+' '{print $2}')
        rl=$(echo $i|awk -F '+' '{print $3}')
        echo "====Database:$db Vgroups:$vg ===="
        echo  "Node   Num"
        if [ $rl -eq 1 ]
        then
                for l in  $(taos  -u $user -p$pass -s "show $db.vgroups" | grep '|'| grep -vw 'vgId'| sed -e 's/ //g'|awk -F '|' '{print $5}')
                do
                        echo $l
                done  | grep -v '0' |sort -n |uniq -c | awk '{print $2"\t"$1}'
        fi
 
 
        if [ $rl -eq 2 ]
        then
                for l in  $(taos  -u $user -p$pass -s "show $db.vgroups" | grep '|'| grep -vw 'vgId'| sed -e 's/ //g'|awk -F '|' '{print $5" "$7}')
                do
                        echo $l
                done  | grep -v '0' |sort -n |uniq -c | awk '{print $2"\t"$1}'
        fi
 
 
        if [ $rl -eq 3 ]
        then
                for l in  $(taos  -u $user -p$pass -s "show $db.vgroups" | grep '|'| grep -vw 'vgId'| sed -e 's/ //g'|awk -F '|' '{print $5" "$7" "$9}')
                do
                        echo $l
                done  | grep -v '0' |sort -n |uniq -c | awk '{print $2"\t"$1}'
        fi
 
        echo ""
done
