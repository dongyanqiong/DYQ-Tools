# -*- coding: utf-8 -*-
""" 
  Transfer data from Database A to Database B table by table by Restful.
  DB and Stable must be create before run dataC.
"""
import requests
import json
from requests.auth import HTTPBasicAuth
import sys
import getopt
import time
import threading
import multiprocessing
import logging

# Set logging config
log_file = 'dataC.log'
handler_test = logging.FileHandler(log_file, mode='w')
handler_control = logging.StreamHandler()
handler_test.setLevel('INFO')
handler_control.setLevel('INFO')
selfdef_fmt = '[%(asctime)s] %(name)s/%(funcName)s(%(process)d/%(threadName)s) %(levelname)s - %(message)s'
formatter = logging.Formatter(selfdef_fmt)
handler_test.setFormatter(formatter)
handler_control.setFormatter(formatter)
logger = logging.getLogger('dataC')
logger.setLevel('DEBUG')
logger.addHandler(handler_test)
logger.addHandler(handler_control)

global pversion
pversion = int(sys.version[0:1])

if pversion < 3:
    reload(sys)
    sys.setdefaultencoding('utf-8')

# Read config file


def get_param(cfgfile):
    global euserName
    global epassWord
    global eurl
    global edb
    global eversion
    global iuserName
    global ipassWord
    global iurl
    global idb
    global iversion
    global threadNum
    global stime
    global etime
    global recordPerSQL
    global tableonly
    global sqlh

    if pversion < 3:
        with open(cfgfile) as j:
            clusterInfo = json.load(j)
            j.close()
    else:
        with open(cfgfile, encoding="utf-8") as j:
            clusterInfo = json.load(j)
            j.close()

    euserName = clusterInfo.get("exportUsername")
    epassWord = clusterInfo.get("exportPassword")
    eurl = clusterInfo.get("exporUrl")
    edb = clusterInfo.get("exportDBName")
    eversion = clusterInfo.get("exportVersion")
    iuserName = clusterInfo.get("importUsername")
    ipassWord = clusterInfo.get("importPassword")
    iversion = clusterInfo.get("importVersion")
    iurl = clusterInfo.get("importUrl")
    idb = clusterInfo.get("importDBName")
    threadNum = clusterInfo.get("threadNum")
    stime = str(clusterInfo.get("startTime"))
    etime = str(clusterInfo.get("endTime"))
    recordPerSQL = clusterInfo.get("recodeOfPerSQL")
    tableonly = clusterInfo.get("tableonly")
    sqlh = clusterInfo.get("sqlheader")


# Restful request
def request_post(url, sql, user, pwd, rss):
    try:
        sql = sql.encode("utf-8")
        headers = {
            'Connection': 'keep-alive',
            'Accept-Encoding': 'gzip, deflate, br'
        }
        try:
            result = rss.post(
                url, data=sql, auth=HTTPBasicAuth(user, pwd), headers=headers, timeout=10)
            text = result.content.decode()
        except Exception as e:
            logger.error(e)
            logger.debug(sql)
            try:
                result = rss.post(
                    url, data=sql, auth=HTTPBasicAuth(user, pwd), headers=headers, timeout=30)
                text = result.content.decode()
            except Exception as e:
                logger.error(e)
                logger.error("Try twice failed!!"+str(sql))
                sys.exit()
            else:
                return text
        else:
            return text
    except Exception as e:
        logger.error(e)
        sys.exit()
        return -1

# Check Restful Return


def check_return(result, tdversion):
    if tdversion == 2:
        datart = json.loads(result).get("status")
    else:
        datart = json.loads(result).get("code")
    if str(datart) == 'succ' or str(datart) == '0':
        chkrt = 'succ'
    else:
        chkrt = 'error'
    return chkrt

# Join SQL


def export_sql(dbname, tbname, exdata):
    load_data = json.loads(exdata)
    data = load_data.get("data")
    exsql = 'insert into ' + dbname+'.'+tbname + ' values '
    for i in range(len(data)):
        exsql = exsql + '('
        for l in range(len(data[i])):
            if data[i][l] is None:
                strs = 'NULL'
                exsql = exsql + strs
            else:
                if pversion < 3:
                    if isinstance(data[i][l], unicode):
                        strs = str(data[i][l])
                        exsql = exsql + '\'' + strs + '\''
                    else:
                        exsql = exsql + str(data[i][l])
                else:
                    if isinstance(data[i][l], str):
                        strs = str(data[i][l])
                        exsql = exsql + '\'' + strs + '\''
                    else:
                        exsql = exsql + str(data[i][l])
            if l != len(data[i])-1:
                exsql = exsql + ','
        exsql = exsql + ')'
    exsql = exsql + ';'
    return exsql


def export_table_only(etbname, itbname, irss, erss):
    cSQL = get_table_struc(etbname, irss)
    nurl = iurl+'/'+idb
    resInfo = request_post(nurl, cSQL, iuserName, ipassWord, erss)
    chkrt = check_return(resInfo, iversion)
    if chkrt == 'error':
        logger.error(resInfo)
    else:
        logger.info("Create table ["+str(itbname)+"] done.")
        ctb_proced.append(1)

# Select data from etbname, and insert into itbname


def export_table(etbname, itbname, irss, erss):
    countsql = 'select count(*) from '+edb+'.'+etbname + \
        ' where _c0 >='+stime + ' and _c0<=' + etime + ';'
    result = request_post(eurl, countsql, euserName, epassWord, erss)
    chkrt = check_return(result, eversion)
    if chkrt == 'error':
        logger.error(result)
        exit
    else:
        load_data = json.loads(result)
        datar = load_data.get("rows")
        row_num = datar
        if row_num != 0:
            data = load_data.get("data")
            count_num = data[0][0]
            logger.debug("Table Name:"+str(etbname)+", Select Rows:"+str(count_num))
        if row_num != 0 and count_num != 0:
            if count_num < recordPerSQL:
                select_sql = sqlh+' '+edb+'.'+etbname + \
                    ' where _c0 >=' + stime + ' and _c0<=' + etime + ';'
                resInfo = request_post(eurl, select_sql, euserName, epassWord, erss)
                imsql = export_sql(idb, itbname, resInfo)
                resInfo = request_post(iurl, imsql, iuserName, ipassWord, irss)
                chkrt = check_return(resInfo, iversion)
                logger.debug("Insert_to_DB "+str(resInfo)+" "+str(eversion)+" "+str(chkrt))
                if chkrt == 'error':
                    datard = json.loads(resInfo).get("desc")
                    if datard == 'Table does not exist':
                        cSQL = get_table_struc(itbname, irss)
                        nurl = iurl+'/'+idb
                        resInfo = request_post(
                            nurl, cSQL, iuserName, ipassWord, irss)
                        chkrt = check_return(resInfo, iversion)
                        if chkrt == 'error':
                            logger.error(resInfo)
                        else:
                            logger.info("Create table "+str(itbname)+" success.")
                            ctb_proced.append(1)
                            resInfo = request_post(
                                iurl, imsql, iuserName, ipassWord, irss)
                            chkrt = check_return(resInfo, iversion)
                            if chkrt == 'error':
                                logger.error(resInfo)
                            datai = json.loads(resInfo).get("data")
                            logger.debug(
                                "Table Name:"+str(itbname)+" Insert Rows:"+str(datai[0][0]))
                            tb_proced.append(1)
                            rw_proced.append(int(datai[0][0]))
                else:
                    datai = json.loads(resInfo).get("data")
                    logger.debug(
                        "Table Name:"+str(itbname)+" Insert Rows:"+str(datai[0][0]))
                    tb_proced.append(1)
                    rw_proced.append(int(datai[0][0]))
            else:
                if count_num % recordPerSQL == 0:
                    rnum = int(count_num/recordPerSQL)
                else:
                    rnum = int(count_num/recordPerSQL)+1
                irows = 0
                for i in range(rnum):
                    offset = i * recordPerSQL
                    select_sql = sqlh+' '+edb+'.'+etbname+' where _c0 >=' + stime + ' and _c0<=' + \
                        etime + ' limit ' + \
                        str(recordPerSQL)+' offset '+str(offset) + ';'
                    logger.debug(select_sql)
                    resInfo = request_post(
                        eurl, select_sql, euserName, epassWord, erss)
                    chkrt = check_return(resInfo, eversion)
                    if chkrt == 'error':
                        logger.error(resInfo)
                    else:
                        imsql = export_sql(idb, itbname, resInfo)
                        resInfo = request_post(
                            iurl, imsql, iuserName, ipassWord, irss)
                        chkrt = check_return(resInfo, iversion)
                        if chkrt == 'error':
                            datard = json.loads(resInfo).get("desc")
                            if datard == 'Table does not exist':
                                cSQL = get_table_struc(itbname, irss)
                                logger.debug(cSQL)
                                nurl = iurl+'/'+idb
                                resInfo = request_post(
                                    nurl, cSQL, iuserName, ipassWord, irss)
                                logger.debug(resInfo)
                                chkrt = check_return(resInfo, iversion)
                                if chkrt == 'error':
                                    logger.error(resInfo)
                                else:
                                    logger.info(
                                        "Create table "+str(itbname)+" success.")
                                    ctb_proced.append(1)
                                    resInfo = request_post(
                                        iurl, imsql, iuserName, ipassWord, irss)
                                    chkrt = check_return(resInfo, iversion)
                                    if chkrt == 'error':
                                        logger.error(resInfo)
                        else:
                            datai = json.loads(resInfo).get("data")
                            irows = irows + datai[0][0]
                logger.debug("Table Name:"+str(itbname)+" Insert Rows:"+str(irows))
                tb_proced.append(1)
                rw_proced.append(int(datai[0][0]))

# Get table create sql


def get_table_struc(tbname, irss):
    etbname = tbname
    getStrcSQL = "show create table "+edb+"."+etbname
    resInfo = request_post(eurl, getStrcSQL, euserName, epassWord, irss)
    chkrt = check_return(resInfo, eversion)
    if chkrt == 'error':
        logger.error(resInfo)
    else:
        load_data = json.loads(resInfo)
        data = load_data.get("data")
        createSQL = (str(data[0][1]).replace(
            "CREATE TABLE", "CREATE TABLE IF NOT EXISTS"))
    return createSQL


# Function for Multiple threads/process
def thread_func(tb_list, tnum, list_num):
    slnum = 1
    irss = requests.session()
    erss = requests.session()
    for ll in range(list_num):
        ii = tnum*list_num+ll
        if ii < len(tb_list):
            etbname = str(tb_list[ii])
            itbname = etbname
            if tableonly == 'false':
                export_table(etbname, itbname, irss, erss)
                slnum += 1
                if slnum == 1000 :
                    time.sleep(1)
                    logger.info("Sleep 1 sec.")
                    slnum = 1
            else:
                if tableonly == 'true':
                    export_table_only(etbname, itbname, irss, erss)
                else:
                    logger.error("CfgFile: tableonly set error!")
    irss.close()
    erss.close()

def process_func(tb_list, tnum, list_num, m_tb, m_rw, m_ctb):
    slnum = 1
    irss = requests.session()
    erss = requests.session()
    for ll in range(list_num):
        ii = tnum*list_num+ll
        if ii < len(tb_list):
            etbname = str(tb_list[ii])
            itbname = etbname
            if tableonly == 'false':
                export_table(etbname, itbname, irss, erss)
                slnum += 1
                if slnum == 1000 :
                    time.sleep(1)
                    logger.info("Sleep 1 sec.")
                    slnum = 1
            else:
                if tableonly == 'true':
                    export_table_only(etbname, itbname, irss, erss)
                else:
                    logger.error("CfgFile: tableonly set error!")
    irss.close()
    erss.close()
    m_tb[tnum] = len(tb_proced)
    m_rw[tnum] = sum_list(rw_proced)
    m_ctb[tnum] = len(ctb_proced)

# Get table list from database
def get_tblist():
    erss = requests.session()
    tblist = []
    tbsql = 'show ' + edb + '.tables;'
    resInfo = request_post(eurl, tbsql, euserName, epassWord, erss)
    chkrt = check_return(resInfo, eversion)
    if chkrt == 'error':
        logger.error(resInfo)
    else:
        load_data = json.loads(resInfo)
        data = load_data.get("data")
        tblist = []
        for i in range(len(data)):
            tblist.insert(i, str(data[i][0]))
    erss.close()
    return tblist

# Multiple threads/process


def multi_thread(tblist, wmethod):
    logger.info('--------------------begin------------------')
    logger.info("##############################")
    threads = []
    if len(tblist) < threadNum:
        irss = requests.session()
        erss = requests.session()
        for i in range(len(tblist)):
            tbname = tblist[i]
            export_table(tbname, tbname, irss, erss)
    else:
        listnum = int(len(tblist)/threadNum)+1
        if wmethod == 'process':
            m_tb = multiprocessing.Array('i',threadNum)
            m_rw = multiprocessing.Array('i',threadNum)
            m_ctb = multiprocessing.Array('i',threadNum)
            for tnum in range(threadNum):
                t = multiprocessing.Process(
                    target=process_func, args=(tblist, tnum, listnum, m_tb, m_rw, m_ctb))
                threads.append(t)
        else:
            for tnum in range(threadNum):
                tname = str('Thread_'+str(tnum))
                t = threading.Thread(target=thread_func,
                                     name=tname, args=(tblist, tnum, listnum))
                threads.append(t)
        for t in threads:
            t.start()
        for t in threads:
            t.join()
    if wmethod == 'process' and len(tblist) >= threadNum :
        logger.info("## "+str(sum_list(m_tb[:]))+"/"+str(len(tblist))+" Tables  and "+str(sum_list(m_rw[:]))+" Rows are proceed.")
        logger.info("## "+str(sum_list(m_ctb[:]))+" tables created.")
    else:
        logger.info("## "+str(sum_list(tb_proced))+"/"+str(len(tblist))+" Tables  and "+str(sum_list(rw_proced))+" Rows are proceed.")
        logger.info("## "+str(sum_list(ctb_proced))+" tables created.")
    logger.info("##############################")
    logger.info('--------------------end------------------')

# Check config file


def config_check():
    irss = requests.session()
    erss = requests.session()
    rvalue = 0
    etestsql = 'show '+edb+'.vgroups'
    itestsql = 'show '+idb+'.vgroups'
    resInfo = request_post(eurl, etestsql, euserName, epassWord, erss)
    chkrt = check_return(resInfo, eversion)
    if chkrt == 'error':
        rvalue = 1
        logger.error("Export DB config error!")
    resInfo = request_post(iurl, itestsql, iuserName, ipassWord, irss)
    chkrt = check_return(resInfo, iversion)
    if chkrt == 'error':
        rvalue = 1
        logger.error("Import DB config error!")
    if int(stime) <= 0:
        rvalue = 1
        logger.error("Start time must be bigger than zer0!")
    if int(recordPerSQL) <= 0:
        rvalue = 1
        logger.error("recordPerSQL must be bigger than zer0!")
    if int(threadNum) <= 0:
        rvalue = 1
        logger.error("recordPerSQL must be bigger than zer0!")
    if edb == idb and eurl == iurl:
        rvalue = 1
        logger.error("Export DB should not be the Import DB!")
    irss.close()
    erss.close()    
    return rvalue

# sum list


def sum_list(rwlist):
    sum = 0
    for i in rwlist:
        sum += int(i)
    return sum


if __name__ == '__main__':
    cfgfile = 'datac.cfg'
    filename = ''
    wmethod = 'thread'
    help = 'false'
    global tb_proced
    global ctb_proced
    global rw_proced
    tb_proced = []
    ctb_proced = []
    rw_proced = []

    if len(sys.argv) <= 1:
        get_param(cfgfile)
        cvalue = config_check()
        if cvalue == 0:
            tblist = get_tblist()
            if len(tblist) == 0:
                exit
            else:
                multi_thread(tblist, wmethod)
        else:
            logger.error("Config file ERROR!")
    else:
        try:
            opts, args = getopt.getopt(sys.argv[1:], "c:f:p")
        except getopt.GetoptError:
            print('\npython datac.py -f tblist_file -p thread\n')
            print("-c filename \tConfig filename (datac.cfg is default).")
            print("-f filename \tTable list file.")
            print("-p \t\tWork with multiple processes( thread is default).")
            print()
            sys.exit
        else:
            for opt, arg in opts:
                if opt == '-c':
                    cfgfile = arg
                if opt == '-f':
                    filename = arg
                if opt == '-p':
                    wmethod = 'process'

            get_param(cfgfile)
            cvalue = config_check()

            if cvalue == 0:
                if len(filename) <= 0:
                    tblist = get_tblist()
                    if len(tblist) == 0:
                        sys.exit
                    else:
                        multi_thread(tblist, wmethod)
                else:
                    fileobj = open(filename, 'r')
                    try:
                        tblist = []
                        for tb in fileobj.readlines():
                            tblist.append(tb.strip('\n'))
                        multi_thread(tblist, wmethod)
                    finally:
                        fileobj.close()
            else:
                logger.error("Config file ERROR!")
