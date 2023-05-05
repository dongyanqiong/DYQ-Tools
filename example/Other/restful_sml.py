import requests
from requests.auth import HTTPBasicAuth

userName="root"
passWord="taosdata"
tdurl="http://127.0.0.1:6041/influxdb/v1/write?db=db01"
fgf = 0x0a
sql = 'stb1,t1=12 c1=3i64,c2=124,c3=123 1642931251000000000'+chr(fgf)+'stb1,t1=12 c1=3i64,c2=124,c3=123 1642931252000000000'

def request_post(url, sql, user, pwd):
    try:
        result = requests.post(url, data=sql, auth=HTTPBasicAuth(user,pwd))
        text=result.content.decode()
        return text
    except Exception as e:
        print(e)


resInfo = request_post(tdurl, sql, userName, passWord)
print(resInfo)


