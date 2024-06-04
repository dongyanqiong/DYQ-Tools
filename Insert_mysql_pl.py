import pymysql
import random
import string
from multiprocessing import Pool

def insert_data(args):
    # 创建游标对象
    db = pymysql.connect(host="192.168.3.67", user="root", password="tbase125!", database="test")
    cursor = db.cursor()
    
    data_list = []
    for _ in range(1000000):
        ts = random.randint(1000000000,9999999999)
        pr = ''.join(random.choices(string.ascii_letters + string.digits, k=50))
        tbname = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
        data_list.append((ts, pr, tbname))

        if len(data_list) == 1000:  # 满足一定数量后批量插入
            # SQL插入语句
            sql = "INSERT INTO tb(ts, pr, tbname) VALUES(%s, %s, %s)"
            try:
                # 执行sql语句
                cursor.executemany(sql, data_list)
                # 提交到数据库执行
                db.commit()
                data_list = []  # 清空列表
            except Exception as e:
                # 如果发生错误则回滚
                print("There was an error: ", e)
                db.rollback()
    
    # 处理完所有数据后检查列表中是否还有剩余数据未插入
    if len(data_list) > 0:
        try:
            cursor.executemany(sql, data_list)
            db.commit()
        except Exception as e:
            print("There was an error: ", e)
            db.rollback()
    
    # 关闭数据库连接
    db.close()

if __name__ == "__main__": 
    pool = Pool(10)
    pool.map(insert_data, range(10))
    pool.close() 
    pool.join()