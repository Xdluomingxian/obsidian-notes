#!/bin/bash
# 同步日记到 GitHub
# 路径配置
WORKSPACE_DIR="/home/ubuntu/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE_DIR/memory"
JOURNAL_FILE="$MEMORY_DIR/$(date +%Y-%m-%d).md"

# 检查日记文件是否存在
if [ ! -f "$JOURNAL_FILE" ]; then
    echo "日记文件不存在: $JOURNAL_FILE"
    exit 1
fi

# 进入工作区目录
cd "$WORKSPACE_DIR"

# 配置 Git（如果需要）
git config --global user.email "godluo@qq.com"
git config --global user.name "小海螺"

# 添加、提交并推送日记文件
git add "$JOURNAL_FILE"
git commit -m "📝 日记: $(date +%Y-%m-%d) - 自动同步"
git push origin main

echo "日记已成功同步到 GitHub: $(date +%Y-%m-%d)"