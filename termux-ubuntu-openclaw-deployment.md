# 红米 K40 Termux + Ubuntu 部署 OpenClaw 完整方案

> 📱 设备：红米 K40 (Android)  
> 🐧 环境：Termux + proot-distro Ubuntu  
> 🌐 网络：国内环境（全镜像源配置）  
> 🚀 优势：完整的 Ubuntu 环境，更好的兼容性

---

## 一、方案概述

### 为什么选择 Termux + Ubuntu？

| 方案 | 优点 | 缺点 |
|------|------|------|
| 纯 Termux | 原生性能，无额外开销 | 包版本可能较旧，部分 npm 模块编译困难 |
| Termux + Ubuntu | 完整 Ubuntu 环境，兼容性好 | proot 性能损耗约 20-30% |

**推荐场景**：需要完整 Linux 环境、运行复杂依赖、追求更好兼容性

### 系统架构

```
Android 系统
    └── Termux (终端模拟器)
        └── proot-distro (用户空间模拟)
            └── Ubuntu 22.04 LTS
                └── Node.js 22+
                    └── OpenClaw
```

---

## 二、Termux 安装与配置

### 2.1 下载 Termux

**国内可用下载源：**

1. **清华 F-Droid 镜像**（推荐）
   ```
   https://mirrors.tuna.tsinghua.edu.cn/fdroid/repo/
   ```

2. **酷安**
   ```
   https://www.coolapk.com/apk/com.termux
   ```

3. **GitHub Releases**（需要网络工具）
   ```
   https://github.com/termux/termux-app/releases
   ```

⚠️ **重要**：不要从 Google Play 下载（版本过旧且不再维护）

### 2.2 初始设置

打开 Termux，执行：

```bash
# 1. 切换为清华镜像源
sed -i 's@deb\.termux\.org@mirrors.tuna.tsinghua.edu.cn/termux@' $PREFIX/etc/apt/sources.list

# 2. 更新包列表
apt update

# 3. 升级现有包
apt upgrade -y

# 4. 安装必要工具
pkg install wget curl git proot-distro -y

# 5. 授予存储权限（可选）
termux-setup-storage
```

### 2.3 配置 Termux 环境变量

```bash
# 编辑 shell 配置
cat >> ~/.bashrc << 'EOF'

# Termux 基础配置
export TERM=xterm-256color
export EDITOR=vim

# 国内镜像配置
export NPM_CONFIG_REGISTRY=https://registry.npmmirror.com
EOF

source ~/.bashrc
```

---

## 三、安装 Ubuntu (proot-distro)

### 3.1 安装 proot-distro

```bash
# 如果之前没安装
pkg install proot-distro -y

# 查看可用系统
proot-distro list
```

### 3.2 安装 Ubuntu 22.04

```bash
# 安装 Ubuntu 22.04 LTS
proot-distro install ubuntu

# 验证安装
proot-distro login ubuntu -- echo "Ubuntu 安装成功"
```

### 3.3 配置 Ubuntu 国内镜像源

首次登录 Ubuntu：

```bash
# 登录 Ubuntu
proot-distro login ubuntu

# 在 Ubuntu 内部执行以下命令：

# 1. 备份原源
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 2. 替换为清华 Ubuntu 镜像
cat > /etc/apt/sources.list << 'EOF'
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
EOF

# 3. 更新包列表
apt update

# 4. 升级系统
apt upgrade -y

# 5. 安装基础工具
apt install -y curl wget git vim nano net-tools ca-certificates
```

### 3.4 创建快捷登录命令

返回 Termux（退出 Ubuntu）：

```bash
exit

# 创建快捷命令
cat >> ~/.bashrc << 'EOF'

# Ubuntu 快捷登录
alias ubuntu='proot-distro login ubuntu'
alias ub='proot-distro login ubuntu'
EOF

source ~/.bashrc
```

现在可以直接输入 `ubuntu` 或 `ub` 登录 Ubuntu。

---

## 四、在 Ubuntu 中安装 Node.js 22+

### 4.1 方法一：NodeSource 官方源（推荐）

登录 Ubuntu 后执行：

```bash
# 安装必要依赖
apt install -y curl ca-certificates gnupg

# 添加 NodeSource 仓库
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

# 安装 Node.js
apt install -y nodejs

# 验证版本
node -v
npm -v
```

### 4.2 方法二：使用 nvm（灵活切换版本）

如果 NodeSource 访问慢：

```bash
# 安装 nvm
curl -fsSL https://gitee.com/mirrors/nvm/raw/master/install.sh | bash

# 加载 nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 添加到 shell 配置
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc

# 安装 Node.js 22
nvm install 22
nvm use 22
nvm alias default 22

# 验证
node -v
npm -v
```

### 4.3 配置 npm 国内镜像

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com

# 验证配置
npm config get registry

# 可选：配置缓存目录（节省空间）
npm config set cache ~/.npm-cache
```

---

## 五、安装 OpenClaw

### 5.1 方法一：使用 npm（推荐）

在 Ubuntu 中执行：

```bash
# 全局安装 OpenClaw
npm install -g openclaw@latest

# 验证安装
openclaw --version

# 配置 npm 全局包路径（避免权限问题）
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
export PATH="$HOME/.npm-global/bin:$PATH"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
```

### 5.2 方法二：使用安装脚本

```bash
# 使用官方安装脚本
curl -fsSL https://openclaw.ai/install.sh | bash

# 如果下载慢，使用国内代理
curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/openclaw/openclaw/main/install.sh | bash
```

### 5.3 运行初始化向导

```bash
# 运行 onboarding
openclaw onboard --install-daemon

# 检查状态
openclaw doctor
openclaw status
```

---

## 六、安装系统依赖

OpenClaw 某些功能需要额外依赖：

```bash
# 在 Ubuntu 中执行

# Python（部分技能需要）
apt install -y python3 python3-pip

# Git
apt install -y git

# 构建工具（编译原生模块）
apt install -y build-essential pkg-config

# OpenSSL
apt install -y openssl libssl-dev

# 其他常用工具
apt install -y jq unzip zip file
```

---

## 七、网络优化配置

### 7.1 GitHub 访问加速

```bash
# 配置 Git 使用镜像
git config --global url."https://ghproxy.com/".insteadOf "https://github.com/"

# 或者使用代理（如果有）
# git config --global http.proxy http://127.0.0.1:7890
# git config --global https.proxy http://127.0.0.1:7890
```

### 7.2 环境变量配置

在 Ubuntu 中：

```bash
cat >> ~/.bashrc << 'EOF'

# OpenClaw 环境变量
export OPENCLAW_HOME="$HOME/.openclaw"
export OPENCLAW_STATE_DIR="$HOME/.openclaw/state"
export OPENCLAW_CONFIG_PATH="$HOME/.openclaw/config.json"

# Node.js 优化（移动设备内存限制）
export NODE_OPTIONS="--max-old-space-size=1024"

# 国内镜像
export NPM_CONFIG_REGISTRY=https://registry.npmmirror.com
export PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
EOF

source ~/.bashrc
```

### 7.3 创建网络诊断脚本

```bash
cat > ~/check-network.sh << 'EOF'
#!/bin/bash
echo "🌐 网络诊断..."
echo ""
echo "1. 测试 GitHub 连接..."
curl -I --connect-timeout 5 https://github.com 2>/dev/null && echo "✅ GitHub 可访问" || echo "❌ GitHub 无法访问"
echo ""
echo "2. 测试 npm 镜像..."
curl -I --connect-timeout 5 https://registry.npmmirror.com 2>/dev/null && echo "✅ npm 镜像可访问" || echo "❌ npm 镜像无法访问"
echo ""
echo "3. 测试 NodeSource..."
curl -I --connect-timeout 5 https://deb.nodesource.com 2>/dev/null && echo "✅ NodeSource 可访问" || echo "❌ NodeSource 无法访问"
echo ""
echo "4. 当前 npm 源："
npm config get registry
EOF

chmod +x ~/check-network.sh
```

---

## 八、性能优化（红米 K40）

### 8.1 内存优化

红米 K40 配置：骁龙 870 + 6/8GB RAM

```bash
# 在 Ubuntu 中配置

# 限制 Node.js 内存使用
export NODE_OPTIONS="--max-old-space-size=1024"

# 创建 OpenClaw 配置文件
mkdir -p ~/.openclaw
cat > ~/.openclaw/config.json << 'EOF'
{
  "gateway": {
    "memoryLimit": 1024,
    "maxConcurrentSessions": 2,
    "disableUnusedChannels": true,
    "disableBrowserAutomation": true,
    "heartbeatInterval": 1800000
  },
  "model": {
    "defaultModel": "bailian/qwen3.5-plus",
    "fallbackModels": ["bailian/qwen3.5-turbo"]
  }
}
EOF
```

### 8.2 proot 性能优化

```bash
# 在 Termux 中创建优化启动脚本
cat > ~/start-ubuntu.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# proot 性能优化参数
export PROOT_NO_SECCOMP=1  # 禁用 seccomp（提升性能）
export PROOT_L2L_ADDR_CACHE=1  # 启用地址缓存

# 登录 Ubuntu
proot-distro login ubuntu --shared-tmp --home --rootfs /data/data/com.termux/files/home/.proot-distro/ubuntu
EOF

chmod +x ~/start-ubuntu.sh
```

### 8.3 后台运行方案

```bash
# 方法一：使用 termux-wake-lock（防止被系统杀死）
pkg install termux-api -y
termux-wake-lock

# 方法二：使用 tmux（推荐）
# 在 Ubuntu 中安装 tmux
apt install -y tmux

# 创建 tmux 会话
tmux new -s openclaw

# 在 tmux 中启动 OpenClaw
openclaw gateway start

# 退出 tmux 但保持运行：Ctrl+B, 然后按 D
# 重新连接：tmux attach -t openclaw
```

### 8.4 电池优化白名单

```bash
# 在 Android 设置中：
# 1. 设置 → 应用 → Termux → 电池
# 2. 选择"无限制"或"不优化"
# 3. 锁定 Termux 到最近任务（防止被清理）
```

---

## 九、启动与验证

### 9.1 启动 Gateway

```bash
# 登录 Ubuntu
ubuntu

# 启动 Gateway
openclaw gateway start

# 查看状态
openclaw gateway status

# 查看日志
openclaw gateway logs --follow
```

### 9.2 配置渠道

```bash
# 配置 Feishu（推荐，国内可用）
openclaw configure --channel feishu

# 配置其他渠道
openclaw configure --channel telegram  # 需要代理
openclaw configure --channel discord   # 需要代理
```

### 9.3 测试

```bash
# 发送测试消息
openclaw message send --channel feishu --message "OpenClaw 部署成功！🐚"

# 检查所有服务
openclaw doctor
```

---

## 十、自动化脚本

### 10.1 一键安装脚本（Termux 端）

保存为 `~/install-openclaw-ubuntu.sh`：

```bash
#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "🚀 开始安装 OpenClaw (Termux + Ubuntu)..."
echo ""

# 1. 更新 Termux
echo "📦 更新 Termux..."
sed -i 's@deb\.termux\.org@mirrors.tuna.tsinghua.edu.cn/termux@' $PREFIX/etc/apt/sources.list
apt update && apt upgrade -y

# 2. 安装必要工具
echo "🔧 安装工具..."
pkg install wget curl git proot-distro -y

# 3. 安装 Ubuntu
echo "🐧 安装 Ubuntu..."
proot-distro install ubuntu

# 4. 配置 Ubuntu 镜像源
echo "🌐 配置 Ubuntu 镜像源..."
proot-distro login ubuntu -- bash -c '
cat > /etc/apt/sources.list << EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
EOF
apt update && apt upgrade -y
apt install -y curl wget git ca-certificates
'

# 5. 安装 Node.js
echo "📥 安装 Node.js..."
proot-distro login ubuntu -- bash -c '
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs
npm config set registry https://registry.npmmirror.com
'

# 6. 安装 OpenClaw
echo "🐚 安装 OpenClaw..."
proot-distro login ubuntu -- bash -c '
npm install -g openclaw@latest
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
'

# 7. 配置环境变量
echo "⚙️ 配置环境变量..."
cat >> ~/.bashrc << 'EOF'

# Ubuntu 快捷登录
alias ubuntu="proot-distro login ubuntu"
alias ub="proot-distro login ubuntu"
EOF

source ~/.bashrc

echo ""
echo "✅ 安装完成！"
echo ""
echo "下一步："
echo "1. 输入 'ubuntu' 登录 Ubuntu"
echo "2. 运行 'openclaw onboard --install-daemon' 初始化"
echo "3. 运行 'openclaw status' 检查状态"
```

### 10.2 一键启动脚本

保存为 `~/start-openclaw.sh`：

```bash
#!/data/data/com.termux/files/usr/bin/bash

echo "🐚 启动 OpenClaw..."

# 保持后台运行
termux-wake-lock

# 登录 Ubuntu 并启动 Gateway
proot-distro login ubuntu -- bash -c '
export NODE_OPTIONS="--max-old-space-size=1024"
openclaw gateway start
'

echo "✅ OpenClaw 已启动"
echo "💡 查看日志：ubuntu -c 'openclaw gateway logs --follow'"
```

---

## 十一、常见问题

### 11.1 proot 性能问题

**问题**：感觉运行缓慢

**解决**：
```bash
# 禁用 seccomp 提升性能
export PROOT_NO_SECCOMP=1

# 使用轻量级模型
openclaw configure --model bailian/qwen3.5-turbo

# 减少并发会话数
# 编辑 ~/.openclaw/config.json，设置 maxConcurrentSessions: 1
```

### 11.2 内存不足

**问题**：OOM 或被系统杀死

**解决**：
```bash
# 降低 Node.js 内存限制
export NODE_OPTIONS="--max-old-space-size=512"

# 关闭其他应用
# 在 Android 设置中给 Termux 电池无限制权限
```

### 11.3 网络超时

**问题**：npm install 超时

**解决**：
```bash
# 增加 npm 超时配置
npm config set fetch-retries 5
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000

# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com
```

### 11.4 sharp 模块编译失败

**问题**：安装时 sharp 报错

**解决**：
```bash
# 使用预编译版本
export SHARP_IGNORE_GLOBAL_LIBVIPS=1
npm install -g openclaw@latest

# 或安装 libvips
apt install -y libvips-dev
```

### 11.5 Gateway 无法启动

**问题**：`openclaw gateway start` 失败

**解决**：
```bash
# 检查日志
openclaw gateway logs

# 检查端口占用
netstat -tlnp | grep :8080

# 重置配置
rm -rf ~/.openclaw/config.json
openclaw onboard --install-daemon
```

### 11.6 proot-distro 登录失败

**问题**：`proot-distro login ubuntu` 报错

**解决**：
```bash
# 重新安装 Ubuntu
proot-distro remove ubuntu
proot-distro install ubuntu

# 检查存储空间
df -h
```

---

## 十二、维护与更新

### 12.1 更新 OpenClaw

```bash
# 登录 Ubuntu
ubuntu

# 更新
npm update -g openclaw

# 或重新安装
npm install -g openclaw@latest

# 重启 Gateway
openclaw gateway restart
```

### 12.2 更新 Ubuntu 系统

```bash
ubuntu
apt update && apt upgrade -y
```

### 12.3 清理缓存

```bash
# 清理 npm 缓存
npm cache clean --force

# 清理 OpenClaw 缓存
rm -rf ~/.openclaw/cache

# 清理 apt 缓存
apt clean
```

### 12.4 备份配置

```bash
# 备份到手机存储
cp -r ~/.openclaw /sdcard/openclaw-backup-$(date +%Y%m%d)

# 或备份到 Git
cd ~/.openclaw
git init
git add .
git commit -m "Backup $(date)"
```

---

## 十三、目录结构

```
/home/ubuntu/.openclaw/
├── config.json          # 主配置文件
├── state/               # 运行时状态
├── cache/               # 缓存文件
├── logs/                # 日志文件
└── workspace/           # 工作空间
    ├── obsidian-notes/  # 笔记仓库
    ├── memory/          # 记忆文件
    └── termux-deployment-guide.md
```

---

## 十四、快速命令参考

### Termux 端

```bash
# 登录 Ubuntu
ubuntu / ub

# 启动 OpenClaw
openclaw gateway start

# 查看状态
openclaw gateway status

# 网络诊断
~/check-network.sh
```

### Ubuntu 端

```bash
# Gateway 管理
openclaw gateway start|stop|restart|status

# 日志
openclaw gateway logs --follow

# 配置
openclaw configure
openclaw doctor

# 更新
openclaw update
```

---

## 十五、性能基准参考

红米 K40 (骁龙 870 + 8GB RAM) 预期性能：

| 指标 | 预期值 |
|------|--------|
| 启动时间 | 10-15 秒 |
| 内存占用 | 400-800 MB |
| 响应延迟 | 500-1500ms |
| 并发会话 | 2-3 个 |
| 电池消耗 | 中等（建议插电使用） |

---

## 附录：完整配置清单

### Termux 配置

```bash
# ~/.bashrc 添加内容
alias ubuntu='proot-distro login ubuntu'
alias ub='proot-distro login ubuntu'
export NPM_CONFIG_REGISTRY=https://registry.npmmirror.com
```

### Ubuntu 配置

```bash
# ~/.bashrc 添加内容
export OPENCLAW_HOME="$HOME/.openclaw"
export NODE_OPTIONS="--max-old-space-size=1024"
export NPM_CONFIG_REGISTRY=https://registry.npmmirror.com
export PATH="$HOME/.npm-global/bin:$PATH"
```

### OpenClaw 配置

```json
{
  "gateway": {
    "memoryLimit": 1024,
    "maxConcurrentSessions": 2,
    "disableUnusedChannels": true,
    "disableBrowserAutomation": true,
    "heartbeatInterval": 1800000
  },
  "model": {
    "defaultModel": "bailian/qwen3.5-plus",
    "fallbackModels": ["bailian/qwen3.5-turbo"]
  }
}
```

---

**文档版本**: 2026-03-07 (v2.0 - Ubuntu proot 版)  
**适用设备**: 红米 K40 (Android + Termux + proot-distro Ubuntu)  
**维护者**: 小海螺 🐚  
**最后更新**: 2026 年 3 月 7 日
