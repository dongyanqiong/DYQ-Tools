#!/bin/sh
tr=$(echo $1| sed 's/0x//g')
ll=$(echo $tr|wc -L)

if [ $ll -gt 8 ]
then
	echo "invalid input "
	exit
fi

if [ $ll -eq 7 ]
then
	str=$(echo "0$tr")
else
	str=$tr
fi

str1=$(echo $str|cut -c 1-2)
str2=$(echo $str|cut -c 3-4)
str3=$(echo $str|cut -c 5-6)
str4=$(echo $str|cut -c 7-9)


echo "$((0x$str4)).$((0x$str3)).$((0x$str2)).$((0x$str1))"
