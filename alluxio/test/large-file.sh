#!/bin/bash

# dd if=/dev/zero of=/mnt/data/file-200GB.txt bs=1G count=200

# download test file from S3
aws s3 cp s3://alluxio.saiguang.test/large-files/file-200GB.txt /mnt/data/file-200GB.txt
#aws s3 cp /mnt/data/file-200GB.txt s3://alluxio.saiguang.test/large-files/file-200GB.txt

# copy from local the large file to alluxio
alluxio fs -Dalluxio.user.file.writetype.default=MUST_CACHE copyFromLocal /mnt/data/file-200GB.txt /file-200GB.txt