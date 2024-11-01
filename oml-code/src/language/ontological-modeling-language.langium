grammar OntologicalModelingLanguage

entry Ontology:
    VocabularyBox | DescriptionBox;

VocabularyBox: 
    annotations+=Annotation*
    "vocabulary" NAMESPACE ("as" ID)? "{"
    (extensions+=Extension|usages+=Usage)*
    statements+=VocabularyStatement*
"}";

// What do the brackets mean in EBNF? I've seen conflicting rules
Annotation: "@" annotationPropRef=[AnnotationProperty:ID] ((Literal | memberRefs+=[Member:ID]) ("," (Literal | memberRefs+=[Member:ID]))*)?;

Extension: "extends" namespace=NAMESPACE ("as" id=ID)?;

Usage: "uses" namespace=NAMESPACE ("as" id=ID)?;

VocabularyStatement: Rule | BuiltIn | SpecializableTerm;

Rule: 
    annotations+=Annotation*
    ("rule" IRI=ID | "ref" "rule" ref=[Rule:ID])
    ("["
        (Predicate ("&" Predicate)* "->" Predicate ("&" Predicate)*)?
    "]")?;

BuiltIn:
    annotations+=Annotation*
    ("builtin" ID | "ref" ref=[BuiltIn:ID]);

SpecializableTerm:
    Type |
    AnnotationProperty
    ScalarProperty
    UnreifiedRelation;

AnnotationProperty:
    annotations+=Annotation*
    "annotation" "property" IRI=ID | "ref" "annotation" "property" ref=[AnnotationProperty:ID]
    PropertySpecialization? 
    PropertyEquivalence?;

Type: Entity | Scalar;

Entity: Aspect | Concept | RelationEntity;

Member:
  VocabularyMember |
  DescriptionMember |
  Statement;

VocabularyMember:
  VocabularyStatement |
  Term;

Scalar:
  annotation=Annotation*
  ("scalar" IRI=ID | "ref" "scalar" ref=[Scalar:ID]) ("["
     (LiteralEnumerationAxiom)?
  "]")? (ScalarSpecialization)? (ScalarEquivalence)?;

Aspect:
  annotations=Annotation*
  ("aspect" IRI=ID | "ref" "aspect" ref=[Aspect:ID]) ("["
    (KeyAxiom)* 
  "]")? (EntitySpecialization)? (EntityEquivalence)?;

ScalarProperty:
    annotations+=Annotation*
    ("scalar" "property" IRI=ID | "ref" "scalar" "property" ref=[ScalarProperty:ID]) ("["
        ("domain" domains+=[Entity:ID] ("," domains+=[Entity:ID])*)?
        ("range" ranges+=[Scalar:ID] ("," ranges+=[Scalar:ID])*)?
        ("functional")?
    "]")? PropertySpecialization? PropertyEquivalence?;

Relation:
    ForwardRelation |
    ReverseRelation |
    UnreifiedRelation;

ForwardRelation:
    annotations=Annotation*
    "forward" IRI=ID;

ReverseRelation:
    annotations=Annotation*
    "reverse" IRI=ID;

UnreifiedRelation:
    annotations=Annotation*
    ("relation" IRI=ID | "ref" "relation" ref=[Relation:ID]) ("["
        ("from" fromRefs+=[Entity:ID] ("," fromRefs+=[Entity:ID])*)?
        ("to" toRefs+=[Entity:ID] ("," toReds+=[Entity:ID])*)?
        (ReverseRelation)?
        ("functional")? 
        ("inverse" "functional")?
        ("symmetric")?
        ("asymmetric")?
        ("reflexive")?
        ("irreflexive")?
        ("transitive")?
    "]")? PropertySpecialization? PropertyEquivalence;

// Hidden terminal
hidden terminal WS: /\s+/;
hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;

// Placeholder rules to suppress warnings
// These need to go before visible terminals otherwise they will be swallowed
// by the ID terminal
terminal DescriptionBox: "PLACEHOLDER000";
terminal Literal: "PLACEHOLDER003";
terminal Predicate: "PLACEHOLDER004";
terminal PropertySpecialization: "PLACEHOLDER005";
terminal PropertyEquivalence: "PLACEHOLDER006";
terminal Concept: "PLACEHOLDER007";
terminal RelationEntity: "PLACEHOLDER008";
terminal LiteralEnumerationAxiom: "PLACEHOLDER009";
terminal ScalarSpecialization: "PLACEHOLDER010";
terminal ScalarEquivalence: "PLACEHOLDER011";
terminal KeyAxiom: "PLACEHOLDER012";
terminal EntitySpecialization: "PLACEHOLDER013";
terminal EntityEquivalence: "PLACEHOLDER014";
terminal Term: "PLACEHOLDER015";
terminal DescriptionMember: "PLACEHOLDER016";
terminal Statement: "PLACEHOLDER017";

// Visible termials
terminal NAMESPACE: /<\S*>/; // TODO: Disallow '>', '#', etc.
terminal ID: "^"? (ALPHA|NUMERIC|SPECIAL) (ALPHA|NUMERIC|SPECIAL|"$")*;
terminal ALPHA: /[a-zA-Z]/;
terminal NUMERIC: /[0-9]/;
terminal SPECIAL: /[-_.~%]/;