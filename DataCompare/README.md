
对比数据差异

1. 修改脚本中源和目标段信息

```python
suserName = 'kunyue'
spassWord = 'kunyue'
surl = 'http://192.168.3.66:6041/rest/sql'
sdb = 'db'
sversion = 2
duserName = 'kunyue'
dpassWord = 'kunyue'
durl = 'http://192.168.3.68:6041/rest/sql'
ddb = 'db'
dversion = 3
stime = '2023-06-13T00:00:00.000+00:00'
etime = '2023-07-23T00:00:00.000+00:00'
unit = '1d'
```

2. 在 stblist 中加入超级表名称

3. 运行python脚本

```bash
python3 datacompare.py
```

** 备注 **

-- TDengine 2.0.x 版本不支持反引号