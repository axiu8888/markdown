#!/bin/bash

filename=docker_images.txt
docker images -a >>$filename
IFS=" "
cat $filename | while read line; do
    # echo $line | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g'
    ARR=($line)
    echo "删除镜像：${ARR[0]}:${ARR[1]}, docker rmi -f ${ARR[2]}"
    echo $(docker rmi -f ${ARR[2]})
    echo "------------------------------------------"
done

rm -f $filename
