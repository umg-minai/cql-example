library MINAICDS version '1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

include MINAIElements version '1.0' called E

context Patient

// Recommendation 35 Tidal Volume

define T: E."Population VentilatedCOVID19PatientsWithARDS"

define "Recommendation 35 Tidal Volume":
  if E."Population VentilatedCOVID19PatientsWithARDS" then
    "Intervention VentilatedCOVID19PatientsWithARDSVentilationPlan"
  else
    null

// Population

// Defined in MINAIElements

// Intervention

define "Intervention VentilatedCOVID19PatientsWithARDSVentilationPlan":
  Tuple{
    combination: 'all',
    actions: {
      FHIR.Goal{
        target: {
          FHIR.Goal.Target{
            measure: E.CodeableConceptFromCode(E."Measure Tidal Volume"),
            detail: Range{high: E.SimpleQuantityFromQuantity(7 'ml/kg')}
          }
        }
      },
      FHIR.Goal{
        target: {
          FHIR.Goal.Target{
            measure: E.CodeableConceptFromCode(E."Measure Pressure Plateau"),
            detail: Range{high: E.SimpleQuantityFromQuantity(30 'cm[H2O]')}
          }
        }
      }
    }
  }

// Recommendation 15 Prophylactic Anticoagulation

define "Recommendation 15 Prophylactic Anticoagulation":
  if E."Population HospitalisedCOVID19PatientsWOVenousThrombosisWOCI" then
    "Intervention HospitalisedCOVID19PatientsWOVenousThrombosisWOCI"(
      // TODO(jmoringe): what if body weight not available?
      // TODO(jmoringe): what if body weight not recorded as Quantity?
      E."Value Body Weight"
    )
  else if E."Population HospitalisedCOVID19PatientsWOVenousThrombosisWITHCI" then
    "Intervention HospitalisedCOVID19PatientsWOVenousThrombosisWITHCI"()
  else
    null

// Population

// Defined in MINAIElements

// Intervention

define function "Intervention HospitalisedCOVID19PatientsWOVenousThrombosisWOCI"(weight Quantity):
  Tuple{
    combination: 'all',
    actions: {
      Tuple{
        combination: 'exactly-one',
        actions: {
          // dalteparin
          // enoxaparin
          FHIR.MedicationRequest{
            // TODO(jmoringe): route subcutaneous
            medication: E.CodeableConceptFromCode(E."Substance Nadroparin"),
            dosageInstruction: {
              FHIR.Dosage{
                doseAndRate: {
                  FHIR.Dosage.DoseAndRate{
                    dose: E.SimpleQuantityFromQuantity(case
                        when weight <= 70 'kg' then 3800 'mg' // TODO(jmoringe): actual unit is 'IE' but the data model does not understand that
                        else 5700 'mg'
                      end),
                    rate: E.SimpleQuantityFromQuantity(1 'd')
                  }
                }
              }
            }
          }
        }
      }
    }
  }

define function "Intervention HospitalisedCOVID19PatientsWOVenousThrombosisWITHCI"():
  Tuple{
    combination: 'all',
    actions: {
      FHIR.MedicationRequest{
        // TODO(jmoringe) route
        medication: E.CodeableConceptFromCode(E."Substance Fondaparinux"),
        dosageInstruction: {
          FHIR.Dosage{
            doseAndRate: {
              FHIR.Dosage.DoseAndRate{
                type: E.CodeableConceptFromCode(E."Measure Tidal Volume"), // TODO
                dose: E.SimpleQuantityFromQuantity(2.5 'mg'),
                rate: E.SimpleQuantityFromQuantity(1 'day')
              }
            }
          }
        }
      },
      FHIR.MedicationRequest{
        // TODO(jmoringe) route: subcutaneous
        medication: E.CodeableConceptFromCode(E."Substance Fondaparinux"),
        doNotPerform: FHIR.boolean{value: true}
      }/*,
      FHIR.PlanDefinition.Action{
        code: {
          CodeableConceptFromCode("tidal volume")
        }
        //reason: 'foo'
      }*/
    }
  }
