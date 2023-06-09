#!/bin/bash

# Read the AWS credentials for the default profile from the file
AWS_ACCESS_KEY_ID=$(awk -F "=" '/^\[default\]$/{flag=1} flag && /aws_access_key_id/{print $2; flag=0}' ~/.aws/credentials | tr -d ' ')
AWS_SECRET_ACCESS_KEY=$(awk -F "=" '/^\[default\]$/{flag=1} flag && /aws_secret_access_key/{print $2; flag=0}' ~/.aws/credentials | tr -d ' ')

# Commands for cloning repo
CLONE_REPO="sudo yum install -y git && [ ! -d ifly-ml-training ] && git clone https://github.com/sg-c/ifly-ml-training.git"

# Commands for setting up aws credentials
SET_KEY_ID="aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID"
SET_SECRET="aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY"
SET_REGION="aws configure set region us-east-1"
SET_FORMAT="aws configure set output json"
SET_UP_AWS="$SET_KEY_ID && $SET_SECRET && $SET_REGION && $SET_FORMAT"

# Set up the nodes
ssh fuse-test-1 "$CLONE_REPO; $SET_UP_AWS"
ssh fuse-test-2 "$CLONE_REPO; $SET_UP_AWS"
ssh fuse-test-3 "$CLONE_REPO; $SET_UP_AWS"
