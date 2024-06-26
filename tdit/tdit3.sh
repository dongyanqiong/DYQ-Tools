##########################
##TDengine Inspection Tools使用说明
##直接执行脚本，会在当前目录生成一个当日日期开头的文件夹和该文件夹同名的压缩包
##文件夹中为巡检日志
##########################

####taos配置文件
CFGFILE=/etc/taos/taos.cfg
ADPFILE=/etc/taos/taosadapter.toml
EXPFILE=/etc/taos/explorer.toml
KEPFILE=/etc/taos/taoskeeper.toml
TAXFILE=/etc/taos/taosx.toml
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
user=root
pass=taosdata

##coredump文件是否合适设置
CORE=0
##预安装包是否全部安装
PACK=1
##系统启动时间是否小于365天
UP=1
##可用内存使用是否小于200M
MEM=0
##是否使用swap
SWA=0
##inode使用是否超过80%
INODE=1
##文件系统使用率是否超过95%
DISK=1
##TDengine服务端是否运行
TDRUN=0
##TDengine是否随机启动
TDOB=1

eversion=1

 mcheck(){
    os=$(cat /etc/os-release| grep PRETTY_NAME | awk '{print $1}'|awk -F '=' '{print $2}' | sed 's/"//g')
    echo "OS:$os:"

    if [ -e /usr/bin/taosd ]
    then
        if [ $eversion -eq 1 ]
        then
            code=$(taosd -k | awk '{print $3}')
            echo "CODE:$code:"
        else
            echo "CODE::"
        fi
    fi


    echo "ACODE:0:"


    utime=$(cat /proc/uptime |awk '{printf "%d",$1/24/3600}')

    if [ $utime -gt 365 ]
        then
            UP=0
            echo "UP:$utime days:no"
        else
            echo "UP:$utime days:yes"
            UP=1
    fi

    corefile=$(cat /proc/sys/kernel/core_pattern|awk '{print $1}'|sed -e 's/|//g')
    if [ $corefile = 'core' ] || [ $corefile = '/usr/share/apport/apport' ]
        then    
            echo "coreCheck:$corefile:no"
            CORE=0
        else
            echo "coreCheck:$corefile:yes"
            CORE=1
    fi

    PACKETFILE=/tmp/packfile.tmp

    case $os in 
    "CentOS")
    rpm -qa >$PACKETFILE 
    ;;
    "Red")
    rpm -qa >$PACKETFILE 
    ;;
    "Ubuntu")
    dpkg -l >$PACKETFILE
    ;;
    *)
    exit
    ;;
    esac




    for i in tmux gdb fio iperf sysstat net-tools jansson snappy
    do 
        grep $i $PACKETFILE 1>/dev/null 2>/dev/null 
        if [ $? -eq 0 ]
            then
                echo "$i:install:yes"
            else
                echo "$i:install:none"
                PACK=0
        fi 

    done

    if [ $PACK -eq 0 ]
    then
        echo "PACK::no"
    else
        echo "PACK::yes"
    fi

    rm -f $PACKETFILE

    ##
    minfree=80
    mtotal=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mfree=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    smtotal=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    smfree=$(grep SwapFree /proc/meminfo | awk '{print $2}')

    #echo "Memory:$mtotal"
    #echo "Swap:$smtotal"
    puse=$((($mtotal-$mfree)*100/$mtotal))

    if [ $puse -gt $minfree ]
        then
            echo "MEMO:$puse%:no"
            MEM=0
        else
            echo "MEMO:$puse%:yes"
            MEM=1
    fi
    smuse=$(($smtotal-$smfree))

    if [ $smuse -gt 0 ]
        then
            echo "SWA:$smuse KB:no"
            SWA=0
        else
            echo "SWA:$smuse KB:yes"
            SWA=1
    fi



    for i in $(df -i |grep '%'| grep -v 'U' |awk '{print $5}' |awk -F '%' '{print $1}')
    do
        if [ $i -gt 80 ]
            then
                INODE=O
                break;
        fi
    done


    for i in $(df -i |grep '%'| grep -v 'U' |awk '{print $5}' |awk -F '%' '{print $1}')
    do
        if [ $i -gt 95 ]
            then
                DISK=O
                break;
        fi
    done

    if [ $INODE = 0 ]
    then
        echo "INODE::no"
    else
        echo "INODE::yes"
    fi

    if [ $DISK = 0 ]
    then
        echo "DISK::no"
    else
        echo "DISK::yes"
    fi

    pse=$(ps -ef | grep -w taosd | grep -v grep |wc -l)
    if [ $pse -eq 0 ]
        then
            echo "TD_MEM::no"
            TDRUN=0
        else
            TDRUN=1
            toasmem=$(ps aux | grep -w taosd | grep -v grep|awk '{print $6}')
            echo "TD_MEM:$toasmem KB:yes"
    fi    

    systemctl list-unit-files | grep taosd |grep enable 1>/dev/null 2>/dev/null
    if [ $? -eq 0 ]
        then
            echo "TDOB:enable:yes"
            TDOB=1
        else
            echo "TDOB:diable:no"
            TDOB=0
    fi

    if [ $eversion -eq 1 ]
    then
        etime=$(taos -u$user -p$pass -s "show grants\G" | grep 'expire_time:' |awk '{print $2}')
    else
        etime=null
    fi
    if [ $etime = 'null' ]
    then 
        echo "ETIME:$etime:yes"
    else
    if [ $etime = 'unlimited' ]
    then
        echo "ETIME:$etime:yes"
    else
        ntime=$(date +%s)
        dtime=$(date +%s -d $etime)
        exp=$((($dtime-$ntime)/3600/24))
        if [ $exp -lt 60 ]
        then
            echo "ETIME:$etime:no"
        else
            echo "ETIME:$etime:yes"
        fi
    fi
    fi


    DMPFILE=/tmp/dnode.tmp
    ##dnode
    taos -u$user -p$pass -s "SET MAX_BINARY_DISPLAY_WIDTH 40; show dnodes;" >$DMPFILE

    DNODE=1

    for i in $(taos -u$user -p$pass -s "show dnodes\G;"| grep end_point|awk '{print $2}')
    do
    status=$(grep $i $DMPFILE | awk '{print $9}') 
    node=$(echo $i|sed -e 's/:/_/g')
    if [ $status != 'ready' ]
        then
            DNODE=0
            break
        fi
    done

    if [ $DNODE -eq 0 ]
    then
        echo "DNODE:ERROR:no"
    else
        echo "DNODE:OK:yes"
    fi


    ##vgroup
    VGS=1
    VGS=$(taos -u$user -p$pass -s "show vnodes"|grep false|wc -l) 

    if [ $VGS -ne 0 ]
    then
        echo "VGS:ERROR:no"
    else
        echo "VGS:OK:yes"
    fi


    rm -f $DMPFILE

}

 oslog()
{
#    CFGFILE=/etc/taos/taos.cfg
    dd=$(date +%Y%m%d)
    taoscfg=$(echo "taoscfg"$dd".txt")
    ufile=$(echo "ulimit"$dd".txt")
    sysfile=$(echo "sysctl"$dd".txt")
    dmesgfile=$(echo "dmesg"$dd".txt")

    echo ""
    echo "###### 机器码 ##########"
    if [ $eversion -eq 1 ]
    then
        taosd -k 
    fi

    echo ""
    echo "###### 操作系统版本 ##########"
    os=$(cat /etc/os-release| grep PRETTY_NAME | awk '{print $1}'|awk -F '=' '{print $2}' | sed 's/"//g')

    case $os in 
    "CentOS")
    cat /etc/redhat-release 
    ;;
    "Red")
    cat /etc/redhat-release 
    ;;
    "Ubuntu")
    cat /etc/issue
    ;;
    *)
    exit
    ;;
    esac

    echo ""
    echo "###### 系统启动时间 ##########"
    uptime 

    echo ""
    echo "###### 预安装包 ##########"

    if [ $os = 'CentOS' -o $os = 'Red' ]
    then
        rpm -qa | grep -E "tmux|gdb|fio|iperf|sysstat|net-tools"
    else
        dpkg -l | grep -E "tmux|gdb|fio|iperf|sysstat|net-tools" | awk '{print $2"-"$3}'
    fi


    echo ""
    echo "###### 自启动程序 ##########"
    systemctl list-unit-files | grep enable  | grep -E "taos|fire"

    echo ""
    echo "###### coredump ##########"
    cat /proc/sys/kernel/core_pattern

    echo ""
    echo "###### 内存(MB) ##########"
    free -m |grep total|awk '{print "||"$1"|"$2"|"$3"|"$4"|"$5"|"$6"|"}'
    echo "|--|--|--|--|--|--|--|"
    free -m |grep -v total |awk '{print "|"$1"|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"}'

    echo ""
    echo "###### 磁盘 ##########"
    df -h
    echo ""
    df -i


    echo ""
    echo "###### hosts ##########"
    cat /etc/hosts | grep -v '^#' | grep -v '^$'


    sysctl -a 2>/dev/null  >$sysfile
    echo "" >> $sysfile
    cat  /etc/security/limits.conf >> $sysfile

    echo "User Limits" >$ufile
    ulimit -a >>$ufile
    echo "" >>$ufile
    echo "taosd Limits" >>$ufile
    cat /proc/`pidof taosd`/limits >>$ufile

    echo "" >>$ufile
    echo "taosadapter Limits" >>$ufile
    cat /proc/`pidof taosadapter`/limits >>$ufile
    dmesg -T >>$dmesgfile

}

 dblog()
{
#    CFGFILE=/etc/taos/taos.cfg
    dd=$(date +%Y%m%d)
    taoscfg=$(echo "taoscfg"$dd".txt")

    echo ""
    echo "###### TDengine进程 ##########"
    ps aux | grep taos | grep -v grep

    echo ""
    echo "###### Cluster ID ##########"
    clid=$(taos -u${user} -p${pass} -s "show cluster\G"|grep 'id:'|awk '{print $NF}')
    echo "ClusterId:$clid"



    echo ""
    echo "###### TDengine近3次启动时间 ##########"
    taosdlog=$(lsof -p `pidof taosd`|grep taosdlog|awk '{print $NF}')
    grep -w startup $taosdlog |tail -n 3


    echo ""
    echo "###### Vnode leader distuibuted ##########"
    echo "<table>"
    echo "<tr><th>节点ID</th><th>LeaderNum</th></tr>"
    taos -u${user} -p${pass} -s "show vnodes"|grep leader| awk '{print $1}'|sort -n |uniq -c|awk '{print "<tr><th>"$2"</th><th>"$1"</th></tr>"}'
    echo "</table>"

    tar -czf taosdlog.tar.gz $taosdlog

    if [ $nodei -ne 2 ]
    then
    echo ""
    echo "##### TDengine Cluster Info ##########"
    echo ""
    echo "###### Timeseries ##########"
    echo '```sql'
    taos -u$user -p$pass -s "select cast(sum(columns-1) as int) as tss,db_name from information_schema.ins_tables group by db_name;"
    echo '```'
    echo ""
    echo "###### Tables_Count ##########"
    echo '```sql'
    taos -u$user -p$pass -s "select cast(count(*) as int) as tbs,db_name from information_schema.ins_tables group by db_name;"
    echo '```'
    echo ""
    echo "###### Dnode ##########"
    echo '```sql'
    taos -u$user -p$pass -s "show dnodes\G;"
    echo '```'
    echo ""
    echo "###### Mnode ##########"
    echo '```sql'
    taos -u$user -p$pass -s "show mnodes;"
    echo '```'
    echo ""
    echo "###### Vnode ##########"
    echo '```sql'
    taos -u$user -p$pass -s "show vnodes;"
    echo '```'
    echo ""
    echo "###### Qnode ##########"
    echo '```sql'
    taos -u$user -p$pass -s "show qnodes;"
    echo '```'
    echo ""
    echo "###### 授权 ##########"
    echo '```sql'
    taos -u$user -p$pass -s "show grants\G;show grants full\G;"
    echo '```'
    echo ""
    echo "###### 数据库 ##########"
    echo '```sql'
    taos -u$user -p$pass -s "select * from information_schema.ins_databases\G;"
    echo '```'
    echo ""
    echo "###### 事务 ##########"
    echo '```sql'
    taos -u$user -p$pass -s "show transactions\G;"
    echo '```'
    echo ""
    echo "###### 连接 ##########"
    echo '```sql'
    taos -u$user -p$pass -s "show connections\G;"
    echo '```'
    echo ""
    echo "###### 查询 ##########"
    echo '```sql'
    taos -u$user -p$pass -s "show queries\G;"
    echo '```'
    echo ""
    echo "###### 订阅 ##########"
    echo '```sql'
    taos -u$user -p$pass -s "show subscriptions\G;"
    echo '```'
    echo ""
    echo "###### 流计算 ##########"
    echo '```sql'
    taos -u$user -p$pass -s "show streams\G;" 
    echo '```'

    grep -v '^#' $CFGFILE  | grep -v "^$"  >$taoscfg
    echo "------------------" >> $taoscfg
    taos -u$user -p$pass -s "show variables;" >> $taoscfg
    fi

    echo ""
    echo "###### Data 目录 ##########"

    grep -v '^#' $CFGFILE | grep -i datadir 1>/dev/null 2>/dev/null
    if [ $? -eq 0 ]
    then
        for i in $(grep -v '^#' $CFGFILE | grep -iw datadir | awk '{print $2}')
        do
            du -sh $i/*
            echo ""
            echo "______________________________________________"
            echo ""
            tree -h $i/
        done
        else
        du -sh /var/lib/taos/*
            echo ""
            echo "______________________________________________"
            echo ""
        tree -h /var/lib/taos/

    fi

    echo ""
    echo "###### Log 目录 ##########"


    grep -v '^#' $CFGFILE | grep -i logdir  1>/dev/null 2>/dev/null
    if [ $? -eq 0 ]
    then
        for i in $(grep -v '^#' $CFGFILE | grep -iw logdir  | awk '{print $2}')
        do
            du -sh $i
            echo ""
            du -sh $i/*
        done
        else
            du -sh /var/log/taos
            echo ""
            du -sh /var/log/taos/*
    fi 

    echo ""
    echo "###### Variables ##########"
    taos -u$user -p$pass -s "set max_binary_display_width 60;show variables;show dnode 1 variables;" | grep '|'| grep -v 'value' 

    echo ""
    echo "###### Cfgs ##########"
    if [ -e $ADPFILE ]
    then 
        echo ""
        echo "###### taosAdapter.toml ##########"
        grep -v '^#' $ADPFILE
    fi


    if [ -e $EXPFILE ]
    then 
        echo ""
        echo "###### taosExplorer.toml ##########"
        grep -v '^#' $ADPFILE
    fi


    if [ -e $KEPFILE ]
    then 
        echo ""
        echo "###### taosKeeper.toml ##########"
        grep -v '^#' $ADPFILE
    fi

    if [ -e $TAXFILE ]
    then 
        echo ""
        echo "###### taosX.toml ##########"
        grep -v '^#' $ADPFILE
    fi
}

report()
{
    cd $1
#    CFGFILE=/etc/taos/taos.cfg
    mlog=mlog.txt
    dblog=dblog.txt
    oslog=oslog.txt
    code=$(grep -w CODE $mlog | awk -F ':' '{print $2}')
    acode=$(grep -w ACODE $mlog|awk -F ':' '{print $2}')
    etime=$(grep -w ETIME $mlog|awk -F ':' '{print $2}')
    checkn=$(grep -E "yes|no" $mlog |wc -l)
    nonum=$(grep -w no $mlog|wc -l)
    clusterId=$(grep -iw ClusterId $dblog |awk -F ':' '{print $2}')



    suggest()
    {
        case $1 in 
        UP)
            echo "系统启动时间大于365天，建议重启服务器。"
        ;;
        coreCheck)
            echo "coredump设置不正确，建议："
            echo "临时生效："
            echo "ulimit -c unlimited"
            echo "sysctl -w kernel.core_pattern=<path>/core-%e-%p"
            echo ""
            echo "永久生效："
            echo "echo \"ulimit -c unlimited\" >>/etc/profile"
            echo "echo \"kernel.core_pattern=<path>/core-%e-%p\" >>/etc/sysctl.conf"
        ;;
        PACK)
        echo "预安装软件包未安装完整，请安装缺失软件。"
        echo "详见2.1 操作系统检查项。"
        ;;
        MEMO)
        echo "剩余内存小于200M，请排查内存占有原因，或增大内存"
        echo "注：硬件变更会更改机器码，请及时联系涛思重新激活产品。"
        ;;
        SWA)
        echo "已使用交换分区，说明内存不足，请排查内存占有原因，或增大内存"
        echo "注：硬件变更会更改机器码，请及时联系涛思重新激活产品。"
        ;;
        yes)
        echo "是"
        ;;
        no)
        echo "否"
        ;;
        TD_MEM)
        echo "TDengine未运行，请检查toasd服务。"
        ;;
        TDOB)
        echo "未设置TDengine开机自启，建议开启，命令如下："
        echo "systemctl enable taosd"
        ;;
        ETIME)
        echo "距离到期时间不足2个月，请及时联系涛思重新激活产品。"
        ;;
        DNODE)
        echo "dnode节点状态异常，请马上检查"
        ;;
        VGS)
        echo "vnode节点状态异常，请马上检查。"
        ;;
        *)
        echo "参数非法"
        ;;
        esac

    }

    trans()
    {
        case $1 in 
        UP)
        echo "系统启动时间"
        ;;
        coreCheck)
        echo "coredump文件位置"
        ;;
        PACK)
        echo "预安装软件包"
        ;;
        MEMO)
        echo "内存使用率"
        ;;
        SWA)
        echo "已用交换分区"
        ;;
        yes)
        echo "是"
        ;;
        no)
        echo "否"
        ;;
        TD_MEM)
        echo "TDengine使用内存"
        ;;
        TDOB)
        echo "TDengine开机自启"
        ;;
        ETIME)
        echo "到期时间"
        ;;
        DNODE)
        echo "dnode状态"
        ;;
        VGS)
        echo "vnode状态"
        ;;
        *)
        echo "参数非法"
        ;;
        esac

    }




    echo "# TDengine 3.x 巡检报告"

    echo "巡检日期：$(date +%Y-%m-%d)"
    echo "巡检员："
    echo "主机名：$(hostname)"
    echo "机器码：$code"
    echo "到期时间：$etime"
    echo "ClusterID：$clusterId"

    echo "## 1. 概述"
    echo "### 1.1 服务器硬件信息："
    echo "服务器型号：$(dmidecode -t system | grep 'Product Name:'|awk -F ':' '{print $2}')"
    echo "CPU：$(lscpu | grep '^Model name:' |awk -F ':' '{print $NF}' |sed 's/  //g') x $(lscpu| grep '^CPU(s):' | awk -F ':' '{print $2}' |sed 's/ //g')"
    echo "内存：$(grep '^MemTotal:' /proc/meminfo  |awk '{printf "%d MB\n",$2/1024}' )"
    echo "磁盘："
    #echo "$(df -TH|grep -v tmpfs)"
    echo "<table>"
    df -TH|grep -v tmpfs|grep -v loop|awk '{print "<tr><th>"$1"</th><th>"$2"</th><th>"$3"</th><th>"$4"</th><th>"$5"</th><th>"$6"</th><th>"$7"</tr>"}'
    echo "</table>"
    echo "### 1.2 软件信息："
    echo "操作系统：$(cat /etc/os-release | grep 'PRETTY_NAME="' | awk -F '=' '{print $2}' |sed 's/"//g')"
    echo "内核版本：$(uname -r)"
    echo "TDengine版本：$(taosd -V| grep 'version:')"



    echo "### 1.3 TDengine信息"
    echo "#### 1.3.1 关键配置信息"
    echo '```bash'
    grep -v '^#' $CFGFILE | grep -v '^$' |while read cv
    do
        echo $cv | awk '{print $1"\t"$2"\t"$3"\t"$4}'

    done
    echo '```'
    echo "<i>查看详细配置请见3.2.TDengine配置项</i>"

    echo "#### 1.3.2 近期启动时间"
    grep ' DND ' $dblog

    echo "### 1.4 巡检概述"
    echo "本次通过对系统各项指标进行检查，发现问题如下："
    echo "巡检项：$checkn"
    echo "不合规项：$nonum"
    echo "整改建议："




    nu=1
    for i in $(grep -w no $mlog|awk -F ':' '{print $1}')
    do
        echo -n "$nu) " 
        suggest $i;
        nu=$(($nu+1))
        echo ""
    done




    echo "## 2. 巡检报告"

    echo "### 2.1 操作系统检查项"

    echo "<table>"
    #echo "| 序号 | 检查项           | 内容    | 是否合规 |"
    #echo "| ---- | ---------------- | ------- | -------- |"
    echo "<tr>"
    echo "<th>序号</th><th>检查项</th><th>内容</th><th>是否合规</th>"
    echo "</tr>"
    nu=1
    for p in UP coreCheck PACK MEMO SWA 
    do
        cname=$(grep $p $mlog | awk -F ':' '{print $1}')
        cvalue=$(grep $p $mlog | awk -F ':' '{print $2}')
        if [ $p = 'PACK' ]
        then
            for ist in $(grep install $mlog| grep no)
            do
                cvalue=$(echo "$cvalue $(echo $ist |awk -F ':' '{printf $1}')")
            done
        fi
        cresult=$(grep $p $mlog | awk -F ':' '{print $3}')
        #echo "|$nu |$rname|$cvalue|$cresult"
        echo "<tr>"
        echo "<th>$nu</th><th>$(trans $cname)</th><th>$cvalue</th><th>$(trans $cresult)</th>"
        echo "</tr>"
        nu=$(($nu+1))
    done
    echo "</table>"
    echo ""



    echo "### 2.2 数据库检查项"

    echo "<table>"
    #echo "| 序号 | 检查项           | 内容    | 是否合规 |"
    #echo "| ---- | ---------------- | ------- | -------- |"
    echo "<tr>"
    echo "<th>序号</th><th>检查项</th><th>内容</th><th>是否合规</th>"
    echo "</tr>"
    nu=1
    for p in TD_MEM TDOB ETIME DNODE VGS
    do
        cname=$(grep $p $mlog | awk -F ':' '{print $1}')
        cvalue=$(grep $p $mlog | awk -F ':' '{print $2}')
        cresult=$(grep $p $mlog | awk -F ':' '{print $3}')
        #echo "|$nu |$rname|$cvalue|$cresult"
        echo "<tr>"
        echo "<th>$nu</th><th>$(trans $cname)</th><th>$cvalue</th><th>$(trans $cresult)</th>"
        echo "</tr>"
        nu=$(($nu+1))
    done
    echo "</table>"
    echo ""
    echo "数据库 Vnode Leader 分布"
    echo "<table>"
    echo "<tr><th>节点ID</th><th>LeaderNum</th></tr>"
    taos -u${user} -p${pass} -s "show vnodes"|grep leader| awk '{print $1}'|sort -n |uniq -c|awk '{print "<tr><th>"$2"</th><th>"$1"</th></tr>"}'
    echo "</table>"
    echo ""
#    echo "### 2.3 系统资源概况"

#    echo "#### 2.3.1 磁盘性能(fio)"

#    echo "#### 2.3.2 网络性能(iperf3)"


    echo "## 3. 附件"

    echo "### 3.1 操作系统巡检日志"
    echo ""
    cat $oslog

    echo "### 3.2 数据库巡检日志"
    echo ""
    head -300 $dblog
    echo '```'
    echo "详情见dblog.txt"
}




ldr=$(echo TD_$(date +%Y%m%d)_$$)
if [ -e $ldr ]
then
    rm -rf $ldr
fi

mkdir $ldr
cd $ldr

nodeinfo=$1
echo ""
echo ""
echo "The config is as follow, you can change by edit the shell. "
echo "cfg=$CFGFILE"
echo "Username=$user"
echo "Password=$pass"
echo ""
echo "Press Enter for continue, Crtl+C Abort"
read nothing

echo -n "Please wait......................"
mcheck >>mlog.txt
echo -n "....."
oslog >>oslog.txt
echo -n "....."
nodei=1
if [ $nodeinfo ]
then
    if [ $nodeinfo = 'dnode' ]
    then
        nodei=2
    fi
fi
dblog >>dblog.txt
echo -n "....."
echo "done"
echo ""


cd ..
report $ldr > $ldr/$ldr.md

cd ..
tar czf $ldr.tar.gz $ldr 

rm -rf $ldr
