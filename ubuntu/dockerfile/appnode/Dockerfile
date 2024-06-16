### 基础镜像
FROM centos:7
#作者
MAINTAINER dingxiuan <dingxiuan@163.com>
# 版本
LABEL version=1.0  description=centos:7
#系统编码
ENV LANG=C.UTF-8
#声明一个挂载点，容器内此路径会对应宿主机的某个文件夹
VOLUME /opt/app/
RUN mkdir -p /opt/app/ && chmod 755 /opt/app/ 
RUN mkdir -p /opt/env/ && chmod 755 /opt/env/ 
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
# docker build -f Dockerfile --rm  --tag appnode:v1 .