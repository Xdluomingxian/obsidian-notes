#!/usr/bin/env python3
"""
Test Playwright browser access to V2EX
"""

import asyncio
from playwright.async_api import async_playwright

async def test_v2ex_access():
    async with async_playwright() as p:
        # Launch Chromium browser
        browser = await p.chromium.launch(
            headless=True,
            args=[
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
            ]
        )
        
        page = await browser.new_page()
        
        try:
            # Navigate to V2EX
            await page.goto('https://www.v2ex.com/', timeout=30000)
            print("✅ Successfully loaded V2EX homepage")
            
            # Wait for content to load
            await page.wait_for_selector('.header', timeout=10000)
            
            # Get page title
            title = await page.title()
            print(f"📄 Page title: {title}")
            
            # Search for openclaw (if search functionality exists)
            # For now, just check if we can access the page
            
            # Take a screenshot for verification
            await page.screenshot(path='/home/ubuntu/.openclaw/workspace/v2ex_screenshot.png')
            print("📸 Screenshot saved: v2ex_screenshot.png")
            
        except Exception as e:
            print(f"❌ Error accessing V2EX: {e}")
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(test_v2ex_access())