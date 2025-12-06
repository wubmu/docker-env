# ClickHouse Docker 单机部署

本目录包含ClickHouse单机部署的Docker Compose配置文件和相关配置。

## 目录结构

```
clickhouse/
├── docker-compose.yml     # Docker Compose配置文件
├── config/
│   ├── config.xml        # ClickHouse服务配置
│   └── users.xml         # 用户和权限配置
├── data/                 # ClickHouse数据目录（挂载后自动创建）
├── logs/                 # ClickHouse日志目录（挂载后自动创建）
└── README.md            # 本文档
```

## 快速启动

### 1. 启动ClickHouse服务

```bash
cd clickhouse
docker-compose up -d
```

### 2. 验证服务状态

```bash
# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f clickhouse

# 检查服务健康状态
curl http://localhost:8123/ping
```

### 3. 连接ClickHouse

#### HTTP接口

```bash
# 使用curl
curl "http://localhost:8123?query=SELECT version()"

# 使用HTTP客户端
GET http://localhost:8123?query=SELECT%20version()
```

#### TCP接口

```bash
# 使用官方客户端（需要安装clickhouse-client）
clickhouse-client --host=localhost --port=9000

# 使用Docker客户端容器
docker-compose run --rm clickhouse-client clickhouse-client --host=clickhouse-server --port=9000
```

#### MySQL兼容接口

```bash
# 使用MySQL客户端
mysql -h localhost -P 9004 -u default -p
```

#### PostgreSQL兼容接口

```bash
# 使用PostgreSQL客户端
psql -h localhost -p 9005 -U default
```

## 默认用户账号

| 用户名 | 密码 | 权限 | 说明 |
|--------|------|------|------|
| default | 空 | 完整权限 | 默认用户，无密码 |
| admin | admin | 完整权限 | 管理员用户 |
| readonly_user | readonly_pass | 只读 | 只读用户 |
| write_user | write_pass | 写入优化 | 数据写入用户 |

### 密码修改

修改密码需要更新`users.xml`中的密码配置，可以使用SHA256哈希值：

```bash
# 生成密码哈希（需要clickhouse-server）
echo -n "your_password" | sha256sum | tr -d '-'

# 或使用Docker
docker run --rm --entrypoint clickhouse-server clickhouse/clickhouse-server:latest password-hash
```

## 配置说明

### 端口配置

- **8123**: HTTP接口
- **9000**: 原生TCP接口
- **9004**: MySQL兼容接口
- **9005**: PostgreSQL兼容接口

### 数据持久化

- **数据目录**: `./data` -> `/var/lib/clickhouse`
- **日志目录**: `./logs` -> `/var/log/clickhouse-server`

### 重要配置项

1. **内存限制**: 默认设置10GB
2. **并发查询**: 最大100个并发
3. **时区**: Asia/Shanghai
4. **数据压缩**: 启用LZ4压缩
5. **日志级别**: information

## 常用操作

### 创建数据库

```sql
CREATE DATABASE my_database;
```

### 创建表

```sql
-- MergeTree引擎示例表
CREATE TABLE my_database.events (
    event_id UInt64,
    event_date Date,
    event_time DateTime,
    user_id UInt64,
    event_type String,
    event_data String
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time, event_id);
```

### 插入数据

```sql
INSERT INTO my_database.events VALUES
(1, today(), now(), 1001, 'login', '{"ip": "127.0.0.1"}'),
(2, today(), now(), 1002, 'click', '{"page": "home"}');
```

### 查询数据

```sql
SELECT * FROM my_database.events LIMIT 10;
```

### 导入数据

```bash
# 从CSV文件导入
cat data.csv | curl 'http://localhost:8123/?query=INSERT INTO my_database.events FORMAT CSV' --data-binary @-

# 使用Docker
docker exec -i clickhouse-server clickhouse-client --query="INSERT INTO my_database.events FORMAT CSV" < data.csv
```

### 导出数据

```bash
# 导出为CSV
curl 'http://localhost:8123/?query=SELECT%20*%20FROM%20my_database.events%20FORMAT%20CSV' > export.csv

# 使用Docker
docker exec clickhouse-server clickhouse-client --query="SELECT * FROM my_database.events FORMAT CSV" > export.csv
```

## 监控和日志

### 查看系统表

```sql
-- 查看活跃查询
SELECT * FROM system.processes;

-- 查看查询日志
SELECT * FROM system.query_log ORDER BY event_time DESC LIMIT 10;

-- 查看表信息
SELECT * FROM system.tables WHERE database = 'my_database';

-- 查看分区信息
SELECT * FROM system.parts WHERE database = 'my_database' AND table = 'events';
```

### 日志位置

- ClickHouse服务器日志: `./logs/clickhouse-server.log`
- 错误日志: `./logs/clickhouse-server.err.log`

## 性能优化建议

### 1. 内存配置

根据服务器内存调整`config.xml`中的内存限制：

```xml
<max_memory_usage>20000000000</max_memory_usage>  <!-- 20GB -->
```

### 2. 并发配置

```xml
<max_threads>16</max_threads>  <!-- CPU核心数 -->
```

### 3. 磁盘配置

使用SSD存储，确保充足的磁盘空间。

### 4. 网络配置

确保网络带宽充足，避免跨机房部署。

## 安全配置

### 1. 修改默认密码

修改`users.xml`中的默认密码配置。

### 2. 限制网络访问

通过Docker网络或防火墙限制访问。

### 3. 启用SSL/TLS

在`config.xml`中配置SSL证书。

## 故障排查

### 1. 容器无法启动

```bash
# 检查日志
docker-compose logs clickhouse

# 检查端口占用
netstat -tlnp | grep 8123
```

### 2. 连接超时

- 检查防火墙设置
- 确认端口映射正确
- 查看容器健康状态

### 3. 查询性能问题

- 检查系统表中的查询日志
- 分析查询执行计划
- 调整内存和线程配置

## 停止服务

```bash
# 停止服务
docker-compose down

# 停止并删除数据（谨慎操作）
docker-compose down -v
```

## 升级版本

1. 备份数据
2. 修改`docker-compose.yml`中的镜像版本
3. 重启服务

```bash
# 备份
docker-compose exec clickhouse-server clickhouse-client --query="BACKUP TABLE my_database.events TO Disk('backups', 'events_backup')"

# 升级
docker-compose pull
docker-compose up -d
```