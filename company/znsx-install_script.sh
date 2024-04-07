#!/bin/bash

echo -e "@_start_@ -----------------------↓↓------------------------ @_start_@"

echo "创建网络"
{
  docker network create --driver bridge znsxnet
}

# [ -f /opt/env/jdks/8/bin/java ] && echo "jdks已存在" || cp -r ./env /opt/

# 创建日志目录
mkdir -p /home/znsx/log

echo -e "\n-----------------------------------"
echo "启动 portainer"
docker run --privileged -d --restart=always \
  -p 9002:9000 \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name portainer \
  portainer/portainer

echo -e "\n-----------------------------------"
echo "启动 grafana"
chmod 777 /home/znsx/data/grafana
docker run --privileged -d --restart=always \
  --network znsxnet --network-alias hsrg-grafana \
  -p 3000:3000 \
  -v /home/znsx/data/grafana:/var/lib/grafana \
  --name znsx-grafana \
  grafana/grafana

echo -e "\n-----------------------------------"
echo "启动 minio"
docker run -d --restart=always \
  --network znsxnet --network-alias hsrg-minio \
  -p 9006:9006 \
  -p 9007:9007 \
  -e MINIO_ACCESS_KEY=admin \
  -e MINIO_SECRET_KEY=hsrg8888 \
  -v /etc/localtime:/etc/localtime \
  -v /home/znsx/data/minio/config:/root/.minio \
  -v /home/znsx/data/minio/data1:/data1 \
  -v /home/znsx/data/minio/data2:/data2 \
  --name znsx-minio \
  minio/minio server http://hsrg-minio/data{1...2} \
  --console-address ":9007"

echo -e "\n-----------------------------------"
echo '启动 znsx-influx'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-influx \
  -p 58086:8086 \
  -v /etc/localtime:/etc/localtime \
  -v /home/znsx/data/influx:/var/lib/influxdb \
  --name znsx-influx \
  influxdb:1.8.10

echo -e "\n-----------------------------------"
echo '启动 znsx-mongo'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-mongo \
  -p 57017:27017 \
  -v /etc/localtime:/etc/localtime \
  -v /home/znsx/data/mongodb:/data/db \
  --name znsx-mongo \
  mongo

echo -e "\n-----------------------------------"
echo '启动 znsx-redis'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-redis \
  -p 56379:6379 \
  -v /etc/localtime:/etc/localtime \
  -v /home/znsx/data/redis:/data \
  --name znsx-redis \
  redis

echo -e "\n-----------------------------------"
echo '启动 znsx-mariadb'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-mysql \
  -p 53306:3306 \
  -v /etc/localtime:/etc/localtime \
  -v /home/znsx/data/mariadb/:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=hsrg8888 \
  --name znsx-mariadb \
  mariadb:latest --character-set-server=utf8 --collation-server=utf8_general_ci

echo -e "\n-----------------------------------"
echo '启动 znsx-psql'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-psql \
  -v /etc/localtime:/etc/localtime \
  -p 55432:5432/tcp \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=hsrg8888 \
  -v /home/znsx/data/postgresql/:/var/lib/postgresql/data \
  --name znsx-psql \
  postgres

echo -e "\n-----------------------------------"
echo '启动 znsx-emqx'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-emqx \
  -p 1883:1883 \
  -p 8083:8083 \
  -p 18083:18083 \
  -v /etc/localtime:/etc/localtime \
  -v /home/znsx/data/emqx/etc:/opt/emqx/etc \
  -v /home/znsx/data/emqx/log:/opt/emqx/log \
  --name znsx-emqx \
  emqx

echo -e "\n------------------ ↓ znsx containers ↓ -----------------\n"

echo -e "\n-----------------------------------"
echo '启动 algorithm'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-midas \
  -p 5000:5000 \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/znsx/program/algorithm/midas/:/usr/local/lib/python3.6/site-packages/midas/ \
  -v /home/znsx/data/reportPath/:/home/znsx/data/reportPath/ \
  -v /home/fileData/report/img/:/home/fileData/report/img/ \
  -v /home/znsx/program/algorithm/pyc.sh:/usr/local/bin/pyc.sh \
  -v /home/znsx/log/:/home/znsx/log/ \
  --name python3.6 \
  python3.6:v2 /bin/bash -c "pyc.sh"

echo -e "\n-----------------------------------"
echo '启动 znsx-nginx'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-nginx \
  -p 80:80 \
  -p 443:443 \
  -v /etc/localtime:/etc/localtime \
  -v /home/znsx/program/web-front/:/usr/share/nginx/ \
  -v /home/fileData/report/img/:/usr/share/nginx/www/image/ \
  -v /home/fileData/autograph/:/usr/share/nginx/www/autograph/ \
  -v /home/fileData/headerImage/:/usr/share/nginx/www/headerImage/ \
  -v /home/fileData/otherImage/:/usr/share/nginx/www/otherImage/ \
  -v /home/fileData/headerImage/:/usr/share/nginx/admin/headerImage/ \
  -v /home/fileData/autograph/:/usr/share/nginx/admin/autograph/ \
  -v /home/fileData/otherImage/:/usr/share/nginx/admin/otherImage/ \
  -v /home/fileData/report/img/:/usr/share/nginx/admin/image/ \
  -v /home/znsx/program/web-front/conf/:/etc/nginx/conf.d/ \
  -v /home/znsx/log/:/var/log/nginx \
  --name znsx-nginx \
  nginx

echo -e "\n-----------------------------------"
echo '启动 znsx-mmhg'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-mmhg \
  -p 10023:10023/tcp \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/znsx/program/mmhg/start.sh:/docker-entrypoint.sh \
  -v /home/znsx/program/mmhg/:/opt/app/ \
  -v /home/znsx/:/home/znsx/ \
  -e LANG="C.utf8" \
  --name znsx-mmhg \
  mono-jdk:v1

echo -e "\n-----------------------------------"
echo '启动 znsx-biz'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-biz \
  -p 58000:1500/tcp \
  -p 62024:62024/tcp \
  -p 62025:62025/tcp \
  -p 52014:52014/udp \
  -p 62014:62014/udp \
  -p 15035:15035/udp \
  -v /etc/localtime:/etc/localtime \
  -v /home/znsx/program/biz/start.sh:/docker-entrypoint.sh \
  -v /home/znsx/program/biz/:/opt/app/ \
  -v /home/znsx/:/home/znsx/ \
  -e LANG="C.utf8" \
  --name znsx-biz \
  hsrg-jdk:11

echo -e "\n-----------------------------------"
echo '启动 znsx-db'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-db \
  -p 58001:1500/tcp \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/znsx/program/db/start.sh:/docker-entrypoint.sh \
  -v /home/znsx/program/db/:/opt/app/ \
  -v /home/znsx/:/home/znsx/ \
  -e LANG="C.utf8" \
  --name znsx-db \
  hsrg-jdk:11

echo -e "\n-----------------------------------"
echo '启动 znsx-task'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-task \
  -p 58002:1500/tcp \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/znsx/program/task/start.sh:/docker-entrypoint.sh \
  -v /home/znsx/program/task/:/opt/app/ \
  -v /home/znsx/:/home/znsx/ \
  -e LANG="C.utf8" \
  --name znsx-task \
  hsrg-jdk:11

echo -e "\n-----------------------------------"
echo '启动 znsx-web'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-web \
  -p 58003:1500/tcp \
  -p 8081:8081/tcp \
  -p 62015:62015/tcp \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/znsx/program/web/start.sh:/docker-entrypoint.sh \
  -v /home/znsx/program/web/:/opt/app/ \
  -v /home/:/home/ \
  -e LANG="C.utf8" \
  --name znsx-web \
  hsrg-jdk:11

echo -e "\n-----------------------------------"
echo '启动 znsx-bt-gateway'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-bt-gateway \
  -p 62080:80/tcp \
  -p 62020:62020/udp \
  -p 62021:62021/tcp \
  -p 28009:1500/tcp \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/znsx/program/bt-gateway/start.sh:/docker-entrypoint.sh \
  -v /home/znsx/program/bt-gateway:/opt/app/ \
  --name znsx-bt-gateway \
  hsrg-jdk:11

echo -e "\n-----------------------------------"
echo '启动 znsx-arrhythmia'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias hsrg-arrhythmia \
  -p 480:80/tcp \
  -p 28008:1500/tcp \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/znsx/program/arrhythmia-algo/start.sh:/docker-entrypoint.sh \
  -v /home/znsx/program/arrhythmia-algo:/opt/app/ \
  -e LANG="C.utf8" \
  --name znsx-arrhythmia \
  hsrg-jdk:11

# echo -e "\n-----------------------------------"
# echo '启动 znsx-collector-mqtt-proxy'
# docker run -d -it --privileged=true --restart=always \
#   --network znsxnet --network-alias hsrg-collector-mqtt-proxy \
#   -v /etc/localtime:/etc/localtime \
#   -v /usr/bin/docker:/usr/bin/docker \
#   -v /home/znsx/program/collector-mqtt-proxy/start.sh:/docker-entrypoint.sh \
#   -v /home/znsx/program/collector-mqtt-proxy:/opt/app/ \
#   --name znsx-collector-mqtt-proxy \
#   hsrg-jdk:11

# echo -e "\n-----------------------------------"
# echo '启动 znsx-acserver'
# docker run -d -it --privileged=true --restart=always \
#   --network znsxnet --network-alias hsrg-acserver \
#   -p 8888:8888 \
#   -p 10604:10604/udp \
#   -p 10352:10352/udp \
#   -v /etc/localtime:/etc/localtime \
#   -v /home/znsx/program/acserver/docker-entrypoint.sh:/docker-entrypoint.sh \
#   -v /home/znsx/program/acserver/:/opt/app/ \
#   --name znsx-acserver \
#   hsrg-jdk:11

echo -e "\n------------------ ↑ znsx containers ↑ -----------------\n"

echo -e "\n------------------ ↓ support containers ↓ -----------------\n"

echo -e "\n-----------------------------------"
echo '启动 support-emqx'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias support-emqx \
  -p 2883:1883/tcp \
  -p 28083:8083/tcp \
  -p 38083:18083/tcp \
  -v /etc/localtime:/etc/localtime \
  -v /home/znsx/data/support_emqx/etc:/opt/emqx/etc \
  -v /home/znsx/data/support_emqx/log:/opt/emqx/log \
  --name support-emqx \
  emqx

echo -e "\n-----------------------------------"
echo '启动 support-biz'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias support-biz \
  -p 28000:1500/tcp \
  -p 7012:52014/udp \
  -p 7014:62014/udp \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/znsx/program/supportBiz/start.sh:/docker-entrypoint.sh \
  -v /home/znsx/program/supportBiz/:/opt/app/ \
  -v /home/znsx/:/home/znsx/ \
  -e LANG="C.utf8" \
  --name support-biz \
  hsrg-jdk:11

echo -e "\n-----------------------------------"
echo '启动 support-db'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias support-db \
  -p 28001:1500 \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/znsx/program/supportDb/start.sh:/docker-entrypoint.sh \
  -v /home/znsx/program/supportDb/:/opt/app/ \
  -v /home/znsx/:/home/znsx/ \
  -e LANG="C.utf8" \
  --name support-db \
  hsrg-jdk:11

echo -e "\n-----------------------------------"
echo '启动 support-web'
docker run -d -it --privileged=true --restart=always \
  --network znsxnet --network-alias support-web \
  -p 7777:7777/tcp \
  -p 28003:1500/tcp \
  -v /etc/localtime:/etc/localtime \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/znsx/program/supportWeb/start.sh:/docker-entrypoint.sh \
  -v /home/znsx/program/supportWeb:/opt/app/ \
  -v /home/:/home/ \
  -e LANG="C.utf8" \
  --name support-web \
  hsrg-jdk:11

echo -e "\n------------------ ↑ support containers ↑ -----------------\n"

echo -e "@_end_@ -----------------------↑↑------------------------ @_end_@"
