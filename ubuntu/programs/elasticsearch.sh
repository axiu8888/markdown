#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 elasticsearch"
elasticsearchDir=$baseDir/elasticsearch
echo "安装目录：$elasticsearchDir"
docker run --privileged -d --restart=always \
    --network mynet --network-alias elasticsearch-net \
    -p 9200:9200 \
    -p 9300:9300 \
    -v /etc/localtime:/etc/localtime \
    -v /etc/timezone:/etc/timezone \
    -v $elasticsearchDir/data:/usr/share/elasticsearch/data \
    -e "discovery.type=single-node" \
    --name elasticsearch \
    elasticsearch
