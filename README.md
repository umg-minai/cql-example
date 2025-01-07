## Introduction

This repository contains [Clinical Quality Language](https://cql.hl7.org/) (CQL) libraries that implement the recommendations in the `material` directory in multiple ways **for educational purposes**.

## Variants

### Clinical Decision Support (CDS)

Based on patient, condition, encounter, etc data, generate lists recommended actions, goals, etc.

A sketch for this variant is implemented in `input/cql/MINAICDS.cql`

### Compliance Check / Clinical Quality Measurement (CQM)

Evaluate recommendation goals over some temporal periods, for example how many times/percentage/etc. each day was the goal not fulfilled.
Should be checked by looking at `Observation`s for the patient
Output could be one report-ish structure for each day or similar.

A sketch for this variant is implemented in `input/cql/MINAICQM.cql`

### Continuous Monitoring, Incremental Processing, Streaming

Somehow check recommendations whenever new observations arrive for a given patient.
This variant is not implemented.
