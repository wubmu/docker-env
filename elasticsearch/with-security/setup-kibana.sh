#!/bin/bash

echo "=== 设置 Kibana 服务账号 ==="

# 等待 Elasticsearch 健康检查通过
echo "等待 Elasticsearch 启动..."
until curl -s -u elastic:YourSecurePassword123! http://localhost:9200/_cluster/health | grep -q '"status":"green"'; do
    echo "等待 Elasticsearch 变为 green 状态..."
    sleep 5
done

echo "Elasticsearch 已就绪！"

# 设置 kibana_system 用户密码
echo "设置 kibana_system 用户密码..."
curl -X POST -u elastic:YourSecurePassword123! -k "http://localhost:9200/_security/user/kibana_system/_password" -H 'Content-Type: application/json' -d'
{
  "password": "kibana_system"
}'

if [ $? -eq 0 ]; then
    echo "kibana_system 用户密码设置成功！"
else
    echo "密码设置可能失败，但 kibana_system 用户通常默认存在，尝试继续..."
fi

# 验证 kibana_system 用户
echo "验证 kibana_system 用户..."
response=$(curl -s -u kibana_system:kibana_system http://localhost:9200/_cluster/health)
if echo "$response" | grep -q '"status"'; then
    echo "kibana_system 用户验证成功！"
else
    echo "kibana_system 用户验证失败，请检查日志"
fi

echo "=== 设置完成 ==="
echo "Kibana 服务账号："
echo "  用户名: kibana_system"
echo "  密码: kibana_system"
echo ""
echo "现在可以启动 Kibana 服务了"