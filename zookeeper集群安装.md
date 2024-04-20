# Zookeeper集群安装

1、配置：

```
zkDir= /opt/programs/zookeeper
&& mkdir -p $zkDir/zk1/
&& cd $zkDir/zk1
&& mkdir -p ./data
&& mkdir -p ./conf
&& mkdir -p ./logs
&& chmod 755 ./*
```

---

2、vim ./conf/zoo.cfg

```
tickTime=2000
initLimit=10
syncLimit=5
dataDir=../data
dataLogDir=../logs
clientPort=2181
#maxClientCnxns=60
#autopurge.snapRetainCount=3
#autopurge.purgeInterval=1

#metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
#metricsProvider.httpPort=7000
#metricsProvider.exportJvmInfo=true

server.1=0.0.0.0:2888:3888
server.2=zk2-net:2888:3888
server.3=zk3-net:2888:3888
```

---

3、vim ./zk1/data/myid

```

输入：1

```

---

4、拷贝： cp zk1 zk2 zk3

修改zk2和zk3的配置：

4.1、vim zk2/conf/zoo.cfg

```
server.1=zk1-net:2888:3888
server.2=0.0.0.0:2888:3888
server.3=zk3-net:2888:3888
```


4.2、vim zk3/conf/zoo.cfg

```
server.1=zk1-net:2888:3888
server.2=zk2-net:2888:3888
server.3=0.0.0.0:2888:3888
```

4.3、vim zk2/data/myid

```
    输入：2
```

4.4、vim /zk3/data/myid

```
    输入：3
```

docker安装：

```
docker pull zookeeper
```

---

5、创建集群容器

5.1、zk1

```
docker run -d --privileged=true \
 --network mynet --network-alias zk1-net \
 -p 2181:2181 \
 -v /etc/localtime:/etc/localtime   \
 -v /opt/programs/zookeeper/zk1/conf/zoo.cfg:/conf/zoo.cfg \
 -v /opt/programs/zookeeper/zk1/data:/data  \
 -v /opt/programs/zookeeper/zk1/logs:/datalog  \
 --name zk1 \
 zookeeper
```

5.2、zk2

```
docker run -d --privileged=true \
 --network mynet --network-alias zk2-net \
 -p 2182:2181 \
 -v /etc/localtime:/etc/localtime   \
 -v /opt/programs/zookeeper/zk2/conf/zoo.cfg:/conf/zoo.cfg \
 -v /opt/programs/zookeeper/zk2/data:/data  \
 -v /opt/programs/zookeeper/zk2/logs:/datalog  \
 --name zk2 \
 zookeeper
```

5.3、zk3

```
docker run -d --privileged=true \
 --network mynet --network-alias zk3-net \
 -p 2183:2181 \
 -v /etc/localtime:/etc/localtime   \
 -v /opt/programs/zookeeper/zk3/conf/zoo.cfg:/conf/zoo.cfg \
 -v /opt/programs/zookeeper/zk3/data:/data  \
 -v /opt/programs/zookeeper/zk3/logs:/datalog  \
 --name zk3 \
 zookeeper
```


--- 

单个容器

```
docker run -d \
 --restart always \
 --privileged=true \
 --network mynet --network-alias zookeeper-net \
 -p 2181:2181 \
 -v /etc/localtime:/etc/localtime   \
 -v /opt/programs/zookeeper/single/conf/zoo.cfg:/conf/zoo.cfg \
 -v /opt/programs/zookeeper/single/data:/data  \
 -v /opt/programs/zookeeper/single/logs:/datalog  \
 --name zookeeper \
 zookeeper
```







~