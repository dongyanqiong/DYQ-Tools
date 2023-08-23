#!/bin/sh
cat $1 |while read l
do
        uname=$(echo $l |awk '{print $1}')
        pass=$(echo $l |awk '{print $2}')
        ulpass=$(echo ${pass} | tr -d '\n' | xxd -plain | sed 's/\(..\)/%\1/g')
        curl "http://127.0.0.1:6041/rest/login/${uname}/${ulpass}" >token.tmp
        token=$(cat token.tmp |awk -F '"' '{print $6}')
        echo "$uname: $token" >> token_list.txt
done