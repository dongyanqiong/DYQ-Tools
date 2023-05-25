#!/bin/sh
user=root
pass=taosdata
taos=taos
outdir='/tmp'
tblist=${outdir}/tblist
db=''

help(){
    echo "Dump Schema out:"
    echo "./csvdump.sh -u root -p taosdata -o /tmp/ -d db01 -S"
    echo "Dump Data out:"
    echo "./csvdump.sh -u root -p taosdata -o /tmp/ -d db01 -D"
    echo "Dump Data in:"
    echo "./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db01 -I"
    echo "-u username"
    echo "-p password"
    echo "-f tblist file"
    echo "-o outdir."
    echo "-d DBname "
    echo "-S Dump schema out."
    echo "-D Dump data out."
    echo "-I Dump data in."
}

dumpSchema(){
    ${taos} -u${user} -p${pass} -s "show create database ${db}\G"|grep '^Create'|awk -F ':' '{print $NF}' >${outdir}/db.sql
    if [ -s ${outdir}/db.sql ]
    then
        echo "${db} dump out done."
        echo ""
        dn=1
        for stb in $(${taos} -u${user} -p${pass} -s "show ${db}.stables"|grep '|'|grep -v 'stable_name'|awk '{print $1}' )
        do
                ${taos} -u${user} -p${pass} -s "show create stable ${db}.${stb} \G"|grep '^Create'|awk -F ':' '{print $NF}' >>${outdir}/stb.sql
                echo "$dn \t${stb} \tdump out done."
                dn=$(($dn+1))
        done
        echo ""
        tn=1
        for tb in $(${taos} -u${user} -p${pass} -s "show ${db}.tables"|grep '|'|grep -v 'table_name'|awk '{print $1}' )
        do
                ${taos} -u${user} -p${pass} -s "show create table ${db}.${tb} \G"|grep '^Create'|awk -F ':' '{print $NF}' >>${outdir}/tb.sql
                echo "$tn \t${tb} \tdump out done."
                tn=$(($tn+1))
        done
    else
        echo "Get DB $db Schema failed!"
    fi
}

dumpData(){
    sql1='select * from '
    sql2=' where _c0>0 '
    num=1
    for tb in $(${taos} -u${user} -p${pass} -s "show ${db}.tables"|grep '|'|grep -v 'table_name'|awk '{print $1}' )
    do
    sql=$(echo "$sql1 ${db}.${tb} $sql2 >>${outdir}/${tb}.csv;")
    ${taos} -u${user} -p${pass} -s "$sql" 1>/dev/null 2>/dev/null
    echo "$tb" >> $tblist
    echo "$num \t${tb} \tdump out done!"
    num=$(($num+1))
    done
}

dumpIn(){
    num=1
    for tb in $(cat $tblist)
    do
    ${taos} -u${user} -p${pass} -s "insert into ${db}.${tb} file '${outdir}/${tb}.csv'" 1>/dev/null 2>/dev/null

    echo "$num \t${tb} \t dump in done!"
    num=$(($num+1))
    done
}


while getopts ':u:p:f:o:d:SDI' opt
do
    case $opt in
        u)
        user=$OPTARG
        ;;
        p)
        pass=$OPTARG
        ;;
        o)
        outdir=$OPTARG
        ;;
        f)
        tblist=$OPTARG
        ;;
        d)
        db=$OPTARG
        ;;
        S)
        echo "dumpSchema"
        dumpSchema
        ;;
        D)
        echo "dumpData"
        dumpData
        ;;
        I)
        echo "dumpIn"
        dumpIn
        ;;
        *)
        help
        exit
    esac
done

