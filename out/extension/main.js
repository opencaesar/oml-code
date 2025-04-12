import * as path from 'node:path';
import { LanguageClient, TransportKind } from 'vscode-languageclient/node.js';
let client;
// This function is called when the extension is activated.
export function activate(context) {
    client = startLanguageClient(context);
}
// This function is called when the extension is deactivated.
export function deactivate() {
    if (client) {
        return client.stop();
    }
    return undefined;
}
function startLanguageClient(context) {
    const serverModule = context.asAbsolutePath(path.join('out', 'language', 'main.cjs'));
    // The debug options for the server
    // --inspect=6009: runs the server in Node's Inspector mode so VS Code can attach to the server for debugging.
    // By setting `process.env.DEBUG_BREAK` to a truthy value, the language server will wait until a debugger is attached.
    const debugOptions = { execArgv: ['--nolazy', `--inspect${process.env.DEBUG_BREAK ? '-brk' : ''}=${process.env.DEBUG_SOCKET || '6009'}`] };
    // If the extension is launched in debug mode then the debug server options are used
    // Otherwise the run options are used
    const serverOptions = {
        run: { module: serverModule, transport: TransportKind.ipc },
        debug: { module: serverModule, transport: TransportKind.ipc, options: debugOptions }
    };
    // Options to control the language client
    const clientOptions = {
        documentSelector: [{ scheme: '*', language: 'oml' }]
    };
    // Create the language client and start the client.
    const client = new LanguageClient('oml', 'OML', serverOptions, clientOptions);
    // Start the client. This will also launch the server
    client.start();
    return client;
}
//# sourceMappingURL=main.js.map