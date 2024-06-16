#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 influxdb2"
influxdbDir=$baseDir/influxdb2
echo "安装目录：$influxdbDir"
docker run --privileged -d --restart=always \
	--network mynet --network-alias influxdb2-net \
	-p 28086:8086 \
	-v $influxdbDir/data:/var/lib/influxdb2 \
	-v $influxdbDir/config:/etc/influxdb2 \
	-e DOCKER_INFLUXDB_INIT_MODE=setup \
	-e DOCKER_INFLUXDB_INIT_USERNAME=admin \
	-e DOCKER_INFLUXDB_INIT_PASSWORD=admin123 \
	-e DOCKER_INFLUXDB_INIT_ORG=root \
	-e DOCKER_INFLUXDB_INIT_BUCKET=bucket0 \
	-e DOCKER_INFLUXDB_INIT_RETENTION=autogen \
	-e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=token123456 \
	--name influxdb2 \
	influxdb:2.7

## 设置用户名和密码
# docker exec influxdb2 influx setup \
# 	--username admin \
# 	--password admin123 \
# 	--org root \
# 	--bucket bucket0 \
# 	--force
