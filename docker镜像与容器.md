
# docker镜像与容器




## Dockerfile


    FROM: 指定基础镜像
    RUN： 构建镜像过程中需要执行的命令。可以有多条。
    CMD：添加启动容器时需要执行的命令。多条只有最后一条生效。可以在启动容器时被覆盖和修改。
    ENTRYPOINT：同CMD，但这个一定会被执行，不会被覆盖修改。
    LABEL ：为镜像添加对应的数据。
    MLABELAINTAINER：表明镜像的作者。将被遗弃，被LABEL代替。
    EXPOSE：设置对外暴露的端口。
    ENV：设置执行命令时的环境变量，并且在构建完成后，仍然生效
    ARG：设置只在构建过程中使用的环境变量，构建完成后，将消失
    ADD：将本地文件或目录拷贝到镜像的文件系统中。能解压特定格式文件，能将URL作为要拷贝的文件
    COPY：将本地文件或目录拷贝到镜像的文件系统中。
    VOLUME：添加数据卷
    USER：指定以哪个用户的名义执行RUN, CMD 和ENTRYPOINT等命令
    WORKDIR：设置工作目录
    ONBUILD：如果制作的镜像被另一个Dockerfile使用，将在那里被执行Docekrfile命令
    STOPSIGNAL：设置容器退出时发出的关闭信号。
    HEALTHCHECK：设置容器状态检查。
    SHELL：更改执行shell命令的程序。Linux的默认shell是["/bin/sh", "-c"]，Windows的是["cmd", "/S", "/C"]


## 镜像&容器的导出/导入

    # 导出 ubuntu-jdk 镜像
    docker save -o ./ubuntu-jdk@v1.tar  ubuntu-jdk:v1 && gzip ./ubuntu-jdk@v1.tar
    # 加载 ubuntu-jdk 镜像
    docker load -i ./ubuntu-jdk@v1.tar.gz 

    # 导出容器
    docker export athenapdfservice > athenapdfservice.tar && gzip ./athenapdfservice.tar
    # 导入容器
    docker import - athenapdfservice < athenapdfservice.tar.gz



## 构建镜像

    ### 基础镜像
    FROM ubuntu:22.04
    #作者
    MAINTAINER dingxiuan <dingxiuan@163.com>
    # 版本
    LABEL version=1.0  description=ubuntu-jdk:21
    # 适配部分docker不支持的问题
    RUN apt-get update && apt-get install -y libltdl7
    # ENV TIME_ZONE Asia/Shanghai
    #系统编码
    #ENV LANG=C.UTF-8
    ENV JAVA_HOME=/opt/env/jdk
    ENV JRE_HOME=$JAVA_HOME/jre
    ENV CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
    ENV PATH=$JAVA_HOME/bin:$PATH
    #声明一个挂载点，容器内此路径会对应宿主机的某个文件夹
    VOLUME /opt/env/jdk/
    VOLUME /opt/app/
    RUN mkdir -p /opt/env/jdk/ && chmod 755 /opt/env/jdk/ && mkdir -p /opt/app/ && chmod 755 /opt/app/
    ADD jdk /opt/env/jdk
    ADD docker-entrypoint.sh /
    RUN chmod 755 /docker-entrypoint.sh
    # 工作目录
    WORKDIR /opt/app/
    #启动容器时的进程
    ENTRYPOINT ["/docker-entrypoint.sh"]
    #HEALTHCHECK --interval=30s --timeout=30s CMD curl -f http://localhost:80/actuator/health || exit 1
    #暴露80端口
    #EXPOSE 80/tcp
    #EXPOSE 80/udp
    #--build-arg=[] :设置镜像创建时的变量；
    #-f :指定要使用的Dockerfile路径；
    #--force-rm :设置镜像过程中删除中间容器；
    #--rm :设置镜像成功后删除中间容器；
    #--tag, -t: 镜像的名字及标签，通常 name:tag 或者 name 格式；
    # 拷贝Dockerfile和start.sh文件到centos，然后执行如下命令
    # docker build -f Dockerfile --rm  --tag ubuntu-jdk:21 .


执行Dockerfile的参数
--build-arg=[] :设置镜像创建时的变量；
-f :指定要使用的Dockerfile路径；
--force-rm :设置镜像过程中删除中间容器；
--rm :设置镜像成功后删除中间容器；
--tag, -t: 镜像的名字及标签，通常 name:tag 或者 name 格式；


## docker-entrypoint.sh文件

    #!/bin/bash
    # 此命令在linux上时，建议通过 vim /yourdir/docker-entrypoint.sh编辑，拷贝，否则运行时可能会报错
    export LANG=C.UTF-8
    echo "Asia/shanghai" >/etc/timezone
    #source /etc/profile

    # #echo "work dir: $PWD"
    # JAVA_HOME=/opt/env/jdks/11
    # PATH=$JAVA_HOME/bin:$PATH
    # CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

    cd /opt/app
    # 倒序后，取第一个jar包
    jar=$(ls -a | grep "\.jar$" | sort  -nr | head -n 1)
    jarName=$(echo "$jar" | cut -f 1 -d '.')
    # 取得一个 application. 开头的文件
    config=$(ls -a | grep application. | sort -rn | head -n 1)

    mkdir -p logs && chmod 755 logs

    {
    # 最大200MB
    MAX_SIZE=$((200 * (1024 << 10)))
    logFile=./logs/$jarName.log
    fileSize=$(wc -c <$logFile)
    # 判断文件是否达到200MB，如果达到，就压缩，并用空文件覆盖已有文件
    if [ $fileSize -gt $MAX_SIZE ]; then
        today=$(date +%Y%m%d)
        echo "压缩日志文件: "
        tar -zcvf ./logs/$jarName__$today.tar.gz $logFile
        echo "" >$logFile
    fi
    }

    exec java -jar $jar \
    -Duser.timezone=GMT+08 \
    -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=*:1500 \
    --spring.config.location=$config \
    >>./logs/$jarName.log


授权：chmod 777 docker-entrypoint.sh


## 创建容器

创建生成PDF的服务

    docker run -d --restart=always \
     --privileged=true \
     --network mynet --network-alias athenapdfservice-net \
     -p 8001:80 \
     -v /etc/localtime:/etc/localtime \
     -v /etc/timezone:/etc/timezone \
     -v /usr/bin/docker:/usr/bin/docker \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v /opt/apps/data:/opt/app/data/  \
     -v /opt/apps/athenapdfservice:/opt/app/  \
     --name athenapdfservice \
     ubuntu-jdk:21


## Windows


关于在windows上的docker启动失败的原因：

1. sh脚本是dos类型的，需要改为unix   https://www.cnblogs.com/cf532088799/p/7719935.html
: set ff=unix



~