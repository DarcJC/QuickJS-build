#!/usr/bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

# Set default version
DEFAULT_VERSION="2024-01-13"
VERSION="${QUICKJS_VERSION:-$DEFAULT_VERSION}"

# Read DESTINATION_DIR from environment variable, set default value
DESTINATION_DIR="${QUICKJS_DEST_DIR:-quickjs}"
TARGET_DIR="$DESTINATION_DIR/quickjs-default"

# Check if VERSION is a URL
if [[ $VERSION =~ ^https?:// ]]; then
    # VERSION is a URL, use git clone
    echo "Cloning QuickJS from $VERSION..."
    if git clone $VERSION $TARGET_DIR; then
        echo "Clone successful."
        ACTUAL_DIR="$TARGET_DIR"
    else
        echo "Error cloning QuickJS repository. Please check the URL."
        exit 1
    fi
else
    # VERSION is not a URL, use the original download method
    SOURCE_URL="https://bellard.org/quickjs/quickjs-${VERSION}.tar.xz"

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

    # Determine the actual directory name after extraction
    ACTUAL_DIR=$(tar -tf "${TAR_FILE}" | head -n 1 | cut -f1 -d"/")
fi

# Enter the QuickJS directory
cd "${ACTUAL_DIR}"

# Copy CMakeLists.txt to the target directory
echo "Copying CMakeLists.txt to ${PWD}..."
cp "${SHELL_FOLDER}/CMakeLists.txt" "${PWD}/"

# Perform compilation based on the provided arguments
COMPILATION_ARGS="$1"
echo "Performing compilation with arguments: $COMPILATION_ARGS..."
rm -rf build

# Check for Windows cross-compilation
if [[ "$COMPILATION_ARGS" == *"mingw32"* || "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]]; then
    # Windows cross-compilation
    eval $COMPILATION_ARGS cmake -B build -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_STATIC_LIBRARY_SUFFIX_C=.lib -DMSLIB=OFF -G Ninja
    eval $COMPILATION_ARGS cmake -B build -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_STATIC_LIBRARY_SUFFIX_C=.lib -DMSLIB=ON -G Ninja
else
    # Regular compilation
    eval $COMPILATION_ARGS cmake -B build
fi

cmake --build build

echo "QuickJS version ${VERSION} compilation is complete."
