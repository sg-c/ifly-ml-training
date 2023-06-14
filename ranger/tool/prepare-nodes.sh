#!/bin/bash

set -e

# clone repo
CLONE_REPO="sudo yum install -y git; [ ! -d ifly-ml-training ] && git clone https://github.com/sg-c/ifly-ml-training.git; "

# Set up the nodes
ssh iflytek-ranger "$CLONE_REPO"
