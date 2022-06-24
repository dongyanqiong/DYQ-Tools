#!/bin/bash
topdir=/TDinternal

pp(){
    echo $1
    echo $2

}

rpl() {
    kword=${1}
    file=${2}
    rword=${3}

    for i in $(grep -nw "${kword}" $file|grep -v "@${kword}" |grep -v "\/${kword}"|grep -v "\.${kword}"|grep -v "${kword}\.h"|grep -v "${kword}-"|awk -F ':' '{print $1}')
    do
        sed -i "${i}s/${kword}/${rword}/g" $file
        if [ $? -ne 0 ]
        then
            echo "sed -i \"${i}s/${kword}/${rword}/g\" $file"
        fi
    done
}

rpl2() {
    kword=${1}
    file=${2}
    rword=${3}

    for i in $(grep -nw "${kword}" $file|grep -v "@${kword}" |grep -v "\/${kword}"|grep -v "\.${kword}"|grep -v "${kword}\.h"|grep -v "${kword}-"|awk -F ':' '{print $1}')
    do
        sed -i "${i}s/${kword}/${rword}/g" $file
        if [ $? -ne 0 ]
        then
            echo "sed -i \"${i}s/${kword}/${rword}/g\" $file"
        fi
    done
}

replace(){
    kword=${1}
    rword=${2}
    for file in  $(grep -rw "${kword}" $topdir/* | awk -F ':' '{print $1}' |sort -n |uniq | grep -E "c$|h$|sh$|go$")
    do
       rpl "${kword}" $file "${rword}"
    done
}

replace2(){
    kword=${1}
    rword=${2}
    for file in  $(grep -rw "${kword}" $topdir/* | awk -F ':' '{print $1}' |sort -n |uniq | grep -E "c$|h$|sh$|go$")
    do
       rpl2 "${kword}" $file "${rword}"
    done
}

replace_pkg_ibkh(){
    for fl in $(grep -r 'Name="' $topdir/*  | awk -F ':' '{print $1}' | grep "sh$"|sort -n |uniq)
    do
        for  fln in $(grep -n 'Name="' $fl | awk -F ':' '{print $1}')
        do
            sed -i "s/Name=\"taosdump/Name=\"ibkhdump/g" $fl
            sed -i "s/Name=\"taosdemo/Name=\"ibkhdemo/g" $fl
            sed -i "s/Name=\"taosadapter/Name=\"ibkhadapter/g" $fl
            sed -i "s/Name=\"taosBenchmakr/Name=\"ibkhBenchmark/g" $fl
            sed -i "s/Name=\"taostools/Name=\"ibkhtools/g" $fl
            sed -i "s/Name=\"taos/Name=\"ibkh/g" $fl
            sed -i "s/Name=\"taos\.tar\.gz/Name=\"ibkh\.tar\.gz/g" $fl
            sed -i "s/Name=\"taos/Name=\"ibkh/g" $fl
        done            
    done
}

replace_mkg_ibkh(){
    cfile=${topdir}/community/src/kit/taos-tools/src/CMakeLists.txt
    sed -i "s/taosBenchmark /ibkhBenchmark /g" $cfile
    sed -i "s/taosdump /ibkdump /g" $cfile

    cfile=${topdir}/community/src/kit/taos-tools/CMakeLists.txt
    sed -i "s/taosBenchmark/ibkhBenchmark/g" $cfile
    sed -i "s/taosdump/ibkdump/g" $cfile

    cfile=${topdir}/community/src/kit/shell/CMakeLists.txt
    sed -i "s/OUTPUT_NAME taos/OUTPUT_NAME ibkh/g"  $cfile
    
    cfile=${topdir}/community/src/dnode/CMakeLists.txt
    sed -i "s/taos\.cfg/ibkhistory\.cfg/g" $cfile
    echo "SET_TARGET_PROPERTIES(taosd PROPERTIES OUTPUT_NAME ibkhd)" >> $cfile
}

replace_mkg_ibkh
replace_pkg_ibkh
replace TDengine iBKHistory
replace TDengine- iBKHistory-
replace taosdata historydata
replace taosc  ibkh
replace 'taos>' 'ibkh>'
replace 'taos\.cfg' 'ibkh\.cfg'
replace 'support@taosdata\.com'  'bkdgyy@ustb\.edu\.cn'
replace 'TAOS Data, Inc' 'Engineering Research Institute of USTB Co\.,Ltd'
replace 'www\.taosdata\.com' 'iet\.ustb\.edu\.cn'
replace 'TAOS Data,' 'Engineering Research Institute of USTB Co\.,Ltd/g'
replace 'taos connect' 'ibkh connect' 
replace 'taos client' 'ibkh client'
replace 'defaultPasswd=\"taosdata\"' 'defaultPasswd=\"historydata\"'
replace '\/etc\/taos' '\/etc\/ibkh' 
replace '\/var\/log\/taos' '\/var\/log\/ibkh'
replace '\/var\/lib\/taos' '\/var\/lib\/ibkh'
replace '\/usr\/local\/taos' '\/usr\/local\/ibkh'
replace2 'taoslog/ibkhlog'
replace2 'taosdlog/ibkhdlog'
replace2 'taosinfo/ibkhinfo'
replace2 'taos_history/ibkh_his'
replace2 'rmtaos/rmibkh'
replace taosd ibkhd
replace taos  ibkh
replace 'taosadapter_' 'ibkadapter_'


