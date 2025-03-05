import {CstNode, DefaultValueConverter, GrammarAST, ValueType} from 'langium';

export class OmlValueConverter extends DefaultValueConverter {

    protected override runConverter(rule: GrammarAST.AbstractRule, input: string, cstNode: CstNode): ValueType {
        if (rule.name == 'NAMESPACE' || rule.name == 'IRI') {
            // 'convertString' simply removes the first and last character of the input
            return input.substring(1, input.length-1)
            //return super.runConverter(rule, input, cstNode);
        } else {
            return super.runConverter(rule, input, cstNode);
        }
    }
}