import requests
from requests.auth import HTTPBasicAuth

userName="root"
passWord="taosdata"
tdurl="http://127.0.0.1:6041/rest/sql"
sql = 'insert into db01.tb1 values(1643738522000,1) (1643738523000,2) (1643738524000,3);'

def request_post(url, sql, user, pwd):
    try:
        result = requests.post(url, data=sql, auth=HTTPBasicAuth(user,pwd))
        text=result.content.decode()
        return text
    except Exception as e:
        print(e)


resInfo = request_post(tdurl, sql, userName, passWord)
print(resInfo)
