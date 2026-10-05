// capture-live.mjs — drive docs/assets/pipeline-live.html via window.seek(t)
// and export frames for the README GIF (Windows path: live-panel's render.py
// transport is POSIX-only, so frames come from Playwright instead).
// Usage:  node capture-live.mjs <html-abs-path> <outdir> [--all]
// Needs a playwright install reachable via the dsh-market checkout.
import { createRequire } from 'node:module'
import { mkdirSync } from 'node:fs'
import { pathToFileURL } from 'node:url'
const require = createRequire('D:/维护/dsh-market/package.json')
const { chromium } = require('playwright')

const html = process.argv[2]
const outdir = process.argv[3]
const all = process.argv.includes('--all')
mkdirSync(outdir, { recursive: true })

const browser = await chromium.launch({
  executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe',
})
const page = await browser.newPage({ viewport: { width: 1600, height: 900 } })
await page.goto(pathToFileURL(html).href + '?manual')
await page.waitForFunction('window.__ready === true')

const problems = await page.evaluate('window.__check()')
if (problems && problems.length) {
  console.log('LAYOUT PROBLEMS:')
  for (const p of problems) console.log(' -', JSON.stringify(p).slice(0, 300))
} else {
  console.log('layout check: clean')
}

const fps = 12, dur = 12
const times = all
  ? Array.from({ length: fps * dur }, (_, i) => i / fps)
  : [1, 6, 11]
for (let i = 0; i < times.length; i++) {
  await page.evaluate(t => window.seek(t), times[i])
  await page.waitForTimeout(40)
  await page.screenshot({ path: `${outdir}/f_${String(i).padStart(4, '0')}.png` })
}
console.log(`frames written: ${times.length} -> ${outdir}`)
await browser.close()
if (problems && problems.length) process.exit(2)
