import taos
 
def taos_conn():
    conn = taos.connect(host="td1.taosdata.com",
                        port=6030,
                        user="root",
                        password="taosdata",
                        database="db01")
    sql_create = 'create table if not exists test01(ts timestamp,v1 int);'
    sql_insert = 'insert into test01 values(1643731200000,1);'
    sql_select = 'select * from test01;'
    conn.execute(sql_create)
    affected_row: int = conn.execute(sql_insert)
    print("Insert rows:",affected_row)
    result: taos.TaosResult = conn.query(sql_select)
    data = result.fetch_all()
    print(data)
    conn.close()
 
if __name__ == "__main__":
    taos_conn()