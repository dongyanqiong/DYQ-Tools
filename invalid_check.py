import taos
import sys

def check(conn, err_tbs):

        mnode_tbs = []
        mnode_ntbs = []
        mnode_stbs = set()
        mnode_tgids = {}

        print("retieve tables from mnode with show tables")
        tbl_cursor = conn.cursor()
        tbl_cursor.execute('show tables')
        i = 0
        for row in tbl_cursor:
                if i % 10000 == 0:
                        print(i, row)
                tgid = (row[5],row[6])
                if (tgid in mnode_tgids):
                        mnode_tgids[tgid].append(row[0])
                else:
                        mnode_tgids[tgid] = [row[0]]
                mnode_tbs.append(row[0])
                if not row[3]:
                        mnode_ntbs.append(row[0])
                else:
                        mnode_stbs.add(row[3])
                i = i + 1
        tbl_cursor.close()

        for tgid,tbs in mnode_tgids.items():
                if len(tbs)>1:
                        print("tid/vgid error", tbs,tgid)
                        err_tbs.extend(tbs)

        vnode_ctbs = []
        in_vnode_cursor = conn.cursor()
        for stb in mnode_stbs:
                print("get child tbname from vnode from {}".format(stb))
                in_vnode_cursor.execute('select tbname from {}'.format(stb))
                i = 0
                for row in in_vnode_cursor:
                        if i % 10000 == 0:
                                print(i, row)
                        vnode_ctbs.append(row[0])
                        i = i + 1
        in_vnode_cursor.close()
        
        mnode_ctbs = set(mnode_tbs).difference(set(mnode_ntbs));
        error_tbs.extend(set(mnode_ctbs).difference(set(vnode_ctbs)))

        print("mnode ctbs - vnode ctbs", set(mnode_ctbs).difference(set(vnode_ctbs)))
        print("vnode ctbs - mnode ctbs", set(vnode_ctbs).difference(set(mnode_ctbs)))

        vnode_id_tbs = []
        uid_vnode_cursor = conn.cursor()
        for idx,tb in enumerate(mnode_tbs):
                if (idx % 10000 == 0):
                        print(idx,tb)        
                sql2 = 'select last_row(_c0) from `{}`'.format(tb)
                try:
                        uid_vnode_cursor.execute(sql2)
                        vnode_id_tbs.append(tb)
                except taos.Error as e:
                        print("table {} error number {}".format(tb, e.errno))
                        if e.errno != -2147482112:
                                vnode_id_tbs.append(tb)
                except BaseException as other:
                        print("exception occur")
        uid_vnode_cursor.close()
        error_tbs.extend(set(mnode_tbs).difference(set(vnode_id_tbs)))
        print("mnode tbs - vnode id tbs", set(mnode_tbs).difference(set(vnode_id_tbs)))
        print("vnode id tbs - mnode tbs", set(vnode_id_tbs).difference(set(mnode_tbs)))

if __name__ == '__main__':
        if (len(sys.argv) < 2):
                print(sys.argv[0], 'db_name user password')
                sys.exit()
        db = sys.argv[1]
        user = sys.argv[2] if (len(sys.argv) >= 3) else "root"
        passwd = sys.argv[3] if (len(sys.argv) >= 4) else "taosdata"

        error_tbs = []
        try:
                conn = taos.connect(user=user, password=passwd, database=db, config="/etc/taos")                
                check(conn, error_tbs)
        except taos.Error as e:
                print(e, e.errno)
        except BaseException as other:
                print(other)
        finally:
                conn.close()

        error_set = set(error_tbs)
        print("================RESULT=====================")
        with open('invalid.sql', 'w') as result_file:
                for tb in error_set:
                        result_file.write('drop table {}.`{}`;\n'.format(db,tb))
                        print('drop table {}.`{}`;'.format(db,tb))
