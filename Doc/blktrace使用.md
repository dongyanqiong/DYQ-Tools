
```bash
blktrace /dev/sdb

blkparse -i sdb -d sdb.bin >>sdb.txt
``
A remap         对于栈式设备，进来的I/O将被重新映射到I/O栈中的具体设备
X split             对于做了Raid或进行了device mapper(dm)的设备，进来的IO可能需要切割，然后发送给不同的设备
Q queued        I/O进入block layer，将要被request代码处理（即将生成IO请求）
G get request  I/O请求（request）生成，为I/O分配一个request 结构体。
M back merge  之前已经存在的I/O request的终止block号，和该I/O的起始block号一致，就会合并。也就是向后合并
F front merge  之前已经存在的I/O request的起始block号，和该I/O的终止block号一致，就会合并。也就是向前合并
I inserted       I/O请求被插入到I/O scheduler队列
S sleep           没有可用的request结构体，也就是I/O满了，只能等待有request结构体完成释放
P plug            当一个I/O入队一个空队列时，Linux会锁住这个队列，不处理该I/O，这样做是为了等待一会，看有没有新的I/O进来，可以合并
U unplug       当队列中已经有I/O request时，会放开这个队列，准备向磁盘驱动发送该I/O。
 这个动作的触发条件是：超时（plug的时候，会设置超时时间）；或者是有一些I/O在队列中（多于1个I/O）
D issued       I/O将会被传送给磁盘驱动程序处理
C complete   I/O处理被磁盘处理完成。

```bash
btt -i sdb.bin
```

Q2Q： 相邻两次进入通用块层的I/O间隔
Q2G：I/O进入block layer到I/O请求（request）生成的时间
G2I：I/O请求生成到被插入I/O请求队列（request queue）的时间
Q2M：I/O进入block层到该I/O被和已存在的I/O请求合并的时间
I2D：I/O请求进入request queue队到分发到设备驱动的时间
M2D：I/O合并成I/O请求到分发到设备驱动的时间
D2C：I/O分到到设备驱动到设备处理完成时间