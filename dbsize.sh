#!/bin/sh
user=root
pass=taosdata

taos -u${user} -p${pass} -s "show databases\G"|grep 'name:' |awk '{print $NF}' |grep -v '_schema'> dblist.tmp
#echo "Get DBlist Done!"
cat -v dblist.tmp | sed 's/\^M//g' >dblist
rm -f dblist.tmp
cat dblist |while read db
do
        taos -u${user} -p${pass} -s "show ${db}.vgroups\G"|grep -E 'vgId|vgroup_id'|awk '{print $NF}' >${db}_vg.tmp
        cat -v ${db}_vg.tmp | sed 's/\^M//g' >${db}.vglist
        rm -f ${db}_vg.tmp
        #echo "Get ${db} vglist Done!"
        if [ -s ${db}.vglist ]
        then
                echo > ${db}.size
                cat ${db}.vglist|while read vid
                do
                        for ddir in $(grep -i datadir /etc/taos/taos.cfg|grep -v '#'|awk '{print $2}')
                        do
                                if [ -d ${ddir}/vnode/vnode${vid} ]
                                then
                                vgsize=$(find ${ddir} -type d -name "vnode${vid}" |xargs du -s |awk '{print $1}')
                                echo "${db}.vnode${vid} ${vgsize}" >>${db}.size
                                fi
                        done
                done
                echo "${db}  $(cat ${db}.size|awk '{sum+=$2} END {print sum/1024/1024 " GB"}')"
        fi
done