const { chromium } = require('playwright');

(async () => {
    // 启动浏览器，添加反检测参数
    const browser = await chromium.launch({
        headless: false,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-blink-features=AutomationControlled',
            '--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
            '--window-size=1920,1080'
        ]
    });

    try {
        const context = await browser.newContext({
            viewport: { width: 1920, height: 1080 },
            userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
            locale: 'zh-CN',
            timezoneId: 'Asia/Shanghai'
        });

        const page = await context.newPage();
        
        // 设置 navigator.webdriver 为 undefined（绕过基本检测）
        await page.addInitScript(() => {
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined,
            });
        });

        console.log('正在访问新浪国际新闻...');
        await page.goto('https://news.sina.com.cn/world/', {
            waitUntil: 'networkidle',
            timeout: 30000
        });

        // 等待页面加载并模拟人类行为
        await page.waitForTimeout(2000);
        
        // 模拟鼠标移动和滚动
        await page.mouse.move(100, 100);
        await page.waitForTimeout(500);
        await page.evaluate(() => window.scrollBy(0, 300));
        await page.waitForTimeout(1000);

        // 搜索伊朗相关新闻
        console.log('正在搜索伊朗相关新闻...');
        const iranLinks = await page.$$eval('a[href*="iran"], a[href*="伊朗"]', links => 
            links.map(link => ({
                text: link.textContent.trim(),
                href: link.href
            })).filter(item => item.text.length > 10)
        );

        if (iranLinks.length > 0) {
            console.log(`找到 ${iranLinks.length} 条伊朗相关新闻:`);
            iranLinks.slice(0, 5).forEach((link, index) => {
                console.log(`${index + 1}. ${link.text} - ${link.href}`);
            });
            
            // 访问第一条相关新闻
            if (iranLinks[0].href) {
                await page.goto(iranLinks[0].href, { waitUntil: 'networkidle', timeout: 30000 });
                await page.waitForTimeout(2000);
                
                const title = await page.title();
                const content = await page.$eval('article, .content, .article-content', el => el.textContent) || 
                               await page.$eval('body', el => el.textContent.substring(0, 1000));
                
                console.log(`\n文章标题: ${title}`);
                console.log(`文章内容预览: ${content.substring(0, 500)}...`);
                
                // 截图保存
                await page.screenshot({ path: '/home/ubuntu/.openclaw/workspace/iran_news_detailed.png', fullPage: true });
                console.log('详细新闻截图已保存');
            }
        } else {
            // 如果没找到伊朗新闻，截取整个页面
            const title = await page.title();
            console.log(`页面标题: ${title}`);
            
            // 获取页面主要内容
            const mainContent = await page.$eval('body', el => {
                const text = el.textContent;
                return text.substring(0, 1000);
            });
            console.log('页面主要内容预览:', mainContent);
            
            await page.screenshot({ path: '/home/ubuntu/.openclaw/workspace/iran_news_overview.png', fullPage: true });
            console.log('新闻概览截图已保存');
        }

    } catch (error) {
        console.error('错误:', error.message);
        // 尝试备用方案：直接访问伊朗相关页面
        try {
            const page = await browser.newPage();
            await page.goto('https://www.chinanews.com.cn/gj/2026/03-03/news.shtml', {
                waitUntil: 'networkidle',
                timeout: 30000
            });
            await page.waitForTimeout(2000);
            const title = await page.title();
            console.log('备用方案 - 页面标题:', title);
            await page.screenshot({ path: '/home/ubuntu/.openclaw/workspace/iran_backup.png', fullPage: true });
            console.log('备用方案截图已保存');
        } catch (backupError) {
            console.error('备用方案也失败:', backupError.message);
        }
    } finally {
        await browser.close();
        console.log('浏览器已关闭');
    }
})();