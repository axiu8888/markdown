#!/bin/bash

echo ""
echo "-----------------------------------"
echo "安装 webssh"
echo "访问地址 http://ip:5022/webssh"
# --net=host \
docker run -d --restart=always \
    --network mynet --network-alias webssh-net \
    --log-driver json-file \
    --log-opt max-file=1 \
    --log-opt max-size=100m \
    -p 5022:22/tcp \
    -e TZ=Asia/Shanghai \
    -e savePass=true \
    -e port=22 \
    --name webssh \
    jrohy/webssh
