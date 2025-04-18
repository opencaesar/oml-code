import { GeneratorContext, LangiumDiagramGenerator } from 'langium-sprotty';
import { SLabel, SModelRoot, SNode, SPort } from 'sprotty-protocol';
import { Import, Ontology } from './generated/ast.js';

export class OMLDiagramGenerator extends LangiumDiagramGenerator {

    protected generateRoot(args: GeneratorContext<Ontology>): SModelRoot {
        const { document } = args;
        const ontology = document.parseResult.value;
        const graph = {
            type: 'graph',
            id: ontology.namespace ?? 'root',
            children: [
                ...ontology.ownedImports.map(s => this.generateNode(s, args))
            ]
        };
        // this.traceProvider.trace(graph, sm);
        return graph;
    }

    protected generateNode(importNode: Import, ctx: GeneratorContext<Ontology>): SNode {
        const { idCache } = ctx;
        const nodeId = idCache.uniqueId(importNode.imported.$refText, importNode);
        const label: SLabel = {
            type: 'label',
            id: idCache.uniqueId(nodeId + '.label'),
            text: importNode.imported.$refText
        };
        this.traceProvider.trace(label, importNode, 'name');
        const node = {
            type: 'node',
            id: nodeId,
            children: [
                label,
                <SPort>{
                    type: 'port',
                    id: idCache.uniqueId(nodeId + '.newTransition')
                }
            ],
            layout: 'stack',
            layoutOptions: {
                paddingTop: 10.0,
                paddingBottom: 10.0,
                paddingLeft: 10.0,
                paddingRight: 10.0
            }
        };
        this.traceProvider.trace(node, importNode);
        this.markerProvider.addDiagnosticMarker(node, importNode, ctx);
        return node;
    }

    // protected generateEdge(transition: Transition, ctx: GeneratorContext<StateMachine>): SEdge {
    //     const { idCache } = ctx;
    //     const sourceId = idCache.getId(transition.$container);
    //     const targetId = idCache.getId(transition.state?.ref);
    //     const edgeId = idCache.uniqueId(`${sourceId}:${transition.event?.ref?.name}:${targetId}`, transition);
    //     const label: SLabel = {
    //         type: 'label:xref',
    //         id: idCache.uniqueId(edgeId + '.label'),
    //         text: transition.event?.ref?.name ?? ''
    //     }
    //     this.traceProvider.trace(label, transition, 'event');
    //     const edge = {
    //         type: 'edge',
    //         id: edgeId,
    //         sourceId: sourceId!,
    //         targetId: targetId!,
    //         children: [
    //             label
    //         ]
    //     };
    //     this.traceProvider.trace(edge, transition);
    //     this.markerProvider.addDiagnosticMarker(edge, transition, ctx);
    //     return edge;
    // }

}