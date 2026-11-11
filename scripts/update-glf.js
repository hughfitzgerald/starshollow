// update-glf.js
// Builds glf.vbs from a local checkout of the GLF fork (hughfitzgerald/vpx-glf)
// and writes it to src/glf/glf.vbs, with a first line naming the branch and
// commit it was built from. Never edit src/glf/glf.vbs by hand; change the fork.
//
// Usage:  npm run update-glf
//         GLF_DIR=/path/to/vpx-glf npm run update-glf
//         npm run update-glf -- --allow-branch   (build from a branch other than starshollow)

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const EXPECTED_BRANCH = 'starshollow';
const projectRoot = path.join(__dirname, '..');
const glfDir = path.resolve(process.env.GLF_DIR || path.join(projectRoot, '..', 'vpx-glf'));
const glfScripts = path.join(glfDir, 'scripts');
const dest = path.join(__dirname, 'src', 'glf', 'glf.vbs');
const allowBranch = process.argv.includes('--allow-branch');

function fail(message) {
    console.error(`update-glf: ${message}`);
    process.exit(1);
}

function git(...args) {
    const result = spawnSync('git', args, { cwd: glfDir, encoding: 'utf8' });
    if (result.error || result.status !== 0) fail(`git ${args.join(' ')} failed in ${glfDir}`);
    return result.stdout.trim();
}

if (!fs.existsSync(path.join(glfScripts, 'Gruntfile.js'))) {
    fail(`no GLF checkout at ${glfDir}. Clone hughfitzgerald/vpx-glf next to this repo, or set GLF_DIR.`);
}
if (!fs.existsSync(path.join(glfScripts, 'node_modules'))) {
    fail(`run "npm install" in ${glfScripts} first.`);
}

const branch = git('rev-parse', '--abbrev-ref', 'HEAD');
if (branch !== EXPECTED_BRANCH && !allowBranch) {
    fail(`the GLF checkout is on "${branch}", not "${EXPECTED_BRANCH}". Switch branches, or pass -- --allow-branch.`);
}

// Rebuild scripts/vpx-glf.vbs from scripts/src
const build = spawnSync('npx', ['grunt', 'concat'], {
    cwd: glfScripts,
    stdio: 'inherit',
    shell: process.platform === 'win32',
});
if (build.error || build.status !== 0) fail('grunt concat failed in the GLF checkout.');

// Stamp after building, so uncommitted source edits show up as -dirty
const sha = git('rev-parse', '--short', 'HEAD');
const dirty = git('status', '--porcelain', '--untracked-files=no') ? '-dirty' : '';
const date = new Date().toISOString().slice(0, 10);
const stamp = `' GLF build: hughfitzgerald/vpx-glf ${branch} @ ${sha}${dirty} (${date}). Do not edit; see FORK.md in that repo.`;

const built = fs.readFileSync(path.join(glfScripts, 'vpx-glf.vbs'), 'utf8');
const eol = built.includes('\r\n') ? '\r\n' : '\n';
fs.writeFileSync(dest, stamp + eol + built);

console.log(`update-glf: wrote ${path.relative(projectRoot, dest)} from ${branch} @ ${sha}${dirty}`);
if (dirty) console.log('update-glf: the GLF checkout has uncommitted changes; commit them before committing glf.vbs here.');
