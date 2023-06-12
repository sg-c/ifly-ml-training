#!/bin/bash

if [ ! -f ./tool/command.sh ]; then
    echo "create the command.sh in ./tool/ for commands to run"
    exit 1
fi

CMD="cd ifly-ml-training; git pull; ./script/command.sh"

# Define the EC2 instance names
instances=("fuse-test-1" "fuse-test-2" "fuse-test-3")

# Upload SSH public key to each EC2 instance
for instance in "${instances[@]}"; do
    echo "Uploading command.sh to ${instance}..."
    scp ./command.sh ${instance}:~/ifly-ml-training/tool/

    echo "Execute command.sh on ${instance}..."
    ssh ${instance} "~/ifly-ml-training/tool/command.sh"
done
