#!/bin/sh
taos=prodbc
user=root
pass=taosdata
#host=172.16.216.154
db=$1

echo "Begin taos Check ..."
${taos} -u$user -p$pass  -k -2147482112 -d $db -T 2 1>/dev/null
echo "taos Check done!"
echo ""
echo "Begin get tables ..."
${taos} -u$user -p$pass  -s "set max_binary_display_width 60; show $db.tables" | grep '|'|grep -v ' table_name '|sed 's/ //g' >$db.alltblist
echo "Get $db all tables done."
echo ""
echo "Beging check ..."
echo "use $db;" > $db.drop.sql
for vtid in $(awk -F '|' '{print "|"$6"|"$7"|"}' $db.alltblist |sort -n |uniq -c| grep -v ' 1 '| awk '{print $2}') 
do
	grep $vtid $db.alltblist|while read ll
	do
		echo "$ll"
		tb=$(echo $ll |awk -F '|' '{print $1}')
		echo "drop table $db.$tb;" >>$db.drop.sql
		
	done
	echo ""

done
echo "Check done!"
echo ""

tchecknum=$(($(wc -l tb0.sql|awk '{print $1}')+$(wc -l tb1.sql|awk '{print $1}')))
dchecknum=$(($(wc -l $db.drop.sql|awk '{print $1}')-1))

echo "taos Check Result:$tchecknum"
echo "dupl Check Result:$dchecknum"

#END
