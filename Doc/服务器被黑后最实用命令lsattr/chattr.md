如果你的 Linux 服务器被黑过，那么对 lsattr/chattr 这个两个命令肯定不陌生。

Linux 服务器被黑后，我们通常会发现`/etc/hosts`,`.ssh/authorized_keys`,`/etc/crontab`,`/etc/passwd` 等等，这些文件无法删除、无法修改。

这些现象就是文件属性(attribute)被修改造成的。

## 用法简介
lsattr  [filename]  查看文件属性
chattr  +|-|= attr filename  修改文件属性
`+`  添加权限
`-`  删除权限
`=`  设定权限
具体用法见示例。  

## 属性说明
Linux下的文件除了具有读、写、执行权限外，还拥有属性，对于普通文件属性通常为空。
```bash
[root@test1 attrtest]# echo "test file" >> test1.txt
[root@test1 attrtest]# ll
total 4
-rw-r--r-- 1 root root 10 Feb  3 08:55 test1.txt
[root@test1 attrtest]# lsattr 
---------------- ./test1.txt

```
文件都有哪些属性呢？ 在 chattr 的 man page 里面列了如下几种：
|属性|说明|
|---|---|
|a|文件只能追加内容|
|A|文件atime不会被修改|
|c|文件会被压缩存储|
|C|copy-on-write，仅部分文件系统支持。|
|d|dump程序运行时，被标记文件不会被备份|
|D|当文件夹设置该属性，修改会被同步写入磁盘类似于`dirsync`|
|e|不能用`chattr`删除|
|E|压缩错误|
|h|被标识文件以文件系统块大小存储而非扇区，该属性不能被`chattr`修改。|
|i|文件不能被修改|
|I|目录正在被索引，该属性不能被`chattr`修改。|
|j|如果文件系统以`data=ordered`方式挂载，被标识文件采用`data=journal`模式处理。|
|N|文件本身有数据存储在indoe中，该属性不能被`chattr`修改。|
|s|被标识文件被删除时，响应磁盘块会被清零，无法恢复。|
|S|文件修改会被立即写入磁盘，相当于`sync`|
|t|和文件合并有关，部分文件系统不支持。|
|T|具有该标识的目录会被视为目录层次的顶端。|
|u|被标识文件被删除时，文件会被保护下来。|
|X|表明压缩文件内容可被访问，该属性不能被`chattr`修改。|
|Z|压缩文件已损坏，该属性不能被`chattr`修改。|

> `c`,`s`,`u` 在ext2、ext3、ext4文件系统中不支持。
> `j`仅用于ext3和ext4系统。
> `D`仅在 kernel 2.5.19 后支持

虽然文件的属性有一大堆，但是最常用的还是`i`和`a`。 

## 示例

### 文件无法被删除
添加`i`属性
```bash
[root@test1 attrtest]# chattr +i test1.txt 
[root@test1 attrtest]# lsattr 
----i----------- ./test1.txt
[root@test1 attrtest]# rm -f test1.txt 
rm: cannot remove ‘test1.txt’: Operation not permitted
```
删除`i`属性
```bash
[root@test1 attrtest]# chattr -i test1.txt 
[root@test1 attrtest]# rm -f test1.txt 
[root@test1 attrtest]# ll
total 0
```
## 文件无法修改
添加`a`属性
```bash
[root@test1 attrtest]# cat test1.txt 
1
2
3
4
5
6
7
8
9
[root@test1 attrtest]# chattr +a test1.txt 
[root@test1 attrtest]# lsattr 
-----a---------- ./test1.txt
[root@test1 attrtest]# sed -i '/4/d' test1.txt 
sed: cannot rename ./sedWDSTf4: Operation not permitted
[root@test1 attrtest]# echo '77' >test1.txt 
-bash: test1.txt: Operation not permitted
[root@test1 attrtest]# echo '77' >>test1.txt 
[root@test1 attrtest]# cat test1.txt 
1
2
3
4
5
6
7
8
9
77
```
删除`a`属性
```bash
[root@test1 attrtest]# chattr -a test1.txt 
[root@test1 attrtest]# lsattr 
---------------- ./test1.txt
[root@test1 attrtest]# sed -i '/4/d' test1.txt 
[root@test1 attrtest]# cat test1.txt 
1
2
3
5
6
7
8
9
77
[root@test1 attrtest]# echo '88' >test1.txt 
[root@test1 attrtest]# cat test1.txt 
88
```




