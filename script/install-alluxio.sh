#!/bin/bash
set -e

# Define the version and S3 bucket details
ALLUXIO_VERSION="2.9.0"
S3_BUCKET="alluxio-binaries"
S3_PATH="os/${ALLUXIO_VERSION}/alluxio-${ALLUXIO_VERSION}-bin.tar.gz"

# Set the installation directory
INSTALL_DIR="/opt/alluxio"

# Set the file name
FILE_NAME="alluxio-${ALLUXIO_VERSION}-bin.tar.gz"

# Check if the file already exists
if [[ -e "${FILE_NAME}" ]]; then
    echo "File ${FILE_NAME} already exists. Skipping download."
else
    # Download the Alluxio tarball
    echo "Downloading Alluxio ${ALLUXIO_VERSION}..."
    aws s3 cp "s3://${S3_BUCKET}/${S3_PATH}" .
fi

# Extract the tarball
echo "Extracting Alluxio tarball..."
tar -xf "${FILE_NAME}"

# Move the extracted files to the installation directory
echo "Moving Alluxio files to ${INSTALL_DIR}..."
sudo mv "alluxio-${ALLUXIO_VERSION}" "${INSTALL_DIR}"

# Set the owner and group of the installation directory
echo "Updating owner and group of ${INSTALL_DIR}..."
sudo chown -R ec2-user:ec2-user "${INSTALL_DIR}"

# Set the ALLUXIO_HOME environment variable
echo "Setting ALLUXIO_HOME environment variable..."
echo "export ALLUXIO_HOME=${INSTALL_DIR}" >> ~/.bashrc
source ~/.bashrc

# Configure Alluxio
echo "Configuring Alluxio..."
cd "${INSTALL_DIR}/conf"
cp alluxio-site.properties.template alluxio-site.properties

