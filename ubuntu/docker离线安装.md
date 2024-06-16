# docker 离线安装

## 下载

地址：https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/

在浏览器中搜索：2024-06，这里的时间可以替换为最新包的时间；

```

# 切换目录
mkdir -p /opt/docker_debs/ && cd /opt/docker_debs/

# 下载安装包
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/containerd.io_1.6.33-1_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-buildx-plugin_0.14.1-1~ubuntu.20.04~focal_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce-cli_26.1.4-1~ubuntu.20.04~focal_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce-rootless-extras_26.1.4-1~ubuntu.20.04~focal_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce_26.1.4-1~ubuntu.20.04~focal_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-compose-plugin_2.27.1-1~ubuntu.20.04~focal_amd64.deb

```

## 安装

创建脚本 dep_install.sh

```
#!/bin/bash

apt-get update -y
apt-get iptables -y


# 生成 deb_pkg.txt 文件
ls | grep ".deb" > ./deb_pkg.txt

cat ./deb_pkg.txt

echo "安装 =================>: dpkg install start..."

# 读取 deb_pkg.txt 文件并安装 .deb 包
while IFS= read -r file
do
  if [ -n "$file" ]; then
     echo "安装 =================>: sudo dpkg -i $file"
     sudo dpkg -i "$file"
  fi
done < ./deb_pkg.txt

echo "安装 =================>: dpkg install end..."

rm -rf ./deb_pkg.txt

```
