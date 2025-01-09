library TypesDemo

using FHIR version '4.0.1'

define MyDecimal: 10.5
define MyRatio: 10:12
define MyList: { 'a', 'b', 'c' }
define MyList2: [Observation] o
define MyTyple: Tuple{slot1: 1, slot2: '2'}
define MyStruturedValue: FHIR.Quantity{value: FHIR.decimal{value: 10.5},
                                       unit: FHIR.string{value: 'mg'}}

// Choice type
define function Foo(x Decimal):
  case
    when x < 10 then '1'
    else 1
  end
