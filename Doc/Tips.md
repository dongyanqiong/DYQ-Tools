## 去除不可见字符
```bash
tr -cd "[:print:]\n" < file1  >>newfile
```

## 大文件切割
```bash
split -200000 -d taosdlog.0 part_ --verbose
```

## nmon
```bash
./nmon -f -s 10 -c 60 -m /tmp/nmon 
```

# 参数说明 
-f   监控结果以文件形式输出，默认机器名+日期.nmon格式 
-F   指定输出的文件名，比如test.nmon 
-s   指的是采样的频率，单位为毫秒 
-c   指的是采样的次数，即以上面的采样频率采集多少次 
-m   指定生成的文件目录 