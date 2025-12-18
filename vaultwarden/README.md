# Vaultwarden (配合 Nginx Proxy Manager)

本项目使用 Docker Compose 部署 [Vaultwarden](https://github.com/dani-garcia/vaultwarden)，一个与 Bitwarden 兼容的轻量级服务端。

此配置专门用于配合已有的 Nginx Proxy Manager (NPM) 实例使用。

## 部署步骤

### 1. 确认 NPM 的 Docker 网络名称

-   在您的服务器上运行 `docker network ls` 命令，找到 NPM 正在使用的网络名称。通常可能是 `npm_default`、`npm_network` 或者您自定义的名称。
-   **修改 `docker-compose.yml` 文件**，将末尾的 `name: npm_network` 替换为您找到的实际网络名称。

### 2. 修改管理员令牌

-   在 `docker-compose.yml` 文件中，将 `ADMIN_TOKEN` 的值 `replace_this_with_a_very_secure_random_token` 修改为一个**长而随机的安全字符串**。
-   这个令牌将用于访问后台管理页面 (`https://您的域名/admin`)。

### 3. 启动 Vaultwarden 服务

-   在当前目录下运行命令：
    ```bash
    docker compose up -d
    ```

### 4. 在 Nginx Proxy Manager 中配置反向代理

1.  登录您的 NPM 管理界面。
2.  进入 `Hosts` -> `Proxy Hosts`，点击 `Add Proxy Host`。
3.  填写以下信息：
    -   **Domain Names**: 输入您想用于 Vaultwarden 的域名 (例如 `bitwarden.yourdomain.com`)。
    -   **Scheme**: `http`
    -   **Forward Hostname / IP**: `vaultwarden` (即 `docker-compose.yml` 中定义的 `container_name`)。
    -   **Forward Port**: `80`
    -   **启用 `Websockets support`** (非常重要！)。
4.  切换到 `SSL` 选项卡。
5.  在 `SSL Certificate` 下拉菜单中，选择 `Request a new SSL certificate`。
6.  **启用 `Force SSL`**。
7.  点击 `Save`。

完成！现在您应该可以通过您的域名访问 Vaultwarden，并且拥有一个安全的 HTTPS 连接。
