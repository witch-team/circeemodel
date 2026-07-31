// CIRCEE MODEL //

@#define REGION = "JPN"
@#define SECTORS = ["nondurable","otherdurable","energydurable","capital"]
@#define MATERIALS = ["virgin","recycled"]
@#define LIFESTYLES = ["lowcarbon","cautious","constrained"]

var  
%------------------------------------------------------------------------------------------------------------
% Consumption good and services firms decision variables
%------------------------------------------------------------------------------------------------------------

    @#for s in SECTORS
        K_f_@{s}                    ${K_f_@{s}}$                (long_name='@{s} good firms capital stock')
        KL_@{s}                     ${KL_@{s}}$                 (long_name='@{s} good firms capital-labor bundle')
        L_@{s}                      ${L_@{s}}$                  (long_name='@{s} good firms labor input')
        M_@{s}                      ${M_@{s}}$                  (long_name='@{s} good firms aggregate materials demand')
        M_virgin_@{s}               ${M_virgin_@{s}}$           (long_name='@{s} good firms virgin materials')
        M_recycled_@{s}             ${M_recycled_@{s}}$         (long_name='@{s} good firms secondary materials')
        Z_@{s}                      ${Z_@{s}}$                  (long_name='@{s} good firms capital-labor-energy bundle')
        Y_@{s}                      ${Y_@{s}}$                  (long_name='@{s} good firms ouput')
        E_@{s}                      ${E_@{s}}$                  (long_name='@{s} good firms aggregate energy input')
        El_@{s}                     ${El_@{s}}$                 (long_name='@{s} good firms electricity input')
        Nel_@{s}                    ${Nel_@{s}}$                (long_name='@{s} good firms fuel input')
        p_e_@{s}                    ${p_e_@{s}}$                (long_name='@{s} good firms aggregate/zero-profit energy price')
        p_m_@{s}                    ${p_m_@{s}}$                (long_name='@{s} good firms aggregate/zero-profit material price ')
        p_m_c_@{s}                  ${p_m_c_@{s}}$              (long_name='@{s} good firms composite material price ')
        IMP_@{s}                    ${IMP_@{s}}$                (long_name='@{s} good imports') 
        EXPORT_@{s}                 ${EXPORT_@{s}}$             (long_name='@{s} good domestically-produced exports') 
        Demand_dom_@{s}             ${Demand_dom_@{s}}$         (long_name='@{s} good demand of domestically-produced goods') 
        p_row_@{s}                  ${p_row_@{s}}$              (long_name='RoW consumption @{s} good price deflator') 
        p_def_@{s}                  ${p_def_@{s}}$              (long_name='aggregate @{s} good price')
        p_@{s}                      ${p_@{s}}$                  (long_name='@{s} good firms wholesale price')
    @#endfor

%------------------------------------------------------------------------------------------------------------
% Material producing sectors decision variables
%------------------------------------------------------------------------------------------------------------

    @#for m in MATERIALS
        Y_@{m}                      ${Y_@{m}}$                  (long_name='@{m} material firms output')
        Z_@{m}                      ${Z_@{m}}$                  (long_name='@{m} material firms capital-energy bundle')
        KL_@{m}                     ${KL_@{m}}$                 (long_name='@{m} material firms capital-labor bundle')
        K_@{m}                      ${K_@{m}}$                  (long_name='@{m} material firms capital input')
        L_@{m}                      ${L_@{m}}$                  (long_name='@{m} material firms labor input')
        E_@{m}                      ${E_@{m}}$                  (long_name='@{m} material firms aggregate energy input')
        El_@{m}                     ${El_@{m}}$                 (long_name='@{m} material firms electricity input')
        Nel_@{m}                    ${Nel_@{m}}$                (long_name='@{m} material firms fuel input')
        p_e_@{m}                    ${p_e_@{m}}$                (long_name='@{m} material firms aggregate/zero-profit energy price')    
        IMP_@{m}                    ${IMP_@{m}}$                (long_name='@{m} material imports') 
        EXPORT_@{m}                 ${EXPORT_@{m}}$             (long_name='@{m} material exports') 
        Demand_dom_@{m}             ${Demand_dom_@{m}}$         (long_name='Domestic demand of domestically-produced @{m} material') 
    @#endfor

        RW                          ${RW}$                      (long_name='Waste processed by the recycling facilities')
        RM                          ${RM}$                      (long_name='Virgin material firms raw materials input demand')
        marginalcost_recycled       ${marginalcost_recycled}$   (long_name='Marginal cost of the recycling firm')

%------------------------------------------------------------------------------------------------------------
% Sharing firms decision variables
%------------------------------------------------------------------------------------------------------------        

        Y_sharing                   ${Y_sharing}$               (long_name='Sharing firms output')
        L_sharing                   ${L_sharing}$               (long_name='Sharing firms labor input')
        ES_sharing_f                ${ES_sharing_f}$            (long_name='Sharing firms energy-using durables-energy bundle ')
        E_sharing                   ${E_sharing}$               (long_name='Sharing firms aggregate energy input')
        El_sharing                  ${El_sharing}$              (long_name='Sharing firms electricity input')
        Nel_sharing                 ${Nel_sharing}$             (long_name='Sharing firms fuel input')
        p_e_sharing                 ${p_e_sharing}$             (long_name='Sharing firms aggregate/zero-profit energy price')
        p_sharing                   ${p_sharing}$               (long_name='sharing services price')
        ED_highuse                  ${ED_highuse}$              (long_name='energy-using durable goods input for the sharing sector')
        u_highuse                   ${u_highuse}$               (long_name='use rate of energy-using goods that are shared through B2C')  
        AC_ID_new_highuse           ${AC_ID_new_highuse}$       (long_name='high-use energy-using goods investment adjustment costs')  
        deltta_energydurable_highuse ${deltta_energydurable_highuse}$  (long_name='high-use energy-using goods depreciation rate')
        r_ed                        ${r_ed}$                    (long_name='rental rate of high-use energy-using goods')

%------------------------------------------------------------------------------------------------------------
% Repairing firms decision variables
%------------------------------------------------------------------------------------------------------------   

        Y_repair                    ${Y_repair}$                (long_name='Repair firms output')
        L_repair                    ${L_repair}$                (long_name='Repair firms labor input')
        K_repair                    ${K_repair}$                (long_name='Repair firms capital input')     
        p_repair                    ${p_repair}$                (long_name='repair services price')

%------------------------------------------------------------------------------------------------------------
% Input prices common to all markets due to perfect competition in input markets 
%------------------------------------------------------------------------------------------------------------ 

        r_k                         ${r_k}$                     (long_name='rental price of capital')
        w                           ${w}$                       (long_name='nominal wage')

%------------------------------------------------------------------------------------------------------------
% Households decision variables 
%------------------------------------------------------------------------------------------------------------ 

        ED_lowuse                   ${ED_lowuse}$               (long_name='energy-using durable good stock')
        deltta_energydurable_lowuse ${deltta_energydurable_lowuse}$ (long_name='low use use energy-using durable good depreciation rate')        
        Inv_ed_new_highuse          ${Inv_ed_new_highuse}$      (long_name='investments in energy-using durable goods used by the sharing sector for B2C') 
        Inv_ed_new_tild             ${Inv_ed_new_tild}$         (long_name='new investments for undepreciated energy-using durable goods')
        Inv_ed_new                  ${Inv_ed_new}$              (long_name='new investments for the replacement of depreciated energy-using durable goods')
        Inv_ed_repair               ${Inv_ed_repair}$           (long_name='repaired energy-using durable goods investments')
        g_inv_ed                    ${g_inv_ed}$                (long_name='CES aggregator of new and repaired investments for depreciated energy-using durable goods')
        p_g_inv_ed                  ${p_g_inv_ed}$              (long_name='price of the CES aggregator of new and repaired investments for depreciated energy-using durable goods') 
        alppha_ed_new               ${alppha_ed_new}$           (long_name='share of new energy-using durable good investments for depreciated energy-using durable goods')
        alppha_ed_repair            ${alppha_ed_repair}$        (long_name='share of new energy-using durable good investments for depreciated energy-using durable goods')
        X                           ${X}$                       (long_name='non-durable goods consumption')
        E_h                         ${E_h}$                     (long_name='households aggregate energy consumption')
        ES                          ${ES}$                      (long_name='aggregate energy services')
        ES_home                     ${ES_home}$                 (long_name='home-produced energy services by households for their own use')
        ES_sharing                  ${ES_sharing}$              (long_name='energy services bought from the sharing market')
        C                           ${C}$                       (long_name='aggregate consumption')
        NES                         ${NES}$                     (long_name='non-energy services goods')
        El_h                        ${El_h}$                    (long_name='households electricity consumption')
        Nel_h                       ${Nel_h}$                   (long_name='households fuel consumption') 
        K                           ${K}$                       (long_name='capital stock of the economy')
        Inv_k                       ${Inv_k}$                   (long_name='new capital investments for the replacement of depreciated capital')
        OD                          ${OD}$                      (long_name='other durable good stock')
        Inv_od                      ${Inv_od}$                  (long_name='other durable good investments')
        p_nd_ati                    ${p_nd_ati}$                (long_name='all tax included non-durable good price')
        h                           ${h}$                       (long_name='average hours worked')
        A_nel                       ${A_nel}$                   (long_name='aggregate fuel efficiency')
        diff_A_nel                  ${diff_A_nel}$              (long_name='aggregate fuel efficiency difference')
        omegga_lowcarbon_saver      ${omegga_lowcarbon_saver}$  (long_name='share of lowcarbon lifestyle savers in total savers')
        q_k_lowcarbon               ${q_k_lowcarbon}$           (long_name='low-carbon lifestyle households time-varying real price of new capital goods')
        omegga_constrained          ${omegga_constrained}$      (long_name='share of low-income groups in total population')
        Expenditures_LIFE

    @#for h in LIFESTYLES  
        ED_lowuse_@{h}              ${ED_lowuse_@{h}}$          (long_name='@{h} households owned energy-using durable good stock')
        deltta_energydurable_lowuse_@{h} ${deltta_energydurable_lowuse_@{h}}$   (long_name='@{h} owned energy-using durable goods depreciation rate')
        u_lowuse_@{h}               ${u_lowuse_@{h}}$           (long_name='@{h} lifestyle households utilization rate of the durable good stock')   
        omegga_repair_@{h}          ${omegga_repair_@{h}}$      (long_name='@{h} lifestyle households share of repair goods in total goods') 
        uc_@{h}                     ${uc_@{h}}$                 (long_name='@{h} households owned energy-using durable good user cost')
        AC_ID_g_@{h}                ${AC_ID_g_@{h}}$            (long_name='@{h} CES aggregator of depreciated owned energy-using durable goods investments adjustment costs')
        AC_ID_new_@{h}              ${AC_ID_new_@{h}}$          (long_name='@{h} new owned energy-using durable goods investments adjustment costs')   
        Inv_ed_new_tild_@{h}        ${Inv_ed_new_tild_@{h}}$    (long_name='@{h} new owned energy-using durable goods investments for undepreciated owned energy-using durable goods')
        Inv_ed_new_@{h}             ${Inv_ed_new_@{h}}$         (long_name='@{h} new owned energy-using durable goods investments for the replacement of depreciated owned energy-using durable goods')
        Inv_ed_repair_@{h}          ${Inv_ed_repair_@{h}}$      (long_name='@{h} repaired owned energy-using durable goods investments')
        g_inv_ed_@{h}               ${g_inv_ed_@{h}}$           (long_name='@{h} CES aggregator of new and repaired owned energy-using durable goods investments for depreciated owned energy-using durable goods')
        p_g_inv_ed_@{h}             ${p_g_inv_ed_@{h}}$         (long_name='@{h} CES aggregator of new and repaired owned energy-using durable goods investments for depreciated owned energy-using durable goods')
        q_ed_newtild_@{h}           ${q_ed_newtild_@{h}}$       (long_name='@{h} lifestyle households time-varying real price of new owned energy-using durable goods')         
        q_ed_depreciated_@{h}       ${q_ed_depreciated_@{h}}$   (long_name='@{h} lifestyle households time-varying real price of owned energy-using durable goods for depreciated owned energy-using durable')        
        X_@{h}                      ${X_@{h}}$                  (long_name='@{h} households non-durable goods consumption')
        E_@{h}                      ${E_@{h}}$                  (long_name='@{h} households aggregate energy consumption')
        ES_@{h}                     ${ES_@{h}}$                 (long_name='@{h} households aggregate energy services')
        ES_home_@{h}                ${ES_home_@{h}}$            (long_name='@{h} households home-produced energy services by households for their own use')
        ES_sharing_@{h}             ${ES_sharing_@{h}}$         (long_name='@{h} households energy services bought from the sharing market')
        C_@{h}                      ${C_@{h}}$                  (long_name='@{h} households aggregate consumption')
        NES_@{h}                    ${NES_@{h}}$                (long_name='@{h} households non-energy services consumption')        
        El_@{h}                     ${El_@{h}}$                 (long_name='@{h} households electricity consumption')
        Nel_@{h}                    ${Nel_@{h}}$                (long_name='@{h} households fuel consumption')
        repair_ed_@{h}              ${repair_ed_@{h}}$          (long_name='@{h} households owned energy-using durable goods refurbishment and repair per unit of owned energy-using durable good')
        p_home_@{h}                 ${p_home_@{h}}$             (long_name='@{h} households home-produced energy services price')
        OD_@{h}                     ${OD_@{h}}$                 (long_name='@{h} households other durable good stock')
        Inv_od_@{h}                 ${Inv_od_@{h}}$             (long_name='@{h} households other durable good investments')
        disc_factor_@{h}            ${disc_factor_@{h}}$        (long_name='@{h} households discount factor')
        p_e_h_@{h}                  ${p_e_h_@{h}}$              (long_name='@{h} households aggregate/zero-profit energy price')
        A_nel_@{h}                  ${A_nel_@{h}}$              (long_name='@{h} households fuel efficiency')
        Expenditures_LIFE_@{h}      ${Expenditures_LIFE_@{h}}$  (long_name='@{h} households otherdurable and durable goods total expenditures')
        share_nondurable_@{h}        ${share_nondurable_@{h}}$          (long_name='@{h} household nondurable share of total nondurable demand including government')
        share_otherdurable_@{h}      ${share_otherdurable_@{h}}$        (long_name='@{h} household share of otherdurables')
        share_energydurable_new_@{h} ${share_energydurable_new_@{h}}$   (long_name='@{h} household share of newly produced energy using goods expenses')
        share_sharing_@{h}           ${share_sharing_@{h}}$             (long_name='@{h} household share of B2C energy services')
        share_repair_@{h}            ${share_repair_@{h}}$              (long_name='@{h} household share of repair services')
        CF_prod_repair_@{h}          ${CF_prod_repair_@{h}}$            (long_name='@{h} household upstream and production phase carbon footprint of repair services')
        CF_prod_nondurable_@{h}      ${CF_prod_nondurable_@{h}}$        (long_name='@{h} household upstream and production phase carbon footprint nondurables')
        CF_prod_otherdurable_@{h}    ${CF_prod_otherdurable_@{h}}$      (long_name='@{h} household upstream and production phase carbon footprint otherdurables')
        CF_prod_energydurable_@{h}   ${CF_prod_energydurable_@{h}}$     (long_name='@{h} household upstream and production phase carbon footprint owned energy using goods')
        CF_prod_sharing_@{h}         ${CF_prod_sharing_@{h}}$           (long_name='@{h} household upstream and production phase carbon footprint B2C services')
        CF_eol_nondurable_@{h}       ${CF_eol_nondurable_@{h}}$         (long_name='@{h} household end of life carbon footprint nondurables')
        CF_eol_otherdurable_@{h}     ${CF_eol_otherdurable_@{h}}$       (long_name='@{h} household end of life carbon footprint otherdurables')
        CF_eol_energydurable_@{h}    ${CF_eol_energydurable_@{h}}$      (long_name='@{h} household end of life carbon footprint owned energy using goods')
        CF_eol_sharing_@{h}          ${CF_eol_sharing_@{h}}$            (long_name='@{h} household end of life carbon footprint B2C energy using goods')
        CF_IW_nondurable_@{h}        ${CF_IW_nondurable_@{h}}$          (long_name='@{h} household industrial waste incineration carbon footprint nondurables')
        CF_IW_otherdurable_@{h}      ${CF_IW_otherdurable_@{h}}$        (long_name='@{h} household industrial waste incineration carbon footprint otherdurables')
        CF_IW_energydurable_@{h}     ${CF_IW_energydurable_@{h}}$       (long_name='@{h} household industrial waste incineration carbon footprint owned energy using goods')
        CF_IW_sharing_@{h}           ${CF_IW_sharing_@{h}}$             (long_name='@{h} household industrial waste incineration carbon footprint B2C energy using goods')
        CF_IW_repair_@{h}            ${CF_IW_repair_@{h}}$              (long_name='@{h} household industrial waste incineration carbon footprint of repair services')
        CF_@{h}                      ${CF_@{h}}$                        (long_name='@{h} household total lifecycle carbon footprint')
        WF_nondurable_@{h}           ${WF_nondurable_@{h}}$             (long_name='@{h} household waste embodied in their consumption of nondurables')
        WF_otherdurable_@{h}         ${WF_otherdurable_@{h}}$           (long_name='@{h} household waste embodied in their consumption of otherdurabless')
        WF_energydurable_@{h}        ${WF_energydurable_@{h}}$          (long_name='@{h} household waste embodied in their consumption of lowuse energy using goods')
        WF_repair_@{h}               ${WF_repair_@{h}}$                 (long_name='@{h} household waste embodied in their consumption of repair services')
        WF_sharing_@{h}              ${WF_sharing_@{h}}$                (long_name='@{h} household waste embodied in their consumption of sharing services')
        WF_@{h}                      ${WF_@{h}}$                        (long_name='@{h} household total waste footprint of their consumption basket')
        MF_@{h}                      ${MF_@{h}}$                        (long_name='@{h} household consumption-side material footprint (net of process losses)')
    @#endfor

    @#for h in ["lowcarbon","cautious"]  
        K_@{h}                      ${K_@{h}}$                 (long_name='@{h} lifestyle households capital stock')
        AC_IK_@{h}                  ${AC_IK_@{h}}$             (long_name='@{h} CES aggregator of capital investments adjustment costs')
        Inv_k_@{h}                  ${Inv_k_@{h}}$             (long_name='@{h} new capital investments')
    @#endfor      
        q_ed_newtild_highuse        ${q_ed_newtild_highuse}$   (long_name='low-carbon lifestyle households time-varying real price of new shared energy-using durable goods')  

%------------------------------------------------------------------------------------------------------------
% Government's decision variables
%------------------------------------------------------------------------------------------------------------ 

        Carbon_budget               ${Carbon_budget}$                   (long_name='primary surplus')  
        Revenues                    ${Revenues}$                        (long_name='fiscal revenues of the government')
        Expenses                    ${Expenses}$                        (long_name='public expenses of the government')
        X_G                         ${X_G}$                             (long_name='public non-durable goods consumption') 
        OD_G                        ${OD_G}$                            (long_name='public other durable goods stock') 
        ED_G                        ${ED_G}$                            (long_name='public energy-using durable goods stock') 
        Inv_ed_G                    ${Inv_ed_G}$                        (long_name='public energy-using durable goods investments') 
        Inv_od_G                    ${Inv_od_G}$                        (long_name='public other durable goods investments')  
        PS                          ${PS}$                              (long_name='Primary surplus')      
        EPR_budget                  ${EPR_budget}$                      (long_name='EPR revenues redistribution')    
        EPR_budget_bis              ${EPR_budget_bis}$                  (long_name='EPR revenues') 
        sub_recycled                ${sub_recycled}$                    (long_name='subsidies to the recycling sector')    

%------------------------------------------------------------------------------------------------------------
% Trade module variables
%------------------------------------------------------------------------------------------------------------ 

        IMP_R                       ${IMP_R}$                           (long_name='Resources imports')
        Domestic_Extraction         ${Domestic_Extraction}$             (long_name='Domestic Extraction')
        TB                          ${TB}$                              (long_name='Trade balance')                           

%------------------------------------------------------------------------------------------------------------
% Physical constraints module variables
%------------------------------------------------------------------------------------------------------------ 

    @#for s in ["capital","otherdurable","energydurable"]           
        M_stock_@{s}                ${M_stock_@{s}}$                    (long_name='@{s} good material stock')
        Gross_additions_stock_@{s}  ${Gross_additions_stock_@{s}}$      (long_name='@{s} good gross additions to the stocks')
        Net_additions_stock_@{s}    ${Net_additions_stock_@{s}}$        (long_name='@{s} good Net additions to the stocks')
    @#endfor

        El                          ${El}$                              (long_name='Electricity flow in the economy')
        Nel                         ${Nel}$                             (long_name='Fuels flow in the economy')
        Gross_additions_stock       ${Gross_additions_stock}$           (long_name='total gross additions to the stocks')
        Material_balance            ${Material_balance}$                (long_name='Material balance on the production side') 
        Material_balance_EWMFA      ${Material_balance_EWMFA}$          (long_name='Material balance from EWMFA perspective') 
        Material_balance_stocks     ${Material_balance_stocks}$         (long_name='Material balance on the stock side') 
        M_stock                     ${M_stock}$                         (long_name='Total material stock of the economy')
        NR_stock_mu                 ${NR_stock_mu}$                     (long_name='Municipalities non-renewable waste stock')
        NR_stock_indu               ${NR_stock_indu}$                   (long_name='Industries non-renewable waste stock')
        IW                          ${IW}$                              (long_name='Industrial waste total economy')
        IW_processedmat             ${IW_processedmat}$                 (long_name='Industrial waste from processed materials')
        IW_finalgoods               ${IW_finalgoods}$                   (long_name='Industrial waste from goods production')
        IW_l                        ${IW_l}$                            (long_name='Landfilled industrial waste')
        IW_r                        ${IW_r}$                            (long_name='Recyclable industrial waste')
        MW                          ${MW}$                              (long_name='Municipal waste')
        MW_l                        ${MW_l}$                            (long_name='Landfilled municipal waste')
        MW_r                        ${MW_r}$                            (long_name='Recyclable municipal waste')
        MW_nondurables              ${MW_nondurables}$                  (long_name='Municipal waste of nondurable goods') 
        MW_otherdurables            ${MW_otherdurables}$                (long_name='Municipal waste of other durable goods') 
        MW_energydurables           ${MW_energydurables}$               (long_name='Municipal waste of energy-using durable goods') 
        Finalsink_total             ${Finalsink_total}$                 (long_name='Waste going ot final sink') 
        IMP_materials               ${IMP_materials}$                   (long_name='Imports of processed materials') 
        EXP_materials               ${EXP_materials}$                   (long_name='Exports of materials') 
        IMP_raw                     ${IMP_raw}$                         (long_name='Imports of raw materials') 
        DMI                         ${DMI}$                             (long_name='Domestic material input') 
        DMC                         ${DMC}$                             (long_name='Domestic material consumption') 
        CO2_economy                 ${CO2_economy}$                     (long_name='CO2 emissions of the economy besides the incineration sector')
        CO2                         ${CO2}$                             (long_name='CO2 emissions total') 
        CO2_incineration            ${CO2_incineration}$                (long_name='CO2 emissions incineration') 
        E_virgin_tot                        ${E_virgin_tot}$            (long_name='Total virgin material sector energy') 
        E_recycled_tot                      ${E_recycled_tot}$          (long_name='Total recycled material sector energy') 
        M_virgin_tot                        ${M_virgin_tot}$            (long_name='Total virgin material inputs across all final goods sectors') 
        M_recycled_tot                      ${M_recycled_tot}$          (long_name='Total recycled material inputs across all final goods sectors') 
        Inv_ed_total                        ${Inv_ed_total}$            (long_name='Total energy-using good investment across household owned and B2C channels') 
        share_energydurable_lowuse_prod     ${share_energydurable_lowuse_prod}$  (long_name='Share of energy-using good production going to household owned lowuse channel') 
        share_energydurable_highuse_prod    ${share_energydurable_highuse_prod}$ (long_name='Share of energy-using good production going to B2C highuse channel') 
        E_upstream_nondurable               ${E_upstream_nondurable}$            (long_name='Upstream material energy attributed to nondurable goods sector') 
        E_upstream_otherdurable             ${E_upstream_otherdurable}$          (long_name='Upstream material energy attributed to otherdurable good sector') 
        E_upstream_energydurable_lowuse     ${E_upstream_energydurable_lowuse}$  (long_name='Upstream material energy attributed to  energy-using good lowuse channel') 
        E_upstream_energydurable_highuse    ${E_upstream_energydurable_highuse}$ (long_name='Upstream material energy attributed to  energy-using good highuse B2C channel') 
        E_upstream_energydurable            ${E_upstream_energydurable}$         (long_name='Upstream material energy attributed to  total energy-using good') 
        E_upstream_capital                  ${E_upstream_capital}$               (long_name='Upstream material energy attributed to capital sector') 
        E_prod_nondurable                   ${E_prod_nondurable}$                (long_name='Upstream and production phase energy of nondurable goods sector') 
        E_prod_otherdurable                 ${E_prod_otherdurable}$              (long_name='Upstream and production phase energy of otherdurable goods sector') 
        E_prod_energydurable_lowuse         ${E_prod_energydurable_lowuse}$      (long_name='Upstream and production phase energy of energy-using good lowuse channel') 
        E_prod_energydurable_highuse        ${E_prod_energydurable_highuse}$     (long_name='Upstream and production phase energy of energy-using good highuse B2C channel') 
        E_prod_energydurable                ${E_prod_energydurable}$             (long_name='Upstream and production phase energy of total energy-using good') 
        E_prod_sharing                      ${E_prod_sharing}$                   (long_name='Upstream and production phase energy of B2C sharing services including highuse durable goods manufacturing') 
        E_direct_capital                    ${E_direct_capital}$                 (long_name='Direct production phase energy of capital sector') 
        E_prod_capital                      ${E_prod_capital}$                   (long_name='Total production phase energy of capital sector') 
        E_prod_total                        ${E_prod_total}$                     (long_name='Total production phase energy across all attributed channels') 
        K_in_capital_chain                  ${K_in_capital_chain}$               (long_name='Capital used in the capital production chain') 
        CO2_prod_nondurable                 ${CO2_prod_nondurable}$              (long_name='Production phase CO2 attributed to nondurable goods sector') 
        CO2_prod_otherdurable               ${CO2_prod_otherdurable}$            (long_name='Production phase CO2 attributed to otherdurable goods sector') 
        CO2_prod_energydurable              ${CO2_prod_energydurable}$           (long_name='Production phase CO2 attributed to household owned energy-using good lowuse goods') 
        CO2_prod_sharing                    ${CO2_prod_sharing}$                 (long_name='Production phase CO2 attributed to B2C sharing services including highuse durable goods') 
        CO2_prod_capital                    ${CO2_prod_capital}$                 (long_name='Production phase CO2 attributed to capital goods') 
        CO2_prod_capital_nondurable         ${CO2_prod_capital_nondurable}$      (long_name='Production phase CO2 from capital sector attributed to nondurable goods') 
        CO2_prod_capital_otherdurable       ${CO2_prod_capital_otherdurable}$    (long_name='Production CO2 from capital sector attributed to otherdurable goods') 
        CO2_prod_capital_energydurable      ${CO2_prod_capital_energydurable}$   (long_name='Production CO2 from capital sector attributed to household owned energy-using good lowuse goods') 
        CO2_prod_capital_repair             ${CO2_prod_capital_repair}$          (long_name='Production phase CO2 from capital sector attributed to repair services') 
        CO2_prod_capital_sharing            ${CO2_prod_capital_sharing}$         (long_name='Production CO2 from capital sector attributed to B2C sharing services including highuse durable goods') 
        CO2_eol_nondurable                  ${CO2_eol_nondurable}$               (long_name='End of life incineration CO2 from nondurable goods municipal waste') 
        CO2_eol_otherdurable                ${CO2_eol_otherdurable}$             (long_name='End of life incineration CO2 from otherdurable goods municipal waste') 
        CO2_eol_energydurable_lowuse        ${CO2_eol_energydurable_lowuse}$     (long_name='End of life incineration CO2 from owned energy-using good lowuse municipal waste') 
        CO2_eol_energydurable_highuse       ${CO2_eol_energydurable_highuse}$    (long_name='End of life incineration CO2 from B2C energy-using good highuse municipal waste') 
        CO2_IW_nondurable                   ${CO2_IW_nondurable}$                (long_name='Industrial waste incineration CO2 attributable to nondurable goods production') 
        CO2_IW_otherdurable                 ${CO2_IW_otherdurable}$              (long_name='Industrial waste incineration CO2 attributable to otherdurable goods production') 
        CO2_IW_capital                      ${CO2_IW_capital}$                   (long_name='Industrial waste incineration CO2 from capital sector production') 
        CO2_IW_repair                       ${CO2_IW_repair}$                    (long_name='Industrial waste incineration CO2 attributable to lowuse energy using goods production and repaired lowuse energy using goods') 
        CO2_IW_energydurable                ${CO2_IW_energydurable}$             (long_name='Industrial waste incineration CO2 attributable to energy-using good highuse B2C production') 
        CO2_IW_sharing                      ${CO2_IW_sharing}$                   (long_name='Industrial waste incineration CO2 attributable to repair sector') 

%------------------------------------------------------------------------------------------------------------
% Energy prices
%------------------------------------------------------------------------------------------------------------ 

        p_nel_h                     ${p_nel_h}$                         (long_name='households fuel price expressed in domestic currency')
        p_nel_f                     ${p_nel_f}$                         (long_name='firms fuel price expressed in domestic currency')
        p_el_f                      ${p_el_f}$                          (long_name='firms electricity price')
        p_el_h                      ${p_el_h}$                          (long_name='households electricity price')
%------------------------------------------------------------------------------------------------------------
% GDP and dividends
%------------------------------------------------------------------------------------------------------------ 

        GDP                         ${GDP}$                             (long_name='Gross Domestic Products') 
        Y_power                     ${Y_power}$                         (long_name='Power sector VA') 
        Inv_k_energy                ${Inv_k_energy}$                    (long_name='Power generation capacities investments')
        DIV_total                   ${DIV_total}$                       (long_name='Dividends')
        DIV_capital                 ${DIV_capital}$                     (long_name='Capital firm dividends')
        DIV_nondurable              ${DIV_nondurable}$                  (long_name='Nondurable firm dividends')
        DIV_otherdurable            ${DIV_otherdurable}$                (long_name='Other durable firm dividends')
        DIV_energydurable           ${DIV_energydurable}$               (long_name='Energy durable firm dividends')
        DIV_virgin                  ${DIV_virgin}$                      (long_name='Virgin material firm dividends')
        DIV_recycled                ${DIV_recycled}$                    (long_name='Secondary material firm dividends')
        DIV_sharing                 ${DIV_sharing}$                     (long_name='Sharing services firm dividends')
        DIV_repair                  ${DIV_repair}$                      (long_name='Repair services firm dividends')
        DIV_imports                 ${DIV_imports}$                     (long_name='Dividends of the import sector')    
        IMP_goods_mateq             ${IMP_goods_mateq}$                 (long_name='Import of goods in material equivalent')    
        EXPORT_goods_mateq          ${EXPORT_goods_mateq}$              (long_name='Export of goods in material equivalent')     
;

predetermined_variables  

        K_lowcarbon
        NR_stock_mu
        NR_stock_indu
        OD_G
        ED_G

    @#for s in ["capital","otherdurable","energydurable"]
        M_stock_@{s}
    @#endfor

    @#for h in LIFESTYLES
        ED_lowuse_@{h}
        OD_@{h}
    @#endfor
        ED_highuse
;

varexo

%------------------------------------------------------------------------------------------------------------
% Resources Efficiency exogeneous
%------------------------------------------------------------------------------------------------------------ 

    A_nel_WITCH                 ${A_el_WITCH }$                    (long_name='aggregate electricity efficiency') 
    A_el_WITCH                  ${A_el_WITCH}$                     (long_name='aggregate fuel efficiency') 

    @#for s in SECTORS    
        A_m_@{s}                    ${A_m_@{s}}$                   (long_name='@{s} good firm material efficiency')
    @#endfor    

%------------------------------------------------------------------------------------------------------------
% Resources Prices exogeneous
%------------------------------------------------------------------------------------------------------------ 

    @#for m in MATERIALS
        p_@{m}                      ${p_@{m}}$                     (long_name='@{m} material price expressed in domestic currency') 
    @#endfor

    p_rawmaterials                  ${p_rawmaterials}$             (long_name='raw material price expressed in domestic currency')
    g_nel_witch                     ${g_nel_witch}$                (long_name='fuel price growth rate compared to baseline year from WITCH')
    g_el_witch                      ${g_el_witch}$                 (long_name='electricity price growth rate comapred to baseline year from WITCH')

%------------------------------------------------------------------------------------------------------------
% Emission factors exogeneous
%------------------------------------------------------------------------------------------------------------

    emissions_el_WITCH              ${emissions_el_WITCH}$         (long_name='Emission factor for electricity') 
    emissions_nel_WITCH             ${emissions_nel_WITCH}$        (long_name='Emission factor for fuels') 

%------------------------------------------------------------------------------------------------------------
% Fiscal policies exogeneous
%------------------------------------------------------------------------------------------------------------

    t_nel_h                     ${t_nel_h}$                         (long_name='households fuel tax')
    t_nel_f                     ${t_nel_f}$                         (long_name='firms fuel tax')
    redistribution              ${redistribution}$                  (long_name='parameter driving the activitation of the carbon tax redistribution mechanism')
    redistribution_epr          ${redistribution_epr}$              (long_name='parameter driving the activitation of the epr redistribution mechanism')
    t_m                         ${t_m}$                             (long_name='industrial waste tax')
    repair_ed_bonus             ${repair_ed_bonus}$                 (long_name='energy-using durable goods repair bonus percentage share of the repair price')  
    t_c_reduced                 ${t_c_reduced}$                     (long_name='reduced consumption tax')
    t_w                         ${t_w}$                             (long_name='tax on municipal waste')     
    c_m                         ${c_m}$                             (long_name='cost of collection and transportation')
    epr_fee_energydurable       ${epr_fee_energydurable}$           (long_name='EPR fee per unit of energy-using durable good produced')
    epr_fee_otherdurable        ${epr_fee_otherdurable}$            (long_name='EPR fee per unit of other durable good produced')
    reduced_laborcosts          ${reduced_laborcosts}$              (long_name='reduced labor costs')

%------------------------------------------------------------------------------------------------------------
% Power generation sector
%------------------------------------------------------------------------------------------------------------

        Inv_RDEN_EE	                ${Inv_RDEN_EE}$                 (long_name='R&D Investments of the power sector and energy efficiency')
        Inv_k_powercapacities       ${Inv_k_powercapacities}$       (long_name='Invetsments in new power generation capacities')

%------------------------------------------------------------------------------------------------------------
% Lifestyles
%------------------------------------------------------------------------------------------------------------

    @#for h in LIFESTYLES   
        modifier_sharing_@{h}      ${modifier_sharing_@{h}}$            (long_name='@{h} sharing lifestyle modifier')
        modifier_repair_@{h}       ${modifier_repair_@{h}}$             (long_name='@{h} repair lifestyle modifier')
        modifier_expenditures_@{h} ${modifier_expenditures_@{h}}$       (long_name='@{h} repair lifestyle modifier')
        siggma_es_@{h}             ${siggma_es_@{h}}$                   (long_name='_@{h} households homeproduced-sharing energy services substitution parameter')
        alppha_sharing_@{h}        ${alppha_sharing_@{h}}$              (long_name='@{h} lifestyle households market-produced sharing services distribution parameter')
        alppha_home_@{h}           ${alppha_home_@{h}}$                 (long_name='@{h} lifestyle households market-produced sharing services distribution parameter')
    @#endfor

    @#for h in ["lowcarbon","cautious"]
        omegga_@{h}                ${omegga_@{h}}$                      (long_name='share of @{h} lifestyle households in the economy') 
    @#endfor   

%------------------------------------------------------------------------------------------------------------
% Other
%------------------------------------------------------------------------------------------------------------

    eppsilon                    ${eppsilon}$                            (long_name='adjustment parameter to make the foreign demand of domestic goods constant through time') 
    @#for s in ["otherdurable","energydurable","capital"]
        Error_stock_@{s}           ${Error_stock_@{s}}$                 (long_name='Error term to macth 2018 data')
    @#endfor
    etta
;

parameters  

%------------------------------------------------------------------------------------------------------------
% Baseline energy prices
%------------------------------------------------------------------------------------------------------------

    p_nel_h_2018               ${p_nel_h_2018}$                     (long_name='households fuel price expressed in domestic currency')
    p_nel_f_2018               ${p_nel_f_2018}$                     (long_name='firms fuel price expressed in domestic currency')
    p_el_f_2018                ${p_el_f_2018}$                      (long_name='firms electricity price')
    p_el_h_2018                ${p_el_h_2018}$                      (long_name='households electricity price')

%------------------------------------------------------------------------------------------------------------
% Growth rate of the economy
%------------------------------------------------------------------------------------------------------------

    n                          ${n}$                                (long_name='demographic growth rate')
    g                          ${g}$                                (long_name='labor productivity growth rate')

%------------------------------------------------------------------------------------------------------------
% Consumer-side parameters
%------------------------------------------------------------------------------------------------------------

    betta                      ${betta}$                            (long_name='nominal discount rate')
    siggma_ies                 ${siggma_ies}$                       (long_name='intertemporel elasticity of substitution')
    siggma_e_h                 ${siggma_e_h}$                       (long_name='households interfuel substitution parameter')
    siggma_home                ${siggma_home}$                      (long_name='energy-using durable goods-energy substitution parameter')
    siggma_c                   ${siggma_c}$                         (long_name='consumption elasticity of substitution')
    siggma_inv_ed              ${siggma_inv_ed}$                    (long_name='CES aggregator of energy-using durable goods investments substitution elasticity')
    alppha_nes                 ${alppha_nes}$                       (long_name='nonenergy services distribution share')
    alppha_es                  ${alppha_es}$                        (long_name='energy services distribution share')
    siggma_nes                 ${siggma_nes}$                       (long_name='nonenergy services substitution elasticity')
    p_fg_row                   ${p_fg_row}$                         (long_name='index of world consumer prices in domestic currency') 
    alppha_x                   ${alppha_x}$                         (long_name='non-durable good distribution parameter')
    alppha_od                  ${alppha_od}$                        (long_name='other durable good distribution parameter')
    alppha_ed                  ${alppha_ed}$                        (long_name='energy-using durable good distribution parameter') 
    alppha_e                   ${alppha_e}$                         (long_name='energy distribution parameter') 
    share_savings_cautious     ${share_savings_cautious}$           (long_name='cautious lifestyle sharings as a share of lowcarbon lifestyle sharing')  
    siggma_dep                 ${siggma_dep}$                       (long_name='sensitivity of the depreciation rate to the use rate of energy-using durable goods')  
    siggma_dep_lowuse
    ac_ik                      ${ac_ik}$                            (long_name='capital investments adjustment cost parameter')
    ac_id                      ${ac_id}$                            (long_name='durable goods investments adjustment cost parameter')

    @#for h in LIFESTYLES  
        habit_@{h}                 ${habit_@{h}}$                       (long_name='@{h} lifestyle households habit persistence parameter')  
        alppha_el_@{h}             ${alppha_el_@{h}}$                   (long_name='@{h} lifestyle households electricity distribution parameter')
        alppha_nel_@{h}            ${alppha_nel_@{h}}$                  (long_name='@{h} lifestyle households fuel distribution parameter')
        alppha_ed_new_@{h}         ${alppha_ed_new_@{h}}$               (long_name='@{h} lifestyle households share of new energy-using durable goods investments for depreciated energy-using durable goods')
        alppha_ed_repair_@{h}      ${alppha_ed_repair_@{h}}$            (long_name='@{h} lifestyle households share of new energy-using durable goods investments for depreciated energy-using durable goods')
    @#endfor
    
%------------------------------------------------------------------------------------------------------------
% Production-side parameters
%------------------------------------------------------------------------------------------------------------

    @#for s in ["nondurable","otherdurable","energydurable","capital","virgin","recycled","sharing","repair"]
        h_@{s}                     ${h_@{s}}$                           (long_name='average number of hours worked')  
    @#endfor 

    @#for s in SECTORS
        Demand_foreign_@{s}        ${Demand_foreign_@{s}}$              (long_name='Foreign demand of domestically-produced @{s} good')
        alppha_k_@{s}              ${alppha_k_@{s}}$                    (long_name='@{s} good firms capital distribution parameter')
        alppha_n_@{s}              ${alppha_n_@{s}}$                    (long_name='@{s} good firms labor distribution parameter')
        alppha_kl_@{s}             ${alppha_kl_@{s}}$                   (long_name='@{s} good firms capital-labor distribution parameter')
        alppha_m_@{s}              ${alppha_m_@{s}}$                    (long_name='@{s} good firms material distribution parameter')
        alppha_z_@{s}              ${alppha_z_@{s}}$                    (long_name='@{s} good firms capital-labor-energy distribution parameter')
        alppha_e_@{s}              ${alppha_e_@{s}}$                    (long_name='@{s} good firms energy distribution parameter')
        alppha_v_@{s}              ${alppha_v_@{s}}$                    (long_name='@{s} good firms virgin materials distribution parameter')
        alppha_r_@{s}              ${alppha_r_@{s}}$                    (long_name='@{s} good firms virgin materials distribution parameter') 
    @#endfor

    @#for m in MATERIALS
        alppha_z_@{m}               ${alppha_z_@{m}}$                   (long_name='@{m} firms capital-energy distribution parameter')
        alppha_k_@{m}               ${alppha_k_@{m}}$                   (long_name='@{m} firms capital distribution parameter')
        alppha_n_@{m}               ${alppha_n_@{m}}$                   (long_name='@{m} firms labor distribution parameter')
        alppha_kl_@{m}              ${alppha_kl_@{m}}$                  (long_name='@{m} firms capital-labor bundle distribution parameter')
        alppha_e_@{m}               ${alppha_e_@{m}}$                   (long_name='@{m} firms aggregate energy distribution parameter')
        siggma_e_@{m}               ${siggma_e_@{m}}$                   (long_name='@{m} firms energy substitution parameter')
        gamma_@{m}                  ${gamma_@{m}}$                      (long_name='material leakage of the @{m} material firm')
    @#endfor

    alppha_rw                   ${alppha_rw}$                       (long_name='recycling firms recyclable waste distribution parameter')
    alppha_rm                   ${alppha_rm}$                       (long_name='virgin material firms raw material distribution parameter')
    siggma_e_f                  ${siggma_e_f}$                      (long_name='firms interfuel substitution parameter')
    siggma_z                    ${siggma_z}$                        (long_name='aggregate capital-labor-energy substitution parameter')
    siggma_y                    ${siggma_y}$                        (long_name='aggregate output substitution parameter')
    siggma_kl                   ${siggma_kl}$                       (long_name='aggregate capital-labor substitution parameter')
    siggma_m                    ${siggma_m}$                        (long_name='intermaterial substitution parameter')
    alppha_es_sharing           ${alppha_es_sharing}$               (long_name='sharing firms energy services distribution parameter')
    alppha_n_sharing            ${alppha_n_sharing}$                (long_name='sharing firms labor distribution share')
    siggma_sharing              ${siggma_sharing}$                  (long_name='sharing firms labor-energyservices substitution parameter')
    alppha_ed_sharing           ${alppha_ed_sharing}$               (long_name='sharing firms energy-using durable goods distribution parameter')
    alppha_e_sharing            ${alppha_e_sharing}$                (long_name='sharing firms energy distribution parameter')
    alppha_n_repair             ${alppha_n_repair}$                 (long_name='repair firms labor distribution parameter')
    alppha_k_repair             ${alppha_k_repair}$                 (long_name='repair firms capital distribution parameter')
    p_capital_norm              ${p_capital_norm}$                  (long_name='normalized capital good price')
    deltta_nondurable_fix       ${deltta_nondurable_fix}$           (long_name='nondurable good natural/obsolescence depreciation rate') 

    @#for s in ["nondurable","otherdurable","energydurable","capital","sharing","virgin","recycled"]
        alppha_el_@{s}             ${alppha_el_@{s}}$                   (long_name='@{s} good firms electricity distribution parameter')
        alppha_nel_@{s}            ${alppha_nel_@{s}}$                  (long_name='@{s} good firms fuel distribution parameter')
    @#endfor

    cost_maintenance            ${cost_maintenance}$                (long_name='maintenance costs for energy-using consumer goods of the sharing economy') 

%------------------------------------------------------------------------------------------------------------
% Government parameters
%------------------------------------------------------------------------------------------------------------

    t_c                         ${t_c}$                             (long_name='consumption tax')
    t_l                         ${t_l}$                             (long_name='labor revenues tax')
    t_k                         ${t_k}$                             (long_name='capital revenues tax')
    Tr                          ${Tr}$                              (long_name='lumpsum  social transfers to households')
    t_el_f                      ${t_el_f}$                          (long_name='firms electricity tax')
    t_el_h                      ${t_el_h}$                          (long_name='households electricity tax')

    @#for s in ["nondurable","otherdurable","energydurable"]
        g_c_@{s}                    ${g_c_@{s}}$                        (long_name='public expenses to @{s} good firms output ratio')
    @#endfor

%------------------------------------------------------------------------------------------------------------
% Trade parameters
%------------------------------------------------------------------------------------------------------------

    siggma_imports              ${siggma_imports}$                  (long_name='substitution elasticity between bundles of domestic and foreign goods for the domestic economy')
    siggma_exports              ${siggma_exports}$                  (long_name='substitution elasticity between bundles of domestic and foreign goods for the RoW')  

    @#for s in SECTORS
        share_domestic_@{s}         ${share_domestic_@{s}}$             (long_name='domestically-produced @{s} good demand distribution parameter for the domestic economy')
        share_imp_@{s}              ${share_imp_@{s}}$                  (long_name='domestically-produced @{s} good demand distribution parameter for the domestic economy')
        share_row_@{s}              ${share_row_@{s}}$                  (long_name='domestically-produced @{s} good demand distribution parameter for the RoW')
        share_row_dom_@{s}          ${share_row_@{s}}$                  (long_name='domestically-produced @{s} good demand distribution parameter for the RoW')
        Foreign_@{s} 
        t_imports_@{s}              ${t_imports_@{s}}$                  (long_name='import duties')
        margin_@{s}                 ${margin_@{s}}$                     (long_name='margins for reexports')
        gamma_reexport_@{s}         ${gamma_reexport_@{s}}$             (long_name='Reexports as a share of exports')
    @#endfor

    @#for m in MATERIALS
        share_domestic_@{m}         ${share_domestic_@{m}}$             (long_name='domestically-produced @{m} materials demand distribution parameter for the domestic economy')
        share_imp_@{m}              ${share_imp_@{m}}$                  (long_name='domestically-produced @{m} materials demand distribution parameter for the domestic economy')
        share_row_@{m}              ${share_row_@{m}}$                  (long_name='domestically-produced @{m} materials demand distribution parameter for the RoW')
        Demand_foreign_@{m}         ${Demand_foreign_@{m}}$             (long_name='RoW demand share of domestically-produced @{m} material') 
    @#endfor

%------------------------------------------------------------------------------------------------------------
% Material stock and flows
%------------------------------------------------------------------------------------------------------------

    decay_mu                    ${decay_mu}$                        (long_name='municipalities waste decay rate')
    decay_indu                  ${decay_indu}$                      (long_name='industrial waste decay rate')
    Foreign_virgin              ${Foreign_virgin}$                  (long_name='foreign demand of virgin materials')
    Foreign_recycled            ${Foreign_recycled}$                (long_name='foreign demand of secondary materials')
    omegga_mun_recycled         ${omegga_mun_recycled}$             (long_name='share of municipal waste sent to recycling')
    omegga_ind_recycled         ${omegga_ind_recycled}$             (long_name='share of industrial waste sent to recycling') 

%------------------------------------------------------------------------------------------------------------
% Circular economy
%------------------------------------------------------------------------------------------------------------

    @#for s in SECTORS
        gamma_@{s}                  ${gamma_@{s}}$                      (long_name='material leakage parameter of the the @{s} good firm')
        material_int_@{s}           ${material_int_@{s}}$               (long_name='Material intensity of @{s} good imports') 
    @#endfor
    
    @#for s in ["otherdurable","energydurable","capital"]
        deltta_@{s}_fix             ${deltta_@{s}_fix}$                 (long_name='@{s} good economic depreciation rate')  
        deltta_@{s}_physical        ${deltta_@{s}_physical}$            (long_name='@{s} good physical depreciation rate')   
    @#endfor
    deltta_energydurable_gov

%------------------------------------------------------------------------------------------------------------
% Other
%------------------------------------------------------------------------------------------------------------

    alppha_k_powercapacities    ${alppha_k_powercapacities}$        (long_name='share of powercapacities capital stock in total capital stock')
    Y_sharing_ss                ${Y_sharing_ss}$                    (long_name='Production of market energy services at steady state')
;

@#include "CIRCEE_calibration.m"

model;

// HOUSEHOLDS //

@#for h in LIFESTYLES 

    [name='@{h} lifestyle household aggregate consumption function']

    C_@{h}         =   (alppha_nes*(NES_@{h}^((siggma_c-1)/siggma_c))+alppha_es*(ES_@{h}^((siggma_c-1)/siggma_c)))^(siggma_c/(siggma_c-1));

    [name='@{h} lifestyle household  non-energy services function']

    NES_@{h}       =   (alppha_x*(X_@{h}^((siggma_nes-1)/siggma_nes))+alppha_od*(OD_@{h}^((siggma_nes-1)/siggma_nes)))^(siggma_nes/(siggma_nes-1));

    [name='@{h} lifestyle household aggregate energy services function']

    ES_@{h}	    =   ((alppha_home_@{h})*(ES_home_@{h}^((siggma_es_@{h}-1)/siggma_es_@{h}))+((1-modifier_sharing_@{h})*alppha_sharing_@{h})*((ES_sharing_@{h})^((siggma_es_@{h}-1)/siggma_es_@{h})))^(siggma_es_@{h}/(siggma_es_@{h}-1));

    [name='@{h} lifestyle household home-produced energy services function']

    ES_home_@{h}	=   (alppha_ed*((u_lowuse_@{h}*ED_lowuse_@{h})^((siggma_home-1)/siggma_home))+alppha_e*((E_@{h})^((siggma_home-1)/siggma_home)))^(siggma_home/(siggma_home-1));

    [name='@{h} lifestyle household home-produced energy services price']

    p_home_@{h}	=   (((alppha_ed^(siggma_home))*(uc_@{h}(-1)/(u_lowuse_@{h}))^(1-siggma_home))+((alppha_e^(siggma_home))*(p_e_h_@{h})^(1-siggma_home)))^(1/(1-siggma_home));

    [name='@{h} lifestyle household sharing services relative demand compared to home-produced energy services demand']

    p_sharing*(1+t_c)/p_home_@{h}	=   ((alppha_sharing_@{h}*(1-modifier_sharing_@{h}))/((alppha_home_@{h})))*(ES_home_@{h}/(ES_sharing_@{h}))^(1/siggma_es_@{h});

    [name='@{h} lifestyle household other durable goods Euler equation'] 

    (alppha_od/alppha_x)*(X_@{h}(+1)/OD_@{h}(+1))^(1/siggma_nes)   
    =	(((p_def_otherdurable*(1+t_c+epr_fee_otherdurable)))/p_nd_ati)*(1/betta)*disc_factor_@{h}
        +((t_w(+1)*(1-omegga_mun_recycled)*(M_stock_otherdurable(+1)*deltta_otherdurable_physical/(OD(+1)+OD_G(+1))))/p_nd_ati(+1))
        -(((p_def_otherdurable(+1)*(1+t_c+epr_fee_otherdurable(+1))))/p_nd_ati(+1))*(1-deltta_otherdurable_fix);

    [name='@{h} lifestyle household effective discount factor']  % This is equal to betta*disc_factor_@{h}

    disc_factor_@{h}     =     (alppha_nes*((C_@{h}/NES_@{h})^(1/siggma_c))*alppha_x*((NES_@{h}/X_@{h})^(1/siggma_nes))*((C_@{h}-habit_@{h}*(C_@{h}(-1)/(1+g+n+g*n)))^(-siggma_ies)-habit_@{h}*betta
                               *(C_@{h}(+1)*(1+g+n+g*n)-habit_@{h}*C_@{h})^(-siggma_ies)))
                               /(alppha_nes*((C_@{h}(+1)/NES_@{h}(+1))^(1/siggma_c))*alppha_x*((NES_@{h}(+1)/X_@{h}(+1))^(1/siggma_nes))*((1+g+n+g*n)^(-siggma_ies))
                               *((C_@{h}(+1)-habit_@{h}*(C_@{h}/(1+g+n+g*n)))^(-siggma_ies)-habit_@{h}*betta*(C_@{h}(+2)*(1+g+n+g*n)-habit_@{h}*C_@{h}(+1))^(-siggma_ies)));

    [name='@{h} lifestyle household other durable goods law of motion']

    Inv_od_@{h}	=   (1+n+g+n*g)*OD_@{h}(+1)-(1-deltta_otherdurable_fix)*OD_@{h};

    [name='@{h} lifestyle household relative demand of owned energy-using durable goods']

    uc_@{h}	    =   (p_nd_ati(+1)/(alppha_x*(NES_@{h}(+1)/X_@{h}(+1))^(1/siggma_nes)))*(alppha_es/alppha_nes)*((NES_@{h}(+1)/ES_@{h}(+1))^(1/siggma_c))
                    *((alppha_home_@{h}(+1)))*((ES_@{h}(+1)/ES_home_@{h}(+1))^(1/siggma_es_@{h}(+1)))*alppha_ed*u_lowuse_@{h}(+1)*((ES_home_@{h}(+1)/(u_lowuse_@{h}(+1)*ED_lowuse_@{h}(+1)))^(1/siggma_home));

    [name='@{h} lifestyle household owned energy-using durable goods Euler equation'] 

    uc_@{h}   =  ((q_ed_newtild_@{h}*p_nd_ati(+1)/(p_nd_ati*betta))*disc_factor_@{h})-((q_ed_newtild_@{h}(+1)-q_ed_depreciated_@{h}(+1)*deltta_energydurable_lowuse_@{h}(+1)));

    [name='@{h} lifestyle household owned energy-using durable goods use rate choice'] 

    uc_@{h}(-1) =   q_ed_depreciated_@{h}*deltta_energydurable_fix*siggma_dep_lowuse*(u_lowuse_@{h}^(siggma_dep_lowuse));

    [name='@{h} lifestyle household owned energy-using durable goods law of motion for undepreciated new owned energy-using durable goods'] 

    (1-AC_ID_new_@{h})*Inv_ed_new_tild_@{h}    =   (1+g+n+g*n)*ED_lowuse_@{h}(+1)-ED_lowuse_@{h};

    [name='@{h} lifestyle household depreciated owned energy-using durable goods law of motion'] 

    (1-AC_ID_g_@{h})*g_inv_ed_@{h} =   deltta_energydurable_lowuse_@{h}*ED_lowuse_@{h};

    [name='Owned energy-using durable good endogenous depreciation rate'] 

    deltta_energydurable_lowuse_@{h} = deltta_energydurable_fix*(u_lowuse_@{h}^(siggma_dep_lowuse));

    [name='@{h} lifestyle household owned energy-using durable goods repair expenses per unit of owned energy-using good'] 

    repair_ed_@{h}	=   Inv_ed_repair_@{h}/ED_lowuse_@{h};

    [name='@{h} lifestyle household owned energy-using durable goods repair expenses in total energy-using goods expenses'] 
    % The fraction of would‑be retirements that are “saved” by repairs. I assume material‐per‐yen is the same for both new and repair.
    % This assumption is not too strong as CIRCEE does not assume any material efficiency evolving through time for now.

    omegga_repair_@{h}        =   Inv_ed_repair_@{h}/(Inv_ed_repair_@{h}+Inv_ed_new_@{h}+Inv_ed_new_tild_@{h}); 

    [name='@{h} lifestyle household new owned energy-using durable good investments adjustment cost function'] 

    AC_ID_new_@{h}	=   (ac_id/2)*(((Inv_ed_new_tild_@{h})/(Inv_ed_new_tild_@{h}(-1)))-1)^2;

    [name='@{h} lifestyle household owned energy-using durable good investments adjustment cost function for depreciated owned energy-using durable goods'] 

    AC_ID_g_@{h}	=   (ac_id/2)*((g_inv_ed_@{h}/g_inv_ed_@{h}(-1))-1)^2;

    [name='@{h} lifestyle households new owned energy-using durable goods investments decision for new additions to the stock']

    (1-modifier_expenditures_@{h})*p_def_energydurable*(1+t_c+epr_fee_energydurable)	=   q_ed_newtild_@{h}*(1-AC_ID_new_@{h}-ac_id*((Inv_ed_new_tild_@{h}/(Inv_ed_new_tild_@{h}(-1)))-1)*(Inv_ed_new_tild_@{h}/(Inv_ed_new_tild_@{h}(-1))))
                                                                                            +betta*(p_nd_ati/p_nd_ati(+1))*(1/disc_factor_@{h})*q_ed_newtild_@{h}(+1)
                                                                                            *ac_id*((Inv_ed_new_tild_@{h}(+1)/(Inv_ed_new_tild_@{h}))-1)*(((Inv_ed_new_tild_@{h}(+1))/(Inv_ed_new_tild_@{h}))^2);

    [name='@{h} lifestyle household owned energy-using durable goods investments decision for depreciated owned energy-using durable good demand']                                

    (1-modifier_expenditures_@{h})*p_g_inv_ed_@{h}   =   q_ed_depreciated_@{h}*(1-AC_ID_g_@{h}-ac_id*((g_inv_ed_@{h}/g_inv_ed_@{h}(-1))-1)*(g_inv_ed_@{h}/g_inv_ed_@{h}(-1)))
                                                        +betta*(p_nd_ati/p_nd_ati(+1))*(1/disc_factor_@{h})*q_ed_depreciated_@{h}(+1)
                                                        *ac_id*((g_inv_ed_@{h}(+1)/g_inv_ed_@{h})-1)*((g_inv_ed_@{h}(+1)/g_inv_ed_@{h})^2);

    [name='@{h} lifestyle household composite owned energy-using durable good investment price']

    p_g_inv_ed_@{h}   =   ((alppha_ed_new_@{h}^siggma_inv_ed)*((p_def_energydurable*(1+t_c+epr_fee_energydurable))^(1-siggma_inv_ed))+((alppha_ed_repair_@{h}*(1-modifier_repair_@{h}))^siggma_inv_ed)*((p_repair*(1+t_c_reduced)*(1-repair_ed_bonus))^(1-siggma_inv_ed)))^(1/(1-siggma_inv_ed));                                                      

    [name='@{h} lifestyle household new owned energy-using durable good investment decision for depreciated owned energy-using durable good'] 

    p_def_energydurable*(1+t_c+epr_fee_energydurable)   =   alppha_ed_new_@{h}*((g_inv_ed_@{h}/(Inv_ed_new_@{h}))^(1/siggma_inv_ed))*p_g_inv_ed_@{h} ;

    [name='@{h} lifestyle household repairedowned energy-using  durable goods investment decision for depreciated owned energy-using durable goods']

    p_repair*(1+t_c_reduced)*(1-repair_ed_bonus) = alppha_ed_repair_@{h}*(1-modifier_repair_@{h})*((g_inv_ed_@{h}/(Inv_ed_repair_@{h}))^(1/siggma_inv_ed))*p_g_inv_ed_@{h} ;

    [name='@{h} lifestyle household relative energy demand'] 

    p_e_h_@{h}	    =   (p_nd_ati/(alppha_x*(NES_@{h}/X_@{h})^(1/siggma_nes)))*(alppha_es/alppha_nes)*((NES_@{h}/ES_@{h})^(1/siggma_c))
                        *((alppha_home_@{h}))*((ES_@{h}/ES_home_@{h})^(1/siggma_es_@{h}))*(alppha_e)*((ES_home_@{h}/(E_@{h}))^(1/siggma_home));

    [name='@{h} lifestyle household electricity demand'] 

    (p_el_h+t_el_h)*(1+t_c)/p_e_h_@{h}=alppha_el_@{h}*A_el_WITCH*(E_@{h}/(A_el_WITCH*El_@{h}))^(1/siggma_e_h);

    [name='@{h} lifestyle household fuel demand'] 

    (p_nel_h+t_nel_h)*(1+t_c)/p_e_h_@{h}=alppha_nel_@{h}*A_nel_@{h}*(E_@{h}/(A_nel_@{h}*Nel_@{h}))^(1/siggma_e_h); 

    [name='@{h} lifestyle household composite energy price'] 
 
    p_e_h_@{h}	=   ((((alppha_el_@{h})^(siggma_e_h))*((p_el_h+t_el_h)*(1+t_c)/A_el_WITCH)^(1-siggma_e_h))+((alppha_nel_@{h})^(siggma_e_h))*(((p_nel_h+t_nel_h)*(1+t_c)/A_nel_@{h})^(1-siggma_e_h)))^(1/(1-siggma_e_h));

    [name='@{h} lifestyle household fuel efficiency of end-uses'] 
    % from Gutowski et al. (2011). For now, given the dynamics of energy efficiency from WITCH, we do not make this equation a constraint in the model so that households do not take this into account when making decisions to buy new or repair.
    % A later version will incorporate this aspect endogeneously.

    A_nel_@{h}      =   ((Inv_ed_new_tild_@{h}+Inv_ed_new_@{h})/(Inv_ed_new_tild_@{h}+Inv_ed_new_@{h}+Inv_ed_repair_@{h}))*A_nel_WITCH
                        +(Inv_ed_repair_@{h}/(Inv_ed_new_tild_@{h}+Inv_ed_new_@{h}+Inv_ed_repair_@{h}))*A_nel_WITCH(-1); 

    [name='@{h} lifestyle household owned enegry-using durable goods total expenditures'] 

    Expenditures_LIFE_@{h} = p_def_energydurable*(1+t_c+epr_fee_energydurable)*(Inv_ed_new_tild_@{h}+Inv_ed_new_@{h})
                            +p_repair*(1+t_c_reduced)*(1-repair_ed_bonus)*Inv_ed_repair_@{h};

@#endfor

@#for h in ["lowcarbon","cautious"] 

    [name='@{h} lifestyle household new capital investments adjustment cost function'] 

    AC_IK_@{h}	=   (ac_ik/2)*((Inv_k_@{h}/Inv_k_@{h}(-1))-1)^2;

    [name='@{h} lifestyle household new capital law of motion'] 

    (1-AC_IK_@{h})*Inv_k_@{h}    =   (1+g+n+g*n)*K_@{h}(+1)-K_@{h}+deltta_capital_fix*K_@{h};

@#endfor         

    [name='Low-carbon lifestyle household new capital investments decision for undepreciated capital demand']

    p_def_capital	=   q_k_lowcarbon*(1-AC_IK_lowcarbon-ac_ik*((Inv_k_lowcarbon/Inv_k_lowcarbon(-1))-1)*(Inv_k_lowcarbon/Inv_k_lowcarbon(-1)))+betta*(p_nd_ati/p_nd_ati(+1))*(1/disc_factor_lowcarbon)*q_k_lowcarbon(+1)
                        *ac_ik*((Inv_k_lowcarbon(+1)/Inv_k_lowcarbon)-1)*((Inv_k_lowcarbon(+1)/Inv_k_lowcarbon)^2);

    [name='Low-carbon lifestyle household capital Euler equation']

    q_k_lowcarbon	=   betta*(p_nd_ati/p_nd_ati(+1))*(1/disc_factor_lowcarbon)*((r_k(+1)/(1+g+n+g*n))*(1-t_k*(1-deltta_capital_fix))+q_k_lowcarbon(+1)
                        *(1-deltta_capital_fix));                        
    
    [name='Sharing firms high-use energy-using goods depreciation rate']

     deltta_energydurable_highuse   =   deltta_energydurable_fix*(u_highuse^(siggma_dep));

     [name='Sharing firms high-use energy-using goods use rate']

     r_ed*(1-t_k)   =   q_ed_newtild_highuse*deltta_energydurable_fix*siggma_dep*(u_highuse^(siggma_dep-1))+cost_maintenance;

     [name='Sharing firms Euler equation for high-use energy-using goods']

     q_ed_newtild_highuse = betta*(p_nd_ati/p_nd_ati(+1))*(1/disc_factor_lowcarbon)*(r_ed(+1)*u_highuse(+1)*(1-t_k)
                            +q_ed_newtild_highuse(+1)*(1-deltta_energydurable_fix*(u_highuse(+1)^siggma_dep))-cost_maintenance*u_highuse(+1));

    [name='Sharing firms high-use energy-using goods law of motion']

     (1-AC_ID_new_highuse)*Inv_ed_new_highuse = (1+g+n+g*n)*ED_highuse(+1)-ED_highuse+deltta_energydurable_fix*((u_highuse^siggma_dep))*ED_highuse;
    
    [name='Sharing firms investment decision in high-use energy-using goods']

     p_def_energydurable*(1+t_c+epr_fee_energydurable) = q_ed_newtild_highuse*(1-AC_ID_new_highuse-ac_id*((Inv_ed_new_highuse/(Inv_ed_new_highuse(-1)))-1)*(Inv_ed_new_highuse/(Inv_ed_new_highuse(-1))))
                                                        +betta*(p_nd_ati/p_nd_ati(+1))*(1/disc_factor_lowcarbon)*q_ed_newtild_highuse(+1)
                                                        *ac_id*((Inv_ed_new_highuse(+1)/(Inv_ed_new_highuse))-1)*(((Inv_ed_new_highuse(+1))/(Inv_ed_new_highuse))^2);

    [name='Sharing firms high-use energy-using good investments adjustment cost function'] 

     AC_ID_new_highuse	=   (ac_id/2)*(((Inv_ed_new_highuse)/(Inv_ed_new_highuse(-1)))-1)^2;     

    [name='Constrained household budget constraint']
    (1-omegga_lowcarbon-omegga_cautious)*((1-t_l)*w*(h_repair*L_repair+h_sharing*L_sharing+h_nondurable*L_nondurable+h_otherdurable*L_otherdurable+h_energydurable*L_energydurable+h_capital*L_capital+h_virgin*L_virgin+h_recycled*L_recycled)+Tr+Carbon_budget+EPR_budget-redistribution_epr*(epr_fee_energydurable-0.0413049832)*p_def_energydurable*Inv_ed_new_highuse) 
    =   (1-omegga_lowcarbon-omegga_cautious)*((1+t_c)*(p_def_energydurable*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained)+p_sharing*ES_sharing_constrained+(p_el_h+t_el_h)*El_constrained+(p_nel_h+t_nel_h)*Nel_constrained)
        +p_def_energydurable*epr_fee_energydurable*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained)+p_nd_ati*X_constrained+p_def_otherdurable*(1+t_c+epr_fee_otherdurable)*Inv_od_constrained+(t_w*(1-omegga_mun_recycled)*M_stock_otherdurable
        *deltta_otherdurable_physical*(OD_constrained)/(OD+OD_G))+p_repair*(1+t_c_reduced)*(1-repair_ed_bonus)*Inv_ed_repair_constrained);   
      
    [name='Lowcarbon household budget constraint']

    omegga_lowcarbon*(((1-t_l)*w*(h_repair*L_repair+h_sharing*L_sharing+h_nondurable*L_nondurable+h_otherdurable*L_otherdurable+h_energydurable*L_energydurable+h_capital*L_capital+h_virgin*L_virgin+h_recycled*L_recycled)+Tr+Carbon_budget+EPR_budget)
    +(omegga_lowcarbon_saver/omegga_lowcarbon)*(((PS+DIV_total+DIV_imports+p_rawmaterials*Domestic_Extraction)/(omegga_lowcarbon_saver+(1-omegga_lowcarbon_saver)*share_savings_cautious))
    +r_k*(1-t_k*(1-deltta_capital_fix))*(K_lowcarbon/(1+g+n+g*n))-p_def_capital*Inv_k_lowcarbon
    +(((1-t_k)*r_ed*u_highuse*ED_highuse-p_def_energydurable*(1+t_c+epr_fee_energydurable)*Inv_ed_new_highuse+Y_power-p_def_capital*Inv_k_energy)/(omegga_lowcarbon_saver+(1-omegga_lowcarbon_saver)*share_savings_cautious))
    -((TB-((p_fg_row+p_fg_row*margin_capital)*gamma_reexport_capital*EXPORT_capital+(p_fg_row+p_fg_row*margin_nondurable)*gamma_reexport_nondurable*EXPORT_nondurable+(p_fg_row+p_fg_row*margin_otherdurable)*gamma_reexport_otherdurable*EXPORT_otherdurable+(p_fg_row+p_fg_row*margin_energydurable)*gamma_reexport_energydurable*EXPORT_energydurable))/(omegga_lowcarbon_saver+(1-omegga_lowcarbon_saver)*share_savings_cautious))))
    =   omegga_lowcarbon*(((1+t_c)*(p_def_energydurable*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+p_sharing*ES_sharing_lowcarbon+(p_el_h+t_el_h)*El_lowcarbon+(p_nel_h+t_nel_h)*Nel_lowcarbon)
        +p_def_energydurable*epr_fee_energydurable*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+p_nd_ati*X_lowcarbon+(p_def_otherdurable*(1+t_c+epr_fee_otherdurable))*Inv_od_lowcarbon+(t_w*(1-omegga_mun_recycled)*M_stock_otherdurable
        *deltta_otherdurable_physical*(OD_lowcarbon)/(OD+OD_G))+p_repair*(((1+t_c_reduced)*(1-repair_ed_bonus))*Inv_ed_repair_lowcarbon)));   

    [name='Cautious household budget constraint']

    omegga_cautious*(((1-t_l)*w*(h_repair*L_repair+h_sharing*L_sharing+h_nondurable*L_nondurable+h_otherdurable*L_otherdurable+h_energydurable*L_energydurable+h_capital*L_capital+h_virgin*L_virgin+h_recycled*L_recycled)+Tr+Carbon_budget+EPR_budget)
    +((1-omegga_lowcarbon_saver)/omegga_cautious)*((share_savings_cautious*(PS+DIV_total+DIV_imports+p_rawmaterials*Domestic_Extraction)/(omegga_lowcarbon_saver+(1-omegga_lowcarbon_saver)*share_savings_cautious))
    +r_k*(1-t_k*(1-deltta_capital_fix))*(K_cautious/(1+g+n+g*n))-p_def_capital*Inv_k_cautious
    +share_savings_cautious*(((1-t_k)*r_ed*u_highuse*ED_highuse-p_def_energydurable*(1+t_c+epr_fee_energydurable)*Inv_ed_new_highuse+Y_power-p_def_capital*Inv_k_energy)/(omegga_lowcarbon_saver+(1-omegga_lowcarbon_saver)*share_savings_cautious))
    -share_savings_cautious*((TB-((p_fg_row+p_fg_row*margin_capital)*gamma_reexport_capital*EXPORT_capital+(p_fg_row+p_fg_row*margin_nondurable)*gamma_reexport_nondurable*EXPORT_nondurable+(p_fg_row+p_fg_row*margin_otherdurable)*gamma_reexport_otherdurable*EXPORT_otherdurable+(p_fg_row+p_fg_row*margin_energydurable)*gamma_reexport_energydurable*EXPORT_energydurable))/(omegga_lowcarbon_saver+(1-omegga_lowcarbon_saver)*share_savings_cautious))))
    =   omegga_cautious*(((1+t_c)*(p_def_energydurable*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)+p_sharing*ES_sharing_cautious+(p_el_h+t_el_h)*El_cautious+(p_nel_h+t_nel_h)*Nel_cautious)
        +p_def_energydurable*epr_fee_energydurable*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)+p_nd_ati*X_cautious+(p_def_otherdurable*(1+t_c+epr_fee_otherdurable))*Inv_od_cautious+(t_w*(1-omegga_mun_recycled)*M_stock_otherdurable
        *deltta_otherdurable_physical*(OD_cautious)/(OD+OD_G))+p_repair*(((1+t_c_reduced)*(1-repair_ed_bonus))*Inv_ed_repair_cautious))); 

    [name='All tax included non-durable good price']

    p_nd_ati  = p_def_nondurable*(1+t_c)+t_w*(1-omegga_mun_recycled)*((1-gamma_nondurable)*M_nondurable/Y_nondurable)*(Demand_dom_nondurable+material_int_nondurable*IMP_nondurable)*(1/(X+X_G));  

    [name='Capital stock of the cautious household as a share of the lowcarbons']

    K_cautious = share_savings_cautious*K_lowcarbon;

    [name='Share of lowcarbon saver in total savers']

    omegga_lowcarbon_saver = omegga_lowcarbon/(omegga_lowcarbon+omegga_cautious);

    [name='Aggregation rule for the capital supply']

    K  = omegga_lowcarbon_saver*K_lowcarbon+(1-omegga_lowcarbon_saver)*K_cautious;

    [name='Households fuel efficiency difference']

    diff_A_nel  =   A_nel-A_nel_WITCH;

// PRODUCTION SECTORS //

    /* Energy market - WITCH */
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    [name='Fuel price - Indutries']

    p_nel_f     =   p_nel_f_2018*(1+g_nel_witch);

    [name='Fuel price - Households']

    p_nel_h     =   p_nel_h_2018*(1+g_nel_witch);

    [name='Electricity price - Indutries']

    p_el_f      =   p_el_f_2018*(1+g_el_witch);

    [name='Electricity price - Households']

    p_el_h      =   p_el_h_2018*(1+g_el_witch);

    /* Materials producing sectors */
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [name='Marginal cost of the recycling sector']

    marginalcost_recycled   =   ((alppha_z_recycled^siggma_y)*(((alppha_kl_recycled^siggma_z)*((((alppha_k_recycled^siggma_kl)*(r_k^(1-siggma_kl))+(alppha_n_recycled^siggma_kl)*(w^(1-siggma_kl)))^(1/(1-siggma_kl)))^(1-siggma_z))
                                +(alppha_e_recycled^siggma_z)*((p_e_recycled)^(1-siggma_z)))^(1/(1-siggma_z)))^(1-siggma_y)+(alppha_rw^siggma_y)*(((t_m*gamma_recycled*(1-omegga_ind_recycled)+c_m*gamma_recycled)/(1-gamma_recycled))^(1-siggma_y)))^(1/(1-siggma_y)); 

    [name='Subsidies to the recycling sector']

    sub_recycled   =   (marginalcost_recycled-p_virgin)*Y_recycled;

    [name='Virgin material firms production technology']

    Y_virgin	=   (alppha_z_virgin*(Z_virgin^((siggma_y-1)/siggma_y))+alppha_rm*(((1-gamma_virgin)*RM)^((siggma_y-1)/siggma_y)))^(siggma_y/(siggma_y-1));

    [name='Virgin material firms raw material demand']

    t_m*gamma_virgin*(1-omegga_ind_recycled)+c_m*gamma_virgin+p_rawmaterials = p_virgin*alppha_rm*(1-gamma_virgin)*(Y_virgin/((1-gamma_virgin)*RM))^(1/siggma_y);

    [name='Recycling firms production technology']

    Y_recycled	=   (alppha_z_recycled*(Z_recycled^((siggma_y-1)/siggma_y))+alppha_rw*((RW*(1-gamma_recycled))^((siggma_y-1)/siggma_y)))^(siggma_y/(siggma_y-1));

    [name='Recycling firms recyclable waste demand']

    (t_m*gamma_recycled*(1-omegga_ind_recycled)+c_m*gamma_recycled) = p_recycled*alppha_rw*(1-gamma_recycled)*(Y_recycled/(RW*(1-gamma_recycled)))^(1/siggma_y);

@#for m in MATERIALS

    [name='@{m} firms (capital-labor)-energy technology']

    Z_@{m}	=   (alppha_kl_@{m}*(KL_@{m}^((siggma_z-1)/siggma_z))+alppha_e_@{m}*((E_@{m})^((siggma_z-1)/siggma_z)))^(siggma_z/(siggma_z-1));

    [name='@{m} firms capital demand']

    r_k   =   alppha_z_@{m}*((Y_@{m}/Z_@{m})^(1/siggma_y))*alppha_kl_@{m}*((Z_@{m}/KL_@{m})^(1/siggma_z))*alppha_k_@{m}
            *((KL_@{m}/K_@{m})^(1/siggma_kl))*(p_@{m});

    [name='@{m} firms labor demand']

    w   =   alppha_z_@{m}*((Y_@{m}/Z_@{m})^(1/siggma_y))*alppha_kl_@{m}*((Z_@{m}/KL_@{m})^(1/siggma_z))*alppha_n_@{m}
            *((KL_@{m}/(h_@{m}*L_@{m}))^(1/siggma_kl))*(p_@{m});

    [name='@{m} firms aggregate energy demand']

    p_e_@{m} =   alppha_z_@{m}*((Y_@{m}/Z_@{m})^(1/siggma_y))*alppha_e_@{m}
                        *((Z_@{m}/(E_@{m}))^(1/siggma_z))*(p_@{m});

   [name='@{m} firms aggregate/zero-profit energy price']

   p_e_@{m}	=   ((alppha_el_@{m}^(siggma_e_@{m}))*(((p_el_f+t_el_f)/A_el_WITCH)^(1-siggma_e_@{m}))+((alppha_nel_@{m})^(siggma_e_@{m}))*(((p_nel_f+t_nel_f)/A_nel_WITCH)^(1-siggma_e_@{m})))^(1/(1-siggma_e_@{m}));

   [name='@{m} firms electricity demand']

   (p_el_f+t_el_f)/p_e_@{m}=alppha_el_@{m}*A_el_WITCH*(E_@{m}/(A_el_WITCH*El_@{m}))^(1/siggma_e_f);

   [name='@{m} good firms fuel demand']

   (p_nel_f+t_nel_f)/p_e_@{m}=alppha_nel_@{m}*A_nel_WITCH*(E_@{m}/(A_nel_WITCH*Nel_@{m}))^(1/siggma_e_f); 

@#endfor

     /* Final goods producing sectors */
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     [name='Capital good firms price']

     p_capital  =   p_capital_norm;

    @#for s in SECTORS   

        @#if s in ["nondurable","otherdurable","energydurable"]

        [name='@{s} good firms price']

        p_@{s}  =   ((alppha_z_@{s}^siggma_y)*(((alppha_kl_@{s}^siggma_z)*((((alppha_k_@{s}^siggma_kl)*(r_k^(1-siggma_kl))+(alppha_n_@{s}^siggma_kl)*(w^(1-siggma_kl)))^(1/(1-siggma_kl)))^(1-siggma_z))+(alppha_e_@{s}^siggma_z)*((p_e_@{s})^(1-siggma_z)))^(1/(1-siggma_z)))^(1-siggma_y)+(alppha_m_@{s}^siggma_y)*((p_m_@{s})^(1-siggma_y)))^(1/(1-siggma_y)); 

        @#endif

     [name='@{s} good firms production technology']

     KL_@{s}	=   (alppha_k_@{s}*(K_f_@{s}^((siggma_kl-1)/siggma_kl))+alppha_n_@{s}*((h_@{s}*L_@{s})^((siggma_kl-1)/siggma_kl)))^(siggma_kl/(siggma_kl-1));

     [name='@{s} good firms (capital-labor)-energy technology']

     Z_@{s}	=   (alppha_kl_@{s}*(KL_@{s}^((siggma_z-1)/siggma_z))+alppha_e_@{s}*((E_@{s})^((siggma_z-1)/siggma_z)))^(siggma_z/(siggma_z-1));
    
     [name='@{s} good firms composite materials price']

     p_m_c_@{s}	=   ((alppha_v_@{s}^(1-siggma_m))*(((p_virgin+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s})*(A_m_@{s}*(1-gamma_@{s})))^(-siggma_m))+((alppha_r_@{s})^(1-siggma_m))*(((p_recycled+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s})*(A_m_@{s}*(1-gamma_@{s})))^(-siggma_m)))^(1/(-siggma_m));

     [name='@{s} good firms aggregate/zero-profit materials price'] 

     p_m_@{s}	=   (p_m_c_@{s}^siggma_m)*((alppha_v_@{s}^(1-siggma_m))*(1/(A_m_@{s}*(1-gamma_@{s})))*(((p_virgin+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s})*(A_m_@{s}*(1-gamma_@{s})))^(1-siggma_m))+((alppha_r_@{s})^(1-siggma_m))*(1/(A_m_@{s}*(1-gamma_@{s})))*(((p_recycled+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s})*(A_m_@{s}*(1-gamma_@{s})))^(1-siggma_m)));

     [name='@{s} good firms aggregate materials demand']

     p_m_@{s}/p_@{s}	=	alppha_m_@{s}*(Y_@{s}/(M_@{s}))^(1/siggma_y);

     [name='@{s} good firms virgin materials demand']

     M_virgin_@{s}    =  ((1/(A_m_@{s}*(1-gamma_@{s})))^siggma_m)*((1/alppha_v_@{s})^(siggma_m-1))*((p_m_c_@{s}/(p_virgin+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s}))^siggma_m)*M_@{s};

     [name='@{s} good firms secondary materials demand']

     M_recycled_@{s}    =  ((1/(A_m_@{s}*(1-gamma_@{s})))^siggma_m)*((1/(alppha_r_@{s}))^(siggma_m-1))*((p_m_c_@{s}/(p_recycled+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s}))^siggma_m)*M_@{s};

     [name='@{s} good firms capital demand']

     r_k/p_@{s}	=   alppha_z_@{s}*((Y_@{s}/Z_@{s})^(1/siggma_y))*alppha_kl_@{s}*((Z_@{s}/KL_@{s})^(1/siggma_z))*alppha_k_@{s}*((KL_@{s}/K_f_@{s})^(1/siggma_kl));

     [name='@{s} good firms labor demand']

     w/p_@{s}	=   alppha_z_@{s}*((Y_@{s}/Z_@{s})^(1/siggma_y))*alppha_kl_@{s}*((Z_@{s}/KL_@{s})^(1/siggma_z))*alppha_n_@{s}*((KL_@{s}/(h_@{s}*L_@{s}))^(1/siggma_kl));

     [name='@{s} good firms aggregate/zero-profit energy price']

     p_e_@{s}	=   ((alppha_el_@{s}^(siggma_e_f))*(((p_el_f+t_el_f)/A_el_WITCH)^(1-siggma_e_f))+((alppha_nel_@{s})^(siggma_e_f))*(((p_nel_f+t_nel_f)/A_nel_WITCH)^(1-siggma_e_f)))^(1/(1-siggma_e_f));

     [name='@{s} good firms aggregate energy demand']

     p_e_@{s}/p_@{s}  =   alppha_z_@{s}*((Y_@{s}/Z_@{s})^(1/siggma_y))*alppha_e_@{s}*((Z_@{s}/(E_@{s}))^(1/siggma_z));

     [name='@{s} good firms electricity demand']

     (p_el_f+t_el_f)/p_e_@{s}=alppha_el_@{s}*A_el_WITCH*(E_@{s}/(A_el_WITCH*El_@{s}))^(1/siggma_e_f);

     [name='@{s} good firms fuel demand']

     (p_nel_f+t_nel_f)/p_e_@{s}=alppha_nel_@{s}*A_nel_WITCH*(E_@{s}/(A_nel_WITCH*Nel_@{s}))^(1/siggma_e_f); 

    @#endfor

    [name='Capital good firms (capital-labor) technology']

    Y_capital	=   (alppha_z_capital*(Z_capital^((siggma_y-1)/siggma_y))+alppha_m_capital*((M_capital)^((siggma_y-1)/siggma_y)))^(siggma_y/(siggma_y-1));

     /* Sharing sector */
     %%%%%%%%%%%%%%%%%%%

     [name='Sharing firm production technology']

     Y_sharing	=   (alppha_n_sharing*((h_sharing*L_sharing)^((siggma_sharing-1)/siggma_sharing))+alppha_es_sharing*(ES_sharing_f^((siggma_sharing-1)/siggma_sharing)))^(siggma_sharing/(siggma_sharing-1));


     [name='Sharing firms price']

     p_sharing = ((Y_sharing_ss/Y_sharing(-1)))^(etta)*((alppha_n_sharing^siggma_sharing)*((w)^(1-siggma_sharing))+(alppha_es_sharing^siggma_sharing)*(((alppha_e_sharing^siggma_home)*((p_e_sharing))^(1-siggma_home)+(alppha_ed_sharing^siggma_home)*(((r_ed)))^(1-siggma_home))^(1/(1-siggma_home)))^(1-siggma_sharing))^(1/((1-siggma_sharing)));
    
    [name='Sharing firms uED demand']

     r_ed      = p_sharing*alppha_es_sharing*((Y_sharing/ES_sharing_f)^(1/siggma_sharing))*alppha_ed_sharing*((ES_sharing_f/(u_highuse*ED_highuse))^(1/siggma_home));

     [name='Sharing firms labor demand']

     w/(p_sharing) =   alppha_n_sharing*((Y_sharing/(h_sharing*L_sharing))^(1/siggma_sharing));

     [name='Sharing firms energy demand']

     p_e_sharing/(p_sharing)	=   alppha_es_sharing*((Y_sharing/ES_sharing_f)^(1/siggma_sharing))*alppha_e_sharing*((ES_sharing_f/(E_sharing))^(1/siggma_home));

     [name='Sharing firms aggregate/zero-profit energy price']

     p_e_sharing	=   (((alppha_el_sharing^(siggma_e_h))*((p_el_f+t_el_f)/A_el_WITCH)^(1-siggma_e_h))+((alppha_nel_sharing)^(siggma_e_h))*(((p_nel_f+t_nel_f)/A_nel)^(1-siggma_e_h)))^(1/(1-siggma_e_h));

     [name='Sharing firms electricity demand']

     (p_el_f+t_el_f)/p_e_sharing=alppha_el_sharing*A_el_WITCH*(E_sharing/(A_el_WITCH*El_sharing))^(1/siggma_e_h);

     [name='Sharing firms fuel demand']

     (p_nel_f+t_nel_f)/p_e_sharing=alppha_nel_sharing*A_nel*(E_sharing/(A_nel*Nel_sharing))^(1/siggma_e_h); 

     /* Repairing sector */  
     %%%%%%%%%%%%%%%%%%%%%

     [name='Repair firms labor demand']

     (1-reduced_laborcosts)*w/p_repair	=   alppha_n_repair*((Y_repair/(h_repair*L_repair))^(1/siggma_kl));

     [name='Repair firms capital demand']

     r_k/p_repair	=   alppha_k_repair*((Y_repair/K_repair)^(1/siggma_kl));

     [name='Repair services price']

     p_repair  =   ((alppha_n_repair^siggma_kl)*(((1-reduced_laborcosts)*w)^(1-siggma_kl))+(alppha_k_repair^siggma_kl)*(r_k^(1-siggma_kl)))^(1/(1-siggma_kl));

// GOVERNMENT //

     [name='Public non-durable goods demand'] 
 
     X_G    =   g_c_nondurable*Y_nondurable;
 
     [name='Public other durable goods decision']
 
     Inv_od_G    =   g_c_otherdurable*Y_otherdurable;
 
     [name='Public energy-using durable goods Euler equation'] 
 
     Inv_ed_G     =   g_c_energydurable*Y_energydurable;

     [name='Public energy-using durable goods law of motion']

     (1+g+n+g*n)*ED_G(+1)	=   Inv_ed_G+(1-deltta_energydurable_gov)*ED_G;

     [name='Public other durable goods law of motion']

     (1+g+n+g*n)*OD_G(+1)	=   Inv_od_G+(1-deltta_otherdurable_fix)*OD_G;

     [name='Fiscal revenues']   

      Revenues	=   epr_fee_otherdurable*p_def_otherdurable*(omegga_lowcarbon*Inv_od_lowcarbon+omegga_cautious*Inv_od_cautious+(1-omegga_lowcarbon-omegga_cautious)*Inv_od_constrained)
                    +epr_fee_energydurable*p_def_energydurable*(Inv_ed_new_highuse+omegga_lowcarbon*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+omegga_cautious*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)+(1-omegga_lowcarbon-omegga_cautious)*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained))
                    +t_c_reduced*p_repair*(1-repair_ed_bonus)*(omegga_lowcarbon*Inv_ed_repair_lowcarbon+omegga_cautious*Inv_ed_repair_cautious+(1-omegga_lowcarbon-omegga_cautious)*Inv_ed_repair_constrained)
                    +t_c*(p_def_nondurable*X+p_def_energydurable*(Inv_ed_new_highuse+omegga_lowcarbon*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+omegga_cautious*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)+(1-omegga_lowcarbon-omegga_cautious)*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained))
                    +p_def_otherdurable*(omegga_lowcarbon*Inv_od_lowcarbon+omegga_cautious*Inv_od_cautious+(1-omegga_lowcarbon-omegga_cautious)*Inv_od_constrained)+p_sharing*ES_sharing+(p_el_h+t_el_h)*El_h+(p_nel_h+t_nel_h)*Nel_h)
                    +t_el_h*(El_h)+t_el_f*(El_nondurable+El_otherdurable+El_energydurable+El_capital+El_virgin+El_recycled+El_sharing)
                    +t_nel_h*(Nel_h)+t_nel_f*(Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_capital+Nel_virgin+Nel_recycled+Nel_sharing)
                    +t_l*w*(h_repair*L_repair+h_sharing*L_sharing+h_nondurable*L_nondurable+h_otherdurable*L_otherdurable+h_energydurable*L_energydurable+h_capital*L_capital+h_virgin*L_virgin+h_recycled*L_recycled)
                    +t_k*(r_k*(K/(1+g+n+g*n))*(1-deltta_capital_fix))
                    +t_k*r_ed*u_highuse*ED_highuse
                    +(t_m*(1-omegga_ind_recycled)+c_m)*(gamma_nondurable*(M_virgin_nondurable+M_recycled_nondurable)+gamma_otherdurable*(M_virgin_otherdurable+M_recycled_otherdurable)+gamma_energydurable*(M_virgin_energydurable+M_recycled_energydurable)+gamma_capital*(M_virgin_capital+M_recycled_capital)+gamma_virgin*RM+gamma_recycled*RW)
                    +t_w*(1-omegga_mun_recycled)*((((1-gamma_nondurable)*M_nondurable/Y_nondurable)*(Demand_dom_nondurable+material_int_nondurable*IMP_nondurable)*(X/(X+X_G)))+(M_stock_otherdurable*deltta_otherdurable_physical*(OD/(OD+OD_G))))
                    +p_fg_row*(t_imports_capital*(IMP_capital)+t_imports_energydurable*(IMP_energydurable)+t_imports_nondurable*(IMP_nondurable)+t_imports_otherdurable*(IMP_otherdurable));

     [name='Fiscal expenses'] 

     Expenses	=  w*reduced_laborcosts*h_repair*L_repair+p_def_nondurable*X_G+p_def_otherdurable*Inv_od_G+p_def_energydurable*Inv_ed_G+Tr+Carbon_budget+EPR_budget+p_repair*repair_ed_bonus*(omegga_lowcarbon*Inv_ed_repair_lowcarbon+omegga_cautious*Inv_ed_repair_cautious+(1-omegga_lowcarbon-omegga_cautious)*Inv_ed_repair_constrained); 

     [name='Carbon tax redistribution mechanism'] 

     Carbon_budget    =   redistribution*(t_nel_h*(Nel_h)+t_nel_f*(Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_virgin+Nel_capital+Nel_recycled+Nel_sharing));

     [name='EPR fee redistribution mechanism'] 

     EPR_budget        =    redistribution_epr*((epr_fee_energydurable-0.0413049832)*p_def_energydurable*(Inv_ed_new_highuse+omegga_lowcarbon*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+omegga_cautious*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)+(1-omegga_lowcarbon-omegga_cautious)*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained)));

     [name='Total EPR revenues'] 

     EPR_budget_bis    =    (epr_fee_energydurable*p_def_energydurable*(Inv_ed_new_highuse+omegga_lowcarbon*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+omegga_cautious*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)+(1-omegga_lowcarbon-omegga_cautious)*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained)));

     [name='Primary surplus']

     PS = Revenues-Expenses;
           
// TRADE // 

    /* Materials trade flows */
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    [name='Virgin materials export supply of the domestic economy']

    EXPORT_virgin	    =   (eppsilon*((share_row_virgin)^siggma_exports)*Demand_foreign_virgin*Y_virgin+(1-eppsilon)*Foreign_virgin);

    [name='Recycled materials export supply of the domestic economy']

    EXPORT_recycled	    =   (eppsilon*((share_row_recycled)^siggma_exports)*Demand_foreign_recycled*Y_recycled+(1-eppsilon)*Foreign_recycled);

@#for m in MATERIALS

    [name='Foreignly-produced @{m} materials demand of the domestic economy'] 

    IMP_@{m}    =   ((share_imp_@{m})^siggma_imports)*(M_@{m}_energydurable+M_@{m}_nondurable+M_@{m}_otherdurable+M_@{m}_capital);

    [name='Domestically-produced @{m} materials demand of the domestic economy']

    Demand_dom_@{m}	=   (share_domestic_@{m}^siggma_imports)*(M_@{m}_energydurable+M_@{m}_nondurable+M_@{m}_otherdurable+M_@{m}_capital);

@#endfor

     /* Final goods trade flows */
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@#for s in SECTORS

     [name='Domestic @{s} good price deflator'] 

     p_def_@{s}	=   ((share_domestic_@{s}^siggma_imports)*(p_@{s}^(1-siggma_imports))+(share_imp_@{s}^siggma_imports)*((p_fg_row+p_fg_row*t_imports_@{s})^(1-siggma_imports)))^(1/(1-siggma_imports)); 

     [name='Foreign @{s} good price deflator'] 

     p_row_@{s}	=   ((share_row_dom_@{s}^siggma_exports)*(p_fg_row^(1-siggma_exports))+(share_row_@{s}^siggma_exports)*(p_@{s}^(1-siggma_exports)))^(1/(1-siggma_exports)); 

     [name='@{s} goods domestically produced exports']

     EXPORT_@{s}	=   (((share_row_@{s})*(p_row_@{s}/p_@{s}))^siggma_exports)*Demand_foreign_@{s}*(eppsilon*Y_@{s}+(1-eppsilon)*Foreign_@{s}); 
     
@#endfor

     [name='Foreignly-produced non-durable good demand of the domestic economy'] 

     IMP_nondurable	=   (((share_imp_nondurable)*(p_def_nondurable/(p_fg_row+p_fg_row*t_imports_nondurable)))^siggma_imports)*(X+X_G);

     [name='Domestically-produced non-durable good demand of the domestic economy']

     Demand_dom_nondurable	=   (((share_domestic_nondurable)*(p_def_nondurable/p_nondurable))^siggma_imports)*(X+X_G);

     [name='Foreignly-produced other durable good demand of the domestic economy'] 

     IMP_otherdurable	=   (((share_imp_otherdurable)*(p_def_otherdurable/(p_fg_row+p_fg_row*t_imports_otherdurable)))^siggma_imports)*((omegga_lowcarbon*Inv_od_lowcarbon+omegga_cautious*Inv_od_cautious+(1-omegga_lowcarbon-omegga_cautious)*Inv_od_constrained)+Inv_od_G);

     [name='Domestically-produced other durable good demand of the domestic economy']

     Demand_dom_otherdurable	=   (((share_domestic_otherdurable)*(p_def_otherdurable/p_otherdurable))^siggma_imports)*((omegga_lowcarbon*Inv_od_lowcarbon+omegga_cautious*Inv_od_cautious+(1-omegga_lowcarbon-omegga_cautious)*Inv_od_constrained)+Inv_od_G);

     [name='Foreignly-produced energy-using durable good demand of the domestic economy'] 

     IMP_energydurable	=   (((share_imp_energydurable)*(p_def_energydurable/(p_fg_row+p_fg_row*t_imports_energydurable)))^siggma_imports)*((omegga_lowcarbon*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+omegga_cautious*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)+(1-omegga_lowcarbon-omegga_cautious)*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained))+Inv_ed_G+Inv_ed_new_highuse);

     [name='Domestically-produced energy-using durable good demand of the domestic economy']

     Demand_dom_energydurable	=   (((share_domestic_energydurable)*(p_def_energydurable/p_energydurable))^siggma_imports)*((omegga_lowcarbon*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+omegga_cautious*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)+(1-omegga_lowcarbon-omegga_cautious)*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained))+Inv_ed_G+Inv_ed_new_highuse);

     [name='Foreignly-produced capital good demand of the domestic economy'] 

     IMP_capital	=   (((share_imp_capital)*(p_def_capital/(p_fg_row+p_fg_row*t_imports_capital)))^siggma_imports)*(Inv_k+Inv_k_energy);

     [name='Domestically-produced capital good demand of the domestic economy']

     Demand_dom_capital	=   (((share_domestic_capital)*(p_def_capital/p_capital))^siggma_imports)*(Inv_k+Inv_k_energy);

     [name='Ressources imports']

     % The values in equations are the share of biomass (imported for 48%, 0.48), metals ores (fully imported, 1) and other non-metallic minerals (fully domestically extracted, hence it does not appear here) that are imported or domestically_produced, weighted by the share of each in each product category mass. 
     % For example, biomass represents 3 percent of materials used for energy-using durable goods and metal ores 66 percent.

     IMP_R	=   RM*(((6.6053092E-01*1+3.1742072E-02*0.48)*(M_virgin_energydurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(2.0252225E-01*1+6.9488153E-02*0.48)*(M_virgin_otherdurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(3.6768029E-01*1+6.6377722E-02*0.48)*(M_virgin_capital/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+1.8454667E-02*0.48*(M_virgin_nondurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))))+p_nel_f*(Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_capital+Nel_virgin+Nel_recycled+Nel_sharing)+p_nel_h*(Nel_h);

     [name='Domestic extraction']

     Domestic_Extraction    =   RM*(1-((6.6053092E-01*1+3.1742072E-02*0.48)*(M_virgin_energydurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(2.0252225E-01*1+6.9488153E-02*0.48)*(M_virgin_otherdurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(3.6768029E-01*1+6.6377722E-02*0.48)*(M_virgin_capital/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+1.8454667E-02*0.48*(M_virgin_nondurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))));

    [name='Dividends of the foreignly- and domestically-produced good aggregator']

     DIV_imports =   p_def_nondurable*(X+X_G)-(p_fg_row+p_fg_row*t_imports_nondurable)*IMP_nondurable-p_nondurable*Demand_dom_nondurable
                    +p_def_otherdurable*((omegga_lowcarbon*Inv_od_lowcarbon+omegga_cautious*Inv_od_cautious+(1-omegga_lowcarbon-omegga_cautious)*Inv_od_constrained)+Inv_od_G)-(p_fg_row+p_fg_row*t_imports_otherdurable)*IMP_otherdurable-p_otherdurable*Demand_dom_otherdurable
                    +p_def_energydurable*((omegga_lowcarbon*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+omegga_cautious*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)+(1-omegga_lowcarbon-omegga_cautious)*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained))+Inv_ed_G+Inv_ed_new_highuse)-(p_fg_row+p_fg_row*t_imports_energydurable)*IMP_energydurable-p_energydurable*Demand_dom_energydurable
                    +p_def_capital*(Inv_k+Inv_k_energy)-(p_fg_row+p_fg_row*t_imports_capital)*IMP_capital-p_capital*Demand_dom_capital
                    +p_virgin*(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital)-p_virgin*IMP_virgin-p_virgin*Demand_dom_virgin
                    +p_recycled*(M_recycled_energydurable+M_recycled_nondurable+M_recycled_otherdurable+M_recycled_capital)-p_recycled*IMP_recycled-p_recycled*Demand_dom_recycled;

     /* Trade balance */
     %%%%%%%%%%%%%%%%%%

     [name='Trade balance of the economy'] 

     TB  =   p_capital*EXPORT_capital+p_nondurable*EXPORT_nondurable+p_otherdurable*EXPORT_otherdurable+p_energydurable*EXPORT_energydurable+p_recycled*EXPORT_recycled+p_virgin*EXPORT_virgin
            +(p_fg_row+p_fg_row*margin_capital)*gamma_reexport_capital*EXPORT_capital+(p_fg_row+p_fg_row*margin_nondurable)*gamma_reexport_nondurable*EXPORT_nondurable+(p_fg_row+p_fg_row*margin_otherdurable)*gamma_reexport_otherdurable*EXPORT_otherdurable+(p_fg_row+p_fg_row*margin_energydurable)*gamma_reexport_energydurable*EXPORT_energydurable
            -(p_fg_row*(IMP_nondurable)+p_fg_row*(IMP_otherdurable)+p_fg_row*(IMP_energydurable)+p_fg_row*(IMP_capital)+p_recycled*IMP_recycled+p_virgin*IMP_virgin+p_rawmaterials*(((6.6053092E-01*1+3.1742072E-02*0.48)*(M_virgin_energydurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(2.0252225E-01*1+6.9488153E-02*0.48)*(M_virgin_otherdurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(3.6768029E-01*1+6.6377722E-02*0.48)*(M_virgin_capital/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+1.8454667E-02*0.48*(M_virgin_nondurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))))*RM)
             -p_nel_f*(Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_capital+Nel_virgin+Nel_recycled+Nel_sharing)-p_nel_h*(Nel_h);

// MARKET CLEARING //

     [name='Capital market clearing']

     K	=   (1+g+n+g*n)*(K_f_nondurable+K_f_otherdurable+K_f_energydurable+K_f_capital+K_virgin+K_recycled+K_repair); 

     [name='Labor market clearing']

     1	=   L_nondurable+L_otherdurable+L_energydurable+L_capital+L_virgin+L_recycled+L_sharing+L_repair;

     [name='Recycling materials market clearing']

     Y_recycled = Demand_dom_recycled+EXPORT_recycled;

     [name='Virgin materials market clearing']

     Y_virgin = Demand_dom_virgin+EXPORT_virgin;  

     [name='Repair market clearing']

     Y_repair	=   (omegga_lowcarbon*Inv_ed_repair_lowcarbon+omegga_cautious*Inv_ed_repair_cautious+(1-omegga_lowcarbon-omegga_cautious)*Inv_ed_repair_constrained);

     [name='Sharing market clearing']

     Y_sharing	=   ES_sharing;

     [name='Non-durable good market clearing']

     Y_nondurable = Demand_dom_nondurable+EXPORT_nondurable;

     [name='other-durable good market clearing']

     Y_otherdurable = Demand_dom_otherdurable+EXPORT_otherdurable;

     [name='Durable good market clearing']

     Y_energydurable = Demand_dom_energydurable+EXPORT_energydurable;

     [name='Investment good market clearing']

     Y_capital = Demand_dom_capital+EXPORT_capital;
                             
     [name='Power generation sector value added']

     Y_power   =   p_el_h*(El_h)+p_el_f*(El_nondurable+El_otherdurable+El_energydurable+El_capital+El_recycled+El_virgin+El_sharing);

     [name='Power generation sector investments']

     Inv_k_energy  =   (eppsilon*alppha_k_powercapacities*Inv_k+(1-eppsilon)*(Inv_RDEN_EE+Inv_k_powercapacities));

    [name='Gross domestic product']

     GDP        =   w*(h_sharing*L_sharing+h_repair*L_repair+h_virgin*L_virgin+h_recycled*L_recycled+h_nondurable*L_nondurable+h_otherdurable*L_otherdurable+h_energydurable*L_energydurable+h_capital*L_capital)
                    +r_k*K
                    +r_ed*u_highuse*ED_highuse
                    +DIV_total
                    +t_c_reduced*p_repair*(1-repair_ed_bonus)*Inv_ed_repair
                    +t_c*(p_def_nondurable*X+p_def_energydurable*(Inv_ed_new_highuse+(omegga_lowcarbon*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+omegga_cautious*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)+(1-omegga_lowcarbon-omegga_cautious)*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained)))+p_def_otherdurable*((omegga_lowcarbon*Inv_od_lowcarbon+omegga_cautious*Inv_od_cautious+(1-omegga_lowcarbon-omegga_cautious)*Inv_od_constrained))
                    +p_sharing*ES_sharing+(p_el_h+t_el_h)*El_h+(p_nel_h+t_nel_h)*Nel_h)
                    +t_el_h*(El_h)+t_el_f*(El_nondurable+El_otherdurable+El_capital+El_energydurable+El_virgin+El_recycled+El_sharing)+t_nel_h*(Nel_h)+t_nel_f*(Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_capital+Nel_virgin+Nel_recycled+Nel_sharing)
                    +p_fg_row*(t_imports_capital*(IMP_capital)+t_imports_energydurable*(IMP_energydurable)+t_imports_nondurable*(IMP_nondurable)+t_imports_otherdurable*(IMP_otherdurable))
                    +margin_capital*p_fg_row*gamma_reexport_capital*EXPORT_capital+margin_nondurable*p_fg_row*gamma_reexport_nondurable*EXPORT_nondurable+margin_otherdurable*p_fg_row*gamma_reexport_otherdurable*EXPORT_otherdurable+margin_energydurable*p_fg_row*gamma_reexport_energydurable*EXPORT_energydurable
            ;

     [name='Dividends of the sectors of production']

     DIV_total   =   p_repair*Y_repair-w*(1-reduced_laborcosts)*h_repair*L_repair-r_k*K_repair
                    +DIV_sharing
                    +p_capital*Y_capital-w*h_capital*L_capital-r_k*K_f_capital-p_e_capital*E_capital-p_m_capital*M_capital
                    +p_nondurable*Y_nondurable-w*h_nondurable*L_nondurable-r_k*K_f_nondurable-p_e_nondurable*E_nondurable-p_m_nondurable*M_nondurable
                    +p_otherdurable*Y_otherdurable-w*h_otherdurable*L_otherdurable-r_k*K_f_otherdurable-p_e_otherdurable*E_otherdurable-p_m_otherdurable*M_otherdurable
                    +p_energydurable*Y_energydurable-w*h_energydurable*L_energydurable-r_k*K_f_energydurable-p_e_energydurable*E_energydurable-p_m_energydurable*M_energydurable
                    +p_virgin*Y_virgin-w*h_virgin*L_virgin-r_k*K_virgin-p_e_virgin*E_virgin-(t_m*gamma_virgin*(1-omegga_ind_recycled)+c_m*gamma_virgin+p_rawmaterials)*RM
                    +p_recycled*Y_recycled-w*h_recycled*L_recycled-r_k*K_recycled-p_e_recycled*E_recycled-(t_m*gamma_recycled*(1-omegga_ind_recycled)+c_m*gamma_recycled)*RW;

    DIV_capital     =   p_capital*Y_capital-w*h_capital*L_capital-r_k*K_f_capital-p_e_capital*E_capital-p_m_capital*M_capital;
    DIV_nondurable  =   p_nondurable*Y_nondurable-w*h_nondurable*L_nondurable-r_k*K_f_nondurable-p_e_nondurable*E_nondurable-p_m_nondurable*M_nondurable;
    DIV_otherdurable =   p_otherdurable*Y_otherdurable-w*h_otherdurable*L_otherdurable-r_k*K_f_otherdurable-p_e_otherdurable*E_otherdurable-p_m_otherdurable*M_otherdurable;
    DIV_energydurable     =   p_energydurable*Y_energydurable-w*h_energydurable*L_energydurable-r_k*K_f_energydurable-p_e_energydurable*E_energydurable-p_m_energydurable*M_energydurable;
    DIV_virgin      =   p_virgin*Y_virgin-w*h_virgin*L_virgin-r_k*K_virgin-p_e_virgin*E_virgin-(t_m*gamma_virgin*(1-omegga_ind_recycled)+c_m*gamma_virgin+p_rawmaterials)*RM;
    DIV_recycled    =   p_recycled*Y_recycled-w*h_recycled*L_recycled-r_k*K_recycled-p_e_recycled*E_recycled-(t_m*gamma_recycled*(1-omegga_ind_recycled)+c_m*gamma_recycled)*RW;
    DIV_sharing     =   p_sharing*Y_sharing - w*h_sharing*L_sharing - p_e_sharing*E_sharing - r_ed*u_highuse*ED_highuse;
    DIV_repair      =   p_repair*Y_repair-w*(1-reduced_laborcosts)*h_repair*L_repair-r_k*K_repair;

// AGGREGATION RULES ACROSS LIFESTYLES //

@#for variables in ["A_nel","Expenditures_LIFE","Inv_od","C","g_inv_ed","p_g_inv_ed","OD","X","ES","ES_home","ES_sharing","NES","alppha_ed_new","alppha_ed_repair","ED_lowuse", "deltta_energydurable_lowuse","Inv_ed_new_tild","Inv_ed_new","Inv_ed_repair"]

     @{variables}  =   omegga_lowcarbon*@{variables}_lowcarbon+omegga_cautious*@{variables}_cautious+(1-omegga_lowcarbon-omegga_cautious)*@{variables}_constrained;

@#endfor

@#for variables in ["E","El","Nel"]

     @{variables}_h  =   omegga_lowcarbon*@{variables}_lowcarbon+omegga_cautious*@{variables}_cautious+(1-omegga_lowcarbon-omegga_cautious)*@{variables}_constrained;

@#endfor

     h             =   L_repair*h_repair+L_sharing*h_sharing+L_capital*h_capital+L_energydurable*h_energydurable+L_nondurable*h_nondurable+L_otherdurable*h_otherdurable+L_virgin*h_virgin+L_recycled*h_recycled;

// CO2 EMISSIONS //

    [name='CO2 emissions of the economy except the incineration sector']

     CO2_economy      = El*emissions_el_WITCH+Nel*emissions_nel_WITCH;

    [name='CO2 emissions from the incineration sector'] %0.415 the emission coefficient. The rest are the share of MW and IW being incinerated

     CO2_incineration = (MW_l*0.8946+IW_l*0.9492)*0.415/1e+12; 

    [name='Total CO2 emissions']

     CO2              =   El*emissions_el_WITCH+Nel*emissions_nel_WITCH+CO2_incineration;

// PHYSICAL CONSTRAINTS //

      [name='Electricity flows']

      El	=   El_h+El_nondurable+El_otherdurable+El_energydurable+El_capital+El_sharing+El_recycled+El_virgin;

      [name='Fuel flows']

      Nel	=   Nel_h+Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_capital+Nel_sharing+Nel_recycled+Nel_virgin;
      
      [name='Total industrial and construction waste flows'] 

      IW    =   IW_r+IW_l;      

      IW_processedmat    =   gamma_virgin*RM;   

      IW_finalgoods = IW-IW_processedmat-gamma_recycled*RW;    

      [name='Total municipal waste flows']

      MW	=   MW_r+MW_l; 

      [name='Nondurable goods municipal waste flows']

      MW_nondurables = ((1-gamma_nondurable)*M_nondurable/Y_nondurable)*(Demand_dom_nondurable+material_int_nondurable*IMP_nondurable);

      [name='Other durable goods municipal waste flows']

      MW_otherdurables = M_stock_otherdurable*deltta_otherdurable_physical;

      [name='Energy-using durable goods municipal waste flows']

      MW_energydurables = M_stock_energydurable*(((1-omegga_repair_lowcarbon)*omegga_lowcarbon*deltta_energydurable_physical*(u_lowuse_lowcarbon^siggma_dep_lowuse)*ED_lowuse_lowcarbon+(1-omegga_repair_cautious)*omegga_cautious*deltta_energydurable_physical*(u_lowuse_cautious^siggma_dep_lowuse)*ED_lowuse_cautious+(1-omegga_repair_constrained)*omegga_constrained*deltta_energydurable_physical*(u_lowuse_constrained^siggma_dep_lowuse)*ED_lowuse_constrained)/(ED_lowuse+ED_highuse+ED_G))+M_stock_energydurable*deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))+M_stock_energydurable*deltta_energydurable_gov*(ED_G/(ED_lowuse+ED_highuse+ED_G)); %from the physical data the physical depreciation rate of durables is 0.085, while from the economic data it is 0.081. Since they are close to one another, to keep track of how u impacts deltta, we assume the physical rate to be equal to the economic rate.

      [name='Recyclable industrial and construction waste flows going to recycling facilities to be recycled']

      IW_r	=   omegga_ind_recycled*(M_stock_capital*deltta_capital_physical+gamma_nondurable*M_nondurable+gamma_otherdurable*M_otherdurable+gamma_energydurable*M_energydurable+gamma_capital*M_capital+gamma_virgin*RM);  

      [name='Landfill/Incinerated industrial and construction waste flows']

      IW_l	=   (1-omegga_ind_recycled)*(M_stock_capital*deltta_capital_physical+gamma_nondurable*M_nondurable+gamma_otherdurable*M_otherdurable+gamma_energydurable*M_energydurable+gamma_capital*M_capital+gamma_virgin*RM)+gamma_recycled*RW;    

      [name='Recyclable municipal waste flows going to recycling facilities to be recycled'] 

      MW_r	=   omegga_mun_recycled*(MW_energydurables+MW_otherdurables+MW_nondurables);   

      [name='Landfill/Incinerated municipal waste flows']

      MW_l	=   (1-omegga_mun_recycled)*(MW_energydurables+MW_otherdurables+MW_nondurables);                 

      [name='Total waste going to final sink']

      Finalsink_total = MW_l+IW_l+MW_r+IW_r-RW; 

      [name='other-durable good material stock accumulation'] 

      (1+g+n+g*n)*M_stock_otherdurable(+1)   =   M_stock_otherdurable*(1-deltta_otherdurable_physical-Error_stock_otherdurable)+Gross_additions_stock_otherdurable;             

      [name='Other durable good gross additions to the stock']

      Gross_additions_stock_otherdurable     =  ((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*(Demand_dom_otherdurable+material_int_otherdurable*IMP_otherdurable);

      [name='Other durable good net additions to the stock']

      Net_additions_stock_otherdurable       =  Gross_additions_stock_otherdurable-M_stock_otherdurable*deltta_otherdurable_physical;

      [name='Energy-using durable good good material stock accumulation']   
      % The effective depreciation rate is (1-omegga_repair)*deltta_energydurable. This ensures that repaired units simply don’t count as “new material” but do extend the life of the existing stock. 
      % Since repair gives another life to exactly the same tonnage that was about to be scrapped in CIRCEE, CIRCEE treats repairs as offsetting a share of that period’s physical retirements
      % Total investment = total scrappage, so the share of repair in total investment exactly equals the share of saved retirements.

      (1+g+n+g*n)*M_stock_energydurable(+1)   =   M_stock_energydurable*(1-(((1-omegga_repair_lowcarbon)*omegga_lowcarbon*deltta_energydurable_physical*(u_lowuse_lowcarbon^siggma_dep_lowuse)*ED_lowuse_lowcarbon+(1-omegga_repair_cautious)*omegga_cautious*deltta_energydurable_physical*(u_lowuse_cautious^siggma_dep_lowuse)*ED_lowuse_cautious+(1-omegga_repair_constrained)*omegga_constrained*deltta_energydurable_physical*(u_lowuse_constrained^siggma_dep_lowuse)*ED_lowuse_constrained)/(ED_lowuse+ED_highuse+ED_G))
                                                -deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))-deltta_energydurable_gov*((ED_G)/(ED_lowuse+ED_highuse+ED_G)))+Gross_additions_stock_energydurable+Error_stock_energydurable;   

      [name='Energy-using durable good net additions to the stock']

      Net_additions_stock_energydurable       =  Gross_additions_stock_energydurable-M_stock_energydurable*(((1-omegga_repair_lowcarbon)*omegga_lowcarbon*deltta_energydurable_physical*(u_lowuse_lowcarbon^siggma_dep_lowuse)*ED_lowuse_lowcarbon+(1-omegga_repair_cautious)*omegga_cautious*deltta_energydurable_physical*(u_lowuse_cautious^siggma_dep_lowuse)*ED_lowuse_cautious+(1-omegga_repair_constrained)*omegga_constrained*deltta_energydurable_physical*(u_lowuse_constrained^siggma_dep_lowuse)*ED_lowuse_constrained)/(ED_lowuse+ED_highuse+ED_G))-M_stock_energydurable*deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))-M_stock_energydurable*deltta_energydurable_gov*((ED_G)/(ED_lowuse+ED_highuse+ED_G));

      [name='Energy-using durable good gross additions to the stock']

      Gross_additions_stock_energydurable     =   ((1-gamma_energydurable)*M_energydurable/Y_energydurable)*(Demand_dom_energydurable+material_int_energydurable*IMP_energydurable);

      [name='Capital good material stock accumulation'] 

      (1+g+n+g*n)*M_stock_capital(+1)   =   M_stock_capital*(1-deltta_capital_physical)+Gross_additions_stock_capital+Error_stock_capital;   

      [name='Capital good gross additions to the material stock'] 

      Gross_additions_stock_capital     =   ((1-gamma_capital)*M_capital/Y_capital)*(Demand_dom_capital+material_int_capital*IMP_capital);

      [name='Capital good net additions to the material stock'] 

      Net_additions_stock_capital       =   ((1-gamma_capital)*M_capital/Y_capital)*(Demand_dom_capital+material_int_capital*IMP_capital)-M_stock_capital*deltta_capital_physical;

      [name='Gross additions to the stock']
      
      Gross_additions_stock             =   Gross_additions_stock_otherdurable+Gross_additions_stock_energydurable+Gross_additions_stock_capital;

      [name='Material balance - Production side'] 

      Material_balance          =   ((1-gamma_nondurable)*M_nondurable/Y_nondurable)*(Demand_dom_nondurable+EXPORT_nondurable)
                                    +((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*(Demand_dom_otherdurable+EXPORT_otherdurable)
                                    +((1-gamma_energydurable)*M_energydurable/Y_energydurable)*(Demand_dom_energydurable+EXPORT_energydurable)
                                    +((1-gamma_capital)*M_capital/Y_capital)*(Demand_dom_capital+EXPORT_capital)
                                    +gamma_nondurable*M_nondurable+gamma_otherdurable*M_otherdurable+gamma_energydurable*M_energydurable+gamma_capital*M_capital
                                    +EXPORT_recycled+EXPORT_virgin
                                    -(IMP_recycled+IMP_virgin+((1-gamma_virgin)*RM)+((1-gamma_recycled)*RW));

      [name='Naterial balance - Economy-wide (EW-MFA identity)']
    
      Material_balance_EWMFA    =   (Domestic_Extraction+IMP_raw+IMP_materials+IMP_goods_mateq)
                                    -(EXP_materials+EXPORT_goods_mateq)-((1+g+n+g*n)*M_stock(+1)-M_stock)-Finalsink_total+(Error_stock_capital-M_stock_otherdurable*Error_stock_otherdurable+Error_stock_energydurable);

      [name='Stock balance check']

      Material_balance_stocks   =   Gross_additions_stock-(M_stock_capital*deltta_capital_physical+M_stock_otherdurable*deltta_otherdurable_physical
                                    +MW_energydurables)-((1+g+n+g*n)*M_stock(+1)-M_stock)+(Error_stock_capital-M_stock_otherdurable*Error_stock_otherdurable+Error_stock_energydurable);

      [name='Total material stock'] 

      M_stock   =   M_stock_energydurable+M_stock_otherdurable+M_stock_capital;

      [name='Municipalities non-recyclable waste physical accumulation']

      (1+g+n+g*n)*NR_stock_mu(+1)   =   NR_stock_mu*(1-decay_mu)+MW_l; 

      [name='Production activities non-recyclable waste physical accumulation']

      (1+g+n+g*n)*NR_stock_indu(+1) =   NR_stock_indu*(1-decay_indu)+IW_l; 

      [name='Imports of refined materials']

      IMP_materials = IMP_recycled+IMP_virgin; 

      [name='Exports of materials']

      EXP_materials = EXPORT_recycled+EXPORT_virgin;

      [name='Imports of raw materials']

      IMP_raw = RM*(((6.6053092E-01*1+3.1742072E-02*0.48)*(M_virgin_energydurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(2.0252225E-01*1+6.9488153E-02*0.48)*(M_virgin_otherdurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(3.6768029E-01*1+6.6377722E-02*0.48)*(M_virgin_capital/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+1.8454667E-02*0.48*(M_virgin_nondurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital)))); 

      [name='Imports of goods in material equivalent']

      IMP_goods_mateq = ((1-gamma_nondurable)*M_nondurable/Y_nondurable)*(material_int_nondurable*IMP_nondurable)
                        +((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*(material_int_otherdurable*IMP_otherdurable)
                        +((1-gamma_energydurable)*M_energydurable/Y_energydurable)*(material_int_energydurable*IMP_energydurable)
                        +((1-gamma_capital)*M_capital/Y_capital)*(material_int_capital*IMP_capital);

      [name='Exports of goods in material equivalent']

      EXPORT_goods_mateq = ((1-gamma_nondurable)*M_nondurable/Y_nondurable)*EXPORT_nondurable
                           +((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*EXPORT_otherdurable
                           +((1-gamma_energydurable)*M_energydurable/Y_energydurable)*EXPORT_energydurable
                           +((1-gamma_capital)*M_capital/Y_capital)*EXPORT_capital;

      [name='Domestic material input']

      DMI = Domestic_Extraction+IMP_raw+IMP_materials+IMP_goods_mateq;

      [name='Domestic material consumption']

      DMC = DMI-EXP_materials-((1-gamma_nondurable)*M_nondurable/Y_nondurable)*EXPORT_nondurable
            -((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*EXPORT_otherdurable
            -((1-gamma_energydurable)*M_energydurable/Y_energydurable)*EXPORT_energydurable
            -((1-gamma_capital)*M_capital/Y_capital)*EXPORT_capital;

@#include "Footprints.m"

end;

@#include "CIRCEE_steadystatemodel.m"

@#include "CIRCEE_shocks.m"

perfect_foresight_with_expectation_errors_setup(periods=82);
perfect_foresight_with_expectation_errors_solver;

model_diagnostics;