# Elasticsearch 内存配置示例

## 1. 低内存配置（适用于 2GB RAM 服务器）
```yaml
environment:
  - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
```
- 总内存占用：约 800MB
- 堆内存：512MB
- 适合：小型项目、开发测试

## 2. 中等内存配置（适用于 4GB RAM 服务器）
```yaml
environment:
  - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
```
- 总内存占用：约 1.5GB
- 堆内存：1GB
- 适合：中小型生产环境

## 3. 较高内存配置（适用于 8GB RAM 服务器）
```yaml
environment:
  - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
```
- 总内存占用：约 3GB
- 堆内存：2GB
- 适合：中型生产环境

## 4. 高内存配置（适用于 16GB+ RAM 服务器）
```yaml
environment:
  - "ES_JAVA_OPTS=-Xms4g -Xmx4g"
```
- 总内存占用：约 6GB
- 堆内存：4GB
- 适合：大型生产环境

## 注意事项

1. **不要超过 31GB**
   - JVM 在超过 31GB 时会使用不同的压缩指针，导致性能下降
   - 建议最大设置为 31GB，或更保守的 30GB

2. **预留系统内存**
   - Elasticsearch 除了堆内存还需要其他内存
   - 文件系统缓存也很重要
   - 建议至少保留 1-2GB 给系统

3. **监控内存使用**
   ```bash
   # 查看 JVM 内存使用
   curl http://localhost:9200/_nodes/stats/jvm?pretty

   # 查看节点内存
   curl http://localhost:9200/_cat/nodes?v&h=name,ram.percent,heap.current,heap.percent
   ```

## 容器内存限制

为了更好地控制内存使用，可以在 docker-compose.yml 中添加内存限制：

```yaml
services:
  es-node1:
    # ... 其他配置
    deploy:
      resources:
        limits:
          memory: 2g
        reservations:
          memory: 1g
```

这将确保容器不会使用超过指定量的内存。