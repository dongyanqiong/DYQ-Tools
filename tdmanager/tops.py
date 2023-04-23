#!/usr/bin/python3
##
##This is tools is design for mangae TDengine Cluster or Nodes.
##Befor use this tools, you must config the host.cfg file.
##

import requests
import json
import os
from requests.api import request
import readline
readline.write_history_file('.history')

###Read Config File
with open("host.cfg",encoding="utf-8") as j:
    data=json.load(j)

CLUSTERS=data

###SQL
SQL_MNODES='show mnodes'
SQL_DNODES='show dnodes'
SQL_DATABASES='show databases'
SQL_VERSION='select server_version()'
SQL_GRANTS='show grants'
SQL_STABLES='show stables'
SQL_CONNECT='show connections'
SQL_QUERY='show queries'


###Join List to Str
def pprint(ss:list):
    lstr=",  ".join([str(s) for s in ss])
    return lstr

###Print Error Message
def perror(estr:str):
    print(" \n \033[0;37;41mCanot Connecto to {estr}! Pleace Check you Config or TDening Process.\033[0m \n ".format(estr=estr))

###Menu Print
def mprint(id:int,meg:str):
    print("\033[0;32;40m%2s. %-20s\033[0m" %(id,meg))

###RESTFul Query&Print
def status_query(host: str, port: int, user: str, password: str, cmd: str):
    url = "http://%s:%d/rest/sql" % (host, port)
    resp = requests.post(url, cmd, auth=(user, password))
    return(json.loads(json.dumps(resp.json())))

def rest_print(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ': 
        print("\033[0;37;42m{hed}\033[0m".format(hed=pprint(dvalue['head'])))
        data_l=len(dvalue['data'])
        for ii in range(data_l):
            vcv=0
            dvl=str(dvalue['data'][ii])
            if (dvl.find('offline')) != -1:
                vcv=1
            if vcv == 1:
                print("\033[0;37;41m{stv}\033[0m".format(stv=pprint(dvalue['data'][ii])))
            else:
                print(pprint(dvalue['data'][ii]))
    else:
        print(" \n Excute Error, {error} !\n ".format(error=dvalue['desc']))

###Return Value Format Print
def dnode_print(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ':   
        print("\n\033[0;37;42m -------Dnode Status-----------\033[0m")
        print("%-2s %-20s %8s %10s %8s %20s" % (dvalue['head'][0],dvalue['head'][1],dvalue['head'][2],dvalue['head'][4],dvalue['head'][5],dvalue['head'][7]))
        data_l=len(dvalue['data'])
        for i in range(data_l):
            if dvalue['data'][i][4] == 'ready':
                print("%-2d %-20s %8d %10s %8s %20s" % (dvalue['data'][i][0],dvalue['data'][i][1],dvalue['data'][i][2],dvalue['data'][i][4],dvalue['data'][i][5],dvalue['data'][i][7]))
            else:
                print("\033[0;37;41m%-2d %-20s %8d %10s %8s %20s\033[0m" % (dvalue['data'][i][0],dvalue['data'][i][1],dvalue['data'][i][2],dvalue['data'][i][4],dvalue['data'][i][5],dvalue['data'][i][7]))
        print()
    else:
        perror()

def mnode_print(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ': 
        print("\n\033[0;37;42m -------Mnode Status-----------\033[0m")
        print("%-2s %-20s %8s" % (dvalue['head'][0],dvalue['head'][1],dvalue['head'][2]))
        data_l=len(dvalue['data'])
        for i in range(data_l):
            if dvalue['data'][i][2] == 'master' or dvalue['data'][i][2] == 'slave' or dvalue['data'][i][2] == 'leader' or dvalue['data'][i][2] == 'follower':
                print("%-2d %-20s %8s" % (dvalue['data'][i][0],dvalue['data'][i][1],dvalue['data'][i][2]))
            else:
                print("\033[0;37;41m%-2d %-20s %8s\033[0m" % (dvalue['data'][i][0],dvalue['data'][i][1],dvalue['data'][i][2]))
        print()
    else:
        perror()

def db_print(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ': 
        print("\n\033[0;37;42m -------DataBases Status-----------\033[0m")
        print("%-20s %8s %8s %8s %8s %10s" % (dvalue['head'][0],dvalue['head'][3],dvalue['head'][4],dvalue['head'][6],dvalue['head'][9],dvalue['head'][18]))
        data_l=len(dvalue['data'])
        for i in range(data_l):
            if dvalue['data'][i][18] == 'ready':
                print("%-20s %8d %8d %8d %8d %10s" % (dvalue['data'][i][0],dvalue['data'][i][3],dvalue['data'][i][4],dvalue['data'][i][6],dvalue['data'][i][9],dvalue['data'][i][18]))
            else:
                print("\033[0;37;41m%-20s %8d %8d %8d %8d %10s\033[0m" % (dvalue['data'][i][0],dvalue['data'][i][3],dvalue['data'][i][4],dvalue['data'][i][6],dvalue['data'][i][9],dvalue['data'][i][18]))
        print()
    else:
        perror()

def grant_print(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ': 
        print("\n\033[0;37;42m -------Grant Status-----------\033[0m")
        print(" %-30s %-20s" % ('Expire Time','Timeseries'))
        data_l=len(dvalue['data'])
        for i in range(data_l):
            if dvalue['data'][i][2] != 'true':
                print(" %-30s %-20s" % (dvalue['data'][i][1],dvalue['data'][i][4]))
            else:
                print("\033[0;37;41m%-30s %-20s\033[0m" % (dvalue['data'][i][1],dvalue['data'][i][4]))
        print()

def version_print(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ': 
        version=dvalue['data'][0][0]
    return version

###Status Check
def dnode_check(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ':   
        d_h=0
        data_l=len(dvalue['data'])
        for i in range(data_l):
            if dvalue['data'][i][4] != 'ready':
                d_h=1
        if d_h == 0:
            print("\033[0;32;40mDnode is OK!\033[m")
        else:
            print("\n\033[0;37;41mDnode is OFFLINE!\033[0m\n")
            print("%-2s %-20s %8s %10s %8s %20s" % (dvalue['head'][0],dvalue['head'][1],dvalue['head'][2],dvalue['head'][4],dvalue['head'][5],dvalue['head'][7]))
            data_l=len(dvalue['data'])
            for i in range(data_l):
                if dvalue['data'][i][4] != 'ready':
                    print("%-2d %-20s %8d %10s %8s %20s" % (dvalue['data'][i][0],dvalue['data'][i][1],dvalue['data'][i][2],dvalue['data'][i][4],dvalue['data'][i][5],dvalue['data'][i][7]))
        print()
    else:
        perror()

def mnode_check(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ':   
        d_h=0
        data_l=len(dvalue['data'])
        for i in range(data_l):
            if dvalue['data'][i][2] == 'offline':
                d_h=1
        if d_h == 0:
            print("\033[0;32;40mMnode is OK!\033[0m")
        else:
            print("\n\033[0;37;41mMnode is OFFLINE!\033[0m\n")
            print("%-2s %-20s %20s" % (dvalue['head'][0],dvalue['head'][1],dvalue['head'][2]))
            data_l=len(dvalue['data'])
            for i in range(data_l):
                if dvalue['data'][i][2] == 'offline':
                    print("%-2d %-20s %20s" % (dvalue['data'][i][0],dvalue['data'][i][1],dvalue['data'][i][2]))
        print()
    else:
        perror()

def db_check(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ': 
        d_h=0
        data_l=len(dvalue['data'])
        for i in range(data_l):
            if dvalue['data'][i][18] != 'ready':
                d_h=1
        if d_h == 0:
            print("\033[0;32;40mDatabases is OK!\033[0m")
        else:
            print("\n\033[0;37;41mDatabases is not Ready!\033[0m\n")
            print("%-20s %8s %8s %8s %8s %10s" % (dvalue['head'][0],dvalue['head'][3],dvalue['head'][4],dvalue['head'][6],dvalue['head'][9],dvalue['head'][18]))
            data_l=len(dvalue['data'])
            for i in range(data_l):
                print("%-20s %8d %8d %8d %8d %10s" % (dvalue['data'][i][0],dvalue['data'][i][3],dvalue['data'][i][4],dvalue['data'][i][6],dvalue['data'][i][9],dvalue['data'][i][18]))
            print()
    else:
        perror()

def dnode_check2(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ':   
        d_h=0
        data_l=len(dvalue['data'])
        for i in range(data_l):
            if dvalue['data'][i][4] != 'ready':
                d_h=1
        if d_h == 0:
            rv=0
        else:
            rv=1
    else:
        rv=3
    return rv

def mnode_check2(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ':   
        d_h=0
        data_l=len(dvalue['data'])
        for i in range(data_l):
            if dvalue['data'][i][2] == 'offline':
                d_h=1
        if d_h == 0:
            rv=0
        else:
            rv=1
    else:
        rv=3
    return rv

def db_check2(dvalue:dict):
    rcode=(dvalue['status'])
    if rcode == 'succ': 
        d_h=0
        data_l=len(dvalue['data'])
        for i in range(data_l):
            if dvalue['data'][i][18] != 'ready':
                d_h=1
        if d_h == 0:
            rv=0
        else:
            rv=1
    else:
        rv=3
    return rv

def num_check(dvalue:dict):
    rv=0
    rcode=(dvalue['status'])
    if rcode == 'succ': 
        rv=dvalue['rows']
    return rv


###Dnode Avriable Check
def avriable_chek(key:str):
    key_l=len(CLUSTERS[key])
    a_did=9999
    for id in range(key_l):
        host=CLUSTERS[key][id][0]
        port=CLUSTERS[key][id][3]
        user=CLUSTERS[key][id][2]
        password=CLUSTERS[key][id][2]
        cmd='select server_status()'
        url = "http://%s:%d/rest/sql" % (host, port)
        try:
            requests.post(url, cmd, auth=(user, password),timeout=10)
        except: 
            print()      
            perror(CLUSTERS[key][id][0])
        else:
            a_did=id
            break
    return a_did

###Status View
def status_view(host: str, port: int, user: str, password: str):
    grant_print(status_query(host,port,user,password,SQL_GRANTS))
    dnode_print(status_query(host,port,user,password,SQL_DNODES))
    mnode_print(status_query(host,port,user,password,SQL_MNODES))
    db_print(status_query(host,port,user,password,SQL_DATABASES))

###Title
def title_print():
    print()
    title="TDengine Operation Tools(beta)"
    head="#"
    head_f=(head.center(90,'#'))
    title_f=(title.center(90,'#'))
    print("\033[0;32;40m{head_f}\033[0m".format(head_f=head_f))
    print("\033[0;32;40m{title_f}\033[0m".format(title_f=title_f))
    print("\033[0;32;40m{head_f}\033[0m".format(head_f=head_f))
    print()

####Main Menu
menu={
    '1.TDengine Cluster Status View':{

    },
    '2.TDengine Cluster Mangement':{

    },
    '3.TDengine Cluster Heathly Check':{

    }
}

####Cluster Menu
num=1
meu={}
for key in (data.keys()):
    nkey=str(num)
    meu[nkey]=key
    num=num+1

####Main
floor=menu
empty_list=[]


####Mangment Menu
mmenu={
    "1":"Show Dnode",
    "2":"Show Mnode",
    "3":"Show Database",
    "4":"Show grants",
    "5":"Show version",
    "6":"Show stables",
    "7":"Custom SQL"
}


while True:
    os.system("clear")
    title_print()
    for key in floor:
        print("\033[0;32;40m{key}\033[0m\n".format(key=key))
    choice=input("\nPlease intput [q for Quit]:").strip()
    if len(choice) == 0:
        continue
    elif choice == 'q':
        break
    elif choice == '1':
        while True:
            os.system("clear")
            title_print()
            print('\n\033[0;32;40mCluster Status View\033[0m\n')
            keys=len(CLUSTERS)+1
            for kid in (meu.keys()):
                mprint(kid,meu[kid])
            mprint(keys,'ALL')
            c_chioce=input("\nInput the Cluster ID or [q for Quit]:").strip()
            if len(c_chioce) == 0:
                continue
            elif c_chioce == 'q':
                break
            elif c_chioce == str(keys):
                for key in CLUSTERS.keys():
                    aid=avriable_chek(key)
                    if aid == 9999:
                        perror(key)
                        anykey=input("\nPress any key to continue......").strip()
                    else:
                        print()
                        tdv=version_print(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],SQL_VERSION))
                        print('\033[0;32;40m###### %-20s Version: %-10s\033[0m' % (key,tdv))
                        status_view(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2])
                anykey=input("\nPress any key to continue......").strip() 
            elif c_chioce in meu.keys():
                key=meu[c_chioce]
                aid=avriable_chek(key)
                if aid == 9999:
                        perror(key)
                        anykey=input("\nPress any key to continue......").strip()
                else:
                    print()
                    tdv=version_print(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],SQL_VERSION))
                    cnum=num_check(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],SQL_CONNECT))
                    qnum=num_check(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],SQL_QUERY))
                    print('\033[0;32;40m###### %-20s Version:%-10s  Connections:%-5d  Queries:%-5d\033[0m' % (key,tdv,cnum,qnum))
                    status_view(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2])
                    anykey=input("\nPress any key to continue......").strip() 
            else:
                anykey=input("\nCluster ID is invald!\n")     
    elif choice == '2':
        while True:
            os.system("clear")
            title_print()
            print('\n\033[0;32;40mTDengine Cluster Mangement\033[0m\n')
            keys=len(CLUSTERS)+1
            for kid in (meu.keys()):
                mprint(kid,meu[kid])
            mprint(keys,'Custom')
            c_chioce=input("\nInput the Cluster ID or [Type q for Quit]:").strip()
            if len(c_chioce) == 0:
                continue
            elif c_chioce == 'q':
                break
            elif c_chioce == str(keys):
                host=input("\nHOST:").strip()
                if host == 'q':
                    break
                user=input("\nUSER:").strip()
                if user == 'q':
                    break
                password=input("\nPASS:").strip()
                if password == 'q':
                    break
                port=input("\nPORT:").strip()
                if port == 'q':
                    break
                port=int(port)
                while True:
                    SQL=input("\n[{cname}]>".format(cname=host)).strip() 
                    if SQL == 'q':
                        break
                    USERSQL=SQL.replace(';','')
                    rest_print(status_query(host,port,user,password,USERSQL))
            elif c_chioce in meu.keys():                   
                key=meu[c_chioce]
                aid=avriable_chek(key)
                if aid == 9999:
                    perror(key)
                    anykey=input("\nPress any key to continue......").strip()
                else:
                    print()
                    print('\033[0;32;40m###### %-20s\033[0m' % (key))
                    print("\nPlease intput your commond(type q for Quit):")
                    while True:
                        SQL=input("\n\033[0;32;40m[{cname}]>\033[0m".format(cname=key)).strip() 
                        if SQL == 'q':
                            break
                        USERSQL=SQL.replace(';','')
                        rest_print(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],USERSQL))    
            else:
                anykey=input("\nInvalid Choice! \n").strip() 
    elif choice == '3':
        os.system("clear")
        title_print()
        print("\n\033[0;32;40mCluster Heathly Check\033[0m\n")
        for key in CLUSTERS.keys():
            key_l=len(CLUSTERS[key])
            aid=avriable_chek(key)
            if aid == 9999:
                perror(key)
            else:
                cstatus=0
                dc=dnode_check2(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],SQL_DNODES))
                if dc != 0:
                    cstatus=1
                mc=mnode_check2(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],SQL_MNODES))
                if mc != 0:
                    cstatus=1
                dbc=db_check2(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],SQL_DATABASES))
                if dbc != 0:
                    cstatus=1
                if cstatus == 0:
                    print('\n\033[0;37;42m## %-20s    OK\033[0m' % (key))
                else:
                    print('\n\033[0;37;41m## %-20s ERROR\033[0m' % (key))
                    if dc !=0:
                        dnode_check(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],SQL_DNODES))
                    if mc !=0:
                        mnode_check(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],SQL_MNODES))
                    if dbc !=0:
                        db_check(status_query(CLUSTERS[key][aid][0],CLUSTERS[key][aid][3],CLUSTERS[key][aid][1],CLUSTERS[key][aid][2],SQL_DATABASES))

        anykey=input("\nPress any key to continue......").strip() 
    else:
        anykey=input("\nInvalid Choice! \n").strip() 

