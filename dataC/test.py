## Transfer data from Database A to Database B table by table by Restful.
import requests
import json
from requests.auth import HTTPBasicAuth
import sys
import time
##python2
##reload(sys)
##sys.setdefaultencoding('utf-8')
###

###Read Config File
with open("datac.cfg",encoding="utf-8") as j:
    data=json.load(j)

euserName=data.get("exportUsername")

print(euserName)