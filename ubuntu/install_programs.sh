#!/bin/bash

{
    echo "创建网络: mynet"
    docker network create --driver bridge mynet
} || { echo "error"; }

dir=$PWD/programs

echo "当前目录 ==>: $dir"

# echo "baseDir=/opt/programs" >$PWD/conf.properties
# cat $PWD/conf.properties

# sh $dir/athenapdf.sh
sh $dir/portainer.sh
sh $dir/kiftd.sh
sh $dir/nexus3.sh
sh $dir/grafana.sh
sh $dir/yapi.sh
sh $dir/zookeeper.sh
sh $dir/rabbitmq.sh
sh $dir/emqx.sh
sh $dir/mongo.sh
sh $dir/influxdb.sh
# sh $dir/influxdb2.sh
sh $dir/mariadb.sh
sh $dir/redis.sh
sh $dir/minio.sh
sh $dir/nginx.sh


# sh $dir/jenkins.sh
# sh $dir/gitlab.sh
# sh $dir/elasticsearch.sh

rm -f $PWD/conf.properties

echo "完成...."