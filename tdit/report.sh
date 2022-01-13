##########################
##使用说明
##report.sh 巡检日志目录
##执行后会以markdown格式输出巡检报告。
##########################

export LANG=en_US.UTF-8
cd $1
CFGFILE=/etc/taos/taos.cfg
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




echo "# TDengine巡检报告"

echo "巡检日期：$(date +%Y-%m-%d)"
echo "巡检员："
echo "主机名：$(hostname)"
echo "机器码：$code"
echo "激活码：$acode"
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
df -TH|grep -v tmpfs|awk '{print "<tr><th>"$1"</th><th>"$2"</th><th>"$3"</th><th>"$4"</th><th>"$5"</th><th>"$6"</th><th>"$7"</tr>"}'
echo "</table>"
echo "### 1.2 软件信息："
echo "操作系统：$(cat /etc/os-release | grep 'PRETTY_NAME="' | awk -F '=' '{print $2}' |sed 's/"//g')"
echo "内核版本：$(uname -r)"
echo "TDengine版本：$(taosd -V| grep 'version:')"



echo "### 1.3 TDengine信息"
echo "#### 1.3.1 关键配置信息"
grep -v '^#' $CFGFILE | grep -v '^$' |while read cv
do
    echo $cv | awk '{print $1"\t"$2}'

done

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
echo ""

echo "### 2.3 系统资源概况"

echo "请参考Web管理器！！"


echo "## 3. 附件"

echo "### 3.1 操作系统巡检日志"
echo ""
cat $oslog

echo "### 3.2 数据库巡检日志"
echo ""
cat $dblog