
from curses.panel import bottom_panel
from logging import logMultiprocessing
import subprocess
import base64
from hashlib import sha256
import hmac
import time
import re
from crypt import methods
from bottle import route, run, template, request, response

def tokenCheck(data, key):
    key = key.encode('utf-8')
    message = data.encode('utf-8')
    sign = base64.b64encode(hmac.new(key, message, digestmod=sha256).digest())
    sign = str(sign, 'utf-8')
    return sign

bkey = '71d8a0d7-508d-4017-8563-60f9099eea71'

returnMsg = '{"resultCode":"000004","resultMsg":"请求已收到，正在处理中！","license":null}'
print(returnMsg)
bsign = tokenCheck(returnMsg,bkey)

print(bsign)