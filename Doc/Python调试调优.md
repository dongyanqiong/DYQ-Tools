# Python 性能调优

再上一章节 [[Python学习笔记]Requests性能优化之Session](https://blog.csdn.net/weixin_43700866/article/details/134438926) 中，通过在 Resquests 中使用 session，将 Python 脚本的运行效率提升了 3 倍。但当时对问题的排查主要是基于猜测，并没有实质性的证据。

## 工具介绍

本次使用 Python 的性能分析工具对脚本进行分析，找到优化点。首先介绍两个工具：
### 1. cProfile
cProfile 是 Python 自带的性能分析模块，不需要额外安装，可以统计程序中函数的调用次数和时间。

```bash
python -m cProfile -o log.profile macd_all.py
```
- 以上命令会运行 `macd_all.py`，对每个函数的调用进行统计，并记录到 log.profile 文件中，方便分析。

### 2. snakeviz

SnakeViz是一个Python模块，用于可视化Python程序的性能分析结果。

安装
```bash
pip install snakeviz
```

分析 cProfile 日志
```bash
snakeviz.exe -p 8080 log.profile
```
- 以上命令会打开一个 HTTP Server，使用8080 端口，并自动打开本地浏览器。

## 性能分析
### 运行优化前脚本
```bash
python -m cProfile -o log1.profile macd_all_v1.py

snakeviz.exe -p 8080 log1.profile
```

看图可以发现耗时最长的函数就是`make_request` 这个网络请求函数，而在下面明细中可以看见`connect of _socket.socket` 耗时很长。
初步可以判断，程序大量时间耗费在建立网络连接方面。

### 运行优化后脚本
```bash
python -m cProfile -o log1.profile macd_all_v2.py

snakeviz.exe -p 8080 log2.profile
```

对比优化前的分析图，可以发现 `make_request` 这个函数耗时从 107s 降低到了 24.3s ， `connect of _socket.socket` 调用次数从9040次降低到了1次，总耗时从 77.93s 下降到毫秒级别。

从分析图中可以看出当前耗时较长的函数是 `'recv_into' of '_socket.socket'`，共调用 18037次，耗时 21.78s。
`recv_info` 会从套接字接收数据，并将其存储在给定的缓冲区中。

在《[Python学习笔记]Requests性能优化之Session》章节有提到，这个脚本会查询 9037 张表，共 1779929 条数据；写入 9037 张表，每个表 1 条数据。

脚本中涉及网络方面方面的操作：
1. 从数据库查询所有股票代码（1次查询）
2. 向数据库写入测试记录（1次写入）
3. 根据代码逐个查询交易数据（9037次查询）
4. 将结果写入数据库（1次写入）

由此可知，程序主要优化点在于减低数据库查询次数，比如说一次查询多只股票的数据。




## 参考
[Python基础(11) 性能测试工具 cProfile](https://blog.csdn.net/irving512/article/details/109446870)
[使用 cProfile 和火焰图调优 Python 程序性能](https://zhuanlan.zhihu.com/p/53760922)
[[量化投资-学习笔记013]Python+TDengine从零开始搭建量化分析平台-策略回测进阶](https://blog.csdn.net/weixin_43700866/article/details/134360560)
[[Python学习笔记]Requests性能优化之Session](https://dbadadong.blog.csdn.net/article/details/134438926)
