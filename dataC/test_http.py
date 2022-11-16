import requests
from requests.auth import HTTPBasicAuth

userName="root"
passWord="taosdata"
url="http://192.168.3.21:6041/rest/sql"
sql_create = 'create table if not exists db01.test03(ts timestamp,v1 int);'
sql_insert = 'insert into db01.test03 values(1643731200000,1);'
sql_select = 'select * from db01.test03;'

def request_post(url, sql, user, pwd):
    try:
        result = requests.post(url, data=sql, auth=HTTPBasicAuth(user,pwd))
        text=result.content.decode()
        return text
    except Exception as e:
        print(e)


request_post(url, sql_create, userName, passWord)
restInfo = request_post(url, sql_insert, userName, passWord)
print(restInfo)
resInfo = request_post(url, sql_select, userName, passWord)
print(resInfo)
