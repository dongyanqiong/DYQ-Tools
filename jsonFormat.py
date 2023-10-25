import json

with open('current.json') as j:
    vnodej=json.load(j)
    j.close()
js = json.dumps(vnodej,sort_keys=True,indent=4,separators=(',',':'))
print(js)
