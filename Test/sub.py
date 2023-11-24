from taospy import Client

# 连接到 TDengine 服务器
conn = Client(host='10.7.7.14', user='root', password='taosdata', database='db01')

# 订阅数据回调函数
def callback(data):
    print(f'Received data: {data}')

# 订阅数据
with conn.subscribe('test1', callback):
    # 在此处可以执行其他任务，让订阅保持活跃
    input('Press Enter to stop the subscription...\n')

# 关闭连接
conn.close()
