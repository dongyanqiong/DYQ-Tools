## 简介
使用Python bottle 框架做的线上授权系统。

### grant.sh
模拟授权系统，根据提供的机器码返回一个MD5校验码
并记录到grantlog.log文件中

### index.py
web接口，监听80端口，读取http请求中参数
校验完成后调用grant 生成激活码


## 使用方法
python3 index.py