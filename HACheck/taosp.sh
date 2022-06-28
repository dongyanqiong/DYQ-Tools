#!/bin/bash

vnodedir=/var/lib/taos/vnode

if [ $(pidof taosd) ]
then
    exit
else
    find $vnodedir/ -type f -name "wal*" --delete
fi

systemctl start taosd