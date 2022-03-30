#!/bin/sh

star=$1
sdir=$2
udir=$(echo $star | awk -F '-' '{print $1"-"$2"-"$3"-"$4}')

RED='\033[0;31m'
GREEN='\033[1;32m'

NC='\033[0m' 

tar xzf $star
tar xzf $udir/taos.tar.gz -C $sdir/
cp -r $udir/driver $sdir/
cp -r $udir/examples $sdir/

ln -s $sdir/driver/libtaos.so.2.4.0.14 $sdir/driver/libtaos.so.1

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