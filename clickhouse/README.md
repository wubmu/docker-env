# ClickHouse Docker Compose 部署指南

## 快速启动

### 启动 ClickHouse 服务器
```bash
docker-compose -f clickhouse-docker-compose.yml up -d
```

### 启动并包含客户端
```bash
docker-compose -f clickhouse-docker-compose.yml --profile client up -d
```

## 服务信息

- **HTTP 接口**: http://localhost:8123
- **TCP 接口**: localhost:9000
- **MySQL 兼容接口**: localhost:9004
- **PostgreSQL 兼容接口**: localhost:9005

## 默认用户

- **default**: 无密码，仅限访问 default 数据库
- **admin**: 密码 `admin123`，具有管理权限

## 连接方式

### 使用 HTTP 接口
```bash
curl "http://localhost:8123?query=SELECT%20version()"
```

### 使用 ClickHouse 客户端
```bash
# 连接到容器内的客户端
docker exec -it clickhouse-client clickhouse-client --host clickhouse-server

# 或者使用本地 clickhouse-client 连接
clickhouse-client --host localhost --port 9000
```

### 使用 MySQL 客户端
```bash
mysql -h localhost -P 9004 -u default -p
```

## 配置文件

- `config.xml`: ClickHouse 服务器配置
- `users.xml`: 用户和权限配置

## 数据持久化

数据存储在 Docker volume 中：
- `clickhouse_data`: 数据文件
- `clickhouse_logs`: 日志文件

## 健康检查

服务包含健康检查，可通过以下命令查看状态：
```bash
docker-compose -f clickhouse-docker-compose.yml ps
```

## 停止服务
```bash
docker-compose -f clickhouse-docker-compose.yml down
```

## 清理数据
```bash
docker-compose -f clickhouse-docker-compose.yml down -v
```