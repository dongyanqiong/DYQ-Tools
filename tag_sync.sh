#!/bin/sh
db=$1
stb=$2
taos=prodbc
shost=172.16.216.154
dhost=172.16.216.154
suser=root
spass=taosdata
duser=root
dpass=taosdata


echo "DBname:$db    Stable:$stb"
echo "Begin...."
${taos} -u$suser -p${spass} -h $shost -s "desc $db.$stb "|grep 'TAG'|awk '{print $1}' >$stb.tags
echo "Get stable tags done!"

${taos} -u$suser -p$spass -h $shost -s "select tbname from  $db.$stb limit 10000;"|grep '|'|grep -v ' tbname '|awk '{print $1}' |sort -n |uniq >$stb.tblist
echo "Get table table list done!"

echo "use $db;" > $stb.select.sql
sql="select tbname,"
for tg in $(cat $stb.tags)
do
	sql=$(echo "$sql $tg,")
done
sql=$(echo "$sql"|sed s'/.$//')

echo ""
echo "Begin Create select tag sql..."
tbn=0
for tb in $(cat $stb.tblist)
do	
	sqlt=$(echo "$sql from $db.$stb where tbname='$tb';")
	echo "$sqlt" >> $stb.select.sql
	tbn=$(($tbn+1))
	if [ $(($tbn%1000)) -eq 0 ]
	then
		echo -n "."
	fi
done
echo ""

echo "Begin get table tag value..."
if [ $tbn -gt 1000 ]
then
	split -1000 -d $stb.select.sql $stb.part_
else
	cp $stb.select.sql $stb.part_00
fi

echo "use $db;" >$stb.value.src
echo "use $db;" >$stb.value.des
for sqlfile in $(ls $stb.part_*)
do
${taos} -u$suser -p$spass -h $shost -f $sqlfile |grep '|' | grep -v ' tbname ' |sed 's/ //g' >> $stb.value.src
echo "Get Src $sqlfile  done."
${taos} -u$duser -p$dpass -h $dhost -f $sqlfile |grep '|' | grep -v ' tbname ' |sed 's/ //g' >> $stb.value.des
echo "Get Des $sqlfile  done."
done


echo "Get table tag values done!"
echo ""
#echo "Begin create alter sql..."

#echo "use $db;" > $stb.alter.sql
#for tb in $(cat $stb.tblist)
#do	
#	ii=0
#	for v in $(grep -w $tb $stb.value|tail -1|sed 's/|/\n/g') 
#	do
#		tvalue[$ii]=$v
#		ii=$(($ii+1))
#	done
#	ii=1
#	for tg in $(cat $stb.tags)
#	do
#		echo "alter table $db.$tb set tag $tg='${tvalue[ii]}';" >>$stb.alter.sql
#		ii=$(($ii+1))	
#	done
#done

echo ""
echo "Begin Check tag diff..."

src=$stb.value.src
des=$stb.value.des


ii=0
for v in $(cat $stb.tags) 
do
	key[$ii]=$v
	ii=$(($ii+1))
done


sql="select tbname,"
for ((i=0;i<${#key[@]};i++))
do
        sql=$(echo "$sql ${key[$i]},")
done
sql=$(echo "$sql"|sed s'/.$//')

echo "use $db;" >$stb.diff.sql
for tb in $(diff $src $des |grep '|'|awk '{print $2}'|awk -F '|' '{print $1}'|sort -n |uniq )
do
	sqlt=$(echo "$sql from $db.$stb  where tbname='$tb' \G") 
	echo $sqlt >>$stb.diff.sql
done


${taos} -u$suser -p$spass -h $shost -f $stb.diff.sql  > $stb.value.diff


for tb in $(diff $src $des |grep '|'|awk '{print $2}'|awk -F '|' '{print $1}'|sort -n |uniq)
do
	grep -w "tbname: $tb" -A ${#key[@]} $stb.value.diff|grep -v 'tbname'|while read ll
	do
		kk=$(echo $ll|awk -F ':' '{print $1}')
		vv=$(echo $ll|awk  '{print $2}')
		echo "alter table $db.$tb set tag $kk='$vv';"
	done
	echo ""
done

echo "Check Done !!!"
#END

