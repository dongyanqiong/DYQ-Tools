import requests
import sys
import datetime
import json
from requests.auth import HTTPBasicAuth
import time
import threading
import multiprocessing

global suserName
global spassWord
global surl
global sdb
global sversion
global duserName
global dpassWord
global durl
global ddb
global dversion
global unit

suserName = 'root'
spassWord = 'taosdata'
surl = 'http://192.168.2.125:6041/rest/sql'
sdb = 'db01'
sversion = 3
duserName = 'root'
duserName = 'root'
dpassWord = 'taosdata'
durl = 'http://10.7.7.14:6041/rest/sql'
ddb = 'db01'
dversion = 3
stime = '2000-01-01T00:00:00.000+00:00'
etime = '2023-10-01T00:00:00.000+00:00'
unit = '1d'

plog = 'process.log'
elog = 'error.log'

def arg_j(sarg):
    try:
        dt = datetime.datetime.fromisoformat(sarg).strftime('%s')
        return dt
    except:
        print("{}. Time only support ISO8601 format!".format(sarg))
        return 1

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

def log_write(logf,elog):
    logf.write(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")+"|\t"+elog+'\n')

def get_tblist(stbname):
    tbl = []
    sql = 'select distinct tbname from `'+sdb+'`.`'+stbname+'`;'
    rt = request_post(surl,sql,suserName,spassWord)
    code = check_return(rt,sversion)
    if code != 'error':
        tbl = json.loads(rt).get("data")
    else:
        print(code)
    return tbl

def get_data(stbname,url,username,password,dbname,version,stime,etime):
    data = dict()
    if version == 2:
        sql = "select count(*) from `"+dbname+'`.`'+stbname+'` where _c0>="'+str(stime)+'" and _c0<="'+str(etime)+'"  group by tbname;'
    else:
        sql = "select count(*),tbname from `"+dbname+'`.`'+stbname+'` where _c0>="'+str(stime)+'" and _c0<="'+str(etime)+'"  group by tbname;'
    rt = request_post(url,sql,username,password)
    code = check_return(rt,version)
    if code != 'error':
        rdata = json.loads(rt).get("data")
        for ll in range(len(rdata)):
            data[rdata[ll][1]]=rdata[ll][0]
    else:
        print(rt)
    return data

def table_diff(tbname):
    tdff = dict()    
    return tdff

if __name__ == '__main__':
    print('-------------------Begin------------------------------')
    if len(sys.argv) >= 3:
        stime = str(sys.argv[1])
        if arg_j(stime) == 1:
            exit()
        etime = str(sys.argv[2])
        if arg_j(etime) == 1:
            exit()
    logp = open(plog,"a")
    loge = open(elog,"a")
    sfile = open('stblist',"r")
    stbl = []
    tb_lost = []
    tb_diff = []
    for stb in sfile:
        stbl.append(stb.strip())
    for stb in stbl:
        sdata = get_data(stb,surl,suserName,spassWord,sdb,sversion,stime,etime)
        ddata = get_data(stb,durl,duserName,dpassWord,ddb,dversion,stime,etime)
        for key in sdata.keys():
            dv = ddata.get(key)
            if str(dv) == 'None':
                tb_lost.append(key)
                log = 'Table:'+key+' not exits in Destination DB: ' + ddb
                #print(log)
                log_write(logp,log)
            else:
                tb_diff.append(key)
                if dv != sdata[key]:
                    rd_diff = sdata[key]-dv
                    log = 'Table:'+key+' Dest:'+str(dv)+' Source:'+str(sdata[key])+' Diff:'+str(rd_diff)
                    #print(log)
                    log_write(logp,log)
    print("Lost tables:{}, Diff tables:{}.".format(len(tb_lost),len(tb_diff)))    

    logp.close()
    loge.close()
    sfile.close()
    print('-------------------END------------------------------')