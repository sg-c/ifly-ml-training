#!/bin/bash
set -e

# Update system packages
sudo yum update -y

# Install required dependencies
sudo yum install -y java-11-amazon-corretto-devel wget tmux

# Download Apache Ranger package
wget -P /tmp https://downloads.apache.org/ranger/2.3.0/apache-ranger-2.3.0.tar.gz

# Extract Apache Ranger package
tar -xf /tmp/apache-ranger-2.3.0.tar.gz -C /tmp

# Move the extracted files to a desired installation directory
sudo mv /tmp/apache-ranger-2.3.0 /opt/ranger

# Configure Apache Ranger properties
cd /opt/ranger
sudo cp install.properties ./install.properties.orig
sudo sed -i 's|^db_root_user=.*$|db_root_user=rangeradmin|' install.properties
sudo sed -i 's|^db_root_password=.*$|db_root_password=<db_root_password>|' install.properties
sudo sed -i 's|^db_host=.*$|db_host=<db_host>|' install.properties
# Add any additional configuration changes as required

# Run the Ranger setup script
sudo ./setup.sh

# Start Apache Ranger services
sudo ./ranger-admin start
sudo ./ranger-usersync start
# Add any additional service startup commands as required

# Enable Apache Ranger services to start on system boot
sudo systemctl enable ranger-admin
sudo systemctl enable ranger-usersync
# Add any additional service enabling commands as required

echo "Apache Ranger installation and deployment completed successfully."
