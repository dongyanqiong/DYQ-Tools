## Transfer data from Database A to Database B table by table by Restful.
import requests
import json
from requests.auth import HTTPBasicAuth
import sys

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

def get_stblist():
    tblist = []  
    tbsql = 'show '+ edb + '.stables;'
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


def getTableStruc(tblist):
    createSQL = []
    for i in range(len(tblist)):
            etbname = tblist[i]
            getStrcSQL = "show create table "+edb+"."+etbname
            resInfo = request_post(eurl, getStrcSQL, euserName, epassWord)    
            datart = json.loads(resInfo).get("status")
            if str(datart) == 'error':
                print(resInfo)
            else:
                load_data = json.loads(resInfo)
                data = load_data.get("data")
                createSQL.append(str(data[0][1]).replace("CREATE TABLE","CREATE TABLE IF NOT EXISTS"))
    return createSQL

def createTable(cSQL):
    nurl = iurl+'/'+idb
    resInfo = request_post(nurl, cSQL, iuserName, ipassWord) 
    datart = json.loads(resInfo).get("status")
    if str(datart) != 'succ' or str(datart) != '0':
            print(resInfo)

def init_table():
    stblist = get_stblist()
    Stable = getTableStruc(stblist)
    snums = 0
    for i in range(len(Stable)):
        createTable(str(Stable[i]))
        snums += 1
    print("Create Stable:",snums)

    tblist = get_tblist()
    Table = getTableStruc(tblist)
    tnums = 0
    for i in range(len(Table)):
        createTable(str(Table[i]))
        tnums += 1
    print("Create Table:",tnums)


## Check config file
def config_check():
    rvalue = 0
    etestsql = 'show '+edb+'.vgroups'
    itestsql = 'show '+idb+'.vgroups'
    resInfo = request_post(eurl, etestsql, euserName, epassWord)
    datart = json.loads(resInfo).get("status")
    if str(datart) != 'succ' or str(datart) != '0':
        rvalue = 1
        print("Export DB config error!")
    resInfo = request_post(iurl, itestsql, iuserName, ipassWord)
    datart = json.loads(resInfo).get("status")
    if str(datart) != 'succ' or str(datart) != '0':
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
        init_table()
    else:
        print("Config file error!")


