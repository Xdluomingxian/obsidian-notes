const { chromium } = require('playwright');

(async () => {
    console.log('正在启动浏览器...');
    const browser = await chromium.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    try {
        const page = await browser.newPage();
        
        // 尝试访问 BBC 中文网的中东新闻
        console.log('正在访问 BBC 中文网中东新闻...');
        await page.goto('https://www.bbc.com/zhongwen/simp/world/middle_east', {
            waitUntil: 'networkidle',
            timeout: 30000
        });
        
        // 等待页面加载并获取内容
        await page.waitForTimeout(3000);
        
        // 获取页面标题和主要内容
        const title = await page.title();
        const content = await page.evaluate(() => {
            // 获取主要新闻标题和摘要
            const headlines = Array.from(document.querySelectorAll('h3, h2, .headline, .title')).slice(0, 10);
            const texts = headlines.map(el => el.textContent.trim()).filter(text => text.length > 10);
            return texts.join('\n');
        });
        
        console.log('页面标题:', title);
        console.log('主要内容:');
        console.log(content);
        
        // 截图保存
        await page.screenshot({ path: '/home/ubuntu/.openclaw/workspace/iran_news.png', fullPage: true });
        console.log('截图已保存到: /home/ubuntu/.openclaw/workspace/iran_news.png');
        
    } catch (error) {
        console.log('访问 BBC 失败，尝试其他新闻源...');
        
        // 尝试访问 Reuters
        try {
            const page2 = await browser.newPage();
            await page2.goto('https://www.reuters.com/search/news?blob=Iran', {
                waitUntil: 'networkidle',
                timeout: 30000
            });
            
            await page2.waitForTimeout(3000);
            
            const title2 = await page2.title();
            const content2 = await page2.evaluate(() => {
                const headlines = Array.from(document.querySelectorAll('h3, h2, .text__heading, .search-result-title')).slice(0, 10);
                const texts = headlines.map(el => el.textContent.trim()).filter(text => text.length > 10);
                return texts.join('\n');
            });
            
            console.log('Reuters 页面标题:', title2);
            console.log('主要内容:');
            console.log(content2);
            
            await page2.screenshot({ path: '/home/ubuntu/.openclaw/workspace/iran_reuters.png', fullPage: true });
            console.log('Reuters 截图已保存到: /home/ubuntu/.openclaw/workspace/iran_reuters.png');
            
        } catch (error2) {
            console.log('所有新闻源访问失败，使用备用方案...');
            console.log('错误详情:', error2.message);
        }
    } finally {
        await browser.close();
        console.log('浏览器已关闭');
    }
})();