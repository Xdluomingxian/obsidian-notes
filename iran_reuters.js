const { chromium } = require('playwright');

(async () => {
    console.log('正在启动浏览器...');
    const browser = await chromium.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    try {
        const page = await browser.newPage();
        
        // 访问路透社中东新闻页面
        console.log('正在访问路透社中东新闻...');
        await page.goto('https://www.reuters.com/world/middle-east/', {
            waitUntil: 'networkidle',
            timeout: 30000
        });
        
        // 等待页面加载
        await page.waitForTimeout(3000);
        
        // 获取页面标题
        const title = await page.title();
        console.log('页面标题:', title);
        
        // 截图
        await page.screenshot({ path: '/home/ubuntu/.openclaw/workspace/iran_reuters.png', fullPage: true });
        console.log('截图已保存到: /home/ubuntu/.openclaw/workspace/iran_reuters.png');
        
        // 尝试提取伊朗相关新闻
        const iranArticles = await page.$$eval('article a[href*="iran"], article a[href*="Iran"]', links => 
            links.map(link => ({
                title: link.textContent?.trim() || '',
                href: link.href || ''
            })).filter(item => item.title && item.title.length > 10)
        );
        
        if (iranArticles.length > 0) {
            console.log('\n找到的伊朗相关新闻:');
            iranArticles.slice(0, 5).forEach((article, index) => {
                console.log(`${index + 1}. ${article.title}`);
            });
        } else {
            console.log('\n未找到明确的伊朗相关新闻，获取页面主要内容...');
            const mainContent = await page.$eval('main, .content, body', el => el.textContent?.substring(0, 2000) || '');
            console.log('主要内容预览:', mainContent.substring(0, 500) + '...');
        }
        
    } catch (error) {
        console.error('错误:', error.message);
        // 尝试获取错误页面的内容
        try {
            const errorContent = await page.content();
            console.log('错误页面内容长度:', errorContent.length);
        } catch (e) {
            console.log('无法获取错误页面内容');
        }
    } finally {
        await browser.close();
        console.log('浏览器已关闭');
    }
})();