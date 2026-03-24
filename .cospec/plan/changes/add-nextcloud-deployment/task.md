## 实施

- [x] 1.1 创建 Nextcloud 服务目录结构
  【目标对象】`nextcloud/` 目录
  【修改目的】建立 Nextcloud 服务的基础目录，遵循项目现有的服务组织规范
  【修改方式】新增独立的 Nextcloud 服务目录
  【相关依赖】参考 `vaultwarden/`、`redis/`、`n8n/` 的目录结构
  【修改内容】
  - 在项目根目录下创建 `nextcloud/` 目录
  - 确保目录结构与项目现有服务保持一致（参考 redis、vaultwarden 等服务）
  - 注意：目录创建后才能进行后续文件创建

- [x] 1.2 创建环境变量配置文件
  【目标对象】`nextcloud/.env` 文件
  【修改目的】集中管理敏感信息和可配置参数，避免硬编码
  【修改方式】新增环境变量文件，使用键值对格式定义
  【相关依赖】参考 `redis/.env` 的实现模式
  【修改内容】
  - 配置 Nextcloud 管理员账户：
    - `NEXTCLOUD_ADMIN_USER=admin`（默认管理员用户名）
    - `NEXTCLOUD_ADMIN_PASSWORD=changeme`（默认密码，需要用户修改）
  - 配置 PostgreSQL 数据库连接信息：
    - `POSTGRES_DB=nextcloud`（数据库名）
    - `POSTGRES_USER=nextcloud`（数据库用户名）
    - `POSTGRES_PASSWORD=nextcloud_db_password`（数据库密码）
    - `POSTGRES_ROOT_PASSWORD=root_password`（root 密码）
  - 配置 Redis 缓存：
    - `REDIS_PASSWORD=redis_password`（Redis 密码，避免特殊字符如 `$`、`#`、`!`）
  - 配置时区：`TZ=Asia/Shanghai`
  - 每个变量上方添加注释说明用途
  - 边界处理：文件顶部添加警告注释，提醒用户修改默认密码
  - 错误处理：.env 文件必须存在，否则 docker-compose 会报错

- [x] 1.3 创建 Docker Compose 配置文件 - 定义版本和网络
  【目标对象】`nextcloud/docker-compose.yml` 文件的顶层配置部分
  【修改目的】定义 Nextcloud 部署的版本和网络配置
  【修改方式】新增 docker-compose.yml 文件，定义版本和网络部分
  【相关依赖】
  - 参考 `vaultwarden/docker-compose.yml:16-24` 的外部网络配置
  - 参考 `redis/docker-compose.yml:46-48` 的独立网络配置
  【修改内容】
  - 文件顶部指定 `version: '3.8'`
  - 在 `networks:` 节点下定义两个网络：
    - `nextcloud-network`：独立网络（driver: bridge），用于内部服务通信
    - `npm_network`：外部网络（external: true, name: npm_network），用于连接 Nginx Proxy Manager
  - 边界处理：npm_network 必须在外部预先创建，否则启动失败
  - 注意：此任务只创建文件骨架和网络配置，不包含 services 定义

- [x] 1.4 配置 PostgreSQL 数据库服务
  【目标对象】`nextcloud/docker-compose.yml` 文件的 `services:` 节点下的 `db:` 服务定义
  【修改目的】为 Nextcloud 提供高性能数据库支持
  【修改方式】在 services 节点下新增 `db` 服务定义
  【相关依赖】
  - 参考 `redis/docker-compose.yml:26-32` 的健康检查配置
  - 参考 `clickhouse/docker-compose.yml:20-24` 的数据卷挂载
  【修改内容】
  - 服务名：`db`
  - 镜像：`postgres:14-alpine`（使用 alpine 版本减小镜像体积）
  - 容器名：`nextcloud-db`
  - 重启策略：`unless-stopped`（符合项目规范）
  - 环境变量（引用 .env 文件）：
    - `POSTGRES_DB: ${POSTGRES_DB}`
    - `POSTGRES_USER: ${POSTGRES_USER}`
    - `POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}`
  - 数据卷：`./postgres-data:/var/lib/postgresql/data`（本地目录自动创建）
  - 健康检查配置：
    - test: `["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]`
    - interval: 30s
    - timeout: 10s
    - retries: 3
    - start_period: 40s（给予数据库足够的启动时间）
  - 网络：只连接到 `nextcloud-network`（不需要外部网络）
  - 注意：环境变量必须在 .env 文件中定义，否则服务启动失败

- [x] 1.5 配置 Redis 缓存服务
  【目标对象】`nextcloud/docker-compose.yml` 文件的 `services:` 节点下的 `redis:` 服务定义
  【修改目的】为 Nextcloud 提供缓存服务，提升文件锁和会话管理性能
  【修改方式】在 services 节点下新增 `redis` 服务定义
  【相关依赖】参考 `redis/docker-compose.yml` 的实现模式
  【修改内容】
  - 服务名：`redis`
  - 镜像：`redis:7-alpine`（使用最新稳定版 alpine 镜像）
  - 容器名：`nextcloud-redis`
  - 重启策略：`unless-stopped`
  - 启动命令：`redis-server --requirepass ${REDIS_PASSWORD}`（密码认证）
  - 健康检查配置：
    - test: `["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]`
    - interval: 30s
    - timeout: 10s
    - retries: 3
    - start_period: 10s
  - 网络：只连接到 `nextcloud-network`
  - 边界处理：Redis 密码不应包含特殊字符（如 `$`、`#`、`!`），避免 shell 解析错误
  - 注意：Redis 无需数据持久化（使用内存缓存即可）

- [x] 1.6 配置 Nextcloud 应用服务
  【目标对象】`nextcloud/docker-compose.yml` 文件的 `services:` 节点下的 `nextcloud:` 服务定义
  【修改目的】定义 Nextcloud 核心应用服务，集成数据库和缓存
  【修改方式】在 services 节点下新增 `nextcloud` 服务定义
  【相关依赖】参考 `vaultwarden/docker-compose.yml` 的配置模式
  【修改内容】
  - 服务名：`nextcloud`
  - 镜像：`nextcloud:latest`（适用于开发/测试环境，生产环境建议指定版本）
  - 容器名：`nextcloud`
  - 重启策略：`unless-stopped`
  - 端口映射：`8080:80`（避免与主机 80 端口冲突）
  - 环境变量配置：
    - PostgreSQL 连接：
      - `POSTGRES_DB: ${POSTGRES_DB}`
      - `POSTGRES_USER: ${POSTGRES_USER}`
      - `POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}`
      - `POSTGRES_HOST: db`（使用服务名作为主机名）
    - 管理员账户：
      - `NEXTCLOUD_ADMIN_USER: ${NEXTCLOUD_ADMIN_USER}`
      - `NEXTCLOUD_ADMIN_PASSWORD: ${NEXTCLOUD_ADMIN_PASSWORD}`
    - Redis 配置：
      - `REDIS_HOST: redis`（使用服务名）
      - `REDIS_HOST_PASSWORD: ${REDIS_PASSWORD}`（注意：密码不应包含特殊字符）
    - 时区：`TZ: ${TZ}`
  - 数据卷配置（三个挂载点）：
    - `./nextcloud-data:/var/www/html`（主数据目录）
    - `./nextcloud-apps:/var/www/html/custom_apps`（自定义应用目录）
    - `./nextcloud-config:/var/www/html/config`（配置文件目录）
  - 依赖关系配置：
    - 使用 `depends_on` 配置服务依赖
    - 添加 `condition: service_healthy` 确保 db 和 redis 健康检查通过后才启动
  - 网络配置：同时连接到两个网络
    - `nextcloud-network`（内部通信）
    - `npm_network`（反向代理访问）
  - 边界处理：
    - 首次启动需要初始化数据库，耗时 1-2 分钟
    - Redis 密码中的特殊字符可能导致连接失败
  - 错误处理：如果 db 或 redis 健康检查失败，nextcloud 服务不会启动

- [x] 1.7 创建 README 文档
  【目标对象】`nextcloud/README.md` 文件
  【修改目的】提供完整的部署说明和使用指南，降低使用门槛
  【修改方式】新增 README.md 文件，遵循项目现有文档规范
  【相关依赖】参考 `redis/README.md` 和 `vaultwarden/README.md` 的文档结构
  【修改内容】
  - 标题：Nextcloud 私有云存储服务
  - 简介：说明 Nextcloud 的用途和特性
  - 快速启动指南：
    - 步骤 1：修改 .env 文件中的默认密码
    - 步骤 2：运行 `docker-compose up -d` 启动服务
    - 步骤 3：访问 `http://localhost:8080` 完成初始化
  - 端口分配表：
    - 8080：Nextcloud Web 界面
    - 5432：PostgreSQL 数据库（仅内部访问）
    - 6379：Redis 缓存（仅内部访问）
  - 环境变量配置说明：
    - 列出所有环境变量及其用途
    - 强调必须修改默认密码
  - 数据持久化说明：
    - 说明三个数据目录的作用（postgres-data、nextcloud-data、nextcloud-apps、nextcloud-config）
  - 常用命令：
    - 启动：`docker-compose up -d`
    - 停止：`docker-compose down`
    - 查看日志：`docker-compose logs -f nextcloud`
    - 重启：`docker-compose restart`
  - 注意事项：
    - 首次启动需要初始化数据库（约 1-2 分钟），请耐心等待
    - Nginx Proxy Manager 集成配置指南（配置域名、SSL 证书）
    - 开发/测试环境安全建议（修改默认密码、限制外部访问）
    - 生产环境需额外加固（启用 HTTPS、配置防火墙、定期备份）
