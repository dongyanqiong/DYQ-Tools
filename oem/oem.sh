#!/bin/sh
BDIR=/TDengine

filetype=(c h sh go json)

rpl() {
    kword=$1
    file=$2
    rword=$3

    for i in $(grep -nw $kword $file|grep -v "@$kword" |grep -v "\/$kword"|grep -v "\.$kword"|grep -v "$kword\.h"|grep -v "$kword-"|awk -F ':' '{print $1}')
    do
        sed -i "${i}s/$kword/$rword/g" $file
    done
}

replace_ibkh(){
    echo "begin  code replace... $(date)"
    for ty in ${filetype[@]}
    do
        for fl in $(find $BDIR -type f -name "*.$ty" )
        do
            rpl TDengine $fl iBKHistory
            rpl taosdata $fl historydata
            rpl taosc $fl ibkh
            rpl 'taos>' $fl 'ibkh>'
            rpl 'taos\.cfg' $fl 'ibkh\.cfg'
            rpl 'support@taosdata\.com' $fl 'bkdgyy@ustb\.edu\.cn'
            sed -i 's/TAOS Data, Inc/Engineering Research Institute of USTB Co\.,Ltd/g' $fl
            sed -i 's/TAOS Data,/Engineering Research Institute of USTB Co\.,Ltd/g' $fl 
            sed -i 's/taos connect/ibkh connect/g' $fl
            sed -i 's/taos client/ibkh client/g' $fl
            sed -i 's/defaultPasswd="taosdata"/defaultPasswd="historydata"/g' $fl
            sed -i 's/\/etc\/taos/\/etc\/ibkh/g' $fl
            sed -i 's/\/var\/log\/taos/\/var\/log\/ibkh/g' $fl
            sed -i 's/\/var\/lib\/taos/\/var\/lib\/ibkh/g' $fl
            sed -i 's/taoslog/ibkhlog/g' $fl
            sed -i 's/taosdlog/ibkhdlog/g' $fl
            sed -i 's/taosinfo/ibkhinfo/g' $fl
            rpl taosd $fl ibkhd
    #        sed -i "s/prompt_size = 6/prompt_size = 12/g" $fl
        done
    done
    echo "code replace done $(date)"

    echo "begin sh replace ... $(date)"
    for fl in $(find $BDIR -type f -name "*.sh" |xargs grep -n 'Name="'| awk -F ':' '{print $1}'|sort -n |uniq)
    do
        for fln in $(grep -n 'Name="' $fl | awk -F ':' '{print $1}')
        do
            sed -i "${fln}s/taosdump/ibkhdump/g" $fl
            sed -i "${fln}s/taosdemo/ibkhdemo/g" $fl
            sed -i "${fln}s/taosadapter/ibkhadapter/g" $fl
            sed -i "${fln}s/taosBenchmakr/ibkhBenchmark/g" $fl
            sed -i "${fln}s/taostools/ibkhtools/g" $fl
            sed -i "${fln}s/taos/ibkh/g" $fl
            sed -i "${fln}s/taos\.tar\.gz/ibkh\.tar\.gz/g" $fl
            sed -i "${fln}s/taos/ibkh/g" $fl
            sed -i "${fln}s/taos/ibkh/g" $fl
        done
    done
    echo  "sh replace done $(date)"

}

replace_ibkh
