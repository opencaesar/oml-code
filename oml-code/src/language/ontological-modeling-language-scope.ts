import { AstNode, AstNodeDescription, AstUtils, DefaultScopeComputation, DefaultScopeProvider, LangiumDocument, ReferenceInfo, Scope } from "langium";
import { isImport, isOntology, OntologicalModelingLanguageTerminals, Ontology } from "./generated/ast.js";

export class OMLScopeComputation extends DefaultScopeComputation {
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

type ParsedIRI = {
    namespace: string,
    memberID?: string
}

export class OMLScopeProvider extends DefaultScopeProvider {
    override getScope(context: ReferenceInfo): Scope {
        if (isImport(context.container))
            return super.getScope(context)
        const document = AstUtils.getDocument(context.container).parseResult.value as Ontology
        const importedOntologyNamespaceToPrefix: Map<string, string|null> = new Map()
        document.ownedImports.forEach((i) => {
            importedOntologyNamespaceToPrefix.set(i.imported.$refText, i.prefix ? i.prefix : null)
        })
        
        return this.createScope(super.getScope(context).getAllElements()
            .filter((desc) => this.isLocalMember(desc) || this.isMemberFromImportedOntology(importedOntologyNamespaceToPrefix, desc.name))
            .map(desc => {
                const parsedIRI = this.parseFullIRI(desc.name)
                return !this.isMemberFromImportedOntology(importedOntologyNamespaceToPrefix, desc.name) ? desc : [desc, {
                ...desc,
                name: this.getAbbreviatedIRI(parsedIRI.memberID!, importedOntologyNamespaceToPrefix.get(parsedIRI.namespace)!)
            }]}).flat()
        )
    }

    private isMemberFromImportedOntology = (importedOntologyNamespaces: Set<string> | Map<string, any>, IRI: string): boolean => {
        const { namespace } = this.parseFullIRI(IRI)
        const ret =  importedOntologyNamespaces.has(namespace)
        // console.log(`${IRI} ${ret ? 'is': 'is not'} a member from one of our imported ontologies: ${importedOntologyNamespaces}`)
        return ret
    }
        
    private isLocalMember = (member: AstNodeDescription): boolean => {
        const ret = !OntologicalModelingLanguageTerminals.IRI.test(member.name)
        // console.log(`is ${member.name} a local member? ${ret}`)
        return ret
    }

    private getAbbreviatedIRI = (memberID: string, prefix: string): string => {
        return prefix + ':' + memberID
    }

    
    private parseFullIRI = (fullIRI: string): ParsedIRI => {
        // Remove trailing separator and add ending bracket
        const sepIndex = fullIRI.lastIndexOf('#') != -1 ? fullIRI.lastIndexOf('#') : fullIRI.lastIndexOf('/')
        const namespace = fullIRI.substring(0, sepIndex + 1) + '>'
        if (fullIRI[sepIndex] !== '>') {
            const memberID = fullIRI.substring(sepIndex + 1, fullIRI.length - 1)
            return { namespace, memberID }
        }
        else {
            return { namespace }
        } 
    }
}