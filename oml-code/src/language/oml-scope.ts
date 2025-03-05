import { AstNode, AstNodeDescription, AstUtils, DefaultScopeComputation, DefaultScopeProvider, interruptAndCheck, LangiumDocument, ReferenceInfo, Scope, Stream } from "langium";
import { isImport, isOntology, Ontology } from "./generated/ast.js";
import { CancellationToken } from "vscode-languageserver";

export class OMLScopeComputation extends DefaultScopeComputation {
    override async computeExportsForNode(parentNode: AstNode, document: LangiumDocument<AstNode>, children: (root: AstNode) => Iterable<AstNode> = AstUtils.streamContents, cancelToken: CancellationToken = CancellationToken.None): Promise<AstNodeDescription[]> {
        const directChildren = AstUtils.streamContents
        const exports: AstNodeDescription[] = [];
        this.exportNode(parentNode, exports, document);
        const candidateNodes: Stream<AstNode> = directChildren(parentNode).map((child: AstNode) => [child, directChildren(child)]).flat(2)
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
                const iri = this.createIRI(ontologyNamespace, unqualifiedName)
                exports.push(this.descriptions.createDescription(node, iri, document))
            }
        }
    }

    // Creates a qualified name for the given SpecializableTerm
    // Should only be used with terms original to the given document
    private createIRI = (namespace: string, name: string): string =>  {
        return namespace + name
    }
}

export class OMLScopeProvider extends DefaultScopeProvider {
    override getScope(context: ReferenceInfo): Scope {
        if (isImport(context.container))
            return super.getScope(context)
        const ontology = AstUtils.getDocument(context.container).parseResult.value as Ontology
        const namespaceToPrefix: Map<string, string> = new Map()
        namespaceToPrefix.set(ontology.namespace, ontology.prefix)
        ontology.ownedImports.forEach((i) => {
            if (i.prefix) {
                namespaceToPrefix.set(i.imported.$refText, i.prefix)
            }
        })
        const scopes = super.getScope(context).getAllElements()
            .filter((desc) => this.isMemberFromImportedOntology(namespaceToPrefix, desc.name))
            .map(desc => {
                const fullIRI = this.parseFullIRI(desc.name)
                let s = [
                    desc, 
                    {...desc, name: this.getAbbreviatedIRI(namespaceToPrefix.get(fullIRI.namespace!)!, fullIRI.name)}
                ]
                if (fullIRI.namespace == ontology.namespace) {
                    s = [...s, {...desc, name: fullIRI.name!} ]
                }
                return s;
                }
            ).flat()
        return this.createScope(scopes)
    }

    private isMemberFromImportedOntology = (importedOntologyNamespaces: Set<string> | Map<string, any>, IRI: string): boolean => {
        const { namespace } = this.parseFullIRI(IRI)
        return (namespace != undefined) ? importedOntologyNamespaces.has(namespace) : false
    }
    
    private getAbbreviatedIRI = (prefix: string, name: string): string => {
        return prefix + ':' + name
    }
    
    private parseFullIRI = (fullIRI: string): IRI => {
        var i = fullIRI.lastIndexOf('#')
        if (i == -1) {
            i = fullIRI.lastIndexOf('/')
        }
        if (i == -1) {
            return { name: fullIRI }
        }
        const namespace = fullIRI.substring(0, i+1)
        const name = fullIRI.substring(i + 1, fullIRI.length)
        return { namespace, name }
    }
}

type IRI = {
    namespace?: string,
    name: string
}
