# Windows上安装docker

参考：[https://docs.docker.com/desktop/wsl/](https://docs.docker.com/desktop/wsl/)
参考：[https://docs.docker.com/desktop/install/windows-install/](https://docs.docker.com/desktop/install/windows-install/)

## 打开虚拟化

以管理员模式打开powershell，执行如何命令：

```

dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All
bcdedit /set hypervisorlaunchtype auto

```

## 安装wsl

```

# 更新到wsl2
wget https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

# 设置wsl版本
wsl.exe --set-version 2

# 查看可安装的列表
wsl.exe --list --online
或: wsl -l -o

# 选择需要安装的版本，以Ubuntu-22.04为例
wsl --install -d Ubuntu-22.04

```

关于

## 建立软连接

```

# 将D:盘下的/home/znsx 映射到 /home/下
ln -s /mnt/d/home/znsx  /home/


```

## docker自动补全的问题

```

apt-get install -y bash-completion
ls -l /bin/sh
dpkg-reconfigure dash
cd /usr/share/bash-completion
chmod +x ./bash_completion
./bash_completion

```

## wsl 无法解析服务器的名称或地址

修改DNS
改为
114.114.114.114
8.8.8.8

## 网络配置

### 启用hyper-v

在powershell的超级管理员模式下执行 hyper-v_enable.cmd，然后重启

### .wslconfig配置

参考：http://www.yxfzedu.com/article/1758

关于 `.wslconfig` 的配置说明: [https://learn.microsoft.com/zh-cn/windows/wsl/wsl-config](https://learn.microsoft.com/zh-cn/windows/wsl/wsl-config)

创建文件 C:/Users/Administrator/.wslconfig

```
[wsl2]
networkingMode=bridged
vmSwitch=WSLBridge
autoMemoryReclaim=gradual
dnsTunneling=true
firewall=false
autoProxy=true
ipv6=true
dhcp=true

```

### Ubuntu配置

vim /etc/wsl.conf

```
[boot]
systemd = true

[network]
generateHosts = false
generateResolvConf = false

```

vim /etc/systemd/network/my-network.conf

```
[Match]
Name=et*
#Name=en*
 
[Network]
DHCP=ipv4

```

vim /etc/resolv.conf

```

nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 114.114.114.114
nameserver 192.168.124.1

```

systemctl restart systemd-networkd

vim /etc/netplan/00-wsl2.yaml

```
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: [192.168.124.15/24]
      gateway4: 192.168.124.1
      routes:
      - to: default
        via: 192.168.124.1
      nameservers:
        addresses: [8.8.8.8, 114.114.114.114, 192.168.124.1]
```

```

apt install mininet -y
sudo netplan apply

```

~
