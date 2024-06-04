import pymysql
import random
import string
import threading
from multiprocessing import Pool

#lock = threading.Lock()
# 创建数据库连接
#db = pymysql.connect(host="192.168.3.67", user="root", password="tbase125!", database="test")

def insert_data(args):
    # 创建游标对象
    db = pymysql.connect(host="192.168.3.67", user="root", password="tbase125!", database="test")
    cursor = db.cursor()
    for _ in range(10000000):
        ts = random.randint(1000000000,9999999999)
        pr = ''.join(random.choices(string.ascii_letters + string.digits, k=50))
        tbname = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
        # SQL插入语句
        sql = "INSERT INTO tb(ts, pr, tbname) VALUES('{}', '{}', '{}')".format(ts, pr, tbname) 
        try:
            # 执行sql语句
#            lock.acquire()
            cursor.execute(sql)
            # 提交到数据库执行
            db.commit()
#            lock.release()
        except Exception as e:
            # 如果发生错误则回滚
            print("There was an error: ", e)
            db.rollback()
    # 关闭数据库连接
    db.close()

if __name__ == "__main__": 
    pool = Pool(10)  # 创建拥有10个进程数量的进程池
    pool.map(insert_data, range(10)) # 启动进程数量
    pool.close() 
    pool.join()