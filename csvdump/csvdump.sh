#!/bin/sh
user=root
pass=taosdata
taos=taos
host=localhost
outdir='/tmp'
tblist=${outdir}/tblist
db=''
batch=20000000
sqlh='select * from '
sqle=' where _c0>0  '

help(){
    echo -e  ""
    echo -e  "Dump Schema out:"
    echo -e  "./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db01 -S"
    echo -e  "Dump Data out:"
    echo -e  "./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db01 -D"
    echo -e  "Dump Data in:"
    echo -e  "./csvdump.sh -u root -p taosdata -o /tmp/ -f /tmp/tblist -d db01 -I"
    echo -e  ""
    echo -e  "-u username"
    echo -e  "-p password"
    echo -e  "-h host"
    echo -e  "-f tblist file"
    echo -e  "-o outdir."
    echo -e  "-d DBname "
    echo -e  "-b Batch size "
    echo -e  "-S Dump schema out."
    echo -e  "-D Dump data out."
    echo -e  "-I Dump data in."
}

dumpSchema(){
    #导出建库语句
    dsql=$(${taos} -u${user} -p${pass} -h ${host} -s "show create database ${db}\G"|grep '^Create'|awk -F ':' '{print $NF}')
    if [ ${#dsql} -gt 1 ]
    then
        echo -e  "${dsql}"  >${outdir}/db.sql
        echo -e  "DB_Name   Info" 
        echo -e  "----------   -----------------------" 
        echo -e  "DB:${db}         Schema dump out done."
        echo -e  ""
        #导出超级表建表语句
        echo -e  "No    Stable     Info" 
        echo -e  "---   --------  -------------------" 
        dn=1
        for stb in $(${taos} -u${user} -p${pass} -h ${host} -s "show ${db}.stables"|grep '|'|grep -v 'stable_name'|awk '{print $1}' )
        do
                ${taos} -u${user} -p${pass} -h ${host} -s "show create stable ${db}.${stb} \G"|grep '^Create'|awk -F ':' '{print $NF}' >>${outdir}/stb.sql
                echo -e  "$dn \t${stb} \tdump out done." 
                dn=$(($dn+1))
        done
        echo -e  ""
        #导出子表/普通表建表语句
        echo -e  "## $(date +'%Y-%m-%d %H:%M:%S')" >> ${outdir}/csvdump.log
        echo -e  "No    Table      Info" >> ${outdir}/csvdump.log
        echo -e  "---   --------  -------------------" >> ${outdir}/csvdump.log
        tn=0
        #导出所有表
        #for tb in $(${taos} -u${user} -p${pass} -s "show ${db}.tables"|grep '|'|grep -v 'table_name'|awk '{print $1}' )
        #导出指定表
        for tb in $(cat $tblist)
        do
            #    csql=$(${taos} -u${user} -p${pass} -s "show create table ${db}.${tb} \G"|grep '^Create'|awk -F ':' '{print $NF}') 
            #    if [ ${#csql} -gt 1 ]
            #    then
            #        echo -e  "${csql}" >>${outdir}/tb.sql
            #        tn=$(($tn+1))
            #        echo -e  "$tn \t${tb} \tdump out done." >> ${outdir}/csvdump.log
            #        echo -e  -n '.'
            #    else
            #        echo -e  "  \t${tb} \tdump out ERROR!"
            #    fi
            echo -e  "show create table ${db}.${tb} \G;" >>${outdir}/${db}.get_table.sql
            tn=$(($tn+1))
        done
        echo -e  "Create Get SQL Done!"
        ${taos} -u${user} -p${pass} -h ${host} -f ${outdir}/${db}.get_table.sql |grep '^Create Table'|awk -F ':' '{print $NF}' >>${outdir}/tb.sql
        echo -e  ""
        sql_count=$(wc -l ${outdir}/tb.sql |awk '{print $1}')
        echo -e  "## ${sql_count}/${tn} tables dump out."
        echo -e  ""
    else
        echo -e  "Get DB $db Schema failed!"
    fi
}

dumpData(){
    tbt=$(date +%s)
    num=0
    echo -e  "Dump SQL : $sqlh ${db}.TABLENAME $sqle >> ${outdir}/TABLENAME.csv;"
    echo -e  ""
    echo -e  "## $(date +'%Y-%m-%d %H:%M:%S')" >> ${outdir}/csvdump.log
    echo -e  "No    Table      Info" >> ${outdir}/csvdump.log
    echo -e  "---   --------  -------------------" >> ${outdir}/csvdump.log
    #导出所有表数据
    #for tb in $(${taos} -u${user} -p${pass} -s "show ${db}.tables"|grep '|'|grep -v 'table_name'|awk '{print $1}' )
    #导出指定表数据
    for tb in $(cat $tblist)
    do
        bt=$(date +%s)
        if [ -e ${outdir}/${tb}.csv ]
        then
            echo -e  "${outdir}/${tb}.csv already exits!!"
            exit
        else
            sql=$(echo -e  "$sqlh ${db}.${tb} $sqle >>${outdir}/${tb}.csv;")
            file_total=$(${taos} -u${user} -p${pass} -h ${host} -s "$sql"|grep 'OK' |awk '{print $3}' )
        #    echo -e  "$tb" >> $tblist
            if [ $file_total ]
            then 
                et=$(date +%s)
                num=$(($num+1))
                echo -e  "$num \t${tb} \t $file_total rows dump out done. Cost $(($et-$bt)) s." >> ${outdir}/csvdump.log
                echo -e  -n '.'
            fi
        fi
    done
    tet=$(date +%s)
    echo -e  ""
    echo -e  "## $num tables dump out!! Cost $(($tet-$tbt)) s."
    echo -e  ""
}

dumpIn(){
    tbt=$(date +%s)
    num=0
    echo -e  "## $(date +'%Y-%m-%d %H:%M:%S')" >> ${outdir}/csvdump.log
    echo -e  "No    Table      Info" >> ${outdir}/csvdump.log
    echo -e  "---   --------  -------------------" >> ${outdir}/csvdump.log
    for tb in $(cat $tblist)
    do
        bt=$(date +%s)
        if [ -e ${outdir}/${tb}.csv ]
        then
            file_count=$(wc -l ${outdir}/${tb}.csv |awk '{print $1}')
            if [ $file_count -lt $batch ]
            then
                insert_total=$(${taos} -u${user} -p${pass} -h ${host} -s "insert into ${db}.${tb} file '${outdir}/${tb}.csv'" |grep 'OK' |awk '{print $3}')
                if [ $insert_total ]
                then 
                    num=$(($num+1))
                    et=$(date +%s)
                    echo -e  "$num \t${tb} \t $insert_total rows dump in done! Cost $((${et}-${bt})) s." >> ${outdir}/csvdump.log
                    echo -e  -n "."
                else
                    echo -e  "   \t${tb} \t  dump in ERROR!"
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
                    insert_total=$(${taos} -u${user} -p${pass} -h ${host} -s "insert into ${db}.${tb} file '${outdir}/${tb}/${csv}'" |grep 'OK' |awk '{print $3}')
                    if [ $insert_total ]
                    then 
                        total_rows=$(($total_rows+$insert_total))
                    else
                        echo -e  "   \t${tb} \t  dump in ERROR!"
                    fi                
                done
                    num=$(($num+1))
                    et=$(date +%s)
                    echo -e  "$num \t${tb} \t $total_rows rows dump in done! Cost $(($et-$bt)) s." >> ${outdir}/csvdump.log
                    echo -e  -n "."
                cd ${outdir}
                rm -rf ${outdir}/${tb}
            fi
        else
            echo -e ""
            echo -e  "${outdir}/${tb}.csv not found!!"
        fi
    done
    tet=$(date +%s)
    echo -e  ""
    echo -e  "## $num tables dump in!! Cost $(($tet-$tbt)) s."
    echo -e  ""
}

if [ $# -eq 0 ]
then
    help
    exit
fi

runlevel=U
while getopts 'u:p:f:o:d:h:b:SDI' opt
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
        h)
        host=$OPTARG
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
    echo -e  "Begin dumpSchema ......"
    echo -e  ""
    dumpSchema
    ;;
    D)
    echo -e  "Begin dumpData ......"
    echo -e  ""
    dumpData
    ;;
    I)
    echo -e  "Begin dumpIn ......"
    echo -e  ""
    dumpIn
    ;;
    *)
    help
    exit
esac