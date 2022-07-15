#!/bin/sh
bfile=$1
file=tmp$$.txt
cfile=/etc/taos/taos.cfg
dfile=dfile$$.txt
tfile=tfile$$.txt
touch $dfile
touch $tfile

for i in $(grep -iw ^dataDir $cfile |awk '{print $3}'|sort -n |uniq)
do
	l=1
	grep -iw ^dataDir $cfile|while read line 
	do
		cjb=$(echo $line|awk '{print $3}')
		pth=$(echo $line|awk '{print $2}')
		if [ $cjb -eq $i ]
		then
			echo "$cjb:$l:$pth" >> $dfile
			l=$(($l+1))
		fi
	done
done


hexdump -e '128/1 "%02x"' $bfile > $file

for i in $(grep 766e6f6465 $file | sed 's/000000000000000000000000/\n/g'| grep 766e6f64652f)
do
dj=$(echo $i|awk -F '766e6f64652f' '{print $1 }' )
df=$(echo $i|awk -F '766e6f64652f' '{print $2}' |xxd -r -ps|cut -c 1-30)
len=${#dj}
if [ $len -lt 20 ]
then
	jb=$(echo $dj|rev|cut -c 5-6|rev)
	gz=$(echo $dj|rev|cut -c 3-4|rev)
	jb=$(($((16#$jb))/2))
	gz=$((($((16#$gz))/2)+1))
	fpth=$(grep "$jb:$gz" $dfile |awk -F ':' '{print $NF}')
	echo -e "\n$fpth:$df\n" >> $tfile
fi

done

for d in $(grep '/' $tfile |awk -F ':' '{print $1}'|sort -n|uniq)
do
	echo $d
	grep $d $tfile | awk -F '/' '{print "\t"$NF}'
	echo -e "\n "
done
echo ""
rm -f $file
rm -f $dfile
rm -f $tfile




