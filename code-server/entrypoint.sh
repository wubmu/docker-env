#!/bin/sh
# 通过 ENTRYPOINTD 机制在 code-server 启动前修正 home 目录权限
chown -R coder:coder /home/coder 2>/dev/null
