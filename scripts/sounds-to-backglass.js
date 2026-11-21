#!/usr/bin/env node
// Sets "output_target" to "backglass" for every voc_, mus_ and sfx_ sound JSON
// in starshollow/sounds that currently targets "playfield".
// Usage: npm run sounds-to-backglass [-- --dry-run]

const fs = require('fs');
const path = require('path');

const soundsDir = path.resolve(__dirname, '../starshollow/sounds');
const dryRun = process.argv.includes('--dry-run');
const pattern = /("output_target"\s*:\s*)"playfield"/g;

let changed = 0;
for (const file of fs.readdirSync(soundsDir)) {
  if (!/^(voc|mus|sfx)_.*\.json$/.test(file)) continue;
  const filePath = path.join(soundsDir, file);
  const text = fs.readFileSync(filePath, 'utf8');
  if (!pattern.test(text)) continue;
  pattern.lastIndex = 0;
  if (!dryRun) fs.writeFileSync(filePath, text.replace(pattern, '$1"backglass"'));
  console.log(`${dryRun ? '[dry-run] ' : ''}${file}`);
  changed++;
}
console.log(`${dryRun ? 'Would update' : 'Updated'} ${changed} file(s).`);
