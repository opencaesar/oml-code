// Monarch syntax highlighting for the oml language.
export default {
    keywords: [
        'all','annotation','as','aspect','asymmetric','builtIn','builtin','bundle','concept','description','differentFrom','domain','entity','exactly','extends','forward','from','functional','includes','instance','inverse','irreflexive','key','language','length','max','maxExclusive','maxInclusive','maxLength','min','minExclusive','minInclusive','minLength','oneOf','pattern','property','range','ref','reflexive','relation','restricts','reverse','rule','sameAs','scalar','self','some','symmetric','to','transitive','uses','vocabulary'
    ],
    operators: [
        '$','&',',','->',':','<','=','@','^^'
    ],
    symbols: /\$|&|\(|\)|,|->|:|<|=|@|\[|\]|\^\^|\{|\}/,

    tokenizer: {
        initial: [
            { regex: /(false|true)/, action: {"token":"BOOLEAN"} },
            { regex: /((\+|-)?((([0-9])+(\.([0-9])*)?)|(\.([0-9])+))(e|E)(\+|-)?([0-9])+)/, action: {"token":"DOUBLE"} },
            { regex: /(((\+|-)?(([0-9])+(\.([0-9])*)))|(\.([0-9])+))/, action: {"token":"DECIMAL"} },
            { regex: /((\+|-)([0-9])+)/, action: {"token":"INTEGER"} },
            { regex: /([0-9])+/, action: {"token":"UNSIGNED_INTEGER"} },
            { regex: /(((("""([\s\S]*?"""))|('''([\s\S]*?''')))|('([\s\S]*?')))|("([\s\S]*?")))/, action: {"token":"string"} },
            { regex: /<[^# ]*[#/]>/, action: {"token":"NAMESPACE"} },
            { regex: /<[^ ]*>/, action: {"token":"IRI"} },
            { regex: /(((((([a-zA-Z])|([0-9]))|([-_.~%]))(((([a-zA-Z])|([0-9]))|([-_.~%]))|\$)*)):((((([a-zA-Z])|([0-9]))|([-_.~%]))(((([a-zA-Z])|([0-9]))|([-_.~%]))|\$)*)))/, action: {"token":"QNAME"} },
            { regex: /(\^?((((([a-zA-Z])|([0-9]))|([-_.~%]))(((([a-zA-Z])|([0-9]))|([-_.~%]))|\$)*)))/, action: { cases: { '@keywords': {"token":"keyword"}, '@default': {"token":"ID"} }} },
            { regex: /(((([a-zA-Z])|([0-9]))|([-_.~%]))(((([a-zA-Z])|([0-9]))|([-_.~%]))|\$)*)/, action: { cases: { '@keywords': {"token":"keyword"}, '@default': {"token":"IDFRAG"} }} },
            { regex: /[a-zA-Z]/, action: { cases: { '@keywords': {"token":"keyword"}, '@default': {"token":"ALPHA"} }} },
            { regex: /[0-9]/, action: {"token":"NUMERIC"} },
            { regex: /[-_.~%]/, action: {"token":"SPECIAL"} },
            { include: '@whitespace' },
            { regex: /@symbols/, action: { cases: { '@operators': {"token":"operator"}, '@default': {"token":""} }} },
        ],
        whitespace: [
            { regex: /\/\*/, action: {"token":"comment","next":"@comment"} },
            { regex: /\/\/[^\n\r]*/, action: {"token":"comment"} },
            { regex: /\s+/, action: {"token":"white"} },
        ],
        comment: [
            { regex: /[^/\*]+/, action: {"token":"comment"} },
            { regex: /\*\//, action: {"token":"comment","next":"@pop"} },
            { regex: /[/\*]/, action: {"token":"comment"} },
        ],
    }
};
