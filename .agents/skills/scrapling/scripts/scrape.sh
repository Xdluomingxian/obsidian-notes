#!/usr/bin/env bash
# Scrapling 爬虫脚本
# 用法：./scrape.sh --url "https://example.com" --selector ".product" --output data.json

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查依赖
check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 未安装"
        exit 1
    fi
    
    if ! python3 -c "import scrapling" &> /dev/null; then
        log_warning "Scrapling 未安装，正在安装..."
        pip3 install scrapling
    fi
}

# 显示帮助
show_help() {
    cat << EOF
🕷️  Scrapling 爬虫脚本

用法：
  $0 --url <URL> --selector <SELECTOR> [选项]

必填参数:
  --url           目标 URL
  --selector      CSS/XPath 选择器

可选参数:
  --fields        字段映射 (格式：field1=selector1,field2=selector2)
  --output        输出文件路径 (默认：stdout)
  --format        输出格式：json/jsonl/csv (默认：json)
  --stealthy      启用隐身模式 (绕过反爬虫)
  --dynamic       启用动态渲染 (JavaScript 网站)
  --headless      无头浏览器模式 (默认：true)
  --wait-for      等待 CSS 选择器加载完成
  --proxy         代理地址 (格式：http://host:port)
  --headers       自定义 headers (JSON 格式)
  --delay         请求延迟 (秒，默认：0)
  --timeout       超时时间 (秒，默认：30)
  --help          显示帮助信息

示例:
  # 基础爬取
  $0 --url "https://example.com" --selector ".product"

  # 提取多个字段
  $0 --url "https://example.com" --selector ".product" \\
     --fields "title=h2::text,price=.price::text,link=a@href"

  # 绕过 Cloudflare
  $0 --url "https://protected.com" --selector ".content" --stealthy

  # 动态网站
  $0 --url "https://spa.com" --selector ".item" --dynamic --wait-for ".loaded"

EOF
}

# 解析参数
URL=""
SELECTOR=""
FIELDS=""
OUTPUT=""
FORMAT="json"
STEALTHY=false
DYNAMIC=false
HEADLESS=true
WAIT_FOR=""
PROXY=""
HEADERS=""
DELAY=0
TIMEOUT=30

while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            URL="$2"
            shift 2
            ;;
        --selector)
            SELECTOR="$2"
            shift 2
            ;;
        --fields)
            FIELDS="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --stealthy)
            STEALTHY=true
            shift
            ;;
        --dynamic)
            DYNAMIC=true
            shift
            ;;
        --headless)
            HEADLESS=true
            shift
            ;;
        --wait-for)
            WAIT_FOR="$2"
            shift 2
            ;;
        --proxy)
            PROXY="$2"
            shift 2
            ;;
        --headers)
            HEADERS="$2"
            shift 2
            ;;
        --delay)
            DELAY="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "未知参数：$1"
            show_help
            exit 1
            ;;
    esac
done

# 验证必填参数
if [[ -z "$URL" ]]; then
    log_error "缺少必填参数：--url"
    show_help
    exit 1
fi

if [[ -z "$SELECTOR" ]]; then
    log_error "缺少必填参数：--selector"
    show_help
    exit 1
fi

# 检查依赖
check_dependencies

# 创建 Python 脚本
PYTHON_SCRIPT=$(cat << 'PYTHON_EOF'
import sys
import json
from scrapling.fetchers import Fetcher, StealthyFetcher, DynamicFetcher

def scrape(url, selector, fields=None, stealthy=False, dynamic=False, 
           headless=True, wait_for=None, proxy=None, headers=None, 
           delay=0, timeout=30):
    """爬取网页数据"""
    
    # 选择 fetcher
    if stealthy:
        fetcher = StealthyFetcher
    elif dynamic:
        fetcher = DynamicFetcher
    else:
        fetcher = Fetcher
    
    # 构建参数
    fetch_kwargs = {
        'headless': headless,
        'timeout': timeout,
    }
    
    if stealthy:
        fetch_kwargs['solve_cloudflare'] = True
    
    if dynamic and wait_for:
        fetch_kwargs['wait_for'] = wait_for
    
    if proxy:
        fetch_kwargs['proxy'] = proxy
    
    # 获取页面
    print(f"[INFO] 正在爬取：{url}", file=sys.stderr)
    page = fetcher.fetch(url, **fetch_kwargs)
    
    # 解析数据
    elements = page.css(selector)
    
    if not elements:
        print(f"[WARNING] 未找到匹配的元素：{selector}", file=sys.stderr)
        return []
    
    results = []
    
    if fields:
        # 提取指定字段
        field_map = {}
        for field_def in fields.split(','):
            if '=' in field_def:
                field_name, field_selector = field_def.split('=', 1)
                field_map[field_name.strip()] = field_selector.strip()
        
        for element in elements:
            item = {}
            for field_name, field_selector in field_map.items():
                if '@' in field_selector:
                    # 提取属性
                    attr = field_selector.split('@')[1]
                    value = element.get(attr) if hasattr(element, 'get') else None
                else:
                    # 提取文本
                    value = element.css(field_selector).get() if hasattr(element, 'css') else element.get(field_selector)
                item[field_name] = value
            results.append(item)
    else:
        # 提取完整 HTML
        for element in elements:
            results.append({
                'html': str(element),
                'text': element.get_text() if hasattr(element, 'get_text') else str(element)
            })
    
    return results

def main():
    import argparse
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--url', required=True)
    parser.add_argument('--selector', required=True)
    parser.add_argument('--fields')
    parser.add_argument('--output')
    parser.add_argument('--format', default='json')
    parser.add_argument('--stealthy', action='store_true')
    parser.add_argument('--dynamic', action='store_true')
    parser.add_argument('--headless', action='store_true', default=True)
    parser.add_argument('--wait-for')
    parser.add_argument('--proxy')
    parser.add_argument('--headers')
    parser.add_argument('--delay', type=float, default=0)
    parser.add_argument('--timeout', type=int, default=30)
    
    args = parser.parse_args()
    
    # 爬取数据
    results = scrape(
        url=args.url,
        selector=args.selector,
        fields=args.fields,
        stealthy=args.stealthy,
        dynamic=args.dynamic,
        headless=args.headless,
        wait_for=args.wait_for,
        proxy=args.proxy,
        headers=args.headers,
        delay=args.delay,
        timeout=args.timeout
    )
    
    # 输出结果
    if args.format == 'json':
        output = json.dumps(results, ensure_ascii=False, indent=2)
    elif args.format == 'jsonl':
        output = '\n'.join(json.dumps(item, ensure_ascii=False) for item in results)
    elif args.format == 'csv':
        import csv
        import io
        if results:
            output_buffer = io.StringIO()
            writer = csv.DictWriter(output_buffer, fieldnames=results[0].keys())
            writer.writeheader()
            writer.writerows(results)
            output = output_buffer.getvalue()
        else:
            output = ""
    else:
        output = str(results)
    
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(output)
        print(f"[SUCCESS] 数据已保存到：{args.output}", file=sys.stderr)
    else:
        print(output)

if __name__ == '__main__':
    main()
PYTHON_EOF
)

# 执行 Python 脚本
log_info "开始爬取：$URL"
log_info "选择器：$SELECTOR"

if [[ -n "$FIELDS" ]]; then
    log_info "字段映射：$FIELDS"
fi

if [[ "$STEALTHY" == "true" ]]; then
    log_info "模式：隐身模式 (绕过反爬虫)"
fi

if [[ "$DYNAMIC" == "true" ]]; then
    log_info "模式：动态渲染 (JavaScript)"
fi

python3 -c "$PYTHON_SCRIPT" \
    --url "$URL" \
    --selector "$SELECTOR" \
    ${FIELDS:+--fields "$FIELDS"} \
    ${OUTPUT:+--output "$OUTPUT"} \
    --format "$FORMAT" \
    ${STEALTHY:+--stealthy} \
    ${DYNAMIC:+--dynamic} \
    ${HEADLESS:+--headless} \
    ${WAIT_FOR:+--wait-for "$WAIT_FOR"} \
    ${PROXY:+--proxy "$PROXY"} \
    ${HEADERS:+--headers "$HEADERS"} \
    --delay "$DELAY" \
    --timeout "$TIMEOUT"

if [[ -n "$OUTPUT" ]]; then
    log_success "爬取完成！数据已保存到：$OUTPUT"
else
    log_success "爬取完成！"
fi
