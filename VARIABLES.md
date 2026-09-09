# Variable reference

Code names, descriptions and units for the main endogenous variables in
`src/CIRCEE_PF.mod` and the output CSVs.

`@{h}` stands for a lifestyle group — `lowcarbon`, `cautious` or `constrained`.
`@{s}` stands for a final-goods sector — `nondurable`, `otherdurable`,
`energydurable` or `capital`. `@{m}` stands for a material — `virgin` or
`recycled`. In the output CSVs these are written out, e.g. `C_lowcarbon`,
`Y_energydurable`, `M_virgin_capital`.

---

## Units

The output CSVs and the model's internal values differ, and the tables below
document the **output CSVs**.

In the CSVs, monetary values are economy-wide totals in JPY, rescaled by
`CIRCEE_RunFile.m` from the model's per-household values (2018 GDP ≈ 5.4e14 JPY).
Energy is converted to **EJ** (2018 household electricity ≈ 0.94 EJ).
Employment is in **millions**. CO₂ is in **Mt** (2018 total ≈ 1155 Mt).
Materials and waste stay in **grams** — divide by 1e12 for megatonnes
(2018 in-use stock ≈ 3.6e16 g, i.e. 36 Gt).

Inside the model, before post-processing, values are detrended and
per-household: the model is solved on a balanced growth path with
labour-productivity and population growth removed, and the capital-good price
normalised (`p_capital_norm = 1`). Energy is in MJ.

All user costs and prices are relative to the capital good, which is the numeraire (p_capital_norm = 1), and are therefore dimensionless.

Anything named `*_percapita` in the code is **per household**, not per person.

CES aggregates — `C`, `NES`, `ES`, `ES_home`, `Z_*`, `KL_*` — combine inputs
measured in different units and are therefore index values normalised at the
2018 base year. Only their ratios and growth rates are meaningful.

---

## Households (lifestyle groups)

| Code name | Description | Unit |
| --- | --- | --- |
| `C_@{h}` | Aggregate consumption (CES index) | index |
| `NES_@{h}` | Non-energy services bundle (CES index) | index |
| `ES_@{h}` | Aggregate energy services (CES index) | index |
| `ES_home_@{h}` | Home-produced energy services (CES aggregate of durable stock and energy) | index |
| `ES_sharing_@{h}` | Energy services bought from the PSS market | JPY |
| `X_@{h}` | Non-durable good consumption | JPY |
| `OD_@{h}` | Other durable good stock | JPY |
| `ED_lowuse_@{h}` | Owned energy-using durable good stock | JPY |
| `E_@{h}` | Aggregate energy consumption | EJ |
| `El_@{h}` | Electricity consumption | EJ |
| `Nel_@{h}` | Fuel consumption | EJ |
| `Inv_ed_new_@{h}` | New energy-using durable goods investments, replacing depreciated stock | JPY |
| `Inv_ed_new_tild_@{h}` | New energy-using durable goods investments, additions to the stock | JPY |
| `Inv_ed_repair_@{h}` | Repaired energy-using durable goods investments | JPY |
| `Inv_od_@{h}` | Other durable good investment | JPY |
| `Inv_k_@{h}` | Capital investment (savers only, i.e. low-carbon and cautious households) | JPY |
| `K_@{h}` | Capital stock (savers only) | JPY |
| `u_lowuse_@{h}` | Utilisation rate of the owned durable stock(share of time in use) | – |
| `uc_@{h}` | User cost of owned energy-using durables | – |
| `omegga_repair_@{h}` | Share of repair in total energy-using goods expenditure | – |
| `p_home_@{h}` | Price of home-produced energy services | – |
| `disc_factor_@{h}` | Effective discount factor | – |
| `Expenditures_LIFE_@{h}` | Total energy-using goods expenditure | JPY |
| `AC_ID_new_@{h}` | Durable investment adjustment costs | JPY |
| `AC_IK_@{h}` | Capital investment adjustment costs | JPY |
| `g_inv_ed_@{h}` | CES aggregator of new and repaired investment for depreciated durables | index |
| `AC_ID_g_@{h}` | Adjustment costs on the depreciated-durable investment aggregator | – |
| `repair_ed_@{h}` | Repair expenditure per unit of owned energy-using durable | – |
| `deltta_energydurable_lowuse_@{h}` | Endogenous depreciation rate of the owned durable stock | rate |
| `A_nel_@{h}` | Fuel efficiency of the group's durable stock | – |
| `p_e_h_@{h}` | Zero-profit household energy price (CES index) | – |
| `q_ed_newtild_@{h}` | Shadow price of new owned energy-using goods (additions to the stock) | – |
| `q_ed_depreciated_@{h}` | Shadow price of owned energy-using goods at the replacement margin | – |
| `q_ed_newtild_highuse` | Shadow price of new PSS-held durables | – |
| `q_k_lowcarbon` | Shadow price of new capital goods | – |

## Footprints (totals by lifestyle group)

| Code name | Description | Unit |
| --- | --- | --- |
| `CF_@{h}` | Total lifecycle carbon footprint | Mt CO₂ |
| `WF_@{h}` | Total waste footprint of the consumption basket | g |
| `MF_@{h}` | Consumption-side material footprint, net of process losses | g |
| `CF_prod_<good>_@{h}` | Upstream and production-phase carbon, by good | Mt CO₂ |
| `CF_eol_<good>_@{h}` | End-of-life carbon, by good | Mt CO₂ |
| `CF_IW_<good>_@{h}` | Industrial-waste incineration carbon, by good | Mt CO₂ |
| `WF_<good>_@{h}` | Waste embodied in consumption, by good | g |
`<good>` is `nondurable`, `otherdurable`, `energydurable`, `sharing` or `repair`.

## Production

| Code name | Description | Unit |
| --- | --- | --- |
| `Y_@{s}`, `Y_sharing`, `Y_repair` | Sector output | JPY |
| `Y_@{m}`, | Virgin and secondary material sector output | g | 
| `K_f_@{s}`, `K_@{m}`, `K_repair` | Capital input | JPY |
| `L_@{s}`, `L_@{m}`, `L_sharing`, `L_repair` | Labour input | share of total employment |
| `E_@{s}`, `E_@{m}`, `E_sharing` | Aggregate energy input | EJ |
| `El_@{s}`, `Nel_@{s}` | Electricity and fuel input | EJ |
| `M_@{s}` | Aggregate material input | g |
| `M_virgin_@{s}` | Virgin material input | g |
| `M_recycled_@{s}` | Secondary material input | g |
| `RM` | Raw material input of the virgin-material sector | g |
| `RW` | Waste processed by the recycling sector | g |
| `p_@{s}` | Wholesale price | – |
| `p_def_@{s}` | Armington price deflator | – |
| `p_e_@{s}`, `p_m_@{s}` | Zero-profit energy and material price | – |
| `DIV_<sector>` | Sector dividends | JPY |

## PSS and repair sectors

| Code name | Description | Unit |
| --- | --- | --- |
| `Y_sharing` | PSS firm output | JPY |
| `p_sharing` | PSS price | – |
| `ED_highuse` | Energy-using durables held by the PSS firm | JPY |
| `u_highuse` | Utilisation rate of PSS-held durables (share of time) | – |
| `r_ed` | Rental rate of PSS-held durables | – |
| `Inv_ed_new_highuse` | PSS investment in new energy-using durables | JPY |
| `Y_repair` | Repair sector output | JPY |
| `p_repair` | Repair services price | – |

## Prices and factor markets

| Code name | Description | Unit |
| --- | --- | --- |
| `w` | Detrended efficiency wage; the wage per worker is w × A_t | – |
| `r_k` | Rental price of capital | – |
| `K` | Capital stock of the economy | JPY |
| `h` | Average hours worked | hours |
| `p_el_h`, `p_el_f` | Household and firm electricity price | JPY/EJ |
| `p_nel_h`, `p_nel_f` | Household and firm fuel price | JPY/EJ |
| `p_nd_ati` | All-tax-included non-durable price | – |

## Government

| Code name | Description | Unit |
| --- | --- | --- |
| `Revenues`, `Expenses` | Fiscal revenues and expenses | JPY |
| `PS` | Primary surplus | JPY |
| `X_G`, `OD_G`, `ED_G` | Public non-durable, other durable, energy-using durable | JPY |
| `Carbon_budget` | Carbon-tax revenue redistributed to households | JPY |
| `EPR_budget` | EPR revenue redistributed to households | JPY |
| `sub_recycled` | Implicit subsidy to the recycling sector (diagnostic) | JPY |

## Trade

| Code name | Description | Unit |
| --- | --- | --- |
| `IMP_@{s}`, `IMP_@{m}` | Imports of goods and materials | JPY, g |
| `EXPORT_@{s}`, `EXPORT_@{m}` | Exports of goods and materials | JPY, g |
| `Demand_dom_@{s}` | Domestic demand for domestically-produced goods | JPY |
| `Domestic_Extraction` | Domestic extraction of raw materials | g |
| `TB` | Trade balance | JPY |

## Material stocks and flows

| Code name | Description | Unit |
| --- | --- | --- |
| `M_stock` | Total in-use material stock | g |
| `M_stock_@{s}` | In-use stock by good | g |
| `Gross_additions_stock` | Gross additions to the stock | g |
| `Net_additions_stock_@{s}` | Net additions by good | g |
| `DMI` | Domestic material input | g |
| `DMC` | Domestic material consumption | g |
| `Material_balance` | Production-side mass-balance residual (should be ≈ 0) | g |
| `Material_balance_EWMFA` | Economy-wide mass-balance residual | g |
| `Material_balance_stocks` | Stock-side mass-balance residual | g |

## Waste

| Code name | Description | Unit |
| --- | --- | --- |
| `IW`, `MW` | Total industrial and municipal waste | g |
| `IW_l`, `MW_l` | Landfilled or incinerated | g |
| `IW_r`, `MW_r` | Sent to recycling | g |
| `MW_nondurables`, `MW_otherdurables`, `MW_energydurables` | Municipal waste by good | g |
| `NR_stock_mu`, `NR_stock_indu` | Accumulated non-recyclable waste stocks | g |
| `Finalsink_total` | Waste reaching the final sink | g |

## Emissions and aggregates

| Code name | Description | Unit |
| --- | --- | --- |
| `CO2` | Total CO₂ emissions | Mt |
| `CO2_economy` | Emissions excluding incineration | Mt |
| `CO2_incineration` | Incineration emissions | Mt |
| `El`, `Nel` | Economy-wide electricity and fuel flows | EJ |
| `GDP` | Gross domestic product | JPY |
| `Y_power` | Power sector value added | JPY |

## Lifestyle shares and modifiers

| Code name | Description | Unit |
| --- | --- | --- |
| `omegga_lowcarbon`, `omegga_cautious` | Population share of each group (exogenous) | – |
| `omegga_constrained` | Population share of the lower-income group | – |
| `modifier_sharing_@{h}` | Sharing lifestyle modifier (exogenous) | – |
| `modifier_expenditures_@{h}` | Sufficiency lifestyle modifier (exogenous) | – |
| `modifier_repair_@{h}` | Repair lifestyle modifier (exogenous, held at 0) | – |
| `siggma_es_@{h}` | Home-to-market energy services substitution elasticity | – |
