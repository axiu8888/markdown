#!/bin/bash

echo ""
echo "-----------------------------------"
baseDir=/opt/programs
# source $PWD/conf.properties

kiftdDir=$baseDir/kiftd

mkdir -p $kiftdDir && cd $kiftdDir || exit

echo "首先任意创建出一个镜像"
docker run -d -p 8087:8080 --name kiftd sf2gis/kiftd

echo "等待3秒"
sleep 3

echo "拷贝资源: $baseDir"
docker cp kiftd:/usr/kiftd/ $baseDir || exit

echo "删除容器"
docker rm -f kiftd

echo -e "\n------------------------------------------"
echo "重新创建容器"
docker run --privileged -d --restart=always \
    --network mynet --network-alias kiftd-net \
    -p 8088:80 \
    -v $kiftdDir:/usr/kiftd \
    --name kiftd \
    sf2gis/kiftd
