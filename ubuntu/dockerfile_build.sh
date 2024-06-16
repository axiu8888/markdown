#!/bin/bash

echo "创建网络: mynet"
{
    docker network create --driver bridge mynet
}

echo -e "\n-----------------------------------"
echo "构建docker镜像"

dir=$PWD

cd $dir/dockerfile/ubuntu && chmod 755 *
docker build -f Dockerfile --rm  --tag ubuntu-jdk:v1 .
