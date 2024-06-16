#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 nexus3"
nexus3Dir=$baseDir/nexus3
echo "安装目录：$nexus3Dir"
mkdir -p $nexus3Dir/data && chmod 777 $nexus3Dir/data
docker run --privileged -d --restart=always \
    --network mynet --network-alias nexus3-net \
    -p 9001:8081 \
    -v $nexus3Dir/data:/nexus-data \
    --name nexus3 \
    sonatype/nexus3