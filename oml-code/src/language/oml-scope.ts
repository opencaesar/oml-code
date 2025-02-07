import { AstNodeDescription, DefaultScopeComputation, LangiumDocument } from "langium";
import { CancellationToken } from "vscode-languageserver";

export class OMLScopeComputation extends DefaultScopeComputation {
    override async computeExports(document: LangiumDocument, cancelToken = CancellationToken.None): Promise<AstNodeDescription[]> {
        console.log("I am running :)")
        return [] //this.computeExportsForNode(document.parseResult.value, document, undefined, cancelToken);
    }
}