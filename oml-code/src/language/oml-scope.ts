import { AstNode, AstNodeDescription, AstUtils, DefaultScopeComputation, interruptAndCheck, LangiumDocument, Stream } from "langium";
import { isOntology, Ontology } from "./generated/ast.js";
import { CancellationToken } from "vscode-languageserver";

export class OMLScopeComputation extends DefaultScopeComputation {
    override async computeExportsForNode(parentNode: AstNode, document: LangiumDocument<AstNode>, children: (root: AstNode) => Iterable<AstNode> = AstUtils.streamContents, cancelToken: CancellationToken = CancellationToken.None): Promise<AstNodeDescription[]> {
        const directChildren = AstUtils.streamContents
        const exports: AstNodeDescription[] = [];
        this.exportNode(parentNode, exports, document);
        const candidateNodes: Stream<AstNode> = directChildren(parentNode).map((child: AstNode) => [child, directChildren(child)]).flat(2)
        console.log(candidateNodes.toArray())
        for (const node of candidateNodes) {
            await interruptAndCheck(cancelToken);
            this.exportNode(node, exports, document);
        }
        return exports;
    }

    protected override exportNode(node: AstNode, exports: AstNodeDescription[], document: LangiumDocument): void {
        if (isOntology(node) && node.namespace) {
            const { namespace } = node
            exports.push(this.descriptions.createDescription(node, namespace, document))
        } else {
            const unqualifiedName: string | undefined = this.nameProvider.getName(node)
            const ontologyNamespace: string | undefined = (document.parseResult.value as Ontology)?.namespace
            if (unqualifiedName &&  ontologyNamespace) {
                const name = this.createIRI(unqualifiedName, ontologyNamespace)
                exports.push(this.descriptions.createDescription(node, name, document))
            }
        }
    }

    // Creates a qualified name for the given SpecializableTerm
    // Should only be used with terms original to the given document
    private createIRI = (memberName: string, ontologyNamespace: string): string =>  {
        return ontologyNamespace.substring(0, ontologyNamespace.length - 1) + memberName + '>'
    }
}