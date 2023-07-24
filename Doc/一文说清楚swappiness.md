对运维过 Linux 的同学 `vm.swappiness` 肯定不陌生。在很多应用中，如Oracle、MySQL、PostgreSQL、TDengine等数据库文档中，也都会提及该参数的设置要求。

那么 `vm.swappiness` 如何设置呢？ 

网络上有很多的解读。最常见的就是 `swappiness` 是一个百分比，比如说设置为60，代表内存使用超过40%（100-60）时，就会启用 SWAP。这种说服看似合理，而且现象也比较符合，但是并不准确。

`swappiness` 确实代表了一个分配比，但没那么简单。根据内核代码中的描述，`swappiness` 代表了在进行内存回收时，匿名页和文件页的比重。具体比重如下：
> 匿名页：`swappiness`
> 文件页：`200-swappiness`
也就是说，当 `swappiness` 配置为100时，匿名页才和文件页拥有相同的权重。

内核官方描述如下：
This control is used to define the rough relative IO cost of swapping and filesystem paging, as a value between 0 and 200. At 100, the VM assumes equal IO cost and will thus apply memory pressure to the page cache and swap-backed pages equally; lower values signify more expensive swap IO, higher values indicates cheaper.

Keep in mind that filesystem IO patterns under memory pressure tend to be more efficient than swap's random IO. An optimal value will require experimentation and will also be workload-dependent.

RedHat 官方文档描述如下：
The swappiness value, ranging from 0 to 200, controls the degree to which the system favors reclaiming memory from the anonymous memory pool, or the page cache memory pool.

Setting the swappiness parameter’s value:

Higher values favor file-mapped driven workloads while swapping out the less actively accessed processes’ anonymous mapped memory of RAM. This is useful for file-servers or streaming applications that depend on data, from files in the storage, to reside on memory to reduce I/O latency for the service requests.

Low values favor anonymous-mapped driven workloads while reclaiming the page cache (file mapped memory). This setting is useful for applications that do not depend heavily on the file system information, and heavily utilize dynamically allocated and private memory, such as mathematical and number crunching applications, and few hardware virtualization supervisors like QEMU.

> 匿名页(anonymous pages)，没有文件背景的页面（即没有与磁盘文件存在任何映射关系的内存页面），如stack，heap，数据段，共享内存。
> 文件页(file-backed pages)，即与磁盘文件存在映射关系的内存页(有文件背景的页面)，例如进程代码段、文件的映射页等 ，也就是`free`中的cache。

插句题外话，`free` 中的 buffer 和 cache 有啥区别？
buffer: 尚未写到磁盘中的数据，通常可通过执行 `sync` 写入磁盘。
cache: 从磁盘中读取的数据，用于避免重复读。

当内存不足时，文件页通常优先被回收（通常是drop掉），匿名页被写入到 SWAP。

那么如何判断内存是否充足，何时进行内存回收呢？

通常由两个参数来控制：`vm.min_free_kbytes` 和 `pages_low` 。
当可用内存小于 `pages_low` 时就会触发内存的回收。

在 RedHat 官方文档中描述`vm.min_free_kbytes`如下：
Sets the size of the reserved free pages pool. It is also responsible for setting the min_page, low_page, and high_page thresholds that govern the behavior of the Linux kernel’s page reclaim algorithms. It also specifies the minimum number of kilobytes to keep free across the system. This calculates a specific value for each low memory zone, each of which is assigned a number of reserved free pages in proportion to their size.

The vm.min_free_kbytes parameter also sets a page reclaim watermark, called min_pages. This watermark is used as a factor when determining the two other memory watermarks, low_pages, and high_pages, that govern page reclaim algorithms.

内核文档中描述如下：
This is used to force the Linux VM to keep a minimum number of kilobytes free. The VM uses this number to compute a watermark[WMARK_MIN] value for each lowmem zone in the system. Each lowmem zone gets a number of reserved free pages based proportionally on its size.

Some minimal amount of memory is needed to satisfy PF_MEMALLOC allocations; if you set this to lower than 1024KB, your system will become subtly broken, and prone to deadlock under high loads.

Setting this too high will OOM your machine instantly.

pages_low 与 min_free_kbytes 对应关系参考：
https://blog.csdn.net/hu1610552336/article/details/113081805

当然，实际情况并没有这么简单，这时我们需要了解 NUMA 这个架构，对于大多数服务器，都会启用 NUMA，这就造成了内存被分成了不同的 zone，当某个 zone 内存耗尽时，其他 zone 可能内存还空闲。这时我们就会看到剩余内存还很多，但是 SWAP 已经开始使用了。

`/proc/zoneinfo` 记录了系统当前不同 zone 内存的使用情况。

总的来说，SWAP 的存在使得内存使用更加平滑，降低程序因偶发的内存暴涨被 OOM 的概率。当然这也分不同的业务场景，比如说大规模的前段应用，有时 OOM 后重启反而比缓慢的进行 SWAP 交换更加高效。而对于运行状态比较复杂的应用，如数据库，保障应用能够持续的运行反而更加重要。在 Oracle 的官方文档中，就明确要求了必须配置 SWAP 分区。

