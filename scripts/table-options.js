// table-options.js
// Builds the <table>.ini [TableOption] section that ships next to the .vpx.
//
// A table option's default lives in exactly one place: the 5th argument of its
// Table1.Option(...) call in scripts/src. VPX falls back to that default for any
// key missing from the ini, so the shipped ini only needs the values that should
// differ, listed in release_ini_overrides.txt. If there are none, no ini ships.
//
// The scan also fails the build if:
//   - an override names an option no Table1.Option call declares
//   - an override value is outside that option's min..max
//   - one option name is declared with different arguments in different places
//
// Usage:
//   node table-options.js --check               scan and validate only
//   node table-options.js --out <file.ini>      also write the release ini (only if there are overrides)
// From build-dev.js: require('./table-options').buildIni({ extra: {...} })

const fs = require('fs');
const path = require('path');

const projectRoot = path.join(__dirname, '..');
const srcRoot = path.join(__dirname, 'src');
const overridesFile = path.join(projectRoot, 'release_ini_overrides.txt');

// VPX stores an option under its display name with every character other than
// a letter, digit or underscore replaced by '_':
//   "Tilt Sensitivity (digital nudge)" -> "Tilt_Sensitivity__digital_nudge_"
function vpxKey(name) {
    return name.replace(/[^A-Za-z0-9_]/g, '_');
}

function listVbs(dir) {
    const out = [];
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const full = path.join(dir, entry.name);
        if (entry.isDirectory()) out.push(...listVbs(full));
        else if (entry.name.endsWith('.vbs')) out.push(full);
    }
    return out;
}

// Drop a VBScript ' comment, ignoring apostrophes inside "strings".
function stripComment(line) {
    let inString = false;
    for (let i = 0; i < line.length; i++) {
        if (line[i] === '"') inString = !inString;
        else if (line[i] === "'" && !inString) return line.slice(0, i);
    }
    return line;
}

// Split on commas that are not inside parentheses or strings.
function splitArgs(s) {
    const args = [];
    let depth = 0, inString = false, cur = '';
    for (const ch of s) {
        if (ch === '"') inString = !inString;
        if (!inString) {
            if (ch === '(') depth++;
            if (ch === ')') depth--;
            if (ch === ',' && depth === 0) { args.push(cur.trim()); cur = ''; continue; }
        }
        cur += ch;
    }
    if (cur.trim()) args.push(cur.trim());
    return args;
}

function scanOptions() {
    const options = new Map(); // key -> { name, min, max, def, args, where }
    const errors = [];
    for (const file of listVbs(srcRoot)) {
        const rel = path.relative(projectRoot, file);
        const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
        // Join " _" continuations into logical lines, comments removed
        let logical = '', startLine = 0;
        for (let i = 0; i < lines.length; i++) {
            const code = stripComment(lines[i]).trimEnd();
            if (!logical) startLine = i + 1;
            if (code.endsWith(' _') || code === '_') {
                logical += code.slice(0, -1) + ' ';
                continue;
            }
            logical += code;
            const re = /Table1\.Option\(/g;
            let m;
            while ((m = re.exec(logical))) {
                let depth = 1, j = m.index + m[0].length, inString = false;
                for (; j < logical.length && depth > 0; j++) {
                    const ch = logical[j];
                    if (ch === '"') inString = !inString;
                    else if (!inString && ch === '(') depth++;
                    else if (!inString && ch === ')') depth--;
                }
                const argStr = logical.slice(m.index + m[0].length, j - 1);
                const args = splitArgs(argStr);
                const nameMatch = /^"(.*)"$/.exec(args[0] || '');
                const where = `${rel}:${startLine}`;
                if (!nameMatch || args.length < 6) {
                    errors.push(`${where}: can't parse Table1.Option(${argStr})`);
                    continue;
                }
                const name = nameMatch[1];
                const key = vpxKey(name);
                const normalized = args.map(a => a.replace(/\s+/g, ' ')).join(', ');
                const opt = {
                    name, where, args: normalized,
                    min: Number(args[1]), max: Number(args[2]), def: Number(args[4]),
                };
                const prev = options.get(key);
                if (prev && prev.args !== opt.args) {
                    errors.push(`"${name}" is declared differently at ${prev.where} and ${where}; every Table1.Option call for one option must pass the same arguments`);
                } else if (!prev) {
                    options.set(key, opt);
                }
            }
            logical = '';
        }
    }
    return { options, errors };
}

// release_ini_overrides.txt: "Key = value" lines, optionally under [TableOption].
// Keys may be the display name ("Glf Debug Log") or the VPX key ("Glf_Debug_Log").
// Lines starting with ; or # are comments.
function readOverrides() {
    const overrides = {};
    if (!fs.existsSync(overridesFile)) return overrides;
    for (const raw of fs.readFileSync(overridesFile, 'utf8').split(/\r?\n/)) {
        const line = raw.trim();
        if (!line || line.startsWith(';') || line.startsWith('#') || line.startsWith('[')) continue;
        const eq = line.indexOf('=');
        if (eq < 0) continue;
        overrides[vpxKey(line.slice(0, eq).trim())] = line.slice(eq + 1).trim();
    }
    return overrides;
}

// Returns { text, errors }. text is null when there is nothing to override.
function buildIni({ extra = {} } = {}) {
    const { options, errors } = scanOptions();
    const values = { ...readOverrides() };
    for (const [k, v] of Object.entries(extra)) values[vpxKey(k)] = String(v);

    for (const [key, value] of Object.entries(values)) {
        const opt = options.get(key);
        if (!opt) {
            errors.push(`Override "${key}" doesn't match any Table1.Option in scripts/src`);
            continue;
        }
        const n = Number(value);
        if (Number.isNaN(n) || n < opt.min || n > opt.max) {
            errors.push(`Override ${key} = ${value} is outside ${opt.min}..${opt.max} ("${opt.name}" at ${opt.where})`);
        }
    }

    const keys = Object.keys(values);
    const text = keys.length
        ? ['[TableOption]', ...keys.map(k => `${k} = ${values[k]}`), ''].join('\r\n')
        : null;
    return { text, errors, options };
}

module.exports = { vpxKey, scanOptions, readOverrides, buildIni };

if (require.main === module) {
    const outIdx = process.argv.indexOf('--out');
    const out = outIdx > 0 ? process.argv[outIdx + 1] : null;
    const { text, errors, options } = buildIni();
    if (errors.length) {
        for (const e of errors) console.error(`error: ${e}`);
        process.exit(1);
    }
    console.log(`${options.size} table options found, ${text ? 'overrides present' : 'no overrides'}`);
    if (out) {
        if (text) {
            fs.writeFileSync(out, text);
            console.log(`Wrote ${out}`);
        } else {
            console.log('No overrides; not shipping an ini');
        }
    }
}
