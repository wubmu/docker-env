# Elasticsearch 单机版 Docker Compose 部署

## 快速启动

### 基础启动 (仅 Elasticsearch + Kibana)
```bash
# 进入目录
cd docker-env/elasticsearch

# 启动服务
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 完整启动 (包含管理工具)
```bash
# 启动所有服务，包括 Cerebro
docker-compose --profile tools up -d
```

## 服务信息

### Elasticsearch
- **HTTP 接口**: http://localhost:9200
- **TCP 接口**: localhost:9300
- **版本**: 8.12.0
- **JVM 堆内存**: 1GB

### Kibana
- **Web 界面**: http://localhost:5601
- **版本**: 8.12.0

### Cerebro (可选)
- **Web 界面**: http://localhost:9000
- **功能**: Elasticsearch 管理工具

## 健康检查

检查 Elasticsearch 集群状态：
```bash
# 检查集群健康
curl -X GET "localhost:9200/_cluster/health?pretty"

# 检查节点信息
curl -X GET "localhost:9200/_nodes?pretty"

# 检查索引状态
curl -X GET "localhost:9200/_cat/indices?v"
```

## 基本操作

### 创建索引
```bash
curl -X PUT "localhost:9200/my-index" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "properties": {
      "title": { "type": "text" },
      "author": { "type": "keyword" },
      "published_date": { "type": "date" }
    }
  }
}'
```

### 插入文档
```bash
curl -X POST "localhost:9200/my-index/_doc" -H 'Content-Type: application/json' -d'
{
  "title": "Elasticsearch Guide",
  "author": "Elastic Team",
  "published_date": "2024-01-01"
}'
```

### 搜索文档
```bash
curl -X GET "localhost:9200/my-index/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "title": "guide"
    }
  }
}'
```

## 配置说明

### Elasticsearch 配置
- **单节点模式**: `discovery.type: single-node`
- **安全功能**: 已禁用 `xpack.security.enabled: false`
- **内存锁定**: 已启用 `bootstrap.memory_lock: true`

### JVM 内存配置
- **堆内存**: 1GB (`-Xms1g -Xmx1g`)
- **垃圾回收器**: G1GC
- **GC 日志**: 已启用

### 数据持久化
- 数据存储在 Docker volume `es_data` 中
- 配置文件挂载到容器内

## 性能优化建议

### 生产环境配置
```bash
# 增加虚拟内存
sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf

# 增加文件描述符限制
ulimit -n 65536
```

### 调整 JVM 内存
编辑 `jvm.options` 文件，调整 `-Xms` 和 `-Xmx` 参数：
- 开发环境：1-2GB
- 生产环境：建议不超过物理内存的 50%，最大 31GB

## 监控和日志

### 查看日志
```bash
# Elasticsearch 日志
docker-compose logs -f elasticsearch

# Kibana 日志
docker-compose logs -f kibana

# 所有服务日志
docker-compose logs -f
```

### 监控指标
- 集群健康状态
- 节点 JVM 使用率
- 索引和搜索性能
- 磁盘使用情况

## 故障排除

### 常见问题
1. **内存不足**: 检查 JVM 堆内存设置
2. **启动失败**: 检查 `vm.max_map_count` 设置
3. **连接问题**: 确认端口未被占用

### 重置数据
```bash
# 停止服务
docker-compose down

# 删除数据卷
docker volume rm elasticsearch_es_data

# 重新启动
docker-compose up -d
```

## 停止和清理
```bash
# 停止服务
docker-compose down

# 停止并删除数据
docker-compose down -v

# 停止并删除所有相关资源
docker-compose --profile tools down -v
```