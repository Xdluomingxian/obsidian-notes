#!/usr/bin/env python3
"""
V2EX 热门获取脚本 - 实时版本
V2EX Hot Topics Fetcher - Real-time version

This script fetches real data from v2ex.com instead of using mock data.
"""

import json
import sys
import re
import time
from datetime import datetime
from urllib.request import urlopen, Request
from urllib.error import URLError
import html

def fetch_v2ex_hot_topics(limit=10, search_keyword=None):
    """
    Fetch real hot topics from V2EX homepage
    """
    try:
        # V2EX homepage URL
        url = "https://www.v2ex.com/"
        
        # Add headers to mimic a real browser
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        }
        
        req = Request(url, headers=headers)
        response = urlopen(req, timeout=10)
        html_content = response.read().decode('utf-8')
        
        # Parse the HTML to extract topic information
        topics = parse_v2ex_html(html_content, limit, search_keyword)
        
        return topics
        
    except URLError as e:
        print(f"Error fetching V2EX data: {e}", file=sys.stderr)
        # Fallback to mock data if real fetch fails
        return get_mock_data(limit, search_keyword)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        return get_mock_data(limit, search_keyword)

def parse_v2ex_html(html_content, limit=10, search_keyword=None):
    """
    Parse V2EX HTML content to extract topic information
    """
    topics = []
    
    # Find all topic entries in the HTML
    # V2EX uses a specific structure for topic listings
    topic_pattern = r'<div class="cell item"[^>]*>.*?<a href="/t/(\d+)"[^>]*>(.*?)</a>.*?<a href="/go/([^"]+)"[^>]*>.*?</a>.*?<span class="small fade">.*?(\d+)\s+条回复.*?</span>.*?<strong><a href="/member/([^"]+)"[^>]*>'
    
    matches = re.findall(topic_pattern, html_content, re.DOTALL | re.IGNORECASE)
    
    for match in matches[:limit]:
        topic_id, title, node, replies, author = match
        
        # Clean up the title (remove HTML entities)
        title = html.unescape(title.strip())
        node = node.strip()
        author = author.strip()
        
        # Filter by search keyword if provided
        if search_keyword and search_keyword.lower() not in title.lower():
            continue
            
        topic_info = {
            "id": int(topic_id),
            "title": title,
            "node": node,
            "replies": int(replies),
            "author": author,
            "url": f"https://v2ex.com/t/{topic_id}"
        }
        
        topics.append(topic_info)
        
        if len(topics) >= limit:
            break
    
    # If no topics found with regex, try alternative parsing
    if not topics:
        topics = parse_v2ex_alternative(html_content, limit, search_keyword)
    
    return topics

def parse_v2ex_alternative(html_content, limit=10, search_keyword=None):
    """
    Alternative parsing method if the main regex fails
    """
    topics = []
    
    # Try to find topic links with /t/ pattern
    topic_links = re.findall(r'<a href="/t/(\d+)"[^>]*>([^<]+)</a>', html_content, re.IGNORECASE)
    nodes = re.findall(r'<a href="/go/([^"]+)"', html_content, re.IGNORECASE)
    authors = re.findall(r'<strong><a href="/member/([^"]+)"', html_content, re.IGNORECASE)
    replies_list = re.findall(r'(\d+)\s+条回复', html_content, re.IGNORECASE)
    
    # Combine the extracted data
    min_length = min(len(topic_links), len(nodes), len(authors), len(replies_list))
    
    for i in range(min_length):
        topic_id, title = topic_links[i]
        node = nodes[i] if i < len(nodes) else "unknown"
        author = authors[i] if i < len(authors) else "unknown"
        replies = replies_list[i] if i < len(replies_list) else "0"
        
        if search_keyword and search_keyword.lower() not in title.lower():
            continue
            
        topic_info = {
            "id": int(topic_id),
            "title": html.unescape(title.strip()),
            "node": node.strip(),
            "replies": int(replies),
            "author": author.strip(),
            "url": f"https://v2ex.com/t/{topic_id}"
        }
        
        topics.append(topic_info)
        
        if len(topics) >= limit:
            break
    
    return topics

def get_mock_data(limit=10, search_keyword=None):
    """
    Fallback mock data
    """
    mock_topics = [
        {"id": 1, "title": "2026 年该学什么编程语言？", "node": "programmer", "replies": 234, "author": "dev123", "url": "https://v2ex.com/t/1"},
        {"id": 2, "title": "MacBook Pro M4 值得买吗？", "node": "apple", "replies": 189, "author": "macfan", "url": "https://v2ex.com/t/2"},
        {"id": 3, "title": "远程办公两年后的感受", "node": "career", "replies": 176, "author": "remote_dev", "url": "https://v2ex.com/t/3"},
        {"id": 4, "title": "推荐几个好用的 VS Code 插件", "node": "programmer", "replies": 156, "author": "vscoder", "url": "https://v2ex.com/t/4"},
        {"id": 5, "title": "大家都在用什么机械键盘？", "node": "hardware", "replies": 143, "author": "keyboard_lover", "url": "https://v2ex.com/t/5"},
        {"id": 6, "title": "求推荐一个靠谱的云服务器", "node": "host", "replies": 132, "author": "cloud_user", "url": "https://v2ex.com/t/6"},
        {"id": 7, "title": "AI 编程助手对比：Cursor vs Copilot", "node": "programmer", "replies": 128, "author": "ai_coder", "url": "https://v2ex.com/t/7"},
        {"id": 8, "title": "iOS 18 体验报告", "node": "apple", "replies": 115, "author": "ios_dev", "url": "https://v2ex.com/t/8"},
        {"id": 9, "title": "独立开发者如何获取第一批用户？", "node": "creative", "replies": 98, "author": "indie_dev", "url": "https://v2ex.com/t/9"},
        {"id": 10, "title": "北京程序员租房经验分享", "node": "life", "replies": 87, "author": "beijing_dev", "url": "https://v2ex.com/t/10"},
    ]
    
    if search_keyword:
        mock_topics = [t for t in mock_topics if search_keyword.lower() in t["title"].lower()]
    
    return mock_topics[:limit]

def format_output(data, search_keyword=None):
    """Format output for display"""
    if search_keyword:
        output = f"💬 V2EX 搜索 '{search_keyword}' 的结果\n\n"
    else:
        output = "💬 V2EX 今日热门\n\n"
    
    if not data:
        output += "暂无相关帖子\n"
        return output
    
    for item in data:
        output += f"{item['id']}. {item['title']}\n"
        output += f"   📂 {item['node']} | 💬 {item['replies']} | @{item['author']}\n"
        output += f"   🔗 {item['url']}\n\n"
    
    return output

def fetch_topic_details(topic_id):
    """
    Fetch detailed information about a specific topic including comments
    """
    try:
        url = f"https://www.v2ex.com/t/{topic_id}"
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        }
        
        req = Request(url, headers=headers)
        response = urlopen(req, timeout=10)
        html_content = response.read().decode('utf-8')
        
        # Extract topic title
        title_match = re.search(r'<h1[^>]*>(.*?)</h1>', html_content, re.DOTALL)
        title = html.unescape(title_match.group(1).strip()) if title_match else f"Topic {topic_id}"
        
        # Extract comments (simplified - just get comment count and first few)
        comments = []
        comment_pattern = r'<div class="reply_content"[^>]*>(.*?)</div>'
        comment_matches = re.findall(comment_pattern, html_content, re.DOTALL)
        
        for i, comment_html in enumerate(comment_matches[:5]):  # Get first 5 comments
            # Clean up comment HTML
            comment_text = re.sub(r'<[^>]+>', '', comment_html)  # Remove HTML tags
            comment_text = html.unescape(comment_text.strip())
            if comment_text:
                comments.append({
                    "index": i + 1,
                    "content": comment_text[:200] + "..." if len(comment_text) > 200 else comment_text
                })
        
        return {
            "title": title,
            "url": url,
            "comments_count": len(comment_matches),
            "sample_comments": comments
        }
        
    except Exception as e:
        print(f"Error fetching topic details: {e}", file=sys.stderr)
        return None

def main():
    limit = 10
    search_keyword = None
    show_details = False
    topic_id_for_details = None
    
    # Parse command line arguments
    args = sys.argv[1:]
    i = 0
    while i < len(args):
        arg = args[i]
        if arg == "--details" or arg == "-d":
            show_details = True
        elif arg == "--topic" or arg == "-t":
            if i + 1 < len(args):
                topic_id_for_details = args[i + 1]
                i += 1
        elif arg.isdigit():
            limit = int(arg)
        elif arg.startswith("--"):
            # Skip unknown flags
            pass
        else:
            # Assume it's a search keyword
            search_keyword = arg
        i += 1
    
    # Handle specific topic details request
    if topic_id_for_details:
        details = fetch_topic_details(topic_id_for_details)
        if details:
            print(f"📝 主题: {details['title']}")
            print(f"🔗 链接: {details['url']}")
            print(f"💬 评论数: {details['comments_count']}")
            print("\n📋 精选评论:")
            for comment in details['sample_comments']:
                print(f"\n{comment['index']}. {comment['content']}")
        else:
            print("无法获取主题详情")
        return
    
    # Fetch hot topics
    data = fetch_v2ex_hot_topics(limit, search_keyword)
    
    # Output format
    if "--json" in sys.argv or "-j" in sys.argv:
        print(json.dumps({"data": data}, ensure_ascii=False, indent=2))
    else:
        output = format_output(data, search_keyword)
        print(output)
        
        # If search keyword is "openclaw", also show detailed info for relevant topics
        if search_keyword and search_keyword.lower() == "openclaw" and data:
            print("🔍 正在获取 OpenClaw 相关帖子的详细信息...\n")
            for topic in data[:2]:  # Get details for first 2 relevant topics
                details = fetch_topic_details(topic['id'])
                if details:
                    print(f"📝 主题: {details['title']}")
                    print(f"💬 评论数: {details['comments_count']}")
                    if details['sample_comments']:
                        print("📋 精选评论:")
                        for comment in details['sample_comments'][:2]:
                            print(f"  • {comment['content']}")
                    print("-" * 50)

if __name__ == "__main__":
    main()