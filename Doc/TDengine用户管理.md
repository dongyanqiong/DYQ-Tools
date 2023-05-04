# TDengine用户管理

## 1.账户和用户管理

一、	TDengine支持两个层级的管理。
第一级是account，即账户；
第二级是user，即用户，在account下面可以建立user。
二、系统安装后，有一个缺省账户root，密码缺省是taosdata，且root账户永不会被删除。
三、TDengine支持read、write、super三种权限。
read：只能查询权限，如查询用户、数据库、表、表记录；
write：除了read权限外，还支持创建数据库、表；
super：除了read、write权限外，还支持创建用户，修改用户权限（仅限read、write）；

### 1.1	账户管理

•	只有root账户可以创建新账户、删除账户、查询账户
•	系统安装后，有一个缺省账户root，密码缺省是taosdata
	CREAT ACCOUNT account_name PASS ‘password’；
创建账户，并指定账户名和密码，密码需要用单引号引起来
	 DROP ACCOUNT account_name；
删除账户
	 SHOW ACCOUNTS；
显示所有账户
注：root无权越级查看其它account下的user，也无法添加、删除那个account下user，但能看到其它的account，能修改其他account下的用户名的密码

### 1.2	用户管理

•	在创建账户（如testac）的同时会默认创建两个用户：
一个是同账户名的用户（如testac），该用户名作为该账户下的主用户名（account manager），具有super权限，可以添加、删除、修改同组内其他用户（仅能修改成read、write权限）；
一个是同账户名前加下划线（如_testac），拥有write权限，被流计算使用。
•	只有主用户（account manager）可以添加用户、删除用户、修改用户权限。
	CREATE USER user_name PASS ‘password’
创建用户，并指定用户名和密码，密码需要用单引号引起来
	DROP USER user_name
删除用户 
	ALTER USER user_name PRIVILEGE read 
修改用户权限为read （限同账户名的用户使用）
	ALTER USER user_name PRIVILEGE write
修改用户权限为write（限同账户名的用户使用）
	SHOW USERS
显示所有用户
注：1、不同账户下的用户，也不能同名。
2、自己不能删除自己。
3、 root无权越级查看其它account下的user，也无法添加、删除其他account下user。

### 1.3	密码管理

• 设置密码时，如果是大小写字母混合，请用单引号将密码包起来
• 任何用户可以修改自己的密码
• 主用户（account manager）可以修改本账户里面所有用户的密码
• root可以修改任何用户的密码

	ALTER USER user_name PASS ‘password’  
修改用户密码

1.1.4	数据库以及表的管理：
• 任何一个用户，包括root和主用户（account manager），只能查看属于自己account账户的数据
• 只有root, 才有权限查看整个系统节点的信息。

## 2.账户操作

### 2.1.创建新账户


create account hou pass "hou" tseries 80000 storage 10737418240 streams 10 qtime 3600 dbs 3 users 3 conns 10 state "all"

state有四个输入选项：r （读权限），w（写权限），all （读写权限），no（无权限）

### 2.2.删除账户

`drop account ACCOUNT_NAME`