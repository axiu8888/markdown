# docker 配置

创建虚拟网络

```
docker network create --driver bridge mynet
```

#查看docker容器的网络

```
iptables -t nat -vnL
```

### MongoDB：

```
拉取镜像：docker pull mongo
运行容器：

docker run --privileged -d --restart=always \
 --network mynet --network-alias mongo-net \
 -e MONGO_INITDB_ROOT_USERNAME=root \
 -e MONGO_INITDB_ROOT_PASSWORD=admin \
 -p 27017:27017 \
 -v /opt/programs/mongo/db/:/data/db/ \
 -v /opt/programs/mongo/log/:/data/log/ \
 --name mongo \
 mongo
```

### mongo-express：

```
拉取镜像：docker pull mongo:0.54
运行容器：

docker run -d \
 --privileged --restart=always \
 --network mynet --network-alias mongo-express-net \
 -p 27018:8081 \
 -e ME_CONFIG_MONGODB_SERVER="mongo-net" \
 -e ME_CONFIG_MONGODB_PORT=27017 \
 -e ME_CONFIG_OPTIONS_EDITORTHEME="default" \
 -e ME_CONFIG_MONGODB_ENABLE_ADMIN="true" \
 -e ME_CONFIG_MONGODB_ADMINUSERNAME="root" \
 -e ME_CONFIG_MONGODB_ADMINPASSWORD="admin" \
 -e ME_CONFIG_BASICAUTH_USERNAME="root" \
 -e ME_CONFIG_BASICAUTH_PASSWORD="admin" \
 --name mongo-express \
 mongo-express
```

镜像地址：https://hub.docker.com/_/mongo-express

| Name                            | Default         | Description                                                                                                              |
| ------------------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------ |
| ME_CONFIG_BASICAUTH_USERNAME    | ''              | mongo-express web username                                                                                               |
| ME_CONFIG_BASICAUTH_PASSWORD    | ''              | mongo-express web password                                                                                               |
| ME_CONFIG_MONGODB_ENABLE_ADMIN  | 'true'          | Enable admin access to all databases. Send strings:`"true"` or `"false"`                                             |
| ME_CONFIG_MONGODB_ADMINUSERNAME | ''              | MongoDB admin username                                                                                                   |
| ME_CONFIG_MONGODB_ADMINPASSWORD | ''              | MongoDB admin password                                                                                                   |
| ME_CONFIG_MONGODB_PORT          | 27017           | MongoDB port                                                                                                             |
| ME_CONFIG_MONGODB_SERVER        | 'mongo'         | MongoDB container name. Use comma delimited list of host names for replica sets.                                         |
| ME_CONFIG_OPTIONS_EDITORTHEME   | 'default'       | mongo-express editor color theme,[more here](http://codemirror.net/demo/theme.html)                                         |
| ME_CONFIG_REQUEST_SIZE          | '100kb'         | Maximum payload size. CRUD operations above this size will fail in[body-parser](https://www.npmjs.com/package/body-parser). |
| ME_CONFIG_SITE_BASEURL          | '/'             | Set the baseUrl to ease mounting at a subdirectory. Remember to include a leading and trailing slash.                    |
| ME_CONFIG_SITE_COOKIESECRET     | 'cookiesecret'  | String used by[cookie-parser middleware](https://www.npmjs.com/package/cookie-parser) to sign cookies.                      |
| ME_CONFIG_SITE_SESSIONSECRET    | 'sessionsecret' | String used to sign the session ID cookie by[express-session middleware](https://www.npmjs.com/package/express-session).    |
| ME_CONFIG_SITE_SSL_ENABLED      | 'false'         | Enable SSL.                                                                                                              |
| ME_CONFIG_SITE_SSL_CRT_PATH     | ''              | SSL certificate file.                                                                                                    |
| ME_CONFIG_SITE_SSL_KEY_PATH     | ''              | SSL key file.                                                                                                            |

### nexus3

```
docker run --privileged -d --restart=always \
 --network mynet --network-alias nexus3-net \
 -p 9001:8081 \
 -v /opt/programs/nexus3/data:/nexus-data \
 -v /opt/programs/nexus3/sonatype-work:/opt/sonatype/sonatype-work/nexus3 \
 --name nexus3 \
 sonatype/nexus3
```

初次启动可能权限不足，需要修改 /opt/programs/nexus3/  目录的权限:
chmod 777 /opt/programs/nexus3 && chmod 777 /opt/programs/nexus3/data
如果使用 账号admin，密码admin123 登陆不进去，需要修改nexus的账号和密码(进入docker后，到 /opt/sonatype/sonatype-work/nexus3 目录修改admin.password文件, 或者是 /nexus-data/admin.password)，或通过后台日志查看密码后拷贝登陆；

### RabbitMQ：

```
拉取镜像：docker pull rabbitmq:3.9-management
运行容器：

docker run --privileged -d --restart=always \
 --network mynet --network-alias rabbitmq-net \
 -p 5671:5671 \
 -p 5672:5672 \
 -p 15672:15672 \
 -p 15671:15671 \
 -p 25672:25672 \
 -v /opt/programs/rabbitmq/var/:/var/lib/rabbitmq \
 -v /opt/programs/rabbitmq/etc/:/etc/rabbitmq/ \
 --name rabbitmq  \
 rabbitmq:3.9-management
```

### Jenkins:

```
拉取镜像：docker pull jenkins
运行容器：

# 创建jenkins目录
cd /opt/programs/ && mkdir -p ./jenkins && chmod 777 ./jenkins && cd ./jenkins

docker run --privileged -d --restart=always \
 --network mynet --network-alias jenkins-net \
 -p 9095:8080 \
 -p 9096:50000 \
 -v /etc/localtime:/etc/localtime \
 -v /var/run/docker.sock:/var/run/docker.sock  \
 -v /usr/bin/docker:/usr/bin/docker  \
 -v /opt/programs/jenkins:/var/jenkins_home \
 -uroot \
 --name jenkins \
 jenkins/jenkins
```

jenkins 在/opt/programs/jenkins目录下，通过软连接到其他目录
比如 /opt/apps/system目录需要部署一个系统

### Redis：

```
拉取镜像：docker pull redis
运行容器：

docker run --privileged -d --restart=always \
 --network mynet --network-alias redis-net \
 -p 6379:6379 \
 -v /opt/programs/redis/redis.conf:/et/redis.conf  \
 -v /opt/programs/redis/data:/var/lib/data  \
 --name redis  \
 redis --appendonly yes --requirepass "123456"
```

### Zookeeper安装

配置：

```
mkdir -p /opt/programs/zookeeper/zk
cd /opt/programs/zookeeper/zk \
    && mkdir -p ./data  \
    && mkdir -p ./conf \
    && mkdir -p ./logs  \
    && chmod 755 ./*
```

vim /opt/programs/zookeeper/zk/conf/zoo.cfg

```
tickTime=2000
initLimit=5
syncLimit=2
dataDir=/data
dataLogDir=/datalog
clientPort=2181
maxClientCnxns=60
server.1=0.0.0.0:2888:3888
#server.2=192.168.0.112:2888:3888
#server.3=192.168.0.113:2888:3888
```

vim /opt/programs/zookeeper/zk/data/myid

输入：1

#如果开启了防火墙，需要执行：

firewall-cmd --zone=public --add-port=2181/tcp --permanent
firewall-cmd --zone=public --add-port=2888/tcp --permanent
firewall-cmd --zone=public --add-port=3888/tcp --permanent
firewall-cmd --reload

```
拉取镜像：docker pull zookeeper 
运行容器：

docker run -d --restart always \
 --privileged=true \
 --network mynet --network-alias zookeeper-net \
 -p 2181:2181 \
 -p 2888:2888 \
 -p 3888:3888 \
 -v /etc/localtime:/etc/localtime   \
 -v /opt/programs/zookeeper/zk/conf/zoo.cfg:/var/lib/zookeeper/conf/zoo.cfg \
 -v /opt/programs/zookeeper/zk/data:/var/lib/zookeeper/data  \
 -v /opt/programs/zookeeper/zk/logs:/var/lib/zookeeper/datalog  \
 --name zookeeper \
 zookeeper
```

查看状态：docker exec -it zookeeper zkServer.sh status

或者
yum -y install nc
echo stat|nc 127.0.0.1 2181

其他博客参考：https://www.cnblogs.com/kingkoo/p/8732448.html

### Mariadb

```
拉取镜像：docker pull mariadb
运行容器：

docker run  --privileged -d --restart=always \
 --network mynet --network-alias mariadb-net \
 -e TIMEZONE=Asis/Shanghai \
 -e MYSQL_ROOT_PASSWORD=admin \
 -e SERVER_ID=1 \
 -v /opt/programs/mariadb/etc/my.cnf:/etc/mysql/my.cnf  \
 -v /opt/programs/mariadb/data:/var/lib/mysql  \
 -v /opt/programs/mariadb/logs:/var/log/mysql  \
 -p 3306:3306  \
 --name mariadb \
 mariadb
```

my.cnf  配置

```
[mysqld]
log-bin=mysql-bin
server-id=1
log-bin=/var/lib/mysql/mysql-bin
```

集群：

```
docker run  --privileged -d --restart=always \
 --network mynet --network-alias mariadb_cluster-net \
 -e TIMEZONE=Asis/Shanghai \
 -e MYSQL_ROOT_PASSWORD=admin \
 -e SERVER_ID=2 \
 -v /opt/programs/mariadb_cluster/etc/my.cnf:/etc/mysql/my.cnf  \
 -v /opt/programs/mariadb_cluster/data:/var/lib/mysql  \
 -v /opt/programs/mariadb_cluster/logs:/logs  \
 -p 3307:3306  \
 --name mariadb_cluster \
 --character-set-server=utf8mb4 \ --collation-server=utf8mb4_unicode_ci \ 
 mariadb 
```

my.cnf  配置

```
[mysqld]
server-id=2
relay-log=/var/lib/mysql/relay-bin
relay-log-index=/var/lib/mysql/relay-bin.index
```

### 特别的 grafana和influxdb

```
拉取镜像：docker pull philhawthorne/docker-influxdb-grafana
运行容器：

docker run -d --name docker-influxdb-grafana \
 --network mynet --network-alias docker-influxdb-grafana-net \
 -p 23003:3003 \
 -p 23004:8083 \
 -p 28086:8086 \
 -v /etc/localtime:/etc/localtime   \
 -v /etc/timezone:/etc/timezone   \
 -v /usr/bin/docker:/usr/bin/docker \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v /opt/programs/influxdb:/var/lib/influxdb \
 -v /opt/programs/grafana:/var/lib/grafana \
philhawthorne/docker-influxdb-grafana:latest
```

### grafana

```
拉取镜像：docker pull grafana/grafana
运行容器：

docker run --privileged -d --restart=always \
 --network mynet --network-alias grafana-net \
 -p 3000:3000 \
 -v /opt/programs/grafana:/var/lib/grafana \
 --name grafana \
 grafana/grafana

授权：chmod 777 /opt/programs/grafana
初始化账号和密码：admin / admin123
```

### influxDB

```
拉取镜像：docker pull influxdb
运行容器：

docker run --privileged -d --restart=always \
 --network mynet --network-alias influxdb-net \
 -p 8086:8086 \
 -v /opt/programs/influxdb/data:/var/lib/influxdb2 \
 -v /opt/programs/influxdb/config:/etc/influxdb2 \
 -e DOCKER_INFLUXDB_INIT_MODE=setup \
 -e DOCKER_INFLUXDB_INIT_USERNAMEadmin \
 -e DOCKER_INFLUXDB_INIT_PASSWORD=123456 \
 --name influxdb \
 influxdb


-e DOCKER_INFLUXDB_INIT_ORG=my-org \
-e DOCKER_INFLUXDB_INIT_BUCKET=my-bucket \
-e DOCKER_INFLUXDB_INIT_RETENTION=1w \
-e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=my-super-secret-auth-token \

```

#### 1.8 版本

```
docker run --privileged -d --restart=always \
 --network mynet --network-alias influxdb-net \
 -p 8086:8086 \
 -v /opt/programs/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf \
 -v /opt/programs/influxdb:/var/lib/influxdb \
 --name influxdb \
 influxdb:1.8
```



influxdb 1.8 创建用户和密码, 进入容器

> docker exec -it influxdb /bin/bash
> influx
> create user "admin" with password '123456' with all privileges

### nexus3

```
拉取镜像：docker pull sonatype/nexus3
运行容器：

docker run --privileged -d --restart=always \
 --network mynet --network-alias nexus3-net \
 -p 9001:8081 \
 -v /opt/programs/nexus3/data:/nexus-data \
 -v /opt/programs/nexus3sonatype-work:/opt/sonatype/sonatype-work/nexus3
 --name nexus3 \
 sonatype/nexus3:3.38.1
```

初次启动可能权限不足，需要修改 /opt/programs/nexus3/  目录的权限:
chmod 777 /opt/programs/nexus3 && chmod 777 /opt/programs/nexus3/data
如果使用 账号admin，密码admin123 登陆不进取，需要修改nexus的账号和密码(进入docker后，到 /opt/sonatype/sonatype-work/nexus3 目录修改admin.password文件, 或者是 /nexus-data/admin.password)，或通过后台日志查看密码后拷贝登陆；

### nginx

```
拉取镜像：docker pull nginx
运行容器：

docker run --privileged -d --restart=always \
 --network mynet --network-alias nginx-net \
 -p 80:80 \
 -p 443:443 \
 -v /opt/programs/nginx/nginx.conf:/etc/nginx/nginx.conf  \
 -v /opt/programs/nginx/share/:/usr/share/nginx/ \
 -v /opt/programs/nginx/conf.d/:/etc/nginx/conf.d/ \
 -v /opt/programs/nginx/var:/var/lib/nginx \
 -v /opt/programs/nginx/log:/var/log/nginx \
 --name nginx \
 nginx
```

### gitlab

```
拉取镜像：docker pull gitlab/gitlab-ce
运行容器：

docker run --restart always --privileged=true \
 --network mynet --network-alias gitlab-net \
 -itd  \
 -p 8823:80 \
 -v /opt/programs/gitlab/etc:/etc/gitlab  \
 -v /opt/programs/gitlab/log:/var/log/gitlab \
 -v /opt/programs/gitlab/var:/var/opt/gitlab \
--name gitlab \
gitlab/gitlab-ce
```

配置：

vim  /opt/programs/gitlab/etc/gitlab.rb

```
#添加如下配置
external_url 'http://gitlab-net:80'
gitlab_rails['gitlab_ssh_host'] = 'gitlab-net'
gitlab_rails['gitlab_shell_ssh_port'] = 22
```

vim  /opt/programs/gitlab/gitlab/var/gitlab-rails/etc/gitlab.yml
#修改如下配置

```
## GitLab settings
gitlab:
    ## Web server settings (note: host is the FQDN, do not include http://)
    host: gitlab-net
    port: 80
    https: false

    # The maximum time unicorn/puma can spend on the request. This needs to be smaller than the worker timeout.
    # Default is 95% of the worker timeout
    max_request_duration_seconds: 57

    # Uncommment this line below if your ssh host is different from HTTP/HTTPS one
    # (you'd obviously need to replace ssh.host_example.com with your own host).
    # Otherwise, ssh host will be set to the `host:` value above
ssh_host: gitlab-net
```

使配置生效：gitlab-ctl reconfigure
重启gitlab：gitlab-ctl restart

账号：root
密码：admin123

参考：https://www.cnblogs.com/diaomina/p/12830449.html

### emqx（MQTT服务器）

```
拉取镜像：docker pull emqx/emqx
运行容器：

docker run -d --restart=always  \
 --network mynet --network-alias emqx-net \
 -p 1883:1883  \
 -p 28083:8083  \
 -p 28883:8883  \
 -p 28084:18084  \
 -p 18083:18083  \
 -v /opt/programs/emqx/data:/opt/emqx/data \
 -v /opt/programs/emqx/log:/opt/emqx/log   \
 --name emqx  \
 emqx/emqx
```

容器启动时可能无法成功，需要给文件夹权限:
mkdir /opt/programs/emqx  && cd /opt/programs/emqx
mkdir ./data && mkdir ./etc && mkdir ./log && chmod 755 ./*

上面的操作会报错，执行下面的指令吧

```
docker run -d --restart=always \
 --name emqx  --network mynet --network-alias emqx-net \
 -p 1883:1883  \
 -p 28083:8083  \
 -p 28883:8883  \
 -p 28084:18084  \
 -p 18083:18083  \
 emqx/emqx
```

拷贝出 对应目录下的配置

docker cp emqx:/opt/emqx/etc  /opt/programs/emqx
docker rm -f emqx

然后重新创建容器

```
docker run -d --restart=always \
 --network mynet --network-alias emqx-net \
 -p 1883:1883 \
 -p 28083:8083  \
 -p 28883:8883  \
 -p 28084:18084  \
 -p 18083:18083  \
 -v /opt/programs/emqx/etc:/opt/emqx/etc \
 --name emqx  \
 emqx/emqx
```

### elasticsearch

```
拉取镜像：docker pull elasticsearch
运行容器：

docker run -d --restart always --privileged=true \
 --network mynet --network-alias elasticsearch-net \
 -p 9200:9200 \
 -p 9300:9300 \
 -v /etc/localtime:/etc/localtime   \
 -v /etc/timezone:/etc/timezone   \
 -v /usr/bin/docker:/usr/bin/docker \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v /opt/programs/elasticsearch:/usr/share/elasticsearch/data \
 -e "discovery.type=single-node" \
 --name elasticsearch \
 elasticsearch:7.14.0
```

### 生成PDF

```
拉取镜像：docker pull arachnysdocker/athenapdf
运行容器：

docker run --rm -v /opt/tmp/$(pwd):/converted/ arachnysdocker/athenapdf athenapdf https://www.arachnys.com/the-long-road-to-achieving-true-perpetual-kyc/
```

### postgres

```
拉取镜像：docker pull postgres
运行容器：

docker run --privileged -d --restart=always \
 --network mynet --network-alias postgres-net \
 -v /etc/localtime:/etc/localtime   \
 -v /usr/bin/docker:/usr/bin/docker \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -p 5432:5432 \
 -e POSTGRES_USER=postgres \
 -e POSTGRES_PASSWORD=123456 \
 -e /opt/programs/postgresql/data/pgdata:/var/lib/postgresql/data/pgdata \
 -v /opt/programs/postgresql/data/mount:/var/lib/postgresql/data \
 --name postgres \
 postgres

#-e /opt/programs/postgresql/postgresql.conf:/etc/postgresql/postgresql.conf \
```

进入容器：docker exec -it postgres /bin/bash
切换用户：su postgres
切换到命令行界面：psql
创建用户：create user  -p -s -e root
创建数据库：create database blogs owner=root;
查看数据库：\l

### kafka

```
拉取镜像：docker pull wurstmeister/kafka
运行容器：

docker run -d  --restart=always \
 --privileged=true \
 --network mynet --network-alias kafka1-net \
 -p 9092:9092 \
 -v /etc/localtime:/etc/localtime   \
 -v /opt/programs/kafka/kafka1:/bitnami/kafka \
 -e ALLOW_PLAINTEXT_LISTENER=yes \
 -e KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper-net:2181 \
 --name kafka1 \
 bitnami/kafka:latest


docker run -d  --restart=always \
 --privileged=true \
 --network mynet --network-alias kafka-net \
 -p 9092:9092 \
 -v /etc/localtime:/etc/localtime   \
 -e ALLOW_PLAINTEXT_LISTENER=yes \
 -e KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper-net:2181 \
 --name kafka \
 bitnami/kafka:latest

```

</br>

### kafka的管理界面

```
docker run --privileged -d --restart=always \
 --network mynet --network-alias kafdrop-net \
 -v /opt/programs/kafdrop/protobuf_desc/:/var/protobuf_desc \
 -p 9100:9000 \
 -e KAFKA_BROKERCONNECT=kafka-net:9092 \
 -e JVM_OPTS="-Xms32M -Xmx64M" \
 -e SERVER_SERVLET_CONTEXTPATH="/" \
 -e CMD_ARGS="--message.format=PROTOBUF --protobufdesc.directory=/var/protobuf_desc" \
 --name kafdrop \
 obsidiandynamics/kafdrop
```

### minio

```
拉去镜像：docker pull minio/minio
运行容器：

# 非集群，唯一的区别在 server 参数：server http://minio-net{1...2}/data{1...4} \

docker  run -d --restart=always  \
 --network mynet --network-alias minio-net  \
 -p 9006:9000  \
 -p 9007:9001  \
 -e MINIO_ACCESS_KEY=admin \
 -e MINIO_SECRET_KEY=admin123 \
 -v /opt/programs/minio/config:/root/.minio \
 -v /opt/programs/minio/data1:/data1 \
 -v /opt/programs/minio/data2:/data2 \
 -v /opt/programs/minio/data3:/data3 \
 -v /opt/programs/minio/data4:/data4 \
 --name minio \
 minio/minio server http://minio-net/data{1...4} \
 --console-address ":9001"
```

### portainer：docker管理

```
docker run --privileged -d --restart=always  \
 -p 9002:9000 \
 -v /etc/localtime:/etc/localtime   \
 -v /etc/timezone:/etc/timezone   \
 -v /usr/bin/docker:/usr/bin/docker \
 -v /var/run/docker.sock:/var/run/docker.sock \
 --name portainer \
 portainer/portainer


主页：http://IP:9002/#!/home
```
