#!/bin/bash

# Determine the parent directory of the script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Specify the paths of the existing and new hosts files
EXISTING_HOSTS_FILE="/etc/hosts"
NEW_HOSTS_FILE="$PARENT_DIR/config/hosts"

# Backup the existing hosts file
cp "$EXISTING_HOSTS_FILE" "/tmp/hosts.backup"

# Merge the new hosts file with the existing one, replacing existing host maps if they exist
awk 'NR==FNR{a[$1]=$2; next} $1 in a {$2=a[$1]} 1' "$NEW_HOSTS_FILE" "$EXISTING_HOSTS_FILE" > "/tmp/hosts.tmp"
sudo mv "/tmp/hosts.tmp" "$EXISTING_HOSTS_FILE"

echo "Merged the new hosts file with the existing one."

# Optionally, display the updated hosts file
echo "Updated /etc/hosts file:"
cat "$EXISTING_HOSTS_FILE"
