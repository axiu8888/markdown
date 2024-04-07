echo "创建网络"
{
    docker network create --driver bridge znsxnet
}

echo "加载docker镜像"
cd ./images
ls -l *.tar | awk '{print $NF}' | sed -r 's#(.*)#docker load -i \1#' | bash
ls -l *.tar.gz | awk '{print $NF}' | sed -r 's#(.*)#gunzip -c \1 |docker load -i \1#' | bash
cd ..
cp -r ./program /home/znsx/
cp -r ./data /home/znsx/
sh $dir/portainer.sh

echo -e "\n------------ 构建容器@start ------------"
docker-compose up -d
#docker-compose up
echo -e "\n------------ 构建容器@end ------------\n"

echo "end~~~~"
