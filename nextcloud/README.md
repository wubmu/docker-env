# Nextcloud 私有云存储服务

## 简介

Nextcloud 是一套开源的私有云存储解决方案，提供文件同步与共享、日历、联系人、在线办公等功能。本配置使用 PostgreSQL 数据库和 Redis 缓存，性能更优，并集成了 Nginx Proxy Manager 反向代理支持。

## 快速启动

### 1. 修改默认密码

**⚠️ 重要：首次启动前必须修改 `.env` 文件中的默认密码！**

```bash
cd nextcloud
# 编辑 .env 文件，修改以下密码：
# - NEXTCLOUD_ADMIN_PASSWORD (Nextcloud 管理员密码)
# - POSTGRES_PASSWORD (PostgreSQL 数据库密码)
# - POSTGRES_ROOT_PASSWORD (PostgreSQL root 密码)
# - REDIS_PASSWORD (Redis 缓存密码)
```

### 2. 启动服务

```bash
docker-compose up -d
```

### 3. 访问服务

打开浏览器访问：`http://localhost:8080`

- 首次启动需要初始化数据库，请耐心等待 1-2 分钟
- 使用 `.env` 文件中配置的管理员账户登录

## 端口分配

| 服务 | 端口 | 说明 |
|------|------|------|
| Nextcloud | 8080 | Web 界面访问端口 |
| PostgreSQL | 5432 | 数据库端口（仅内部访问） |
| Redis | 6379 | 缓存端口（仅内部访问） |

## 环境变量配置

在 `.env` 文件中可以配置以下参数：

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| NEXTCLOUD_ADMIN_USER | admin | Nextcloud 管理员用户名 |
| NEXTCLOUD_ADMIN_PASSWORD | changeme | **必须修改**：管理员密码 |
| POSTGRES_DB | nextcloud | PostgreSQL 数据库名 |
| POSTGRES_USER | nextcloud | PostgreSQL 用户名 |
| POSTGRES_PASSWORD | nextcloud_db_password | **必须修改**：数据库密码 |
| POSTGRES_ROOT_PASSWORD | root_password | **必须修改**：PostgreSQL root 密码 |
| REDIS_PASSWORD | redis_password | **必须修改**：Redis 密码（不要使用特殊字符） |
| TZ | Asia/Shanghai | 时区设置 |

## 数据持久化

数据保存在以下目录中（位于 `nextcloud/` 目录下）：

- `postgres-data/`：PostgreSQL 数据库文件
- `nextcloud-data/`：Nextcloud 主数据目录（用户文件、应用等）
- `nextcloud-apps/`：自定义应用目录
- `nextcloud-config/`：配置文件目录

## 常用命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 查看日志
docker-compose logs -f nextcloud

# 查看所有服务日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 重启单个服务
docker-compose restart nextcloud

# 查看服务状态
docker-compose ps
```

## 注意事项

### 1. 首次启动

- 首次启动需要初始化数据库，大约需要 1-2 分钟
- 如果 Nextcloud 容器启动失败，请检查数据库和 Redis 是否已经健康运行：
  ```bash
  docker-compose ps
  ```

### 2. Nginx Proxy Manager 集成

本配置已集成 Nginx Proxy Manager 网络支持，如需配置域名和 HTTPS：

1. 确保 `npm_network` 已在外部创建（Nginx Proxy Manager 项目中）
2. 在 Nginx Proxy Manager 中添加代理主机：
   - 域名：您的域名（如 `cloud.example.com`）
   - 转发主机：`nextcloud`（容器名）
   - 转发端口：`80`
3. 配置 SSL 证书（推荐使用 Let's Encrypt）

### 3. 安全建议

**开发/测试环境：**
- 修改 `.env` 文件中的所有默认密码
- 限制外部访问（使用防火墙规则）
- 定期备份数据

**生产环境（额外加固）：**
- 使用固定的 Nextcloud 版本（修改 `docker-compose.yml` 中的镜像标签，如 `nextcloud:28`）
- 启用 HTTPS（通过 Nginx Proxy Manager）
- 配置防火墙，仅允许必要的访问
- 定期备份数据库和文件目录
- 配置邮件服务器（用于通知和密码重置）

### 4. Redis 密码注意事项

Redis 密码不应包含以下特殊字符，否则可能导致连接失败：
- `$`（美元符号）
- `#`（井号）
- `!`（感叹号）
- 其他可能被 shell 解释的特殊字符

推荐使用字母、数字和下划线组合。

## 故障排查

### 问题 1：Nextcloud 容器无法启动

**原因**：数据库或 Redis 未就绪

**解决方案**：
```bash
# 检查服务健康状态
docker-compose ps

# 查看数据库日志
docker-compose logs db

# 查看 Redis 日志
docker-compose logs redis
```

### 问题 2：npm_network 不存在错误

**原因**：Nginx Proxy Manager 网络未创建

**解决方案**：
- 如果不需要 Nginx Proxy Manager，可以删除 `docker-compose.yml` 中的 `npm_network` 相关配置
- 如果需要，请先启动 Nginx Proxy Manager 项目

### 问题 3：数据库连接失败

**原因**：环境变量配置错误或数据库未启动

**解决方案**：
```bash
# 检查 .env 文件是否存在
cat .env

# 重新启动数据库
docker-compose restart db

# 查看数据库健康状态
docker inspect nextcloud-db | grep -A 10 Health
```

## 更多资源

- [Nextcloud 官方文档](https://docs.nextcloud.com/)
- [Nextcloud Docker 镜像说明](https://hub.docker.com/_/nextcloud)
- [PostgreSQL 官方文档](https://www.postgresql.org/docs/)
- [Redis 官方文档](https://redis.io/documentation)
