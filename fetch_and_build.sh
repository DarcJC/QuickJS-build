#!/usr/bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

# 设置默认版本和源URL
DEFAULT_VERSION="2024-01-13"
VERSION="${QUICKJS_VERSION:-$DEFAULT_VERSION}"
SOURCE_URL="https://bellard.org/quickjs/quickjs-${VERSION}.tar.xz"

# 通过环境变量读取DESTINATION_DIR，设置默认值
DESTINATION_DIR="${QUICKJS_DEST_DIR:-quickjs}"
TARGET_DIR="$DESTINATION_DIR/quickjs-$VERSION"

# 检查目标目录是否存在
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

# 创建存放QuickJS代码的目录
mkdir -p "${DESTINATION_DIR}"
cd "${DESTINATION_DIR}"

# 下载QuickJS源代码
echo "Downloading QuickJS version ${VERSION}..."
if curl -O "${SOURCE_URL}"; then
    echo "Download successful."
else
    echo "Error downloading QuickJS. Please check the version and URL."
    exit 1
fi

# 解压下载的文件
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

# 确定解压后的实际目录名并进入该目录
ACTUAL_DIR=$(tar -tf "${TAR_FILE}" | head -n 1 | cut -f1 -d"/")
cd "${ACTUAL_DIR}"

# 拷贝CMakeLists.txt到目标目录
echo "Copying CMakeLists.txt to ${PWD}..."
cp "${SHELL_FOLDER}/CMakeLists.txt" "${PWD}/"

# 判断是否执行交叉编译
if [ "$1" == "--window" ]; then
    echo "Performing cross-compilation for Windows..."
    CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ rm -rf build && cmake -B build -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_STATIC_LIBRARY_SUFFIX_C=.lib && cmake --build build
else
    echo "Performing regular compilation..."
    rm -rf build && cmake -B build && cmake --build build
fi

echo "QuickJS version ${VERSION} compilation is complete."
