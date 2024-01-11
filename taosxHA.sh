#!/bin/sh
tmm=prodbx
keyw=tmq_oilwell
dir='/root/tmq2'
tmqs=$(echo "${dir}/tmq_oilwell.sh")
outf=$(echo "${dir}/oilwell.out")

ps -ef |grep prodbx|grep -v grep|grep ${keyw} 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
    nohup sh ${tmqs} > ${outf} &
fi 