grammar OntologicalModelingLanguage

entry Ontology:
    VocabularyBox;

VocabularyBox:
    Vocabulary;

Vocabulary:
    // ownedAnnotations+=Annotation*
    'vocabulary' namespace=NAMESPACE 'as' prefix=ID '{'
        ownedImports+=(Extension|Usage)*
        ownedStatements+=VocabularyStatement*
    '}';

VocabularyStatement:
    // Rule |
    SpecializableTerm;

Import:
    Extension |
    Usage |
    Inclusion;

Extension:
    'extends' namespace=NAMESPACE ('as' prefix=ID)?;

Usage:
    'uses' namespace=NAMESPACE ('as' prefix=ID)?;

Inclusion:
    'includes' namespace=NAMESPACE ('as' prefix=ID)?;

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

hidden terminal WS: /\s+/;

Ref returns string: 			        		        QNAME |	ID;


//----------------------------

terminal NAMESPACE:					                    /<[^> #]*(#|\/)>/;

terminal ID returns string:								IDFRAG;

terminal QNAME returns string:							IDFRAG ':' IDFRAG;


//----------------------------

terminal fragment IDFRAG:								'^'? (ALPHA|NUMERIC|SPECIAL) (ALPHA|NUMERIC|SPECIAL|'$')*;

terminal fragment ALPHA:								/[a-zA-Z]/;

terminal fragment NUMERIC: 								/[0-9]/;

terminal fragment SPECIAL:								/[-_.~%]/;