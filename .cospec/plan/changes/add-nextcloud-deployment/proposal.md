# 变更：添加 Nextcloud Docker Compose 部署配置

## 原因
用户需要部署 Nextcloud 私有云存储服务，基于 PostgreSQL 数据库（性能更优）、Redis 缓存（提升性能）以及集成 Nginx Proxy Manager 反向代理，用于开发/测试环境快速启动。

## 变更内容
- 创建 `nextcloud/` 目录结构，遵循项目现有的服务组织规范
- 创建 `docker-compose.yml`，包含以下服务：
  - **Nextcloud 应用服务**：使用官方 Nextcloud 镜像，挂载数据目录，配置 PostgreSQL 连接和 Redis 缓存
  - **PostgreSQL 数据库服务**：使用 PostgreSQL 14-alpine 镜像，配置健康检查，挂载数据卷
  - **Redis 缓存服务**：使用 Redis 7-alpine 镜像，配置密码认证，提升 Nextcloud 性能
  - **网络配置**：创建独立网络 `nextcloud-network`，同时连接到外部网络 `npm_network` 实现反向代理
- 创建 `.env` 环境变量文件，集中管理敏感信息（数据库密码、管理员账户、Redis 密码等）
- 创建 `README.md` 文档，包含快速启动指南、配置说明、常用命令和注意事项
- 配置健康检查（PostgreSQL 和 Redis）确保服务依赖关系
- 配置重启策略为 `unless-stopped` 符合项目规范

## 影响
- **受影响的规范**：新增 Nextcloud 服务规范，遵循项目统一的 Docker Compose 配置模式
- **受影响的代码**：
  - `nextcloud/docker-compose.yml`：定义 Nextcloud、PostgreSQL、Redis 三个服务及其网络配置
  - `nextcloud/.env`：存储环境变量，包括数据库连接信息、管理员账户、Redis 密码等
  - `nextcloud/README.md`：提供部署文档，包含快速启动、配置说明、端口信息等
