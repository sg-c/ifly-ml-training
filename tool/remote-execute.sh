#!/bin/bash

CMD="cd ifly-ml-training; git pull; ./script/command.sh"

# Set up the nodes
ssh fuse-test-1 "$CMD"
ssh fuse-test-2 "$CMD"
ssh fuse-test-3 "$CMD"
