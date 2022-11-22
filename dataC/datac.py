## Transfer data from Database A to Database B table by table by Restful.
import requests
import json
from requests.auth import HTTPBasicAuth
import sys
import getopt
import time
import threading
import multiprocessing

pversion = int(sys.version[0:1])

if pversion  < 3 :
    reload(sys)
    sys.setdefaultencoding('utf-8')

###Read Config File
if pversion<3:
    with open("datac.cfg") as j:
        clusterInfo=json.load(j)
else:
    with open("datac.cfg",encoding="utf-8") as j:
        clusterInfo=json.load(j)

euserName=clusterInfo.get("exportUsername")
epassWord=clusterInfo.get("exportPassword")
eurl=clusterInfo.get("exporUrl")
edb=clusterInfo.get("exportDBName")

iuserName=clusterInfo.get("importUsername")
ipassWord=clusterInfo.get("importPassword")
iurl=clusterInfo.get("importUrl")
idb=clusterInfo.get("importDBName")

threadNum = clusterInfo.get("threadNum")

## Begin time for select data from table.
## Before one day.
#stime = str(int(time.time()*1000-86400000))
## All data.
stime = str(clusterInfo.get("startTime"))

## Number of one SQL.
recordPerSQL = clusterInfo.get("recodeOfPerSQL")


## Restful request
def request_post(url, sql, user, pwd):
    try:
        sql = sql.encode("utf-8")
        headers = {
            'Connection': 'keep-alive',
            'Accept-Encoding': 'gzip, deflate, br'
        }
        result = requests.post(url, data=sql, auth=HTTPBasicAuth(user,pwd),headers=headers)
        text=result.content.decode()
        return text
    except Exception as e:
        print(e)

## Join SQL
def export_sql(dbname,tbname,exdata):
    load_data = json.loads(exdata,encoding='utf-8')
    data = load_data.get("data")
    exsql = 'insert into ' + dbname+'.'+tbname +' values '
    for i in range(len(data)):
        exsql = exsql + '('
        for l in range(len(data[i])):
            if data[i][l] is None:
                strs = 'NULL'
                exsql = exsql + strs 
            else:
                if pversion < 3: 
                    if isinstance(data[i][l],unicode):
                            strs = str(data[i][l])
                            exsql = exsql + '\'' + strs + '\''
                    else:
                             exsql = exsql + str(data[i][l]) 
                else:
                    if isinstance(data[i][l],str):           
                        strs = str(data[i][l])
                        exsql = exsql + '\'' + strs + '\''
                    else:
                        exsql = exsql + str(data[i][l]) 
            if l != len(data[i])-1:
                    exsql = exsql +  ','
        exsql = exsql +')'
    exsql = exsql + ';'
    return exsql

## Select data from etbname, and insert into itbname
def export_table(etbname,itbname):
    countsql = 'select count(*) from '+edb+'.'+etbname+' where _c0 >='+stime+';'
    result = request_post(eurl, countsql, euserName, epassWord)
    datart = json.loads(result).get("status")
    if str(datart) == 'error':
        print(result)
        exit
    else:
        load_data = json.loads(result)
        datar = load_data.get("rows")
        row_num = datar
        if row_num != 0:
            data = load_data.get("data")
            count_num = data[0][0]
            print(time.strftime('%Y-%m-%d %H:%M:%S'),"Table Name:",etbname,"Select Rows:",count_num)
        if row_num != 0 and count_num != 0:
            if count_num < recordPerSQL:
                select_sql = 'select * from '+edb+'.'+etbname+' where _c0 >='+ stime +';'
                resInfo = request_post(eurl, select_sql, euserName, epassWord)
                imsql = export_sql(idb,itbname,resInfo)
                resInfo = request_post(iurl, imsql, iuserName, ipassWord)
                datart = json.loads(resInfo).get("status")
                if str(datart) == 'error':
                    print(resInfo)
                else:
                    datai = json.loads(resInfo).get("data")
                    print(time.strftime('%Y-%m-%d %H:%M:%S'),"Table Name:",itbname,"Insert Rows:",datai[0][0])
            else:
                if count_num % recordPerSQL == 0:
                    rnum = int(count_num/recordPerSQL)
                else:
                    rnum = int(count_num/recordPerSQL)+1
                irows = 0
                for i in range(rnum):
                    offset = i * recordPerSQL
                    select_sql = 'select * from '+edb+'.'+etbname+' where _c0 >='+ stime +' limit '+str(recordPerSQL)+' offset '+str(offset) +';'
    #                print(select_sql)
                    resInfo = request_post(eurl, select_sql, euserName, epassWord)
                    datart = json.loads(resInfo).get("status")
                    if str(datart) == 'error':
                        print(resInfo)
                    else:
                        imsql = export_sql(idb,itbname,resInfo)
                        resInfo = request_post(iurl, imsql, iuserName, ipassWord)
                        datart = json.loads(resInfo).get("status")
                        if str(datart) == 'error':
                            print(resInfo)
                        else:
                            datai = json.loads(resInfo).get("data")
                            irows = irows + datai[0][0]
                print(time.strftime('%Y-%m-%d %H:%M:%S'),"Table Name:",itbname,"Insert Rows:",irows)

## Function for Multiple threads/process
def thread_func(tb_list,tnum,list_num):
    for ll in range(list_num):
        ii=tnum*list_num+ll
        if ii < len(tblist):
            etbname = str(tb_list[ii])
            itbname = etbname
            export_table(etbname,itbname)
           
## Get table list from database
def get_tblist():
    tblist = []  
    tbsql = 'show '+ edb + '.tables;'
    resInfo = request_post(eurl, tbsql, euserName, epassWord)
    datart = json.loads(resInfo).get("status")
    if str(datart) == 'error':
        print(resInfo)
    else:
        load_data = json.loads(resInfo)
        data = load_data.get("data")
        tblist= []
        for i in range(len(data)):
            tblist.insert(i,str(data[i][0]))
    return tblist

## Multiple threads/process
def multi_thread(tblist,wmethod):
    threads = []
    if len(tblist) < threadNum:
        for i in range(len(tblist)):
            tbname = tblist[i]
            export_table(tbname)
            proce = str(i+1)+'/'+str(len(tblist))
            print(proce)
    else:
        listnum = int(len(tblist)/threadNum)+1
        if wmethod == 'process':
            for tnum in range(threadNum):  
                t = multiprocessing.Process(target=thread_func,args=(tblist,tnum,listnum))
                threads.append(t)
        else:
            for tnum in range(threadNum):             
                t = threading.Thread(target=thread_func,args=(tblist,tnum,listnum))
                threads.append(t)
        for t in threads:  
            t.start()
        for t in threads:  
            t.join()

## Check config file
def config_check():
    rvalue = 0
    etestsql = 'show '+edb+'.vgroups'
    itestsql = 'show '+idb+'.vgroups'
    resInfo = request_post(eurl, etestsql, euserName, epassWord)
    datart = json.loads(resInfo).get("status")
    if str(datart) == 'error':
        rvalue = 1
        print("Export DB config error!")
    resInfo = request_post(iurl, itestsql, iuserName, ipassWord)
    datart = json.loads(resInfo).get("status")
    if str(datart) == 'error':
        rvalue = 1 
        print("Import DB config error!") 
    if int(stime) <= 0:
        rvalue = 1
        print("Start time must be bigger than zer0!") 
    if int(recordPerSQL) <= 0:
        rvalue = 1
        print("recordPerSQL must be bigger than zer0!")
    if int(threadNum) <= 0:
        rvalue = 1
        print("recordPerSQL must be bigger than zer0!")
    if edb == idb and eurl == iurl:
        rvalue = 1
        print("Export DB should not be the Import DB!")
    return rvalue


if __name__ == '__main__':
    cvalue = config_check()
    filename = ''
    wmethod = 'thread'
    help = 'false'
    if cvalue == 0:
        if len(sys.argv) <= 1:
            tblist = get_tblist()
            if len(tblist) == 0:
                exit
            else:
                multi_thread(tblist,wmethod)
        else:
            try:
                opts,args=getopt.getopt(sys.argv[1:],"f:p")
            except getopt.GetoptError:
                print('\npython datac.py -f tblist_file -p thread\n')
                print("-f filename \tTable list file.")
                print("-p \t\tWork with multiple processes( thread is default).")
                print()
                sys.exit
            else:
                for opt,arg in opts:
                    if opt == '-f':
                        filename = arg
                    if opt == '-p':
                        wmethod = 'process'
                if len(filename) <=0:
                    tblist = get_tblist()
                    if len(tblist) == 0:
                        exit
                    else:
                        multi_thread(tblist,wmethod)
                else:
                    fileobj = open(filename,'r')
                    try:
                        tblist = []
                        for tb in fileobj.readlines():
                            tblist.append(tb.strip('\n'))
                        multi_thread(tblist,wmethod)
                    finally:
                        fileobj.close()
    else:
        print("Config file error!")


