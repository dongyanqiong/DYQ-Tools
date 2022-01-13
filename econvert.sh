#!/bin/sh
errcode=$1
code1=$(echo $1|sed 's/-//g')
code2=$(echo "obase=2;$code1"|bc)
code3=$(echo $code2|sed 's/0/A/g')
code4=$(echo $code3|sed 's/1/0/g')
code5=$(echo $code4|sed 's/A/1/g')
code6=$(echo $code5|cut -c 13-31)
code7=$(echo "obase=16;ibase=2;$code6"|bc)
echo "ErrorCode: $(($code7+1))"
grep $(($code7+1)) taoserror.h
