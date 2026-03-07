# GitHub CLI 配置指南

## 📅 创建日期
2026-03-01

## 🎯 目的
记录在 OpenClaw 环境中配置 GitHub CLI 的完整过程，用于后续参考和同步到 Obsidian 笔记系统。

## 🔧 配置步骤

### 1. 安装 GitHub CLI
```bash
# 添加 GitHub CLI 仓库源
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# 安装 gh CLI
sudo apt update && sudo apt install gh -y
```

### 2. GitHub 认证配置
```bash
# 使用 Personal Access Token 进行认证
echo "YOUR_GITHUB_TOKEN" | gh auth login --with-token
```

### 3. 验证配置状态
```bash
# 检查认证状态
gh auth status

# 测试 API 访问
gh api user --jq '.login'
gh api user/repos --jq 'length'
```

### 4. Git 全局配置
```bash
# 设置 Git 用户信息
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

## ⚠️ 安全注意事项

### Personal Access Token 权限要求
- **repo**: Full control of private repositories (必需)
- **workflow**: Update GitHub Action workflows (可选)

### 安全最佳实践
1. **定期轮换令牌**：建议每 30-90 天更换一次
2. **最小权限原则**：只授予必要的权限范围
3. **避免硬编码**：不要在代码或配置文件中直接存储令牌
4. **立即撤销泄露的令牌**：如果令牌被意外公开，立即在 GitHub 设置中撤销

## 🛠️ 故障排除

### 常见错误及解决方案

#### 错误：`GraphQL: Resource not accessible by personal access token`
- **原因**：Personal Access Token 缺少必要的权限
- **解决方案**：重新生成包含 `repo` 权限的令牌

#### 错误：`gh: command not found`
- **原因**：GitHub CLI 未正确安装
- **解决方案**：按照步骤 1 重新安装

#### 错误：认证失败
- **原因**：令牌已过期或被撤销
- **解决方案**：生成新的 Personal Access Token 并重新认证

## 📦 相关技能安装

在配置 GitHub CLI 的同时，还安装了以下相关技能：

- **gh-cli**: GitHub 官方 CLI 集成技能
- **github-cli**: 社区版 GitHub CLI 技能
- **find-skills**: 用于发现和安装其他代理技能
- **web-search-tavily**: Tavily 网络搜索功能
- **v2ex-hot-cn**: V2EX 热门话题监控（中文版）

## 🔗 参考链接

- [GitHub CLI 官方文档](https://cli.github.com/)
- [Personal Access Tokens 文档](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [OpenClaw 技能系统](https://docs.openclaw.ai/skills)

## 📝 后续步骤

1. **创建专用仓库**：为 Obsidian 笔记创建专门的 GitHub 仓库
2. **设置同步工作流**：配置自动同步机制（如 GitHub Actions 或本地脚本）
3. **定期备份**：确保笔记数据的安全性和一致性
4. **版本控制最佳实践**：合理使用 Git 分支和标签管理笔记版本

---
*本文档由 OpenClaw AI 助手自动生成，用于记录技术配置过程。*