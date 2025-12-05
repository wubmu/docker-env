# Elasticsearch Docker 部署方案

本项目提供了两种 Elasticsearch 部署配置：带安全认证和不带安全认证。

## 目录结构

```
elasticsearch/
├── with-security/          # 带安全认证的配置
│   ├── docker-compose.yml  # Docker Compose 配置文件
│   └── elasticsearch.yml   # Elasticsearch 配置文件
├── without-security/       # 无安全认证的配置
│   ├── docker-compose.yml  # Docker Compose 配置文件
│   └── elasticsearch.yml   # Elasticsearch 配置文件
├── docker-compose.yml      # 原始配置文件（无安全认证）
├── elasticsearch.yml       # 原始配置文件
└── README.md              # 使用说明文档
```

## 部署方式

### 1. 带安全认证的部署（推荐用于生产环境）

```bash
cd with-security/

# 启动服务
docker-compose up -d

# 查看 elastic 用户密码（默认：YourSecurePassword123!）
# 建议修改 docker-compose.yml 中的密码
```

连接方式：
- **HTTP API**: `http://YOUR_SERVER_IP:9200` (需要认证)
- **Kibana**: `http://YOUR_SERVER_IP:5601` (用户名: elastic, 密码: YourSecurePassword123!)
- **Cerebro**: `http://YOUR_SERVER_IP:9000`

远程连接示例：
```bash
# 使用 curl
curl -u elastic:YourSecurePassword123! http://YOUR_SERVER_IP:9200/_cluster/health

# 使用 Python
from elasticsearch import Elasticsearch
es = Elasticsearch(
    ["http://YOUR_SERVER_IP:9200"],
    http_auth=("elastic", "YourSecurePassword123!")
)
```

### 2. 无安全认证的部署（适合开发测试）

```bash
cd without-security/

# 启动服务
docker-compose up -d
```

连接方式：
- **HTTP API**: `http://YOUR_SERVER_IP:9200` (无需认证)
- **Kibana**: `http://YOUR_SERVER_IP:5601` (无需认证)
- **Cerebro**: `http://YOUR_SERVER_IP:9000`

远程连接示例：
```bash
# 使用 curl
curl http://YOUR_SERVER_IP:9200/_cluster/health

# 使用 Python
from elasticsearch import Elasticsearch
es = Elasticsearch(["http://YOUR_SERVER_IP:9200"])
```

### 3. 原始配置（位于根目录）

```bash
# 在当前目录启动（无安全认证）
docker-compose up -d

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