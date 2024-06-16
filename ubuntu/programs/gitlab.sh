#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "创建 gitlab"
gitlabDir=$baseDir/gitlab
echo "安装目录：$gitlabDir"
docker run --privileged -d --restart=always \
    --network mynet --network-alias gitlab-net \
    -p 8823:80 \
    -v $gitlabDir/etc:/etc/gitlab \
    -v $gitlabDir/log:/var/log/gitlab \
    -v $gitlabDir/gitlab/var:/var/opt/gitlab \
    --name gitlab \
    gitlab/gitlab-ce
