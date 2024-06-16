#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 nginx"
nginxDir=$baseDir/nginx
echo "安装目录：$nginxDir"
mkdir -p $nginxDir && cp -r $PWD/programs/nginx/* $nginxDir
docker run --privileged -d --restart=always \
    --network mynet --network-alias nginx-net \
    -p 80:80 \
    -p 443:443 \
    -v $nginxDir/share/:/usr/share/nginx/ \
    -v $nginxDir/conf.d/:/etc/nginx/conf.d/ \
    -v $nginxDir/var:/var/lib/nginx \
    -v $nginxDir/log:/var/log/nginx \
    --name nginx \
    nginx

# echo "拷贝nginx.conf文件"
# cd $nginxDir || exit
#docker cp ./nginx.conf nginx:/etc/nginx/nginx.conf
