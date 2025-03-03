import type { ValidationAcceptor, ValidationChecks } from 'langium';
import { isDescription, isDescriptionBundle, isVocabulary, isVocabularyBundle, type OmlAstType, type Ontology, type ScalarEquivalenceAxiom } from './generated/ast.js';
import type { OmlServices } from './oml-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: OmlServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.OmlValidator;
    const checks: ValidationChecks<OmlAstType> = {
        ScalarEquivalenceAxiom: validator.checkUniqueScalarEquivalenceProperties,
        Ontology: validator.checkValidImports
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

    checkValidImports(ontology: Ontology, accept: ValidationAcceptor): void {
        // OML supports several kinds of imports for each one of its ontology kinds:
        // * Vocabulary: extends Vocabulary, uses Description
        // * Vocabulary Bundle: extends VocabularyBundle, includes Vocabulary
        // * Description: extends Description, uses Vocabulary
        // * Description Bundle: extends DescriptionBundle, includes Description, uses Vocabulary, uses VocabularyBundle
        
        for (const ownedImport of ontology.ownedImports) {
            // If we can't locate the node this import is referring to, an
            // error will be given by the scope provider
            if (!ownedImport.imported.ref) {
                return
            }
            if (ownedImport.kind.extension) {
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
                if (!ownedImport.kind.usage) {
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
                if (
                    !ownedImport.kind.inclusion
                ) {
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
                if (
                    !ownedImport.kind.usage
                ) {
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
                if (ownedImport.kind.inclusion) {
                    if (!isDescription(ownedImport.imported.ref)) {
                        accept(
                            'error',
                            `Description bundles can include Descriptions (including ${ownedImport.imported.ref.$type}`,
                            {node: ownedImport}
                        )
                    }
                } else if (ownedImport.kind.usage) {
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
    }
}
