#!/bin/bash
echo "Asia/shanghai" > /etc/timezone
export   LANG=C.UTF-8
#export LC_ALL=zh_CN.utf8
#source /etc/profile

JAVA_HOME=/opt/env/jdks/11
PATH=$JAVA_HOME/bin:$PATH
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

dir=/home/znsx/program
cd $dir/web
appname=$(ls -l|grep '\.jar$'  | awk '{print $9}'|sort -rV)
name=$(echo $appname|cut -d ' ' -f1)

exec java -jar \
 -Duser.timezone=GMT+08 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:18000 \
 $dir/web/$name  \
 --spring.config.location=$dir/web/config/application.properties,$dir/config/conf.properties \
 >> /home/znsx/log/znsx-web.log

