#!/bin/bash
# 此命令在linux上时，建议通过 vim /docker-entrypoint.sh编辑，拷贝，否则运行时可能会报错
export LANG=C.UTF-8
#source /etc/profile

JAVA_HOME=/opt/env/jdks/18
PATH=$JAVA_HOME/bin:$PATH
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

echo "Asia/shanghai" >/etc/timezone
cd /opt/app

appname=$(ls | grep .jar | sort -rn)
#appname=$(find ./ -type f -name "*.jar" | sort -rn)
name=$(echo $appname | cut -d ' ' -f1)
configname=$(ls | grep application. | sort -rn)
configfile=$(echo $configname | cut -d ' ' -f1)

mkdir -p logs && chmod 755 logs

# 使用exec 启动，进程ID为1，容器结束时会通知此进程
exec java -jar \
 -Duser.timezone=GMT+08 \
 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:18000 \
 $name \
 --spring.config.location=$configfile \
 >>./logs/$(echo "$name" | cut -f 1 -d '.').log
