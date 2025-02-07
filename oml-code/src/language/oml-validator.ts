import type { ValidationChecks } from 'langium';
import type { OmlAstType } from './generated/ast.js';
import type { OmlServices } from './oml-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: OmlServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.OmlValidator;
    const checks: ValidationChecks<OmlAstType> = {};
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class OmlValidator {}
