#!/bin/bash
set -e

# Set the edition
EDITION="open-source"
ALLUXIO_VERSION="2.9.0"

# Define the version and S3 bucket details
S3_BUCKET="alluxio-binaries"

# Determine the file name and directory name based on the edition
if [[ "${EDITION}" == "enterprise" ]]; then
    FILE_NAME="alluxio-enterprise-${ALLUXIO_VERSION}-bin.tar.gz"
    DIR_NAME="alluxio-enterprise-${ALLUXIO_VERSION}"
else
    FILE_NAME="alluxio-${ALLUXIO_VERSION}-bin.tar.gz"
    DIR_NAME="alluxio-${ALLUXIO_VERSION}"
fi

# Set the installation directory
INSTALL_DIR="/opt/alluxio"

# Check if the installation directory exists
if [[ ! -d "${INSTALL_DIR}" ]]; then
    # Check if the file already exists
    if [[ ! -e "${FILE_NAME}" ]]; then
        # Determine the S3 path based on the edition
        if [[ "${EDITION}" == "enterprise" ]]; then
            S3_PATH="ee_byol/${ALLUXIO_VERSION}-1.0/${FILE_NAME}"
        else
            S3_PATH="os/${ALLUXIO_VERSION}/${FILE_NAME}"
        fi

        # Download the Alluxio tarball
        echo "Downloading Alluxio ${ALLUXIO_VERSION}..."
        aws s3 cp "s3://${S3_BUCKET}/${S3_PATH}" .
    fi

    # Extract the tarball
    echo "Extracting Alluxio tarball..."
    tar -xf "${FILE_NAME}"

    # Move the extracted files to the installation directory
    echo "Moving Alluxio files to ${INSTALL_DIR}..."
    sudo mv "${DIR_NAME}" "${INSTALL_DIR}"

    # Set the owner and group of the installation directory
    echo "Updating owner and group of ${INSTALL_DIR}..."
    sudo chown -R ec2-user:ec2-user "${INSTALL_DIR}"
else
    echo "Alluxio is already installed in ${INSTALL_DIR}. Skipping extraction."
fi

# Rest of the script...
