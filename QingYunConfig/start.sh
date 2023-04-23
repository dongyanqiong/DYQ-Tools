#!/bin/sh

cp -f /etc/taos/taos.cfg.tmpl /etc/taos/taos.cfg

file=/etc/taos/metadata.info
curl http://metadata/self > $file

firstep=$(grep '/sid' $file | grep role_name | grep 1$|head -1 | awk -F '/' '{print $4":6030"}')

sed -i "1i firstEp $firstep "  /etc/taos/taos.cfg
sed -i "2i fqdn $HOSTNAME " /etc/taos/taos.cfg

sed -i 's/\/var\/log\/taos/\/data\/taos\/log/g'  /etc/taos/taosadapter.toml

if [ $(pidof taosd) ]
then
    exit
else
    systemctl start taosd && systemctl enable taosd
    systemctl start taosadapter && systemctl enable taosadapter
fi

firstname=$(echo $firstep|awk -F ':' '{print $1}')

if [ $HOSTNAME != $firstname ]
then
    sleep 30
    sql=$(echo "create dnode \"$HOSTNAME:6030\";")
    taos -s "$sql"
fi
