// vpinball.js
// Single source of truth for the VPinball executable. Override with the VPINBALL env var.
//   require('./vpinball').VPINBALL      -> path, for use from other scripts
//   node vpinball.js -Play ../starshollow -> launches VPinball with the given args

const { spawnSync } = require('child_process');

const VPINBALL = process.env.VPINBALL
    || '/Applications/VPinballX_BGFX.app/Contents/MacOS/VPinballX_BGFX';

module.exports = { VPINBALL };

if (require.main === module) {
    const result = spawnSync(VPINBALL, process.argv.slice(2), { stdio: 'inherit' });
    if (result.error) {
        console.error(`Failed to launch ${VPINBALL}: ${result.error.message}`);
        process.exit(1);
    }
    process.exit(result.status ?? 1);
}
