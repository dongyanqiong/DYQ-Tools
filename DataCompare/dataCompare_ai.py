import requests
import sys
import datetime
import json
from requests.auth import HTTPBasicAuth
import configparser


def arg_j(sarg):
    """Parse time string in ISO8601 format to timestamp."""
    try:
        dt = datetime.datetime.fromisoformat(sarg).strftime('%s')
        return dt
    except ValueError:
        sys.exit(f"{sarg}. Time only support ISO8601 format!")


def request_post(url, sql, user, pwd):
    """Post request to specific url."""
    try:
        sql = sql.encode("utf-8")
        headers = {
            'Connection': 'keep-alive',
            'Accept-Encoding': 'gzip, deflate, br',
        }
        result = requests.post(url, data=sql, auth=HTTPBasicAuth(user,pwd),headers=headers)
        text = result.content.decode()
        return text
    except Exception as e:
        print(e)


def check_return(result, tdversion):
    """Check result of request."""
    if tdversion == 2:
        datart = json.loads(result).get("status")
    else:
        datart = json.loads(result).get("code")
        
    if str(datart) == 'succ' or str(datart) == '0':
        chkrt = 'succ'
    else:
        chkrt = 'error'
    return chkrt


def get_data(stbname, url, username, password, dbname, version, stime, etime):
    """Get data from source database or destination database."""
    data = dict()
    if version == 2:
        sql = f"select count(*) from `{dbname}`.`{stbname}` where _c0>='{stime}' and _c0<='{etime}' group by tbname;"
    else:
        sql = f"select count(*),tbname from `{dbname}`.`{stbname}` where _c0>='{stime}' and _c0<='{etime}' group by tbname;"
    
    rt = request_post(url, sql, username, password)
    code = check_return(rt, version)
    
    if code != 'error':
        rdata = json.loads(rt).get("data")
        for ll in range(len(rdata)):
            data[rdata[ll][1]] = rdata[ll][0]
    else:
        print(rt)
    return data


def compare_data(source_info, destination_info, stime, etime):
    """Compare data between source database and destination database."""
    tb_lost = set()
    tb_diff = set()

    with open('stblist', 'r') as sfile:
        for stbname in sfile:
            stbname = stbname.strip()
            
            source_data = get_data(stbname, **source_info, stime=stime, etime=etime)
            destination_data = get_data(stbname, **destination_info, stime=stime, etime=etime)
        
            for key, source_value in source_data.items():
                destination_value = destination_data.get(key)

                if destination_value is None:
                    tb_lost.add(key)
                    print(f'Table {key} not exist in destination DB {destination_info["dbname"]}')
                elif destination_value != source_value:
                    tb_diff.add(key)
                    print(f'Table {key} has different values between source and destination, source is {source_value}, destination is {destination_value}.')
                    
    print("Lost tables: {}, Diff tables: {}.".format(len(tb_lost), len(tb_diff)))


def main():
    config = configparser.ConfigParser()
    config.read('config.ini')

    source_info = {
        'url': config['source']['url'],
        'username': config['source']['username'],
        'password': config['source']['password'],
        'dbname': config['source']['dbname'],
        'version': int(config['source']['version']),
    }

    destination_info = {
        'url': config['destination']['url'],
        'username': config['destination']['username'],
        'password': config['destination']['password'],
        'dbname': config['destination']['dbname'],
        'version': int(config['destination']['version']),
    }

    if len(sys.argv) >= 3:
        stime = str(sys.argv[1])
        etime = str(sys.argv[2])
    else:
        stime = '2000-01-01T00:00:00.000+00:00'
        etime = '2023-10-01T00:00:00.000+00:00'
    arg_j(stime)
    arg_j(etime)

    compare_data(source_info, destination_info, stime, etime)


if __name__ == "__main__":
    main()