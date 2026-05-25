# Terminal 搭建记录

## 环境

- **系统**: Ubuntu 22.04 (Linux 5.15)
- **Shell**: zsh 5.8.1
- **平台**: Docker 容器

## 组件列表

### 1. Zsh

```bash
apt install zsh
chsh -s $(which zsh)
```

### 2. Oh-My-Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

- 配置文件: `~/.zshrc`
- 安装路径: `~/.oh-my-zsh`
- 已启用插件: `git`, `fzf`

### 3. Powerlevel10k 主题

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

- 配置文件: `~/.p10k.zsh`
- 重新配置: `p10k configure`

### 4. fzf - 模糊搜索

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
```

- 在 `~/.zshrc` 中 source: `[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh`
- 同时在 oh-my-zsh plugins 中启用了 `fzf` 插件
- 常用快捷键:
  - `Ctrl+R` - 模糊搜索历史命令
  - `Ctrl+T` - 模糊搜索文件并插入路径
  - `Alt+C` - 模糊搜索目录并 cd 进入

### 5. NVM - Node 版本管理

- 版本: 0.39.5
- Node: v22.22.3
- 镜像: npmmirror (`NVM_NODEJS_ORG_MIRROR`)
- 配置位于 `~/.zshrc` 末尾

### 6. acme.sh - SSL 证书

```bash
curl https://get.acme.sh | sh -s email=my@example.com
```

- 安装路径: `~/.acme.sh`

### 7. Git

- 版本: 2.34.1
- 用户: wubmu

### 8. Docker

- Docker: 27.0.3
- Docker Compose: v2.28.1

## 文件结构

```
~/.zshrc            # zsh 主配置
~/.p10k.zsh         # Powerlevel10k 主题配置
~/.oh-my-zsh/       # Oh-My-Zsh 安装目录
~/.fzf/             # fzf 安装目录
~/.nvm/             # NVM 安装目录
~/.acme.sh/         # acme.sh 安装目录
```
