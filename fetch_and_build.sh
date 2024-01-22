#!/usr/bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

# Set default version and source URL
DEFAULT_VERSION="2024-01-13"
VERSION="${QUICKJS_VERSION:-$DEFAULT_VERSION}"
SOURCE_URL="https://bellard.org/quickjs/quickjs-${VERSION}.tar.xz"

# Read DESTINATION_DIR from environment variable, set default value
DESTINATION_DIR="${QUICKJS_DEST_DIR:-quickjs}"
TARGET_DIR="$DESTINATION_DIR/quickjs-$VERSION"

# Check if the target directory exists
if [ -d "${DESTINATION_DIR}" ]; then
    read -p "Directory ${DESTINATION_DIR} already exists. Do you want to remove it? (y/N) " response
    case "$response" in 
        [yY][eE][sS]|[yY]) 
            echo "Removing directory ${DESTINATION_DIR}..."
            rm -rf "${DESTINATION_DIR}"
            ;;
        *)
            echo "Exiting script."
            exit 1
            ;;
    esac
fi

# Create directory to store QuickJS code
mkdir -p "${DESTINATION_DIR}"
cd "${DESTINATION_DIR}"

# Download QuickJS source code
echo "Downloading QuickJS version ${VERSION}..."
if curl -O "${SOURCE_URL}"; then
    echo "Download successful."
else
    echo "Error downloading QuickJS. Please check the version and URL."
    exit 1
fi

# Extract the downloaded file
TAR_FILE="quickjs-${VERSION}.tar.xz"
if [ -f "${TAR_FILE}" ]; then
    echo "Extracting ${TAR_FILE}..."
    if tar -xf "${TAR_FILE}"; then
        echo "Extraction successful."
    else
        echo "Error extracting the TAR file."
        exit 1
    fi
else
    echo "Downloaded file ${TAR_FILE} does not exist."
    exit 1
fi

# Determine the actual directory name after extraction and enter the directory
ACTUAL_DIR=$(tar -tf "${TAR_FILE}" | head -n 1 | cut -f1 -d"/")
cd "${ACTUAL_DIR}"

# Copy CMakeLists.txt to the target directory
echo "Copying CMakeLists.txt to ${PWD}..."
cp "${SHELL_FOLDER}/CMakeLists.txt" "${PWD}/"

# Determine whether to perform cross-compilation
if [ "$1" == "--window" ]; then
    echo "Performing cross-compilation for Windows..."
    rm -rf build && CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ cmake -B build -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_STATIC_LIBRARY_SUFFIX_C=.lib && cmake --build build
else
    echo "Performing regular compilation..."
    rm -rf build && cmake -B build && cmake --build build
fi

echo "QuickJS version ${VERSION} compilation is complete."
