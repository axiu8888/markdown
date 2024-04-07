# 停止并删除 dokcer
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi $(docker images -aq)
systemctl stop docker
rm -drf /home/docker
rm -drf /var/lib/docker

# 删除相关依赖
sudo yum -y remove docker-ce.x86_64
sudo yum -y remove libcgroup.x86_64
# rm -drf /home/fileData
# rm -drf /home/reportPath
# rm -drf /home/znsx


# yum remove -y audit-libs-python.x86_64
# yum remove -y checkpolicy.x86_64
# yum remove -y container-selinux.noarch
# yum remove -y libcgroup.x86_64
# yum remove -y libsemanage-python.x86_64
# yum remove -y libtool-ltdl.x86_64 
# yum remove -y pigz.x86_64
# yum remove -y python-IPy.noarch
# yum remove -y setools-libs.x86_64
