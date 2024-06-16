#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 minio"
minioDir=$baseDir/minio
echo "安装目录：$minioDir"
docker run --privileged -d --restart=always \
    --network mynet --network-alias minio-net \
    -p 9006:9000 \
    -p 9003:9003 \
    -e MINIO_ACCESS_KEY=admin \
    -e MINIO_SECRET_KEY=admin123 \
    -v $minioDir/config:/root/.minio \
    -v $minioDir/data1:/data1 \
    -v $minioDir/data2:/data2 \
    -v $minioDir/data3:/data3 \
    -v $minioDir/data4:/data4 \
    --name minio \
    minio/minio server http://minio-net/data{1...4} \
    --console-address ":9003"
