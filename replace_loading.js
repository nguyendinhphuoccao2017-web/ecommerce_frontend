const fs = require('fs');
const path = require('path');

function replaceInDir(dir) {
    fs.readdirSync(dir).forEach(file => {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            replaceInDir(fullPath);
        } else if (fullPath.endsWith('.dart')) {
            let content = fs.readFileSync(fullPath, 'utf8');
            if (content.includes('CircularProgressIndicator()')) {
                content = content.replace(/CircularProgressIndicator\(\)/g, 'CircularProgressIndicator(color: const Color(0xFFDB3022))');
                fs.writeFileSync(fullPath, content);
            }
        }
    });
}

replaceInDir(path.join(__dirname, 'lib'));
