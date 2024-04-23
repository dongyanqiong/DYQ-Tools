## 安装OpenSSL
```bash
yum install -y openssl
```

## 创建私钥

```bash
openssl  genrsa -des3 -out mykey.pem 2048

#taosExplorer不支持des3
openssl  genrsa  -out mykey.pem 2048
```

```bash
[root@c3-66 sslkey]# openssl  genrsa -des3 -out mykey.pem 2048
Generating RSA private key, 2048 bit long modulus
...........................................................+++
..................................................+++
e is 65537 (0x10001)
Enter pass phrase for mykey.pem:
Verifying - Enter pass phrase for mykey.pem:
```

## 创建签名

```bash
openssl req -new -key mykey.pem  -out cert.csr
```

```bash
[root@c3-66 sslkey]# openssl req -new -key mykey.pem  -out cert.csr
Enter pass phrase for mykey.pem:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:cn
State or Province Name (full name) []:beijing
Locality Name (eg, city) [Default City]:beijing
Organization Name (eg, company) [Default Company Ltd]:taosdata
Organizational Unit Name (eg, section) []:taosdata
Common Name (eg, your name or your server's hostname) []:adapter
Email Address []:it@taosdata.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

## 创建证书

```bash
 openssl x509 -req -days 3650 -in cert.csr -signkey mykey.pem  -out cert.crt
```

```bash
[root@c3-66 sslkey]# openssl x509 -req -days 3650 -in cert.csr -signkey mykey.pem  -out cert.crt
Signature ok
subject=/C=cn/ST=beijing/L=beijing/O=taosdata/OU=taosdata/CN=adapter/emailAddress=it@taosdata.com
Getting Private key
Enter pass phrase for mykey.pem:
```

## 创建公钥

```bash
openssl rsa -in mykey.pem  -inform pem -pubout -out pubkey.pem
```

```bash
[root@c3-66 sslkey]# openssl rsa -in mykey.pem  -inform pem -pubout -out pubkey.pem
writing RSA key
```

## taosAdapter 配置
```bash
[ssl]
enable = true
certFile = "cert.crt"
keyFile = "mykey.pem"
```

## taosExplorer配置

```bash
[ssl]
certificate = "cert.crt"
certificate_key = "mykey.pem"
```

## Nginx 配置

```bash
 server {
        listen 6041 ssl;
        ssl_certificate  /etc/nginx/cert.crt;
        ssl_certificate_key     /etc/nginx/mykey.pem;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE; 
        ssl_prefer_server_ciphers on;
        }
```



## curl测试

```bash
curl -k --insecure -utest244:test https://192.168.3.66:6041/rest/sql -d "select server_version();"
```

打印证书的过期时间
openssl x509 -in signed.crt -noout -dates

打印出证书的内容：
openssl x509 -in cert.pem -noout -text

打印出证书的系列号
openssl x509 -in cert.pem -noout -serial

打印出证书的拥有者名字
openssl x509 -in cert.pem -noout -subject

以RFC2253规定的格式打印出证书的拥有者名字
openssl x509 -in cert.pem -noout -subject -nameopt RFC2253

在支持UTF8的终端一行过打印出证书的拥有者名字
openssl x509 -in cert.pem -noout -subject -nameopt oneline -nameopt -escmsb

打印出证书的MD5特征参数
openssl x509 -in cert.pem -noout -fingerprint

打印出证书的SHA特征参数
openssl x509 -sha1 -in cert.pem -noout -fingerprint

把PEM格式的证书转化成DER格式
openssl x509 -in cert.pem -inform PEM -out cert.der -outform DER

把一个证书转化成CSR
openssl x509 -x509toreq -in cert.pem -out req.pem -signkey key.pem

给一个CSR进行处理，颁发字签名证书，增加CA扩展项
openssl x509 -req -in careq.pem -extfile openssl.cnf -extensions v3_ca -signkey key.pem -out cacert.pem

给一个CSR签名，增加用户证书扩展项
openssl x509 -req -in req.pem -extfile openssl.cnf -extensions v3_usr -CA cacert.pem -CAkey key.pem -CAcreateserial

查看csr文件细节：
openssl req -in my.csr -noout -text
