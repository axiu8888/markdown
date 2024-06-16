#!/bin/bash
# 此命令在linux上时，建议通过 vim /docker-entrypoint.sh编辑，拷贝，否则运行时可能会报错
export LANG=C.UTF-8
#source /etc/profile

baseDir=/opt/programs
echo -e "\n-----------------------------------"
echo "创建 appnode"
dir=$baseDir/appnode
docker run -d --restart always \
    --privileged=true \
    --network mynet --network-alias appnode-net \
    -p 380:80 \
    -v /etc/localtime:/etc/localtime \
    -v /etc/timezone:/etc/timezone \
    -v /opt/env/:/opt/env/ \
    -v $dir/start.sh:/docker-entrypoint.sh \
    -v $dir:/opt/app/ \
    --name appnode \
    appnode:v1
