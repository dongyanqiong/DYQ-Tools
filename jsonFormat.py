import json
import sys
import getopt

cfile = sys.argv[1]

def printjson(vnodej):
    js = json.dumps(vnodej, sort_keys=True, indent=4, separators=(',', ':'))
    print(js)

def writejson(vnodej, ofile):
    try:
        with open(ofile, 'w') as ff:
            json.dump(vnodej, ff)
    except Exception as e:
        print(e)
        sys.exit()

try:
    with open(cfile, 'r') as j:
        vnodej = json.load(j)
        j.close()
except Exception as e:
    print(e)
    sys.exit()

printjson(vnodej)
