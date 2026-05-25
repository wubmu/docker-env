FROM codercom/code-server:latest

# 构建参数：按需安装编译环境
ARG INSTALL_NODEJS=true
ARG INSTALL_GO=true
ARG INSTALL_GO_TOOLS=true

USER root


# apt更换阿里源
# 镜像里面没有sources.list文件，需要自己创建
RUN echo "deb http://mirrors.aliyun.com/debian/ trixie main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ trixie-updates main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian/ trixie main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian/ trixie-updates main non-free contrib" >> /etc/apt/sources.list

# 替换/etc/apt/sources.list.d/debian.list
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources


# 安装基础依赖（按需安装，build-essential 已包含 gcc/g++/make）
RUN apt-get update && \
    apt-get install -y git sudo curl wget python3 python3-pip && \
    if ! dpkg -l build-essential >/dev/null 2>&1; then apt-get install -y build-essential; fi && \
    rm -rf /var/lib/apt/lists/*

# 安装 Docker CLI（daemon 由 dind sidecar 提供）
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian trixie stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# docker镜像走http和https linux宿主机的代理
#RUN export http_proxy=http://172.17.0.1:7890 && \
 #   export https_proxy=http://172.17.0.1:7890 && \
  #  export no_proxy=localhost,127.0.0.1,*,internal




# 复制离线资源（目录为空时不会报错）
COPY @offline-resource/ /tmp/offline/

# 安装 Node.js 22
RUN if [ "$INSTALL_NODEJS" = "true" ]; then \
        if [ -f /tmp/offline/nvm-0.39.5-install.sh ]; then \
            bash /tmp/offline/nvm-0.39.5-install.sh && \
            export NVM_DIR="$HOME/.nvm" && \
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
            nvm install 22 && nvm use 22 && nvm alias default 22 && \
            corepack enable pnpm; \
        else \
            echo "[WARNING] nvm install script not found, skip Node.js installation"; \
        fi; \
    else \
        echo "[INFO] INSTALL_NODEJS=false, skip Node.js installation"; \
    fi


# RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
#     apt-get install -y nodejs && \
#     npm install -g npm@latest yarn@latest

# 安装 Go 1.22.1 使用本地文件
ENV GOPROXY=https://goproxy.cn,direct
ENV GO_VERSION 1.22.1
RUN if [ "$INSTALL_GO" = "true" ]; then \
        if [ -f /tmp/offline/go1.22.1.linux-amd64.tar.gz ]; then \
            tar -C /usr/local -xzf /tmp/offline/go1.22.1.linux-amd64.tar.gz && \
            rm /tmp/offline/go1.22.1.linux-amd64.tar.gz; \
        else \
            echo "[WARNING] go tarball not found, skip Go installation"; \
        fi; \
    else \
        echo "[INFO] INSTALL_GO=false, skip Go installation"; \
    fi

# 配置环境变量
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH=/home/coder/go
ENV PATH="$GOPATH/bin:$PATH"

# 安装常用 Go 工具（依赖 go 已安装）
RUN if [ "$INSTALL_GO_TOOLS" = "true" ] && command -v go >/dev/null 2>&1; then \
        go install golang.org/x/tools/cmd/goimports@latest && \
        go install github.com/go-delve/delve/cmd/dlv@latest && \
        go install honnef.co/go/tools/cmd/staticcheck@latest; \
    else \
        echo "[INFO] skip Go tools installation"; \
    fi

# 配置用户环境
RUN mkdir -p /home/coder/.config && chown -R coder:coder /home/coder

# 使用 ENTRYPOINTD 机制：启动前自动修正 home 目录权限
COPY entrypoint.sh /etc/entrypoint.d/chown-home.sh
RUN chmod +x /etc/entrypoint.d/chown-home.sh
ENV ENTRYPOINTD=/etc/entrypoint.d

USER coder
WORKDIR /home/coder

# 初始化 Go 环境
RUN mkdir -p $GOPATH && \
    if command -v go >/dev/null 2>&1; then go version; fi && \
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.bashrc

# 安装oh-my-zsh


# 安装常用 VS Code 扩展
RUN code-server --install-extension golang.go && \
    code-server --install-extension dbaeumer.vscode-eslint && \
    code-server --install-extension esbenp.prettier-vscode

EXPOSE 8080
