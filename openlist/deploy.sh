#!/bin/bash

# OpenList 部署脚本
# 用于新服务器上的首次部署

set -e

echo "=== OpenList 部署脚本 ==="
echo ""

# 检查是否存在配置文件
if [ ! -f "openlist-data/config.json" ]; then
    echo "首次部署，创建配置文件..."
    mkdir -p openlist-data
    cp config.json.template openlist-data/config.json
    echo "配置文件已创建: openlist-data/config.json"
    echo "请根据实际情况修改数据库密码和 SITE_URL"
    echo ""
    read -p "是否现在编辑配置文件？(y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-vi} openlist-data/config.json
    fi
else
    echo "配置文件已存在: openlist-data/config.json"
fi

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo "错误: .env 文件不存在"
    echo "请先创建 .env 文件并配置数据库密码"
    exit 1
fi

# 启动服务
echo ""
echo "启动服务..."
docker-compose up -d

echo ""
echo "=== 部署完成 ==="
echo "服务状态："
docker-compose ps

echo ""
echo "查看初始管理员密码："
echo "docker logs openlist | grep 'admin user'"
