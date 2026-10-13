# Supplementary tables — CIRCEE-LIFE

To ensure accurate simulations, it is essential to reproduce the historical macroeconomic data of Japan. The model is calibrated to 2018 as its initial steady state. In the Dynare software implementation, CIRCEE-LIFE is initialised on a balanced growth path, where all endogenous variables grow at constant rates and agents’ optimality conditions hold exactly, before the simulation begins over the 2018–2050 horizon. The choice of 2018 as the base year is justified on two grounds. Technically, 2018 is the year for which the full set of calibration data is available at sufficient disaggregation across national accounts, material flow accounts, and consumer surveys. Empirically, 2018 corresponds to a period of low cyclical activity in Japan: the output gap stood at 1.86% according to Bank of Japan data, indicating that the Japanese economy was close to its potential output and therefore a reasonable approximation of the balanced growth path that the steady state initialisation requires. Together, these conditions ensure that the model’s initial conditions reflect structural rather than cyclical features of the Japanese economy.

The model parameters and exogenous variables follow the latest CIRCEE-LIFE<sup>1</sup> calibration, drawing mainly on Japanese national statistics (E-stat and the Agency of Natural Resources and Energy), the Japan Industrial Productivity Database 2021 (RIETI), the OECD.Stat database for fiscal data and SSP Scenario Explorer 3.2.0 for SSP2. The calibration of depreciation rates, waste flows and material stocks and flows has been refined since earlier versions of CIRCEE<sup>1</sup> thanks to special data extracts from the Mat_stocks database<sup>2,3</sup>. We focus on SSP2 for demographic and economic growth data from the IIASA database, and for the evolution of each lifestyle group’s share of the total population in the LIFE-CE model.

Parameters and exogenous variables related to materials and waste are calibrated on the model’s first-order conditions (FOCs) and on data from the Mat_stocks database (MISO2) and the Ministry of the Environment’s White Papers on the Sound Material Cycle society and reports on industrial and municipal waste, RIETI’s input-output tables and the Ministry of the Environment’s Sankey diagrams (waste generation and management). Prices of raw, virgin and secondary materials were computed from FOCs, data from RIETI’s IO table (nominal expenses data), material flows from MISO2 and waste reports from the Ministry of the Environment (quantity data).

To facilitate cross-country comparison, the CIRCEE-LIFE model can be recalibrated using country-specific behavioural parameters, waste-management practices, material stocks and flows data and national statistics. Such adaptations will enable policymakers to evaluate context-specific trade-offs. The following table presents parameter values and their sources<sup>1</sup>.


## Supplementary Table 1. Calibration of CIRCEE

| Description | Code name | Value | Source of data |
| --- | --- | --- | --- |
| Labour-productivity growth rate | `g` | 0.01153 | SSPs database<sup>4,5,6</sup> |
| Population growth rate | `n` | -0.00642 | SSPs database<sup>4,5,6</sup> |
| Import Armington elasticity | `siggma_imports` | 3.4 | [7], [8] |
| Export Armington elasticity | `siggma_exports` | 3.1 | [7], [8] |
| Non-energy services and energy services substitution elasticity | `siggma_c` | 0.98 | [9], [10] |
| Durable goods and energy substitution elasticity | `siggma_home` | 0.425 | [10], [11], [12] |
| Capital-labour-energy and material inputs substitution elasticity | `siggma_y` | 0.2 | [13], [14] |
| Capital and labour inputs substitution elasticity | `siggma_kl` | 0.75 | [14], [15] |
| Firms’ electricity and fuels inputs substitution elasticity | `siggma_e_f` | 0.66 | WITCH model [16] |
| Primary and secondary material inputs substitution elasticity | `siggma_m` | 0.8 | Model assumption concerning material balance |
| Capital-labour and energy inputs substitution elasticity | `siggma_z` | 0.4 | [15], [17], [18] |
| Households’ electricity and fuels substitution elasticity | `siggma_e_h` | 0.66 | WITCH model [16] |
| PSS firm’s labour input and energy-using good-energy inputs substitution elasticity | `siggma_sharing` | 0.5 | Model’s assumption |
| Coefficient of relative risk aversion | `siggma_ies` | 1.22 | [19], [20] |
| Non-durable good and semi-durable good substitution elasticity | `siggma_nes` | 0.98 | [9], [21], [22] |
| Repair and new energy-using goods substitution elasticity | `siggma_inv_ed` | 1.5 | Model’s assumption |
| Energy-using goods investment adjustment cost parameter | `ac_id` | 0.86845 | [23] |
| Capital goods investment adjustment cost parameter | `ac_ik` | 1.46 | [23] |
| Value-added tax | `t_c` | 0.099 | OECD.stat and RIETI |
| Capital income tax | `t_k` | 0.17906 | OECD.stat and RIETI |
| Labour income tax | `t_l` | 0.31957 | OECD.stat and RIETI |
| Government demand share in non-durable goods | `g_c_nondurable` | 0.32062 | Model’s First-Order Conditions and RIETI data |
| Government demand share in other durable goods | `g_c_otherdurable` | 0.0002 | Model’s First-Order Conditions and RIETI data |
| Government demand share in energy-using goods | `g_c_energydurable` | 1.3484E-5 | Model’s First-Order Conditions and RIETI data |
| Non-durable good producer’s labour distribution parameter | `alppha_n_nondurable` | 0.03706 | Model’s First-Order Conditions and RIETI data |
| Non-durable good producer’s capital distribution parameter | `alppha_k_nondurable` | 0.59052 | Model’s First-Order Conditions and RIETI data |
| Other-durable good producer’s labour distribution parameter | `alppha_n_otherdurable` | 0.04265 | Model’s First-Order Conditions and RIETI data |
| Other-durable good producer’s capital distribution parameter | `alppha_k_otherdurable` | 0.46333 | Model’s First-Order Conditions and RIETI data |
| Energy-using good producer’s labour distribution parameter | `alppha_n_energydurable` | 0.02515 | Model’s First-Order Conditions and RIETI data |
| Energy-using good producer’s capital distribution parameter | `alppha_k_energydurable` | 0.90498 | Model’s First-Order Conditions and RIETI data |
| Capital good producer’s labour distribution parameter | `alppha_n_capital` | 0.02512 | Model’s First-Order Conditions and RIETI data |
| Capital good producer’s capital distribution parameter | `alppha_k_capital` | 0.90595 | Model’s First-Order Conditions and RIETI data |
| Primary material producer’s labour distribution parameter | `alppha_n_virgin` | 0.03978 | Model’s First-Order Conditions and RIETI data |
| Primary material producer’s capital distribution parameter | `alppha_k_virgin` | 0.52715 | Model’s First-Order Conditions and RIETI data |
| Secondary material producer’s labour distribution parameter | `alppha_n_recycled` | 0.02835 | Model’s First-Order Conditions and RIETI data |
| Secondary material producer’s capital distribution parameter | `alppha_k_recycled` | 0.81428 | Model’s First-Order Conditions and RIETI data |
| Repair firm’s labour distribution parameter | `alppha_n_repair` | 0.06464 | Model’s First-Order Conditions and RIETI data |
| Repair firm’s capital distribution parameter | `alppha_k_repair` | 0.08098 | Model’s First-Order Conditions and RIETI data |
| Non-durable good producer’s capital-labour distribution parameter | `alppha_kl_nondurable` | 0.85934 | Model’s First-Order Conditions and RIETI data |
| Non-durable good producer’s energy distribution parameter | `alppha_e_nondurable` | 0.00017 | Model’s First-Order Conditions, Agency for Natural Resources and Energy and RIETI data |
| Other-durable good producer’s capital-labour distribution parameter | `alppha_kl_otherdurable` | 0.85181 | Model’s First-Order Conditions and RIETI data |
| Other-durable good producer’s energy distribution parameter | `alppha_e_otherdurable` | 0.00012 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, and RIETI data |
| Energy-using good producer’s capital-labour distribution parameter | `alppha_kl_energydurable` | 0.92464 | Model’s First-Order Conditions and RIETI data |
| Energy-using good producer’s energy distribution parameter | `alppha_e_energydurable` | 2.00373E-5 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, and RIETI data |
| Capital good producer’s capital-labour distribution parameter | `alppha_kl_capital` | 0.96158 | Model’s First-Order Conditions and RIETI data |
| Capital good producer’s energy distribution parameter | `alppha_e_capital` | 4.21430E-6 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, and RIETI data |
| Primary material producer’s capital-labour distribution parameter | `alppha_kl_virgin` | 0.45033 | Model’s First-Order Conditions and RIETI data |
| Primary material producer’s energy distribution parameter | `alppha_e_virgin` | 0.00745 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, and RIETI data |
| Secondary material producer’s capital-labour distribution parameter | `alppha_kl_recycled` | 0.69053 | Model's First-Order Conditions and RIETI data |
| Secondary material producer’s energy distribution parameter | `alppha_e_recycled` | 0.00087 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, and RIETI data |
| Non-durable good producer’s capital-labour-energy distribution parameter | `alppha_z_nondurable` | 0.97866 | Model's First-Order Conditions and RIETI data |
| Non-durable good producer’s material distribution parameter | `alppha_m_nondurable` | 5.33987E-7 | Model’s First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Resource Panel database |
| Other-durable good producer’s capital-labour-energy distribution parameter | `alppha_z_otherdurable` | 0.8028 | Model’s First-Order Conditions and RIETI data |
| Other-durable good producer’s material distribution parameter | `alppha_m_otherdurable` | 0.03851 | Models First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Resource Panel database |
| Energy-using good producer’s capital-labour-energy distribution parameter | `alppha_z_energydurable` | 0.69112 | Model’s First-Order Conditions and RIETI data |
| Energy-using good producer’s material distribution parameter | `alppha_m_energydurable` | 0.43556 | Models First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Resource Panel database |
| Capital good producer’s capital-labour-energy distribution parameter | `alppha_z_capital` | 0.32059 | Model’s First-Order Conditions and RIETI data |
| Capital good producer’s material distribution parameter | `alppha_m_capital` | 84.2245 | Models First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Resource Panel database |
| Primary material producer’s capital-labour-energy distribution parameter | `alppha_z_virgin` | 2.16386E-6 | Model’s First-Order Conditions and RIETI data |
| Primary material producer’s raw material distribution parameter | `alppha_rm` | 0.15589 | Models First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Resource Panel database |
| Secondary material producer’s capital-labour-energy distribution parameter | `alppha_z_recycled` | 6.83961E-7 | Model’s First-Order Conditions and RIETI data |
| Secondary material producer’s recyclable waste distribution parameter | `alppha_rw` | 0.01525 | Models First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Resource Panel database |
| Discount factor (effective discount rate equals 0.993) | `betta` | 0.99929 | Model’s First-Order Conditions and RIETI data |
| Domestic production of non-durable good distribution parameter | `share_domestic_nondurable` | 0.98529 | Model’s First-Order Conditions and RIETI data |
| Domestic production of other-durable good distribution parameter | `share_domestic_otherdurable` | 0.47762 | Model’s First-Order Conditions and RIETI data |
| Domestic production of energy-using good distribution parameter | `share_domestic_energydurable` | 0.90207 | Model’s First-Order Conditions and RIETI data |
| Domestic production of capital good distribution parameter | `share_domestic_capital` | 0.7497 | Model’s First-Order Conditions and RIETI data |
| Domestic production of primary material distribution parameter | `share_domestic_virgin` | 0.99556 | Model’s First-Order Conditions, Resource Panel and RIETI data |
| Domestic production of secondary material distribution parameter | `share_domestic_recycled` | 0.99426 | Model’s First-Order Conditions, Ministry of the Environment, Resource Panel and RIETI data |
| Imports of non-durable good distribution parameter | `share_imp_nondurable` | 0.53987 | Model’s First-Order Conditions and RIETI data |
| Imports of other-durable good distribution parameter | `share_imp_otherdurable` | 0.46718 | Model’s First-Order Conditions and RIETI data |
| Imports of energy-using good distribution parameter | `share_imp_energydurable` | 0.93552 | Model’s First-Order Conditions and RIETI data |
| Imports of capital good distribution parameter | `share_imp_capital` | 0.44937 | Model’s First-Order Conditions and RIETI data |
| Imports of primary material distribution parameter | `share_imp_virgin` | 0.29092 | Model’s First-Order Conditions, Resource Panel and RIETI data |
| Imports of secondary material distribution parameter | `share_imp_recycled` | 0.31353 | Model’s First-Order Conditions, Ministry of the Environment, Resource Panel and RIETI data |
| Exports of non-durable good to the Rest of the World (RoW) distribution parameter | `share_row_nondurable` | 0.16907 | Model’s First-Order Conditions, World Bank and RIETI data |
| Exports of other-durable goods to the RoW distribution parameter | `share_row_otherdurable` | 0.29599 | Model’s First-Order Conditions, World Bank and RIETI data |
| Exports of energy-using good to the RoW distribution parameter | `share_row_energydurable` | 0.34426 | Model’s First-Order Conditions, World Bank and RIETI data |
| Exports of capital good to the RoW distribution parameter | `share_row_capital` | 0.21792 | Model’s First-Order Conditions, World Bank and RIETI data |
| Exports of primary materials to the RoW distribution parameter | `share_row_virgin` | 1.01275 | Model’s First-Order Conditions, Resource Panel and RIETI data |
| Exports of secondary materials to the RoW distribution parameter | `share_row_recycled` | 1.01346 | Model’s First-Order Conditions, Ministry of the Environment, Resource Panel and RIETI data |
| Foreign production of non-durable good distribution parameter | `share_row_dom_nondurable` | 0.99869 | Model’s First-Order Conditions, World Bank and RIETI data |
| Foreign production of other-durable good distribution parameter | `share_row_dom_otherdurable` | 0.99254 | Model’s First-Order Conditions, World Bank and RIETI data |
| Foreign production of energy-using good distribution parameter | `share_row_dom_energydurable` | 0.98802 | Model’s First-Order Conditions, World Bank and RIETI data |
| Foreign production of capital good distribution parameter | `share_row_dom_capital` | 0.99712 | Model’s First-Order Conditions, World Bank and RIETI data |
| Foreign demand for the domestic production of non-durable goods | `Demand_foreign_nondurable` | 12.59126 | World Bank and RIETI data |
| Foreign demand for the domestic production of other-durable goods | `Demand_foreign_otherdurable` | 12.59126 | World Bank and RIETI data |
| Foreign demand for the domestic production of energy-using goods | `Demand_foreign_energydurable` | 12.59126 | World Bank and RIETI data |
| Foreign demand for the domestic production of capital goods | `Demand_foreign_capital` | 10.28267 | World Bank and RIETI data |
| Social transfers (JPY) | `Tr` | 0.12365 | OECD data |
| Household’s habit consumption parameter | `habit_@{h}` | 0.55 | [24] |
| PSS firm’s energy-using good input distribution parameter | `alppha_ed_sharing` | 0.67565 | Model’s First-Order Conditions, RIETI and OECD data |
| PSS firm’s energy input distribution parameter | `alppha_e_sharing` | 0.00744 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, E-stat, OECD and RIETI databases |
| PSS firm’s energy-services input distribution parameter | `alppha_es_sharing` | 0.15388 | Model’s First-Order Conditions and Survey on the current state of the sharing economy from e-stat.go.jp |
| PSS firm’s labour input parameter | `alppha_n_sharing` | 0.00015 | Model’s First-Order Conditions, RIETI and OECD data |
| Non-energy services distribution parameter in nested consumption CES | `alppha_nes_@{h}` | 0.901 | Model’s First-Order Conditions, E-stat and RIETI data |
| Energy services distribution parameter in nested consumption CES | `alppha_es_@{h}` | 0.0926 | Model’s First-Order Conditions and Survey on the current state of the sharing economy from e-stat.go.jp |
| Non-durable goods distribution parameter in nested consumption CES | `alppha_x_@{h}` | 0.92874 | Model’s First-Order Conditions and RIETI data |
| Other-durable goods distribution parameter in nested consumption CES | `alppha_od_@{h}` | 0.06688 | Model’s First-Order Conditions and RIETI data |
| PSS energy services distribution parameter in nested consumption CES | `alppha_sharing_@{h}` | 0.08177 | Model's First-Order Conditions, E-stat and RIETI databases |
| Home-produced energy services distribution parameter in nested consumption CES | `alppha_home_@{h}` | 0.94250 | Model’s First-Order Conditions, RIETI data and the Survey on the Current State of the Sharing Economy from e-stat.go.jp |
| New energy-using goods investments distribution parameter in nested investment CES | `alppha_ed_new_@{h}` | 0.83944 | Model’s First-Order Conditions, OECD and RIETI data |
| Repaired energy-using goods investments distribution parameter in nested investment CES | `alppha_ed_repair_@{h}` | 0.37758 | Model’s First-Order Conditions, OECD and RIETI data |
| Energy-using goods distribution parameter in nested consumption CES | `alppha_d_@{h}` | 0.71246 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Households’ energy distribution parameter in nested consumption CES | `alppha_e_@{h}` | 0.01576 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Households’ electricity distribution parameter | `alppha_el_@{h}` | 0.25978 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Households’ fuels distribution parameter | `alppha_nel_@{h}` | 0.43806 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, E-stat, OECD and RIETI databases |
| Secondary material producer’s electricity input distribution parameter | `alppha_el_recycled` | 0.61362 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Secondary material producer’s fuel input distribution parameter | `alppha_nel_recycled` | 0.12927 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Primary material producer’s electricity input distribution parameter | `alppha_el_virgin` | 0.17009 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Primary material producer’s fuel input distribution parameter | `alppha_nel_virgin` | 0.55322 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Capital good producer’s electricity input distribution parameter | `alppha_el_capital` | 0.47126 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Capital good producer’s fuel input distribution parameter | `alppha_nel_capital` | 0.22542 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Energy-using good producer’s electricity input distribution parameter | `alppha_el_energydurable` | 0.64802 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Energy-using good producer’s fuel input distribution parameter | `alppha_nel_energydurable` | 0.11005 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Semi-durable good producer’s electricity input distribution parameter | `alppha_el_otherdurable` | 0.63531 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Other-durable good producer’s fuel input distribution parameter | `alppha_nel_otherdurable` | 0.11698 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Non-durable good producer’s electricity input distribution parameter | `alppha_el_nondurable` | 0.1411 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Non-durable good producer’s fuel input distribution parameter | `alppha_nel_nondurable` | 0.59998 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| PSS energy services producer’s electricity input distribution parameter | `alppha_el_sharing` | 0.28728 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| PSS energy services producer’s fuel input distribution parameter | `alppha_nel_sharing` | 0.39874 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, E-stat, OECD and RIETI databases |
| Non-durable good producer’s primary materials input distribution parameter | `alppha_v_nondurable` | 0.03114 | Model’s First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Other-durable good producer’s primary materials input distribution parameter | `alppha_v_otherdurable` | 0.26476 | Model’s First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Energy-using good producer’s primary materials input distribution parameter | `alppha_v_energydurable` | 0.45407 | Model’s First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Capital good producer’s primary materials input distribution parameter | `alppha_v_capital` | 0.5558 | Model’s First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Non-durable good producer’s secondary materials input distribution parameter | `alppha_r_nondurable` | 0.00384 | Model’s First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Other-durable good producer’s secondary materials input distribution parameter | `alppha_r_otherdurable` | 9.95846E-5 | Model’s First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Energy-using good producer’s secondary materials input distribution parameter | `alppha_r_energydurable` | 1.07254E-5 | Model’s First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Capital good producer’s secondary materials input distribution parameter | `alppha_r_capital` | 8.01645E-6 | Model’s First-Order Conditions, RIETI data, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Capital good economic depreciation rate | `deltta_capital_fix` | 0.06683 | RIETI data |
| Capital good physical depreciation rate | `deltta_capital_physical` | 0.01092 | Mat_stocks data<sup>2,3</sup> |
| Energy-using good depreciation rate scaling parameter | `deltta_energydurable_fix` | 0.57744 | Depreciation rate equation and Mat_stocks data<sup>2,3</sup> |
| Other-durable good depreciation rate | `deltta_otherdurable_fix` | 0.08357 | [25] |
| Firms’ electricity excise tax | `t_el_f` | 0.01096 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, OECD and RIETI databases |
| Households’ electricity excise tax | `t_el_h` | 0 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, E-stat, OECD and RIETI databases |
| Use rate of energy-using goods owned by households | `u_lowuse` | 0.1625 | See Table S2 |
| Sensitivity parameter of the depreciation rate to the use rate of energy-using goods owned by households | `siggma_dep_lowuse` | 1.04669 | Model’s depreciation rate equation to reach u_lowuse and depreciation rate for energy-using goods of 0.08077 from [25] |
| Use rate of energy-using goods used by the PSS sector | `u_highuse` | 0.27 | Calibration using available data for car-sharing vehicles and washing machines:<br>Cars: 10.5 hours per day according to a survey of the Consumer Affairs Agency<sup>26</sup> <br>Washing machines: 3 hours per day on average according to https://land.home4u.jp/guide/landry-6-2599<br>Vehicles and washing machines represent 6.66% and 7.76% of the total of energy-using goods stock, respectively. The weighted average gives a use rate of approximately 0.27. |
| Sensitivity parameter of the depreciation rate to the use rate of energy-using goods used by the PSS sector | `siggma_dep_highuse` | 1.04669 | Assumed equal to siggma_dep_lowuse, yielding a depreciation rate of 0.147 |
| <br>Share of higher-income group in the total population | `omegga_lowcarbon` | 0.69046 | [27] |
| Share of medium-income group in the total population | `omegga_cautious` | 0.15693 | [27] |
| Semi-durable good EPR fee as a share of the final price | `fee_epr_otherdurable` | 0.00329 | Ministry of Economy, Trade and Industry (METI), [28] |
| Durable goods EPR fee as a share of the final price | `fee_epr_energydurable` | 0.04131 | [29], [30] |
| Capital goods import tariff | `t_imports_capital` | 0.00221 | International Trade Administration and TransCustoms |
| Non-durable goods import tariff | `t_imports_nondurable` | 0.04398 | International Trade Administration and TransCustoms |
| Other-durable goods import tariff | `t_imports_otherdurable` | 0.03202 | International Trade Administration and TransCustoms |
| Energy-using goods import tariff | `t_imports_energydurable` | 0 | International Trade Administration and TransCustoms |
| Collection and transportation cost (JPY per gram) | `c_m` | 0.01042 | Report on Waste Management in Japan (2021) of the Ministry of the Environment (Japan)<br> |
| Electricity efficiency | `A_el` | 0.95228 | WITCH model |
| Fuel efficiency | `A_nel` | 1.00950 | WITCH model |
| Households’ gross electricity price (JPY per MJ) | `p_el_h_2018` | 5.30796 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, E-stat, OECD and RIETI databases |
| Households’ fuel tax (JPY per MJ) | `t_nel_h` | 0.87209 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, E-stat, OECD and RIETI databases |
| Households’ gross fuel price (JPY per MJ) | `p_nel_h_2018` | 2.34865 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, E-stat, OECD and RIETI databases |
| Firms’ gross electricity price (JPY per MJ) | `p_el_f_2018` | 4.90882 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, E-stat, OECD and RIETI databases |
| Firms’ fuel tax (JPY per MJ) | `t_nel_f` | 0.52497 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, E-stat, OECD and RIETI databases |
| Firms’ gross fuel price (JPY per MJ) | `p_nel_f_2018` | 1.93214 | Model’s First-Order Conditions, Agency for Natural Resources and Energy, E-stat, OECD and RIETI databases |
| Material intensity of non-durable goods imports | `material_int_nondurable` | 0.20264 | Resource Panel, RIETI database, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Material intensity of other-durable goods imports | `material_int_otherdurable` | 0.20264 | Resource Panel, RIETI database, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Material intensity of energy-using goods imports | `material_int_energydurable` | 0.20264 | Resource Panel, RIETI database, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Material intensity of capital goods imports | `material_int_capital` | 0.20264 | Resource Panel, RIETI database, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Primary material gross price (JPY per gram) | `p_virgin` | 0.0474 | Model’s First-Order Conditions, Resource Panel, RIETI database, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Secondary material gross price (JPY per gram) | `p_secondary` | 0.0293 | Model’s First-Order Conditions, Resource Panel, RIETI database, Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan) |
| Material loss during the production process of energy-using goods | `gamma_energydurable` | 0.05333 | Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan), Resource Panel database and RIETI databases |
| Material loss during the production process of other-durable goods | `gamma_otherdurable` | 0.08989 | Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan), Resource Panel database and RIETI databases |
| Material loss during the production process of non-durable goods | `gamma_nondurable` | 0.20563 | Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan), Resource Panel database and RIETI databases |
| Material loss during the production process of capital goods | `gamma_capital` | 0.01678 | Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan), Resource Panel database and RIETI databases |
| Material loss during the production process of primary materials | `gamma_virgin` | 0.03851 | Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan), Resource Panel database and RIETI databases |
| Material loss during the production process of secondary materials | `gamma_recycled` | 0.04061 | Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan), Resource Panel database and RIETI databases |
| Share of recycled waste in total municipal waste | `omegga_mun_recycled` | 0.21264 | Ministry of the Environment (Japan), Resource Panel and RIETI databases |
| Share of recycled waste in total industrial waste | `omegga_ind_recycled` | 0.8456 | Ministry of the Environment (Japan), Resource Panel and RIETI databases |
| Industrial waste tax (JPY per gram) | `t_m` | 0.0009 | Ministry of the Environment (Japan), [31] |
| Municipal waste tax (JPY per gram) | `t_w` | 0.0966 | Ministry of the Environment (Japan) |
| Price of raw materials (JPY per gram) | `p_rawmaterials` | 0.0067 | Mat_stocks data<sup>2,3</sup>, Ministry of the Environment (Japan), Resource Panel, and RIETI database |

## Supplementary Table 2. Use rate of energy-using goods

| Good | Use rate (fraction of a day) | Share in total energy-using goods owned (source: National Survey of Family Income and Expenditures from e-stat.go.jp) | Source |
| --- | --- | --- | --- |
| Cars | 0.0208 | 6.66% | Assuming 9,656 km per year at an average driving speed of 60 km/h<sup>32,33</sup>, rounding to 30 min per day. |
| Washing machines | 0.0446 | 7.76% | An average of up to 4 washing-machine cycles per week, each lasting 1.5 hours<sup>34,35</sup> |
| Refrigerators | 1 | 7.06% | Refrigerators are powered continuously |
| AC | 0.071 | 14.37% | 600 hours per year from Household Energy Consumption/CO<sub>2</sub> survey of the Ministry of the Environment (Japan) |
| TV | 0.1875 | 11.57% | 4.5 h per day from Household Energy Consumption /CO<sub>2</sub> survey of the Ministry of the Environment (Japan) |
| Computers | 0.188 | 8.30% | 4.5 h per day<sup>36,37</sup> |
| Smartphones | 0.125 | 11.35% | 3 hours per day<sup>38</sup> |
| Cooking appliances | 0.0417 | 16.88% | 1 h per day spent on meal preparation<sup>39</sup> |
| Heating | 0.11 | 14.72% | Up to 950 hours per year from Household Energy Consumption/CO<sub>2</sub> survey of the Ministry of the Environment (Japan) |
| Water heater | 0.167 | 1.33% | 4 h per day<sup>40</sup><br> |
| Weighted average (target) | 0.1625 | 100% | - |

## References (Supplementary Information)

1. Corbier, D., Pettifor, H., Agnew, M., & Schlegel, N. (2026). Economic incentives and lifestyle drivers: how they shape consumers' engagement in repairing energy-using consumer goods and their environmental impacts in Japan. Global Environmental Change, 96, 103102

2. Wiedenhofer, D., Streeck, J., Wieland, H., Grammer, B., Baumgart, A., Plank, B., Helbig, C., Pauliuk, S., Haberl, H., & Krausmann, F. (2024). From extraction to end‐uses and waste management: Modeling economy‐wide material cycles and stock dynamics around the world. Journal of Industrial Ecology, 28(6), 1464–1480.

3. Streeck, J., Grammer, B., Wieland, H., & Wiedenhofer, D. (2024). socialecologyboku/MISO2: V1.0.0 [Computer software]. Zenodo. https://zenodo.org/records/12795906

4. Riahi, K., Vuuren, D.P., Kriegler, E., Edmonds, J., O’Neill, B.C., Fujimori, S., Bauer, N., Calvin, K., Dellink, R., Fricko, O., Lutz, W., Popp, A., Cuaresma, J.C., KC, S., Leimbach, M., Jiang, L., Kram, T., Rao, S., Emmerling, J., Ebi, K., Hasegawa, T., Havlik, P., Humpenader, F., Silva, L.A.D., Smith, S., Stehfest, E., Bosetti, V., Eom, J., Gernaat, D., Masui, T., Rogelj, J., Strefler, J., Drouet, L., Krey, V., Luderer, G., Harmsen, M., Takahashi, K., Baumstark, L., Doelman, J.C., Kainuma, M., Klimont, Z., Marangoni, G., Lotze-Campen, H., Obersteiner, M., Tabeau, A., Tavoni, M. (2017). The shared socioeconomic pathways and their energy, land use, and greenhouse gas emissions implications: An overview. Global Environmental Change 42, 153–168

5. Rogelj, J., Popp, A., Calvin, K.V., Luderer, G., Emmerling, J., Gernaat, D., Fujimori, S., Strefler, J., Hasegawa, T., Marangoni, G., Krey, V., Kriegler, E., Riahi, K., Vuuren, D.P., Doelman, J., Drouet, L., Edmonds, J., Fricko, O., Harmsen, M., Havlik, P., Humpenader, F., Stehfest, E., Tavoni, M. (2018). Scenarios towards limiting global mean temperature increase below 1.5 °C. Nature Climate Change 8(4), 325–332

6. Gidden, M.J., Riahi, K., Smith, S.J., Fujimori, S., Luderer, G., Kriegler, E., Vuuren, D.P., Berg, M., Feng, L., Klein, D., Calvin, K., Doelman, J.C., Frank, S., Fricko, O., Harmsen, M., Hasegawa, T., Havlik, P., Hilaire, J., Hoesly, R., Horing, J., Popp, A., Stehfest, E., Takahashi, K. (2019). Global emissions pathways under different socioeconomic scenarios for use in CMIP6: a dataset of harmonized emissions trajectories through the end of the century. Geoscientific Model Development 12(4), 1443–1475

7. Feenstra, R.C., Luck, P., Obstfeld, M., Russ, K.N. (2018). In search of the Armington elasticity. Review of Economics and Statistics 100(1), 135–150

8. Bajzik, J., Havranek, T., Irsova, Z., Schwarz, J. (2020). Estimating the Armington elasticity: The importance of study design and publication bias. Journal of International Economics 127, 103383

9. Ogaki, M., Reinhart, C.M. (1998). Measuring intertemporal substitution: The role of durable goods. Journal of Political Economy 106(5), 1078–1098.

10. Corbier, D., Gonand, F. (2024). A hybrid electricity-economy model to assess the aggregate impacts of low-carbon transition: An application to France. Ecological Economics 216, 108027

11. Henriet, F., Maggiar, N., Schubert, K. (2014). A stylized applied energy-economy model for France. The Energy Journal 35(4), 1–38

12. Dhawan, R., Jeske, K. (2008). Energy price shocks and the macroeconomy: the role of consumer durables. Journal of Money, Credit and Banking 40(7), 1357–1377

13. Capros, P., Van Regemorter, D., Paroussos, L., Karkatsoulis, P., Fragkiadakis, C., Tsani, S., Charalampidis, I., Revesz, T., Perry, M., Abrell, J. (2013). GEM-E3 model documentation. JRC Scientific and Policy Reports 26034

14. Okagawa, A., Kanemi, B., et al. (2008). Estimation of substitution elasticities for CGE models. Technical report

15. Muck, J., et al. (2017). Elasticity of Substitution Between Labour and Capital: Robust Evidence from Developed Economies

16. Emmerling, J., Drouet, L., Reis, L., Bevione, M., Berger, L., Bosetti, V., Carrara, S., De Cian, E., De Maere D’Aertrycke, G., Longden, T., et al. (2016). The WITCH 2016 model-documentation and implementation of the shared socioeconomic pathways

17. Burniaux, J.-M., Truong, T.P. (2002). GTAP-e: an energy-environmental version of the GTAP model. GTAP technical papers, 1

18. Wang, F., Jiang, Y., Zhang, W., Yang, F. (2019). Elasticity of factor substitution and driving factors of energy intensity in China’s industry. Energy & Environment 30(3), 385–407

19. Iiboshi, H., Matsumae, T., Namba, R., Nishiyama, S.-I. (2015). Estimating a DSGE model for Japan in a data-rich environment. Journal of the Japanese and International Economies 36, 25–55

20. Sugo, T., Ueda, K. (2008). Estimating a dynamic stochastic general equilibrium model for Japan. Journal of the Japanese and International Economies 22(4), 476–502

21. Hansen, L.P., Singleton, K.J. (1982). Generalized instrumental variables estimation of nonlinear rational expectations models. Econometrica: Journal of the Econometric Society, 1269–1286

22. Fauvel, Y., & Samson, L. (1991). Intertemporal substitution and durable goods: an empirical analysis. Canadian Journal of Economics, 192-205.

23. Melina, G., Cantelmo, A. (2017). Sectoral labour mobility and optimal monetary policy. Technical report, International Monetary Fund

24. Havranek, T., Rusnak, M., Sokolova, A. (2017). Habit formation in consumption: A meta-analysis. European Economic Review 95, 142–167

25. Nomura, K., Suga, Y. (2018). Measurement of depreciation rates using microdata from disposal survey of Japan. In: The 35th IARIW General Conference, Copenhagen, Denmark

26. Consumer Affairs Agency (2023). Overview of car-sharing trends. Accessible at: https://www.caa.go.jp/policies/policy/consumer_policy/caution/internet/assets/internet_committee_230330_08.pdf

27. Pettifor, H., Agnew, M., Wilson, C. (2023). A framework for measuring and modelling low-carbon lifestyles. Global Environmental Change 82, 102739

28. Hotta, Y., Hayashi, S., Bengtsson, M., Mori, H. (2009). Extended Producer Responsibility policy in East Asia. Consideration of International Resource Circulation.

29. Association for Electric Home Appliances: Recycle price list (2024). https://www.rkc.aeha.or.jp/files/recycle_price_list.pdf

30. Ministry of Economy, Trade and Industry, J.: Automobile Recycle. https://www.meti.go.jp/policy/monoinfoservice/mono/automobile/automobilerecycle/other/pdf/pamphlet/foreigner.pdf

31. yamamoto-mrc.co.jp (2021). What is industrial waste tax? A thorough explanation of the tax system. Available at https://www.yamamoto-mrc.co.jp/column/industrial/

32. Heatmap.news (2023). How Tokyo became an anti-car paradise. https://heatmap.news/economy/tokyo-anti-carpedestrian-paradise: :text=Car

33. Integrityexports.com: Japan’s Used Cars Are Newer With Lower Mileage (2021). https://integrityexports.com/japan-car-auction-academy/why-cars-from-japan/japans-used-cars-are-newer-with-lower-mileage/

34. tg-uchi.jp: More than half of people wash their clothes every day! How often does everyone wash their clothes? (2023). https://tg-uchi.jp/topics/5946

35. prtimes.jp: Survey on washing machines: 40% of owners use their washing machines ”almost every day.” A high percentage of young people do their laundry between 7pm and 10pm. (2021). https://prtimes.jp/main/html/rd/p/000001061.000007815.html

36. datareportal.com: The unique nuances of digital in Japan (2021). https://datareportal.com/reports/the-unique-nuances-of-digital-in-japan

37. Tasaki, T., Motoshita, M., Uchida, H., & Suzuki, Y. (2013). Assessing the replacement of electrical home appliances for the environment: an aid to consumer decision making. Journal of Industrial Ecology, 17(2), 290-298.

38. travelvoice.jp: The average time spending for a smart phone in Japan is 3 hours and 7 minutes a user a day (2018). https://www.travelvoice.jp/english/the-average-time-spending-for-a-smart-phone-in-japan-is-3-hours-and-7-minutes-a-user-a-day

39. Ministry of Internal Affairs and Communications (2021). 2021 Survey on Time Use and Leisure Activities

40. Shiraki, H., Nakamura, S., Ashina, S., Honjo, K. (2016). Estimating the hourly electricity profile of Japanese households–coupling of engineering and statistical methods. Energy 114, 478–491
