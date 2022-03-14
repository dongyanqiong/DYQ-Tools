
#!/bin/sh
mkdir -p /data/taos/{data,log,core,soft,tmp,dump}

file=/etc/taos/metadata.info
curl http://metadata/self > $file

for i in $(grep '/ip' $file | grep role_name | awk '{print $NF}'|sort -n)
do
    hname=$(grep $i $file| grep role_name|awk -F '/' '{print $4}')
    if [ $hname ]
    then
        echo "$i $hname" >>/etc/hosts
    fi
done