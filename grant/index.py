
from curses.panel import bottom_panel
from logging import logMultiprocessing
import subprocess
import base64
from hashlib import sha256
import hmac
import time
import taos
from crypt import methods
from bottle import route, run, template, request, response

##写入本地日志
def log_write(msg):
    logfile = "./grant_info.log"
    file = open(logfile, 'a')
    file.write(msg)
    file.write('\r\n')
    file.close()

##将传递的SQL写入TDengine数据库
def db_write(msg):
    try:
        conn: taos.TaosConnection = taos.connect(host="localhost",
                                         user="root",
                                         password="taosdata",
                                         database="grant_log",
                                         port=6030,
                                         config="/etc/taos",  
                                         timezone="Asia/Shanghai")  

        affected_row: int = conn.execute(msg)
        conn.close()
        if affected_row == 1:
            err = 0
        else:
            err = 1
    except:
        err = 1
    return err

##将从TDengine数据库查询测点数
def db_select(msg):
    try:
        conn: taos.TaosConnection = taos.connect(host="localhost",
                                         user="root",
                                         password="taosdata",
                                         database="grant_log",
                                         port=6030,
                                         config="/etc/taos",  
                                         timezone="Asia/Shanghai")  

        result: taos.TaosResult = conn.query(msg)
        for row in result:
            rmsg = row[0]
        conn.close()
    except:
        rmsg = 0
    return rmsg

def timeConvert(otime):
    rtime = otime[0:4]+"-"+otime[4:6]+"-"+otime[6:8]
    return rtime

##根据华为云算法生成authToken，传递参数（需加密字符串，key）
def tokenCheck(data, key):
    key = key.encode('utf-8')
    message = data.encode('utf-8')
    sign = base64.b64encode(hmac.new(key, message, digestmod=sha256).digest())
    sign = str(sign, 'utf-8')
    return sign

##调用授权系统，生成授权码，要求传递(到期时间，测点数，机器码)
def licenseGrant(etime,tser,mcode):
    plicense = subprocess.Popen(['/bin/sh', './grant.sh', '-k', mcode],shell=False,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    lic = plicense.stdout.readline().strip()
    return str(lic,'UTF-8')

##监听grant，对传入变量进行处理
@route('/grant/')
def do_grant():
    ##预设默认返回值
    rCode = '000005'
    rMsg = 'unknown Error.'
    license = '0000000000'
    bkey = '71d8a0d7-508d-4017-8563-60f9099eea71'

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

    if activity == 'getLicense':
        ##根据传入变量生成要加密的字符串
        longMsg = "activity="+activity+"&businessId="+businessId+"&chargingMode="+chargingMode+"&customerId="+customerId+"&customerName="+customerName+"&expireTime="+expireTime+"&orderId="+orderId+"&periodNumber="+periodNumber+"&periodType="+periodType+"&productId="+productId+"&provisionType="+provisionType+"&saasExtendParams="+saasExtendParams+"&testFlag="+testFlag+"&timeStamp="+timeStamp+"&userId="+userId+"&userName="+userName
        key = bkey+timeStamp
        Ctoken = tokenCheck(longMsg,key)

        if Ctoken == authToken:
            psql = 'select last(snum) from grant_log.product_info where productid="'+productId+'";';
            serNum = db_select(psql)
            etime = timeConvert(str(20220531202610))
            mCode = eval(base64.b64decode(saasExtendParams, altchars=None, validate=False).decode())
            Code = (mCode[0])['value'] 
            if len(Code) == 24 and serNum > 0:
                license = licenseGrant(etime,serNum,Code)
                sql = "insert into grant_log.url_log values(now,\'"+activity+"\',\'"+businessId+"\',\'"+chargingMode+"\',\'"+customerId+"\',\'"+customerName+"\',\'"+expireTime+"\',\'"+orderId+"\',\'"+periodNumber+"\',\'"+periodType+"\',\'"+productId+"\',\'"+provisionType+"\',\'"+saasExtendParams+"\',\'"+testFlag+"\',\'"+timeStamp+"\',\'"+userId+"\',\'"+userName+"\',\'"+authToken+"\',\'"+license+"\');"
                if db_write(str(sql)) == 0:
                    rCode = '000000'
                    rMsg = 'Success.'
                else:
                    rCode = '000005'
                    rMsg = 'Write DB Failed.'
                    license = '0000000000'
            else:
                rCode = '000001'
                rMsg = 'machineCode is invalid.'
                license = '0000000000'
        else:
            rCode = '000002'
            rMsg = 'authToken Error.'
            license = '0000000000'
    else:
        rCode = '000002'
        rMsg = 'Invalid Argument.'
        license = '0000000000'
    
    returnMsg = '{"resultCode":"'+rCode+'","resultMsg":"'+rMsg+'","license":"'+license+'"}'
    bsign = tokenCheck(returnMsg,bkey)
    httpMsg='sign_type="HMAC-SHA256", signature= "'+bsign+'"'
    response.add_header('Body-Sign', httpMsg)
    return template(returnMsg)
    #return template('{"resultCode":"{{rCode}}","resultMsg":"{{rMsg}}","license":"{{license}}"}', rCode=rCode, rMsg=rMsg,license=license)


if __name__ == '__main__':
    run(host='0.0.0.0', port=80,reloader=True)
    


