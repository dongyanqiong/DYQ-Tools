1、模拟延迟传输
```bash
# tc  qdisc  add  dev  eth0  root  netem  delay  100ms
```
该命令将 eth0 网卡的传输设置为延迟100毫秒发送。

更真实的情况下，延迟值不会这么精确，会有一定的波动，我们可以用下面的情况来模拟出带有波动性的延迟值：
```bash
# tc  qdisc  add  dev  eth0  root  netem  delay  100ms  10ms
```
该命令将 eth0 网卡的传输设置为延迟 100ms ± 10ms （90 ~ 110 ms 之间的任意值）发送。
还可以更进一步加强这种波动的随机性：
```bash
# tc  qdisc  add  dev  eth0  root  netem  delay  100ms  10ms  30%
```
该命令将 eth0 网卡的传输设置为 100ms ，同时，大约有 30% 的包会延迟 ± 10ms 发送。

2、模拟网络丢包
```bash
# tc  qdisc  add  dev  eth0  root  netem  loss  1%
```
该命令将 eth0 网卡的传输设置为随机丢掉 1% 的数据包。 也可以设置丢包的成功率：
```bash
# tc  qdisc  add  dev  eth0  root  netem  loss  1%  30%
```
该命令将 eth0 网卡的传输设置为随机丢掉 1% 的数据包，成功率为 30% 。

3、模拟包重复
```bash
# tc  qdisc  add  dev  eth0  root  netem  duplicate 1%
```
该命令将 eth0 网卡的传输设置为随机产生 1% 的重复数据包 。

4、模拟包损坏
```bash
# tc  qdisc  add  dev  eth0  root  netem  corrupt  0.2%
```
该命令将 eth0 网卡的传输设置为随机产生 0.2% 的损坏的数据包 。 (内核版本需在2.6.16以上）

5、模拟包乱序
```bash
# tc  qdisc  change  dev  eth0  root  netem  delay  10ms   reorder  25%  50%
```
该命令将 eth0 网卡的传输设置为:有 25% 的数据包（50%相关）会被立即发送，其他的延迟 10 秒。
新版本中，如下命令也会在一定程度上打乱发包的次序: # tc  qdisc  add  dev  eth0  root  netem  delay  100ms  10ms