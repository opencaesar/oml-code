import { AstNode, AstNodeDescription, AstUtils, DefaultScopeComputation, DefaultScopeProvider, EMPTY_SCOPE, LangiumDocument, MultiMap, PrecomputedScopes, ReferenceInfo, Scope, Stream, stream } from "langium";
import { Concept, Description, DescriptionBundle, Entity, Import, isDescription, isDescriptionBundle, isImport, isMember, isOntology, isTerm, isVocabulary, isVocabularyBundle, Ontology, Relation, RelationEntity, Vocabulary, VocabularyBox, VocabularyBundle } from "./generated/ast.js";
import { CancellationToken } from "vscode-languageserver";

export class OmlScopeComputation extends DefaultScopeComputation {
    override async computeExports(document: LangiumDocument, cancelToken = CancellationToken.None): Promise<AstNodeDescription[]> {
        return this.computeExportsForNode(document.parseResult.value, document, AstUtils.streamAllContents, cancelToken);
    }

    protected override exportNode(node: AstNode, exports: AstNodeDescription[], document: LangiumDocument): void {
        if (isOntology(node) && node.namespace) {
            exports.push(this.descriptions.createDescription(node, '<'+node.namespace+'>', document))
        } else if (isMember(node) && node.name) {
            const ontology = document.parseResult.value as Ontology
            exports.push(this.descriptions.createDescription(node, '<'+ontology.namespace+node.name+'>', document))
        }
    }

    override async computeLocalScopes(document: LangiumDocument): Promise<PrecomputedScopes> {
        const ontology = document.parseResult.value as Ontology;
        const scopes = new MultiMap<AstNode, AstNodeDescription>();
        const localDescriptions: AstNodeDescription[] = [];
        for (const node of AstUtils.streamAllContents(ontology)) {
            if (isMember(node) && node.name) {
                localDescriptions.push(this.descriptions.createDescription(node, node.name, document));
                localDescriptions.push(this.descriptions.createDescription(node, ontology.prefix+':'+node.name, document));
            }
        }
        scopes.addAll(ontology, localDescriptions);
        return scopes;
    }
}

export class OmlScopeProvider extends DefaultScopeProvider {
    override getScope(context: ReferenceInfo): Scope {
        const scopes: Array<Stream<AstNodeDescription>> = [];
        var referenceType: string
        try {
            referenceType = this.getReferenceType(context);
        } catch(error) {
            return EMPTY_SCOPE
        }

        const precomputed = AstUtils.getDocument(context.container).precomputedScopes;
        if (precomputed) {
            let currentNode: AstNode | undefined = context.container;
            do {
                const allDescriptions = precomputed.get(currentNode);
                if (allDescriptions.length > 0) {
                    scopes.push(stream(allDescriptions).filter(
                        desc => this.reflection.isSubtype(desc.type, referenceType)));
                }
                currentNode = currentNode.$container;
            } while (currentNode);
        }

        if (!isImport(context.container)) {
            const abbrevIriDescriptions = new Set<AstNodeDescription>();
            const document = AstUtils.getDocument(context.container);
            const ontology = document.parseResult.value as Ontology;
            const namespaceToPrefix = new Map<string, string>();
            ontology.ownedImports.filter(i => i.prefix).forEach(i => {
                var namespace = i.imported.$refText
                namespaceToPrefix.set(namespace.substring(1, namespace.length-1), i.prefix!)
            })
            this.indexManager.allElements(referenceType).forEach( i => {
                const [namespace, name] = this.getIri(i.name)
                const prefix = namespaceToPrefix.get(namespace)
                if (prefix) {
                    abbrevIriDescriptions.add({...i, name:prefix+':'+name})
                }
            })
            scopes.push(stream(abbrevIriDescriptions))
        }

        let result: Scope = this.getGlobalScope(referenceType, context);
        for (let i = scopes.length - 1; i >= 0; i--) {
            result = this.createScope(scopes[i], result);
        }
        return result;
    }

    getIri(iri: string): [string, string] {
        var i = iri.lastIndexOf('#')
        if (i == -1) {
            i = iri.lastIndexOf('/')
        }
        return [iri.substring(1, i+1), iri.substring(i+1, iri.length-1)]
    }

    getReferenceType(context: ReferenceInfo) : string {
        const referenceId = `${context.container.$type}:${context.property}`;
        if (referenceId == 'SpecializationAxiom:superTerm') {
            var type : string|undefined
            if (isTerm(context.container.$container)) {
                type = context.container.$container.$type
            } else if (isTerm(context.container.$container?.$container)) {
                type = context.container.$container?.$container.$type
            }
            if (type) {
                if (type == Concept || type == RelationEntity) {
                    return Entity
                } if (type.endsWith(Relation)) {
                    return Relation
                } else {
                    return type
                }
            }
        } else if (referenceId == 'Import:imported') {
            const kind = (context.container as Import).kind
            const ont = context.container.$container as Ontology
            if (isVocabulary(ont)) {
                switch(kind) {
                    case  'extends': return Vocabulary
                    case  'uses': return Description
                }
            } else if (isDescription(ont)) {
                switch(kind) {
                    case  'extends': return Description
                    case  'uses': return Vocabulary
                }
            } else if (isVocabularyBundle(ont)) {
                switch(kind) {
                    case  'extends': return VocabularyBundle
                    case  'includes': return Vocabulary
                }
            } else if (isDescriptionBundle(ont)) {
                switch(kind) {
                    case  'extends': return DescriptionBundle
                    case  'includes': return Description
                    case  'uses': return VocabularyBox
                }
            }
        }
        return this.reflection.getReferenceType(context);
    }
}

