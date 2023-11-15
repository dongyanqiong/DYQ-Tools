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
def request_post(url, sql, user, pwd):
    try:
        sql = sql.encode("utf-8")
        headers = {
            'Connection': 'keep-alive',
            'Accept-Encoding': 'gzip, deflate, br'
        }
        try:
            result = requests.post(
                url, data=sql, auth=HTTPBasicAuth(user, pwd), headers=headers, timeout=10)
        except Exception as e:
            logger.error(e)
            logger.debug(sql)
            try:
                result = requests.post(
                    url, data=sql, auth=HTTPBasicAuth(user, pwd), headers=headers, timeout=30)
            except Exception as e:
                logger.error(e)
                logger.error(f"Try twice failed!! {sql}")
                sys.exit()
            else:
                text = result.content.decode()
                return text
        else:
            text = result.content.decode()
            return text
    except Exception as e:
        logger.error(e)
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


def export_table_only(etbname, itbname):
    cSQL = get_table_struc(etbname)
    nurl = iurl+'/'+idb
    resInfo = request_post(nurl, cSQL, iuserName, ipassWord)
    chkrt = check_return(resInfo, iversion)
    if chkrt == 'error':
        logger.error(resInfo)
    else:
        logger.info(f"Create table [{itbname}] done.")
        ctb_proced.append(1)

# Select data from etbname, and insert into itbname


def export_table(etbname, itbname):
    countsql = 'select count(*) from '+edb+'.'+etbname + \
        ' where _c0 >='+stime + ' and _c0<=' + etime + ';'
    result = request_post(eurl, countsql, euserName, epassWord)
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
            logger.info(f"Table Name:{etbname}, Select Rows:{count_num}")
        if row_num != 0 and count_num != 0:
            if count_num < recordPerSQL:
                select_sql = sqlh+' '+edb+'.'+etbname + \
                    ' where _c0 >=' + stime + ' and _c0<=' + etime + ';'
                resInfo = request_post(eurl, select_sql, euserName, epassWord)
                imsql = export_sql(idb, itbname, resInfo)
                resInfo = request_post(iurl, imsql, iuserName, ipassWord)
                chkrt = check_return(resInfo, iversion)
                logger.debug(f"Insert_to_DB {resInfo},{eversion},{chkrt}")
                if chkrt == 'error':
                    datard = json.loads(resInfo).get("desc")
                    if datard == 'Table does not exist':
                        cSQL = get_table_struc(itbname)
                        nurl = iurl+'/'+idb
                        resInfo = request_post(
                            nurl, cSQL, iuserName, ipassWord)
                        chkrt = check_return(resInfo, iversion)
                        if chkrt == 'error':
                            logger.error(resInfo)
                        else:
                            logger.info(f"Create table {itbname} success.")
                            ctb_proced.append(1)
                            resInfo = request_post(
                                iurl, imsql, iuserName, ipassWord)
                            chkrt = check_return(resInfo, iversion)
                            if chkrt == 'error':
                                logger.error(resInfo)
                            datai = json.loads(resInfo).get("data")
                            logger.info(
                                f"Table Name:{itbname} Insert Rows:{datai[0][0]}")
                            tb_proced.append(1)
                            rw_proced.append(int(datai[0][0]))
                else:
                    datai = json.loads(resInfo).get("data")
                    logger.info(
                        f"Table Name:{itbname} Insert Rows:{datai[0][0]}")
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
                        eurl, select_sql, euserName, epassWord)
                    chkrt = check_return(resInfo, eversion)
                    if chkrt == 'error':
                        logger.error(resInfo)
                    else:
                        imsql = export_sql(idb, itbname, resInfo)
                        resInfo = request_post(
                            iurl, imsql, iuserName, ipassWord)
                        chkrt = check_return(resInfo, iversion)
                        if chkrt == 'error':
                            datard = json.loads(resInfo).get("desc")
                            if datard == 'Table does not exist':
                                cSQL = get_table_struc(itbname)
                                logger.debug(cSQL)
                                nurl = iurl+'/'+idb
                                resInfo = request_post(
                                    nurl, cSQL, iuserName, ipassWord)
                                logger.debug(resInfo)
                                chkrt = check_return(resInfo, iversion)
                                if chkrt == 'error':
                                    logger.error(resInfo)
                                else:
                                    logger.info(
                                        f"Create table {itbname} success.")
                                    ctb_proced.append(1)
                                    resInfo = request_post(
                                        iurl, imsql, iuserName, ipassWord)
                                    chkrt = check_return(resInfo, iversion)
                                    if chkrt == 'error':
                                        logger.error(resInfo)
                        else:
                            datai = json.loads(resInfo).get("data")
                            irows = irows + datai[0][0]
                logger.info(f"Table Name:{itbname} Insert Rows:{irows}")
                tb_proced.append(1)
                rw_proced.append(int(datai[0][0]))

# Get table create sql


def get_table_struc(tbname):
    etbname = tbname
    getStrcSQL = "show create table "+edb+"."+etbname
    resInfo = request_post(eurl, getStrcSQL, euserName, epassWord)
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
    for ll in range(list_num):
        ii = tnum*list_num+ll
        if ii < len(tblist):
            etbname = str(tb_list[ii])
            itbname = etbname
            if tableonly == 'false':
                export_table(etbname, itbname)
                slnum += 1
                if slnum == 10 :
                    time.sleep(1)
                    logger.info("Sleep 1 sec.")
                    slnum = 1
            else:
                if tableonly == 'true':
                    export_table_only(etbname, itbname)
                else:
                    logger.error("CfgFile: tableonly set error!")

# Get table list from database


def get_tblist():
    tblist = []
    tbsql = 'show ' + edb + '.tables;'
    resInfo = request_post(eurl, tbsql, euserName, epassWord)
    chkrt = check_return(resInfo, eversion)
    if chkrt == 'error':
        logger.error(resInfo)
    else:
        load_data = json.loads(resInfo)
        data = load_data.get("data")
        tblist = []
        for i in range(len(data)):
            tblist.insert(i, str(data[i][0]))
    return tblist

# Multiple threads/process


def multi_thread(tblist, wmethod):
    logger.info('--------------------begin------------------')
    threads = []
    if len(tblist) < threadNum:
        for i in range(len(tblist)):
            tbname = tblist[i]
            export_table(tbname)
            proce = str(i+1)+'/'+str(len(tblist))
            logger.info(proce)
    else:
        listnum = int(len(tblist)/threadNum)+1
        if wmethod == 'process':
            for tnum in range(threadNum):
                t = multiprocessing.Process(
                    target=thread_func, args=(tblist, tnum, listnum))
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
    logger.info('--------------------end------------------')
    logger.info("##############################")
    logger.info(
        f"## {len(tb_proced)}/{len(tblist)} Tables  and {sum_list(rw_proced)} Rows are proceed.")
    logger.info(f"## {len(ctb_proced)} tables created.")
    logger.info("##############################")

# Check config file


def config_check():
    rvalue = 0
    etestsql = 'show '+edb+'.vgroups'
    itestsql = 'show '+idb+'.vgroups'
    resInfo = request_post(eurl, etestsql, euserName, epassWord)
    chkrt = check_return(resInfo, eversion)
    if chkrt == 'error':
        rvalue = 1
        logger.error("Export DB config error!")
    resInfo = request_post(iurl, itestsql, iuserName, ipassWord)
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
