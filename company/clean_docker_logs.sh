#!/bin/sh

echo "======== start clean docker containers logs ========"
dir=/var/run/docker/containerd
logs=$(find $dir/ -name *-json.log)
for log in $logs; do
	echo "clean logs : $log"
	cat /dev/null >"$log"
done

dir=/home/znsx/docker/containers
logs=$(find $dir/ -name *-json.log)
for log in $logs; do
	echo "clean logs : $log"
	cat /dev/null >"$log"
done

echo "======== end clean docker containers logs ========"
