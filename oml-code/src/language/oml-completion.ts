import { CompletionContext, CompletionValueItem, DefaultCompletionProvider } from "langium/lsp";
import { CompletionItem, TextEdit } from "vscode-languageserver";
import { Element, isDescription, isDescriptionBox, isMember, isOntology, isVocabulary, isVocabularyBundle, Member, Ontology } from "./generated/ast.js";
import { AstNodeDescription, ReferenceInfo, Stream } from "langium";

export class OmlCompletionProvider extends DefaultCompletionProvider {

    protected override getReferenceCandidates(refInfo: ReferenceInfo, _context: CompletionContext): Stream<AstNodeDescription> {
        return this.scopeProvider.getScope(refInfo).getAllElements().filter(d => d.name.startsWith('<'));
    }

    protected override buildCompletionTextEdit(context: CompletionContext, label: string, newText: string): TextEdit | undefined {
        const start = context.textDocument.positionAt(context.tokenOffset);
        const end = context.position;
        return { newText, range: { start, end } };
    }

    protected override fillCompletionItem(context: CompletionContext, item: CompletionValueItem): CompletionItem | undefined {
        if ('nodeDescription' in item) {
            const desc = item.nodeDescription
            if (isMember(desc.node)) {
                var [namespace, name] = this.getIri(desc.node)
                const ontology = context.document.parseResult.value as Ontology
                const imp = ontology.ownedImports.find(i => i.imported.ref?.namespace == namespace)
                const importedOntology = this.getOntology(desc.node)
                const prefix = (imp && imp.prefix) ? imp.prefix : importedOntology.prefix
                const abbreviatedIri = (ontology != importedOntology ? prefix+':' : '')+name
                item = {...item, detail: namespace, label: abbreviatedIri}
                if (!imp && ontology != importedOntology) {
                    const importStatement = this.getImportStatment(ontology, importedOntology)
                    const lastImport = ontology.ownedImports.at(-1)
                    var start = context.textDocument.positionAt(lastImport
                        ? lastImport.$cstNode?.offset! + lastImport.$cstNode?.length! 
                        : context.textDocument.getText().indexOf('{')+1)
                    const addImportStatement = {newText: "\n\n\t"+importStatement, range: {start: start, end: start}}
                    item = {...item, additionalTextEdits: [ addImportStatement ] }
                }
            }
        }
        return super.fillCompletionItem(context, item)
    }

    getIri(member: Member): [string, string] {
        return [ this.getOntology(member).namespace, member.name! ]
    }

    getOntology(element : Element): Ontology {
        while(element && !isOntology(element)) {
            element = element.$container
        }
        return element as Ontology
    }

    getImportStatment(importing: Ontology, imported: Ontology): string|undefined {
        if (importing.$type == imported.$type) {
            return 'extends <' + imported.namespace + '> as ' + imported.prefix
        } else if (isVocabulary(importing) && isDescription(imported)) {
            return 'uses <' + imported.namespace + '> as ' + imported.prefix
        } else if (isDescriptionBox(importing) && isVocabulary(imported)) {
            return 'uses <' + imported.namespace + '> as ' + imported.prefix
        } else if (isVocabularyBundle(importing) && isVocabulary(imported)) {
            return 'includes <' + imported.namespace + '> as ' + imported.prefix
        }
        return undefined
    }

}
