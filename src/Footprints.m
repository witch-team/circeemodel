// FOOTPRINTS //

    %Total material sector energy */

    [name='Total virgin material sector energy']
    E_virgin_tot        =   El_virgin+Nel_virgin;

    [name='Total recycled material sector energy']
    E_recycled_tot      =   El_recycled+Nel_recycled;

    [name='Total virgin material inputs across all final goods sectors']
    M_virgin_tot        =  M_virgin_nondurable+M_virgin_otherdurable+M_virgin_energydurable+M_virgin_capital;

    [name='Total recycled material inputs across all final goods sectors']
    M_recycled_tot      =  M_recycled_nondurable+M_recycled_otherdurable+M_recycled_energydurable+M_recycled_capital;

    %Investment split key for energy-using good sector

    [name='Total energy-using good investment across household owned and B2C channels']
    Inv_ed_total        =  omegga_lowcarbon*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+omegga_cautious*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)
                          +(1-omegga_lowcarbon-omegga_cautious)*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained)+Inv_ed_new_highuse+Inv_ed_G;

    [name='Share of energy-using good production going to household owned lowuse channel']
    share_energydurable_lowuse_prod    =   (Inv_ed_total-Inv_ed_new_highuse)/Inv_ed_total;

    [name='Share of energy-using good production going to B2C highuse channel']
    share_energydurable_highuse_prod   =   Inv_ed_new_highuse/Inv_ed_total;

    %Upstream material energy attributed to each final consumption goods sector */

    [name='Upstream material energy attributed to nondurable goods sector']
    E_upstream_nondurable   =  E_virgin_tot*(M_virgin_nondurable/M_virgin_tot)+E_recycled_tot*(M_recycled_nondurable/M_recycled_tot);

    [name='Upstream material energy attributed to otherdurable goods sector']
    E_upstream_otherdurable =  E_virgin_tot*(M_virgin_otherdurable/M_virgin_tot)+E_recycled_tot*(M_recycled_otherdurable/M_recycled_tot);

    [name='Upstream material energy attributed to energy-using good lowuse channel']
    E_upstream_energydurable_lowuse = (E_virgin_tot*(M_virgin_energydurable/M_virgin_tot)+E_recycled_tot*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_lowuse_prod;

    [name='Upstream material energy attributed to energy-using good highuse B2C channel']
    E_upstream_energydurable_highuse = (E_virgin_tot*(M_virgin_energydurable/M_virgin_tot)+E_recycled_tot*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_highuse_prod;

    [name='Upstream material energy attributed to total energy-using goods']

    E_upstream_energydurable   =  E_virgin_tot*(M_virgin_energydurable/M_virgin_tot)+E_recycled_tot*(M_recycled_energydurable/M_recycled_tot);

    [name='Upstream material energy attributed to capital sector']

    E_upstream_capital          =  E_virgin_tot*(M_virgin_capital/M_virgin_tot)+E_recycled_tot*(M_recycled_capital/M_recycled_tot);

    %Total production phase energy per final consumption sector
    %Direct manufacturing energy + upstream material processing energy

    [name='Upstream and production phase energy of nondurable goods sector']
    E_prod_nondurable           = (El_nondurable+Nel_nondurable)+E_upstream_nondurable;

    [name='Upstream and production phase energy of otherdurable goods sector']
    E_prod_otherdurable         = (El_otherdurable+Nel_otherdurable)+E_upstream_otherdurable;

    [name='Upstream and production phase energy of energy-using good lowuse channel']
    E_prod_energydurable_lowuse = (El_energydurable+Nel_energydurable)*share_energydurable_lowuse_prod+E_upstream_energydurable_lowuse;

    [name='Upstream and production phase energy of energy-using good highuse B2C channel']
    E_prod_energydurable_highuse = (El_energydurable+Nel_energydurable)*share_energydurable_highuse_prod+E_upstream_energydurable_highuse;

    [name='Upstream and production phase energy of total energy-using good']

    E_prod_energydurable         = (El_energydurable+Nel_energydurable)+E_upstream_energydurable;

    [name='Upstream and production phase energy of B2C sharing services including highuse durable goods manufacturing']
    E_prod_sharing              =  El_sharing+Nel_sharing+E_prod_energydurable_highuse;

    [name='Direct production phase energy of capital sector']
    E_direct_capital            =   El_capital + Nel_capital;
                
    [name='Total production phase energy of capital sector']
    E_prod_capital              =   E_direct_capital + E_upstream_capital;

    [name='Total production phase energy across all attributed channels']
    E_prod_total                =  E_prod_nondurable+E_prod_otherdurable+E_prod_sharing+E_prod_capital+E_prod_energydurable_lowuse;

    %Production phase CO2 attributed to each final consumption sector

    [name='Capital used in the capital production chain']
    K_in_capital_chain = K_f_capital+ K_virgin*(M_virgin_capital/M_virgin_tot)+K_recycled*(M_recycled_capital/M_recycled_tot);

    [name='Production phase CO2 attributed to nondurable goods sector']
    CO2_prod_nondurable         =   (CO2_economy-El_h*emissions_el_WITCH-Nel_h*emissions_nel_WITCH)*(E_prod_nondurable/E_prod_total);

    [name='Production phase CO2 attributed to otherdurable goods sector']
    CO2_prod_otherdurable         =   (CO2_economy-El_h*emissions_el_WITCH-Nel_h*emissions_nel_WITCH)*(E_prod_otherdurable/E_prod_total);

    [name='Production phase CO2 attributed to household owned energy-using good lowuse goods']
    CO2_prod_energydurable         =   (CO2_economy-El_h*emissions_el_WITCH-Nel_h*emissions_nel_WITCH)*((E_prod_energydurable_lowuse)/E_prod_total);

    [name='Production phase CO2 attributed to B2C sharing services including highuse durable goods']
    CO2_prod_sharing         =   (CO2_economy-El_h*emissions_el_WITCH-Nel_h*emissions_nel_WITCH)*(E_prod_sharing/E_prod_total);

    [name='Production phase CO2 attributed to capital goods']
    CO2_prod_capital        =   (CO2_economy-El_h*emissions_el_WITCH-Nel_h*emissions_nel_WITCH)*(E_prod_capital/E_prod_total); 

    [name='Production phase CO2 from capital sector attributed to nondurable goods']
    CO2_prod_capital_nondurable = CO2_prod_capital*(K_f_nondurable+K_virgin*(M_virgin_nondurable/M_virgin_tot)+K_recycled*(M_recycled_nondurable/M_recycled_tot))/(K-K_in_capital_chain);

    [name='Production CO2 from capital sector attributed to otherdurable goods']
    CO2_prod_capital_otherdurable = CO2_prod_capital*(K_f_otherdurable+K_virgin*(M_virgin_otherdurable/M_virgin_tot)+K_recycled*(M_recycled_otherdurable/M_recycled_tot))/(K-K_in_capital_chain);

    [name='Production CO2 from capital sector attributed to household owned energy-using good lowuse goods']
    CO2_prod_capital_energydurable = CO2_prod_capital*(K_f_energydurable*share_energydurable_lowuse_prod+(K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_lowuse_prod)/(K-K_in_capital_chain);

    [name='Production phase CO2 from capital sector attributed to repair services']
    CO2_prod_capital_repair  =   CO2_prod_capital*(K_repair/(K-K_in_capital_chain));

    [name='Production CO2 from capital sector attributed to B2C sharing services including highuse durable goods']
    CO2_prod_capital_sharing = CO2_prod_capital*(K_f_energydurable*share_energydurable_highuse_prod+(K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_highuse_prod)/(K-K_in_capital_chain);

    %End-of-life CO2 from municipal waste incineration

    [name='End of life incineration CO2 from nondurable goods municipal waste']
    CO2_eol_nondurable  =   (1-omegga_mun_recycled)*(MW_nondurables*0.8946)*0.415/1e+12;

    [name='End of life incineration CO2 from otherdurable goods municipal waste']
    CO2_eol_otherdurable=   (1-omegga_mun_recycled)*(MW_otherdurables*0.8946)*0.415/1e+12;

    [name='End of life incineration CO2 from owned energy-using good lowuse municipal waste']
    CO2_eol_energydurable_lowuse   =   (1-omegga_mun_recycled)*M_stock_energydurable*(((1-omegga_repair_lowcarbon)*omegga_lowcarbon*deltta_energydurable_physical*(u_lowuse_lowcarbon^siggma_dep_lowuse)*ED_lowuse_lowcarbon+(1-omegga_repair_cautious)*omegga_cautious*deltta_energydurable_physical*(u_lowuse_cautious^siggma_dep_lowuse)*ED_lowuse_cautious+(1-omegga_repair_constrained)*omegga_constrained*deltta_energydurable_physical*(u_lowuse_constrained^siggma_dep_lowuse)*ED_lowuse_constrained)/(ED_lowuse+ED_highuse+ED_G))*0.8946*(0.415/1e+12);

    [name='End of life incineration CO2 from B2C energy-using good highuse municipal waste']
    CO2_eol_energydurable_highuse  =   (1-omegga_mun_recycled)*M_stock_energydurable*deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))*0.8946*(0.415/1e+12);

    %Industrial waste incineration CO2 attributable to final consumption goods production

    [name='Industrial waste incineration CO2 attributable to nondurable goods production']
    CO2_IW_nondurable   =   (((gamma_nondurable*M_nondurable+gamma_virgin*RM*(M_virgin_nondurable/M_virgin_tot))*(1-omegga_ind_recycled)+gamma_recycled*RW*(M_recycled_nondurable/M_recycled_tot))*0.9492)*(0.415/1e+12)+CO2_IW_capital*(K_f_nondurable+K_virgin*(M_virgin_nondurable/M_virgin_tot)+K_recycled*(M_recycled_nondurable/M_recycled_tot))/(K-K_in_capital_chain);

    [name='Industrial waste incineration CO2 attributable to otherdurable goods production']
    CO2_IW_otherdurable =   (((gamma_otherdurable*M_otherdurable+gamma_virgin*RM*(M_virgin_otherdurable/M_virgin_tot))*(1-omegga_ind_recycled)+gamma_recycled*RW*(M_recycled_otherdurable/M_recycled_tot))*0.9492)*(0.415/1e+12)+CO2_IW_capital*(K_f_otherdurable+K_virgin*(M_virgin_otherdurable/M_virgin_tot)+K_recycled*(M_recycled_otherdurable/M_recycled_tot))/(K-K_in_capital_chain);

    [name='Industrial waste incineration CO2 from capital sector production']
    CO2_IW_capital = (((gamma_capital*M_capital+M_stock_capital*deltta_capital_physical+gamma_virgin*RM*(M_virgin_capital/M_virgin_tot))*(1-omegga_ind_recycled)+gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))*0.9492)*(0.415/1e+12);

    [name='Industrial waste incineration CO2 attributable to lowuse energy using goods production and repaired lowuse energy using goods']
    CO2_IW_energydurable           = (((gamma_energydurable*M_energydurable+gamma_virgin*RM*(M_virgin_energydurable/M_virgin_tot))*(1-omegga_ind_recycled)+gamma_recycled*RW*(M_recycled_energydurable/M_recycled_tot))*0.9492)*(0.415/1e+12)*share_energydurable_lowuse_prod+CO2_IW_capital*((K_f_energydurable+K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_lowuse_prod)/(K-K_in_capital_chain);

    [name='Industrial waste incineration CO2 attributable to energy-using good highuse B2C production']
    CO2_IW_sharing           = (((gamma_energydurable*M_energydurable+gamma_virgin*RM*(M_virgin_energydurable/M_virgin_tot))*(1-omegga_ind_recycled)+gamma_recycled*RW*(M_recycled_energydurable/M_recycled_tot))*0.9492)*(0.415/1e+12)*share_energydurable_highuse_prod+CO2_IW_capital*((K_f_energydurable+K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_highuse_prod)/(K-K_in_capital_chain);

    [name='Industrial waste incineration CO2 attributable to repair sector']

    CO2_IW_repair       = CO2_IW_capital*(K_repair/(K-K_in_capital_chain));

    %Household-level footprints

    omegga_constrained= 1-omegga_lowcarbon-omegga_cautious;

@#for h in LIFESTYLES

    [name='@{h} household nondurable share of total nondurable demand including government']
    share_nondurable_@{h}       =   omegga_@{h}*X_@{h}/(X+X_G);

    [name='@{h} household share of otherdurables']
    share_otherdurable_@{h}       =   omegga_@{h}*Inv_od_@{h}/(Inv_od+Inv_od_G);

    [name='@{h} household share of newly produced energy using goods expenses']
    share_energydurable_new_@{h}   =   omegga_@{h}*(Inv_ed_new_tild_@{h}+Inv_ed_new_@{h})/(Inv_ed_total);

    [name='@{h} household share of B2C energy services']
    share_sharing_@{h}       =   omegga_@{h}*ES_sharing_@{h}/ES_sharing;

    [name='@{h} household share of repair services']
    share_repair_@{h}    =   omegga_@{h}*Inv_ed_repair_@{h}/Inv_ed_repair;

    [name='@{h} household upstream and production phase carbon footprint of repair services']
    CF_prod_repair_@{h}  =   CO2_prod_capital_repair*share_repair_@{h};

    [name='@{h} household upstream and production phase carbon footprint nondurables']
    CF_prod_nondurable_@{h}     =   (CO2_prod_nondurable+CO2_prod_capital_nondurable)*share_nondurable_@{h}*(Demand_dom_nondurable/(Demand_dom_nondurable+EXPORT_nondurable));

    [name='@{h} household upstream and production phase carbon footprint otherdurables']
    CF_prod_otherdurable_@{h}     =   (CO2_prod_otherdurable+CO2_prod_capital_otherdurable)*share_otherdurable_@{h}*(Demand_dom_otherdurable/(Demand_dom_otherdurable+EXPORT_otherdurable));
    
    [name='@{h} household upstream and production phase carbon footprint owned energy using goods']
    CF_prod_energydurable_@{h}     =   (CO2_prod_energydurable*share_energydurable_new_@{h}+CO2_prod_capital_energydurable*share_energydurable_new_@{h})*(Demand_dom_energydurable/(Demand_dom_energydurable+EXPORT_energydurable));

    [name='@{h} household upstream and production phase carbon footprint B2C services']
    CF_prod_sharing_@{h}     =   (CO2_prod_sharing+CO2_prod_capital_sharing)*share_sharing_@{h}*(Demand_dom_energydurable/(Demand_dom_energydurable+EXPORT_energydurable));

    [name='@{h} household end of life carbon footprint nondurables']
    CF_eol_nondurable_@{h}      =   CO2_eol_nondurable*share_nondurable_@{h};

    [name='@{h} household end of life carbon footprint otherdurables']
    CF_eol_otherdurable_@{h}      =   CO2_eol_otherdurable*omegga_@{h}*(OD_@{h}/(OD+OD_G));

    [name='@{h} household end of life carbon footprint owned energy using goods']
    CF_eol_energydurable_@{h}      =   CO2_eol_energydurable_lowuse*omegga_@{h}*((1-omegga_repair_@{h})*deltta_energydurable_physical*(u_lowuse_@{h}^siggma_dep_lowuse)*ED_lowuse_@{h}/(omegga_lowcarbon*(1-omegga_repair_lowcarbon)*deltta_energydurable_physical*(u_lowuse_lowcarbon^siggma_dep_lowuse)*ED_lowuse_lowcarbon+omegga_cautious*(1-omegga_repair_cautious)*deltta_energydurable_physical*(u_lowuse_cautious^siggma_dep_lowuse)*ED_lowuse_cautious+omegga_constrained*(1-omegga_repair_constrained)*deltta_energydurable_physical*(u_lowuse_constrained^siggma_dep_lowuse)*ED_lowuse_constrained));

    [name='@{h} household end of life carbon footprint B2C energy using goods']
    CF_eol_sharing_@{h}      =   (1-omegga_mun_recycled)*M_stock_energydurable*deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))*omegga_@{h}*ES_sharing_@{h}/ES_sharing*0.8946*(0.415/1e+12);

    [name='@{h} household industrial waste incineration carbon footprint nondurables']
    CF_IW_nondurable_@{h}       =   CO2_IW_nondurable*share_nondurable_@{h}*(Demand_dom_nondurable/(Demand_dom_nondurable+EXPORT_nondurable));

    [name='@{h} household industrial waste incineration carbon footprint otherdurables']
    CF_IW_otherdurable_@{h}       =   CO2_IW_otherdurable*share_otherdurable_@{h}*(Demand_dom_otherdurable/(Demand_dom_otherdurable+EXPORT_otherdurable));

    [name='@{h} household industrial waste incineration carbon footprint owned energy using goods']
    CF_IW_energydurable_@{h}       =   CO2_IW_energydurable*share_energydurable_new_@{h}*(Demand_dom_energydurable/(Demand_dom_energydurable+EXPORT_energydurable));

    [name='@{h} household industrial waste incineration carbon footprint B2C energy using goods']
    CF_IW_sharing_@{h}       =   CO2_IW_sharing*share_sharing_@{h}*(Demand_dom_energydurable/(Demand_dom_energydurable+EXPORT_energydurable));

    [name='@{h} household industrial waste incineration carbon footprint of repair services']
    CF_IW_repair_@{h}   = CO2_IW_repair*share_repair_@{h};

    [name='@{h} household total lifecycle carbon footprint']
    CF_@{h}             =  CF_prod_nondurable_@{h}+CF_eol_nondurable_@{h}+CF_IW_nondurable_@{h}
                          +CF_prod_otherdurable_@{h}+CF_eol_otherdurable_@{h}+CF_IW_otherdurable_@{h}
                          +CF_prod_energydurable_@{h}+CF_eol_energydurable_@{h}+CF_IW_energydurable_@{h}
                          +CF_prod_sharing_@{h}+CF_eol_sharing_@{h}+CF_IW_sharing_@{h}
                          +CF_prod_repair_@{h}+CF_IW_repair_@{h}
                          +omegga_@{h}*(El_@{h}*emissions_el_WITCH+Nel_@{h}*emissions_nel_WITCH);

    [name='@{h} household waste embodied in their consumption of nondurables']
    WF_nondurable_@{h}  =   (MW_nondurables
                            +((gamma_nondurable*M_nondurable+gamma_virgin*RM*(M_virgin_nondurable/M_virgin_tot)
                            +gamma_recycled*RW*(M_recycled_nondurable/M_recycled_tot))/Y_nondurable)
                            *(Demand_dom_nondurable+material_int_nondurable*IMP_nondurable)
                            +(gamma_capital*M_capital+M_stock_capital*deltta_capital_physical
                            +gamma_virgin*RM*(M_virgin_capital/M_virgin_tot)
                            +gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))
                            *((K_f_nondurable
                            +K_virgin*(M_virgin_nondurable/M_virgin_tot)
                            +K_recycled*(M_recycled_nondurable/M_recycled_tot))/(K-K_in_capital_chain))
                            *(Demand_dom_capital/Y_capital))*share_nondurable_@{h};

    [name='@{h} household waste embodied in their consumption of otherdurables']
    WF_otherdurable_@{h} =   (MW_otherdurables)*omegga_@{h}*(OD_@{h}/(OD+OD_G))
                            +(((gamma_otherdurable*M_otherdurable+gamma_virgin*RM*(M_virgin_otherdurable/M_virgin_tot)
                            +gamma_recycled*RW*(M_recycled_otherdurable/M_recycled_tot))/Y_otherdurable)
                            *(Demand_dom_otherdurable+material_int_otherdurable*IMP_otherdurable)
                            +(gamma_capital*M_capital+M_stock_capital*deltta_capital_physical
                            +gamma_virgin*RM*(M_virgin_capital/M_virgin_tot)
                            +gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))
                            *((K_f_otherdurable
                            +K_virgin*(M_virgin_otherdurable/M_virgin_tot)
                            +K_recycled*(M_recycled_otherdurable/M_recycled_tot))/(K-K_in_capital_chain))
                            *(Demand_dom_capital/Y_capital))*share_otherdurable_@{h};

    [name='@{h} household waste embodied in their consumption of lowuse energy using goods']
    WF_energydurable_@{h} =   M_stock_energydurable*(1-omegga_repair_@{h})*deltta_energydurable_physical*(u_lowuse_@{h}^siggma_dep_lowuse)*omegga_@{h}*ED_lowuse_@{h}/(ED_lowuse+ED_highuse+ED_G)
                            +((gamma_energydurable*M_energydurable+gamma_virgin*RM*(M_virgin_energydurable/M_virgin_tot)
                            +gamma_recycled*RW*(M_recycled_energydurable/M_recycled_tot))/Y_energydurable)
                            *(Demand_dom_energydurable+material_int_energydurable*IMP_energydurable)
                            *share_energydurable_lowuse_prod*share_energydurable_new_@{h}
                            +(gamma_capital*M_capital+M_stock_capital*deltta_capital_physical
                            +gamma_virgin*RM*(M_virgin_capital/M_virgin_tot)
                            +gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))
                            *(((K_f_energydurable
                            +K_virgin*(M_virgin_energydurable/M_virgin_tot)
                            +K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_lowuse_prod)/(K-K_in_capital_chain))
                            *(Demand_dom_capital/Y_capital)
                            *share_energydurable_new_@{h};

    [name='@{h} household waste embodied in their consumption of sharing services']
    WF_sharing_@{h}     =   M_stock_energydurable*deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))*share_sharing_@{h}
                            +((gamma_energydurable*M_energydurable+gamma_virgin*RM*(M_virgin_energydurable/M_virgin_tot)
                            +gamma_recycled*RW*(M_recycled_energydurable/M_recycled_tot))/Y_energydurable)
                            *(Demand_dom_energydurable+material_int_energydurable*IMP_energydurable)
                            *share_energydurable_highuse_prod*share_sharing_@{h}
                            +(gamma_capital*M_capital+M_stock_capital*deltta_capital_physical
                            +gamma_virgin*RM*(M_virgin_capital/M_virgin_tot)
                            +gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))
                            *(((K_f_energydurable
                            +K_virgin*(M_virgin_energydurable/M_virgin_tot)
                            +K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_highuse_prod)/(K-K_in_capital_chain))
                            *(Demand_dom_capital/Y_capital)
                            *share_sharing_@{h};

    [name='@{h} household waste embodied in their consumption of repair services']
    WF_repair_@{h}      =   (gamma_capital*M_capital+M_stock_capital*deltta_capital_physical
                            +gamma_virgin*RM*(M_virgin_capital/M_virgin_tot)
                            +gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))
                            *(K_repair/(K-K_in_capital_chain))
                            *(Demand_dom_capital/Y_capital)
                            *share_repair_@{h};

    [name='@{h} household total waste footprint of their consumption basket']
    WF_@{h}             =   WF_nondurable_@{h}+WF_otherdurable_@{h}+WF_energydurable_@{h}+WF_sharing_@{h}+WF_repair_@{h};

    [name='@{h} household consumption-side material footprint (net of process losses)']
    MF_@{h}             =   (1-gamma_nondurable)*((M_virgin_nondurable+M_recycled_nondurable)*(Demand_dom_nondurable/Y_nondurable)
                            +(M_virgin_nondurable+M_recycled_nondurable)/Y_nondurable*material_int_nondurable*IMP_nondurable)*share_nondurable_@{h}
                            +(1-gamma_otherdurable)*((M_virgin_otherdurable+M_recycled_otherdurable)*(Demand_dom_otherdurable/Y_otherdurable)
                            +(M_virgin_otherdurable+M_recycled_otherdurable)/Y_otherdurable*material_int_otherdurable*IMP_otherdurable)*share_otherdurable_@{h}
                            +(1-gamma_energydurable)*((M_virgin_energydurable+M_recycled_energydurable)*(Demand_dom_energydurable/Y_energydurable)
                            +(M_virgin_energydurable+M_recycled_energydurable)/Y_energydurable*material_int_energydurable*IMP_energydurable)*share_energydurable_lowuse_prod*share_energydurable_new_@{h}
                            +(1-gamma_energydurable)*((M_virgin_energydurable+M_recycled_energydurable)*(Demand_dom_energydurable/Y_energydurable)
                            +(M_virgin_energydurable+M_recycled_energydurable)/Y_energydurable*material_int_energydurable*IMP_energydurable)*share_energydurable_highuse_prod*share_sharing_@{h}
                            +(1-gamma_capital)*((M_virgin_capital+M_recycled_capital)*(Demand_dom_capital/Y_capital)
                            +(M_virgin_capital+M_recycled_capital)/Y_capital*material_int_capital*IMP_capital)
                            *(((K_f_nondurable
                            +K_virgin*(M_virgin_nondurable/M_virgin_tot)
                            +K_recycled*(M_recycled_nondurable/M_recycled_tot))/(K-K_in_capital_chain))*share_nondurable_@{h}
                            +((K_f_otherdurable
                            +K_virgin*(M_virgin_otherdurable/M_virgin_tot)
                            +K_recycled*(M_recycled_otherdurable/M_recycled_tot))/(K-K_in_capital_chain))*share_otherdurable_@{h}
                            +(((K_f_energydurable
                            +K_virgin*(M_virgin_energydurable/M_virgin_tot)
                            +K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_lowuse_prod)/(K-K_in_capital_chain))*share_energydurable_new_@{h}
                            +(((K_f_energydurable
                            +K_virgin*(M_virgin_energydurable/M_virgin_tot)
                            +K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_highuse_prod)/(K-K_in_capital_chain))*share_sharing_@{h}
                            +(K_repair/(K-K_in_capital_chain))*share_repair_@{h});

@#endfor
