#!/bin/bash

# install java11 and other softwares
sudo yum install -y java-11-amazon-corretto git tmux

# mount ebs for data
# format the disk
sudo mkfs -t ext4 /dev/sdb
# create mount point
sudo mkdir /mnt/data
# mount the disk
sudo mount /dev/sdb /mnt/data

# clone repo
[ ! -d ifly-ml-training ] && git clone https://github.com/sg-c/ifly-ml-training.git