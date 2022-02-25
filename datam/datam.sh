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
csql=$(taos -h $source_ip -u $source_user -p$source_pass -s "show create table $source_db.$source_table\G;"| grep 'Create Table:'| awk -F '(' '{print $NF ";"}' )
csql=$(echo "create table $dest_db.$dest_table ($csql")

taos -h $dest_ip -u $dest_user -p$dest_pass -s "$csql" | grep 'Query OK' 1>/dev/null 2>/dev/null
rt=$?
if [ $rt -ne 0 ]
then
	echo ""
	echo "Cannot Create table $dest_db.$dest_table at $dest_ip"
	exit;
fi

datafile=$(echo "$tmpdir/$source_table".csv)

echo ""
echo "Begine dump out data........"
taos -h $source_ip -u $source_user -p$source_pass -s "select * from $source_db.$source_table >> $datafile;" 1>/dev/null 
echo "Dump out done."

sed -i '1d' $datafile
echo ""
echo "Begin dump in data......"
taos -h $dest_ip -u $dest_user -p$dest_pass -s "insert into $dest_db.$dest_table file '$datafile';" 1>/dev/null 

rm -f $datafile

echo "Dump in over."
echo ""


