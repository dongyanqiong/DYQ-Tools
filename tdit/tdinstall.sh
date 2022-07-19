#!/bin/sh
pkg=$1
cfg=/etc/taos/taos.cfg
adpcfg=/etc/taos/taosadapter.toml
logDir=/data/taos/log
dataDir=/data/taos/data
tempDir=/data/taos/tmp
coreDir=/data/taos/core

if [ $# -ne 1 ]
then
    echo "./install.sh  TDengine-enterprise-server-2.4.0.14-Linux-x64.tar.gz "
    exit
fi

cfgCreate(){
    cp $cfg $cfg.$(date +%s)
    rm -f $cfg
    echo " firstEp                     $(hostname):6030 " >>  $cfg 
    echo " #secondEp                    node2:6030 " >>  $cfg 
    echo " fqdn                        $(hostname) " >>  $cfg 
    echo " #arbitrator                  node2:6042 " >>  $cfg 
    echo " logDir                      ${logDir} " >>  $cfg 
    echo " dataDir                     ${dataDir} " >>  $cfg 
    echo " tempDir                     ${tempDir} " >>  $cfg 
    echo " numOfThreadsPerCore         2.0 " >>  $cfg 
    echo " ratioOfQueryCores           2.0 " >>  $cfg 
    echo " numOfCommitThreads          8.0 " >>  $cfg 
    echo " minTablesPerVnode           1000 " >>  $cfg 
    echo " tableIncStepPerVnode        1000 " >>  $cfg 
    echo " maxVgroupsPerDb             8 " >>  $cfg 
    echo " keepColumnName              1 " >>  $cfg 
    echo " balance                     0 " >>  $cfg 
    echo " blocks                      6 " >>  $cfg 
    echo " maxSQLLength                1048576 " >>  $cfg 
    echo " maxNumOfOrderedRes          100000 " >>  $cfg 
    echo " maxNumOfDistinctRes         10000000 " >>  $cfg 
    echo " maxWildCardsLength          100 " >>  $cfg 
    echo " update                      2 " >>  $cfg 
    echo " cachelast                   1 " >>  $cfg 
    echo " timezone                    UTC-8 " >>  $cfg 
    echo " locale                      en_US.UTF-8 " >>  $cfg 
    echo " charset                     UTF-8 " >>  $cfg 
    echo " maxShellConns               100000 " >>  $cfg 
    echo " maxConnections              100000 " >>  $cfg 
    echo " monitor                     1 " >>  $cfg 
    echo " logKeepDays                 -1 " >>  $cfg 
    echo " debugflag                   131 " >>  $cfg 
    echo " rpcForceTcp                 1 " >>  $cfg 
    echo " slaveQuery                  0 " >>  $cfg 
    echo " numOfMnodes                 3 " >>  $cfg 
    echo " offlineInterval             15 " >>  $cfg 
    echo " tcpConnTimeout              100 " >>  $cfg 
    echo " #shellActivityTimer         120 " >>  $cfg 
    echo " #compressMsgSize            -1 " >>  $cfg 
    echo " #compressColData            -1 " >>  $cfg 
    echo " #keepTimeOffset              0 " >>  $cfg   
    cp $adpcfg $adpcfg.$$
    num=$(grep -n '/var/log/taos' $adpcfg|awk -F ':' '{print $1}') 
    sed -i "${num} d" $apbcfg
    sed -i "${num} i path = \"${logDir}\"" $adpcfg
}

coreSet(){
    set_core ${coreDir}

}

pkgInstall(){
    tar xzf $pkg -C ./
    cd $(echo $pkg|awk -F '-' '{print $1"-"$2"-"$3"-"$4}')
    ./install.sh -e no
}

enableService(){
    systemctl enable taosd
    systemctl enable taosadapter
}

###Main

echo "Begin pkgInstall ......"
pkgInstall
echo "...pkgInstall Finished!"
echo ""

echo "Begin cfgCreate ......"
cfgCreate
echo "...cfgCreate Finished!"
echo ""

echo "Begin coreSet ......"
coreSet
echo "...coreSet Finished!"
echo ""

echo "Begin enableService ......"
enableService
echo "...enableService Finished!"