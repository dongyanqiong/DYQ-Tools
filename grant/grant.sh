#!/bin/sh
##taosGrant -expire 2022-06-06 -k 7YF73zuPPLq0HZkGgTC3dNtG

while getopts ":e:k:" opt
do
    case $opt in
    e)
    et=$OPTARG
    ;;
    k)
    mc=$OPTARG
    ;;
    *)
    echo "Invild Argument"
    exit
    ;;
    esac
done

#echo "#machineCode $mc"
echo "$(date +%s) $et $mc " >> grantlog.log
echo "$et$mc"|md5sum|awk '{print $1}'