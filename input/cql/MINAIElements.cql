library MINAIElements version '1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

codesystem "LOINC": 'http://loinc.org'

code "Measure Tidal Volume": '20117-8' from LOINC
  display 'Tidal volume. spontaneous+mechanical/Body weight [Volume/mass] --on ventilator'

code "Measure Pressure Plateau": '76259-1' from LOINC display 'Pressure.plateau Respiratory system airway --on ventilator'

code "Measure Body Weight": '29463-7' from LOINC display 'Body Weight'

codesystem "SNOMED": 'http://snomed.info/sct'

code "Condition COVID19": '840539006' from SNOMED display 'Disease caused by Severe acute respiratory syndrome coronavirus 2 (disorder)'

code "Condition HIT2": '111588002' from SNOMED display 'Heparin-induced thrombocytopenia with thrombosis (disorder)'

code "Condition ARDS": '67782005' from SNOMED display 'Acute respiratory distress syndrome (disorder)'

code "Allergy Heparin": '294872001' from SNOMED display 'Allergy to heparin (finding)'

code "Allergy Heparinoid": '294876003' from SNOMED display 'Allergy to heparinoid'

// TODO concept "Concept Heparin Allergy":

code "Procedure Ventilation": '0617009' from SNOMED display 'Artificial respiration (procedure)'

//define $atcde#B01AX05 "Fondaparinux"

code "Substance Fondaparinux": '708189008' from SNOMED display 'Fondaparinux (substance)'

code "Substance Nadroparin": '699946002' from SNOMED display 'Nadroparin (substance)'

context Patient

// Helper functions

define function MeasuresInGoalAsConcepts(goal FHIR.Goal):
  goal.target.measure M return FHIRHelpers.ToConcept(M)

define function CodeableConceptFromCode(code Code):
  FHIR.CodeableConcept{
    coding: {
      FHIR.Coding{
        code: FHIR.code{value: code.code}/*,
        system: system{value: "tidel volume".system}*/
      }
    }
  }

define function SimpleQuantityFromQuantity(quantity System.Quantity):
  FHIR.SimpleQuantity{
    value: FHIR.decimal{value: quantity.value},
    unit: FHIR.string{value: quantity.unit}
  }

// Shared definitions

define "Has Condition COVID-19":
  exists([Condition: "Condition COVID19"]) // SCT 404684003 "Clinical finding (finding)"

define "Has Condition HIT2":
  exists([Condition: "Condition HIT2"]) // SCT 404684003 "Clinical finding(finding)"

define "Has Condition ARDS":
  exists([Condition: "Condition ARDS"]) // SCT 404684003 "Clinical finding (finding)"

define "Subject To Procedure Ventilated":
  exists([Procedure: "Procedure Ventilation"]) // SCT 71388002 "Procedure (procedure)"

define "Has Heparin Allergy":
  // TODO this should be done with a concept and/or code equivalence
  exists([AllergyIntolerance: "Allergy Heparin"])
    or exists([AllergyIntolerance: "Allergy Heparinoid"])

// Recommendation 35 Tidal Volume

// Population

define "Population VentilatedCOVID19PatientsWithARDS":
  "Subject To Procedure Ventilated"
    and "Has Condition COVID-19"
    and "Has Condition ARDS"

// Intervention

// Recommendation 15 Prophylactic Anticoagulation

define "Value Body Weight":
  First([Observation] O where O.code ~ "Measure Body Weight" return O.value)

// Population

define "Population HospitalisedCOVID19PatientsWOVenousThrombosisWOCI":
  "Has Condition COVID-19"
    and not "Population HIT2OrHeparinAllergy"

define "Population HospitalisedCOVID19PatientsWOVenousThrombosisWITHCI":
  "Has Condition COVID-19"
    and "Population HIT2OrHeparinAllergy"

define "Population HIT2OrHeparinAllergy":
  "Has Condition HIT2"
    or "Has Heparin Allergy"

// Intervention
