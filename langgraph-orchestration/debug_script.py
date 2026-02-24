import asyncio
import datetime
import json
import os
from playwright.async_api import async_playwright

LOG_FILE = "debug_log.txt"
SCREENSHOT_FILE = "debug_screenshot.png"
TARGET_URL = "http://localhost:5173/v2/"
MAX_BODY_SIZE = 200 * 1024  # 200KB

stats = {
    "requests": 0,
    "failures": 0,
    "console_errors": 0
}

def log(message):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(f"[{timestamp}] {message}\n")

async def run_debug():
    # Clear log file
    if os.path.exists(LOG_FILE):
        os.remove(LOG_FILE)
    
    log(f"Starting debug session for {TARGET_URL}")

    async with async_playwright() as p:
        # Launch browser
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()

        # 1) Collect Console logs
        page.on("console", lambda msg: handle_console(msg))
        page.on("pageerror", lambda err: handle_page_error(err))

        # 2, 3, 4) Network monitoring
        page.on("request", lambda req: handle_request(req))
        page.on("response", lambda res: asyncio.create_task(handle_response(res)))

        try:
            log(f"Navigating to {TARGET_URL}...")
            await page.goto(TARGET_URL, timeout=30000, wait_until="networkidle")
            await asyncio.sleep(2)

            # [Reproduction Scenario]
            # Button click: #login-button
            login_button = page.locator("#login-button")
            if await login_button.count() > 0:
                log("Found #login-button, clicking...")
                await login_button.click()
                await asyncio.sleep(1)
            else:
                log("#login-button not found, skipping.")

            # Link navigation: a[data-testid='settings']
            settings_link = page.locator("a[data-testid='settings']")
            if await settings_link.count() > 0:
                log("Found settings link, clicking...")
                await settings_link.click()
                await asyncio.sleep(1)
            else:
                log("Settings link not found, skipping.")

            await asyncio.sleep(5)
            await page.screenshot(path=SCREENSHOT_FILE)
            log(f"Screenshot saved to {SCREENSHOT_FILE}")

        except Exception as e:
            log(f"ERROR during execution: {str(e)}")
        finally:
            await browser.close()
            
            summary = (
                "\n--- Execution Summary ---\n"
                f"Total Requests: {stats['requests']}\n"
                f"Failed Requests (status >= 400): {stats['failures']}\n"
                f"Console Errors/Warnings: {stats['console_errors']}\n"
            )
            log(summary)
            print(summary)

def handle_console(msg):
    if msg.type in ["error", "warning"]:
        stats["console_errors"] += 1
    log(f"[CONSOLE][{msg.type.upper()}] {msg.text}")

def handle_page_error(err):
    stats["console_errors"] += 1
    log(f"[PAGEERROR][UNCAUGHT] {err.message}\n{err.stack}")

def handle_request(req):
    stats["requests"] += 1
    log(f"[REQUEST] {req.method} {req.url}")

async def handle_response(res):
    status = res.status
    if status >= 400:
        stats["failures"] += 1
    
    log(f"[RESPONSE] {res.request.method} {res.url} | Status: {status}")

    # Body storage criteria: API(JSON/Text) or error
    content_type = res.headers.get("content-type", "").lower()
    is_api = any(t in content_type for t in ["json", "text", "application/"])
    is_media = any(t in content_type for t in ["image", "font", "video", "audio"])
    
    if (is_api or status >= 400) and not is_media:
        try:
            body = await res.text()
            if len(body) > MAX_BODY_SIZE:
                body = body[:MAX_BODY_SIZE] + "... [TRUNCATED]"
            log(f"[BODY][{res.url}]\n{body}\n---")
        except Exception:
            log(f"[BODY][{res.url}] Could not read body (Binary or empty)")

if __name__ == "__main__":
    asyncio.run(run_debug())
