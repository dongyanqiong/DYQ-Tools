
在[TDengine 跨版本迁移实战](https://blog.csdn.net/weixin_43700866/article/details/134417800)章节中提到了进行 TDengine 数据迁移的 Python脚本。脚本支持多线程或多进程模式。

但是使用多进程模式时，会出现问题，如下：

多线程模式：
```bash
python3 datac_com23v2.py 
[2023-11-17 13:43:00,526] dataC/multi_thread(1975/MainThread) INFO - --------------------begin------------------
[2023-11-17 13:43:00,527] dataC/multi_thread(1975/MainThread) INFO - ##############################
[2023-11-17 13:43:24,346] dataC/multi_thread(1975/MainThread) INFO - ## 9038/9038 Tables  and 27425 Rows are proceed.
[2023-11-17 13:43:24,347] dataC/multi_thread(1975/MainThread) INFO - ## 0 tables created.
[2023-11-17 13:43:24,348] dataC/multi_thread(1975/MainThread) INFO - ##############################
[2023-11-17 13:43:24,349] dataC/multi_thread(1975/MainThread) INFO - --------------------end------------------
```

多进程模式：
```bash
python3 datac_com23v2.py 
[2023-11-17 14:08:57,023] dataC/multi_thread(2208/MainThread) INFO - --------------------begin------------------
[2023-11-17 14:08:57,024] dataC/multi_thread(2208/MainThread) INFO - ##############################
[2023-11-17 14:09:19,175] dataC/multi_thread(2208/MainThread) INFO - ## 0/9038 Tables  and 0 Rows are proceed.
[2023-11-17 14:09:19,177] dataC/multi_thread(2208/MainThread) INFO - ## 0 tables created.
[2023-11-17 14:09:19,177] dataC/multi_thread(2208/MainThread) INFO - ##############################
[2023-11-17 14:09:19,178] dataC/multi_thread(2208/MainThread) INFO - --------------------end------------------
```

脚本虽然正常运行了，但是输出结构中没有打印出进度信息。造成这个问题的原因在于多进程模式变量的共享需要特殊处理。

具体处理方法为在调用 `multiprocessing.Process` 先声明共享变量，然后再进程中再进行定义。

修改步骤如下：
1. 在 `multi_thread` 函数中，添加共享变量的定义
    ```python
    m_tb = multiprocessing.Array('i',threadNum)
    m_rw = multiprocessing.Array('i',threadNum)
    m_ctb = multiprocessing.Array('i',threadNum)
    ```
2. 将共享变量传递个子函数
    ```python
    target = process_func, args=(tblist, tnum, listnum, m_tb, m_rw, m_ctb)
    ```
3. 在函数中将记录写入共享变量
    ```python
    m_tb[tnum] = len(tb_proced)
    m_rw[tnum] = sum_list(rw_proced)
    m_ctb[tnum] = len(ctb_proced)   
    ```
4. 对记录进行统计输出
   ```python
   if wmethod == 'process':
        logger.info("## "+str(sum_list(m_tb[:]))+"/"+str(len(tblist))+" Tables  and "+str(sum_list(m_rw[:]))+" Rows are proceed.")
        logger.info("## "+str(sum_list(m_ctb[:]))+" tables created.")
   ```

部分代码如下：

```python
def process_func(tb_list, tnum, list_num, m_tb, m_rw, m_ctb):
    slnum = 1
    irss = requests.session()
    erss = requests.session()
    for ll in range(list_num):
        ii = tnum*list_num+ll
        if ii < len(tb_list):
            etbname = str(tb_list[ii])
            itbname = etbname
            if tableonly == 'false':
                export_table(etbname, itbname, irss, erss)
                slnum += 1
                if slnum == 1000 :
                    time.sleep(1)
                    logger.info("Sleep 1 sec.")
                    slnum = 1
            else:
                if tableonly == 'true':
                    export_table_only(etbname, itbname, irss, erss)
                else:
                    logger.error("CfgFile: tableonly set error!")
    irss.close()
    erss.close()
    m_tb[tnum] = len(tb_proced)
    m_rw[tnum] = sum_list(rw_proced)
    m_ctb[tnum] = len(ctb_proced)

def multi_thread(tblist, wmethod):
    logger.info('--------------------begin------------------')
    logger.info("##############################")
    threads = []
    if len(tblist) < threadNum:
        irss = requests.session()
        erss = requests.session()
        for i in range(len(tblist)):
            tbname = tblist[i]
            export_table(tbname, irss, erss)
            proce = str(i+1)+'/'+str(len(tblist))
            logger.info(proce)
    else:
        listnum = int(len(tblist)/threadNum)+1
        if wmethod == 'process':
            m_tb = multiprocessing.Array('i',threadNum)
            m_rw = multiprocessing.Array('i',threadNum)
            m_ctb = multiprocessing.Array('i',threadNum)
            for tnum in range(threadNum):
                t = multiprocessing.Process(
                    target=process_func, args=(tblist, tnum, listnum, m_tb, m_rw, m_ctb))
                threads.append(t)
        else:
            for tnum in range(threadNum):
                tname = str('Thread_'+str(tnum))
                t = threading.Thread(target=thread_func,
                                     name=tname, args=(tblist, tnum, listnum))
                threads.append(t)
        for t in threads:
            t.start()
        for t in threads:
            t.join()
    if wmethod == 'process':
        logger.info("## "+str(sum_list(m_tb[:]))+"/"+str(len(tblist))+" Tables  and "+str(sum_list(m_rw[:]))+" Rows are proceed.")
        logger.info("## "+str(sum_list(m_ctb[:]))+" tables created.")
    else:
        logger.info("## "+str(sum_list(tb_proced))+"/"+str(len(tblist))+" Tables  and "+str(sum_list(rw_proced))+" Rows are proceed.")
        logger.info("## "+str(sum_list(ctb_proced))+" tables created.")
    logger.info("##############################")
    logger.info('--------------------end------------------')

```


再次运行程序，已经能正常输出结构了。

```bash
datac_com23v2.py -p
[2023-11-17 14:52:30,965] dataC/multi_thread(2840/MainThread) INFO - --------------------begin------------------
[2023-11-17 14:52:30,966] dataC/multi_thread(2840/MainThread) INFO - ##############################
[2023-11-17 14:52:38,869] dataC/multi_thread(2840/MainThread) INFO - ## 9038/9038 Tables  and 27425 Rows are proceed.
[2023-11-17 14:52:38,870] dataC/multi_thread(2840/MainThread) INFO - ## 0 tables created.
[2023-11-17 14:52:38,871] dataC/multi_thread(2840/MainThread) INFO - ##############################
[2023-11-17 14:52:38,872] dataC/multi_thread(2840/MainThread) INFO - --------------------end------------------
```

## 知识点
multiprocess 进程间共享变量有三种方式：Value, Array 和 Manager。前两者是共享内存，支持的数据类型有限，最后一种是使用服务进程管理需要共享的变量，支持的数据类型更丰富，但速度不如前两者。

## 参考
1. [Sharing state between processes](https://docs.python.org/3/library/multiprocessing.html)

