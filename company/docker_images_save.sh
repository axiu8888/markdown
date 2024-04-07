#!/bin/bash
dir=./images
mkdir -p $dir && chmod 755 $dir
filename=docker_images.txt
docker images >>$filename
IFS=" "
cat $filename | while read line; do
    ARR=($line)
    name=${ARR[0]}
    tag=${ARR[1]}
    image=$name:$tag
    if [ "$(echo $name | grep "/")" != "" ]; then
        name=${name##*/}
        # echo "new name ==>: ${name}"
    fi
    tar_name=$name@$tag.tar
    echo "导出镜像 =>: docker save $image > $dir/$tar_name && gzip $dir/$tar_name"
    echo $(docker save $image > $dir/$tar_name && gzip $dir/$tar_name)
    echo "------------------------------------------"
done

rm -f $filename
rm -f $dir/REPOSITORY@TAG.tar

echo $(ll -h)

