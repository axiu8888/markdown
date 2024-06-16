#!/bin/bash

echo "创建网络: mynet"
{
    docker network create --driver bridge mynet
}

baseDir=/opt/apps

echo -e "\n-----------------------------------"
echo "创建 athenapdfservice"
athenapdfserviceDir=$baseDir/athenapdfservice
docker run -d --restart=always \
    --privileged=true \
    --network mynet --network-alias athenapdfservice-net \
    -p 35005:5005/tcp \
    -p 8001:80/tcp \
    -v /etc/localtime:/etc/localtime \
    -v /etc/timezone:/etc/timezone \
    -v /usr/bin/docker:/usr/bin/docker \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $baseDir/data:/opt/app/data/ \
    -v $athenapdfserviceDir/docker-entrypoint.sh:/docker-entrypoint.sh \
    -v $athenapdfserviceDir:/opt/app/ \
    --name athenapdfservice \
    ubuntu-jdk:v1

echo -e "\n-----------------------------------"
echo "创建 system"
systemDir=$baseDir/system
docker run -d --restart always \
    --privileged=true \
    --network mynet --network-alias system-net \
    -p 35007:5005/tcp \
    -p 8002:80/tcp \
    -v /etc/localtime:/etc/localtime \
    -v /etc/timezone:/etc/timezone \
    -v $systemDir/docker-entrypoint.sh:/docker-entrypoint.sh \
    -v $systemDir:/opt/app/ \
    --name system \
    ubuntu-jdk:v1

