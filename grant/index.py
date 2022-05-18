
import subprocess
import base64
import json
from crypt import methods
from bottle import route, run, template, request

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
    mCode = eval(base64.b64decode(saasExtendParams, altchars=None, validate=False).decode())
    Code = (mCode[0])['value']    
    plicense = subprocess.Popen(['/bin/sh', './grant.sh', '-k', Code],shell=False,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    license = plicense.stdout.readline().strip()
    if len(license) > 10:
        rCode = '000000'
        rMsg = 'Success.'
        return template('{"resultCode":"{{rCode}}","resultMsg":"{{rMsg}}","license":"{{license}}"}', rCode=rCode, rMsg=rMsg,license=license)
    else:
        rCode = '000001'
        rMsg = 'Failed.'
        return template('{"resultCode":"{{rCode}}","resultMsg":"{{rMsg}}","license":"error"}', rCode=rCode, rMsg=rMsg,license=license)


run(host='0.0.0.0', port=80,reloader=True)
