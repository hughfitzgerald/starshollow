const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const inputDir = process.argv[2];
if (!inputDir) {
  console.error("Usage: node batch-convert-yaml-to-glfshow.js <folder_path>");
  process.exit(1);
}

// Expand tabs to spaces using real tab-stop math instead of a flat
// replace. A flat `\t` -> '  ' swap breaks YAML nesting whenever the
// parent line's indent isn't itself a multiple of 2 (e.g. a 2-space
// "lights:" line followed by a tab-indented child lands at the SAME
// indent as "lights:", turning the child into a sibling key instead of
// a nested one, so step.lights parses as null and no lights ever make
// it into the show). Expanding to the next multiple of `tabSize`
// always advances past the parent's indent, preserving proper nesting.
function expandTabs(str, tabSize = 8) {
  return str.split('\n').map(line => {
    let result = '';
    let col = 0;
    for (const ch of line) {
      if (ch === '\t') {
        const spaces = tabSize - (col % tabSize);
        result += ' '.repeat(spaces);
        col += spaces;
      } else {
        result += ch;
        col += 1;
      }
    }
    return result;
  }).join('\n');
}

function convertFile(filePath, showName) {
  try {
    const raw = expandTabs(fs.readFileSync(filePath, 'utf8'));
    const data = yaml.load(raw);

    let output = `With CreateGlfShow("${showName}")\n`;

    data.forEach(step => {
      const time = step.time.toFixed(5);
      output += `  With .AddStep(${time}, Null, Null)\n`;

      const lights = step.lights || {};
      if (Object.keys(lights).length > 0) {
        output += `    .Lights = Array( _\n`;

        const entries = Object.entries(lights);
        entries.forEach(([name, color], index) => {
          const lineEnd = (index === entries.length - 1) ? '\n' : ', _\n';
          if(lineEnd=='\n')
          {
            output += `      "${name}|100|${color}")\n`;
          }else
          {
            output += `      "${name}|100|${color}"` + lineEnd;
          }
          
        });
      }

      output += `  End With\n`;
    });

    output += `End With\n`;

    const outputFileName = path.basename(filePath).replace(/\.(ya?ml)$/i, '.glf.vbs');
    const outputPath = path.join(path.dirname(filePath), outputFileName);
    fs.writeFileSync(outputPath, output, 'utf8');

    console.log(`✅ Converted: ${outputFileName}`);
  } catch (err) {
    console.error(`❌ Error converting ${filePath}: ${err.message}`);
  }
}

// Process all .yaml/.yml files in the folder
fs.readdirSync(inputDir).forEach(file => {
  const fullPath = path.join(inputDir, file);
  if (fs.statSync(fullPath).isFile() && /\.(ya?ml)$/i.test(file)) {
    const showName = path.basename(file, path.extname(file));
    convertFile(fullPath, showName);
  }
});
