```shell
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
```

```shell
go get -u github.com/taosdata/driver-go/v2@latest
```

```shell
go mod tidy
```

```shell
go run test.go
```