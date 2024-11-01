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

// Placeholder rules to suppress warnings
terminal DescriptionBox: "PLACEHOLDER";
terminal NAMESPACE: "PLACEHOLDER";
terminal ID: "PLACEHOLDER";
terminal Literal: "PLACEHOLDER";
terminal Predicate: "PLACEHOLDER";
terminal PropertySpecialization: "PLACEHOLDER";
terminal PropertyEquivalence: "PLACEHOLDER";
terminal Concept: "PLACEHOLDER";
terminal RelationEntity: "PLACEHOLDER";
terminal LiteralEnumerationAxiom: "PLACEHOLDER";
terminal ScalarSpecialization: "PLACEHOLDER";
terminal ScalarEquivalence: "PLACEHOLDER";
terminal KeyAxiom: "PLACEHOLDER";
terminal EntitySpecialization: "PLACEHOLDER";
terminal EntityEquivalence: "PLACEHOLDER";
terminal Term: "PLACEHOLDER";
terminal DescriptionMember: "PLACEHOLDER";
terminal Statement: "PLACEHOLDER";