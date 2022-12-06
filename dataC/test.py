import json
import sys

pversion = int(sys.version[0:1])

def get_param(cfgfile):
    global username
    global password
    global database
    global tablename
    if pversion<3:
        with open(cfgfile) as j:
            cfginfo=json.load(j)
            j.close()
    else:
        with open(cfgfile,encoding="utf-8") as j:
            cfginfo=json.load(j)
            j.close()
    username = cfginfo.get("username")
    password = cfginfo.get("password")
    database = cfginfo.get("database")
    tablename = cfginfo.get("tablename")

if __name__ == '__main__':
    cfgfile = 'test.cfg'
    get_param(cfgfile)
    print("Username:",username)
    print("Password:",password)
    print("Database:",database)
    print("Tablename:",tablename)