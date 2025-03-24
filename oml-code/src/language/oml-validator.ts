import { AstNode, AstUtils, Reference, type ValidationAcceptor, type ValidationChecks } from 'langium';
import { isDescription, isDescriptionBundle, isVocabulary, isVocabularyBundle, Element, type OmlAstType, type Ontology, type ScalarEquivalenceAxiom, isOntology, Import } from './generated/ast.js';
import type { OmlServices } from './oml-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: OmlServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.OmlValidator;
    const checks: ValidationChecks<OmlAstType> = {
        Element: [ validator.checkImportedCrossReferences ],
        Ontology: [ validator.checkUnusedImports ],
        Import: [ validator.checkValidImports ],
        ScalarEquivalenceAxiom: [ validator.checkUniqueScalarEquivalenceProperties ],
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class OmlValidator {
    // A ScalarEquivalenceAxiom can only have one instance of each of the
    // properties listed in uniqueProps. This validation rule addresses
    // the fact that optional elements in unordered groups aren't supported
    // by langium
    checkUniqueScalarEquivalenceProperties(axiom: ScalarEquivalenceAxiom, accept: ValidationAcceptor): void {
        // Note: this list will need to be updated if more properties are added to the ScalarEquivalenceAxiom rule
        const uniqueProps = [
            'length',
            'minLength',
            'maxLength',
            'pattern',
            'language',
            'minInclusive',
            'minExclusive',
            'maxInclusive',
            'maxExclusive'
        ]
        
        for (const prop of uniqueProps) {
            // @ts-ignore
            if (axiom[prop].length > 1) {
                accept('error', `specifiy at most one of each property (duplicate ${prop})`, {
                    node: axiom
                })
            }
        }
    }

    checkValidImports(ownedImport: Import, accept: ValidationAcceptor): void {
        // OML supports several kinds of imports for each one of its ontology kinds:
        // * Vocabulary: extends Vocabulary, uses Description
        // * Vocabulary Bundle: extends VocabularyBundle, includes Vocabulary
        // * Description: extends Description, uses Vocabulary
        // * Description Bundle: extends DescriptionBundle, includes Description, uses Vocabulary, uses VocabularyBundle
        
        const ontology = ownedImport.$container

        // If we can't locate the node this import is referring to, an
        // error will be given by the scope provider
        if (ownedImport.imported?.ref == undefined) {
            return
        }
        if (ownedImport.kind == 'extends') {
            if (ownedImport.imported.ref.$type === ontology.$type) {
                return
            } else {
                accept(
                    'error',
                    `${ontology.$type}s can extend other ${ontology.$type}s (extending ${ownedImport.imported.ref.$type})`,
                    {node: ownedImport}
                )
            }
        }
        
        if (isVocabulary(ontology)) {
            if (ownedImport.kind != 'uses') {
                accept(
                    'error',
                    'Vocabularies can extend other Vocabularies and use Descriptions',
                    {node: ownedImport}
                )
            } else if (!isDescription(ownedImport.imported.ref)) {
                accept(
                    'error',
                    `Vocabularies use Descriptions (using ${ownedImport.imported.ref.$type})`,
                    {node: ownedImport}
                )
            }
        } else if (isVocabularyBundle(ontology)) {
            if (ownedImport.kind != 'includes') {
                accept(
                    'error',
                    'Vocabulary Bundles can extend other Vocabulary Bundles and include Vocabularies',
                    {node: ownedImport}
                )
            } else if (!isVocabulary(ownedImport.imported.ref)) {
                accept(
                    'error',
                    `Vocabulary Bundles can include Vocabularies (including ${ownedImport.imported.ref.$type})`,
                    {node: ownedImport}
                )
            }
        } else if (isDescription(ontology)) {
            if (ownedImport.kind != 'uses') {
                accept(
                    'error',
                    'Descriptions can extend other Descriptions and use Vocabularies',
                    {node: ownedImport}
                )
            } else if (!isVocabulary(ownedImport.imported.ref)) {
                accept(
                    'error',
                    `Descriptions can use Vocabularies (using ${ownedImport.imported.ref.$type})`,
                    {node: ownedImport}
                )
            }
        } else if (isDescriptionBundle(ontology)) {
            if (ownedImport.kind == 'includes') {
                if (!isDescription(ownedImport.imported.ref)) {
                    accept(
                        'error',
                        `Description bundles can include Descriptions (including ${ownedImport.imported.ref.$type}`,
                        {node: ownedImport}
                    )
                }
            } else if (ownedImport.kind == 'uses') {
                if (!isVocabulary(ownedImport.imported.ref) && !isVocabularyBundle(ownedImport.imported.ref)) {
                    accept(
                        'error',
                        `Description bundles can use Vocabularies or Vocabulary Bundles (using ${ownedImport.imported.ref.$type})`,
                        {node: ownedImport}
                    )
                }
            } else {
                accept(
                    'error',
                    'Description Bundles can extend Description Bundles, includes Descriptions, and use Vocabulary and Vocabulary Bundles',
                    {node: ownedImport}
                )
            }
        }
    }

    checkUnusedImports(ontology: Ontology, accept: ValidationAcceptor): void {
        const usedPrefixes: Set<string> = new Set();
        for (const element of AstUtils.streamAllContents(ontology)) {
            this.checkReferences(element, (key, value) => {
                const iri = value.$refText
                if (iri && !iri.startsWith('<') && iri.includes(':')) {
                    usedPrefixes.add(iri.substring(0, iri.indexOf(':')))
                }
            })
        }
        for (const ownedImport of ontology.ownedImports) {
            if (ownedImport.prefix && !usedPrefixes.has(ownedImport.prefix)) {
                accept(
                    'warning',
                    "Could not find a reference to prefix '"+ownedImport.prefix+"'",
                    {node: ownedImport, property: 'prefix'}
                )
            }
        }
    }

    checkImportedCrossReferences(element: Element, accept: ValidationAcceptor): void {
        this.checkReferences(element, (key, value) => {
            const ontology = this.getOntology(element)
            if (value.$refText && value.$refText.startsWith('<')) {
                if (!this.isImportedIn(value.$refText, ontology)) {
                    accept(
                        'error',
                        "Could not find an ontology import for term '"+value.$refText+"'",
                        {node: element, property: key}
                    )
                }
            }

        })
    }

    checkReferences(node: AstNode, callback: (key: any, value: any) => void): void {
        Object.entries(node).forEach(([key, value]) => {
            if (Array.isArray(value)) {
                value.forEach(item => {
                    if (this.isReference(item)) {
                        callback(key, item)
                    }
                });
            } else if (this.isReference(value)) {
                callback(key, value)
            }
          });
    }

    isReference<T extends AstNode>(obj: any): obj is Reference<T> {
        return obj !== null && typeof obj === 'object' && 'ref' in obj;
    }
      
    getOntology(element : Element): Ontology {
        while(element && !isOntology(element)) {
            element = element.$container
        }
        return element as Ontology
    }

    isImportedIn(iri: string, ontology: Ontology): boolean {
        var i = iri.lastIndexOf('#')
        if (i == -1) {
            i = iri.lastIndexOf('/')
        }
        if (i != -1) {
            const namespace = iri.substring(1, i+1)
            return ontology.namespace == namespace || ontology.ownedImports.some(i => i.imported && i.imported.ref?.namespace == namespace)
        }
        return false;
    }

}
