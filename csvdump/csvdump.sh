#!/bin/sh
user=root
pass=taosdata
taos=taos
outdir='/tmp'
tblist=${outdir}/tblist
db=''
sqlh='select * from '
sqle=' where _c0>0 '

help(){
    echo "Dump Schema out:"
    echo "./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db01 -S"
    echo "Dump Data out:"
    echo "./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db01 -D"
    echo "Dump Data in:"
    echo "./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db01 -I"
    echo ""
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
    #导出建库语句
    dsql=$(${taos} -u${user} -p${pass} -s "show create database ${db}\G"|grep '^Create'|awk -F ':' '{print $NF}')
    if [ ${#dsql} -gt 1 ]
    then
        echo "${dsql}"  >${outdir}/db.sql
        echo "${db} dump out done."
        echo ""
        #导出超级表建表语句
        dn=1
        for stb in $(${taos} -u${user} -p${pass} -s "show ${db}.stables"|grep '|'|grep -v 'stable_name'|awk '{print $1}' )
        do
                ${taos} -u${user} -p${pass} -s "show create stable ${db}.${stb} \G"|grep '^Create'|awk -F ':' '{print $NF}' >>${outdir}/stb.sql
                echo "$dn \t${stb} \tdump out done."
                dn=$(($dn+1))
        done
        echo ""
        #导出子表/普通表建表语句
        tn=0
        #导出所有表
        #for tb in $(${taos} -u${user} -p${pass} -s "show ${db}.tables"|grep '|'|grep -v 'table_name'|awk '{print $1}' )
        #导出指定表
        for tb in $(cat $tblist)
        do
                csql=$(${taos} -u${user} -p${pass} -s "show create table ${db}.${tb} \G"|grep '^Create'|awk -F ':' '{print $NF}') 
                if [ ${#csql} -gt 1 ]
                then
                    echo "${csql}" >>${outdir}/tb.sql
                    tn=$(($tn+1))
                    echo "$tn \t${tb} \tdump out done."
                else
                    echo "  \t${tb} \tdump out ERROR!"
                fi
        done
        echo "## $tn tables dump out."
        echo ""
    else
        echo "Get DB $db Schema failed!"
    fi
}

dumpData(){
    num=0
    #导出所有表数据
    #for tb in $(${taos} -u${user} -p${pass} -s "show ${db}.tables"|grep '|'|grep -v 'table_name'|awk '{print $1}' )
    #导出指定表数据
    for tb in $(cat $tblist)
    do
        if [ -e ${outdir}/${tb}.csv ]
        then
            echo "${outdir}/${tb}.csv already exits!!"
            exit
        else
            sql=$(echo "$sqlh ${db}.${tb} $sqle >>${outdir}/${tb}.csv;")
            file_total=$(${taos} -u${user} -p${pass} -s "$sql"|grep 'OK' |awk '{print $3}' )
        #    echo "$tb" >> $tblist
            if [ $file_total ]
            then 
                num=$(($num+1))
                echo "$num \t${tb} \t $file_total rows dump out done."
            fi
        fi
    done
    echo "## $num tables dump out!!"
    echo ""
}

dumpIn(){
    num=0
    for tb in $(cat $tblist)
    do
        if [ -e ${outdir}/${tb}.csv ]
        then
            insert_total=$(${taos} -u${user} -p${pass} -s "insert into ${db}.${tb} file '${outdir}/${tb}.csv'" |grep 'OK' |awk '{print $3}')
            num=$(($num+1))
            echo "$num \t${tb} \t $insert_total rows dump in done!"
        else
            echo "${outdir}/${tb}.csv not found!!"
        fi
    done
    echo "## $num tables dump in!!"
    echo ""
}

if [ $# -eq 0 ]
then
    help
    exit
fi

while getopts 'u:p:f:o:d:SDI' opt
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
        echo "Begin dumpSchema ......"
        echo ""
        dumpSchema
        ;;
        D)
        echo "Begin dumpData ......"
        echo ""
        dumpData
        ;;
        I)
        echo "Begin dumpIn ......"
        echo ""
        dumpIn
        ;;
        *)
        help
        exit
    esac
done

