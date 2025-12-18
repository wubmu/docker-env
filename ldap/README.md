# OpenLDAP 环境

本项目使用 Docker Compose 快速搭建一个 OpenLDAP 服务。

## 包含的服务

1.  **OpenLDAP**: `osixia/openldap:1.5.0`
    -   核心 LDAP 服务。
2.  **phpLDAPadmin**: `osixia/phpldapadmin:0.9.0`
    -   一个用于管理 OpenLDAP 的 Web 用户界面。

## 如何使用

1.  **启动服务**:
    在当前目录下运行以下命令：
    ```bash
    docker compose up -d
    ```

2.  **访问服务**:
    -   LDAP 服务端口: `ldap://localhost:389`
    -   phpLDAPadmin 管理界面: [http://localhost:8080](http://localhost:8080)

## 默认配置和凭据

-   **登录 DN (Login DN)**: `cn=admin,dc=mycompany,dc=com`
-   **密码 (Password)**: `admin_password`

**重要**: 请务必在 `docker-compose.yml` 文件中修改 `LDAP_ADMIN_PASSWORD` 的默认值 `admin_password` 为一个更安全的密码。

## 数据持久化

-   LDAP 的数据和配置分别持久化在当前目录下的 `./data/ldap` 和 `./data/slapd.d` 文件夹中。
