#!/bin/bash

###代码根目录
topdir=/TDinternal

###替代的变量
TDengine=iBKHistory
taos=ibkh
taosc=ibkh
taosd=ibkhd
taosdata=historydata
taosdemo=ibkhdemo
taosdump=ibkdump
rmtaos=rmibkh
taostools=ibkhtools
taosBenchmark=ibkhBenchmark
taosadapter=ibkhadapter
taoslog=ibkhlog
taosdlog=ibkhdlog
taosinfo=ibkhinfo
taos_history=ibkh_his
web='iet\.ustb\.edu\.cn'
copyright='Engineering Research Institute of USTB Co\.,Ltd'
email='bkdgyy@ustb\.edu\.cn'




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

replace3(){
    kword=${1}
    rword=${2}
    for file in  $(grep -rw "${kword}" $topdir/* | awk -F ':' '{print $1}' |sort -n |uniq | grep -E "c$|h$|sh$|go$")
    do
       sed -i "s/${kword}/${rword}/g" $file
    done
}

###修改打包文件
replace_pkg_ibkh(){
    for fl in $(grep -r 'Name="' $topdir/*  | awk -F ':' '{print $1}' | grep "sh$"|sort -n |uniq)
    do
        for  fln in $(grep -n 'Name="' $fl | awk -F ':' '{print $1}')
        do
            sed -i "s/Name=\"taosdump/Name=\"${taosdump}/g" $fl
            sed -i "s/Name=\"taosdemo/Name=\"${taosdemo}/g" $fl
            sed -i "s/Name=\"taosadapter/Name=\"${taosadapter}/g" $fl
            sed -i "s/Name=\"taosBenchmakr/Name=\"${taosBenchmark}/g" $fl
            sed -i "s/Name=\"taostools/Name=\"${taostools}/g" $fl
            sed -i "s/Name=\"taos/Name=\"${taos}/g" $fl
            sed -i "s/Name=\"taos\.tar\.gz/Name=\"${taos}\.tar\.gz/g" $fl
            sed -i "s/Name=\"taos/Name=\"${taos}/g" $fl
        done            
    done
}

replace_mkg_ibkh(){
    cfile=${topdir}/community/src/kit/taos-tools/src/CMakeLists.txt
    sed -i "s/taosBenchmark /${taosBenchmark} /g" $cfile
    sed -i "s/taosdump /${taosdump} /g" $cfile

    cfile=${topdir}/community/src/kit/taos-tools/CMakeLists.txt
    sed -i "s/taosBenchmark/${taosBenchmark}/g" $cfile
    sed -i "s/taosdump/${taosdump}/g" $cfile

    cfile=${topdir}/community/src/kit/shell/CMakeLists.txt
    sed -i "s/OUTPUT_NAME taos/OUTPUT_NAME ${taos}/g"  $cfile
    
    cfile=${topdir}/community/src/dnode/CMakeLists.txt
    sed -i "s/taos\.cfg/${taos}\.cfg/g" $cfile
    echo "SET_TARGET_PROPERTIES(taosd PROPERTIES OUTPUT_NAME ${taosd})" >> $cfile

    sed -i "s/taos/${taos}/g" ${topdir}/community/packaging/tools/release_note

    sed -i "152s/\${productName}/${taos}/g" ${topdir}/community/packaging/tools/makepkg.sh
}

replace_adapter_ibkh(){
    replace 'taosadapter_' "${taosadapter}_"
    replace3 '\/etc\/taos\/taosadapter\.toml' "\/etc\/${taos}\/${taosadapter}\.toml"
    sed -i "2a replace github.com/taosdata/taosadapter => ../../../../community/src/plugins/taosadapter" ${topdir}/enterprise/src/plugins/taosainternal/go.mod
} 

replace_web_ibkh(){
    for file in  $(find  $topdir/enterprise/src/plugins/web/ -type f -name "*.html")
    do
       sed -i "s/TDengine/${TDengine}/g" $file
       sed -i "s/TAOS Data/${copyright}/g" $file
       sed -i "s/www\.taosdata\.com/${web}/g" $file
    done
}

###修改taosc的提示符长度
prompt(){
    cfile=${topdir}/community/src/kit/shell/src/shellEngine.c
    plen=$((${#taos}+2))
    if [ $plen -gt 6 ]
    then
        sed -i "s/prompt_size = 6/prompt_size = $plen/g" $cfile
    fi
}

replace_mkg_ibkh
replace_pkg_ibkh
replace_adapter_ibkh
replace_web_ibkh

###修改代码
replace TDengine ${TDengine}
replace TDengine- ${TDengineq}-
replace taosdata ${taosdata}
replace taosc  ${taosc}
replace 'taos>' "${taos}>"
replace3 'taos\.cfg' "${taos}\.cfg"
replace 'support@taosdata\.com'  ${email}
replace 'TAOS Data, Inc' "${copyright}"
replace 'www\.taosdata\.com' ${web}
replace 'TAOS Data,' ${copyright}
replace 'taos connect' "${taos} connect"
replace 'taos client' "${taos} client"
replace 'defaultPasswd=\"taosdata\"' "defaultPasswd=\"${taosdata}\""
replace '\/etc\/taos' "\/etc\/${taos}"
replace '\/var\/log\/taos' "\/var\/log\/${taos}"
replace '\/var\/lib\/taos' "\/var\/lib\/${taos}"
replace '\/usr\/local\/taos' "\/usr\/local\/${taos}"
replace3 taoslog ${taoslog}
replace3 taosdlog ${taosdlog}
replace3 taosinfo ${taosinfo}
replace3 taos_history ${taos_history}
replace3 rmtaos ${rmtaos}
replace taosd ${taosd}

prompt


