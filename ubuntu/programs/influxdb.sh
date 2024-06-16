#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 influxdb"
influxdbDir=$baseDir/influxdb
echo "安装目录：$influxdbDir"
docker run --privileged -d --restart=always \
	--network mynet --network-alias influxdb-net \
	-p 8086:8086 \
	-v $influxdbDir:/var/lib/influxdb \
	--name influxdb \
	influxdb:1.8.10