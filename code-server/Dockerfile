FROM codercom/code-server:latest

USER root


# apt更换阿里源
# 镜像里面没有sources.list文件，需要自己创建
RUN echo "deb http://mirrors.aliyun.com/debian/ bullseye main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian/ bullseye main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib" >> /etc/apt/sources.list

# 替换/etc/apt/sources.list.d/debian.list
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources


# 安装基础依赖
RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    gcc \
    g++ \
    make \
    python3 \
    python3-pip \
    sudo \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# docker镜像走http和https linux宿主机的代理 
RUN export http_proxy=http://172.17.0.1:7890 && \
    export https_proxy=http://172.17.0.1:7890 && \
    export no_proxy=localhost,127.0.0.1,*,internal




# 复制离线资源
COPY @offline-resource/nvm-0.39.5-install.sh /tmp/nvm-install.sh
COPY @offline-resource/go1.22.1.linux-amd64.tar.gz /tmp/go.tar.gz

# 安装 Node.js 22 使用本地nvm安装包
RUN bash /tmp/nvm-install.sh && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install 22 && \
    nvm use 22 && \
    nvm alias default 22 && \
    corepack enable pnpm


# RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
#     apt-get install -y nodejs && \
#     npm install -g npm@latest yarn@latest

# 安装 Go 1.22.1 使用本地文件
ENV GOPROXY=https://goproxy.cn,direct
ENV GO_VERSION 1.22.1
RUN tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# 配置环境变量
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH=/home/coder/go
ENV PATH="$GOPATH/bin:$PATH"

# 安装常用 Go 工具
RUN go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest && \
    go install honnef.co/go/tools/cmd/staticcheck@latest

# 配置用户环境
USER coder
WORKDIR /home/coder

# 初始化 Go 环境
RUN mkdir -p $GOPATH && \
    go version && \
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.bashrc

# 安装oh-my-zsh


# 安装常用 VS Code 扩展
RUN code-server --install-extension golang.go && \
    code-server --install-extension dbaeumer.vscode-eslint && \
    code-server --install-extension esbenp.prettier-vscode

EXPOSE 8080

ENTRYPOINT ["/usr/bin/entrypoint", "--bind-addr", "0.0.0.0:8080"]