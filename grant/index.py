
from logging import logMultiprocessing
import subprocess
import base64
from hashlib import sha256
import hmac
import time
import taos
from crypt import methods
from bottle import route, run, template, request


def log_write(msg):
    logfile = "./grant_info.log"
    file = open(logfile, 'a')
    file.write(msg)
    file.write('\r\n')
    file.close()

def db_write(msg):
    conn: taos.TaosConnection = taos.connect(host="localhost",
                                         user="root",
                                         password="taosdata",
                                         database="grant_log",
                                         port=6030,
                                         config="/etc/taos",  
                                         timezone="Asia/Shanghai")  
    conn.execute(msg)
    conn.close()


def tokenCheck(data, key):
    key = key.encode('utf-8')
    message = data.encode('utf-8')
    sign = base64.b64encode(hmac.new(key, message, digestmod=sha256).digest())
    sign = str(sign, 'utf-8')
    return sign

@route('/grant/')
def do_grant():
    activity = request.GET.get('activity')
    businessId = request.GET.get('businessId')
    chargingMode = request.GET.get('chargingMode')
    customerId = request.GET.get('customerId')
    customerName = request.GET.get('customerName')
    expireTime = request.GET.get('expireTime')
    orderId = request.GET.get('orderId')
    periodNumber = request.GET.get('periodNumber')
    periodType = request.GET.get('periodType')
    productId = request.GET.get('productId')
    provisionType = request.GET.get('provisionType')
    saasExtendParams = request.GET.get('saasExtendParams')
    testFlag = request.GET.get('testFlag')
    timeStamp = request.GET.get('timeStamp')
    userId = request.GET.get('userId')
    userName = request.GET.get('userName')
    authToken = request.GET.get('authToken')

    longMsg = "activity="+activity+"&businessId="+businessId+"&chargingMode="+chargingMode+"&customerId="+customerId+"&customerName="+customerName+"&expireTime="+expireTime+"&orderId="+orderId+"&periodNumber="+periodNumber+"&periodType="+periodType+"&productId="+productId+"&provisionType="+provisionType+"&saasExtendParams="+saasExtendParams+"&testFlag="+testFlag+"&timeStamp="+timeStamp+"&userId="+userId+"&userName="+userName
    key = "71d8a0d7-508d-4017-8563-60f9099eea71"+timeStamp
    Ctoken = tokenCheck(longMsg,key)
    if Ctoken == authToken:
        mCode = eval(base64.b64decode(saasExtendParams, altchars=None, validate=False).decode())
        Code = (mCode[0])['value'] 
        ltime = int(time.time()*1000//1)
        if len(Code) == 24:
            plicense = subprocess.Popen(['/bin/sh', './grant.sh', '-k', Code],shell=False,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
            license = plicense.stdout.readline().strip()
            sql = "insert into grant_log.url_log values(now,\'"+activity+"\',\'"+businessId+"\',\'"+chargingMode+"\',\'"+customerId+"\',\'"+customerName+"\',\'"+expireTime+"\',\'"+orderId+"\',\'"+periodNumber+"\',\'"+periodType+"\',\'"+productId+"\',\'"+provisionType+"\',\'"+saasExtendParams+"\',\'"+testFlag+"\',\'"+timeStamp+"\',\'"+userId+"\',\'"+userName+"\',\'"+authToken+"\',\'"+str(license,'UTF-8')+"\');"
            db_write(str(sql))
            rCode = '000000'
            rMsg = 'Success.'
        else:
            rCode = '000001'
            rMsg = 'machineCode Error.'
            license = '0000000000'
    else:
        rCode = '000002'
        rMsg = 'authToken Error.'
        license = '0000000000'
    
    return template('{"resultCode":"{{rCode}}","resultMsg":"{{rMsg}}","license":"{{license}}"}', rCode=rCode, rMsg=rMsg,license=license)


run(host='0.0.0.0', port=80,reloader=True)
    


