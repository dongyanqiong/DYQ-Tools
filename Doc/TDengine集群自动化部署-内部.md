# TDengine集群自动化部署-内部

## 1.环境准备

### 1.1 安装Ansible

```shell
yum install epel-release -y
yum install ansible -y
```

### 1.2 解压缩配置包

```shell
tar cvzf tdengine.gz -C /etc/ansible/
```

### 1.3 配置 /etc/ansible/hosts 

```shell
##示例
[atest]
192.168.0.81 ansible_ssh_user="root" ansible_ssh_pass="tbase125!" 
```

## 2.环境预配置

### 2.1 修改预配置主任务 

/etc/ansible/tdengine/roles/preset.yml

```shell
- name: Preset
	hosts: atest   ###hosts中组名称
  vars:
    coredir: "/var"   ###core文件位置
    cluster: "atest"  ###集群名称，用于定义不同hosts文件
  roles:
    - preset
```

### 2.2 添加hosts文件

在/etc/ansible/tdengine/roles/preset/files/atest/ 下创建hosts文件

```shell
192.168.0.81 c0-81
```

## 3.配置安装主任务

### 3.1 修改安装主任务文件

/etc/ansible/tdengine/roles/install.yml

```shell
- name: TDengine
  hosts: atest  ###hosts中的组名称
  vars:
     pkg: "TDengine-enterprise-server-2.2.1.3-Linux-x64.tar.gz"  ###安装包名称
     dir: "TDengine-enterprise-server-2.2.1.3"   ###安装包解压后文件夹名称
  roles:
    - install
```

### 3.2 准备安装文件

在安装目录下准备安装包和配置文件

```shell
/etc/ansible/tdengine/rolesinstall/files
├── taos.cfg
└── TDengine-enterprise-server-2.2.1.3-Linux-x64.tar.gz
```

## 4.安装TDengine

```shell
ansible-playbook /etc/ansible/tdengine/roles/preset.yml 
ansible-playbook /etc/ansible/tdengine/roles/install.yml 
```

















