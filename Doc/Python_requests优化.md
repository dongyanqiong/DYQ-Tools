
# Requests 性能优化

Requests 可是说是 Python 中最常用的库了。用法也非常简单，但是想真正的用的好并不容易。
下面介绍一个提升性能小技巧：使用 session 会话功能。

- 会话对象让你能够跨请求保持某些参数。它也会在同一个 Session 实例发出的所有请求之间保持 cookie， 期间使用 urllib3 的 connection pooling 功能。所以如果你向同一主机发送多个请求，底层的 TCP 连接将会被重用，从而带来显著的性能提升。

以上示例采用的是在之前的章节[[量化投资-学习笔记013]Python+TDengine从零开始搭建量化分析平台-策略回测进阶](https://dbadadong.blog.csdn.net/article/details/134360560)中的回测脚本。
程序会查询 9037 张股票的近10个月的交易数据，使用交易策略进行回测，并将回测结构写入数据库。

涉及数据量：
查询 9037 张表，共 1779929 条数据；写入 9037 张表，每个表 1 条数据。


当时为提示写入效率，采用多进程/线程的方式，将回测数据写入数据库。

实际运行情况如下：

线程数=1
```bash
# time python3 macd_all_code.py
real    1m44.506s
user    0m10.732s
sys     0m1.620s
```

线程数=2
```bash
# time python3 macd_all_code.py 
real    2m45.544s
user    0m20.274s
sys     0m2.338s
```
时间反而增加了1倍，完全不符合设计逻辑。。

因为数据库部署在本地，磁盘为SSD，CPU负载也不高，因此初步判断问题出在程序内部。
首先排查的就是网络连接部分，因为要查询 9037 张表，每个表发起一次连接（TCP三次握手+四次挥手），这部分确实会耗时较高。
修改代码，使用 session，保证每个线程只建立一次连接。

修改前代码：
```python
def get_request(sql):
    sql = sql.encode("utf-8")
    headers = {
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br'
    }
    response = requests.post(url, data=sql, auth=(
        username, password), headers=headers)
    data = json.loads(response.content.decode())
    result = data.get("data")
    return result


def thread_func(df_code, tnum, list_num):
    bi = tnum*list_num
    ei = bi+list_num
    if tnum < (threadNum-1):
        df = df_code.iloc[bi:ei, :]
    else:
        df = df_code.iloc[bi:len(df_code), :]
    df_profit = loop_bt(df)
    write_td(df_profit)
    rss.close()
```

修改后代码：
```python
def get_request(sql, rss):
    sql = sql.encode("utf-8")
    headers = {
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br'
    }
    response = rss.post(url, data=sql, auth=(
        username, password), headers=headers)
    data = json.loads(response.content.decode())
    result = data.get("data")
    return result

def thread_func(df_code, tnum, list_num):
    rss = requests.session()
    bi = tnum*list_num
    ei = bi+list_num
    if tnum < (threadNum-1):
        df = df_code.iloc[bi:ei, :]
    else:
        df = df_code.iloc[bi:len(df_code), :]
    df_profit = loop_bt(df, rss)
    write_td(df_profit, rss)
    rss.close()
```
- 以上只贴了关键两部分代码，其他代码请参考《[量化投资-学习笔记013]Python+TDengine从零开始搭建量化分析平台-策略回测进阶》章节。

## 运行脚本进行测试

threadNum=1
```bash
# time python3 macd_all_code_request.py 
real    0m30.566s
user    0m8.497s
sys     0m1.344s
```

threadNum=2
```bash
# time python3 macd_all_code_request.py 
real    0m32.053s
user    0m17.897s
sys     0m1.604s
```
虽然线程数的提示并没有提示效率，但通过使用 session, 程序整体执行效率提示了 3 倍。

以下是测试过程中网络连接数的变化：

未使用session，线程数=1
```bash
# ss -s
Total: 181
TCP:   4254 (estab 1, closed 4252, orphaned 0, timewait 4252)

Transport Total     IP        IPv6
RAW       0         0         0
UDP       9         5         4
TCP       2         2         0
INET      11        7         4
FRAG      0         0         0
```

未使用session，线程数=2
```bash
# ss -s
Total: 182
TCP:   4203 (estab 0, closed 4200, orphaned 0, timewait 4200)

Transport Total     IP        IPv6
RAW       0         0         0
UDP       9         5         4
TCP       3         3         0
INET      12        8         4
FRAG      0         0         0
```

使用session，线程数=1
```bash
# ss -s
Total: 183
TCP:   3 (estab 1, closed 1, orphaned 0, timewait 1)

Transport Total     IP        IPv6
RAW       0         0         0
UDP       10        6         4
TCP       2         2         0
INET      12        8         4
FRAG      0         0         0
```


使用session，线程数=2
```bash
# ss -s
Total: 182
TCP:   4 (estab 2, closed 1, orphaned 0, timewait 1)

Transport Total     IP        IPv6
RAW       0         0         0
UDP       9         5         4
TCP       3         3         0
INET      12        8         4
FRAG      0         0         0
```

通过以上对比发现，网络连接数大幅下降，从优化前的 4000 多个 下降到 2-4 个。


## session 进阶设置

```
class requests.adapters.HTTPAdapter(pool_connections=10, pool_maxsize=10, max_retries=0, pool_block=False)[source]
The built-in HTTP Adapter for urllib3.

Provides a general-case interface for Requests sessions to contact HTTP and HTTPS urls by implementing the Transport Adapter interface. This class will usually be created by the Session class under the covers.

Parameters
- pool_connections – The number of urllib3 connection pools to cache.
- pool_maxsize – The maximum number of connections to save in the pool.
- max_retries – The maximum number of retries each connection should attempt. Note, this applies only to failed DNS lookups, socket connections and connection timeouts, never to requests where data has made it to the server. By default, Requests does not retry failed connections. If you need granular control over the conditions under which we retry a request, import urllib3’s Retry class and pass that instead.
- pool_block – Whether the connection pool should block for connections.
```

我在代码中添加了相关设置
```python
rss.mount('http://', requests.adapters.HTTPAdapter(pool_connections=20, pool_maxsize=20, max_retries=3))
```
但是执行速度并没有提升，看来瓶颈已经不在网络连接方面了。

后面持续进行优化吧。



[官方文档-高级用法-会话对象](https://requests.readthedocs.io/projects/cn/zh-cn/latest/user/advanced.html#session-objects)
[python3 requests使用连接池](https://www.cnblogs.com/cooolr/p/11396108.html)
[[Python] 用Session()优化requests的性能](https://zhuanlan.zhihu.com/p/114283369)