# 📱 Termux 部署 OpenClaw 完整指南

**设备**：红米40（联发科天玑8300-Ultra + 8/12GB RAM）  
**创建时间**：2026-03-06  
**标签**：#OpenClaw #Termux #Android #部署 #自托管

---

## ⚠️ 前置说明

### 设备要求
- ✅ 支持 Node.js、Python、npm
- ✅ 可运行 Gateway 服务
- ⚠️ 后台运行需要特殊配置（Android 杀后台）
- ⚠️ 存储空间有限，建议配合外部存储

### 红米40配置
- **处理器**：联发科天玑8300-Ultra
- **内存**：8/12GB RAM
- **性能**：足够运行 OpenClaw Gateway

---

## 📋 操作步骤

### 第一步：安装 Termux

```bash
# 从 F-Droid 下载（推荐，更新及时）
https://f-droid.org/packages/com.termux/

# 或从 GitHub Releases
https://github.com/termux/termux-app/releases
```

> ⚠️ **不要从 Google Play 下载**（版本过旧）

---

### 第二步：Termux 基础配置

```bash
# 1. 更新软件源
pkg update && pkg upgrade -y

# 2. 安装必要依赖
pkg install -y nodejs-lts python pip git curl wget proot-distro

# 3. 授予存储权限
termux-setup-storage

# 4. 配置 Node.js（需要 v22+）
node --version
# 如果版本低于 22，执行：
pkg install nodejs-22
```

---

### 第三步：安装 OpenClaw

```bash
# 1. 安装 OpenClaw（全局）
npm install -g openclaw@latest

# 2. 验证安装
openclaw --version
openclaw help
```

---

### 第四步：配置 API Key

```bash
# 1. 创建配置文件
mkdir -p ~/.openclaw
cd ~/.openclaw

# 2. 配置 API Key（以阿里云/通义为例）
export AISA_API_KEY="your-api-key-here"

# 3. 永久保存（添加到 bashrc）
echo 'export AISA_API_KEY="your-api-key-here"' >> ~/.bashrc
echo 'export OPENCLAW_MODEL="qwen/qwen-2.5-coder-32b-instruct"' >> ~/.bashrc
source ~/.bashrc
```

---

### 第五步：初始化 OpenClaw

```bash
# 1. 运行 onboard 向导
openclaw onboard

# 2. 选择配置
# - 模型提供商：选择你有的 API Key（阿里云/智谱/DeepSeek 等）
# - 渠道：先跳过（手机部署建议先用 CLI）
# - 工作空间：使用默认 ~/.openclaw/workspace
```

---

### 第六步：启动 Gateway

```bash
# 方案 A：前台运行（测试用）
openclaw gateway --port 18789

# 方案 B：后台运行（推荐）
openclaw gateway start --port 18789

# 查看状态
openclaw gateway status
```

---

### 第七步：解决 Android 后台杀进程问题

> ⚠️ **关键步骤**：Android 会杀后台进程，需要以下方案之一：

#### 方案 1：使用 termux-wake-lock（推荐）

```bash
# 安装 wake lock 工具
pkg install -y termux-api

# 获取 wake lock（防止休眠）
termux-wake-lock

# 启动 Gateway
openclaw gateway start

# 释放 wake lock（停止时使用）
termux-wake-unlock
```

#### 方案 2：使用 nohup + 自启动脚本

```bash
# 创建启动脚本
cat > ~/start-openclaw.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/.openclaw
export AISA_API_KEY="your-key"
nohup openclaw gateway --port 18789 > ~/gateway.log 2>&1 &
echo "Gateway started with PID: $!"
EOF

chmod +x ~/start-openclaw.sh

# 添加到 Termux 自启动（需要 Termux:Boot 应用）
mkdir -p ~/.termux/boot
cp ~/start-openclaw.sh ~/.termux/boot/
```

#### 方案 3：使用 proot-distro 运行完整 Linux（进阶）

```bash
# 安装 Ubuntu
proot-distro install ubuntu

# 进入 Ubuntu 环境
proot-distro login ubuntu

# 在 Ubuntu 内安装 OpenClaw（更稳定）
```

---

### 第八步：访问 Control UI

```bash
# 1. 获取手机 IP（局域网）
ifconfig
# 或
ip addr show

# 2. 在同一局域网的电脑上访问
http://<手机 IP>:18789

# 3. 或使用 Termux 内访问
openclaw web
```

---

### 第九步：配置渠道（可选）

```bash
# 登录 WhatsApp（需要扫码）
openclaw channels login whatsapp

# 登录 Telegram（需要 Bot Token）
openclaw channels login telegram

# 查看已登录渠道
openclaw channels list
```

---

## 🔧 优化建议

### 1. 存储优化

```bash
# 将工作空间移到外部存储
ln -s /sdcard/openclaw-workspace ~/.openclaw/workspace
```

### 2. 性能优化

```bash
# 限制并发会话数
export OPENCLAW_MAX_SESSIONS=5

# 使用轻量级模型
export OPENCLAW_MODEL="qwen/qwen-2.5-coder-7b-instruct"
```

### 3. 日志管理

```bash
# 查看 Gateway 日志
openclaw gateway logs

# 限制日志大小
export OPENCLAW_LOG_MAX_SIZE=10M
```

---

## 📊 资源占用预估

| 项目 | 占用 |
|------|------|
| 安装包 | ~200MB |
| 运行时内存 | 300-500MB |
| 存储空间 | 1-2GB |
| CPU | 闲置时<5%，活跃时 20-40% |
| 电量 | 约 5-10%/小时（持续运行） |

---

## ⚠️ 常见问题

### Q1: Gateway 启动失败

```bash
# 检查端口占用
netstat -tlnp | grep 18789

# 更换端口
openclaw gateway --port 18790
```

### Q2: npm 安装慢

```bash
# 使用国内镜像
npm config set registry https://registry.npmmirror.com
npm install -g openclaw@latest
```

### Q3: 后台被杀

```bash
# 确保执行了 termux-wake-lock
# 在手机设置中给 Termux 授予"自启动"和"后台运行"权限
```

### Q4: API Key 配置问题

```bash
# 验证配置
echo $AISA_API_KEY
openclaw config list
```

---

## 🎯 快速命令汇总

```bash
# 启动
termux-wake-lock && openclaw gateway start

# 停止
openclaw gateway stop && termux-wake-unlock

# 状态
openclaw gateway status

# 日志
openclaw gateway logs

# 重启
openclaw gateway restart
```

---

## 🔗 相关链接

- [[OpenClaw 官方文档]]
- [[Termux 使用指南]]
- [[AI 模型配置]]
- [[视频生成技能]]

---

## 📝 备注

- 本笔记基于 OpenClaw 官方文档整理
- 适用于 Android 手机 Termux 环境
- 红米40 实测可用
- 需要稳定的网络连接
