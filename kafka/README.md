
# Kafka 集群 Docker 环境

这是一个基于 Docker Compose 的 Kafka 集群环境配置，包含了三个 Kafka broker 节点、一个 ZooKeeper 服务器和一个 Kafka UI 管理界面。该配置适用于本地开发和测试环境。

## 环境要求

- Docker Engine 20.10.0 或更高版本
- Docker Compose v2.0.0 或更高版本
- 至少 4GB 可用内存
- 至少 10GB 可用磁盘空间

## 架构组件

- **ZooKeeper**: 用于集群协调和管理
- **Kafka Broker**: 3个节点的 Kafka 集群
- **Kafka UI**: Web界面管理工具

## 端口说明

- ZooKeeper: 2181
- Kafka Broker 1: 9092 (内部), 19092 (外部)
- Kafka Broker 2: 9093 (内部), 19093 (外部)
- Kafka Broker 3: 9094 (内部), 19094 (外部)
- Kafka UI: 8080

## 快速开始

### 1. 启动集群

在包含 `docker-compose.yml` 的目录中运行：

```bash
docker-compose up -d
```

### 2. 验证服务状态

```bash
docker-compose ps
```

### 3. 访问 Kafka UI

打开浏览器访问：http://localhost:8080

## 使用说明

### 连接到 Kafka 集群

- 从容器内部连接：
  - Bootstrap Servers: `kafka1:9092,kafka2:9093,kafka3:9094`

- 从主机连接：
  - Bootstrap Servers: `localhost:19092,localhost:19093,localhost:19094`

### 数据持久化

数据和日志文件被持久化到以下目录：

- ZooKeeper 数据: `./zk-data`
- ZooKeeper 日志: `./zk-logs`
- Kafka 数据: 
  - `./kafka1-data`
  - `./kafka2-data`
  - `./kafka3-data`

## 配置说明

### ZooKeeper 配置

- 客户端端口: 2181
- Tick Time: 2000ms

### Kafka 配置

每个 Kafka broker 都配置了：

- 自动创建主题功能
- 复制因子为3
- PLAINTEXT 监听器用于内部通信
- PLAINTEXT_HOST 监听器用于外部访问

## 常见问题

### 1. 服务无法启动

检查端口占用：
```bash
netstat -ano | findstr "2181 9092 9093 9094 19092 19093 19094 8080"
```

### 2. 数据目录权限问题

确保当前用户对数据目录有读写权限：
```bash
chmod -R 777 ./zk-data ./zk-logs ./kafka1-data ./kafka2-data ./kafka3-data
```

## 停止和清理

### 停止服务

```bash
docker-compose down
```

### 完全清理（包括数据）

```bash
docker-compose down -v
rm -rf ./zk-data ./zk-logs ./kafka*-data
```

## 安全建议

当前配置适用于开发环境，如果要用于生产环境，建议：

1. 启用 SSL/TLS 加密
2. 配置访问控制和认证
3. 调整 JVM 参数和性能参数
4. 配置适当的日志清理策略

## 主题管理

### 创建新主题

可以通过以下两种方式创建主题：

1. 使用 Kafka UI 界面创建
   - 访问 http://localhost:8080
   - 在界面上选择创建主题选项

2. 使用命令行创建
   ```bash
   # 进入kafka1容器
   docker exec -it kafka1 bash

   # 创建主题（3个分区，3个副本）
   kafka-topics --create --topic 测试主题 --bootstrap-server kafka1:9092 --partitions 3 --replication-factor 3

   # 列出所有主题
   kafka-topics --list --bootstrap-server kafka1:9092
   ```

### 查看主题详细信息

```bash
kafka-topics --describe --topic 测试主题 --bootstrap-server kafka1:9092
```

### 发送消息到主题

```bash
kafka-console-producer --broker-list kafka1:9092 --topic 测试主题
```

### 消费主题消息

```bash
kafka-console-consumer --bootstrap-server kafka1:9092 --topic 测试主题
```

## 许可证

MIT License