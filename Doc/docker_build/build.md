
## 生成镜像
```shell
docker build --rm -f "/TDengine/packaging/docker/Dockerfile"  --network=host -t tdengine/tdengine-server:e26063 "." --build-arg pkgFile=TDengine-enterprise-server-2.6.0.63-Linux-x64.tar.gz --build-arg dirName="TDengine-enterprise-server-2.6.0.63" --build-arg cpuType="amd64"
```
## 查看镜像

```shell
docker image ls 
```
## 运行镜像
```shell
docker run -d --name doctest -p 6030-6049:6030-6049 -p 6030-6049:6030-6049/udp   dc936a362ea4
```
## 查看容器
```shell
docker container ls -a
```
## 登录容器
```shell
docker ps
docker exec -it dc936a362ea4 /bin/bash
```

## 导出容器
```shell
 docker save dc936a362ea4 >td26063.tar
```
## 删除容器
```shell
docker container rm dc936a362ea4
```
