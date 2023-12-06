import json
import sys
import logging
import os

logging.basicConfig(level=logging.INFO)
global cfile
datadir = [
    ['/data1',
     '/data2',
     '/data3'],
    ['/data4',
     '/data5',
     '/data6'],
    ['/data7',
     '/data8']
]

if len(sys.argv) == 4:
    cfile = sys.argv[1]
    sfile = sys.argv[2]
    ddir = sys.argv[3]
    if ddir[-1] == '/':
        ddir = ddir.rstrip('/')
else:
    logging.info(
        "python3 filemv.py current.json /data7/vnode/vnode4/tsdb/v4f1933ver15.head /data8")
    sys.exit()

def file_exist(filename):
    if os.path.exists(filename):
        return 0
    else:
        logging.error(f"{filename} not exist!")
        sys.exit()

file_exist(cfile)
file_exist(sfile)
file_exist(ddir)

sfile_k = sfile.split('/')
sfile_l = sfile.split('/vnode')

def looup_data(dpath, dlist):
    for ind_1 in range(len(dlist)):
        for ind_2 in range(len(dlist)):
            try:
                if dlist[ind_1][ind_2] == dpath:
                    return ind_1, ind_2
            except Exception as e:
                logging.error(f"{dpath} not found in dataDir!")
                logging.info(dlist)
                sys.exit()


sLe_1, sLe_2 = looup_data(sfile_l[0], datadir)
dLe_1, dLe_2 = looup_data(ddir, datadir)
if sLe_1 == dLe_1 and sLe_2 == dLe_2:
    logging.error("Target location is the same as the original path!")
    logging.debug(f"{sfile},{ddir}")
    sys.exit()

def mv_file(file, path):
    import subprocess
    try:
        print(f"mv {file} {path}")
        rt = subprocess.run(["mv", file, path])
        return rt.returncode
    except Exception as e:
        logging.error(f"{e}")
        return -1


fname_l = list(sfile_k[len(sfile_k)-1])
fname_l.pop(0)

dfid = int(''.join(fname_l[fname_l.index('f')+1:fname_l.index('v')]))
dver = int(''.join(fname_l[fname_l.index('r')+1:fname_l.index('.')]))
dtype = str(''.join(fname_l[fname_l.index('.')+1:len(fname_l)]))
if dtype == 'stt':
    dtype = 'stt lvl'
    print("Stt file not support!!")
    sys.exit()
logging.debug(
    f"fid: {dfid}, type:{dtype}, version: {dver},Levle: {sLe_1},{sLe_2},{dLe_1},{dLe_2}")


def printjson(vnodej):
    js = json.dumps(vnodej, sort_keys=True, indent=4, separators=(',', ':'))
    print(js)


def fileMv(vnodej, dfid, dver, sLe_1, sLe_2, dLe_1, dLe_2):
    print("============Warning=======================")
    print(" Excute the python shell is very dangerous!")
    print(" Before mv the file, you shuold make sure:\n")
    print(" 1. current.json and file has been backup.")
    print(" 2. Process taosd has been stopped.\n")
    notice = input("Enter y to continue: ")
    if notice != 'y':
        sys.exit()
    result = 0
    for ff in vnodej['fset']:
        for key, value in ff.items():
            if key == dtype:
                logging.debug(f"key_value: {key},{value}")
                logging.debug(f"value Type: {type(value)}")
                if dtype == 'stt lvl':
                    logging.error("Stt file not support!!")
                    sys.exit()
                else:
                    while isinstance(value, list):
                        value = value[0]['files']
                if value:
                    fvalue = value
                    logging.debug(f"favlue:  {type(fvalue)}  {fvalue}")
                    logging.debug(f"favlue Type: {fvalue.keys()}")
                    if fvalue['fid'] == dfid and fvalue['cid'] == dver and fvalue['did.level'] == sLe_1 and fvalue['did.id'] == sLe_2:
                        sfile_k[1] = ddir
                        dpath = '/'.join(sfile_k[1:len(sfile_k)-1])+'/'
                        rt = mv_file(sfile, dpath)
                        if rt == 0:
                            fvalue['did.levle'] = dLe_1
                            fvalue['did.id'] = dLe_2
                            outf = open(cfile, 'w')
                            json.dump(vnodej, outf)
                            outf.close()
                            print(f"{cfile} is overwrite!")
                            result = 1
                        else:
                            logging.error("File move failed!")
    if result == 0:
        logging.error(f"File not found in current.json!")


try:
    with open(cfile, 'r') as j:
        vnodej = json.load(j)
        j.close()
except Exception as e:
    logging.error(e)
    sys.exit()

fileMv(vnodej, dfid, dver, sLe_1, sLe_2, dLe_1, dLe_2)
# printjson(vnodej)
