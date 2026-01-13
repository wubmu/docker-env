# Redis Docker 环境

## 快速启动

```bash
cd redis
docker-compose up -d
```

## 连接 Redis

```bash
redis-cli -h 127.0.0.1 -p 6379
```

## 常用命令

- 启动: `docker-compose up -d`
- 停止: `docker-compose down`
- 查看日志: `docker-compose logs -f`
- 重启: `docker-compose restart`

## 数据持久化

数据会保存在 `./data` 目录中，即使容器重启数据也不会丢失。

## 端口

- Redis 端口: 6379

## 安全配置

1. **密码设置**: 修改 `.env` 文件中的 `REDIS_PASSWORD` 值
2. **配置文件**: 如需自定义配置，取消 `docker-compose.yml` 中配置文件的注释
3. **生产环境**: 建议限制访问 IP，使用内网网络