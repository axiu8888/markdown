#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "创建 zookeeper"
zkDir=$baseDir/zookeeper/zk
echo "安装目录：$zkDir"
mkdir -p $zkDir
cd $zkDir &&
    mkdir -p ./data &&
    mkdir -p ./conf &&
    mkdir -p ./logs &&
    chmod 755 ./*
# 创建zoo,cfg
touch $zkDir/conf/zoo.cfg
echo "
tickTime=2000
initLimit=5
syncLimit=2
dataDir=/data
dataLogDir=/datalog
clientPort=2181
maxClientCnxns=60
server.1=0.0.0.0:2888:3888
#server.2=192.168.0.112:2888:3888
#server.3=192.168.0.113:2888:3888
" >$zkDir/conf/zoo.cfg
# 创建myid
touch $zkDir/data/myid
echo "1" >$zkDir/data/myid
chmod 755 $zkDir/*/*
# 创建容器
docker run --privileged -d --restart=always \
    --network mynet --network-alias zookeeper-net \
    -p 2181:2181 \
    -p 2888:2888 \
    -p 3888:3888 \
    -v /etc/localtime:/etc/localtime \
    -v $zkDir/zk/conf/zoo.cfg:/var/lib/zookeeper/conf/zoo.cfg \
    -v $zkDir/data:/var/lib/zookeeper/data \
    -v $zkDir/logs:/var/lib/zookeeper/datalog \
    --name zookeeper \
    zookeeper
