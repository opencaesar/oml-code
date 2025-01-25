// import type { ValidationAcceptor, ValidationChecks } from 'langium';
// import type { OntologicalModelingLanguageAstType } from './generated/ast.js';
import { ValidationAcceptor, ValidationChecks } from 'langium';
import type { OntologicalModelingLanguageServices } from './ontological-modeling-language-module.js';
import { OntologicalModelingLanguageAstType, ScalarEquivalenceAxiom } from './generated/ast.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: OntologicalModelingLanguageServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.OntologicalModelingLanguageValidator;
    const checks: ValidationChecks<OntologicalModelingLanguageAstType> = {
        ScalarEquivalenceAxiom: validator.checkUniqueScalarEquivalenceProperties
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class OntologicalModelingLanguageValidator {

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

}
