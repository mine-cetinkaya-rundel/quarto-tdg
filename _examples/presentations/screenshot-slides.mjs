#!/usr/bin/env node
// Screenshot each slide of a revealjs presentation.
// Usage: node screenshot-slides.mjs <html-file> <output-prefix> [width] [height]
//
// Outputs: <output-prefix>-slide-1.png, <output-prefix>-slide-2.png, etc.

import { chromium } from 'playwright';
import { fileURLToPath } from 'url';
import path from 'path';

const [htmlFile, outputPrefix, widthArg, heightArg] = process.argv.slice(2);

if (!htmlFile || !outputPrefix) {
  console.error('Usage: node screenshot-slides.mjs <html-file> <output-prefix> [width] [height]');
  process.exit(1);
}

const width = parseInt(widthArg) || 1920;
const height = parseInt(heightArg) || 1080;

async function screenshotSlides() {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.setViewportSize({ width, height });

  // Convert to file:// URL if it's a local path
  const url = htmlFile.startsWith('http')
    ? htmlFile
    : `file://${path.resolve(htmlFile)}`;

  await page.goto(url, { waitUntil: 'networkidle' });

  // Wait for Reveal.js to initialize
  await page.waitForFunction(() => typeof Reveal !== 'undefined' && Reveal.isReady());

  // Get all slide indices (RevealJS uses h/v coordinates for horizontal/vertical navigation)
  const slideIndices = await page.evaluate(() => {
    return Reveal.getSlides().map(slide => Reveal.getIndices(slide));
  });

  console.log(`Found ${slideIndices.length} slides`);

  // Screenshot each slide
  for (let i = 0; i < slideIndices.length; i++) {
    const { h, v } = slideIndices[i];

    // Navigate to slide using horizontal/vertical indices
    await page.evaluate(({ h, v }) => {
      Reveal.slide(h, v);
    }, { h, v });

    // Wait for any transitions/animations
    await page.waitForTimeout(300);

    const outputPath = `${outputPrefix}-slide-${i + 1}.png`;
    await page.screenshot({ path: outputPath });
    console.log(`Saved ${outputPath} (h=${h}, v=${v})`);
  }

  await browser.close();
  console.log(`Screenshotted ${slideIndices.length} slides`);
}

screenshotSlides().catch((err) => {
  console.error('Error:', err.message);
  process.exit(1);
});
