import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { OntologicalModelingLanguageAstType, Person } from './generated/ast.js';
import type { OntologicalModelingLanguageServices } from './ontological-modeling-language-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: OntologicalModelingLanguageServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.OntologicalModelingLanguageValidator;
    const checks: ValidationChecks<OntologicalModelingLanguageAstType> = {
        Person: validator.checkPersonStartsWithCapital
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class OntologicalModelingLanguageValidator {

    checkPersonStartsWithCapital(person: Person, accept: ValidationAcceptor): void {
        if (person.name) {
            const firstChar = person.name.substring(0, 1);
            if (firstChar.toUpperCase() !== firstChar) {
                accept('warning', 'Person name should start with a capital.', { node: person, property: 'name' });
            }
        }
    }

}
