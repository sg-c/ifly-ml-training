#!/bin/bash
set -e

# Update system packages
sudo yum update -y

# Install required dependencies
sudo yum install -y java-11-amazon-corretto-devel git maven wget

# Install MySQL Server
sudo yum install -y mysql-server

# Start and enable MySQL service
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Secure MySQL installation
sudo mysql_secure_installation

# Clone Apache Ranger repository
git clone https://github.com/apache/ranger.git
cd ranger

# Checkout the desired version
git checkout tags/release-ranger-2.3.0

# Build Apache Ranger
mvn clean compile package install assembly:assembly -DskipTests=true -Pall

# Extract the Ranger package
tar -xf target/ranger-2.3.0.tar.gz -C /opt

# Configure Apache Ranger properties
cd /opt/ranger-2.3.0
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

echo "Apache Ranger build and installation completed successfully."
