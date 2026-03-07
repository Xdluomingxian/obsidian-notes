const { chromium } = require('playwright');

(async () => {
  // 启动浏览器
  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  try {
    // 创建新页面
    const page = await browser.newPage();
    
    // 设置视窗大小
    await page.setViewportSize({ width: 1920, height: 1080 });
    
    // 访问 V2EX 首页
    console.log('正在访问 V2EX 首页...');
    await page.goto('https://www.v2ex.com', {
      waitUntil: 'networkidle',
      timeout: 30000
    });
    
    // 等待页面完全加载
    await page.waitForTimeout(3000);
    
    // 截图保存
    const screenshotPath = '/home/ubuntu/.openclaw/workspace/v2ex_homepage.png';
    await page.screenshot({
      path: screenshotPath,
      fullPage: false,
      type: 'png'
    });
    
    console.log(`截图已保存到: ${screenshotPath}`);
    
    // 获取页面标题验证
    const title = await page.title();
    console.log(`页面标题: ${title}`);
    
  } catch (error) {
    console.error('执行过程中出现错误:', error);
    process.exit(1);
  } finally {
    // 关闭浏览器
    await browser.close();
  }
})();