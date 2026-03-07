const { chromium } = require('playwright');

(async () => {
    console.log('正在启动无头浏览器...');
    
    // 启动无头浏览器，添加反爬虫措施
    const browser = await chromium.launch({
        headless: true, // 必须设置为 true 在无图形界面环境中
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-web-security',
            '--disable-features=IsolateOrigins,site-per-process',
            '--disable-blink-features=AutomationControlled'
        ]
    });

    const context = await browser.newContext({
        viewport: { width: 1920, height: 1080 },
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        locale: 'zh-CN',
        timezoneId: 'Asia/Shanghai',
        // 跳过图片和样式表以减少请求
        acceptDownloads: false,
        bypassCSP: true
    });

    const page = await context.newPage();
    
    try {
        // 尝试访问中文新闻网站
        console.log('正在访问新浪国际新闻...');
        await page.goto('https://news.sina.com.cn/world/', {
            waitUntil: 'domcontentloaded',
            timeout: 30000
        });
        
        // 等待页面加载并查找伊朗相关内容
        await page.waitForTimeout(3000);
        
        // 获取页面标题和主要内容
        const title = await page.title();
        console.log(`页面标题: ${title}`);
        
        // 尝试查找包含"伊朗"的新闻链接
        const iranLinks = await page.$$eval('a[href*="iran"], a:has-text("伊朗")', links => 
            links.slice(0, 5).map(link => ({
                text: link.textContent.trim(),
                href: link.href
            }))
        );
        
        if (iranLinks.length > 0) {
            console.log('找到伊朗相关新闻:');
            iranLinks.forEach((link, index) => {
                console.log(`${index + 1}. ${link.text} - ${link.href}`);
            });
            
            // 访问第一个伊朗新闻链接
            if (iranLinks[0].href) {
                console.log(`\n正在访问: ${iranLinks[0].href}`);
                await page.goto(iranLinks[0].href, { waitUntil: 'domcontentloaded', timeout: 30000 });
                await page.waitForTimeout(2000);
                
                // 获取新闻内容
                const content = await page.$eval('article, .article-content, .content', el => el.textContent.trim())
                    .catch(() => '未找到文章内容');
                
                console.log('\n新闻内容摘要:');
                console.log(content.substring(0, 500) + '...');
                
                // 截图保存
                await page.screenshot({ path: '/home/ubuntu/.openclaw/workspace/iran_news_final.png', fullPage: true });
                console.log('截图已保存到: /home/ubuntu/.openclaw/workspace/iran_news_final.png');
            }
        } else {
            // 如果没找到伊朗新闻，获取页面主要内容
            const mainContent = await page.$eval('body', el => el.textContent.trim());
            console.log('页面主要内容预览:');
            console.log(mainContent.substring(0, 300) + '...');
            
            await page.screenshot({ path: '/home/ubuntu/.openclaw/workspace/iran_news_final.png' });
            console.log('截图已保存到: /home/ubuntu/.openclaw/workspace/iran_news_final.png');
        }
        
    } catch (error) {
        console.error('访问新闻网站时出错:', error.message);
        
        // 尝试备用方案：直接搜索
        try {
            console.log('尝试备用方案：访问百度搜索...');
            await page.goto('https://www.baidu.com', { waitUntil: 'domcontentloaded', timeout: 30000 });
            await page.waitForTimeout(2000);
            
            // 使用更稳健的选择器
            const searchInput = await page.$('#kw') || await page.$('input[name="wd"]');
            if (searchInput) {
                await searchInput.fill('伊朗最新局势 2026');
                await page.keyboard.press('Enter');
                await page.waitForTimeout(5000);
                
                const searchTitle = await page.title();
                console.log(`搜索页面标题: ${searchTitle}`);
                
                // 获取搜索结果
                const results = await page.$$eval('#content_left h3 a', links => 
                    links.slice(0, 3).map(link => ({
                        text: link.textContent.trim(),
                        href: link.href
                    }))
                );
                
                console.log('搜索结果:');
                results.forEach((result, index) => {
                    console.log(`${index + 1}. ${result.text}`);
                });
                
                await page.screenshot({ path: '/home/ubuntu/.openclaw/workspace/iran_search_final.png' });
                console.log('搜索结果截图已保存');
            }
        } catch (searchError) {
            console.error('备用方案也失败:', searchError.message);
            await page.screenshot({ path: '/home/ubuntu/.openclaw/workspace/iran_error.png' });
        }
    }
    
    await browser.close();
    console.log('浏览器已关闭');
})();