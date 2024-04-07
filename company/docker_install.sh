#!/bin/bash

echo "移除旧版本"
sudo yum remove docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-engine
# sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
echo "安装需要的组件"
sudo yum install -y yum-utils

echo "配置阿里云的仓库地址"
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

echo "安装"
sudo yum install podman -y
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y --allowerasing --skip-broken --nobest
# sudo yum install docker-ce docker-ce-cli containerd.io --skip-broken --nobest

sudo systemctl enable docker.service
sudo systemctl stop docker

# echo -e "\n--------------------------------------"
# echo "创建deamon.json"
# mkdir -p /etc/docker
# dockerDeamon=/etc/docker/daemon.json
# touch $dockerDeamon
# echo '{
#   "registry-mirrors": [
#     "https://ustc-edu-cn.mirror.aliyuncs.com",
#     "https://hub-mirror.c.163.com",
#     "https://mirror.baidubce.com"
#   ],
#   "storage-driver": "devicemapper"
# }
# ' >$dockerDeamon

echo "启动"
sudo systemctl restart docker

