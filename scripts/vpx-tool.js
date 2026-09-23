// vpx-tool.js
// Cross-platform replacement for the old `pwsh -Command "..."` npm scripts.
// Reads the game name from ../gamename.txt and runs vpxtool extract/assemble.

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const projectRoot = path.join(__dirname, '..');
const gameNameFilePath = path.join(projectRoot, 'gamename.txt');

function main() {
    const mode = process.argv[2];

    if (mode !== 'extract' && mode !== 'assemble') {
        console.error('Usage: node vpx-tool.js <extract|assemble>');
        process.exit(1);
    }

    let gameName;
    try {
        const fileContent = fs.readFileSync(gameNameFilePath, 'utf8');
        gameName = fileContent.split(/\r?\n/)[0].trim();
    } catch (error) {
        console.error(`Error reading "${gameNameFilePath}":`, error.message);
        process.exit(1);
    }

    if (!gameName) {
        console.error(`Error: "${gameNameFilePath}" is empty.`);
        process.exit(1);
    }

    const target = mode === 'extract'
        ? path.join(projectRoot, `${gameName}.vpx`)
        : path.join(projectRoot, gameName);

    // Copyrighted sounds (mus_*, voc_*, sfx_*) aren't committed. Temporarily drop
    // their sounds.json entries so vpxtool can still assemble without them.
    const soundsJsonPath = path.join(target, 'sounds.json');
    let originalSoundsJson = null;
    if (mode === 'assemble' && fs.existsSync(soundsJsonPath)) {
        const text = fs.readFileSync(soundsJsonPath, 'utf8');
        const sounds = JSON.parse(text);
        const missing = [];
        const present = sounds.filter((sound) => {
            const ext = path.extname(sound.path.split(/[\\/]/).pop()).toLowerCase();
            const exists = fs.existsSync(path.join(target, 'sounds', sound.name + ext));
            if (!exists) missing.push(sound.name);
            return exists;
        });
        if (missing.length > 0) {
            console.warn(`Skipping ${missing.length} missing sounds (not in repo): ${missing.join(', ')}`);
            originalSoundsJson = text;
            fs.writeFileSync(soundsJsonPath, JSON.stringify(present, null, 2));
        }
    }

    console.log(`Running: vpxtool ${mode} ${target}`);
    let result;
    try {
        result = spawnSync('vpxtool', [mode, target], {
            stdio: 'inherit',
            shell: process.platform === 'win32',
        });
    } finally {
        if (originalSoundsJson !== null) {
            fs.writeFileSync(soundsJsonPath, originalSoundsJson);
        }
    }

    if (result.error) {
        console.error(`Failed to run vpxtool: ${result.error.message}`);
        process.exit(1);
    }

    process.exit(result.status ?? 0);
}

main();
