#!/bin/sh
while true
do
taos -s "show dnodes" |grep '6030' | grep -v 'version not match' |grep -i offline
RS=$?
if [ $RS -ne 0 ]
then
		break;
fi
done
