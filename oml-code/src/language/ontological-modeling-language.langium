grammar OntologicalModelingLanguage

entry Ontology:
    VocabularyBox;

VocabularyBox:
    Vocabulary;

Vocabulary:
    // ownedAnnotations+=Annotation*
    'vocabulary' namespace=NAMESPACE 'as' prefix=ID '{'
        (ownedImports+=(Extension) | ownedImports+=(Usage))*
        (ownedStatements+=VocabularyStatement)*
    '}';


VocabularyStatement:
    // Rule |
    SpecializableTerm;

// TODO: Implement specific import rules as defined by the spec:
// OML supports several kinds of imports for each one of its ontology kinds:
// * Vocabulary: extends Vocabulary, uses Description
// * Vocabulary Bundle: extends VocabularyBundle, includes Vocabulary
// * Description: extends Description, uses Vocabulary
// * Description Bundle: extends DescriptionBundle, includes Description, uses Vocabulary, uses VocabularyBundle

Import:
    Extension |
    Usage |
    Inclusion;

Extension:
    'extends' imported=[Vocabulary:NAMESPACE] ('as' prefix=ID)?;

Usage:
    'uses' imported=[Vocabulary:NAMESPACE] ('as' prefix=ID)?;

Inclusion:
    'includes' imported=[Vocabulary:NAMESPACE] ('as' prefix=ID)?;

// Rule:
//     ownedAnnotations+=Annotation*
//     ('rule' name=ID | 'ref' 'rule' ref=[Rule:ID]) ('['
//         (antecedent+=Predicate ('&' antecedent+=Predicate)* '->' consequent+=Predicate ('&' consequent+=Predicate)*)?

//     ']')?;

SpecializableTerm:
    Type |
    AnnotationProperty |
    // ScalarProperty |
    UnreifiedRelation;

Type:
    Entity/* |
    Scalar*/;

Entity:
    Aspect |
    Concept |
    RelationEntity;

Aspect:
    // ownedAnnotations+=Annotation*
	('aspect' name=ID | 'ref' 'aspect' ref=[Aspect:Ref]) 
    /* 
    ('['
		(ownedKeys+=KeyAxiom)* 
	']')?
    */
     /* (EntitySpecialization)? (EntityEquivalence)? */;

Concept:
	// ownedAnnotations+=Annotation*
	('concept' name=ID | 'ref' 'concept' ref=[Concept:Ref]) 
    /* 
    ('['
		(ownedEnumeration=InstanceEnumerationAxiom)?
		(ownedKeys+=KeyAxiom)* 
	']')? 
    */
    (EntitySpecialization)? /* (EntityEquivalence)? */;

// Langium doesn't support optional elements for unordered groups, so these
// keyword statements have to be mandatory for now
RelationEntity:
    // ownedAnnotations+=Annotation*
	('relation' 'entity' name=ID | 'ref' 'relation' 'entity' ref=[RelationEntity:Ref]) ('['
		('from' sources+=[Entity:Ref] (',' sources+=[Entity:Ref])*)?
		('to' targets+=[Entity:Ref] (',' targets+=[Entity:Ref])*)?
		/* (forwardRelation=ForwardRelation)? */
		/* (reverseRelation=ReverseRelation)? */
		(
            (functional?='functional') &
            (inverseFunctional?='inverse' 'functional') &
            (symmetric?='symmetric') &
            (asymmetric?='asymmetric') &
            (reflexive?='reflexive') &
            (irreflexive?='irreflexive') &
            (transitive?='transitive')
         )
		/* (ownedKeys+=KeyAxiom)* */
	']')? (EntitySpecialization)? /* (EntityEquivalence)? */;

fragment EntitySpecialization infers Entity:
	'<' (ownedSpecializations+=SpecializationAxiom (',' ownedSpecializations+=SpecializationAxiom)* 
		/*
        |
		(ownedSpecializations+=SpecializationAxiom (',' ownedSpecializations+=SpecializationAxiom)*)? '['
			ownedPropertyRestrictions+=PropertyRestrictionAxiom*
		']'
        */);



AnnotationProperty:
	// ownedAnnotations+=Annotation*
	(('annotation' 'property' name=ID) | ('ref' 'annotation' 'property' ref=[AnnotationProperty:Ref]))
		/* (PropertySpecialization)? (PropertyEquivalence)? */;

Relation:
	UnreifiedRelation;

ReverseRelation:
	// ownedAnnotations+=Annotation*
	'reverse' name=ID;

UnreifiedRelation:
	// ownedAnnotations+=Annotation*
	('relation' name=ID | 'ref' 'relation' ref=[Relation:Ref]) ('['
		('from' sources+=[Entity:Ref] (',' sources+=[Entity:Ref])*)?
		('to' targets+=[Entity:Ref] (',' targets+=[Entity:Ref])*)?
		(reverseRelation=ReverseRelation)?
		(
            (functional?='functional') &
            (inverseFunctional?='inverse' 'functional') &
            (symmetric?='symmetric') &
            (asymmetric?='asymmetric') &
            (reflexive?='reflexive') &
            (irreflexive?='irreflexive') &
            (transitive?='transitive')
        )
	']')? /* (PropertySpecialization)? (PropertyEquivalence)? */;

SpecializationAxiom:
	superTerm=[SpecializableTerm:Ref];


//--------------

Ref returns string: 							ID | QNAME | IRI;

// terminal CrossRef returns string: 						QNAME | IRI;

// terminal Boolean returns string:						BOOLEAN_STR;

// terminal UnsignedInteger returns number: 				UNSIGNED_INTEGER_STR;

// terminal Integer returns number: 						UNSIGNED_INTEGER_STR | INTEGER_STR;

// terminal Decimal returns number:						DECIMAL_STR;

// terminal Double returns number:							DOUBLE_STR;

//----------------------------

// terminal BOOLEAN_STR returns boolean:					/(false|true)/;

// terminal UNSIGNED_INTEGER_STR returns number:			NUMERIC+;

// terminal INTEGER_STR returns number:					('+'|'-')? NUMERIC+;

// terminal DECIMAL_STR returns number:					('+'|'-')? (NUMERIC+('.'NUMERIC*)? | ('.'NUMERIC+));

// terminal DOUBLE_STR returns number:						('+'|'-')? (NUMERIC+('.'NUMERIC*)? | ('.'NUMERIC+)) ('e'|'E') ('+'|'-')? NUMERIC+;

// terminal STRING returns number:							('"' (!('"'|'\\') | '\\'.)* '"') | ("'" (!("'"|'\\') | '\\'.)* "'") | ("'''" -> "'''") | '"""' -> '"""';

terminal NAMESPACE returns string:						/<[^# ]*[#/]>/; // /<[^> #]*[#/]>/; // '<' (!('>'|' '|'#'))* ('#'|'/') '>' 

terminal IRI returns string:							/<[^ ]*>/; // '<' (!('>'|' '))* '>'

terminal ID returns string:								/[_a-zA-Z][\w_]*/;

terminal QNAME returns string:							IDFRAG ':' IDFRAG;

hidden terminal ML_COMMENT: 							/\/\*[\s\S]*?\*\//;
 
hidden terminal SL_COMMENT:                             /\/\/[^\n\r]*/;
 
hidden terminal WS:                                     /\s+/;

//----------------------------

terminal fragment IDFRAG:								'^'? (ALPHA|NUMERIC|SPECIAL) (ALPHA|NUMERIC|SPECIAL|'$')*;

terminal fragment ALPHA:								/[a-zA-Z]/;

terminal fragment NUMERIC: 								/[0-9]/;

terminal fragment SPECIAL:								/[-_.~%]/;