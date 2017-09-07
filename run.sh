#!/bin/sh
set -e

if [ -z $WORKSPACE ]
then
  WORKSPACE=$(pwd)
fi

docker pull dukeluke16/qemu-build:latest

docker run -it --rm \
  --oom-kill-disable \
  --privileged \
  -v $WORKSPACE:/root/src \
  -p 5901:5901 \
  -p 5986:5986 \
  dukeluke16/qemu-build:latest $*
