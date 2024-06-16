#!/bin/bash

# filename=docker_images.txt
# docker images -a >>$filename
# IFS=" "
# cat $filename | while read line; do
#     # echo $line | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g'
#     ARR=($line)
#     echo "加载镜像: gunzip -c ${ARR[0]}:${ARR[1]} | docker load -i ${ARR[2]}"
#     echo $(docker rmi -f ${ARR[2]})
#     echo "------------------------------------------"
# done

# rm -f $filename

cd ./images
ls -l  *.tar|awk '{print $NF}'|sed -r 's#(.*)#docker load -i \1#' |bash
ls -l  *.tar.gz|awk '{print $NF}'|sed -r 's#(.*)#docker load -i \1#' |bash
#ls -l  *.tar.gz|awk '{print $NF}'|sed -r 's#(.*)#gunzip -c \1 |docker load -i \1#' |bash

cd ../


