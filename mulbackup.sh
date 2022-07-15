#!/bin/sh
cfg=/etc/taos/taos.cfg
for ll in $(grep -iw datadir $cfg| grep -v '^#'|awk '{print $2"#"$3"#"$4}')
do
#    echo $ll
    path=$(echo $ll|awk -F '#' '{print $1}')
    level=$(echo $ll|awk -F '#' '{print $2}')
    priv=$(echo $ll|awk -F '#' '{print $3}')
    if [ $level -eq 0 ] & [ $priv -eq 1 ]
    then
        ppath=${path}
    fi
done

vid=0
for vid in $(ls $ppath/vnode/ | grep "vnode*")
do
    curfile=$ppath/vnode/$vid/tsdb/current
    for ll in $(grep -iw datadir $cfg| grep -v '^#'|awk '{print $2"#"$3"#"$4}')
    do
    path=$(echo $ll|awk -F '#' '{print $1}')
    level=$(echo $ll|awk -F '#' '{print $2}')
    priv=$(echo $ll|awk -F '#' '{print $3}')
        if [ $priv -ne 1 ]
        then
            echo "cp -f $curfile $path/vnode/$vid/tsdb/current"
            cp -f $curfile $path/vnode/$vid/tsdb/current
        fi
    done
done

