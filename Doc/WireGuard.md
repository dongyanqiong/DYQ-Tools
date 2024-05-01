
[Install WebSite](https://www.wireguard.com/install/#installation)


```bash
yum -y install epel-release elrepo-release
yum -y install yum-plugin-elrepo
yum -y install kmod-wireguard wireguard-tools
```

```bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.proxy_arp = 1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

```


```bash
wg genkey > private.key
wg pubkey < private.key  > public.key
```

## 服务端 wg0.conf
```bash
[Interface]
Address = 172.16.2.3/32
ListenPort = 8820
## 服务端私钥
PrivateKey = YO8FD+Pr+vMvQAUBXIAV4Yhrr0aBlDrlUc50Mv01S3g=
DNS = 192.168.1.252
MTU = 1500
PostUp = iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT;iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT;iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT;iptables -t nat -A POSTROUTING -s 172.16.2.0/24 -o ens192 -j MASQUERADE
PostDown = iptables -D INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT;iptables -D FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT;iptables -D FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT;iptables -t nat -D POSTROUTING -s 172.16.2.0/24 -o ens192 -j MASQUERADE

[Peer]
AllowedIPs = 172.16.2.1/24
## 客户端公钥
PublicKey = KlopGMq3A86LVvWXEzQ4GiSLQCSjWaPDuMx/QTA3gV8=
```

## 客户端 client.conf
```bash
[Interface]
Address = 172.16.2.13/32
## 客户端私钥
PrivateKey = 4OIW8bA7El1NK0YCVCYZf7jLWOZp8D3nOjddFM5zc2g=
DNS = 8.8.8.8
MTU = 1500

[Peer]
Endpoint = bj.taosdata.com:8820
## 服务端公钥
PublicKey = TxxHmFuozmzcxv9fTz4QOoJ6q6pBUwl251tpzp23HTU=
AllowedIPs = 0.0.0.0/0
```

## 启停服务端
```bash
wg-quick up wg0
wg-quick down wg0
```

## 启停客户端
```bash
wg-quick up client
wg-quick down wg0
```

### 查看VPN接口详细信息
```bash
wg show all
```