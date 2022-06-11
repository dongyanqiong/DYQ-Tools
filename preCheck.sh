#!/bin/bash
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en

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


softlist=(curl gdb tmux fio iperf3 iostat netstat bpftrace)
diskSize=10000000

wab='\033[47;30m'
NC='\033[0m'


if [ $os = 'Ubuntu' ]
then
    liblist=(libdl.so libm.so librt.so libpthread.so libc.so) 
elif [ $os = 'CentOS' -o $os = 'Red' ] 
then
    liblist=(libdl.so libm.so librt.so libpthread.so libc.so libstdc++.so libgcc_s.so) 
else
    echo "The script not support this OS."
fi


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

libCheck()
{
    lbName=$1
    if [ $os = 'Ubuntu' ]
    then
        libdir='/lib/x86_64-linux-gnu/'
    else
        libdir='/usr/lib*/'
    fi
    ls ${libdir} | grep $lbName 1>/dev/null 2>/dev/null 
    RS=$?
    if [ $RS -eq 0 ]
    then   
        mesg $lbName OK 
    else
        mesg $lbName  ERROR
    fi    
    
    
}

softCheck()
{
    softName=$1
    type -p $softName 1>/dev/null 2>/dev/null
    RS=$?
    if [ $RS -eq 0 ]
    then   
        mesg $softName OK 
    else
        mesg $softName  ERROR
    fi

}

selinuxCheck()
{
    getV=$(getenforce)
    cfgV=$(grep -v '^#' /etc/selinux/config| grep 'SELINUX=' | awk -F '=' '{print $2}'| tr 'a-z' 'A-Z')
    if [ $getV == 'Disabled' ] && [ $cfgV == 'DISABLED' ]
    then
        mesg SELinux OK
    else
        mesg SELinux ERROR
    fi
}

hostnameCheck()
{
    if [ $HOSTNAME == 'localhost' ]
    then
        mesg hostname ERROR
    else
        grep $HOSTNAME /etc/hosts 1>/dev/null 2>/dev/null
        RS=$?
        if [ $RS -eq 0 ]
        then
            mesg Hostname OK
        else
            mesg Hostname ERROR 
        fi
    fi
}

coreCheck()
{
    limV=$(ulimit -a| grep 'core file size'| awk '{print $NF}')
    if [ $limV == 'unlimited' ]
    then
        mesg Core OK
    else
        mesg Core ERROR
    fi

}
limitCheck()
{
    echo
    echo "OS Limits.............."
    echo "##/etc/systemd/system.conf"
    grep -v '^#' /etc/systemd/system.conf| grep -E "NOFILE|NPROC"
    echo
    echo "##sysctl"
    sysctl -a 2>/dev/null | grep -E "pid_max|nr_open|wmem_max|rmem_max"
    echo
    echo "##limits.conf" 
    grep -v '^#'  /etc/security/limits.conf | grep -E "nofile|nproc"|sed 's/\t\t/\t/g'
    
}

fwCheck()
{
    systemctl list-unit-files | grep firewalld 1>/dev/null 2>/dev/null 
    RS=$?
    if [ $RS -ne 0 ]
    then
        mesg Firewall OK
    else
        st=$(systemctl status firewalld| grep 'Active:' | awk '{print $2}')
        if [ $st == 'active' ]
        then
            mesg Firewall ERROR
        else
            mesg Firewall OK
        fi
    fi
}

timeCheck()
{
    #mesg timezone $(date +'%Z %z')
    if [ $(pidof ntpd) ]
    then
        mesg NTP OK
    else
        mesg NTP ERROR
    fi
}

zoneCheck()
{
    echo
    echo "TimeZone................"
    mesg timezone $(date +'%Z %z')
    echo
}

diskCheck()
{
    df -l -t ext4 -t xfs -t ext3 | grep -v boot | grep -v 'Filesystem'|while read line
    do
        avSize=$(echo $line |awk '{print $4}')
        mPoint=$(echo $line |awk '{print $6}')
        if [ $avSize -lt $diskSize ]
        then
            mesg $mPoint ERROR
        else
            mesg $mPoint OK
        fi
    done
}

sysCheck()
{
    echo
    echo "OS Configs.............."
    echo 
    tmpfile=/tmp/sysctl$$
    sysctl -a > $tmpfile 2>/dev/null
    nr_hugepages=$(grep -w 'vm.nr_hugepages' $tmpfile |awk '{print $NF}')
    if [ $nr_hugepages -eq 0 ]
    then
        mesg nr_hugepages OK
    else
        mesg nr_hugepages ERROR
    fi

    swappiness=$(grep -w 'vm.swappiness' $tmpfile |awk '{print $NF}')
    if [ $swappiness -eq 0 ]
    then
        mesg swappiness ERROR
    else
        mesg swappiness OK
    fi   

    overcommit_memory=$(grep -w 'vm.overcommit_memory' $tmpfile |awk '{print $NF}')
    if [ $overcommit_memory -eq 0 ]
    then
        mesg overcommit_memory OK
    else
        mesg overcommit_memory ERROR
    fi 

    overcommit_ratio=$(grep -w 'vm.overcommit_ratio' $tmpfile |awk '{print $NF}')
    if [ $overcommit_ratio -eq 0 ]
    then
        mesg overcommit_ratio ERROR
    else
        mesg overcommit_ratio OK
    fi 

    dirty_background_ratio=$(grep -w 'vm.dirty_background_ratio' $tmpfile |awk '{print $NF}')
    if [ $dirty_background_ratio -eq 0 ]
    then
        mesg dirty_background_ratio ERROR
    else
        mesg dirty_background_ratio OK
    fi 

    dirty_ratio=$(grep -w 'vm.dirty_ratio' $tmpfile |awk '{print $NF}')
    if [ $dirty_ratio -eq 0 ]
    then
        mesg dirty_ratio ERROR
    else
        mesg dirty_ratio OK
    fi 


    rm -f $tmpfile
}




###Main####
#clear
pdesc 'BEGIN'
echo -e "${wab} $(mprint 'Libray Check')${NC}"
for lb in ${liblist[@]}
do
    libCheck $lb
done

echo
echo -e "${wab} $(mprint 'OS Config Check')${NC}"
if [ $os = 'CentOS' -o $os = 'Red' ]
then
    selinuxCheck
fi

hostnameCheck
coreCheck
fwCheck
timeCheck

echo
echo -e "${wab} $(mprint 'Software Check')${NC}"
for soft in ${softlist[@]}
do
    softCheck $soft
done
echo
echo -e "${wab} $(mprint 'Disk Usage Check')${NC}"
diskCheck

echo 
echo -e "${wab} $(mprint 'Other Config Check')${NC}"
sysCheck
zoneCheck
limitCheck


pdesc 'END'
