import { AstNodeDescription, DefaultScopeComputation, LangiumDocument } from "langium";
import { LangiumServices } from "langium/lsp";
import { CancellationToken } from "vscode-languageclient";

export class OMLScopeComputation extends DefaultScopeComputation {
    constructor(services: LangiumServices) {
        super(services);
    }

    override async computeExports(document: LangiumDocument, cancelToken = CancellationToken.None): Promise<AstNodeDescription[]> {
        return [] //this.computeExportsForNode(document.parseResult.value, document, undefined, cancelToken);
    }
}