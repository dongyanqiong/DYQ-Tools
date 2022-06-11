<div style="page-break-after: always; break-after: page;"></div>
# taosKeeper

taosKeeper是TDengine各项监控指标的导出工具，通过简单的几项配置即可获取TDengine的运行状态。并且taosKeeper支持多种收集器，可以方便进行监控数据的展示。

taosKeeper使用TDengine RESTful接口，所以不需要安装TDengine客户端即可使用。

taosKeeper对外提供服务的默认端口为6043。


## 安装

taosKeeper 集成在TDengine server企业版的安装包里，通过运行服务端安装脚本安装。
也可通过拷贝 `taosKeeper` 文件到你的 `PATH` 中来实现安装。

```sh
sudo ./install.sh
```

## 启动

在启动前，需事先配置好两个配置文件：keeper.toml， metrics.toml

首先，在 `/etc/taos/keeper.toml` 配置TDengine连接参数。

```toml
# Start with debug middleware for gin
debug = false

# Listen port, default is 6043
port = 6043

# log level
loglevel = "info"

# go pool size
gopoolsize = 50000

# interval for TDengine metrics
RotationInterval = "15s"

[tdengine]
host = "127.0.0.1"
port = 6041
username = "root"
password = "taosdata"
```

其次，在 `/etc/taos/metrics.toml` 中配置指标前缀等其他信息。

```toml
# metrics prefix in metrics names.
prefix = "taos"

# cluster identifier for multiple TDengine clusters
cluster = "production"
```

如果你希望在非TDengine服务端节点上部署taosKeeper，但希望使用 `systemd`来管理taosKeeper，请复制 `taosKeeper.service` 到 `/lib/systemd/system/` 或 `/etc/systemd/system/`，启动服务。

```sh
sudo cp taoskeeper.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start taosKeeper
```

设置taosKeeper随系统开机自启动。

```sh
sudo systemctl enable taosKeeper
```

## 使用

### Prometheus (by scrape)

taosKeeper可以像 `node-exporter` 一样向Prometheus提供监控指标。\
在 `/etc/prometheus/prometheus.yml` 添加配置：

```yml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: "taosKeeper"
    static_configs:
      - targets: ["taosKeeper:6043"]
```

现在使用PromQL查询即可以显示结果，比如要查看指定主机（通过FQDN正则匹配表达式筛选）硬盘使用百分比：

```promql
taos_dn_disk_used / taos_dn_disk_total {fqdn=~ "tdengine.*"}
```



### Zabbix

1. 导入zabbix临时文件 `zbx_taos_keeper_templates.xml`。
2. 使用 `TDengine` 模板来创建主机，修改宏 `{$taosKeeper_HOST}` 和 `{$COLLECTION_INTERVAL}`。
3. 等待并查看到自动创建的条目。

### 常见问题

* 启动报错，显示connection refused

  **解析**：taosKeeper依赖restful接口查询数据，请检查taosAdapter是否正常运行或keeper.toml中taosAdapter地址是否正确。


* taosKeeper监控不同TDengine实例显示的监测指标数目不一致？

  **解析**：如果TDengine中未创建某项指标，taosKeeper不能获取对应的监测结果。

