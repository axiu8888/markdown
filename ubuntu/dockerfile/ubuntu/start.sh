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

exec java -jar \
  -Duser.timezone=GMT+08 \
  -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=*:5005 \
  $jar \
  --spring.config.location=$config \
  >>./logs/$jarName.log \
  2>&1

