// import type { Ontology } from '../language/generated/ast.js';
// import chalk from 'chalk';
import { Command } from 'commander';
import { OntologicalModelingLanguageLanguageMetaData } from '../language/generated/module.js';
// import { createOntologicalModelingLanguageServices } from '../language/ontological-modeling-language-module.js';
// import { extractAstNode } from './cli-util.js';
// import { generateJavaScript } from './generator.js';
// import { NodeFileSystem } from 'langium/node';
import * as url from 'node:url';
import * as fs from 'node:fs/promises';
import * as path from 'node:path';
const __dirname = url.fileURLToPath(new URL('.', import.meta.url));

const packagePath = path.resolve(__dirname, '..', '..', 'package.json');
const packageContent = await fs.readFile(packagePath, 'utf-8');

// export const generateAction = async (fileName: string, opts: GenerateOptions): Promise<void> => {
//     const services = createOntologicalModelingLanguageServices(NodeFileSystem).OntologicalModelingLanguage;
//     const model = await extractAstNode<Model>(fileName, services);
//     const generatedFilePath = generateJavaScript(model, fileName, opts.destination);
//     console.log(chalk.green(`JavaScript code generated successfully: ${generatedFilePath}`));
// };

export type GenerateOptions = {
    destination?: string;
}

export default function(): void {
    const program = new Command();

    program.version(JSON.parse(packageContent).version);

    const fileExtensions = OntologicalModelingLanguageLanguageMetaData.fileExtensions.join(', ');
    program
        .command('parseAndValidate')
        .argument('<file>', `source file (possible file extensions: ${fileExtensions})`)
        .description('Indicates where a program parses & validates successfully, but produces no output code')
        // .action(generateAction);

    program.parse(process.argv);
}
