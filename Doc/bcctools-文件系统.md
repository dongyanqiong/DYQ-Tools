
之前简单介绍过了Linux下的工具集 [bcc-tools](https://dbadadong.blog.csdn.net/article/details/125758205)，

本次详细的介绍一下和文件系统相关的一些工具。


## filelife
该工具通过跟踪`vsf_create()`和`vfs_delete()`函数，来检测文件从创建到删除的存活时间。
工具会输出进程ID、线程名称、文件寿命和文件名称。
通过 `filelife` 我们可以看到哪些线程在频繁创建和删除文件。

```bash
TIME     PID    COMM             AGE(s)  FILE
10:07:39 1493   vnode-mgmt       0.05    meta-ver130
10:07:39 1493   vnode-mgmt       0.03    meta-ver130
10:07:39 1493   vnode-mgmt       0.70    00000000000000006878.idx
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.1
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.2
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.3
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.4
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.5
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.6
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.7
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.8
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.9
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.10
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.11
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.12
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.13
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.14
10:07:39 1493   vnode-mgmt       0.01    MANIFEST-000001
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.1
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.2
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.3
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.4
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.1
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.2
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.3
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.4
10:07:39 1493   vnode-mgmt       0.00    MANIFEST-000001
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.1
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.2
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.3
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.4
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.5
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.6
10:07:39 1493   vnode-mgmt       0.00    main.tdb-journal.7
```
## fileslower
这个工具用来检测读写耗时长的文件，如果不指定耗时，默认为10ms。

可以通过以下参数指定基础你好ID和耗时，`fileslower -p 281933 100`。

- D 表示读写动作，R(读)，W(写)

```bash
Tracing sync read/writes slower than 10 ms
TIME(s)  COMM           TID    D BYTES   LAT(ms) FILENAME
1.417    vnode-merge    281993 R 4096      14.01 v18f19579ver144631.stt
1.877    vnode-merge    281993 R 4096      10.74 v18f19579ver144645.stt
1.891    vnode-merge    281993 R 4096      13.08 v18f19579ver144645.stt
2.164    vnode-merge    281993 R 4096      10.47 v18f19579ver144613.stt
2.202    vnode-merge    281993 R 4096      11.78 v18f19579ver144593.stt
2.968    vnode-merge    281993 R 4096      14.04 v18f19579ver144652.stt
2.981    vnode-merge    281993 R 4096      12.43 v18f19579ver144652.stt
3.318    vnode-merge    281993 R 4096      11.59 v18f19579ver144614.stt
3.334    vnode-merge    281993 R 4096      15.62 v18f19579ver144614.stt
4.659    vnode-merge    281993 R 4096      21.78 v18f19579ver144706.stt
4.669    vnode-merge    281993 R 4096      10.38 v18f19579ver144706.stt
5.312    vnode-merge    281993 R 4096      10.46 v18f19579ver144620.stt
6.025    vnode-merge    281993 R 4096      14.37 v18f19579ver144693.stt
6.191    vnode-merge    281993 R 4096      17.30 v18f19579ver144616.stt
6.209    vnode-merge    281993 R 4096      16.72 v18f19579ver144616.stt
```
## filetop
该工具用于统计一段时间内读写较高的文件。
- READS/WRITES 读写次数
- R_Kb/W_Kb 读写数据量
- T 文件类型：R(常规文件)，S(Socket)，O(other)

```bash
00:21:41 loadavg: 48.26 48.36 47.02 50/1685 393731

TID    COMM             READS  WRITES R_Kb    W_Kb    T FILE
281992 vnode-merge      407    0      1628    0       R v50f19544ver140873.stt
281966 vnode-merge      0      380    0       1520    R v50f19565ver1724.data
281970 vnode-merge      0      350    0       1400    R v50f19549ver1704.data
281978 vnode-merge      337    0      1348    0       R v50f19569ver131206.stt
281994 vnode-merge      334    0      1336    0       R v50f19540ver140920.stt
281989 vnode-merge      331    0      1324    0       R v50f19568ver136719.stt
281977 vnode-merge      292    0      1168    0       R v50f19574ver75820.stt
281994 vnode-merge      0      289    0       1156    R v50f19540ver1250.data
281972 vnode-merge      286    0      1144    0       R v50f19578ver140918.stt
281992 vnode-merge      0      281    0       1124    R v50f19544ver1250.data
281978 vnode-merge      0      277    0       1108    R v50f19569ver2115.data
281953 vnode-merge      0      262    0       1048    R v50f19557ver1704.data
281968 vnode-merge      0      260    0       1040    R v50f19541ver1250.data
281972 vnode-merge      0      259    0       1036    R v50f19578ver2132.data
281970 vnode-merge      256    0      1024    0       R v50f19549ver130808.stt
281996 vnode-merge      241    0      964     0       R v50f19564ver117468.stt
281961 vnode-merge      237    0      948     0       R v50f19572ver134799.stt
281974 vnode-merge      0      235    0       940     R v50f19556ver1704.data
281980 vnode-merge      0      231    0       924     R v50f19552ver1704.data
281997 vnode-merge      218    0      872     0       R v50f19571ver140943.stt
```

## vfscount
用于统计一段时间内调用`vfs_`相关函数的次数，并进行排序。
如果命令后不加时间（默认s），需要使用`Ctrl-C`中止。

```bash
Tracing... Ctrl-C to end.
^C
ADDR             FUNC                          COUNT
ffffffffb7c69a71 vfs_rename                        2
ffffffffb7c69471 vfs_create                        2
ffffffffb7c6a351 vfs_unlink                        6
ffffffffb7c617e1 vfs_fstat                        13
ffffffffb7c594e1 vfs_open                         55
ffffffffb7c94311 vfs_statfs                       58
ffffffffb7c61841 vfs_fstatat                      62
ffffffffb7c61761 vfs_getattr                      75
ffffffffb7c5ba91 vfs_read                       1972
ffffffffb7c5bc01 vfs_write                      2507
```


## vfsstat
统计一段时间时间内 VFS 调用的次数，与`vfscount`不同，该工具不会输出线程信息，仅对不同的调用进行统计。

```bash
TIME         READ/s  WRITE/s CREATE/s   OPEN/s  FSYNC/s
10:09:02:       325      487        0        2        0
10:09:03:       317      485        1        4        0
10:09:04:       226      904       15       26        0
10:09:05:       295      538        2        3        0
10:09:06:       318      478        0        2        0
10:09:07:       338      488        0        5        0
10:09:08:       305      466        2        2        0
10:09:09:        42       96       12       18        0
10:09:10:       334     1009        6       23        0
10:09:11:       695      760        0        6        0
10:09:12:       699      765        0        1        0
10:09:13:       519      647        2       19        0
10:09:14:       331      507        0        1        0
10:09:15:       269      664       14       19        0
10:09:16:       291      820        4       13        0
10:09:17:       337      519        0        0        0
10:09:18:       328      501        0        2        0
```


## xfsslower/ext4slower
统计一段时间内存 XFS/EXT4 文件系统中文件的读写时间。

- T 文件类型：R(常规文件)，S(Socket)，O(other)
- OFF_KB  File offset


```bash
Tracing XFS operations slower than 10 ms
TIME     COMM           PID    T BYTES   OFF_KB   LAT(ms) FILENAME
10:01:57 vnode-write    1146   S 0       0         566.79 vnode_tmp.json
10:01:57 vnode-write    1146   S 0       0         327.59 vnode_tmp.json
10:01:57 vnode-commit   1146   S 0       0         149.27 00000000000000000000.log
10:01:57 vnode-commit   1146   S 0       0         148.91 00000000000000000000.log
10:01:58 vnode-commit   1146   S 0       0          12.75 v4f1736ver1.stt
10:01:58 vnode-commit   1146   S 0       0          13.99 00000000000000005123.log
10:02:02 vnode-write    1146   S 0       0          12.11 vnode_tmp.json
10:02:02 vnode-commit   1146   S 0       0          12.44 00000000000000005123.log
10:02:02 vnode-commit   1146   S 0       0          10.90 00000000000000005232.log
10:02:04 vnode-write    1146   W 280053  9300       11.15 00000000000000005232.log
10:02:05 vnode-merge    1146   S 0       0         171.87 v4f1736ver3.head
10:02:05 vnode-merge    1146   S 0       0         304.71 v5f1736ver3.head
10:02:05 vnode-merge    1146   S 0       0          10.30 v4f1736ver3.data
10:02:05 vnode-merge    1146   S 0       0          12.02 v4f1736ver3.sma
10:02:05 vnode-merge    1146   S 0       0          12.38 v5f1736ver3.data
10:02:08 vnode-commit   1146   S 0       0         143.99 00000000000000005232.log
10:02:08 vnode-commit   1146   S 0       0          97.54 00000000000000005240.log
10:02:08 vnode-commit   1146   S 0       0          10.37 v5f1736ver4.stt
10:02:08 vnode-commit   1146   S 0       0          10.48 00000000000000005350.log
10:02:13 vnode-write    1146   S 0       0         796.80 vnode_tmp.json
10:02:13 vnode-write    1146   S 0       0         927.95 vnode_tmp.json
10:02:13 vnode-commit   1146   S 0       0          11.38 00000000000000005359.log
10:02:13 vnode-commit   1146   S 0       0          13.13 00000000000000005350.log
10:02:13 vnode-write    1146   W 280053  1094       10.11 00000000000000005475.log
10:02:14 vnode-commit   1146   S 0       0          10.81 00000000000000005475.idx
10:02:14 vnode-commit   1146   S 0       0          13.89 v5f1736ver5.stt
10:02:14 vnode-commit   1146   S 0       0          21.05 00000000000000005467.idx
10:02:16 vnode-merge    1146   S 0       0          11.46 v4f1736ver3.data
10:02:19 vnode-commit   1146   S 0       0          34.90 00000000000000005475.log
10:02:19 vnode-commit   1146   S 0       0          32.18 00000000000000005467.log
10:02:19 vnode-commit   1146   S 0       0          10.05 meta-ver.tmp
10:02:19 vnode-commit   1146   S 0       0          11.30 v4f1736ver7.stt
10:02:19 vnode-commit   1146   S 0       0          12.99 00000000000000005593.log
10:02:20 vnode-write    1146   W 280053  4923       12.18 00000000000000005585.log
```

以上信息在 Github 的 [Bcc](https://github.com/iovisor/bcc) 库中都能找到。