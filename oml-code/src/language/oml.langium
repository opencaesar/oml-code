grammar OML

entry Ontology:
    VocabularyBox
    | DescriptionBox;

Annotation:
    '@' {infer Annotation} property=[AnnotationProperty:Ref] (AnnotationValue ("," AnnotationValue)*)?;

fragment AnnotationValue:
    literalValues+=Literal | referencedValues+=[Member:Ref];

Element:
	Annotation |
	Argument |
	Assertion |
	Axiom |
	IdentifiedElement |
	Import |
	Instance |
	Literal |
	Predicate;

Assertion:
	PropertyValueAssertion
	TypeAssertion;

TypeAssertion:
	type=[Entity:Ref];

Axiom:
	KeyAxiom |
	PropertyRestrictionAxiom |
	EntityEquivalenceAxiom |
	PropertyEquivalenceAxiom |
	ScalarEquivalenceAxiom |
	InstanceEnumerationAxiom |
	LiteralEnumerationAxiom |
	SpecializationAxiom;

IdentifiedElement:
	Member |
	Ontology;

Instance:
	AnonymousInstance |
	NamedInstance;

Member:
	VocabularyMember |
	DescriptionMember |
	Statement;

VocabularyMember:
	Term |
	VocabularyStatement;

DescriptionMember:
	DescriptionStatement;

Statement:
	VocabularyStatement |
	DescriptionStatement;

Term:
	Property |
	SpecializableTerm;

Property:
	AnnotationProperty |
	SemanticProperty;

SemanticProperty:
	ScalarProperty |
	Relation;

Relation:
	ForwardRelation |
	ReverseRelation |
	UnreifiedRelation;

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
	SpecializableProperty;

Type:
    Entity |
    Scalar;

SpecializableProperty:
	AnnotationProperty |
    ScalarProperty |
    UnreifiedRelation;

RelationBase:
	RelationEntity |
	UnreifiedRelation;

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

AnnotationProperty:
	ownedAnnotations+=Annotation*
	(('annotation' 'property' name=ID) | ('ref' 'annotation' 'property' ref=[AnnotationProperty:Ref]))
	    (PropertySpecialization)? (PropertyEquivalence)?;

ScalarProperty:
	ownedAnnotations+=Annotation*
	('scalar' 'property' name=ID | 'ref' 'scalar' 'property' ref=[ScalarProperty:Ref]) ('['
		('domain' domains+=[Entity:Ref] (',' domains+=[Entity:Ref])*)?
		('range' ranges+=[Scalar:Ref] (',' ranges+=[Scalar:Ref])*)?
		(functional?='functional')?
	']')? (PropertySpecialization)? (PropertyEquivalence)?;

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
	('instance' name=ID | 'ref' 'instance' ref=[ConceptInstance:Ref]) (':' ownedTypes+=TypeAssertion (',' ownedTypes+=TypeAssertion)*)? ('['
		ownedPropertyValues+=PropertyValueAssertion*
	']')?;
	
RelationInstance:
	ownedAnnotations+=Annotation*
	('relation' 'instance' name=ID | 'ref' 'relation' 'instance' ref=[RelationInstance:Ref]) (':' ownedTypes+=TypeAssertion (',' ownedTypes+=TypeAssertion)*)? ('['
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
    kind=ImportKind imported=[Ontology:NAMESPACE] ('as' prefix=ID)?;

Extension infers Import:
    kind='extends' imported=[Ontology:NAMESPACE] ('as' prefix=ID)?;

Usage infers Import:
    kind='uses' imported=[Ontology:NAMESPACE] ('as' prefix=ID)?;

Inclusion infers Import:
    kind='includes' imported=[Ontology:NAMESPACE] ('as' prefix=ID)?;

SpecializationAxiom:
	superTerm=[Term:Ref];

PropertyRestrictionAxiom:
	PropertySelfRestrictionAxiom |
	PropertyRangeRestrictionAxiom |
	PropertyCardinalityRestrictionAxiom |
	PropertyValueRestrictionAxiom;

PropertyRangeRestrictionAxiom:
	'restricts' kind=RangeRestrictionKind property=[SemanticProperty:Ref] 'to' range=[Type:Ref];

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

RangeRestrictionKind returns string:
	'all' |
	'some' ;

CardinalityRestrictionKind returns string:
	'exactly' |
	'min' |
	'max';

ImportKind returns string:
	'extends' |
	'uses' |
	'includes';

//--------------

Ref returns string: 							 		QNAME | ID | IRI;

CrossRef returns string: 								QNAME | IRI;

Boolean returns boolean:								BOOLEAN;

UnsignedInteger returns number: 						UNSIGNED_INTEGER;

Integer returns number: 								UNSIGNED_INTEGER | INTEGER;

Decimal returns number:									DECIMAL;

Double returns number:									DOUBLE;

//----------------------------

hidden terminal ML_COMMENT: 							/\/\*[\s\S]*?\*\//;
 
hidden terminal SL_COMMENT:                             /\/\/[^\n\r]*/;
 
hidden terminal WS:                                     /\s+/;

//----------------------------

terminal BOOLEAN:										/(false|true)/;

terminal DOUBLE:										('+'|'-')? (NUMERIC+('.'NUMERIC*)? | ('.'NUMERIC+)) ('e'|'E') ('+'|'-')? NUMERIC+;

terminal DECIMAL:										('+'|'-')? (NUMERIC+('.'NUMERIC*)) | ('.'NUMERIC+);

terminal INTEGER:										('+'|'-') NUMERIC+;

terminal UNSIGNED_INTEGER:								NUMERIC+;

terminal STRING:				                         ('"""' -> '"""') | ("'''" -> "'''") | ("'" -> "'") | ('"' -> '"');

terminal NAMESPACE:										/<[^# ]*[#/]>/;

terminal IRI:											/<[^ ]*>/;

terminal QNAME:											IDFRAG ':' IDFRAG;

terminal ID:											IDFRAG;

//----------------------------

terminal fragment IDFRAG:								'^'? (ALPHA|NUMERIC|SPECIAL) (ALPHA|NUMERIC|SPECIAL|'$')*;

terminal fragment ALPHA:								/[a-zA-Z]/;

terminal fragment NUMERIC: 								/[0-9]/;

terminal fragment SPECIAL:								/[-_.~%]/;