#!/bin/sh
##./install.sh  TDengine-enterprise-server-2.4.0.14-Linux-x64.tar.gz /home/tdengine/test

star=$1
sdir=$2
udir=$(echo $star | awk -F '-' '{print $1"-"$2"-"$3"-"$4}')

RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m' 


if [ $# -ne 2 ]
then
    echo "./install.sh  TDengine-enterprise-server-2.4.0.14-Linux-x64.tar.gz /home/tdengine/test"
    exit
fi

if [ -e $star ]
then
    echo ""
    echo "tar file: $star"
else
    echo ""
    echo "$star is not exists!!"
    exit
fi

if [ -d $sdir ]
then
    echo ""
    echo "TDengine Dir: $sdir"
else
    echo ""
    echo "$sdir is not exists!!"
    exit
fi


tar xzf $star -C $sdir/
sdir=$(echo "${sdir}$(echo $star|awk -F '-Linux' '{print $1}')")
if [ -e $sdir/taos.tar.gz ]
then
    tar xzf $sdir/taos.tar.gz -C $sdir/ 
elif [ -e $sdir/package.tar.gz ]
then
    tar xzf $sdir/package.tar.gz -C $sdir/ 
else
    echo "No package found at $sdir!"
    exit
fi

libname=$(ls $sdir/driver/libtaos.*)
cp ${libname} $sdir/driver/libtaos.so.1

echo ""
echo -e "${GREEN}TDengine have been installed on $sdir ${NC}"
echo ""
echo -e "${RED}Add the following config to profile:${NC}"
echo ""
echo -e "${GREEN}TD_HOME=$sdir ${NC}"
echo -e "${GREEN}PATH=\$PATH:\$TD_HOME/bin:\$TD_HOME/jemalloc/bin${NC}"
echo -e "${GREEN}LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$TD_HOME/driver:\$TD_HOME/jemalloc/lib${NC}"
echo -e "${GREEN}C_INCLUDE_PATH=\$TD_HOME/inc:\$TD_HOME/jemalloc/include${NC}"
echo ""
echo -e "${GREEN}export TD_HOME${NC}"
echo -e "${GREEN}export C_INCLUDE_PATH${NC}"
echo -e "${GREEN}export LD_LIBRARY_PATH${NC}"
echo -e "${GREEN}export PATH${NC}"
echo ""