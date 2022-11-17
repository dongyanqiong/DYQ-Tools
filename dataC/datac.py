## Transfer data from Database A to Database B table by table by Restful.
import requests
import json
from requests.auth import HTTPBasicAuth
import sys
import time

euserName="root"
epassWord="taosdata"
eurl="http://192.168.3.21:6041/rest/sql"
edb='db11'

iuserName="root"
ipassWord="taosdata"
iurl="http://192.168.3.21:6041/rest/sql"
idb='db12'

thnum = 20
## Begin time for select data from table.
#stime = str(int(time.time()*1000-86400000))
stime = str(1500000000000)
## Number of one SQL.
offnum = 5000

def request_post(url, sql, user, pwd):
    try:
        sql = sql.encode('utf-8')
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

def export_table(etbname,edbname,eurl,eusername,epassword,itbname,idbname,iurl,iusername,ipassword,stime,offnum):
    countsql = 'select count(*) from '+edbname+'.'+etbname+' where _c0 >='+stime+';'
    result = request_post(eurl, countsql, eusername, epassword)
    load_data = json.loads(result)
    datar = load_data.get("rows")
    row_num = datar
    if row_num != 0:
        data = load_data.get("data")
        count_num = data[0][0]
    if row_num != 0 and count_num != 0:
        if count_num < offnum:
            select_sql = 'select * from '+edbname+'.'+etbname+' where _c0 >='+ stime +';'
#            print(select_sql)
            resInfo = request_post(eurl, select_sql, eusername, epassword)
            imsql = export_sql(idbname,itbname,resInfo)
            resInfo = request_post(iurl, imsql, iusername, ipassword)
            datai = json.loads(resInfo).get("data")
            print("Table Name:",itbname,"\t\tInsert Rows:",datai[0][0])
        else:
            if count_num % offnum == 0:
                rnum = int(count_num/offnum)
            else:
                rnum = int(count_num/offnum)+1
            irows = 0
            for i in range(rnum):
                offset = i * offnum
                select_sql = 'select * from '+edbname+'.'+etbname+' where _c0 >='+ stime +' limit '+str(offnum)+' offset '+str(offset) +';'
#                print(select_sql)
                resInfo = request_post(eurl, select_sql, eusername, epassword)
                imsql = export_sql(idbname,itbname,resInfo)
                resInfo = request_post(iurl, imsql, iusername, ipassword)
                datai = json.loads(resInfo).get("data")
                irows = irows + datai[0][0]
            print("Table Name:",itbname,"\t\tInsert Rows:",irows)

def thfun(tb_list,thread_num,list_num,edbname,eurl,eusername,epassword,idbname,iurl,iusername,ipassword):
    for ll in range(list_num):
        ii=thread_num*list_num+ll
        if ii < len(tblist):
            etbname = str(tb_list[ii])
            itbname = etbname
            export_table(etbname,edbname,eurl,eusername,epassword,itbname,idbname,iurl,iusername,ipassword)


def get_tblist(eurl,edb,euserName, epassWord):
## Get table list from whole database.    
#    tbsql = 'show '+ edb + '.tables;'
## Get table list from stable.
    tbsql = 'select tbname from '+edb+'.meters;'
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
        export_table(tbname,edb,eurl,euserName,epassWord,tbname,idb,iurl,iuserName,ipassWord,stime,offnum)


## Get table list from file.
##
print(type(sys.argv[1]))
#fileobj = open("tblist.txt",'r')
#try:
#    tblist =  fileobj.readlines()
#    for i in range(len(tblist)):
#        tbname = tblist[i].strip('\n')
#        export_table(tbname,edb,eurl,euserName,epassWord,tbname,idb,iurl,iuserName,ipassWord,stime,offnum)
#finally:
#    fileobj.close()




