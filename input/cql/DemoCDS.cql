library DemoCDS version '1.0.0'

using FHIR version '4.0.1'

include MINAIElements called E

code "My Condition" : '1234' from E.SNOMED display 'My condition'

context Patient

define "Recommendation 35":
  if "In Population" then
    "Recommended Actions"
  else
    null

// Population

define private "In Population":
  exists([Condition: E."Condition COVID19"])

// Intervention

define private "Recommended Actions":
  {
    Tuple{
        type: 'MedicationRequest',
        substance: E."Substance Nadroparin",
        dosage: 5 'mg/d'
    }
  }
