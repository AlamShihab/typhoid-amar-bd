# Care-setting composition and first-line susceptibility trends in typhoid, Dhaka, 1999 to 2022

A reproduction and sensitivity analysis of the published 24-year typhoid antimicrobial resistance dataset of the Child Health Research Foundation (CHRF): Tanmoy et al. 2024, *PLoS Neglected Tropical Diseases*.

**Report:** [`docs/index.html`](docs/index.html) (published with GitHub Pages)

## Question

Tanmoy et al. showed that resistance of *Salmonella* Typhi to the first-line drugs amoxicillin, chloramphenicol and cotrimoxazole fell between 1999 and 2022. Over the same years, the mix of recorded care settings in the sample changed a lot: hospital inpatients, hospital outpatients and a community diagnostic centre contributed very different shares in different years. This project asks:

> How sensitive are the observed first-line susceptibility trends to the changing mix of recorded care settings?

## What the paper did and what this project adds

| Topic | Tanmoy et al. 2024 | This project |
|---|---|---|
| Data | 12,435 culture-confirmed isolates, 1999 to 2022 | The same published S1 Data; no new data |
| Main outcomes | Yearly resistance to each drug, MDR, ciprofloxacin non-susceptibility | Reproduced first; then susceptibility to each first-line drug, with 95% intervals |
| Care setting | Inpatient and outpatient counts and MDR by year (S1 Fig) | A coverage audit of all three settings; hospital-only versus all-source estimates; trends standardised to a fixed setting mix |
| Tools | Stata and R | A tested R, DuckDB and SQL pipeline that rebuilds every number with one command |

## Key findings

1. **The published results reproduce.** 23 of 24 checks against the paper's text and figures match; the one difference (ciprofloxacin non-susceptibility in 2003, 86.2% among 29 isolates) and the rounding and averaging notes are explained in `audit/discrepancies.md`.
2. **Susceptibility to each first-line drug roughly doubled**, from 36 to 37% in 2004 to 2006 to 80 to 82% in 2020 to 2022, while the recorded setting mix changed a lot (inpatients were the largest group in 2009 to 2016, outpatients from 2017 onwards).
3. **The trend is not an artefact of the setting mix.** Adding the community centre moved a year's pooled estimate by a median of 0.6 percentage points (largest 4.2, chloramphenicol in 2005). Holding the inpatient/outpatient mix fixed changed the modelled trend by at most 1.0 point in interior years, and by -0.8 to 2.5 points across all robustness variants.

These describe culture-confirmed isolates under a constant *recorded* setting mix, not typhoid in Dhaka as a whole (see Limitations).

## How to run

Requirements: R 4.3 or later and [Quarto](https://quarto.org).

```sh
Rscript install.R      # once: installs packages into a project library and writes renv.lock
Rscript run_core.R     # rebuilds everything from data/raw/S1_Data.xlsx
```

`run_core.R` parses every script, runs the automated tests, then runs each stage in its own R process:

| Stage | Script | Output |
|---|---|---|
| Load and gate | `R/01_load.R` | DuckDB database, `audit/raw_values.csv`, `audit/bad_values.csv` (must be empty) |
| Reproduction and coverage | `R/02_validate.R` | `audit/reproduction_checks.csv`, coverage grid, attrition, data-derived tiers |
| Descriptive figures | `R/03_descriptive.R` | `figures/fig_r*`, `fig_c*`, `fig_d*` |
| Setting-mix analysis | `R/04_standardise.R` | hospital-only versus all-source comparison, Tier 1 and Tier 2 standardisation |
| Robustness | `R/05_robustness.R` | `audit/robustness.csv` |
| Report | `report/report.qmd` | `docs/index.html` |

The workbook's MD5 is checked against `data/raw/SOURCES.md` before loading. SQL views are in `sql/`, one per file. Any value outside the allowed lists stops the build before analysis.

## Attribution

| Component | Belongs to |
|---|---|
| Surveillance, laboratory measurements, source dataset and original findings | The original investigators and CHRF |
| Reproduction of selected published results | This project's implementation, with the original work credited |
| Data-quality checks, tests and the reproducible pipeline | This project |
| Setting-mix analysis and robustness checks | This project's analytical extension |
| Interpretation of the new results | This project's independent interpretation |

This is independent work using published data. It is not a CHRF product, collaboration or endorsement, and it makes no treatment recommendation.

## Limitations

- Isolates are culture-confirmed cases from physician-ordered blood cultures at five Dhaka sites, with a paediatric focus. Who was cultured, prior antibiotic use, age and severity are not recorded, so the analysis describes trends under a constant *recorded* setting mix, not typhoid in Dhaka.
- Settings are recorded source categories, not like-for-like facilities, and S1 has no site IDs.
- The hospitals joined the WHO-coordinated surveillance network in 2009, and culture switched to BACTEC in 2016.
- The S, I and R categories follow CLSI 2020, as published; S1 has no zone sizes, so nothing was re-interpreted.
- The data end in 2022, before the 2024 ceftriaxone-resistant outbreak.

## Data and licence

- **Data:** `data/raw/S1_Data.xlsx` is S1 Data of Tanmoy AM, Hooda Y, Sajib MSI, et al. (2024) Trends in antimicrobial resistance amongst *Salmonella* Typhi in Bangladesh: A 24-year retrospective observational study (1999–2022). *PLoS Negl Trop Dis* 18(10): e0012558. https://doi.org/10.1371/journal.pntd.0012558. It is published under CC BY 4.0 and redistributed unmodified with credit.
- **Code:** MIT licence (see `LICENSE`).
