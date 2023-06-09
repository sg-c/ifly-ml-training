#!/bin/bash
set -e

# Generate temporary SSH key pair
ssh-keygen -t rsa -b 2048 -f /tmp/id_rsa -q -N ""

# Define the EC2 instance names
instances=("fuse-test-1" "fuse-test-2" "fuse-test-3")

# Upload SSH public key to each EC2 instance
for instance in "${instances[@]}"; do
    echo "Uploading SSH public key to ${instance}..."
    cat /tmp/id_rsa.pub | ssh ${instance} "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

    echo "Copying private key to ${instance}..."
    scp /tmp/id_rsa ${instance}:~/.ssh/id_rsa
    ssh ${instance} "chmod 600 ~/.ssh/id_rsa"
done

# Clean up temporary SSH key pair
rm /tmp/id_rsa /tmp/id_rsa.pub
