import { expandToNode, joinToNode, toString } from 'langium/generate';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { extractDestinationAndName } from './cli-util.js';
export function generateJavaScript(model, filePath, destination) {
    const data = extractDestinationAndName(filePath, destination);
    const generatedFilePath = `${path.join(data.destination, data.name)}.js`;
    const fileNode = expandToNode `
        "use strict";

        ${joinToNode(model.ownedImports, greeting => `console.log('Hello, ${greeting.imported}!');`, { appendNewLineIfNotEmpty: true })}
    `.appendNewLineIfNotEmpty();
    if (!fs.existsSync(data.destination)) {
        fs.mkdirSync(data.destination, { recursive: true });
    }
    fs.writeFileSync(generatedFilePath, toString(fileNode));
    return generatedFilePath;
}
//# sourceMappingURL=generator.js.map