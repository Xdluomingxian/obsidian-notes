# Scrapling - 智能网页爬虫技能

> 🕷️ An adaptive Web Scraping framework that handles everything from a single request to a full-scale crawl!

## 描述

使用 Scrapling 进行智能网页爬取和数据提取。Scrapling 是一个自适应爬虫框架，可以：
- 自动适应网站结构变化
- 绕过反爬虫系统（Cloudflare Turnstile 等）
- 支持并发爬取和代理轮换
- 支持暂停/恢复爬取

## 触发条件

使用此技能当用户：
- 需要爬取网站数据
- 需要绕过反爬虫系统
- 需要大规模爬取多个页面
- 需要提取结构化数据
- 提到"爬虫"、" scrape"、"抓取"、"提取数据"等

**不要使用**：简单网页浏览、API 调用、已有官方 API 的网站

## 安装

```bash
# 安装 Scrapling
pip install scrapling

# 或从源码安装
pip install git+https://github.com/D4Vinci/Scrapling.git
```

## 使用方法

### 基础爬取

```bash
./scripts/scrape.sh --url "https://example.com" --selector ".product" --output products.json
```

### 绕过 Cloudflare

```bash
./scripts/scrape.sh --url "https://protected-site.com" --stealthy --output data.json
```

### 大规模爬取

```bash
./scripts/spider.sh --start-url "https://example.com" --depth 3 --concurrency 5 --output results.jsonl
```

## 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--url` | 目标 URL | 必填 |
| `--selector` | CSS/XPath 选择器 | 必填 |
| `--output` | 输出文件路径 | stdout |
| `--stealthy` | 启用隐身模式 | false |
| `--headless` | 无头浏览器模式 | true |
| `--proxy` | 代理地址 | 无 |
| `--depth` | 爬取深度 | 1 |
| `--concurrency` | 并发数 | 5 |
| `--format` | 输出格式 (json/jsonl/csv) | json |

## 输出格式

```json
[
  {
    "url": "https://example.com/product/1",
    "title": "Product Title",
    "price": "$99.99",
    "description": "...",
    "scraped_at": "2026-03-07T14:30:00Z"
  }
]
```

## 示例

### 示例 1：抓取产品列表

```bash
./scripts/scrape.sh \
  --url "https://quotes.toscrape.com/" \
  --selector ".quote" \
  --fields "text=.text::text,author=.author::text" \
  --output quotes.json
```

### 示例 2：绕过 Cloudflare

```bash
./scripts/scrape.sh \
  --url "https://nopecha.com/demo/cloudflare" \
  --stealthy \
  --selector "#padded_content a" \
  --output cloudflare_data.json
```

### 示例 3：大规模爬取

```bash
./scripts/spider.sh \
  --start-url "https://example.com" \
  --depth 2 \
  --concurrency 10 \
  --output crawl_results.jsonl
```

## 注意事项

1. **遵守 robots.txt** - 爬取前检查目标网站的 robots.txt
2. **尊重速率限制** - 设置合适的并发数和延迟
3. **合法合规** - 仅爬取允许公开访问的数据
4. **存储凭证** - API Key 等敏感信息存储在环境变量中

## 依赖

- Python 3.8+
- scrapling
- playwright (用于动态渲染)

## 故障排除

### 问题 1：被网站封锁

**解决**：启用隐身模式 + 代理轮换
```bash
./scripts/scrape.sh --url "..." --stealthy --proxy "http://proxy:port"
```

### 问题 2：动态内容无法抓取

**解决**：使用动态渲染
```bash
./scripts/scrape.sh --url "..." --dynamic --wait-for ".loaded-content"
```

### 问题 3：爬取速度慢

**解决**：增加并发数
```bash
./scripts/spider.sh --concurrency 20 --depth 3
```

## 相关资源

- GitHub: https://github.com/D4Vinci/Scrapling
- 文档：https://scrapling.readthedocs.io/
- Discord: https://discord.gg/EMgGbDceNQ

## 版本

- Scrapling: 最新版
- 技能版本：1.0.0
- 创建日期：2026-03-07
