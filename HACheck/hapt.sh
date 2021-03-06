#!/bin/bash
#---------------------------------
###配置节点FQDN
tdnodes=(c0-11 c0-12 c0-13)
###Tdengine root用户密码
password=taosdata
###初始数据副本数
repl=3
###初始数据表数量
tnum=10000
###初始数据单表记录数
rnum=100
#---------------------------------

export LANG=en_US.UTF-8
wab='\033[47;30m'
NC='\033[0m'

pdesc()
{
    echo
    echo "----------------------$1---------------------"
    echo

}

mprint()
{

    strN=$1
    strLen=$((50-$(echo $strN|wc -L)))
    echo -n  "$strN "
    for ((ll=1;ll<$strLen;ll++))
    do
        echo -n  "."
    done
}

mesg()
{
    RED='\033[0;31m'
    GREEN='\033[1;32m'
    NC='\033[0m'
    mName=$1
    mType=$2  
    case $mType in
    "OK")
        echo -e "${GREEN} $(mprint $mName) OK ${NC}" 
        ;;
    "ERROR")
        echo -e "${RED} $(mprint $mName) ERROR ${NC}"
        ;;
    *)
    echo " $@"
    ;;
    esac
}

sshcheck()
{
    node=$1
    ssh $node hostname 1>/dev/null 2>/dev/null
    rt=$?
    if [ $rt -ne 0 ]
    then
        echo "Please maker sure SSH Trust has been configured on $node!"
        exit
    fi
}


os=$(cat /etc/os-release| grep PRETTY_NAME | awk '{print $1}'|awk -F '=' '{print $2}' | sed 's/"//g')
if [ $os = 'Ubuntu' ]
then
    echo "You should run this script by bash!"
    echo "/bin/bash preCheck.sh"
    echo ""
elif [ $os = 'CentOS' -o $os = 'Red' ] 
then
    echo ""
else
    echo "The script not support this OS."
fi

for dnode in ${tdnodes[@]}
do
    sshcheck $dnode
done

pdesc 'BEGIN'

###Create demo data
echo "Performance Test "
echo "taosBenchmark -uroot -p$password -d db01 -a $repl -t $tnum -n $rnum "
taosBenchmark -uroot -p$password -d db01 -a $repl -t $tnum -n $rnum -y 1>/dev/null 2>/dev/null 
if [ $? -eq 0 ]
then
    mesg Performance_Test OK
else
    mesg Performance_Test ERROR
    exit
fi

echo -e "\033[1;32m \n$(tail -5 output.txt |grep -v '^$') \033[0m"
echo " "
echo "Cluster HA Test"
tid=11
for dnode in ${tdnodes[@]}
do
    echo "$dnode:"
    tbname=$(echo "db01.test_"$tid)
    ssh $dnode  "systemctl stop taosd"  1>/dev/null 2>/dev/null
    sleep 15
    taos -uroot -p$password -s "show dnodes\G;" | grep status|grep offline 1>/dev/null 2>/dev/null 
    if [ $? -ne 0 ]
    then
        mesg "$dnode:Stoped" ERROR 
        exit
    else
        mesg "$dnode:Stoped" OK
    fi
    qcheck=$(taos -uroot -p$password -s "select count(*) as sum from db01.d11\G;" | grep 'sum:' |awk '{print $2}')
    if [ $qcheck -eq $rnum ]
    then
        mesg "$dnode:Query" OK
        taos -uroot -p$password -s "create table $tbname (ts timestamp,v1 int);" 1>/dev/null 2>/dev/null
        if [ $? -eq 0 ]
        then
            mesg "$dnode:Create_Table" OK
        else
            mesg "$dnode:Create_Table" ERROR
            exit
        fi
        taos -uroot -p$password -s "insert into $tbname values(1643811742000,2222);" 1>/dev/null 2>/dev/null 
        if [ $? -eq 0 ]
        then
            mesg "$dnode:Insert" OK
        else
            mesg "$dnode:Insert" ERROR
            exit
        fi
        icheck=$(taos -uroot -p$password -s "select v1 from $tbname where ts=1643811742000 \G;"| grep 'v1:'|awk '{print $2}')
        if [ $icheck -eq 2222 ]
        then
            mesg "$dnode:Query" OK
            mesg "$dnode:HACheck" OK
        else
            mesg "$dnode:Query" ERROR
            exit
        fi
    else
        mesg "$dnode:Query" ERROR
        exit
    fi
    ssh $dnode  "systemctl start taosd"  1>/dev/null 2>/dev/null
    st=0
    while true
    do
        st=$(($st+1))
        taos -uroot -p$password -s "show dnodes\G;" | grep status|grep offline 1>/dev/null 2>/dev/null
        if [ $? -ne 0 ]
        then
            mesg "$dnode:Start" OK
            break
        fi
        sleep 5
        if [ $st -eq 10 ]
        then
            mesg "$dnode:Start" ERROR
            exit
        fi
    done
    tid=$(($tid+100))
    echo ""
done
echo ""
mesg HACheck OK


pdesc 'END'