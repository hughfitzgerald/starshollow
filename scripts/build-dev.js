// build-dev.js
// Local equivalent of .github/workflows/build.yml, but leaves glf in dev mode
// and the table unlocked. Works on a staged copy of the table folder so the
// working tree isn't modified. Output: build/<game>-dev-<count>-<sha>.zip

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const projectRoot = path.join(__dirname, '..');
const buildRoot = path.join(projectRoot, 'build');
const stageDir = path.join(buildRoot, 'dev');
const VPINBALL = process.env.VPINBALL
    || '/Applications/VPinballX_BGFX.app/Contents/MacOS/VPinballX_BGFX';

function run(cmd, args, options = {}) {
    const result = spawnSync(cmd, args, {
        stdio: 'inherit',
        shell: process.platform === 'win32',
        ...options,
    });
    if (result.error || result.status !== 0) {
        console.error(`Failed: ${cmd} ${args.join(' ')}${result.error ? ` (${result.error.message})` : ''}`);
        process.exit(1);
    }
}

// <commit count, zero-padded so filenames sort in order>-<short sha>[-dirty]
function gitBuildId() {
    const git = (...args) => spawnSync('git', args, { cwd: projectRoot, encoding: 'utf8' });
    const sha = git('rev-parse', '--short', 'HEAD');
    const count = git('rev-list', '--count', 'HEAD');
    if (sha.status !== 0 || count.status !== 0) return 'local';
    const dirty = git('status', '--porcelain').stdout.trim();
    return `${count.stdout.trim().padStart(4, '0')}-${sha.stdout.trim()}${dirty ? '-dirty' : ''}`;
}

function main() {
    const game = fs.readFileSync(path.join(projectRoot, 'gamename.txt'), 'utf8').split(/\r?\n/)[0].trim();
    const build = `dev-${gitBuildId()}`;
    const name = `${game}-${build}`;

    // Concat the dev-mode script into <game>/script.vbs (no cached functions, glf_production_mode stays False)
    run('npx', ['grunt', 'concat:vpx'], { cwd: __dirname });
    const script = fs.readFileSync(path.join(projectRoot, game, 'script.vbs'), 'utf8');

    // Stage a copy of the table pack folder with the script in CRLF, as a Windows build would
    fs.rmSync(stageDir, { recursive: true, force: true });
    const stagedGame = path.join(stageDir, game);
    fs.cpSync(path.join(projectRoot, game), stagedGame, { recursive: true });
    fs.writeFileSync(path.join(stagedGame, 'script.vbs'), script.replace(/\r?\n/g, '\r\n'));

    // Convert the pack folder to <stage>/<game>.vpx using the same VPinball build used for editing
    const vpxOut = path.join(stageDir, `${game}.vpx`);
    fs.rmSync(vpxOut, { force: true });
    run(VPINBALL, ['-Convert', stagedGame, vpxOut]);
    if (!fs.existsSync(vpxOut)) {
        console.error(`Conversion produced no file at ${vpxOut}`);
        process.exit(1);
    }

    // Package release files
    const releaseDir = path.join(stageDir, 'release');
    fs.mkdirSync(releaseDir, { recursive: true });
    fs.renameSync(path.join(stageDir, `${game}.vpx`), path.join(releaseDir, `${name}.vpx`));

    const b2s = path.join(projectRoot, 'b2s', 'Projects', 'Stars Hollow Showdown', `${game}.directb2s`);
    if (!fs.existsSync(b2s)) {
        console.error(`Backglass not found at ${b2s}`);
        process.exit(1);
    }
    fs.copyFileSync(b2s, path.join(releaseDir, `${name}.directb2s`));

    const ini = path.join(projectRoot, 'default_ini_settings.txt');
    if (fs.existsSync(ini)) fs.copyFileSync(ini, path.join(releaseDir, `${name}.ini`));

    fs.cpSync(path.join(projectRoot, 'StarsHollowDMD'), path.join(releaseDir, 'StarsHollowDMD'), { recursive: true });

    // Zip it
    const zipPath = path.join(buildRoot, `${name}.zip`);
    fs.rmSync(zipPath, { force: true });
    if (process.platform === 'win32') {
        run('powershell', ['-NoProfile', '-Command', `Compress-Archive -Path '${releaseDir}\\*' -DestinationPath '${zipPath}'`]);
    } else {
        run('zip', ['-rq', zipPath, '.'], { cwd: releaseDir });
    }

    fs.rmSync(stageDir, { recursive: true, force: true });
    console.log(`\nDev build ready: ${path.relative(projectRoot, zipPath)}`);
}

main();
