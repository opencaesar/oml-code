import { type Module, inject } from 'langium';
import { createDefaultModule, createDefaultSharedModule, type DefaultSharedModuleContext, type PartialLangiumServices } from 'langium/lsp';
import { OMLGeneratedModule, OmlGeneratedSharedModule } from './generated/module.js';
import { OmlValidator, registerValidationChecks } from './oml-validator.js';
import { OmlScopeComputation, OmlScopeProvider } from './oml-scope.js';
import { OmlValueConverter } from './oml-converter.js';
import { OmlCompletionProvider } from './oml-completion.js';
import { LangiumSprottyServices, LangiumSprottySharedServices, SprottyDefaultModule, SprottyDiagramServices, SprottySharedModule } from 'langium-sprotty';
import { OMLDiagramGenerator } from './oml-diagram-generator.js';

/**
 * Declaration of custom services - add your own service classes here.
 */
export type OmlAddedServices = {
    validation: {
        OmlValidator: OmlValidator
    }
}

/**
 * Union of Langium default services and your custom services - use this as constructor parameter
 * of custom service classes.
 */
export type OmlServices = LangiumSprottyServices & OmlAddedServices

/**
 * Dependency injection module that overrides Langium default services and contributes the
 * declared custom services. The Langium defaults can be partially specified to override only
 * selected services, while the custom services must be fully specified.
 */
export const OmlModule: Module<OmlServices, PartialLangiumServices & SprottyDiagramServices & OmlAddedServices> = {
    diagram: {
        DiagramGenerator: services => new OMLDiagramGenerator(services)
    },
    parser: {
        ValueConverter: () => new OmlValueConverter()
    },
    validation: {
        OmlValidator: () => new OmlValidator()
    },
    references: {
        ScopeComputation: (services) => new OmlScopeComputation(services),
        ScopeProvider: (services) => new OmlScopeProvider(services)
    },
    lsp: {
        CompletionProvider: (services) => new OmlCompletionProvider(services),
    }
};

/**
 * Create the full set of services required by Langium.
 *
 * First inject the shared services by merging two modules:
 *  - Langium default shared services
 *  - Services generated by langium-cli
 *
 * Then inject the language-specific services by merging three modules:
 *  - Langium default language-specific services
 *  - Services generated by langium-cli
 *  - Services specified in this file
 *
 * @param context Optional module context with the LSP connection
 * @returns An object wrapping the shared services and the language-specific services
 */
export function createOmlServices(context: DefaultSharedModuleContext): {
    shared: LangiumSprottySharedServices,
    Oml: OmlServices
} {
    const shared = inject(
        createDefaultSharedModule(context),
        OmlGeneratedSharedModule,
        SprottySharedModule
    );
    const Oml = inject(
        createDefaultModule({ shared }),
        OMLGeneratedModule,
        SprottyDefaultModule,
        OmlModule
    );
    shared.ServiceRegistry.register(Oml);
    registerValidationChecks(Oml);
    if (!context.connection) {
        // We don't run inside a language server
        // Therefore, initialize the configuration provider instantly
        shared.workspace.ConfigurationProvider.initialized({});
    }
    return { shared, Oml };
}
