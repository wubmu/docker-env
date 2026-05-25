# Code-Server Docker 部署踩坑记录

## 1. Nginx Proxy Manager WebSocket 转发

NPM 的 **Advanced** 配置注入的是 server 级别，不在 location 块内。WebSocket 头必须在 location 块里才生效。

**错误写法（NPM Advanced 注入后的结果）：**
```nginx
server {
    # 这里不生效
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection upgrade;

    location / {
        include conf.d/include/proxy.conf;
    }
}
```

**正确做法：** 直接改容器内的 `/data/nginx/proxy_host/<id>.conf`，把 WebSocket 头放到 location 块内：
```nginx
location / {
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection upgrade;
    include conf.d/include/proxy.conf;
}
```

> 修改后执行 `docker cp` + `nginx -t` + `nginx -s reload`。注意 NPM 重新保存配置时会覆盖手动修改。

## 2. code-server 反向代理必须设置 PROXY_DOMAIN

直连 IP 访问时不需要设置 `PROXY_DOMAIN`，但通过 Nginx 反向代理时**必须设置**为实际域名，否则 WebSocket 连接会失败。

```yaml
environment:
  - PROXY_DOMAIN=code.example.com  # 必须与实际访问域名一致
```

## 3. no-new-privileges 与 fixuid 冲突

`codercom/code-server` 基础镜像使用 fixuid 自动修正挂载卷的文件权限，fixuid 依赖 setuid 权位。`security_opt: no-new-privileges:true` 会禁止 setuid，导致容器无法启动。

**解决：** 去掉 `no-new-privileges`，或用 entrypoint 脚本在启动前手动 chown。

## 4. 绑定挂载目录权限问题

容器内 coder 用户 (UID 1000) 无法写入宿主机 root 创建的目录。两种解决方式：

- **entrypoint 脚本（推荐）：** 启动前自动 chown
```sh
#!/bin/sh
for dir in /home/coder/.config /home/coder/project; do
    [ -d "$dir" ] && chown -R coder:coder "$dir" 2>/dev/null
done
exec /usr/bin/entrypoint.sh --bind-addr 0.0.0.0:8080 "$@"
```

- **宿主机手动 chown：** `chown -R 1000:1000 ./config ./workspace`

## 5. 基础镜像 Debian 版本要匹配 apt 源

`codercom/code-server:latest` 底层系统会随版本更新（bullseye → trixie），apt 源地址必须匹配，否则 404。构建前先确认：

```dockerfile
RUN cat /etc/os-release  # 查看 PRETTY_NAME 确认版本
```

## 6. Dockerfile COPY 文件不存在会构建失败

`COPY file /tmp/` 在文件不存在时直接报错中止构建。用目录级 COPY 可以规避：

```dockerfile
# 空目录不会报错
COPY @offline-resource/ /tmp/offline/

# RUN 里判断具体文件
RUN if [ -f /tmp/offline/go.tar.gz ]; then ...; else echo "[WARNING] skip"; fi
```

## 7. 用 Build Args 实现选择性安装编译环境

通过 `.env` 文件控制，不用每次手动传参：

```yaml
# docker-compose.yml
build:
  args:
    INSTALL_NODEJS: ${INSTALL_NODEJS:-true}
    INSTALL_GO: ${INSTALL_GO:-true}
```

```bash
# .env 文件
INSTALL_NODEJS=true
INSTALL_GO=false

# 临时覆盖
INSTALL_GO=true docker compose up -d --build
```
