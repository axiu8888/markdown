#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 emqx"
emqxDir=$baseDir/emqx
echo "安装目录：$emqxDir"
mkdir -p $emqxDir/log && mkdir -p $emqxDir/etc

echo "创建临时的emqx"
docker run -d --restart=always \
    --name emqx --network mynet --network-alias emqx-net \
    -p 1883:1883 \
    -p 18083:18083 \
    emqx/emqx
echo "拷贝emqx"
docker cp emqx:/opt/emqx/etc $emqxDir
docker cp emqx:/opt/emqx/log $emqxDir
docker rm -f emqx

chmod 777 $emqxDir/*

# 创建新的emqx
docker run --privileged -d --restart=always \
    --network mynet --network-alias emqx-net \
    -p 1883:1883 \
    -p 18083:18083 \
    -v $emqxDir/etc:/opt/emqx/etc \
    -v $emqxDir/log:/opt/emqx/log \
    --name emqx \
    emqx/emqx
