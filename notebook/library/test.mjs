#! /usr/bin/env -S zx --quiet

const ppt = require('puppeteer')

const browser = await ppt.launch({args: ['--no-sandbox']})
const page = await browser.newPage()
await page.goto('https://example.com')
await page.screenshot({ path: 'example.png' })
await page.pdf({ path: 'example.pdf' })

await browser.close()
