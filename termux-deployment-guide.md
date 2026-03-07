# 红米 K40 Termux 部署 OpenClaw 完整方案

> 📱 设备：红米 K40 (Android)  
> 🛠️ 环境：Termux  
> 🌐 网络：国内环境（需配置镜像源）

---

## 一、前置准备

### 1.1 安装 Termux

**推荐下载源（国内可用）：**

- **F-Droid 镜像**：https://mirrors.tuna.tsinghua.edu.cn/fdroid/repo/
- **酷安**：https://www.coolapk.com/apk/com.termux

⚠️ **重要**：不要从 Google Play 下载（版本过旧），必须从 F-Droid 或可信镜像源下载。

### 1.2 基础设置

打开 Termux，执行以下命令：

```bash
# 更新软件源（使用清华镜像）
sed -i 's@deb\.termux\.org@mirrors.tuna.tsinghua.edu.cn/termux@' $PREFIX/etc/apt/sources.list

# 更新包列表
apt update

# 升级现有包
apt upgrade -y

# 授予存储权限（可选，用于访问手机文件）
termux-setup-storage
```

---

## 二、安装 Node.js 22+

OpenClaw 需要 Node.js 22 或更高版本。

### 2.1 方法一：Termux 官方源（推荐）

```bash
# 安装 Node.js 22
pkg install nodejs -y

# 验证版本
node -v
npm -v
```

如果版本低于 22，使用方法二。

### 2.2 方法二：使用 nvm 安装最新版

```bash
# 安装必要工具
pkg install curl wget git -y

# 安装 nvm
export NVM_DIR="$HOME/.nvm"
curl -fsSL https://gitee.com/mirrors/nvm/raw/master/install.sh | bash

# 加载 nvm
source $NVM_DIR/nvm.sh

# 添加到 shell 配置
echo 'source $NVM_DIR/nvm.sh' >> ~/.bashrc

# 安装 Node.js 22
nvm install 22
nvm use 22
nvm alias default 22

# 验证
node -v
npm -v
```

### 2.3 配置 npm 国内镜像

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com

# 验证配置
npm config get registry
```

---

## 三、安装 pnpm（可选但推荐）

pnpm 比 npm 更节省空间，适合移动设备。

```bash
# 安装 pnpm
npm install -g pnpm

# 配置 pnpm 使用国内镜像
pnpm config set registry https://registry.npmmirror.com

# 验证
pnpm -v
```

---

## 四、安装 OpenClaw

### 4.1 方法一：使用安装脚本（推荐）

```bash
# 使用国内镜像加速安装脚本
curl -fsSL https://openclaw.ai/install.sh | bash
```

如果下载慢，使用方法二。

### 4.2 方法二：直接使用 npm 安装

```bash
# 使用 npm 安装
npm install -g openclaw@latest

# 或使用 pnpm
pnpm add -g openclaw@latest
pnpm approve-builds -g  # 确认构建脚本
```

### 4.3 安装后配置

```bash
# 运行初始化向导
openclaw onboard --install-daemon

# 检查状态
openclaw doctor
openclaw status
```

---

## 五、依赖项安装

OpenClaw 某些功能需要额外依赖：

```bash
# 安装 Python（部分技能需要）
pkg install python -y

# 安装 Git
pkg install git -y

# 安装构建工具（如果需要编译原生模块）
pkg install clang make pkg-config -y

# 安装 OpenSSL
pkg install openssl -y

# 安装 libuv（Node.js 依赖）
pkg install libuv -y
```

---

## 六、网络优化（国内环境）

### 6.1 GitHub 访问加速

```bash
# 配置 Git 使用代理（如果有）
# git config --global http.proxy http://127.0.0.1:7890
# git config --global https.proxy http://127.0.0.1:7890

# 或使用镜像源
git config --global url."https://ghproxy.com/".insteadOf "https://github.com/"
```

### 6.2 环境变量配置

创建配置文件：

```bash
cat >> ~/.bashrc << 'EOF'

# OpenClaw 环境变量
export OPENCLAW_HOME="$HOME/.openclaw"
export OPENCLAW_STATE_DIR="$HOME/.openclaw/state"
export OPENCLAW_CONFIG_PATH="$HOME/.openclaw/config.json"

# Node.js 优化（减少内存占用）
export NODE_OPTIONS="--max-old-space-size=512"

# 使用国内镜像
export NPM_CONFIG_REGISTRY=https://registry.npmmirror.com
export PNPMP_REGISTRY=https://registry.npmmirror.com
EOF

# 使配置生效
source ~/.bashrc
```

---

## 七、启动与验证

### 7.1 启动 Gateway

```bash
# 启动 OpenClaw Gateway
openclaw gateway start

# 查看状态
openclaw gateway status

# 查看日志
openclaw gateway logs
```

### 7.2 配置渠道

根据需求配置消息渠道：

```bash
# 配置 Feishu（推荐，国内可用）
openclaw configure --channel feishu

# 配置 Telegram（需要代理）
openclaw configure --channel telegram

# 配置微信（需要额外配置）
openclaw configure --channel wechat
```

### 7.3 测试

```bash
# 发送测试消息
openclaw message send --channel feishu --message "OpenClaw 部署成功！"
```

---

## 八、性能优化（移动设备）

### 8.1 限制资源使用

编辑配置文件：

```bash
# 创建配置目录
mkdir -p ~/.openclaw

# 创建配置文件
cat > ~/.openclaw/config.json << 'EOF'
{
  "gateway": {
    "memoryLimit": 512,
    "maxConcurrentSessions": 2,
    "disableUnusedChannels": true
  },
  "model": {
    "defaultModel": "bailian/qwen3.5-plus",
    "fallbackModels": ["bailian/qwen3.5-turbo"]
  }
}
EOF
```

### 8.2 后台运行

使用 termux-wake-lock 防止被系统杀死：

```bash
# 安装 wake lock
pkg install termux-api -y

# 保持后台运行
termux-wake-lock

# 使用 tmux 保持会话
pkg install tmux -y
tmux new -s openclaw
openclaw gateway start
# Ctrl+B, D 退出会话但保持运行
```

---

## 九、常见问题

### 9.1 安装失败：权限错误

```bash
# 使用 npm 前缀到用户目录
npm config set prefix ~/.npm-global
export PATH="$HOME/.npm-global/bin:$PATH"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
```

### 9.2 内存不足

```bash
# 关闭其他应用
# 限制 Node.js 内存
export NODE_OPTIONS="--max-old-space-size=256"

# 使用轻量级模型
openclaw configure --model bailian/qwen3.5-turbo
```

### 9.3 网络超时

```bash
# 增加 npm 超时
npm config set fetch-retries 5
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000

# 使用代理（如果有）
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
```

### 9.4 sharp 模块编译失败

```bash
# 使用预编译版本
export SHARP_IGNORE_GLOBAL_LIBVIPS=1
npm install -g openclaw@latest
```

---

## 十、维护与更新

### 10.1 更新 OpenClaw

```bash
# 使用 npm 更新
npm update -g openclaw

# 或使用 pnpm
pnpm update -g openclaw

# 重启 Gateway
openclaw gateway restart
```

### 10.2 清理缓存

```bash
# 清理 npm 缓存
npm cache clean --force

# 清理 OpenClaw 缓存
rm -rf ~/.openclaw/cache
```

### 10.3 备份配置

```bash
# 备份配置
cp -r ~/.openclaw ~/storage/shared/openclaw-backup-$(date +%Y%m%d)
```

---

## 十一、推荐配置（红米 K40）

红米 K40 配置：骁龙 870 + 6/8GB RAM

```bash
# 推荐设置
export NODE_OPTIONS="--max-old-space-size=1024"  # 1GB 内存限制
export OPENCLAW_MAX_SESSIONS=3                   # 最大并发会话

# 推荐模型（平衡性能与速度）
openclaw configure --model bailian/qwen3.5-plus

# 禁用不需要的功能
# 编辑 ~/.openclaw/config.json 添加:
{
  "gateway": {
    "disableBrowserAutomation": true,  # 禁用浏览器自动化（节省资源）
    "disableFileWatching": false,      # 保持文件监控
    "heartbeatInterval": 1800000       # 30 分钟心跳（减少 API 调用）
  }
}
```

---

## 十二、快速命令参考

```bash
# 启动/停止/重启
openclaw gateway start
openclaw gateway stop
openclaw gateway restart

# 状态检查
openclaw status
openclaw doctor

# 配置
openclaw configure
openclaw configure --channel feishu

# 日志
openclaw gateway logs
openclaw gateway logs --follow

# 更新
openclaw update
```

---

## 附录：完整安装脚本

保存为 `install-openclaw.sh` 一键执行：

```bash
#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 开始安装 OpenClaw..."

# 1. 更新系统
echo "📦 更新系统..."
sed -i 's@deb\.termux\.org@mirrors.tuna.tsinghua.edu.cn/termux@' $PREFIX/etc/apt/sources.list
apt update && apt upgrade -y

# 2. 安装基础依赖
echo "🔧 安装依赖..."
pkg install nodejs python git curl wget -y

# 3. 配置 npm 镜像
echo "🌐 配置 npm 镜像..."
npm config set registry https://registry.npmmirror.com

# 4. 安装 OpenClaw
echo "📥 安装 OpenClaw..."
npm install -g openclaw@latest

# 5. 配置环境变量
echo "⚙️ 配置环境变量..."
cat >> ~/.bashrc << 'EOF'
export OPENCLAW_HOME="$HOME/.openclaw"
export NODE_OPTIONS="--max-old-space-size=1024"
EOF
source ~/.bashrc

# 6. 初始化
echo "🎯 初始化 OpenClaw..."
openclaw onboard --install-daemon

echo "✅ 安装完成！运行 'openclaw status' 检查状态"
```

---

**文档版本**: 2026-03-07  
**适用设备**: 红米 K40 (Android + Termux)  
**维护者**: 小海螺 🐚
