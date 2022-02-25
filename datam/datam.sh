#!/bin/sh

tmpdir=/tmp
cfgfile=datam.cfg
mtype=$(grep -w 'mtype' $cfgfile | awk '{print $2}')
source_ip=$(grep -w 'source_ip' $cfgfile | awk '{print $2}')
source_user=$(grep -w 'source_user' $cfgfile | awk '{print $2}')
source_pass=$(grep -w 'source_pass' $cfgfile | awk '{print $2}')
source_db=$(grep -w 'source_db' $cfgfile | awk '{print $2}')
source_table=$(grep -w 'source_table' $cfgfile | awk '{print $2}')
dest_ip=$(grep -w 'dest_ip' $cfgfile | awk '{print $2}')
dest_user=$(grep -w 'dest_user' $cfgfile | awk '{print $2}')
dest_pass=$(grep -w 'dest_pass' $cfgfile | awk '{print $2}')
dest_db=$(grep -w 'dest_db' $cfgfile | awk '{print $2}')
dest_table=$(grep -w 'dest_table' $cfgfile | awk '{print $2}')

echo ""
echo "Source IP: $source_ip"
echo "Source Table: $source_table"
echo ""
echo "Dest IP:   $dest_ip"
echo "Dest Table:   $dest_table"
echo ""
echo "Type any key to Continue, or Ctrl+C exit"
read xxxx

###get table struc
csql=$(taos -h $source_ip -u $source_user -p$source_pass -s "show create table $source_db.$source_table\G;| grep 'Create Table:'| awk -F ':' '{print $NF}'" )

echo $csql

