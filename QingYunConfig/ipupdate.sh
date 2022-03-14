#!/bin/sh

file=/tmp/metadata.info
curl http://metadata/self > $file

cp -f /etc/hosts /etc/hosts.bak
grep '^127' /etc/hosts.bak > /etc/hosts
grep 'metadata' /etc/hosts.bak > /etc/hosts

for i in $(grep '/ip' $file | grep role_name | awk '{print $NF}'|sort -n)
do
    hname=$(grep $i $file| grep role_name|awk -F '/' '{print $4}')
    if [ $hname ]
    then
        echo "$i $hname" >>/etc/hosts
    fi
done
