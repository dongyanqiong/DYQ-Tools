#!/bin/sh
dbname='iot_prod'
tbpre='t_inverter_'

taos -s "SET MAX_BINARY_DISPLAY_WIDTH 60;show $dbname.tables" >>show$$.txt
grep ${tbpre} show$$.txt | awk -F '|' '{print $1","$6","$7}' |sed 's/ //g' >>tblist$$.txt
awk -F ',' '{print $2","$3}' tblist$$.txt |sort -n |uniq -c |sort -n >>uniq$$.txt
grep '^      2' uniq$$.txt  |awk '{print $NF}' >>tid$$.txt
for i in $(cat tid$$.txt); do grep -w $i tblist$$.txt ; done |awk -F ',' '{print $1}' >>invalid_table$$.txt