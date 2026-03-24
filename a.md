```
#【修改代理信息】
bbc_device_api bbc_config --cmd set_proxy_config \
    --proxy_enabled 1 \
    --proxy_type 1 \
    --proxy_host 192.168.1.100 \
    --proxy_port 1080 \
    --proxy_timeout 30 \
    --proxy_username admin \
    --proxy_password password123


bbc_device_api bbc_config --cmd get_proxy_config 
```

| 参数 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `--proxy_enabled` | int | 是否启用代理 | 0=禁用, 1=启用 |
| `--proxy_type` | int | 代理类型 | 1=SOCKS5, 2=HTTP_CONNECT, 3=HTTPS_CONNECT|
| `--proxy_host` | string | 代理服务器地址 | 192.168.1.100 |
| `--proxy_port` | int | 代理服务器端口 | 1080 |
| `--proxy_username` | string | 代理用户名 | admin |
| `--proxy_password` | string | 代理密码 | password123 |
| `--proxy_timeout` | int | 代理连接超时（秒） | 30 |
| `--proxy_fallback_direct` | int | 是否fallback直连 | 0=否, 1=是 |
```