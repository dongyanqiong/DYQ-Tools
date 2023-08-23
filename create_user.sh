#!/bin/sh
cat $1 |while read l
do
        uname=$(echo $l |awk '{print $1}')
        pass=$(echo $l |awk '{print $2}')
	echo "create user $uname pass '${pass}' ;"
done
