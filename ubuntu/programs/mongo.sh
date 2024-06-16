#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 mongo"
mongoDir=$baseDir/mongo
echo "安装目录：$mongoDir"
docker run --privileged -d --restart=always \
    --network mynet --network-alias mongo-net \
    -e MONGO_INITDB_ROOT_USERNAME=admin \
    -e MONGO_INITDB_ROOT_PASSWORD=admin123 \
    -p 27017:27017 \
    -v $mongoDir/db:/data/db/ \
    --name mongo \
    mongo
