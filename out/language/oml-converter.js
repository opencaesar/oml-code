import { DefaultValueConverter } from 'langium';
export class OmlValueConverter extends DefaultValueConverter {
    runConverter(rule, input, cstNode) {
        if (rule.name == 'NAMESPACE' && cstNode.grammarSource.$type == 'RuleCall') {
            return input.substring(1, input.length - 1);
        }
        else {
            return super.runConverter(rule, input, cstNode);
        }
    }
}
//# sourceMappingURL=oml-converter.js.map