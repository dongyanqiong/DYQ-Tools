#!/bin/bash

###代码根目录
topdir=/TDinternal
varfile=./$1.cfg


TDengine=$(grep '^TDengine=' $varfile|awk -F '=' '{print $NF}')
taos=$(grep '^taos=' $varfile|awk -F '=' '{print $NF}')
taosc=$(grep '^taosc=' $varfile|awk -F '=' '{print $NF}')
taosshell=$(grep '^taosshell=' $varfile|awk -F '=' '{print $NF}')
etctaos=$(grep '^etctaos=' $varfile|awk -F '=' '{print $NF}')
logtaos=$(grep '^logtaos=' $varfile|awk -F '=' '{print $NF}')
libtaos=$(grep '^libtaos=' $varfile|awk -F '=' '{print $NF}')
localtaos=$(grep '^libtaos=' $varfile|awk -F '=' '{print $NF}')
taoscfg=$(grep '^taoscfg=' $varfile|awk -F '=' '{print $NF}')
taosd=$(grep '^taosd=' $varfile|awk -F '=' '{print $NF}')
taosdata=$(grep '^taosdata=' $varfile|awk -F '=' '{print $NF}')
taosdemo=$(grep '^taosdemo=' $varfile|awk -F '=' '{print $NF}')
taosdump=$(grep '^taosdump=' $varfile|awk -F '=' '{print $NF}')
rmtaos=$(grep '^rmtaos=' $varfile|awk -F '=' '{print $NF}')
taostools=$(grep '^taostools=' $varfile|awk -F '=' '{print $NF}')
taosBenchmark=$(grep '^taosBenchmark=' $varfile|awk -F '=' '{print $NF}')
taosadapter=$(grep '^taosadapter=' $varfile|awk -F '=' '{print $NF}')
taoslog=$(grep '^taoslog=' $varfile|awk -F '=' '{print $NF}')
taosdlog=$(grep '^taosdlog=' $varfile|awk -F '=' '{print $NF}')
taosinfo=$(grep '^taosinfo=' $varfile|awk -F '=' '{print $NF}')
taos_history=$(grep '^taos_history=' $varfile|awk -F '=' '{print $NF}')
web=$(grep '^web=' $varfile|awk -F '=' '{print $NF}')
copyright=$(grep '^copyright=' $varfile|awk -F '=' '{print $NF}')
email=$(grep '^email=' $varfile|awk -F '=' '{print $NF}')
wTDengine=$(grep '^wTDengine=' $varfile|awk -F '=' '{print $NF}')



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
            sed -i "s/Name=\"taosBenchmark/Name=\"${taosBenchmark}/g" $fl
            sed -i "s/Name=\"taostools/Name=\"${taostools}/g" $fl
            sed -i "s/serverName=\"taosd/serverName=\"${taosd}/g" $fl
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
    sed -i "s/taos\.cfg/${taoscfg}/g" $cfile
    echo "SET_TARGET_PROPERTIES(taosd PROPERTIES OUTPUT_NAME ${taosd})" >> $cfile

    sed -i "s/taos/${taos}/g" ${topdir}/community/packaging/tools/release_note

    num=$(grep -n 'adapterName\.toml' ${topdir}/community/packaging/tools/makepkg.sh | grep productName | awk -F ':' '{print $1}')
    sed -i "${num}s/\${productName}/${taos}/g" ${topdir}/community/packaging/tools/makepkg.sh
}

replace_adapter_ibkh(){
    replace 'taosadapter_' "${taosadapter}_"
    replace3 '\/etc\/taos\/taosadapter\.toml' "\/etc\/${etctaos}\/${taosadapter}\.toml"
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

replace_win_ibkh(){
   for file in $(grep -rn "C:/TDengine/" $topdir/* | grep '\.c:'|awk -F ':' '{print $1}')
   do
	sed -i "s/TDengine/${wTDengine}/g" $file
   done
}


###修改taosc的提示符长度
prompt(){
    cfile=${topdir}/community/src/kit/shell/src/shellEngine.c
    plen=$((${#taosshell}+2))
    if [ $plen -gt 6 ]
    then
        sed -i "s/prompt_size = 6/prompt_size = $plen/g" $cfile
    fi

    cfile=${topdir}/community/src/client/src/tscSystem.c
    clen=$((${#taoslog}+4))
    if [ $clen -gt 12 ]
    then
        sed -i "s/tscLogFileName\[12\]/tscLogFileName\[$clen\]/g" $cfile

    fi
}

####生成配置文件
create_cfg(){
    cfgname=$(echo $taoscfg|sed 's/\///g')
    cfgfile=${topdir}/enterprise/packaging/cfg/${cfgname}
    servicefile=${topdir}/enterprise/packaging/cfg/${taosd}.service
    cp -f ${topdir}/community/packaging/cfg/taos.cfg  ${cfgfile}
    cp -f ${topdir}/community/packaging/cfg/taosd.service ${servicefile}
    sed -i "s/TDengine/${TDengine}/g" ${cfgfile}
    sed -i "s/\/var\/log\/taos/\/var\/log\/${logtaos}/g" ${cfgfile}
    sed -i "s/\/var\/lib\/taos/\/var\/lib\/${libtaos}/g" ${cfgfile}
    sed -i "s/support@taosdata\.com/${email}/g" ${cfgfile}
    sed -i "s/taos/${taos}/g" ${cfgfile}

    sed -i "s/TDengine/${TDengine}/g" ${servicefile} 
    sed -i "s/taosd/${taosd}/g" ${servicefile} 
    sed -i "s/taos/${taos}/g" ${servicefile} 
}


#####Main###########
replace_mkg_ibkh
replace_pkg_ibkh
replace_adapter_ibkh
replace_web_ibkh
replace_win_ibkh

###修改代码
replace TDengine ${TDengine}
replace TDengine- ${TDengineq}-
replace taosdata ${taosdata}
replace taosc  ${taosc}
replace 'taos>' "${taosshell}>"
replace3 'taos\.cfg' "${taoscfg}"
replace 'support@taosdata\.com'  ${email}
replace 'TAOS Data, Inc' "${copyright}"
replace 'www\.taosdata\.com' ${web}
replace 'TAOS Data,' ${copyright}
replace 'taos connect' "${taos} connect"
replace 'taos client' "${taos} client"
replace 'defaultPasswd=\"taosdata\"' "defaultPasswd=\"${taosdata}\""
replace '\/etc\/taos' "\/etc\/${etctaos}"
replace '\/var\/log\/taos' "\/var\/log\/${logtaos}"
replace '\/var\/lib\/taos' "\/var\/lib\/${libtaos}"
replace '\/usr\/local\/taos' "\/usr\/local\/${localtaos}"
replace3 taoslog ${taoslog}
replace3 taosdlog ${taosdlog}
replace3 taosinfo ${taosinfo}
replace3 taos_history ${taos_history}
replace3 rmtaos ${rmtaos}
replace taosd ${taosd}

prompt
create_cfg
