#!/bin/bash

dir=$PWD

cd docker || exit

echo "安装libc相关依赖"
v=$(cat /etc/redhat-release | sed -r 's/.* ([0-9]+)\..*/\1/')
# if [ $v == 7 ]; then
#     rpm -ivh  ./soft/docker7/policycoreutils-python-2.5-33.el7.x86_64.rpm --nodeps
#     rpm -ivh  ./soft/docker7/audit-libs-python-2.8.5-4.el7.x86_64.rpm --nodeps
#     rpm -ivh  ./soft/docker7/checkpolicy-2.5-8.el7.x86_64.rpm --nodeps
#     rpm -ivh  ./soft/docker7/setools-libs-3.3.8-4.el7.x86_64.rpm --nodeps
#     rpm -ivh  ./soft/docker7/libcgroup-0.41-21.el7.x86_64.rpm --nodeps
#     rpm -ivh  ./soft/docker7/libsemanage-python-2.5-14.el7.x86_64.rpm --nodeps
#     rpm -ivh  ./soft/docker7/libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm --nodeps
#     rpm -ivh  ./soft/docker7/pigz-2.3.4-1.el7.x86_64.rpm --nodeps
#     rpm -ivh  ./soft/docker7/python-IPy-0.75-6.el7.noarch.rpm --nodeps
#     rpm -ivh  ./soft/docker7/container-selinux-2.107-3.el7.noarch.rpm --nodeps
#     rpm -ivh  ./soft/docker7/libseccomp-2.5.1-1.el8.x86_64.rpm --nodeps
# elif [ $v == 8 ]; then
#     rpm -ivh  ./soft/docker8/libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm --nodeps
#     rpm -ivh  ./soft/docker8/libcgroup-0.41-21.el7.x86_64.rpm --nodeps
#     rpm -ivh  ./soft/docker8/libseccomp-2.5.1-1.el8.x86_64.rpm --nodeps
# fi

echo "开始安装docker"
tar -zxvf docker-23.0.0.tar
cp docker/* /usr/bin/
cp ./docker.service /etc/systemd/system/docker.service
chmod +x /etc/systemd/system/docker.service
systemctl daemon-reload
systemctl start docker
systemctl enable docker.service
cp docker-compose /usr/local/bin/
chmod +x /usr/local/bin/docker-compose
# systemctl status docker
systemctl stop docker
cd ..
mkdir -p /home/znsx
mv /var/lib/docker /home/znsx/docker
ln -s /home/znsx/docker /var/lib/docker
echo "docker 安装完成"
systemctl restart docker.service

echo "加载docker的自动补全"
cd ./completions || exit
sh ./init.sh
cd ../

# echo "创建网络"
# {
#     docker network create --driver bridge znsxnet
# }

echo "加载docker镜像"
cd ./images || exit
ls -l *.tar | awk '{print $NF}' | sed -r 's#(.*)#docker load -i \1#' | bash
ls -l *.tar.gz | awk '{print $NF}' | sed -r 's#(.*)#gunzip -c \1 |docker load -i \1#' | bash
cd ..
cp -r ./program /home/znsx/
cp -r ./data /home/znsx/
sh "$dir"/portainer.sh

echo -e "\n------------ 构建容器@start ------------"
#docker-compose up -d
#docker-compose up
cd "$dir"/ && sh ./znsx-install_script.sh
echo -e "\n------------ 构建容器@end ------------\n"

echo "end~~~~"
