import createContainer from './di.config'
import { SprottyDiagramIdentifier } from "sprotty-vscode-webview";
import { SprottyLspEditStarter } from "sprotty-vscode-webview/lib/lsp/editing";
import { configureModelElement } from 'sprotty';
import { Container } from 'inversify';
import { PaletteButtonView } from './html-views';
import { PaletteButton } from 'sprotty-vscode-webview/lib/lsp/editing';

export class OMLSprottyStarter extends SprottyLspEditStarter {
    protected override createContainer(diagramIdentifier: SprottyDiagramIdentifier): Container {
        return createContainer(diagramIdentifier.clientId);
    }

    protected override addVscodeBindings(container: Container, diagramIdentifier: SprottyDiagramIdentifier): void {
        super.addVscodeBindings(container, diagramIdentifier);
        configureModelElement(container, 'button:create', PaletteButton, PaletteButtonView);
    }
}

new OMLSprottyStarter().start()