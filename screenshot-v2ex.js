const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  // 设置视口大小
  await page.setViewportSize({ width: 1920, height: 1080 });
  
  // 访问 V2EX
  await page.goto('https://www.v2ex.com/', { waitUntil: 'networkidle' });
  
  // 等待页面完全加载（额外等待3秒确保动态内容加载）
  await page.waitForTimeout(3000);
  
  // 截图并保存
  await page.screenshot({ path: 'v2ex-homepage.png', fullPage: true });
  await browser.close();
  console.log('V2EX homepage screenshot saved as v2ex-homepage.png');
})();