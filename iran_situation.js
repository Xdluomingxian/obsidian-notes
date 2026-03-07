const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
    console.log('正在启动浏览器...');
    const browser = await chromium.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    const context = await browser.newContext();
    const page = await context.newPage();
    
    try {
        // 搜索伊朗最新局势
        console.log('正在搜索伊朗最新局势...');
        await page.goto('https://www.baidu.com', { waitUntil: 'networkidle' });
        
        // 在百度搜索框中输入关键词
        await page.fill('#kw', '伊朗最新局势 2026');
        await page.click('#su');
        
        // 等待搜索结果加载
        await page.waitForLoadState('networkidle');
        await page.waitForTimeout(3000);
        
        // 获取搜索结果内容
        const searchResults = await page.evaluate(() => {
            const results = [];
            const resultElements = document.querySelectorAll('.result h3 a');
            for (let i = 0; i < Math.min(10, resultElements.length); i++) {
                const title = resultElements[i].textContent.trim();
                const url = resultElements[i].href;
                results.push({ title, url });
            }
            return results;
        });
        
        // 保存搜索结果到文件
        fs.writeFileSync('/home/ubuntu/.openclaw/workspace/iran_search_results.json', 
            JSON.stringify(searchResults, null, 2));
        console.log('搜索结果已保存');
        
        // 访问第一个新闻链接获取详细内容
        if (searchResults.length > 0) {
            console.log(`正在访问: ${searchResults[0].title}`);
            await page.goto(searchResults[0].url, { waitUntil: 'networkidle' });
            await page.waitForTimeout(3000);
            
            // 提取文章主要内容
            const articleContent = await page.evaluate(() => {
                // 尝试多种可能的新闻内容选择器
                const selectors = [
                    '.article-content',
                    '.content',
                    '#content',
                    '.text',
                    'article',
                    '.post-content',
                    '.news-content'
                ];
                
                let content = '';
                for (const selector of selectors) {
                    const element = document.querySelector(selector);
                    if (element) {
                        content = element.textContent.trim();
                        break;
                    }
                }
                
                // 如果没有找到特定选择器，获取整个body的文本
                if (!content) {
                    content = document.body.textContent.trim();
                }
                
                // 清理内容，只保留前2000个字符
                return content.substring(0, 2000);
            });
            
            fs.writeFileSync('/home/ubuntu/.openclaw/workspace/iran_news_content.txt', 
                articleContent);
            console.log('新闻内容已保存');
        }
        
        // 截图搜索结果页面
        await page.screenshot({ 
            path: '/home/ubuntu/.openclaw/workspace/iran_search_screenshot.png',
            fullPage: true 
        });
        console.log('搜索结果截图已保存');
        
    } catch (error) {
        console.error('错误:', error);
        fs.writeFileSync('/home/ubuntu/.openclaw/workspace/iran_error.txt', 
            error.toString());
    } finally {
        await browser.close();
        console.log('浏览器已关闭');
    }
})();