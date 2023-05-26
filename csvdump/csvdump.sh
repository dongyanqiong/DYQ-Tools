#!/bin/sh
user=root
pass=taosdata
taos=taos
outdir='/tmp'
tblist=${outdir}/tblist
db=''
batch=20000
sqlh='select ts,current,voltage from '
sqle=' where _c0>0  '

help(){
    echo ""
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
    echo "-b Batch size "
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
        echo "DB_Name   Info" 
        echo "----------   -----------------------" 
        echo "DB:${db}         Schema dump out done."
        echo ""
        #导出超级表建表语句
        echo "No    Stable     Info" 
        echo "---   --------  -------------------" 
        dn=1
        for stb in $(${taos} -u${user} -p${pass} -s "show ${db}.stables"|grep '|'|grep -v 'stable_name'|awk '{print $1}' )
        do
                ${taos} -u${user} -p${pass} -s "show create stable ${db}.${stb} \G"|grep '^Create'|awk -F ':' '{print $NF}' >>${outdir}/stb.sql
                echo "$dn \t${stb} \tdump out done." 
                dn=$(($dn+1))
        done
        echo ""
        #导出子表/普通表建表语句
        echo "No    Table      Info" >> ${outdir}/csvdump.log
        echo "---   --------  -------------------" >> ${outdir}/csvdump.log
        tn=0
        #导出所有表
        #for tb in $(${taos} -u${user} -p${pass} -s "show ${db}.tables"|grep '|'|grep -v 'table_name'|awk '{print $1}' )
        #导出指定表
        for tb in $(cat $tblist)
        do
            #    csql=$(${taos} -u${user} -p${pass} -s "show create table ${db}.${tb} \G"|grep '^Create'|awk -F ':' '{print $NF}') 
            #    if [ ${#csql} -gt 1 ]
            #    then
            #        echo "${csql}" >>${outdir}/tb.sql
            #        tn=$(($tn+1))
            #        echo "$tn \t${tb} \tdump out done." >> ${outdir}/csvdump.log
            #        echo -n '.'
            #    else
            #        echo "  \t${tb} \tdump out ERROR!"
            #    fi
            echo "show create table ${db}.${tb} \G;" >>${outdir}/${db}.get_table.sql
            tn=$(($tn+1))
        done
        echo "Create Get SQL Done!"
        ${taos} -u${user} -p${pass} -f ${outdir}/${db}.get_table.sql |grep '^Create Table'|awk -F ':' '{print $NF}' >>${outdir}/tb.sql
        echo ""
        sql_count=$(wc -l ${outdir}/tb.sql |awk '{print $1}')
        echo "## ${sql_count}/${tn} tables dump out."
        echo ""
    else
        echo "Get DB $db Schema failed!"
    fi
}

dumpData(){
    num=0
    echo "Dump SQL : $sqlh ${db}.TABLENAME $sqle >> ${outdir}/TABLENAME.csv;"
    echo ""
    echo "No    Table      Info" >> ${outdir}/csvdump.log
    echo "---   --------  -------------------" >> ${outdir}/csvdump.log
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
                echo "$num \t${tb} \t $file_total rows dump out done." >> ${outdir}/csvdump.log
                echo -n '.'
            fi
        fi
    done
    echo ""
    echo "## $num tables dump out!!"
    echo ""
}

dumpIn(){
    num=0
    echo "No    Table      Info" >> ${outdir}/csvdump.log
    echo "---   --------  -------------------" >> ${outdir}/csvdump.log
    for tb in $(cat $tblist)
    do
        bt=$(date +%s)
        if [ -e ${outdir}/${tb}.csv ]
        then
            file_count=$(wc -l ${outdir}/${tb}.csv |awk '{print $1}')
            if [ $file_count -lt $batch ]
            then
                insert_total=$(${taos} -u${user} -p${pass} -s "insert into ${db}.${tb} file '${outdir}/${tb}.csv'" |grep 'OK' |awk '{print $3}')
                if [ $insert_total ]
                then 
                    num=$(($num+1))
                    et=$(date +%s)
                    echo "$num \t${tb} \t $insert_total rows dump in done! Cost $((${et}-${bt})) s." >> ${outdir}/csvdump.log
                    echo -n "."
                else
                    echo "   \t${tb} \t  dump in ERROR!"
                fi
            else
                #对大文件按照batch进行切割导入
                mkdir ${outdir}/${tb}
                cp ${outdir}/${tb}.csv ${outdir}/${tb}/
                cd  ${outdir}/${tb}
                split -${batch} -d ${tb}.csv part_
                total_rows=0
                for csv in $(ls part_*)
                do
                    insert_total=$(${taos} -u${user} -p${pass} -s "insert into ${db}.${tb} file '${outdir}/${tb}/${csv}'" |grep 'OK' |awk '{print $3}')
                    if [ $insert_total ]
                    then 
                        total_rows=$(($total_rows+$insert_total))
                    else
                        echo "   \t${tb} \t  dump in ERROR!"
                    fi                
                done
                    num=$(($num+1))
                    et=$(date +%s)
                    echo "$num \t${tb} \t $total_rows rows dump in done! Cost $(($et-$bt)) s." >> ${outdir}/csvdump.log
                    echo -n "."
                cd ${outdir}
                rm -rf ${outdir}/${tb}
            fi
        else
            echo "${outdir}/${tb}.csv not found!!"
        fi
    done
    echo ""
    echo "## $num tables dump in!!"
    echo ""
}

if [ $# -eq 0 ]
then
    help
    exit
fi

runlevel=U
while getopts 'u:p:f:o:d:b:SDI' opt
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
        b)
        batch=$OPTARG
        ;;
        S)
        runlevel=S
        ;;
        D)
        runlevel=D
        ;;
        I)
        runlevel=I
        ;;
        *)
        help
        exit
    esac
done

case $runlevel in 
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