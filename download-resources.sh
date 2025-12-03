#!/bin/bash

# 创建离线资源目录
mkdir -p @offline-resource

# 设置版本变量
NVM_VERSION="0.39.5"
GO_VERSION="1.22.1"
OH_MY_ZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

# 设置下载目录
DOWNLOAD_DIR="@offline-resource"

echo "开始下载离线资源..."

# 下载 NVM 安装脚本
echo "下载 NVM 安装脚本..."
curl -L -o "${DOWNLOAD_DIR}/nvm-${NVM_VERSION}-install.sh" \
    "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh"

# 下载 Go
echo "下载 Go ${GO_VERSION}..."
curl -L -o "${DOWNLOAD_DIR}/go${GO_VERSION}.linux-amd64.tar.gz" \
    "https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz"

# 下载 Oh My Zsh 安装脚本
echo "下载 Oh My Zsh 安装脚本..."
curl -L -o "${DOWNLOAD_DIR}/oh-my-zsh-install.sh" \
    "${OH_MY_ZSH_INSTALL_URL}"

# 下载 Node.js
echo "下载 Node.js v22 二进制文件..."
curl -L -o "${DOWNLOAD_DIR}/node-v22.0.0-linux-x64.tar.gz" \
    "https://nodejs.org/dist/v22.0.0/node-v22.0.0-linux-x64.tar.gz"

# 设置执行权限
chmod +x "${DOWNLOAD_DIR}/nvm-${NVM_VERSION}-install.sh"
chmod +x "${DOWNLOAD_DIR}/oh-my-zsh-install.sh"

echo "资源下载完成！"
echo "下载的文件列表："
ls -lh "${DOWNLOAD_DIR}" 