#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "创建 jenkins"
jenkinsDir=$baseDir/jenkins
echo "安装目录：$jenkinsDir"
cd /opt/programs/ && mkdir -p ./jenkins && chmod 777 ./jenkins && cd ./jenkins
docker run --privileged -d --restart=always \
    --network mynet --network-alias jenkins-net \
    -p 9095:8080 \
    -p 9096:50000 \
    -v /etc/localtime:/etc/localtime \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/bin/docker:/usr/bin/docker \
    -v $jenkinsDir:/var/jenkins_home \
    -uroot \
    --name jenkins \
    jenkins/jenkins:jdk11
