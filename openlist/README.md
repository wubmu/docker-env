# OpenList 部署说明

## 版本说明

当前使用的 OpenList 镜像版本为 **v4.1.10**，属于 **v4.1.0 及以后版本**。

**重要**：v4.1.0 及以后版本不再支持通过环境变量配置数据库，必须使用配置文件。

## 新部署步骤

### 1. 准备配置文件

首次部署前，需要准备配置文件：

```bash
# 复制模板
cp config.json.template openlist-data/config.json

# 根据需要修改配置（主要是数据库密码和 SITE_URL）
vi openlist-data/config.json
```

### 2. 修改 .env 文件

确保 `.env` 文件中的数据库密码与 `config.json` 中一致：

```env
POSTGRES_DB=openlist
POSTGRES_USER=openlist
POSTGRES_PASSWORD=your_secure_password_here
TZ=Asia/Shanghai
SITE_URL=https://openlist.2wahaha.top
```

### 3. 启动服务

```bash
docker-compose up -d
```

## 配置文件说明

- `database.type`: 数据库类型，设置为 `postgres`
- `database.host`: 数据库主机，使用 Docker 网络名 `db`
- `database.port`: 数据库端口，默认 `5432`
- `database.user`: 数据库用户名
- `database.password`: 数据库密码
- `database.name`: 数据库名
- `database.ssl_mode`: SSL 模式，Docker 内部网络可设置为 `disable`
- `site_url`: 站点 URL，用于反向代理

## 常见问题

### Q: 为什么环境变量不生效？

A: v4.1.0 及以后版本不再支持通过环境变量配置数据库，必须使用 `config.json` 文件。

### Q: 如何使用环境变量方式部署？

A: 需要使用 v4.1.0 以前的镜像，例如：
```yaml
image: openlistteam/openlist:v4.0.9
```

### Q: 初始管理员密码是什么？

A: 首次启动后，密码会在日志中显示，请查看：
```bash
docker logs openlist | grep "admin user"
```

## 参考资料

- [OpenList 官方文档](https://doc.oplist.org/configuration/configuration)
- [render部署最新版openlist教程](https://linux.do/t/topic/1031701)
