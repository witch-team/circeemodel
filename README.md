# CIRCEE: The CIRCular Energy Economy model #

## General description

CIRCEE, a deterministic Dynamic Stochastic General Equilibrium (DSGE) model augmented with material flow analysis with mass balance and has a one-way soft-link to the IAM WITCH model (Emmerling et al., 2016), that analyzes the circular economy by integrating material, energy, and economic flows. The model simulates interactions among producers, consumers, government, and the external sector, with a particular focus on consumer-focused circular strategies (sharing, repair, recycling, sufficiency) and climate change mitigation goals. This model captures the trade-offs and synergies between different sustainability objectives. Additionally, there’s a version called « CIRCEE_LIFE » that soft-links CIRCEE in a two-way with the lifestyle model LIFE model (Pettifor et al., 2023). 

## Project structure

### Main files

#### **CIRCEE_PF.mod**

**Role**: Main Dynare model file containing the full economic structure

**Contents**:

* **Macro definitions**: Selection of region (JPN/EU27/CN), model type (B2C/C2C), SSP scenarios, sectors, materials, and lifestyles.

Users can choose between B2C and C2C sharing business models. 

Users can select different regions, such as Japan, and the EU27 coming in October and mainland China in 2026.

Users can only choose the scenario SSP2 among all available scenarios. However, other SSP scenarios beyond SSP2 will be added in the next following months. 

Users can only run CIRCEE without any lifestyle changes.The parameters related to lifestyle changes are referred to as « modifiers » and have a default value of 0 in the public version of the file. If users wish to run CIRCEE-LIFE (sufficiency, repair, and sharing lifestyles), they can request this feature at darius.corbier@cmcc.it.
  
* **Endogenous variables** (600+):

  * Firms’ decision variables (output, investment, employment, energy)
  * Household variables by lifestyle (consumption, saving, durables)
  * Government variables (budget, taxes, subsidies)
  * International trade variables
  * Material stocks and flows
  * CO₂ emissions
* **Predetermined variables**: Capital stocks, durable goods, waste
* **Exogenous variables**: Technological efficiencies, resource prices, fiscal policies
* **Parameters**: Substitution elasticities, preference parameters, depreciation rates
* **Model equations**:

  * Household behavior (by lifestyle: low-carbon, cautious, constrained)
  * Sectoral production functions (consumer goods, materials, services)
  * Market-clearing conditions
  * Physical constraints (material balances, emissions)
  * International trade with Armington CES

**Notable features**:

* Uses the Dynare preprocessor with `@#for` loops to auto-generate equations
* Supports two variants: B2C (business-to-consumer sharing) and C2C (consumer-to-consumer sharing)
* Perfect-foresight solution over 82 periods (2018–2100)

---

#### **CIRCEE_RunFile.m**

**Role**: Main execution and post-processing script

**Execution steps**:

1. **Setup**

   * Select mode (classic/calibration)
   * Select model (B2C/C2C)
   * Choose SSP scenario (SSP1/SSP2/SSP4/SSP5/NoGrowth)

2. **Generate calibration files**

   * `CIRCEE_calibration.m`: Structural parameters from `calibration.csv`
   * `CIRCEE_baseyear_values.m`: Initial values (2018 base year)
   * `CIRCEE_shocks.m`: Paths of exogenous shocks from `shocks.csv`
   * `CIRCEE_endvalues.m`: Terminal values for convergence

3. **Run Dynare**

   * Call `dynare CIRCEE_PF.mod`
   * Compute steady state
   * Solve the transition path

4. **Post-processing of results**

   * **Rescaling**: Multiply by population × productivity
   * **Unit conversion**:

     * Energy in EJ (÷10¹²)
     * Employment in millions of people (÷10⁶)
   * **GDP calculation**: In MER and PPP
   * **CSV generation**:

     * `CIRCEE_output_levels.csv`: Scaled absolute levels
     * `CIRCEE_output_deviation.csv`: Deviations relative to 2020
     * `CIRCEE_output_levels_efficientlaborunit.csv`: Per effective labor unit
     * `CIRCEE_output_deviation_efficientlaborunit.csv`: Relative deviations
     * Thematic files: Electrification, Sharing, Repairing, Lowering_Expenditures

5. **Welfare analysis**

   * Compute consumption equivalent by lifestyle
   * Compare 2018 vs 2050

---

#### **CIRCEE_steadystatemodel.m**

**Role**: Analytical steady-state computation

**Sections**:

1. **Energy prices**: Derived from WITCH trajectories
2. **Parameter aggregation**: Lifestyle-weighted averages
3. **Numeraire**: Fix the price of capital goods
4. **Price aggregators**: Composite (CES) prices for each sector
5. **Investment decisions**: Capital and household durables
6. **Production sectors**:

   * Consumer goods (nondurables, semi-durables, durables)
   * Capital goods
   * Materials (virgin, recycled)
   * Services (repair, sharing)
7. **Household consumption**: By lifestyle and good type
8. **Market clearing**: Supply–demand equalization
9. **Employment**: Sectoral labor allocation
10. **Aggregates**: GDP, emissions, material flows, waste
11. **Government budget**: Revenues, expenditures, primary balance
12. **Trade**: Imports, exports, trade balance

**Method**: Recursive solution starting from normalized ratios, then computing absolute levels

---

### Calibration files (not provided)

#### **calibration.csv**

**Expected structure**:

* Columns: `Variable`, `Value`, `Scenario`, `Model`
* Contains all structural parameters of the model
* Filtered by SSP scenario and model type (B2C/C2C)

**Example parameters**:

* Substitution elasticities (σ)
* Distribution shares (α)
* Depreciation rates (δ)
* Fiscal parameters
* Behavioral parameters

#### **shocks.csv**

**Expected structure**:

* Columns: `Variable`, `Year`, `Value`
* Time paths for 2019–2100 for:

  * Energy and material efficiencies (WITCH)
  * Resource prices
  * Public policies (taxes, subsidies, EPR)
  * Utilization and repair rates
  * Emission factors

---

## Key model variables

### By production sector

* `Y_s`: Sectoral output
* `K_f_s`, `L_s`: Capital and labor
* `M_s`, `E_s`: Materials and energy
* `El_s`, `Nel_s`: Electricity and fuels
* `p_s`: Wholesale price

### By household lifestyle

* `C_h`: Aggregate consumption
* `D_h` or `D_lowuse_h`: Stock of durable goods
* `X_h`, `SD_h`: Nondurables and semi-durables
* `ES_h`: Energy services
* `Inv_d_new_h`, `Inv_d_repair_h`: New and repaired durable investment

### Government

* `Revenues`, `Expenses`, `PS`: Public budget
* `Carbon_budget`, `EPR_budget`: Tax redistribution

### Trade

* `IMP_s`, `EXPORT_s`: Sectoral trade
* `TB`: Trade balance
* `Bonds_foreign`: External debt

### Environment

* `CO2`: Total emissions
* `MW`, `IW`: Municipal and industrial waste
* `DMC`, `DMI`: Domestic material consumption and inputs
* `M_stock`: Total material stock

---

## Usage

### Standard run

```matlab
CIRCEE_RunFile('classic', 'B2C')
```

### Calibration mode

```matlab
CIRCEE_RunFile('calibration', 'C2C')
```

### Parameters

* `mode`: 'classic' (default) or 'calibration'
* `modelType`: 'B2C' (default) or 'C2C'

---

## SSP scenarios

The model supports 5 population and economic growth scenarios:

* **SSP1**: Sustainable development
* **SSP2**: Middle-of-the-road trends (default)
* **SSP4**: Inequality
* **SSP5**: Rapid growth
* **NoGrowth**: Demographic stationarity

---

## Outputs

### Generated CSV files (in `/Output`)

1. Absolute levels and relative deviations
2. Variables normalized per unit of effective labor
3. Thematic files for circular strategies

### Rescaled variables

* Economic variables: × (population × productivity)
* Employment: × population
* Energy: in exajoules (EJ)

---

## Dependencies

* **MATLAB** R2016b or later
* **Dynare** 4.6 or later
* Toolbox: Statistics and Machine Learning

---

## Technical notes

* **Time horizon**: 2018–2100 (82 periods)
* **Frequency**: Annual
* **Solution method**: Perfect foresight
* **Expectations handling**: Support for expectation errors (`learnt_in`)
* **Convergence**: Automatic steady-state verification

---

## Author and references

This model implements a circular-economy framework with three heterogeneous lifestyles, integrating production, consumption, material flows, and public policies within a dynamic general equilibrium setting.



   - Model File : "CIRCEE_PF.mod"
  
This is the primary model file that contains the declarations of variables and parameters, as well as the main equations and FOCs of the model. For a comprehensive overview of the equations, please refer to the Appendix of Corbier et al. (2025). It’s important to note that the model’s equations have undergone slight modifications since Corbier et al. (2025). 
    
  - Steady State File : "CIRCEE_steadystatemodel.m"
  
This file manually solves the steady-state of the model. If you modify any equation in CIRCEE_PF.mod, you must also adjust the model’s resolution for the steady state in CIRCEE_steadystatemodel.m.

  - Calibration file : "calibration.csv"
  
This is the calibration file with the values for parameters, and exogenous variables at steady state. The baseline year is 2018. 
    
  - Shocks file : "shocks.csv"
  
This file contains the values of exogenous/policy variables that can be introduced into the system at any time in a deterministic set up with no anticipation erros. 

To run the model, users must download Dynare from https://www.dynare.org/ and use either Matlab (version 2023-2024) or GNU Octave. A new version will be available for Julia users in the coming months. If possible, I recommend using Matlab over GNU Octave. To run CIRCEE, users can call the file « CIRCEE_RunFile.m » from their Matlab or GNU Octave console. If you encounter any issues, please contact darius.corbier@cmcc.it. Also, any comments or suggestions for model development are more than welcomed. 

If you use CIRCEE, please cite:

- Corbier, D., Pettifor, H., Agnew, M., & Drouet, L. (2024). CIRCEE, the CIRCular Energy Economy model: Bridging the gap between economic and industrial ecology concepts. Journal of Industrial Ecology, 28(6), 1996-2011.

- Corbier, D., Pettifor, H., Agnew, M., & Nagashima, M. (2025). Shaping sustainable consumption practices: Changing consumers’ habits through lifestyle changes and Extended Producer Responsibility schemes. Resources, Conservation and Recycling, 217, 108214.

Other references :

Emmerling, J., Drouet, L., Reis, L. A., Bevione, M., Berger, L., Bosetti, V., ... & Havlik, P. (2016). The WITCH 2016 model-documentation and implementation of the shared socioeconomic pathways (No. 42.2016). Nota di Lavoro.

Pettifor, H., Agnew, M., & Wilson, C. (2023). A framework for measuring and modelling low-carbon lifestyles. Global Environmental Change, 82, 102739.


To introduce specific exogenous or policy variables (varexo in CIRCEE_PF.mod) with a particular growth rate, users can follow the instructions in section 3.1.2. of "CIRCEE_RunFile.m". Alternatively, they can specify specific absolute values in "shock.csv" or in CIRCEE_PF.mod. If they desire a fully deterministic model with no error of anticipation, they can use "shock.csv". Conversely, if they want a deterministic setup with anticipation errors, they can include the line "@#include CIRCEE_shocks.m " in "CIRCEE_PF.mod". Also, you need to insert a terminal value for the shock in "terminal conditions" in "CIRCEE_steadystatemodel.m". For further information of the shock structure, please refer to the Dynare manual book at https://www.dynare.org/. 

One piece of advice : avoid using too many shocks and to be cautious about the magnitude of the shocks or you will bump into infeasibilities and corner solutions. 

---

