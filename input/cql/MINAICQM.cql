library MINAICDS version '1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

include MINAIElements version '1.0' called E

context Patient

// Recommendation 35 Tidal Volume

define "Recommendation 35 Tidal Volume":
  if E."Population VentilatedCOVID19PatientsWithARDS" then
    "Intervention VentilatedCOVID19PatientsWithARDSVentilationPlan"
  else
    false

// Population

// Defined in MINAIElements

// Intervention

define "Intervention VentilatedCOVID19PatientsWithARDSVentilationPlan":
  exists([Goal] G 
           where exists(G.target T 
                          where T.measure ~ E.CodeableConceptFromCode(E."Measure Tidal Volume")
                                and T.detail is Range
                                and T.detail.high = 7 'ml/kg'))
    and exists([Goal] G 
                 where exists(G.target T 
                                where T.measure ~ E.CodeableConceptFromCode(E."Measure Pressure Plateau")
                                        and T.detail is Range
                                        and T.detail.high = 30 'cm[H2O]'))
  

// Recommendation 15 Prophylactic Anticoagulation

define "Value Body Weight": 
  First([Observation] O where O.code = E."Measure Body Weight" return O.value)

define "Recommendation 15 Prophylactic Anticoagulation":
  if E."Population HospitalisedCOVID19PatientsWOVenousThrombosisWOCI" then
    "Intervention HospitalisedCOVID19PatientsWOVenousThrombosisWOCI"
  else if E."Population HospitalisedCOVID19PatientsWOVenousThrombosisWITHCI" then
    "Intervention HospitalisedCOVID19PatientsWOVenousThrombosisWITHCI"
  else
    false

// Population

// Defined in MINAIElements

// Intervention

define "Intervention HospitalisedCOVID19PatientsWOVenousThrombosisWOCI":
  //let weight: 1 in
  Tuple{
    combination: 'all',
    actions: {
      Tuple{
        test: case
          when "Value Body Weight" weight return weight <= 70 'kg' then 3800 '/d'
          else 5700 '/d'
        end,
        combination: 'exactly-one',
        actions: {
          // dalteparin
          // enoxaparin
          FHIR.MedicationRequest{
            medication: E.CodeableConceptFromCode(E."Substance Nadroparin")
          }
        }
      }
    }
  }

define "Intervention HospitalisedCOVID19PatientsWOVenousThrombosisWITHCI":
  Tuple{
    combination: 'all',
    actions: {
      FHIR.MedicationRequest{
        // TODO route
        medication: E.CodeableConceptFromCode(E."Substance Fondaparinux"),
        dosageInstruction: {
          FHIR.Dosage{
            doseAndRate: {
              FHIR.Dosage.DoseAndRate{
                type: E.CodeableConceptFromCode(E."Measure Tidal Volume"), // TODO
                dose: FHIR.SimpleQuantity{
                  value: FHIR.decimal{value: 2.5},
                  unit: FHIR.string{value: 'mg'},
                  code: FHIR.code{value: E."Measure Tidal Volume".code} // TODO
                },
                rate: FHIR.SimpleQuantity{
                  value: FHIR.decimal{value: 1},
                  unit: FHIR.string{value: 'day'},
                  code: FHIR.code{value: E."Measure Tidal Volume".code} // TODO
                }
              }
            }
          }
        }
      },
      FHIR.MedicationRequest{
        // TODO route: subcutaneous
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
