const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto('https://x.com');
  await page.screenshot({ path: 'x-homepage.png' });
  await browser.close();
  console.log('Screenshot saved as x-homepage.png');
})();