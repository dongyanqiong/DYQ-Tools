
import requests
import json
import sys
import getopt
import os
import readline
readline.write_history_file('.history')

def pprint(ss:list):
    lstr=",  ".join([str(s) for s in ss])
    return lstr
def perror(estr:str):
    print(" \n \033[0;37;41mCanot Connecto to {estr}! \033[0m \n ".format(estr=estr))
def status_query(host: str, port: int, user: str, password: str, cmd: str):
    url = "http://%s:%d/rest/sql" % (host, port)
    try:
        resp = requests.post(url, cmd, auth=(user, password),timeout=10)
    except:
        perror(host)
        return(2)
    else:
        return(json.loads(json.dumps(resp.json())))
def rest_print(rvalue:dict):
    rcode=(rvalue['status'])
    if rcode == 'succ': 
        print("\033[0;37;42m{hed}\033[0m".format(hed=pprint(rvalue['head'])))
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
        os.system("clear")
        qr=status_query(host,port,user,password,'select server_version()')
        if qr != 2 and qr['status'] == 'succ':
            version=qr['data'][0][0]
            cquery=status_query(host,port,user,password,'show connections')
            qquery=status_query(host,port,user,password,'show queries')
            cnum=cquery['rows']
            qnum=qquery['rows']
            print('\n\033[0;32;40m TDengine Version:{version} Connections:{cnum} Queries:{qnum} \033[0m\n'.format(version=version,cnum=cnum,qnum=qnum))
            while True:
                    SQL=input("\n\033[0;32;40m[{cname}]>\033[0m".format(cname=host)).strip() 
                    if SQL == 'q':
                        break
                    USERSQL=SQL.replace(';','')
                    qr=status_query(host,port,user,password,USERSQL)
                    if qr != 2:
                        rest_print(qr)    
                        continue
