#!/bin/bash
export LANG=en_US.UTF-8
wab='\033[47;30m'
NC='\033[0m'

###配置节点FQDN
tdnodes=(test1 )

###root用户密码
password=taosdata

pdesc()
{
    echo
    echo "----------------------$1---------------------"
    echo

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
taosBenchmark -d db01 -t 4000 -n 100 1>/dev/null 2>/dev/null 
if [ $? -eq 0 ]
then
    mesg Init_Demo_Data OK
else
    mesg Init_Demo_Data ERROR
    exit
fi

for dnode in ${tdnodes[@]}
do
    #ssh $dnode  systemctl stop taosd
    sleep 5
    taos -uroot -p$password -s "show dnodes;" | grep offline 1>/dev/null 2>/dev/null 
    if [ $? -ne 0 ]
    then
        exit
    fi


done

pdesc 'END'