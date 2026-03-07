const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  // 设置视口大小
  await page.setViewportSize({ width: 1920, height: 1080 });
  
  // 访问 X.com
  await page.goto('https://x.com', { waitUntil: 'networkidle' });
  
  // 等待动态内容加载（额外等待3秒）
  await page.waitForTimeout(3000);
  
  // 截取完整页面
  await page.screenshot({ path: 'x-homepage-full.png', fullPage: true });
  await browser.close();
  console.log('X.com homepage screenshot saved as x-homepage-full.png');
})();