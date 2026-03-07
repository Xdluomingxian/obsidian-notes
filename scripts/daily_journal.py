#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
每日日记生成器 - 中文版本
自动生成包含工作内容、问题解决、待办事项的中文日记
"""

import os
import json
import datetime
from pathlib import Path

def get_today_date():
    """获取今天的日期字符串"""
    return datetime.datetime.now().strftime("%Y-%m-%d")

def generate_chinese_journal():
    """生成中文日记"""
    today = get_today_date()
    journal_path = f"/home/ubuntu/.openclaw/workspace/memory/{today}.md"
    
    # 从系统中收集今日活动数据
    activities = collect_daily_activities()
    
    # 生成中文日记内容
    journal_content = f"""# {today} 工作日记

## 📋 今日工作内容
{format_work_items(activities.get('work_items', []))}

## ❓ 遇到的问题
{format_problems(activities.get('problems', []))}

## ✅ 已解决问题
{format_solutions(activities.get('solutions', []))}

## ⏳ 待解决事项
{format_pending_items(activities.get('pending', []))}

## 📝 待办事项清单
{format_todo_list(activities.get('todos', []))}

## 💡 明日计划
- [ ] 

---
*日记自动生成于 {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
"""
    
    # 写入日记文件
    with open(journal_path, 'w', encoding='utf-8') as f:
        f.write(journal_content)
    
    print(f"中文日记已生成: {journal_path}")
    return journal_path

def collect_daily_activities():
    """收集今日活动数据"""
    # 这里可以从各种来源收集数据：
    # - OpenClaw 日志
    # - 系统活动记录
    # - 用户交互历史
    # - 工具使用记录
    
    activities = {
        'work_items': [],
        'problems': [],
        'solutions': [],
        'pending': [],
        'todos': []
    }
    
    # 示例数据收集（实际实现会更复杂）
    try:
        # 从 OpenClaw 获取今日活动
        from subprocess import run, PIPE
        
        # 获取今日 token 使用情况
        result = run(['curl', '-s', 'http://127.0.0.1:18789/v1/status'], 
                    capture_output=True, text=True)
        if result.returncode == 0:
            try:
                status_data = json.loads(result.stdout)
                token_usage = status_data.get('tokenUsageToday', [])
                if token_usage:
                    activities['work_items'].append(f"处理了 {len(token_usage)} 个用户请求，消耗了 {token_usage[0].get('totalTokens', '未知')} tokens")
            except:
                pass
    except Exception as e:
        activities['problems'].append(f"无法获取系统状态数据: {str(e)}")
    
    return activities

def format_work_items(items):
    """格式化工作内容"""
    if not items:
        return "- 无具体工作记录"
    return "\n".join([f"- {item}" for item in items])

def format_problems(problems):
    """格式化问题列表"""
    if not problems:
        return "- 今日未遇到明显问题"
    return "\n".join([f"- {problem}" for problem in problems])

def format_solutions(solutions):
    """格式化解决方案"""
    if not solutions:
        return "- 无新解决方案"
    return "\n".join([f"- {solution}" for solution in solutions])

def format_pending_items(pending):
    """格式化待解决事项"""
    if not pending:
        return "- 所有问题均已解决"
    return "\n".join([f"- {item}" for item in pending])

def format_todo_list(todos):
    """格式化待办事项"""
    if not todos:
        return "- 暂无明确待办事项"
    return "\n".join([f"- [ ] {todo}" for todo in todos])

if __name__ == "__main__":
    generate_chinese_journal()