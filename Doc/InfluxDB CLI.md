# InfluxDB CLI

InfluxDB 提供了客户端 influx 用于管理数据库。自2.1版本，客户端influx就和服务端influxd分离开了，需要单独安装。

在1.x版本中客户端支持SQL语句，但在2.x版本中，已经不支持SQL语法了。这对熟悉关系型数据库的人来说不太友好。

## 1.客户端初始化

InfluxDB 服务端启动后，使用Influx CLI 进行初始化（使用web管理界面操作更加方便，http://IP:port ，默认端口8086，我在配置文件修改成了8080）。

```shell
#influx setup --host http://localhost:8080
> Welcome to InfluxDB 2.0!
? Please type your primary username admin
? Please type your password *********
? Please type your password again *********
? Please type your primary organization name test
? Please type your primary bucket name db01
? Please type your retention period in hours, or 0 for infinite 0
? Setup with these parameters?
  Username:          admin
  Organization:      test
  Bucket:            db01
  Retention Period:  infinite
 Yes
User    Organization    Bucket
admin   test            db01

```

查看当前配置

```shell
#influx config
Active  Name    URL                     Org
*       default http://localhost:8080   test
```

查看当前客户端配置

```shell
influx config
```

创建 Token，Token 在以后的操作中非常必要。

```shell
#influx auth create -o test --all-access
ID                      Description     Token                                                                                           User Name       User ID         Permissions
094769ed38624000                        dK-GjQBMFVBw_cjaxhI7ekuGi3ouJ8FkJ1plEE39iOHnqRedZuTXCy96jQhqOEa1Rdb9A5jEin-GxKDsp7DbWw==        admin           094769346d624000[read:orgs/d781e1ab6a34faad/authorizations write:orgs/d781e1ab6a34faad/authorizations read:orgs/d781e1ab6a34faad/buckets write:orgs/d781e1ab6a34faad/buckets read:orgs/d781e1ab6a34faad/dashboards write:orgs/d781e1ab6a34faad/dashboards read:/orgs/d781e1ab6a34faad read:orgs/d781e1ab6a34faad/sources write:orgs/d781e1ab6a34faad/sources read:orgs/d781e1ab6a34faad/tasks write:orgs/d781e1ab6a34faad/tasks read:orgs/d781e1ab6a34faad/telegrafs write:orgs/d781e1ab6a34faad/telegrafs read:/users/094769346d624000 write:/users/094769346d624000 read:orgs/d781e1ab6a34faad/variables write:orgs/d781e1ab6a34faad/variables read:orgs/d781e1ab6a34faad/scrapers write:orgs/d781e1ab6a34faad/scrapers read:orgs/d781e1ab6a34faad/secrets write:orgs/d781e1ab6a34faad/secrets read:orgs/d781e1ab6a34faad/labels write:orgs/d781e1ab6a34faad/labels read:orgs/d781e1ab6a34faad/views write:orgs/d781e1ab6a34faad/views read:orgs/d781e1ab6a34faad/documents write:orgs/d781e1ab6a34faad/documents read:orgs/d781e1ab6a34faad/notificationRules write:orgs/d781e1ab6a34faad/notificationRules read:orgs/d781e1ab6a34faad/notificationEndpoints write:orgs/d781e1ab6a34faad/notificationEndpoints read:orgs/d781e1ab6a34faad/checks write:orgs/d781e1ab6a34faad/checks read:orgs/d781e1ab6a34faad/dbrp write:orgs/d781e1ab6a34faad/dbrp read:orgs/d781e1ab6a34faad/notebooks write:orgs/d781e1ab6a34faad/notebooks read:orgs/d781e1ab6a34faad/annotations write:orgs/d781e1ab6a34faad/annotations read:orgs/d781e1ab6a34faad/remotes write:orgs/d781e1ab6a34faad/remotes read:orgs/d781e1ab6a34faad/replications write:orgs/d781e1ab6a34faad/replications]
```

## 2.数据写入

表结构：

| 表名 | 标签1    | 标签2 | 列名 |
| ---- | -------- | ----- | ---- |
| tb01 | building | Floor | temp |

数据：

| building | floor | temp | timestamp  |
| -------- | ----- | ---- | ---------- |
| Baoli    | 702a  | 24.5 | 1651036342 |

```sh
influx write \
  -b db01 \
  -o test \
  -p s \
  't01,building=boli,floor=702a temp=24.5  1651036342'
```

## 3.数据查询



```js
influx query 'from(bucket: "db01")
    |> range(start: -60h)
    |> filter(fn: (r) => r._measurement == "t01" and r.building == "boli" and r.floor=="702a")
    |> filter(fn: (r) => r._field == "temp")'
```

```shell
#influx query 'from(bucket: "test")
>     |> range(start: -6h)
>     |> filter(fn: (r) => r._measurement == "t01" and r.building == "boli" and r.floor=="702a")
>     |> filter(fn: (r) => r._field == "temp")'
Error: failed to execute query: 404 Not Found: failed to initialize execute state: could not find bucket "test"
[root@i0-110 ~]# influx query 'from(bucket: "db01")
>     |> range(start: -60h)
>     |> filter(fn: (r) => r._measurement == "t01" and r.building == "boli" and r.floor=="702a")
>     |> filter(fn: (r) => r._field == "temp")'
Result: _result
Table: keys: [_start, _stop, _field, _measurement, building, floor]
                   _start:time                      _stop:time           _field:string     _measurement:string         building:string            floor:string                      _time:time                  _value:float
------------------------------  ------------------------------  ----------------------  ----------------------  ----------------------  ----------------------  ------------------------------  ----------------------------
2022-04-25T12:57:12.487988590Z  2022-04-28T00:57:12.487988590Z                    temp                     t01                    boli                    702a  2022-04-27T05:12:22.000000000Z    
```

## 4.备份恢复

备份恢复需要admin 用户token

```shell
 influx backup /data/dump/ -t dK-GjQBMFVBw_cjaxhI7ekuGi3ouJ8FkJ1plEE39iOHnqRedZuTXCy96jQhqOEa1Rdb9A5jEin-GxKDsp7DbWw==
```

```shell
influx restore /data/dump/ -t  dK-GjQBMFVBw_cjaxhI7ekuGi3ouJ8FkJ1plEE39iOHnqRedZuTXCy96jQhqOEa1Rdb9A5jEin-GxKDsp7DbWw==
```

```shell
##恢复指定bucket
influx restore /data/dump/ --bucket db01 -t  dK-GjQBMFVBw_cjaxhI7ekuGi3ouJ8FkJ1plEE39iOHnqRedZuTXCy96jQhqOEa1Rdb9A5jEin-GxKDsp7DbWw==
```

## 5.用户管理

### 5.1.用户创建

为组织test创建用户billy，密码 Passw0rd

```shell
#influx user create -n billy -p 'Passw0rd' -o test     
ID                      Name
09476ebecfe24000        billy
```

查看当前用户

```shell
# influx user list
ID                      Name
094769346d624000        admin
09476ebecfe24000        billy
```

### 5.2.修改密码

```shell
#influx user password -n billy
? Please type new password for "billy" *********
? Please type new password for "billy" again *********
Successfully updated password for user "billy"
```

### 5.3.删除用户

WEB管理界面无法删除用户，只能通过CLI来进行。删除用户只能通过user-id来完成。

```shell
# influx user delete -i 09476ebecfe24000
ID                      Name    Deleted
09476ebecfe24000        billy   true
# influx user list
ID                      Name
094769346d624000        admin
```

## 6.数据库管理

InfluxDB中没有Database，只有Organization 和 Bucket。用关系库的理解，Organization 对应数据库示例，Bucket对应Database。

### 6.1.Org管理

```shell
##创建org
# influx org create -n db02
ID                      Name
4e4317920dba2bb5        db02
# influx org list
ID                      Name
4e4317920dba2bb5        db02
d781e1ab6a34faad        test

##重命名org
# influx org update -i 4e4317920dba2bb5 -n test2
ID                      Name
4e4317920dba2bb5        test2
# influx org list
ID                      Name
4e4317920dba2bb5        test2
d781e1ab6a34faad        test

##删除org
# influx org delete -i 4e4317920dba2bb5       
ID                      Name    Deleted
4e4317920dba2bb5        test2   true
# influx org list
ID                      Name
d781e1ab6a34faad        test
```

### 6.2.Bucket管理

```shell
##创建bucket
# influx bucket create -n db02 -o test -r 1w
ID                      Name    Retention       Shard group duration    Organization ID         Schema Type
e6e6f7ae16812784        db02    168h0m0s        24h0m0s                 d781e1ab6a34faad        implicit

# influx bucket list -o test
ID                      Name            Retention       Shard group duration    Organization ID         Schema Type
74091a2d2a220be1        _monitoring     168h0m0s        24h0m0s                 d781e1ab6a34faad        implicit
5175f85981b38eef        _tasks          72h0m0s         24h0m0s                 d781e1ab6a34faad        implicit
493461b293cb9760        db01            infinite        168h0m0s                d781e1ab6a34faad        implicit
e6e6f7ae16812784        db02            168h0m0s        24h0m0s                 d781e1ab6a34faad        implicit

##重命名bucket
# influx bucket update -i e6e6f7ae16812784 -n db03 -r 2w
ID                      Name    Retention       Shard group duration    Organization ID         Schema Type
e6e6f7ae16812784        db03    336h0m0s        24h0m0s                 d781e1ab6a34faad        implicit

# influx bucket list -o test
ID                      Name            Retention       Shard group duration    Organization ID         Schema Type
74091a2d2a220be1        _monitoring     168h0m0s        24h0m0s                 d781e1ab6a34faad        implicit
5175f85981b38eef        _tasks          72h0m0s         24h0m0s                 d781e1ab6a34faad        implicit
493461b293cb9760        db01            infinite        168h0m0s                d781e1ab6a34faad        implicit
e6e6f7ae16812784        db03            336h0m0s        24h0m0s                 d781e1ab6a34faad        implicit

##删除bucket
# influx bucket delete -n db03 -o test
ID                      Name    Retention       Shard group duration    Organization ID         Schema Type     Deleted
e6e6f7ae16812784        db03    336h0m0s        24h0m0s                 d781e1ab6a34faad        implicit        true

# influx bucket list -o test          
ID                      Name            Retention       Shard group duration    Organization ID         Schema Type
74091a2d2a220be1        _monitoring     168h0m0s        24h0m0s                 d781e1ab6a34faad        implicit
5175f85981b38eef        _tasks          72h0m0s         24h0m0s                 d781e1ab6a34faad        implicit
493461b293cb9760        db01            infinite        168h0m0s                d781e1ab6a34faad        implicit
```



https://docs.influxdata.com/influxdb/v2.2/reference/cli/influx/

![image-20220427173021427](InfluxDB CLI.assets/image-20220427173021427.png)

![image-20220427173109716](InfluxDB CLI.assets/image-20220427173109716.png)