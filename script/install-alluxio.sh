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

# Check if the installation directory exists
if [[ ! -d "${INSTALL_DIR}" ]]; then
    # Check if the file already exists
    [[ ! -e "${FILE_NAME}" ]] && aws s3 cp "s3://${S3_BUCKET}/${S3_PATH}" .

    # Extract the tarball
    echo "Extracting Alluxio tarball..."
    tar -xf "${FILE_NAME}"

    # Move the extracted files to the installation directory
    echo "Moving Alluxio files to ${INSTALL_DIR}..."
    sudo mv "alluxio-${ALLUXIO_VERSION}" "${INSTALL_DIR}"

    # Set the owner and group of the installation directory
    echo "Updating owner and group of ${INSTALL_DIR}..."
    sudo chown -R ec2-user:ec2-user "${INSTALL_DIR}"
else
    echo "Alluxio is already installed in ${INSTALL_DIR}. Skipping extraction."
fi

# Set the ALLUXIO_HOME environment variable if not already set in .bashrc
if ! grep -q "ALLUXIO_HOME" ~/.bashrc; then
    echo "Setting ALLUXIO_HOME environment variable..."
    echo "export ALLUXIO_HOME=${INSTALL_DIR}" >>~/.bashrc
    source ~/.bashrc
fi

# Add $ALLUXIO_HOME/bin to the PATH if not already set in .bashrc
if ! grep -q "export PATH=.*\$ALLUXIO_HOME/bin.*" ~/.bashrc; then
    echo "Adding $ALLUXIO_HOME/bin to the PATH..."
    echo 'export PATH="$ALLUXIO_HOME/bin:$PATH"' >>~/.bashrc
    source ~/.bashrc
fi

# Set the JAVA_HOME environment variable if not already set in .bashrc
if ! grep -q "JAVA_HOME" ~/.bashrc; then
    echo "Setting JAVA_HOME environment variable..."
    echo "export JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto.x86_64" >>~/.bashrc
    source ~/.bashrc
fi

# Configure Alluxio
echo "Configuring Alluxio..."
cp config/alluxio-site.properties "${INSTALL_DIR}/conf"
cp config/alluxio-env.sh "${INSTALL_DIR}/conf"
cp config/masters "${INSTALL_DIR}/conf"
cp config/workers "${INSTALL_DIR}/conf"

# Get the hostname of the current node based on the IP-to-Hostname mapping in /etc/hosts
CURRENT_HOSTNAME=$(grep "$(hostname -I | awk '{print $1}')" /etc/hosts | awk '{print $2}')

# Update alluxio-site.properties with the current hostname
echo "Updating alluxio.master.hostname configuration..."
sed -i "s|^alluxio.master.hostname=.*$|alluxio.master.hostname=${CURRENT_HOSTNAME}|" "${INSTALL_DIR}/conf/alluxio-site.properties"
