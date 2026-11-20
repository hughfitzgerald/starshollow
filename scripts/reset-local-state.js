// reset-local-state.js
// Puts your local copy back to what a new player gets, so the defaults in the
// script are what you actually see:
//   starshollow.ini      drops [TableOption] (your option menu choices) and
//                        [TableOverride] (your difficulty/exposure/tone mapper);
//                        window placement, plugins, etc. are kept
//   starshollow_glf.ini  drops [HighScores] and [MachineVars] (high scores,
//                        credits, last game's scores)
//   <old name>_glf.ini   deleted if it's left over from before a rename
// Each changed file is backed up to <file>.bak first.
//
// Usage: npm run reset-local-state [-- --dry-run]

const fs = require('fs');
const path = require('path');

const projectRoot = path.join(__dirname, '..');
const game = fs.readFileSync(path.join(projectRoot, 'gamename.txt'), 'utf8').split(/\r?\n/)[0].trim();
const dryRun = process.argv.includes('--dry-run');

function removeSections(file, sections) {
    if (!fs.existsSync(file)) {
        console.log(`${path.basename(file)}: not found, nothing to do`);
        return;
    }
    const drop = new Set(sections.map(s => s.toLowerCase()));
    const text = fs.readFileSync(file, 'utf8');
    const eol = text.includes('\r\n') ? '\r\n' : '\n';
    const kept = [];
    const removed = [];
    let skipping = false;
    for (const line of text.split(/\r?\n/)) {
        const header = /^\s*\[(.+)\]\s*$/.exec(line);
        if (header) {
            skipping = drop.has(header[1].toLowerCase());
            if (skipping) removed.push(header[1]);
        }
        if (!skipping) kept.push(line);
    }
    if (!removed.length) {
        console.log(`${path.basename(file)}: none of [${sections.join('], [')}] present`);
        return;
    }
    console.log(`${path.basename(file)}: removing [${removed.join('], [')}]`);
    if (dryRun) return;
    fs.copyFileSync(file, `${file}.bak`);
    const out = kept.join(eol).trim();
    if (out) fs.writeFileSync(file, out + eol);
    else fs.rmSync(file);
}

removeSections(path.join(projectRoot, `${game}.ini`), ['TableOption', 'TableOverride']);
removeSections(path.join(projectRoot, `${game}_glf.ini`), ['HighScores', 'MachineVars']);

// glf names its ini after cGameName; any other *_glf.ini is from an old name
for (const f of fs.readdirSync(projectRoot)) {
    if (f.endsWith('_glf.ini') && f !== `${game}_glf.ini`) {
        console.log(`${f}: stale (game is now "${game}"), deleting`);
        if (!dryRun) fs.rmSync(path.join(projectRoot, f));
    }
}

if (dryRun) console.log('\nDry run; nothing changed.');
