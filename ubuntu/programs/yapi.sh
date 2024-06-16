#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 yapi"
yapiDir=$baseDir/yapi
echo "安装目录：$yapiDir"
mkdir -p $yapiDir && touch $yapiDir/config.json && chmod 755 $yapiDir/*
echo '{
    "port": "9009",
    "adminAccount": "root",
    "timeout": 120000,
    "db": {
        "servername": "mongo",
        "DATABASE": "yapi",
        "port": 27017,
        "user": "admin",
        "pass": "admin123",
        "authSource": "admin"
    },
    "mail": {
        "enable": false,
        "host": "smtp.gmail.com",
        "port": 465,
        "from": "*",
        "auth": {
            "user": "dingxiuan@163.com",
            "pass": "admin123"
        }
    }
}
' >$yapiDir/config.json
# 初始化
docker run -d --rm \
    --name yapi-init \
    --link mongo:mongo \
    --net=mynet \
    -v $yapiDir/config.json:/yapi/config.json \
    yapipro/yapi \
    server/install.js
# 安装
docker run --privileged -d --restart=always \
    --network mynet --network-alias yapi-net \
    -p 9009:9009 \
    -v /etc/localtime:/etc/localtime \
    -v /etc/timezone:/etc/timezone \
    -v $yapiDir/config.json:/yapi/config.json \
    --link mongo:mongo \
    --name yapi \
    yapipro/yapi \
    server/app.js
