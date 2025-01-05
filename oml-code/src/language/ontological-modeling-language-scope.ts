import { AstNode, AstNodeDescription, DefaultScopeComputation, LangiumDocument } from "langium";
import { isOntology, Ontology } from "./generated/ast.js";

export class OMLScopeComputation extends DefaultScopeComputation {
    protected override exportNode(node: AstNode, exports: AstNodeDescription[], document: LangiumDocument): void {
        if (isOntology(node) && node.namespace) {
            const { namespace } = node
            exports.push(this.descriptions.createDescription(node, namespace, document))
        } else {
            const unqualifiedName: string | undefined = this.nameProvider.getName(node)
            const ontologyNamespace: string | undefined = (document.parseResult.value as Ontology).namespace
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