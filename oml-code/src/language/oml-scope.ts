import { AstNode, AstNodeDescription, AstUtils, DefaultScopeComputation, DefaultScopeProvider, LangiumDocument, ReferenceInfo, Scope } from "langium";
import { isImport, isMember, isOntology, Ontology } from "./generated/ast.js";
import { CancellationToken } from "vscode-languageserver";

export class OMLScopeComputation extends DefaultScopeComputation {
    override async computeExports(document: LangiumDocument, cancelToken = CancellationToken.None): Promise<AstNodeDescription[]> {
        return this.computeExportsForNode(document.parseResult.value, document, AstUtils.streamAllContents, cancelToken);
    }

    protected override exportNode(node: AstNode, exports: AstNodeDescription[], document: LangiumDocument): void {
        if (isOntology(node) && node.namespace) {
            const { namespace } = node
            exports.push(this.descriptions.createDescription(node, namespace, document))
        } else if (isMember(node) && node.name) {
            const namespace = (document.parseResult.value as Ontology).namespace
            if (namespace) {
                const iri = namespace+node.name
                exports.push(this.descriptions.createDescription(node, iri, document))
            }
        }
    }
}

export class OMLScopeProvider extends DefaultScopeProvider {
    override getScope(context: ReferenceInfo): Scope {
        if (isImport(context.container)) {
            return this.getScopeforImport(context)
        } else {
            return this.getScopeforMember(context)
        }
    }

    getScopeforImport(context: ReferenceInfo): Scope {
        return super.getScope(context)
    }

    getScopeforMember(context: ReferenceInfo): Scope {
        const namespaceToPrefix = new Map<string, string>();
        const uris = new Set<string>();

        // get the document
        const document = AstUtils.getDocument(context.container);

        // process current ontology
        const ontology = document.parseResult.value as Ontology;
        namespaceToPrefix.set(ontology.namespace, ontology.prefix)
        uris.add(document.uri.toString())

        // process imported ontologies
        ontology.ownedImports.forEach(i => {
            if (i.prefix) {
                namespaceToPrefix.set(i.imported.$refText, i.prefix)
                if (i.imported.ref) {
                    const importedDoc = AstUtils.getDocument(i.imported.ref)
                    if (importedDoc) {
                        uris.add(importedDoc.uri.toString())
                    }
                }
            }
        })
        
        // get the reference type
        const referenceType = this.reflection.getReferenceType(context);

        //get all possible descriptions from these ontologies
        const allDescriptions = this.indexManager.allElements(referenceType, uris).toArray();

        // derive all possible candidate descritions using iri, abbrev iri, and name
        const candidateDescriptions = new Set<AstNodeDescription>();
        allDescriptions.forEach(i => {
            // get iri and prefix
            const [namespace, name] = this.getIri(i)
            const prefix = namespaceToPrefix.get(namespace)
            //TODO: without next line, resolving links does not work (not sure why)
            candidateDescriptions.add(i);
            // add full iri version
            candidateDescriptions.add({...i, name:'<'+namespace+name+'>'});
            // add abbrev iri version
            candidateDescriptions.add({...i, name:prefix+':'+name});
            // add name version if local ref
            if (namespace == ontology.namespace) {
                candidateDescriptions.add({...i, name:name});
            }
        })
        
        //convert them to descriptions inside of a scope
        return this.createScope(candidateDescriptions);
    }

    getIri(desc: AstNodeDescription): [string, string] {
        const iri = desc.name
        let i = iri.lastIndexOf('#')
        if (i == -1) {
            i = iri.lastIndexOf('/')
        }
        return [iri.substring(0, i+1), iri.substring(i+1, iri.length)]
    }

}
