#!/bin/bash

docker ps -a >>docker_ps_a.txt

# # 翻转每一行，获取翻转后的一个单词
# rev docker_ps_a.txt | cut -d' ' -f1 | rev

for name in $(rev docker_ps_a.txt | cut -d' ' -f1 | rev); do
    echo "删除容器: docker rm -f $name, $(docker rm -f "$name")"
done

rm -f docker_ps_a.txt
