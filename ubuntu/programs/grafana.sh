#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 grafana"
grafanaDir=$baseDir/grafana
echo "安装目录：$grafanaDir"
mkdir -p $grafanaDir
chmod 777 $grafanaDir
docker run --privileged -d --restart=always \
    --network mynet --network-alias grafana-net \
    -p 3000:3000 \
    -v $grafanaDir:/var/lib/grafana \
    --name grafana \
    grafana/grafana
