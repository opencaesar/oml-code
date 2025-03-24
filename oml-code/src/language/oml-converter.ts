import {CstNode, DefaultValueConverter, GrammarAST, ValueType} from 'langium';

export class OmlValueConverter extends DefaultValueConverter {

    protected override runConverter(rule: GrammarAST.AbstractRule, input: string, cstNode: CstNode): ValueType {
        if (rule.name == 'NAMESPACE' && cstNode.grammarSource.$type == 'RuleCall') {
            return input.substring(1, input.length-1)
        } else {
            return super.runConverter(rule, input, cstNode);
        }
    }
}