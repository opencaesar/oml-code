grammar OML

entry Ontology:
    VocabularyBox
    | DescriptionBox;

Annotation:
    '@' {infer Annotation} property=[AnnotationProperty:Ref] (AnnotationValue ("," AnnotationValue)*)?;

fragment AnnotationValue:
    literalValues+=Literal | referencedValues+=[Member:Ref];

// This rule is needed for AnnotationValue
Member:
	Aspect |
	Concept |
	RelationEntity |
	Scalar |
	AnnotationProperty |
	ScalarProperty |
	UnreifiedRelation |
	BuiltIn |
	Rule |
	ConceptInstance |
	RelationInstance;


VocabularyBox:
    Vocabulary |
    VocabularyBundle;

Vocabulary:
    ownedAnnotations+=Annotation*
    'vocabulary' namespace=NAMESPACE 'as' prefix=ID '{'
        (ownedImports+=(Extension) | ownedImports+=(Usage))*
        (ownedStatements+=VocabularyStatement)*
    '}';

VocabularyBundle:
    ownedAnnotations+=Annotation*
    'vocabulary' 'bundle' namespace=NAMESPACE 'as' prefix=ID '{'
        ownedImports+=(Extension|Inclusion)*
    '}';

DescriptionBox:
	Description |
	DescriptionBundle;

Description:
	ownedAnnotations+=Annotation*
	'description' namespace=NAMESPACE 'as' prefix=ID '{'
		ownedImports+=(Extension|Usage)*
		ownedStatements+=DescriptionStatement*
	'}';

DescriptionBundle:
	ownedAnnotations+=Annotation*
	'description' 'bundle' namespace=NAMESPACE 'as' prefix=ID '{'
		ownedImports+=(Extension|Usage|Inclusion)*
	'}';

SpecializableTerm:
    Type |
    AnnotationProperty |
    ScalarProperty |
    UnreifiedRelation;

Type:
    Entity |
    Scalar;

Entity:
    Aspect |
    Concept |
    RelationEntity;

Aspect:
    ownedAnnotations+=Annotation*
	('aspect' name=ID | 'ref' 'aspect' ref=[Aspect:Ref]) 
    ('['
		(ownedKeys+=KeyAxiom)* 
	']')?
    (EntitySpecialization)? (EntityEquivalence)?;

Concept:
	ownedAnnotations+=Annotation*
	('concept' name=ID | 'ref' 'concept' ref=[Concept:Ref]) 
    ('['
		(ownedEnumeration=InstanceEnumerationAxiom)?
		(ownedKeys+=KeyAxiom)* 
	']')? 
    (EntitySpecialization)? (EntityEquivalence)?;

RelationEntity:
    ownedAnnotations+=Annotation*
	('relation' 'entity' name=ID | 'ref' 'relation' 'entity' ref=[RelationEntity:Ref]) ('['
		('from' sources+=[Entity:Ref] (',' sources+=[Entity:Ref])*)?
		('to' targets+=[Entity:Ref] (',' targets+=[Entity:Ref])*)?
		(forwardRelation=ForwardRelation)?
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
		(ownedKeys+=KeyAxiom)*
	']')? (EntitySpecialization)? (EntityEquivalence)?;

fragment EntitySpecialization infers Entity:
	'<' (ownedSpecializations+=SpecializationAxiom (',' ownedSpecializations+=SpecializationAxiom)* 
        |
		(ownedSpecializations+=SpecializationAxiom (',' ownedSpecializations+=SpecializationAxiom)*)? '['
			ownedPropertyRestrictions+=PropertyRestrictionAxiom*
		']');

fragment EntityEquivalence infers Entity:
	'=' ownedEquivalences+=EntityEquivalenceAxiom (',' ownedEquivalences+=EntityEquivalenceAxiom)*;

EntityEquivalenceAxiom:
	superEntities+=[Entity:Ref] ('&' superEntities+=[Entity:Ref])*
	|
	{infer EntityEquivalenceAxiom} 
	(superEntities+=[Entity:Ref] ('&' superEntities+=[Entity:Ref])*)? '['
		ownedPropertyRestrictions+=PropertyRestrictionAxiom*
	']';

Scalar:
	ownedAnnotations+=Annotation*
	('scalar' name=ID | 'ref' 'scalar' ref=[Scalar:Ref]) ('['
		 ownedEnumeration=LiteralEnumerationAxiom
	']')? (ScalarSpecialization)? (ScalarEquivalence)?;

fragment ScalarSpecialization infers Scalar:
	'<' ownedSpecializations+=SpecializationAxiom (',' ownedSpecializations+=SpecializationAxiom)*;

fragment ScalarEquivalence infers Scalar:
	'=' ownedEquivalences+=ScalarEquivalenceAxiom (',' ownedEquivalences+=ScalarEquivalenceAxiom)*;

/*

ScalarEquivalenceAxiom:
	superScalar=[Scalar:Ref] ('['
		(('length' length=UnsignedInteger)? &
		 ('minLength' minLength=UnsignedInteger)? &
		 ('maxLength' maxLength=UnsignedInteger)? &
		 ('pattern' pattern=STRING)? &
		 ('language' language=ID)? &
		 ('minInclusive' minInclusive=Literal)? &
		 ('minExclusive' minExclusive=Literal)? &
		 ('maxInclusive' maxInclusive=Literal)? &
		 ('maxExclusive' maxExclusive=Literal)?)
	']')?;

* * * * * * * * * *

    Because optional elements in unordered groups are unsupported, I don't see
    how to port this rule while retaining its original behavior.
    My main idea for how to replicate similar behavior to the original is using
    the following rule in conjunction with a validation rule that doesn't
    allow you to populate a field multiple times.
    Additionally, because fields like 'length' may be populated multiple times,
    only grab the first value if one is present

* * * * * * * * * *

*/

ScalarEquivalenceAxiom:
	superScalar=[Scalar:Ref] ('['
		(('length' length+=UnsignedInteger) |
		 ('minLength' minLength+=UnsignedInteger) |
		 ('maxLength' maxLength+=UnsignedInteger) |
		 ('pattern' pattern+=STRING) |
		 ('language' language+=ID) |
		 ('minInclusive' minInclusive+=Literal) |
		 ('minExclusive' minExclusive+=Literal) |
		 ('maxInclusive' maxInclusive+=Literal) |
		 ('maxExclusive' maxExclusive+=Literal))*
	']')?;

Property:
	AnnotationProperty |
	SemanticProperty;

AnnotationProperty:
	ownedAnnotations+=Annotation*
	(('annotation' 'property' name=ID) | ('ref' 'annotation' 'property' ref=[AnnotationProperty:Ref]))
	    (PropertySpecialization)? (PropertyEquivalence)?;


SemanticProperty:
	ScalarProperty |
	Relation;

ScalarProperty:
	ownedAnnotations+=Annotation*
	('scalar' 'property' name=ID | 'ref' 'scalar' 'property' ref=[ScalarProperty:Ref]) ('['
		('domain' domains+=[Entity:Ref] (',' domains+=[Entity:Ref])*)?
		('range' ranges+=[Scalar:Ref] (',' ranges+=[Scalar:Ref])*)?
		(functional?='functional')?
	']')? (PropertySpecialization)? (PropertyEquivalence)?;

Relation:
	ForwardRelation |
	ReverseRelation |
	UnreifiedRelation;

ForwardRelation:
	ownedAnnotations+=Annotation*
	'forward' name=ID;

ReverseRelation:
	ownedAnnotations+=Annotation*
	'reverse' name=ID;


UnreifiedRelation:
	ownedAnnotations+=Annotation*
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
	']')? (PropertySpecialization)? (PropertyEquivalence)?;


fragment PropertySpecialization infers SpecializableProperty:
	'<' ownedSpecializations+=SpecializationAxiom (',' ownedSpecializations+=SpecializationAxiom)*;

fragment PropertyEquivalence infers SpecializableProperty:
	'=' ownedEquivalences+=PropertyEquivalenceAxiom (',' ownedEquivalences+=PropertyEquivalenceAxiom)*;

PropertyEquivalenceAxiom:
	superProperty=[Property:Ref];

Rule:
	ownedAnnotations+=Annotation*
	('rule' name=ID | 'ref' 'rule' ref=[Rule:Ref]) ('['
		(antecedent+=Predicate ('&' antecedent+=Predicate)* '->' consequent+=Predicate ('&' consequent+=Predicate)*)?
	']')?;

BuiltIn:
	ownedAnnotations+=Annotation*
	('builtin' name=ID | 'ref' 'builtin' ref=[BuiltIn:Ref]);

AnonymousInstance:
	AnonymousConceptInstance |
	AnonymousRelationInstance;

AnonymousConceptInstance:
	{infer AnonymousConceptInstance} (':' type=[Concept:Ref])? '['
		ownedPropertyValues+=PropertyValueAssertion*
	']';
	
AnonymousRelationInstance:
	target=[NamedInstance:Ref] '['
		ownedPropertyValues+=PropertyValueAssertion*
	']';

NamedInstance:
	ConceptInstance |
	RelationInstance;

ConceptInstance:
	ownedAnnotations+=Annotation*
	('instance' name=ID | 'ref' 'instance' ref=[ConceptInstance:Ref]) (':' ownedTypes+=ConceptTypeAssertion (',' ownedTypes+=ConceptTypeAssertion)*)? ('['
		ownedPropertyValues+=PropertyValueAssertion*
	']')?;
	
RelationInstance:
	ownedAnnotations+=Annotation*
	('relation' 'instance' name=ID | 'ref' 'relation' 'instance' ref=[RelationInstance:Ref]) (':' ownedTypes+=RelationTypeAssertion (',' ownedTypes+=RelationTypeAssertion)*)? ('['
		('from' sources+=[NamedInstance:Ref] (',' sources+=[NamedInstance:Ref])*)? 
		('to' targets+=[NamedInstance:Ref] (',' targets+=[NamedInstance:Ref])*)?
		ownedPropertyValues+=PropertyValueAssertion*
	']')?;

VocabularyStatement:
	Rule |
	BuiltIn |
	SpecializableTerm;

DescriptionStatement:
	NamedInstance;

Import:
    Extension |
    Usage |
    Inclusion;

Extension infers Import:
    kind=Extends imported=[Vocabulary:NAMESPACE] ('as' prefix=ID)?;

Usage infers Import:
    kind=Uses imported=[Vocabulary:NAMESPACE] ('as' prefix=ID)?;

Inclusion infers Import:
    kind=Includes imported=[Vocabulary:NAMESPACE] ('as' prefix=ID)?;

SpecializationAxiom:
	superTerm=[SpecializableTerm:Ref];

PropertyRestrictionAxiom:
	PropertySelfRestrictionAxiom |
	PropertyRangeRestrictionAxiom |
	PropertyCardinalityRestrictionAxiom |
	PropertyValueRestrictionAxiom;

PropertyRangeRestrictionAxiom:
	'restricts' kind=(RangeRestrictionKind) property=[SemanticProperty:Ref] 'to' range=[Type:Ref];

PropertyCardinalityRestrictionAxiom:
	'restricts' property=[SemanticProperty:Ref] 'to' kind=CardinalityRestrictionKind cardinality=UnsignedInteger (range=[Type:Ref])?;

PropertyValueRestrictionAxiom:
	'restricts' property=[SemanticProperty:Ref] 'to' (literalValue=Literal | containedValue=AnonymousInstance | referencedValue=[NamedInstance:Ref]);

PropertySelfRestrictionAxiom:
	'restricts' property=[SemanticProperty:Ref] 'to' 'self';

KeyAxiom:
	'key' properties+=[Property:Ref] (',' properties+=[Property:Ref])*;

InstanceEnumerationAxiom:
	'oneOf' instances+=[ConceptInstance:Ref] (',' instances+=[ConceptInstance:Ref])*;

LiteralEnumerationAxiom:
	'oneOf' literals+=Literal (',' literals+=Literal)*;

ConceptTypeAssertion infers TypeAssertion:
	type=[Concept:Ref];

RelationTypeAssertion infers TypeAssertion:
	type=[RelationEntity:Ref];

PropertyValueAssertion:
	property=[SemanticProperty:Ref] PropertyValue ("," PropertyValue)*;

fragment PropertyValue infers PropertyValueAssertion:
	(literalValues+=Literal | containedValues+=AnonymousInstance | referencedValues+=[NamedInstance:Ref]);

Predicate:
	UnaryPredicate |
	BinaryPredicate |
	BuiltInPredicate;

UnaryPredicate:
	TypePredicate |
	RelationEntityPredicate;
	
BinaryPredicate:
	PropertyPredicate |
	SameAsPredicate |
	DifferentFromPredicate;

TypePredicate:
	type=[Type:Ref] '(' argument=Argument ')';
	
RelationEntityPredicate:
	type=[RelationEntity:Ref] '(' argument1=Argument ',' argument=Argument ',' argument2=Argument ')';

PropertyPredicate:
	property=[Property:Ref] '(' argument1=Argument ',' argument2=Argument ')';

SameAsPredicate:
	'sameAs' '(' argument1=Argument ',' argument2=Argument ')';

DifferentFromPredicate:
	'differentFrom' '(' argument1=Argument ',' argument2=Argument ')';

BuiltInPredicate:
	'builtIn' '(' builtIn=[BuiltIn:Ref] ',' arguments+=Argument (',' arguments+=Argument)* ')';

Argument:
	variable=ID | literal=Literal | instance=[NamedInstance:CrossRef];














// TODO: Implement specific import rules as defined by the spec:
// OML supports several kinds of imports for each one of its ontology kinds:
// * Vocabulary: extends Vocabulary, uses Description
// * Vocabulary Bundle: extends VocabularyBundle, includes Vocabulary
// * Description: extends Description, uses Vocabulary
// * Description Bundle: extends DescriptionBundle, includes Description, uses Vocabulary, uses VocabularyBundle




// Rule:
//     ownedAnnotations+=Annotation*
//     ('rule' name=ID | 'ref' 'rule' ref=[Rule:ID]) ('['
//         (antecedent+=Predicate ('&' antecedent+=Predicate)* '->' consequent+=Predicate ('&' consequent+=Predicate)*)?

//     ']')?;


Literal:
	IntegerLiteral |
	DecimalLiteral |
	DoubleLiteral |
	BooleanLiteral |
	QuotedLiteral;

IntegerLiteral:
	value=Integer;

DecimalLiteral:
	value=Decimal;

DoubleLiteral:
	value=Double;

BooleanLiteral:
	value=Boolean;

QuotedLiteral:
	value=STRING (('^^' type=[Scalar:Ref]) | ('$' langTag=ID))?; 

/*

    I'm not sure what the intention of these enums are, but for now I've
    ported them by replacing them with literals + inference

*/

RangeRestrictionKind returns string:
	'all' |
	'some' ;

CardinalityRestrictionKind returns string:
	'exactly' |
	'min' |
	'max';

Extends infers ImportKind:
	extension = 'extends';

Uses infers ImportKind:
	usage = 'uses';

Includes infers ImportKind:
	inclusion = 'includes';

//--------------

Ref returns string: 							 QNAME | ID | IRI;

CrossRef returns string: 						QNAME | IRI;

Boolean returns string:						BOOLEAN_STR;

UnsignedInteger returns number: 				UNSIGNED_INTEGER_STR;

Integer returns number: 						UNSIGNED_INTEGER_STR | INTEGER_STR;

terminal Decimal returns number:                		DECIMAL_STR;

terminal Double returns number:						    	DOUBLE_STR;

//----------------------------

terminal BOOLEAN_STR returns boolean:					/(false|true)/;

terminal UNSIGNED_INTEGER_STR returns number:			NUMERIC+;

terminal INTEGER_STR returns number:					('+'|'-')? NUMERIC+;

terminal DECIMAL_STR returns number:					('+'|'-')? (NUMERIC+('.'NUMERIC*)? | ('.'NUMERIC+));

terminal DOUBLE_STR returns number:						('+'|'-')? (NUMERIC+('.'NUMERIC*)? | ('.'NUMERIC+)) ('e'|'E') ('+'|'-')? NUMERIC+;

terminal STRING returns string:							('"' (!('"'|'\\') | '\\'.)* '"') | ("'" (!("'"|'\\') | '\\'.)* "'") | ("'''" -> "'''") | '"""' -> '"""';

terminal NAMESPACE returns string:						/<[^# ]*[#/]>/; // /<[^> #]*[#/]>/; // '<' (!('>'|' '|'#'))* ('#'|'/') '>' 

terminal IRI returns string:							/<[^ ]*>/; // '<' (!('>'|' '))* '>'

terminal QNAME returns string:							ID ':' ID;

terminal ID returns string:								IDFRAG;

hidden terminal ML_COMMENT: 							/\/\*[\s\S]*?\*\//;
 
hidden terminal SL_COMMENT:                             /\/\/[^\n\r]*/;
 
hidden terminal WS:                                     /\s+/;

//----------------------------

terminal fragment IDFRAG:								'^'? (ALPHA|NUMERIC|SPECIAL) (ALPHA|NUMERIC|SPECIAL|'$')*;

terminal fragment ALPHA:								/[a-zA-Z]/;

terminal fragment NUMERIC: 								/[0-9]/;

terminal fragment SPECIAL:								/[-_.~%]/;