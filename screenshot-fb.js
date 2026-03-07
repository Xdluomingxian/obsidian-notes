const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  // 设置视口大小以确保完整截图
  await page.setViewportSize({ width: 1920, height: 1080 });
  
  // 访问 Facebook
  await page.goto('https://www.facebook.com', { waitUntil: 'networkidle' });
  
  // 等待页面完全加载（额外等待3秒确保动态内容加载）
  await page.waitForTimeout(3000);
  
  // 截图并保存
  await page.screenshot({ path: 'facebook-homepage.png', fullPage: true });
  await browser.close();
  console.log('Facebook homepage screenshot saved as facebook-homepage.png');
})();