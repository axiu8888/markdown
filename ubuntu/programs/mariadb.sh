#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 mariadb"
mariadbDir=$baseDir/mariadb/
echo "安装目录：$mariadbDir"
mkdir -p $mariadbDir/etc
touch $mariadbDir/etc/my.cnf
echo "
[mysqld]
log-bin=mysql-bin
server-id=1
log-bin=/var/lib/mysql/mysql-bin
" >>$mariadbDir/etc/my.cnf
docker run --privileged -d --restart=always \
    --network mynet --network-alias mariadb-net \
    -e TIMEZONE=Asis/Shanghai \
    -e MYSQL_ROOT_PASSWORD=admin \
    -e SERVER_ID=1 \
    -v $mariadbDir/etc/my.cnf:/etc/mysql/my.cnf \
    -v $mariadbDir/data:/var/lib/mysql \
    -v $mariadbDir/logs:/var/log/mysql \
    -p 3306:3306 \
    --name mariadb \
    mariadb:10.10
