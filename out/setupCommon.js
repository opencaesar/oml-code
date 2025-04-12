import getEditorServiceOverride from '@codingame/monaco-vscode-editor-service-override';
import getKeybindingsServiceOverride from '@codingame/monaco-vscode-keybindings-service-override';
import { useOpenEditorStub } from 'monaco-editor-wrapper/vscode/services';
import { useWorkerFactory } from 'monaco-editor-wrapper/workerFactory';
export const defineUserServices = () => {
    return {
        userServices: Object.assign(Object.assign({}, getEditorServiceOverride(useOpenEditorStub)), getKeybindingsServiceOverride()),
        debugLogging: true
    };
};
export const configureMonacoWorkers = () => {
    // override the worker factory with your own direct definition
    useWorkerFactory({
        ignoreMapping: true,
        workerLoaders: {
            editorWorkerService: () => new Worker(new URL('monaco-editor/esm/vs/editor/editor.worker.js', import.meta.url), { type: 'module' })
        }
    });
};
export const configureWorker = () => {
    // vite does not extract the worker properly if it is URL is a variable
    const lsWorker = new Worker(new URL('./language/main-browser', import.meta.url), {
        type: 'module',
        name: 'Oml Language Server'
    });
    return {
        options: {
            $type: 'WorkerDirect',
            worker: lsWorker
        }
    };
};
//# sourceMappingURL=setupCommon.js.map