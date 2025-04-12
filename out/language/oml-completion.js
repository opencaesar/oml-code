import { DefaultCompletionProvider } from "langium/lsp";
import { isDescription, isDescriptionBox, isMember, isOntology, isVocabulary, isVocabularyBundle } from "./generated/ast.js";
export class OmlCompletionProvider extends DefaultCompletionProvider {
    getReferenceCandidates(refInfo, _context) {
        return this.scopeProvider.getScope(refInfo).getAllElements().filter(d => d.name.startsWith('<'));
    }
    buildCompletionTextEdit(context, label, newText) {
        const start = context.textDocument.positionAt(context.tokenOffset);
        const end = context.position;
        return { newText, range: { start, end } };
    }
    fillCompletionItem(context, item) {
        var _a, _b;
        if ('nodeDescription' in item) {
            const desc = item.nodeDescription;
            if (isMember(desc.node)) {
                var [namespace, name] = this.getIri(desc.node);
                const ontology = context.document.parseResult.value;
                const imp = ontology.ownedImports.find(i => { var _a; return ((_a = i.imported.ref) === null || _a === void 0 ? void 0 : _a.namespace) == namespace; });
                const importedOntology = this.getOntology(desc.node);
                const prefix = (imp && imp.prefix) ? imp.prefix : importedOntology.prefix;
                const abbreviatedIri = (ontology != importedOntology ? prefix + ':' : '') + name;
                item = Object.assign(Object.assign({}, item), { detail: namespace, label: abbreviatedIri });
                if (!imp && ontology != importedOntology) {
                    const importStatement = this.getImportStatment(ontology, importedOntology);
                    const lastImport = ontology.ownedImports.at(-1);
                    var start = context.textDocument.positionAt(lastImport
                        ? ((_a = lastImport.$cstNode) === null || _a === void 0 ? void 0 : _a.offset) + ((_b = lastImport.$cstNode) === null || _b === void 0 ? void 0 : _b.length)
                        : context.textDocument.getText().indexOf('{') + 1);
                    const addImportStatement = { newText: "\n\n\t" + importStatement, range: { start: start, end: start } };
                    item = Object.assign(Object.assign({}, item), { additionalTextEdits: [addImportStatement] });
                }
            }
        }
        return super.fillCompletionItem(context, item);
    }
    getIri(member) {
        return [this.getOntology(member).namespace, member.name];
    }
    getOntology(element) {
        while (element && !isOntology(element)) {
            element = element.$container;
        }
        return element;
    }
    getImportStatment(importing, imported) {
        if (importing.$type == imported.$type) {
            return 'extends <' + imported.namespace + '> as ' + imported.prefix;
        }
        else if (isVocabulary(importing) && isDescription(imported)) {
            return 'uses <' + imported.namespace + '> as ' + imported.prefix;
        }
        else if (isDescriptionBox(importing) && isVocabulary(imported)) {
            return 'uses <' + imported.namespace + '> as ' + imported.prefix;
        }
        else if (isVocabularyBundle(importing) && isVocabulary(imported)) {
            return 'includes <' + imported.namespace + '> as ' + imported.prefix;
        }
        return undefined;
    }
}
//# sourceMappingURL=oml-completion.js.map