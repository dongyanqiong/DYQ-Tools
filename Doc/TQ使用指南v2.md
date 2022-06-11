# TQ使用指南v2





## 1. TQ概述



#### 1.1 TQ特点

TQ是TDengine家族的消息队列产品，底层概念与TDengine时序数据库相同。

使用者需先阅读TDengine用户手册，厘清基本概念后(主要概念有：dnode/vnode/vgroup/wal/C&C++&Java 连接器/订阅/taos shell/数据库/超级表/普通表/集群)，再阅读本指南。

##### 产品亮点

高性能、高可靠：内部采用TDengine的存储引擎实现，读写吞吐量非常好，带有持久化存储，支持多副本。

丰富的连接器：目前提供C/C++/Java/Python/Go/Node.js/**RESTful**。

##### 限制

- 无offset管理机制，需客户端记录offset

- 无消费者管理策略，需要consumer自己控制消费的分区




#### 1.2 TQ适用场景

适合数据同步、实时计算两个场景。



#### 1.3 TQ工作原理

TQ作为消息队列产品，提供持久化的、高可用的消息服务。

与其他消息队列产品一样，TQ具有主题topic和分区partion的概念。

- 每个应用场景对应不同的消息体，同时对应一个topic；
- 每个topic可划分若干partion，以提升并发生产写入、消费的性能。

每个topic隶属于某个vgroup，如在多副本集群的情形下，每个vgroup由多个vnode组成，以实现高可用。

一个topic所属的vnode，与TDengine时序库vnode不同点在于：一个vnode一张表、维持一个与时间有关系的自增序列。在vnode为master时，解析wal，为wal的每条记录，更新它的第一列时间戳为自增序列。

用户通过连接器，向指定的partition表中写消息。用户需提前规划、配置好topic下属的分区表，生产者将向指定的分区表中写入数据。

**消息体构建**：生产者每次产生一批记录，将其按约定的编码规则构建成一条消息，将该条消息写入TQ指定主题topic的分区表partion。分区表只存储消息体，没有key的概念。

**消息消费**：消费者每次从TQ指定主题topic的分区表partion读取一条消息，将其按约定的编码规则解析为对应的记录，进行相关业务操作。处理成功之后，消费者更新并记录offset。

**管理界面**：用户通过TQ CLI进入交互式管理界面，创建、维护主题topic，创建、维护分区表partion，查看主题、分区表，查看分区表内消息数量。



- ##### 生产消息

用户通过连接器，读取一批源数据记录，构建消息体，向指定的主题topic的partition表中写入消息。

注意：一定要区分用户记录和TQ消息这两个概念，TQ消息可以包含多条用户的记录。

**消息的解析，需要生产者和消费者进行充分的交流，确定彼此理解消息内部结构，消息在TQ中是一个长度不超过16000字节的binary列。**

1. 生产者写入TQ时，可随意指定offset，最终写入的offset是一long值类型的单调递增的整数，是由TQ服务端自动生成的。 

2. 写入时，partition需要指定。



- ##### 消费消息

消费消息时，用户通过连接器，使用订阅功能，订阅topic中的每个partition表来实现消费。

拉取数据后，offset的记录，由客户端负责。

使用taos_consume接口来完成消息消费。

![TQ使用指南](/Users/xiaobo/Library/Mobile Documents/com~apple~CloudDocs/tdengine/0 文档/TQ/TQ使用指南.png)





## 2. TQ快速入门

1. 创建主题。【以电力系统为例，各个地市一区各部署一套TQ，至少创建一个topic。如需同步聚合计算派生的表，按需增加topic】
2. 写入消息。【各一区采集应用将信息封装，写入TQ】
3. 消费消息。【各入库应用消费本地TQ，入库；中心侧三区部署一套TQ，汇入各一区的topic。入库应用消费所有topic，入库中心TDengine】
4. 删除主题

#### 2.1 注意事项

TQ的topic对应TDengine之数据库，删除db也会导致topic被删除

#### 2.2 开发语言接口

topic下面的数据表与普通的数据表没有区别，写入方法、订阅方法也相同，因此不需要开发任何额外的连接器或者API。当前版本实现了订阅接口的连接器都可以使用。





## 3. TQ使用说明

TQ共用TDengine命令行管理工具taos shell，进行系统配置及维护。

```$ shell
$ taos

Welcome to the TDengine shell from Linux, Client Version:2.4.0.16
Copyright (c) 2020 by TQ, Inc. All rights reserved.

taos> 
```



#### 3.1 创建主题

```
CREATE TOPIC [IF NOT EXISTS] topic_name [PARTITIONS partitons] [other database options]
```

说明：

- 创建主题时可指定除precision和update以外的其他数据库参数，系统自动创建名为topic_name的微秒类型数据库

- partitons是该主题的分区数目，有效范围[0-1000] 。当取值>0时，系统自动创建名为ps的超级表，名为p1-p<partitions>的多个分区表

  

#### 3.2 删除主题

```
DROP TOPIC [IF NOT EXISTS] topic_name
```

说明：

- 所包含的全部数据库、数据表将被删除，谨慎使用

  

#### 3.3 修改主题

```
ALTER TOPIC topic_name [PARTITIONS partitons]
```

说明：

- 可以修改分区数目

  

#### 3.4 显示系统所有主题

```
SHOW TOPICS
```



#### 3.5 使用方法

- 创建主题后，系统会创建名为topic_name的微秒类型数据库、名为ps的超级表、名为p1 ~ p\<partitions>的多个分区表，数据模型如下：

| P\<PartitionId> | 分区表名 |                       |                                                              |
| --------------- | -------- | --------------------- | ------------------------------------------------------------ |
| OFF             | 数据列   | 微秒时间戳            | 即offset。**INSERT写入时，可指定offset为任意值，最终offset的写入值会在服务端自动替换为唯一的、单调递增的微秒时间戳** |
| TS              | 数据列   | 微秒时间戳            | 用户指定的时间，不会被自动更新。该列可作为写入时间，或采集时间，由用户指定。 |
| CONTENT         | 数据列   | BINARY（16000 Bytes） | 具体的消息内容                                               |
| PID             | 标签列   | 整型                  | 分区编号，做统计时可能用到                                   |

- 写入、读取、订阅分区表的方式与TDengine的普通表相同
- 删除数据库时，对应的主题也会被删除



#### 3.6 示例代码

下面的C语言示例代码片段，创建了一个配有10个partition，名为tq_test的topic，然后往每个partion各写入一条内容为test的记录。

```c
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <taos.h>  // TAOS header file

int main(int argc, char *argv[]) {
  char qstr[1024];
  TAOS_RES *pSql = NULL;

  // connect to server
  if (argc < 2) {
    printf("please input server-ip \n");
    return 0;
  }

  TAOS *taos = taos_connect(argv[1], "root", "taosdata", NULL, 0);
  if (taos == NULL) {
    printf("failed to connect to server, reason:%s\n", "null taos" /*taos_errstr(taos)*/);
    exit(1);
  }
  
  TAOS_RES* res;
  // create topic
  res = taos_query(taos, "create topic tq_test partitions 10");
  taos_free_result(res);

  res = taos_query(taos, "use tq_test");
  taos_free_result(res);

  print_results(taos, "show stables");
  print_results(taos, "show tables");

  // insert data
  for (int i = 0; i < 10; i++) {
    char *sql = "insert into p%d values(now + %ds, now, 'test')";
    sprintf(qstr, sql, i, i);
    res = taos_query(taos, qstr);
    taos_free_result(res);
  }
}
```



## 4. 安装部署TQ

### 4.1   TQ服务器安装、启动

<font color="red">**【说明】自TDengine企业版2.4.x起，TQ内嵌于TDengine，无需独立安装。**</font>

TDengine服务器部分，提供tar.gz包供安装。

- TQ-enterprise-enterprise-server-2.4.x.x-Linux-x64.tar.gz - TDengine企业版服务端安装包
- TQ-enterprise-enterprise-arbitrator-2.4.x.x-Linux-x64.tar.gz - TDengine企业版仲裁器安装包

安装部署步骤如下：

1. 从涛思交付团队获取TDengine安装包

2. 上传至服务器指定目录，解压缩 `sudo tar xzvf TDengine-enterprise-server-2.4.0.16-Linux-x64.tar.gz`

3. 进入解压后的子目录，安装 `cd TDengine-enterprise-server-2.4.0.16 && sudo ./install`

   解压软件包之后，会在解压目录下看到以下文件(目录)：

     connector:  各开发语言连接器
     driver:  应用驱动driver
     examples:  示例代码
     install.sh:  主安装脚本，用于安装服务端及客户端程序
     taos.tar.gz:  主安装包

4. 编辑 /etc/taos/taos.cfg，将firstEP和fqdn修改为本机的hostname

5. 编辑/etc/hosts，将**集群所有节点**的域名解析添加进去(如已部署DNS server，则略过)

6. 启动taosd服务 `sudo systemctl start taosd`

   **提示：安装过程中，会提示安装的数据节点是否要加入一个已经存在的TDengine集群，如果是，则需要输入该集群的任何节点的FQDN:端口号(默认6030)作为本机的first EP；如果直接回车，则会新创建一个集群。**

7. 添加节点至集群

所有待加入集群的节点，在配置文件中(默认路径：/etc/ttaos/taos.cfg)将firstEP指向集群中正常工作的任一节点后，重启taosd服务` sudo systemctl start taosd`，进入taos命令行工具执行下面命令，将待加入节点添加至该集群：
```$ shell
> CREATE DNODE '<fqdn of node>:<port>';		//将fqdn:port指向的节点添加到集群
> SHOW DNODES;														//显示当前集群节点信息
```

8. 从集群中删除节点

在taos命令行工具中执行下面命令，将指定节点从当前集群中删除：

```$ shell
> DROP DNODE '<fqdn of node>:<port>';		//将fqdn:port指向的节点从集群删除
```



### 4.2   应用驱动安装

应用驱动目前支持的平台有：Linux x64, Windwos x64, Windows x86。

<font color="green">【**注意】TDengine服务器安装包中已包含应用驱动，无需再单独安装。**</font>

Linux和Windows x64/x86安装包如下：

- TDengine-enterprise-client-2.4.x.x-Linux-x64.tar.gz
- TDengine-client-2.4.x.x-Windows-x64.exe
- TDengine-client-2.4.x.x-Windows-x86.exe

以Linux 64应用驱动为例(Windows x64/x86安装类似)介绍安装步骤如下：

1. **获得应用驱动的tar.gz安装包，如TDengine-client-2.4.x.x-Linux-x64.tar.gz**
2. **解压缩软件包**

将软件包放置在当前用户可读写的任意目录下，然后执行下面的命令：

`tar -xzvf TDengine-client-xxxx.tar.gz`

其中xxxx需要替换为实际版本的字符串。

3. **执行安装脚本**

解压软件包之后，会在解压目录下看到以下文件(目录)：

  Install_client.sh：安装脚本，用于应用驱动程序
  taos.tar.gz：应用驱动安装包
  driver：应用驱动driver
  connector: 编程语言连接器 Python/JDBC
  examples: 示例程序 C/Go/JDBC/Matlab/Python/R

运行install_client.sh进行安装。

4. **配置参数**

编辑taos.cfg文件(默认路径/etc/taos/taos.cfg)，将firstEP修改为集群中正常工作的任一节点的End Point，例如：node1:6030

**提示： 如本机没有部署TDengine服务器，仅安装了应用驱动，则taos.cfg中无需配置FQDN。**

*应用驱动在Windows系统的默认安装路径为：C:\TDengine.*



### 4.3   服务器目录

| **目录/文件**                 | **说明**                                                   |
| ----------------------------- | ---------------------------------------------------------- |
| **/usr/local/taos/bin**       | 可执行文件目录。其中的执行文件都会软链接到/usr/bin目录下。 |
| **/usr/local/taos/connector** | 各种连接器目录。                                           |
| **/usr/local/taos/driver**    | 动态链接库目录。会软链接到/usr/lib目录下。                 |
| **/usr/local/taos/examples**  |                                                            |
| **/usr/local/taos/include**   | 对外提供的C语言接口的头文件。                              |
| **/etc/taos/taos.cfg**        | 默认[配置文件]                                             |
| **/var/lib/taos**             | 默认数据文件目录,可通过[配置文件]修改位置.                 |
| **/var/log/taos**             | 默认日志文件目录,可通过[配置文件]修改位置                  |

