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

    console.log(`Running: vpxtool ${mode} ${target}`);
    const result = spawnSync('vpxtool', [mode, target], {
        stdio: 'inherit',
        shell: process.platform === 'win32',
    });

    if (result.error) {
        console.error(`Failed to run vpxtool: ${result.error.message}`);
        process.exit(1);
    }

    process.exit(result.status ?? 0);
}

main();
