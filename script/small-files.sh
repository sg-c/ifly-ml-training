#!/bin/bash
set -e

# Define the S3 bucket details
S3_BUCKET="alluxio.saiguang.test"
TOTAL_FILES=1000000
FILES_PER_PROCESS=50000
NUM_PROCESSES=20

# Function to upload a range of files to S3
upload_files_to_s3() {
    local start="$1"
    local end="$2"
    for i in $(seq $start $end); do
        # Convert i to a hexadecimal value
        hex=$(printf "%05x" $i)
        # Upload the file to S3
        aws s3 cp /tmp/file.txt "s3://${S3_BUCKET}/small-files/file-$hex.txt"
    done
}

# Export the function to make it accessible to parallel processes
export -f upload_files_to_s3

# Create a file of 8KB
dd if=/dev/zero of=/tmp/file.txt bs=1024 count=8

# Calculate the number of processes needed
num_processes=$((TOTAL_FILES / FILES_PER_PROCESS))
if [[ $((TOTAL_FILES % FILES_PER_PROCESS)) -ne 0 ]]; then
    num_processes=$((num_processes + 1))
fi

# Launch parallel processes to upload files
for ((i = 0; i < num_processes; i++)); do
    start=$((i * FILES_PER_PROCESS + 1))
    end=$((start + FILES_PER_PROCESS - 1))
    if [[ $end -gt $TOTAL_FILES ]]; then
        end=$TOTAL_FILES
    fi
    upload_files_to_s3 $start $end &
done

# Wait for all processes to finish
wait

# Remove the file
rm /tmp/file.txt
