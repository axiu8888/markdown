#!/bin/bash

baseDir=/opt/programs
# source $PWD/conf.properties

echo ""
echo "-----------------------------------"
echo "安装 rabbitmq"
rabbitmqDir=$baseDir/rabbitmq
echo "安装目录：$rabbitmqDir"
docker run --privileged -d --restart=always \
    --network mynet --network-alias rabbitmq-net \
    -p 5672:5672 \
    -p 15672:15672 \
    -v $rabbitmqDir/var/:/var/lib/rabbitmq \
    -v $rabbitmqDir/etc/:/etc/rabbitmq/ \
    -e RABBITMQ_DEFAULT_USER=admin \
    -e RABBITMQ_DEFAULT_PASS=admin123 \
    -e RABBITMQ_DEFAULT_VHOST=test \
    --name rabbitmq \
    rabbitmq:3.11-management
# docker run --privileged -d \
# 	--network mynet --network-alias rabbitmq-net \
# 	-p 5671:5671 \
# 	-p 5672:5672 \
# 	-p 15672:15672 \
# 	-p 15671:15671 \
# 	-p 25672:25672 \
# 	-v $rabbitmqDir/var/:/var/lib/rabbitmq \
# 	-v $rabbitmqDir/etc/:/etc/rabbitmq/ \
# 	-e RABBITMQ_DEFAULT_USER=admin \
# 	-e RABBITMQ_DEFAULT_PASS=admin123 \
# 	-e RABBITMQ_DEFAULT_VHOST=test \
# 	--name rabbitmq \
# 	rabbitmq:3.11-management

echo "进入rabbitmq容器，启动管理界面，运动 rabbitmq_ui.sh"
touch rabbitmq_ui.sh
echo -e "#!/bin/bash
rabbitmq-plugins enable rabbitmq_management
echo \"执行结束，退出！\"
exit
" >$PWD/rabbitmq_ui.sh
docker cp $PWD/rabbitmq_ui.sh rabbitmq:/opt/rabbitmq_ui.sh
docker exec rabbitmq sh /opt/rabbitmq_ui.sh
rm -f $PWD/rabbitmq_ui.sh

