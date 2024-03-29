#!/usr/bin/python3
import requests
import json
import sys
import getopt
import os
commonds = [
'SHOW TABLES','SHOW DNODES','SHOW MNODES','SHOW VGROUPS','SHOW CONNECTIONS','SHOW VARIABLES','SHOW QUERIES','SHOW SCORES',
'CREATE DATABASE','CREATE STABLE','CREATE TABLE','CREATE USER',
'ALTER DATABASE','ALTER TABLE','ALTER STABLE','ALTER USER',
'BOOL','TINYINT','SMALLINT','INT','BIGINT','FLOAT','DOUBLE','STRING',
'TIMESTAMP','BINARY','NCHAR','JSON','OR','AND','NOT','EQ','NE','ISNULL','NOTNULL','IS','LIKE','MATCH','NMATCH','CONTAINS',
'GLOB','BETWEEN','IN','GT','GE','LT','LE','BITAND','BITOR','BITXOR','LSHIFT','RSHIFT','SHOW','DATABASES','TOPICS',
'FUNCTIONS','MNODES','DNODES','ACCOUNTS','USERS','QUERIES','CONNECTIONS','STREAMS',
'VARIABLES','SCORES','GRANTS','VNODES','DOT','CREATE','COUNT()','LAST()','LAST_ROW()','FIRST()','AVG()','MAX()','MIN()','SUM()',
'TABLE','STABLE','DATABASE','TABLES','STABLES','VGROUPS','DROP',
'TOPIC','DNODE','USER','ACCOUNT','USE','DESCRIBE','REPLICA','BLOCKS','KEEP',
'ALTER','PASS','PRIVILEGE','LOCAL','COMPACT','IF','EXISTS',
'AS','SELECT','UNION','ALL','DISTINCT','FROM','RANGE()','INTERVAL()','EVERY()','_BLOCK_DIST()','SERVER_VERSION()','CLIENT_VERSION()','SERVER_STATUS()',
'SESSION','STATE_WINDOW()','FILL()','SLIDING','ORDER',
'BY','ASC','GROUP','HAVING','LIMIT','OFFSET','SLIMIT',
'SOFFSET','WHERE','TODAY','RESET','QUERY','ADD',
'COLUMN','MODIFY','TAG','CHANGE','SET','KILL','CONNECTION',
'STREAM','COLON','DELETE','ABORT','AFTER','ATTACH','BEFORE','BEGIN','CASCADE','NONE','PREV',
'LINEAR','IMPORT','TBNAME','JOIN','INSERT','INTO','VALUES','FILE'
]

def complete(text,state):
    for cmd in commonds:
        if cmd.startswith(text.upper()):
            if not state:
                return cmd
            else:
                state -= 1

def pprint(ss:list):
    lstr=",  ".join([str(s) for s in ss])
    return lstr
def perror(estr:str):
    print(" \n Canot Connecto to {estr}!  \n ".format(estr=estr))
def status_query(host: str, port: int, user: str, password: str, cmd: str):
    url = "http://%s:%d/rest/sql" % (host, port)
    try:
        resp = requests.post(url, cmd.encode('utf-8'), auth=(user, password),timeout=10)
    except:
        perror(host)
        return(2)
    else:
        return(json.loads(json.dumps(resp.json())))
def rest_print(rvalue:dict):
    rcode=(rvalue['status'])
    if rcode == 'succ': 
        print("{hed}".format(hed=pprint(rvalue['head'])))
        data_ll=len(rvalue['data'])
        if data_ll == 0:
            data_l=1
        else:
            data_l=len(str(rvalue['data'][0]))
        head='-'
        print(head.center(data_l,'-'))
        for ii in range(data_ll):
            print(pprint(rvalue['data'][ii]))
            iii=ii+1
            if iii>90 and iii%100 == 0:
                anykey=input("{rnum} rows output.Press Enter to Contine [q for Quit]......".format(rnum=iii)).strip() 
                if anykey == 'q':
                    break
    else:
        print(" \n Excute Error, {error} !\n ".format(error=rvalue['desc']))

if len(sys.argv) <= 1:
    print('\nptaos.py -h host [-p port -u root -P password]\n')
    exit
else:
    try:
        opts,args=getopt.getopt(sys.argv[1:],"h:p:u:P")
    except getopt.GetoptError:
        print('\nptaos.py -h host [-p port -u root -P password]\n')
        sys.exit
    else:
        host=''
        port=6041
        user='root'
        password='taosdata'
        for opt,arg in opts:
            if opt == '-h':
                host=arg
            elif opt== '-p':
                port=int(arg)
            elif opt == '-u':
                user=arg
            elif opt == '-P':
                passowrd=arg
            else:
                sys.exit
        os.system("cls")
        qr=status_query(host,port,user,password,'select server_version()')
        if qr != 2 and qr['status'] == 'succ':
            version=qr['data'][0][0]
            cquery=status_query(host,port,user,password,'show connections')
            qquery=status_query(host,port,user,password,'show queries')
            cnum=cquery['rows']
            qnum=qquery['rows']
            print('\n TDengine Version:{version} Connections:{cnum} Queries:{qnum} \n'.format(version=version,cnum=cnum,qnum=qnum))
            while True:
                    #SQL=input("\n[{cname}]>".format(cname=host)).strip() 
                    SQL=input("\n[{cname}]>".format(cname=host)).strip() 
                    if SQL.lower() == 'q' :
                        break
                    USERSQL=SQL.replace(';','')
                    qr=status_query(host,port,user,password,USERSQL)
                    if qr != 2:
                        rest_print(qr)    
                        continue
