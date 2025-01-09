library DemoContextAndRetrieve

using FHIR version '4.0.1'

include MINAIElements called E

context Patient // to enable result display

define Value1: {1, 2, 3, 4, 5}
define Value2: Value1
define Value3: Value1 v where (v mod 2 = 0) return ToString(v + 1)

context Patient

define OnePatient: Patient
define OnePatientId: Patient p return p.id.value
define OnePatientConditions: [Condition] c
define OnePatientCovid19Conditions: [Condition: E."Condition COVID19"] c

//context Population // not available in implementation guide mode
//
//define AllPatients: Patient P
//define AllPatientsConditions: [Condition] C