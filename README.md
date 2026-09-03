# CIRCEE: The CIRCular Energy Economy model

## General description

CIRCEE is a dynamic general equilibrium model, augmented with material flow analysis and mass balance, with a one-way soft-link to the IAM WITCH model (Emmerling et al., 2016) for energy efficiency, energy prices, emission factors and energy investments trajectories. It analyses the circular economy by integrating material, energy, and economic flows. The model simulates interactions among producers, consumers, government, and the external sector, with a particular focus on consumer-focused circular strategies (sharing, repair, sufficiency), policies (e.g., EPR schemes) and climate change mitigation goals, capturing the trade-offs and synergies between different sustainability objectives.

This repository also includes **CIRCEE-LIFE**, a two-way iterative coupling of CIRCEE with **LIFE**, a lifestyle-dynamics submodel (including cognitions, behaviours, and material and social context) that distinguishes three lifestyle groups from the typology of Pettifor et al. (2023). The coupling jointly calibrates two behavioural modifiers (sharing and sufficiency / lowering expenditures) at year 2020, then iterates between CIRCEE and LIFE until the lifestyle frequency trajectories stabilise out to 2060. The **sufficiency** and **sharing** lifestyles are included here; **repair** is available on demand and will be released open-source by the end of the year.

> ⚠️ Expect long runtimes and high memory use if you do not use an HPC.
>
> Version note. This repository holds the current version of CIRCEE. The 2025 Resources, Conservation and Recycling and 2026 Global Environmental Change papers were run on earlier versions: the CIRCEE calibration has since been refined as newer material- and waste-flow data became available, and the LIFE calibration was updated by Hazel Pettifor and Hazel Maureen. Those papers cannot be reproduced exactly from this code — the qualitative dynamics are unchanged, but levels can differ slightly. Earlier versions for the reproduction of the two papers will be made available soon.

---

## Quick start (CIRCEE-LIFE coupling)

```bash
# 1. Open config.sh and edit the scenario lines:
#       RUN_MODE="coupled"                  # or "baseline" for no lifestyle heterogeneity
#       SCENARIO_SHARING="ecoactive"        # or "affordability"
#       SCENARIO_SUFFICIENCY="ecoactive"    # or "affordability"
#    Then set MATLAB_BIN to point at your MATLAB binary.

# 2. Run:
bash run.sh
```

The script runs a smoke test on MATLAB, then either runs the full coupling or a single baseline CIRCEE run, depending on `RUN_MODE`.

### Single run without the coupling

To run CIRCEE alone with the exogenous paths in `data/<REGION>/raw/shocks.csv`, from MATLAB:

```matlab
cd src
CIRCEE_RunFile
```

`CIRCEE_RunFile.m` writes `src/CIRCEE_shocks.m` before invoking Dynare, so calling `dynare CIRCEE_PF.mod` directly will fail on that missing include.

### Run modes

Set `RUN_MODE` in `config.sh` (or override on the command line: `RUN_MODE=baseline bash run.sh`).

| Mode | What happens | Typical use |
| --- | --- | --- |
| `coupled` | Full CIRCEE ↔ LIFE iterative coupling. Phase 1 jointly calibrates T0 modifiers in propensity space; Phase 2 iterates the LIFE dynamics until lifestyle frequencies converge. Hours-scale runtime. | The full model run. |
| `baseline` | Single CIRCEE run with all behavioural modifiers held at zero. No Phase 1, no Phase 2, no LIFE feedback. Minutes-scale runtime. `SCENARIO_*` settings are ignored. | Sanity checks, sensitivity analysis on CIRCEE parameters, generating a reference trajectory. |

To run CIRCEE **on its own, without any lifestyle scenario**, set `RUN_MODE="baseline"` (or `RUN_MODE=baseline bash run.sh`). This runs the economic model once with all behavioural modifiers at zero and BAU infrastructures (Baseline in the model), producing the reference trajectory against which the coupled runs are compared. It is the fastest way to run the model and the recommended starting point.

### Scenarios (coupled mode only)

Two behavioural narratives drive sufficiency and sharing lifestyle adoption. They can be combined freely across sharing and sufficiency:

| Scenario | Logic |
| --- | --- |
| `ecoactive` | Awareness-led. Adoption is highest among households that already exhibit environmental awareness and strong low-carbon cognitions. |
| `affordability` | Necessity-led. Adoption is driven by the need to save money and by budget constraints. |

### Config settings

All user-facing options are set in `config.sh`:

| Variable | Options | Meaning |
| --- | --- | --- |
| `RUN_MODE` | `coupled` \| `baseline` | Full CIRCEE↔LIFE coupling, or a single CIRCEE run with no modifiers. |
| `SCENARIO_SHARING` | `ecoactive` \| `affordability` | Behavioural narrative for sharing (coupled mode). |
| `SCENARIO_SUFFICIENCY` | `ecoactive` \| `affordability` | Behavioural narrative for sufficiency (coupled mode). |
| `SIGMA_SCENARIO` | `Baseline` \| `Progressive` \| `Regressive` | Infrastructure (σ^es) scenario — see below. Run `Baseline` first (welfare reference). |
| `FORESIGHT_MODE` | `anticipation_errors` \| `perfect_foresight` | How agents anticipate the shock path. |
| `WELFARE_MODE` | `single` \| `all` | Run welfare for the current σ scenario only, or all σ scenarios sequentially. |
| `SSP_SCENARIO` | `SSP2` | Socioeconomic pathway (SSP2 available now). |
| `MATLAB_BIN` | path | Path to your MATLAB binary. |

This yields four combinations, e.g. `ecoactive_ecoactive`, `affordability_affordability`, `ecoactive_affordability`, `affordability_ecoactive`. Output files are tagged with the combined name.

### Infrastructures configuration (substitution elasticity)

Independently of the behavioural narratives, the surrounding *infrastructures* is represented by the elasticity of substitution (siggma_es) between ownership-based and PSS-based (market) energy services. A higher siggma_es means home and PSS energy services are closer substitutes, i.e. more enabling infrastructures for moving away from ownership. They differ in the **level** of σ and in how it is **distributed** across the three lifestyle groups over 2018–2050:

| Infrastructure configurations | Logic |
| --- | --- |
| `Baseline` | Low substitution held roughly constant — a weakly enabling infrastructures. |
| `Progressive` | siggma_es rises over time, with the largest increase for lower-income groups (enablement concentrated on those who most depend on external conditions). |
| `Regressive` | siggma_es rises over time, with the largest increase for higher-income groups. |

`Progressive` and `Regressive` reach a similar aggregate level of enablement by 2050 but distribute it oppositely, isolating the effect of *how* enablement is distributed from *how much* there is. The σ trajectories are set in the calibration/shock inputs; see `config.sh` and the infrastructures-configuration block in the calibration files. (Earlier model versions also included `Utopia_Equality` and `Dystopian_Equality`.)

---

## Requirements

* **MATLAB R2024b** (older versions probably work; R2023b or later is recommended).
* **Dynare** installed and on MATLAB's path (the CIRCEE model is a `.mod` file). Download from https://www.dynare.org/ — the latest version is recommended.
* **bash** ≥ 4, plus `bc`, `awk`, `sed`, `grep` (standard on macOS/Linux).
* For distributional/figure post-processing: **R** (≥ 4.0) with `ggplot2`, `patchwork`, `ggh4x`.

---

## Repository layout

```
.
├── README.md
├── LICENSE
├── CITATION.cff
├── .gitignore
├── post/                                    ← Figures
    ├── README.md              
    ├── Figure_2.R
    ├── Figure_3.R
    ├── Figure_4.R
    ├── Figure_5.R
    └── SI/
        ├── TrilemmaWaste_SI.R
        └── Carbon_and_waste_footprint_SI.R
        └── Prices_SI.R
        └── Userates_SI.R
        └── Sensitivitybounds_SI.R
├── scripts/
│   ├── config.sh                           ← edit this (scenarios + MATLAB path + tolerances)
│   ├── run.sh                              ← run this
│   └── lib/
│       ├── parameters.sh                   ← LIFE model constants (β, α, frequency arrays, ratios)
│       ├── common.sh                       ← shared helpers (MATLAB call, shocks builder, output reader)
│       ├── Full_coupling.sh                ← Phase 1 (T0 calibration) and Phase 2 (outer loop)
│       ├── tune_sharing.sh                 ← 1D bisection tuner for sharing modifiers
│       └── tune_expenditures.sh            ← 1D bisection tuner for sufficiency modifiers
├── src/                                    ← model code (MATLAB + Dynare)
│   ├── MODEL_selection.inc                 ← region selection (@#define REGION)
│   ├── CIRCEE_PF.mod                       ← Dynare model
│   ├── CIRCEE_RunFile.m                    ← top-level MATLAB driver
│   ├── CIRCEE_steadystatemodel.m           ← steady-state computation
│   ├── CIRCEE_calibration.m                ← calibration values (generated/provided)
│   ├── CIRCEE_WelfareAnalysis.m            ← CEV + distributional indices
│   ├── CIRCEE_WelfarePostProcess.m         ← welfare driver (single run)
│   ├── CIRCEE_WelfarePostProcess_batch.m   ← example driver (loops over runs; edit USER PATHS)
│   ├── CIRCEE_WelfareExport.m              ← welfare/distribution CSV export
│   ├── Footprints.m                        ← carbon/waste/material footprints
│   └── clean_up.m                          ← housekeeping helper
└── data/
    └── <REGION>/                           ← e.g. JPN
        ├── raw/
        │   ├── calibration.csv             ← CIRCEE calibration table
        │   └── shocks.csv                  ← exogenous paths; zero modifiers (classic mode)
        └── templates/
            └── shocks.csv                  ← skeleton for the coupled pipeline
```

The paths above follow scripts/config.sh (SRC_DIR=../src, PATH_TEMPLATES=../data/<REGION>/templates/, RESULTS_DIR=../results), so the scripts are run from within scripts/. Adjust config.sh if your layout differs.

results/ is created at runtime and is not tracked. Runtime-generated files — src/CIRCEE_shocks.m, src/CIRCEE_endvalues.m, src/CIRCEE_baseyear_values.m, src/data_shocks.csv, Dynare's src/+CIRCEE_PF/, and the entire results tree including welfare .mat files — are gitignored.

---

## How the coupling works

### Phase 1 — Joint T0 calibration

The two behavioural modifier triplets (sharing × {lowcarbon, cautious, constrained} and sufficiency × the same three groups) are jointly calibrated so that CIRCEE's year-2020 outputs match propensity-space targets in the LIFE model. Each block is tuned by 1D bisection (`lib/tune_sharing.sh`, `lib/tune_expenditures.sh`); the two blocks are then alternated until both are jointly satisfied. The order of tuning alternates each iteration to reduce ordering bias.

### Phase 2 — Outer CIRCEE ↔ LIFE loop

* **Run A** — CIRCEE with all behavioural modifiers = 0 (the homogeneous baseline, where all households behave identically). Runs once.
* **Run B** — CIRCEE with the full behavioural modifier path. Runs each iteration.
* **LIFE update** — for each year *T* on the 2025…2060 grid:
  * `out_freq_h(T) = in_freq_h(T) × ES_h(T) / ES_h(T-1)`
  * feed through cognition, then Δbehaviour
  * rescale by the group calibration ratio to get the next year's frequency

The loop iterates until the maximum behavioural frequency change (share of uptake of ASI behaviour) between two consecutive outer iterations falls below `OUTER_TOL`.

---

## Main model files

### CIRCEE_PF.mod

**Role**: Main model file containing the full economic structure — declarations of variables and parameters, and the model equations and first-order conditions. For a comprehensive overview of the equations, refer to the Appendix of Corbier et al. (2025). Note that the equations have undergone slight modifications since Corbier et al. (2024, 2025, 2026).

**Contents**:

* **Macro definitions**: region selection (JPN only for now), SSP scenario, and definitions of sectors, materials, and lifestyles.
  * Users can select the region in `MODEL_selection.inc` (`@#define REGION`): Japan (JPN) is available now, with the EU27 and China coming soon.
  * Users can currently select SSP2, as the LIFE model is only calibrated on SSP2. 
  * The parameters governing lifestyle changes are the "modifiers". A baseline run holds all modifiers at 0. This repository currently includes the **sufficiency** and **sharing** lifestyles; the **repair** lifestyle is available on demand (darius.corbier@cmcc.it) and will be released by the end of the year.
* **Endogenous variables (300+)**: firms' decisions (output, capital, labour, energy and material inputs); household variables by lifestyle (consumption, saving/investment, energy-using and other durable goods); government (budget, taxes, subsidies); international trade; material stocks and flows; waste flows; CO₂ emissions.
* **Predetermined variables**: capital stocks, energy-using and other durable goods stocks, material stocks.
* **Exogenous variables**: technological efficiencies, resource prices, fiscal policies.
* **Parameters**: substitution elasticities, preference parameters, depreciation rates.
* **Model equations**: household behaviour (by lifestyle: low-carbon is the highest-income group, cautious is the moderate income group, constrained is the lowest-income group); sectoral production functions (consumer and capital goods, materials, repair and sharing services); market-clearing conditions; physical constraints (material balances, emissions); trade with Armington CES.

**Features**:

* Uses the Dynare preprocessor with `@#for` loops to auto-generate equations.
* Perfect-foresight solution, with or without anticipation errors, over 82 periods (2018–2100).

### CIRCEE_RunFile.m

**Role**: Top-level MATLAB driver: execution and post-processing.

**Execution steps**:

1. **Setup** — select mode (`'classic'` single run, or `'calibration'` used by the coupling pipeline), model (B2C / C2C), and SSP scenario (SSP2 available).
2. **Generate calibration files** — `CIRCEE_calibration.m` (structural parameters from `calibration.csv`); `CIRCEE_baseyear_values.m` (2018 base-year values); `CIRCEE_shocks.m` (exogenous shock paths from `shocks.csv`); `CIRCEE_endvalues.m` (terminal values for convergence). See section 3.1.2 of `CIRCEE_RunFile.m` for adding exogenous/policy variables. Advice: avoid too many shocks and be cautious with magnitudes to prevent infeasibilities and corner solutions.
3. **Run Dynare** — `dynare CIRCEE_PF.mod`; compute the steady state from `CIRCEE_steadystatemodel.m`; solve the transition path.
4. **Post-processing** — rescaling (per-household values scaled to economy-wide totals by population × labour productivity × group population share); unit conversion (energy in EJ, employment in millions); GDP in MER and PPP; CSV generation, including per-scenario level files, per-household variables (`*_percapita` in the code), carbon/waste/material footprints, and thematic CIRCEE-LIFE files.
5. **Welfare and distributional analysis** — see below (post-processing on saved outputs; no Dynare re-run required).

### CIRCEE_steadystatemodel.m

**Role**: Analytical steady-state computation. If you modify any equation in `CIRCEE_PF.mod`, adjust the corresponding steady-state resolution here. Recursive solution from normalised ratios to absolute levels, covering energy prices (from WITCH), lifestyle-weighted parameter aggregation, the numeraire, CES price aggregators, investment, production sectors, household consumption, market clearing, employment, aggregates (GDP, emissions, material flows, waste), the government budget, and trade.

---

## Welfare and distributional analysis

The welfare pipeline runs as **post-processing on the saved model outputs**, reading the raw per-household simulation stored in the welfare `.mat` files. It does **not** require re-running Dynare, so it completes in minutes.

* **`CIRCEE_WelfareAnalysis.m`** — computes lifetime consumption-equivalent variation (CEV) by lifestyle group, and between-group inequality for energy-service access, consumption, and carbon/waste/material footprints. Inequality is reported as a between-group **Gini**, a **high-to-low per-household ratio**, and a between-group **Atkinson** index (ε robustness). All inequality measures are computed on **per-household** quantities. With three lifestyle groups, decile-based measures such as the Palma are not well-defined; the high-to-low per-household ratio is reported instead. Also note that, since we do not observe the full income distribution, the Gini and Atkinson results should be interpreted with caution.
* **`CIRCEE_WelfarePostProcess.m`** — the driver for a single run: loads the saved welfare `.mat` files, calls the analysis, and exports results. Point it at your own input/output folders via its arguments.
* **`CIRCEE_WelfarePostProcess_batch.m`** — an **example** driver that loops over lifestyle × scenario × foresight combinations and calls the single-run driver for each. It is provided as a template: edit the `USER PATHS` block at the top and the lifestyle/scenario lists to match your own runs.
* **`CIRCEE_WelfareExport.m`** — exports the welfare and distributional results to CSV.
* **`Footprints.m`** — computes the material, waste, and carbon footprints used in the distributional analysis.

**To run the welfare post-processing** for a single run:

```matlab
clear functions          % ensure edited functions are reloaded
CIRCEE_WelfarePostProcess('folder',   '<path-to-welfare-inputs>', ...
                          'baseline', 'Baseline', ...
                          'output',   '<path-to-output>')
```

To reproduce a full set of runs, edit the `USER PATHS` block in `CIRCEE_WelfarePostProcess_batch.m` and run it; it loops over the lifestyle and scenario lists you specify.

---

## Calibration and shock files

### calibration.csv
* Columns: `Variable`, `Scenario`, `Model`, `Value`.
* All structural parameters and most exogenous variables, filtered by SSP scenario and model type. Example parameters: substitution elasticities (σ), distribution shares (α), depreciation rates (δ), fiscal parameters.

### shocks.csv (templates/shocks.csv)
* Columns (semicolon-delimited): `Variable`; `Region`; `Year`; `Value`.
* Time paths (2019–2100) for: energy and material efficiencies (WITCH); share of each lifestyle in total population; resource-price evolution (WITCH); R&D, energy-efficiency, and power-generation investments (WITCH); behavioural modifiers; emission factors.

Two copies exist and serve different purposes:
* `data/<REGION>/raw/shocks.csv` — read directly by `CIRCEE_RunFile.m` in classic mode. Shipped with all behavioural modifiers set to zero, so a fresh clone reproduces the reference run.
* `data/<REGION>/templates/shocks.csv` — the skeleton used by the coupled pipeline. `build_shocks_csv` in `scripts/lib/common.sh` appends the modifier paths for a given lifestyle configuration and writes the result to `results/grid_point_data/shocks.csv`.

---

## Outputs

### Coupled mode

Saved at the project root, tagged by scenario name:

| File | Contents |
| --- | --- |
| `shocks_final_<scenario>.csv` | converged modifier path passed to CIRCEE |
| `Sharing_final_<scenario>.csv` | final CIRCEE sharing outputs |
| `Lowering_Expenditures_final_<scenario>.csv` | final CIRCEE sufficiency outputs |
| `convergence_<scenario>.csv` | max frequency change per outer iteration |
| `life_dynamics_<scenario>.csv` | full LIFE frequency state per outer iteration × year |
| `modifiers_sharing_T0.csv` | T0 sharing modifiers, targets, baselines |
| `modifiers_expenditures_T0.csv` | T0 sufficiency modifiers, targets, baselines |

### Baseline mode

| File | Contents |
| --- | --- |
| `shocks_baseline.csv` | zero-modifier shocks fed to CIRCEE |
| `Sharing_baseline.csv` | CIRCEE sharing outputs (no modifiers applied) |
| `Lowering_Expenditures_baseline.csv` | CIRCEE expenditures outputs (no modifiers applied) |

Additional intermediate CIRCEE files land in `grid_point_data/` in both modes. Welfare and distributional CSVs (CEV, Gini, high-to-low per-household ratio, Atkinson) are produced by the welfare pipeline.

---

## Key model variables

**By production sector**: `Y_s` (output), `K_f_s`/`L_s` (capital/labour), `M_s`/`E_s` (materials/energy), `El_s`/`Nel_s` (electricity/fuels), `p_s` (wholesale price).

**By household lifestyle**: `C_h` (consumption), `D_h`/`D_lowuse_h` (durable stock), `X_h`/`SD_h` (nondurables/semi-durables), `ES_h` (energy services), `Inv_d_new_h`/`Inv_d_repair_h` (new/repaired durable investment).

**Government**: `Revenues`, `Expenses`, `PS` (budget); `Carbon_budget`, `EPR_budget` (redistribution).

**Trade**: `IMP_s`, `EXPORT_s`, `TB` (trade balance), `Bonds_foreign`.

**Environment**: `CO2`; `MW`/`IW` (municipal/industrial waste); `DMC`/`DMI` (material consumption/inputs); `M_stock`; `Gross_additions_stock`/`Net_additions_stock`; `Material_balance` (mass-balance check).

---

## SSP scenarios

The current version supports SSP2; further scenarios are planned: SSP1 (sustainable development), SSP2 (middle-of-the-road, default), SSP4 (inequality), SSP5 (rapid growth), NoGrowth (demographic stationarity).

---

## Roadmap

CIRCEE is under active development. Planned extensions include:

* **Supply-side circular-economy strategies** — the current model focuses on demand-side, consumer-facing strategies (sharing, repair, sufficiency). Future versions will add supply-side strategies such as **recycling** and **green product design** (e.g. durability, reparability, and material choices at the design stage).
* **Additional lifestyles** — the **repair** lifestyle will be released open-source (currently available on demand).
* **More regions** — the EU27 and South Korea are planned, alongside the current Japan (JPN) calibration.
* **More SSP scenarios** — SSP1, SSP4, SSP5, and NoGrowth, beyond the current SSP2.
* **A Julia implementation** of the model.

---

## Technical notes

* **Time horizon**: 2018–2100. An extra 20 years (82 periods total) are added to avoid end-of-horizon spikes; discard results from 2081 to 2100. The current CIRCEE-LIFE code gives results from 2018 to 2060. Later periods are discarded. If you wish to run CIRCEE-LIFE after 2060, data on lifestyles are available upon request.
* **Frequency**: annual.
* **Solution method**: perfect foresight, with or without anticipation errors (see the Dynare manual).
* **Expectations handling**: support for expectation errors (`learnt_in`).
* **Convergence**: automatic steady-state verification.

If you encounter any issues, please contact darius.corbier@cmcc.it. Comments and suggestions for model development are welcome.

---

## Citation

If this code supports your work, please cite:

- Corbier, D., Pettifor, H., Agnew, M., & Drouet, L. (2024). CIRCEE, the CIRCular Energy Economy model: Bridging the gap between economic and industrial ecology concepts. *Journal of Industrial Ecology*, 28(6)
- Corbier, D., Pettifor, H., Agnew, Maureen (2026). CIRCEE: The CIRCular Energy Economy model (Version X.Y) [Software]. Zenodo. https://doi.org/10.5281/zenodo.XXXXXXX

**Other references:**

- Emmerling, J., Drouet, L., Reis, L. A., Bevione, M., Berger, L., Bosetti, V., … & Havlik, P. (2016). The WITCH 2016 model — documentation and implementation of the shared socioeconomic pathways (No. 42.2016). Nota di Lavoro.
- Pettifor, H., Agnew, M., & Wilson, C. (2023). A framework for measuring and modelling low-carbon lifestyles. *Global Environmental Change*, 82, 102739.
- Corbier, D., Pettifor, H., Agnew, M., & Nagashima, M. (2025). Shaping sustainable consumption practices: Changing consumers’ habits through lifestyle changes and Extended Producer Responsibility schemes. 
*Resources, Conservation and Recycling*, 217, 108214.
- Corbier, D., Pettifor, H., Agnew, M., & Schlegel, N. (2026). Economic incentives and lifestyle drivers: how they shape consumers' engagement in repairing energy-using consumer goods and their environmental impacts in Japan. *Global Environmental Change*, 96, 103102.

