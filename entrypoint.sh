#!/bin/bash
set -e
kvmAvailable=$(grep '\<kvm\>' /proc/misc | cut -f 1 -d' ')

# Create the kvm node (required --privileged)
if [ ! -e /dev/kvm ]; then
  if [ $kvmAvailable ]; then
    mknod /dev/kvm c 10 $kvmAvailable
  else
    echo "WARNING: KVM not currently available, software acceleration will be used."
  fi
fi

# use pipenv shell environment
pipenv shell
