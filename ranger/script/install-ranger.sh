#!/bin/bash
set -e

# Define the version and S3 bucket details
RANGER_VERSION="2.2.0"
S3_BUCKET="alluxio.saiguang.test"
S3_PATH="ranger-${RANGER_VERSION}.tar.gz"
LOCAL_ARTIFACT="/tmp/ranger-${RANGER_VERSION}.tar.gz"

# Update system packages
sudo yum update -y

# Install required dependencies
sudo yum install -y java-1.8.0-openjdk-devel wget git maven

# Install MySQL Server
sudo yum install -y mysql-server

# Start and enable MySQL service
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Secure MySQL installation
sudo mysql_secure_installation <<EOF
y
changeme123
changeme123
y
y
y
y
EOF

# Check if the build artifact exists in S3
if aws s3 ls "s3://${S3_BUCKET}/${S3_PATH}" >/dev/null 2>&1; then
  echo "Build artifact found in S3. Downloading..."
  aws s3 cp "s3://${S3_BUCKET}/${S3_PATH}" "${LOCAL_ARTIFACT}"
else
  echo "Build artifact not found in S3. Building Ranger ${RANGER_VERSION}..."
  
  # Clone Apache Ranger repository
  cd ~
  git clone https://github.com/apache/ranger.git ranger

  # Checkout the desired version
  cd ranger
  git checkout tags/release-ranger-${RANGER_VERSION}

  # Build Apache Ranger
  mvn clean compile package install -DskipTests -Pall

  # Extract the Ranger package
  tar -czf "${LOCAL_ARTIFACT}" -C target/ ranger-${RANGER_VERSION}
fi

# Extract the Ranger package
echo "Extracting the Ranger tarball..."
tar -xf "${LOCAL_ARTIFACT}" -C /opt

# Configure Apache Ranger properties
cd "/opt/ranger-${RANGER_VERSION}"
sudo cp install.properties ./install.properties.orig
sudo sed -i 's|^db_root_user=.*$|db_root_user=root|' install.properties
sudo sed -i 's|^db_root_password=.*$|db_root_password=changeme123|' install.properties
sudo sed -i 's|^db_host=.*$|db_host=localhost|' install.properties
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
