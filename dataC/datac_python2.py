## Transfer data from Database A to Database B table by table by Restful.
import requests
import json
from requests.auth import HTTPBasicAuth
import sys
import time
##python2
reload(sys)
sys.setdefaultencoding('utf-8')
###

euserName="root"
epassWord="taosdata"
eurl="http://192.168.3.21:6041/rest/sql"
edb='db31'

iuserName="test"
ipassWord="Tbase125#@!"
iurl="http://192.168.3.23:6041/rest/sql"
idb='db32'

threadNum = 20

## Begin time for select data from table.
## Before one day.
stime = str(int(time.time()*1000-86400000))
## All data.
#stime = str(1500000000000)

## Number of one SQL.
recordPerSQL = 6


def request_post(url, sql, user, pwd):
    try:
        sql = sql.encode("utf-8")
        result = requests.post(url, data=sql, auth=HTTPBasicAuth(user,pwd))
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
#            print(select_sql)
            resInfo = request_post(eurl, select_sql, eusername, epassword)
            imsql = export_sql(idbname,itbname,resInfo)
#            print(imsql)
            resInfo = request_post(iurl, imsql, iusername, ipassword)
            datart = json.loads(resInfo).get("status")
            if str(datart) == 'error':
#                print(imsql)
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
                imsql = export_sql(idbname,itbname,resInfo)
                resInfo = request_post(iurl, imsql, iusername, ipassword)
#                print(resInfo)
                datart = json.loads(resInfo).get("status")
                if str(datart) == 'error':
#                    print(imsql)
                    print(resInfo)
                else:
                    datai = json.loads(resInfo).get("data")
                    irows = irows + datai[0][0]
            print(time.strftime('%Y-%m-%d %H:%M:%S'),"Table Name:",itbname,"Insert Rows:",irows)


def thfun(tb_list,thread_num,list_num,edbname,eurl,eusername,epassword,idbname,iurl,iusername,ipassword):
    for ll in range(list_num):
        ii=thread_num*list_num+ll
        if ii < len(tblist):
            etbname = str(tb_list[ii])
            itbname = etbname
            export_table(etbname,edbname,eurl,eusername,epassword,itbname,idbname,iurl,iusername,ipassword)


def get_tblist(eurl,edb,euserName, epassWord):
## Get table list from whole database.    
    tbsql = 'show '+ edb + '.tables;'
## Get table list from stable.
#    tbsql = 'select tbname from '+edb+'.meters;'
    resInfo = request_post(eurl, tbsql, euserName, epassWord)
    load_data = json.loads(resInfo)
    data = load_data.get("data")
    tblist= []
    for i in range(len(data)):
        tblist.insert(i,str(data[i][0]))
    return tblist


## Get table list from database.
##
tblist = get_tblist(eurl,edb,euserName, epassWord)
for i in range(len(tblist)):
        tbname = tblist[i]
        proce = str(i+1)+'/'+str(len(tblist))
#        print(proce)
        export_table(tbname,edb,eurl,euserName,epassWord,tbname,idb,iurl,iuserName,ipassWord,stime,recordPerSQL)#


## Get table list from file.
##
#filename = sys.argv[1]
#fileobj = open(filename,'r')
#try:
#    tblist =  fileobj.readlines()
#    for i in range(len(tblist)):
#        tbname = tblist[i].strip('\n')
#        export_table(tbname,edb,eurl,euserName,epassWord,tbname,idb,iurl,iuserName,ipassWord,stime,recordPerSQL)
#finally:
#    fileobj.close()
#


