#!/bin/bash

flag_file="/tmp/prepared"

# Check if the flag file exists
if [[ ! -f "${flag_file}" ]]; then

    # install java11 and other softwares
    sudo yum install -y java-11-amazon-corretto-devel tmux

    # mount ebs for data
    # format the disk
    sudo mkfs -t ext4 /dev/sdb
    # create mount point
    sudo mkdir /mnt/data
    # mount the disk
    sudo mount /dev/sdb /mnt/data
    # update permission
    sudo chmod 777 /mnt/data

    # Create the flag file
    touch "${flag_file}"
    echo "Flag file created: ${flag_file}"
else
    echo "Flag file already exists: ${flag_file}. Skipping script execution."
fi
