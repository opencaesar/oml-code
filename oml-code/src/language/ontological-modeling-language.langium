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

Extension infers Import:
    /* kind=Extends */ namespace=NAMESPACE ('as' prefix=ID)?;

Usage infers Import:
    /* kind=Uses */ namespace=NAMESPACE ('as' prefix=ID)?;

Inclusion infers Import:
    /* kind=Includes */ namespace=NAMESPACE ('as' prefix=ID)?;

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
    // Concept |
    RelationEntity;

Aspect:
    // ownedAnnotations+=Annotation*
	('aspect' name=ID | 'ref' 'aspect' ref=[Aspect:ID/* Ref */]) 
    /* 
    ('['
		(ownedKeys+=KeyAxiom)* 
	']')?
    */
     /* (EntitySpecialization)? (EntityEquivalence)? */;


// Langium doesn't support optional elements for unordered groups, so these
// keyword statements have to be mandatory for now
RelationEntity:
    // ownedAnnotations+=Annotation*
	('relation' 'entity' name=ID | 'ref' 'relation' 'entity' ref=[RelationEntity:ID/* Ref */]) ('['
		('from' sources+=[Entity:ID/* Ref */] (',' sources+=[Entity:ID/* Ref */])*)?
		('to' targets+=[Entity:ID/* Ref */] (',' targets+=[Entity:ID/* Ref */])*)?
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
	']')? /* (EntitySpecialization)? (EntityEquivalence)? */;

AnnotationProperty:
	// ownedAnnotations+=Annotation*
	(('annotation' 'property' name=ID) | ('ref' 'annotation' 'property' ref=[AnnotationProperty:ID/* Ref */]))
		/* (PropertySpecialization)? (PropertyEquivalence)? */;

Relation:
	UnreifiedRelation;

ReverseRelation:
	// ownedAnnotations+=Annotation*
	'reverse' name=ID;

UnreifiedRelation:
	// ownedAnnotations+=Annotation*
	('relation' name=ID | 'ref' 'relation' ref=[Relation:ID/* Ref */]) ('['
		('from' sources+=[Entity:ID/* Ref */] (',' sources+=[Entity:ID/* Ref */])*)?
		('to' targets+=[Entity:ID/* Ref */] (',' targets+=[Entity:ID/* Ref */])*)?
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


terminal NAMESPACE: /<[^> #]*[#/]>/;
terminal ID: IDFRAG;

terminal IDFRAG: '^'? (ALPHA|NUMERIC|SPECIAL) (ALPHA|NUMERIC|SPECIAL|'$')*;
terminal fragment ALPHA:								/[a-zA-z]/;
terminal fragment NUMERIC: 								/[0-9]+/;
terminal fragment SPECIAL:								/[-_.~%]/;

hidden terminal WS: /\s+/;