#!/bin/bash

dir=./images
mkdir -p $dir && chmod 755 $dir
filename=./docker_images.txt
docker images >>$filename


# 忽略第一行标题行并读取文件内容
tail -n +2 $filename | while read -r line
do
  # 使用 awk 来处理每一行的内容
  name=$(echo "$line" | awk '{print $1}')
  tag=$(echo "$line" | awk '{print $2}')
  image=$name:$tag
  if [ "$(echo $name | grep "/")" != "" ]; then
    name=${name##*/}  # 截取反斜杠，如: minio/minio 截取为 minio
  fi
  
  # 输出 REPOSITORY@TAG 的格式
  #echo "${name}@${tag}"
  tar_name=$name@$tag.tar
  echo "导出镜像 =>: docker save $image > $dir/$tar_name && gzip $dir/$tar_name"
  "echo $(docker save $image > $dir/$tar_name && gzip $dir/$tar_name)"
  echo "------------------------------------------"
done


# IFS=" "
# cat $filename | while read line; do
#     ARR=($line)
#     name=${ARR[0]}
#     tag=${ARR[1]}
#     image=$name:$tag
#     if [ "$(echo $name | grep "/")" != "" ]; then
#         name=${name##*/}
#         # echo "new name ==>: ${name}"
#     fi
#     tar_name=$name@$tag.tar
#     echo "导出镜像 =>: docker save $image > $dir/$tar_name && gzip $dir/$tar_name"
#     echo $(docker save $image > $dir/$tar_name && gzip $dir/$tar_name)
#     echo "------------------------------------------"
# done

rm -f $filename
rm -f $dir/REPOSITORY@TAG.tar

ll -h


