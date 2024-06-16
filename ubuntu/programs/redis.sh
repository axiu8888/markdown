#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 redis"
redisDir=$baseDir/redis
echo "安装目录：$redisDir"
docker run --privileged -d --restart=always \
    --network mynet --network-alias redis-net \
    -p 6379:6379 \
    -v $redisDir/data:/var/lib/data \
    --name redis \
    redis \
    --appendonly yes
