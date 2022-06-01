#!/bin/bash
export LANG=en_US.UTF-8

###配置节点FQDN
tdnodes=(td11 td12 t13)

###root用户密码
password=taosdata

sshcheck()
{
    node=$1
    echo $node
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