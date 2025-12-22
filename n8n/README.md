# n8n 工作流自动化平台

基于 Docker Compose 部署的 n8n 工作流自动化平台，使用 PostgreSQL 作为数据库，并配置了外部任务运行器（Task Runners）以支持 JavaScript 和 Python 代码执行。

## 架构组件

- **n8n**: 主要的工作流自动化服务（端口 5678）
- **PostgreSQL**: 数据库服务（端口 5432）
- **Task Runners**: 外部代码执行环境
  - JavaScript Runner（健康检查端口 5681）
  - Python Runner（健康检查端口 5682）

## 快速开始

### 1. 启动服务

```bash
docker-compose up -d
```

### 2. 访问 n8n

打开浏览器访问：http://localhost:5678

默认登录信息：
- 用户名：`admin`
- 密码：`admin_password`

## 配置说明

### 端口分配

| 服务 | 端口 | 说明 |
|------|------|------|
| n8n Web 界面 | 5678 | n8n 的 Web 管理界面 |
| n8n Broker | 5679 | n8n 与任务运行器通信端口 |
| PostgreSQL | 5432 | 数据库服务 |
| JavaScript Runner | 5681 | JavaScript 运行器健康检查 |
| Python Runner | 5682 | Python 运行器健康检查 |

### 环境变量配置

主要配置项位于 `docker-compose.yml` 文件中：

#### n8n 服务配置
- `NODE_ENV=production`: 生产环境模式
- `N8N_RUNNERS_ENABLED=true`: 启用任务运行器
- `N8N_RUNNERS_MODE=external`: 使用外部任务运行器
- `N8N_BASIC_AUTH_ACTIVE=true`: 启用基础认证
- `N8N_BASIC_AUTH_USER=admin`: 管理员用户名
- `N8N_BASIC_AUTH_PASSWORD=admin_password`: 管理员密码

#### 数据库配置
- 数据库名：`n8n`
- 用户名：`n8n`
- 密码：`n8n_password`

### 任务运行器配置

任务运行器的配置文件位于 `n8n-task-runners.json`：

```json
{
  "task-runners": [
    {
      "runner-type": "javascript",
      "health-check-server-port": "5681",
      "env-overrides": {
        "NODE_FUNCTION_ALLOW_BUILTIN": "crypto",
        "NODE_FUNCTION_ALLOW_EXTERNAL": "moment,uuid"
      }
    },
    {
      "runner-type": "python",
      "health-check-server-port": "5682",
      "env-overrides": {
        "PYTHONPATH": "/opt/runners/task-runner-python",
        "N8N_RUNNERS_STDLIB_ALLOW": "json"
      }
    }
  ]
}
```

## 自定义任务运行器镜像

如果需要添加额外的 Python 或 JavaScript 依赖包，可以构建自定义的运行器镜像：

```bash
# 构建自定义镜像
docker buildx build \
  -f Dockerfile \
  -t n8nio/runners:custom \
  .
docker buildx build \
  -f Dockerfile.n8n \
  -t n8nio/n8n:2.0.2-custom \
  .
```

在 Dockerfile 中可以添加所需的依赖：

```dockerfile
FROM n8nio/runners:2.0.2
USER root
# 安装 JavaScript 依赖
RUN cd /opt/runners/task-runner-javascript && pnpm add moment uuid
# 安装 Python 依赖
RUN cd /opt/runners/task-runner-python && uv pip install numpy pandas
# 复制配置文件
COPY n8n-task-runners.json /etc/n8n-task-runners.json
USER runner
```

## 数据持久化

数据通过 Docker 卷进行持久化：
- `n8n_data`: 存储 n8n 的工作流、凭证和执行历史
- `postgres_data`: 存储 PostgreSQL 数据库文件

## 常用命令

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f n8n
docker-compose logs -f task-runners

# 重启服务
docker-compose restart n8n
docker-compose restart task-runners

# 停止所有服务
docker-compose down

# 完全停止并删除数据卷（谨慎使用）
docker-compose down -v
```

## 安全建议

1. **修改默认密码**：
   - 修改 `N8N_BASIC_AUTH_PASSWORD` 的默认值
   - 修改数据库密码 `POSTGRES_PASSWORD`

2. **启用加密**：
   - 设置 `N8N_ENCRYPTION_KEY` 环境变量来加密敏感数据

3. **网络安全**：
   - 在生产环境中考虑使用 HTTPS
   - 限制数据库端口的访问

## 故障排查

### 任务运行器无法连接

1. 确认 `N8N_RUNNERS_TASK_BROKER_URI` 指向正确的容器名称
2. 检查端口是否冲突
3. 验证认证令牌是否一致

### 端口冲突

如果遇到端口冲突，可以修改 docker-compose.yml 中的端口映射，确保：
- n8n Broker 使用 5679
- JavaScript Runner 使用 5681 或更高
- Python Runner 使用 5682 或更高

## 更多信息

- [n8n 官方文档](https://docs.n8n.io/)
- [n8n GitHub 仓库](https://github.com/n8n-io/n8n)
- [n8n Task Runners 配置指南](https://docs.n8n.io/hosting/configuration/task-runners/)