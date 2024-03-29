## Transfer data from Database A to Database B table by table by Restful.
import requests
import json
from requests.auth import HTTPBasicAuth
import sys
import time
import threading
import multiprocessing
##python2
reload(sys)
sys.setdefaultencoding('utf-8')
###

###Read Config File
with open("datac.cfg") as j:
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

def export_sql(dbname,tbname, exdata):
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
##python2                
                if isinstance(data[i][l],unicode):
##python3
#                if isinstance(data[i][l],str):           
                    strs = str(data[i][l])
                    exsql = exsql + '\'' + strs + '\''
                else:
                    exsql = exsql + str(data[i][l]) 
            if l != len(data[i])-1:
                    exsql = exsql +  ','
        exsql = exsql +')'
    exsql = exsql + ';'
    return exsql

def export_table(etbname,edbname,eurl,eusername,epassword,itbname,idbname,iurl,iusername,ipassword,stime,recordPerSQL):
    countsql = 'select count(*) from '+edbname+'.'+etbname+' where _c0 >='+stime+';'
    result = request_post(eurl, countsql, eusername, epassword)
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
                select_sql = 'select * from '+edbname+'.'+etbname+' where _c0 >='+ stime +';'
                resInfo = request_post(eurl, select_sql, eusername, epassword)
                imsql = export_sql(idbname,itbname,resInfo)
                resInfo = request_post(iurl, imsql, iusername, ipassword)
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
                    select_sql = 'select * from '+edbname+'.'+etbname+' where _c0 >='+ stime +' limit '+str(recordPerSQL)+' offset '+str(offset) +';'
    #                print(select_sql)
                    resInfo = request_post(eurl, select_sql, eusername, epassword)
                    datart = json.loads(resInfo).get("status")
                    if str(datart) == 'error':
                        print(resInfo)
                    else:
                        imsql = export_sql(idbname,itbname,resInfo)
                        resInfo = request_post(iurl, imsql, iusername, ipassword)
                        datart = json.loads(resInfo).get("status")
                        if str(datart) == 'error':
                            print(resInfo)
                        else:
                            datai = json.loads(resInfo).get("data")
                            irows = irows + datai[0][0]
                print(time.strftime('%Y-%m-%d %H:%M:%S'),"Table Name:",itbname,"Insert Rows:",irows)

def thfun(tb_list,thread_num,list_num,edbname,eurl,eusername,epassword,idbname,iurl,iusername,ipassword,stime,recordPerSQL):
    for ll in range(list_num):
        ii=thread_num*list_num+ll
        if ii < len(tblist):
            etbname = str(tb_list[ii])
            itbname = etbname
            export_table(etbname,edbname,eurl,eusername,epassword,itbname,idbname,iurl,iusername,ipassword,stime,recordPerSQL)
           

def get_tblist(eurl,edb,euserName, epassWord):
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

def multi_thread(tblist,threadnum,edb,eurl,euserName,epassWord,idb,iurl,iuserName,ipassWord,stime,recordPerSQL):
    threads = []
    if len(tblist) < threadnum:
        for i in range(len(tblist)):
            tbname = tblist[i]
            export_table(tbname,edb,eurl,euserName,epassWord,tbname,idb,iurl,iuserName,ipassWord,stime,recordPerSQL)
            proce = str(i+1)+'/'+str(len(tblist))
            print(proce)
    else:
        listnum = int(len(tblist)/threadnum)+1
        for tnum in range(threadnum):  
## multiThread            
#            t = threading.Thread(target=thfun,args=(tblist,tnum,listnum,edb,eurl,euserName,epassWord,idb,iurl,iuserName,ipassWord,stime,recordPerSQL))
## multiProcess
            t = multiprocessing.Process(target=thfun,args=(tblist,tnum,listnum,edb,eurl,euserName,epassWord,idb,iurl,iuserName,ipassWord,stime,recordPerSQL))
            threads.append(t)
        for t in threads:  
            t.start()
        for t in threads:  
            t.join()

def config_check(threadNum,edb,eurl,euserName,epassWord,idb,iurl,iuserName,ipassWord,stime,recordPerSQL):
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
    cvalue = config_check(threadNum,edb,eurl,euserName,epassWord,idb,iurl,iuserName,ipassWord,stime,recordPerSQL)
    if cvalue == 0:
        if len(sys.argv) <= 1:
        ## Get table list from database.
        ##
            tblist = get_tblist(eurl,edb,euserName, epassWord)
            if len(tblist) == 0:
                exit
            else:
                multi_thread(tblist,threadNum,edb,eurl,euserName,epassWord,idb,iurl,iuserName,ipassWord,stime,recordPerSQL)
        else:
        ## Get table list from file.
        ##
            filename = sys.argv[1]
            fileobj = open(filename,'r')
            try:
                tblist = []
                for tb in fileobj.readlines():
                    tblist.append(tb.strip('\n'))
                multi_thread(tblist,threadNum,edb,eurl,euserName,epassWord,idb,iurl,iuserName,ipassWord,stime,recordPerSQL)

            finally:
                fileobj.close()
    else:
        print("Config file error!")


