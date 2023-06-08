#!/bin/bash

# Create a file of 8KB
dd if=/dev/zero of=/tmp/file.txt bs=1024 count=8

# Upload it to S3 1 million times
for i in $(seq 1 1000000); do
    # Convert i to a hexadecimal value
    hex=$(printf "%05x" $i)

    # Upload the file to S3
    aws s3 cp /tmp/file.txt s3://alluxio.saiguang.test/small-files/file-$hex.txt
done

# Remove the file
rm /tmp/file.txt
