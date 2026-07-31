%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEADY-STATE COMPUTATION %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

steady_state_model;

    %------------------------------------------------------------------------------------------------------------
    % 1. Energy prices (from WITCH trajectories)
    %------------------------------------------------------------------------------------------------------------

    p_nel_f                             =   p_nel_f_2018*(1+g_nel_witch);
    p_nel_h                             =   p_nel_h_2018*(1+g_nel_witch);
    p_el_f                              =   p_el_f_2018*(1+g_el_witch);
    p_el_h                              =   p_el_h_2018*(1+g_el_witch);

    %------------------------------------------------------------------------------------------------------------
    % 2. Parameter aggregation (lifestyle-weighted averages) 
    %------------------------------------------------------------------------------------------------------------

    alppha_ed_new                       =   omegga_lowcarbon*alppha_ed_new_lowcarbon+omegga_cautious*alppha_ed_new_cautious+(1-omegga_lowcarbon-omegga_cautious)*alppha_ed_new_constrained; 
    alppha_ed_repair                    =   omegga_lowcarbon*alppha_ed_repair_lowcarbon+omegga_cautious*alppha_ed_repair_cautious+(1-omegga_lowcarbon-omegga_cautious)*alppha_ed_repair_constrained; 

    %------------------------------------------------------------------------------------------------------------
    % 3. Numeraire
    %------------------------------------------------------------------------------------------------------------
    p_capital                           =   p_capital_norm;

    %------------------------------------------------------------------------------------------------------------
    % 4. Price aggregators (CES)
    %------------------------------------------------------------------------------------------------------------

    p_def_capital                       =   (((share_domestic_capital)^siggma_imports)*((p_capital)^(1-siggma_imports))+((share_imp_capital)^siggma_imports)*((p_fg_row+p_fg_row*t_imports_capital)^(1-siggma_imports)))^(1/(1-siggma_imports));
    p_row_capital	                    =   ((share_row_dom_capital^siggma_exports)*((p_fg_row)^(1-siggma_exports))+((share_row_capital)^siggma_exports)*(((p_capital))^(1-siggma_exports)))^(1/(1-siggma_exports)); 
    @#for s in SECTORS 
        p_m_c_@{s}                      =   ((alppha_v_@{s}^(1-siggma_m))*(((p_virgin+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s})*(A_m_@{s}*(1-gamma_@{s})))^(-siggma_m))+((alppha_r_@{s})^(1-siggma_m))*(((p_recycled+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s})*(A_m_@{s}*(1-gamma_@{s})))^(-siggma_m)))^(1/(-siggma_m));
        p_m_@{s}	                    =   (p_m_c_@{s}^siggma_m)*((alppha_v_@{s}^(1-siggma_m))*(1/(A_m_@{s}*(1-gamma_@{s})))*(((p_virgin+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s})*(A_m_@{s}*(1-gamma_@{s})))^(1-siggma_m))+((alppha_r_@{s})^(1-siggma_m))*(1/(A_m_@{s}*(1-gamma_@{s})))*(((p_recycled+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s})*(A_m_@{s}*(1-gamma_@{s})))^(1-siggma_m)));
        p_e_@{s}	                    =   ((alppha_el_@{s}^(siggma_e_f))*(((p_el_f+t_el_f)/A_el_WITCH)^(1-siggma_e_f))+((alppha_nel_@{s})^(siggma_e_f))*(((p_nel_f+t_nel_f)/A_nel_WITCH)^(1-siggma_e_f)))^(1/(1-siggma_e_f));
    @#endfor

    @#for m in MATERIALS       
        p_e_@{m}	=   ((alppha_el_@{m}^(siggma_e_@{m}))*(((p_el_f+t_el_f)/A_el_WITCH)^(1-siggma_e_@{m}))+((alppha_nel_@{m})^(siggma_e_@{m}))*(((p_nel_f+t_nel_f)/A_nel_WITCH)^(1-siggma_e_@{m})))^(1/(1-siggma_e_@{m}));                                                
    @#endfor 
    %------------------------------------------------------------------------------------------------------------
    % 5. Investment decisions
    %------------------------------------------------------------------------------------------------------------

    q_k_lowcarbon                       =   p_def_capital;
    AC_ID_lowcarbon                     =   0;
    AC_IK_lowcarbon                     =   0;
    AC_IK_cautious                      =   0;
    Inv_k_lowcarbon_K_lowcarbon         =   (g+n+g*n+deltta_capital_fix);
    Inv_k_cautious_K_cautious           =   (g+n+g*n+deltta_capital_fix);
    Inv_k_K                             =   (g+n+g*n+deltta_capital_fix);
    r_k                                 =   ((1+g+n+g*n))*(q_k_lowcarbon*((1+g+n+g*n)^(siggma_ies)-betta)+betta*q_k_lowcarbon*deltta_capital_fix)/(betta*(1-t_k*(1-deltta_capital_fix)));

    %------------------------------------------------------------------------------------------------------------
    % 6. Production sectors
    %------------------------------------------------------------------------------------------------------------

        %------------------------------------------------------------------------------
        % 6.1. Capital goods
        %------------------------------------------------------------------------------

        Y_M_capital                         =   (((p_m_capital/(p_capital))/(alppha_m_capital))^(siggma_y));
        Z_Y_capital                         =   ((1-alppha_m_capital*(1/Y_M_capital)^((siggma_y-1)/siggma_y))/(alppha_z_capital))^(siggma_y/(siggma_y-1));
        Z_E_capital                         =   ((p_e_capital/(p_capital))/(alppha_z_capital*((1/Z_Y_capital)^(1/siggma_y))*alppha_e_capital))^(siggma_z);
        KL_Z_capital                        =   ((1-alppha_e_capital*((1/Z_E_capital)^((siggma_z-1)/siggma_z)))/alppha_kl_capital)^(siggma_z/(siggma_z-1));
        K_KL_capital                        =   (alppha_z_capital*((1/Z_Y_capital)^(1/siggma_y))*alppha_kl_capital*((1/KL_Z_capital)^(1/siggma_z))*alppha_k_capital*((p_capital)/r_k))^siggma_kl;
        L_KL_capital                        =   (1/h_capital)*((1-alppha_k_capital*((K_KL_capital)^((siggma_kl-1)/siggma_kl)))/(alppha_n_capital))^(siggma_kl/(siggma_kl-1));  
        w                                   =   (p_capital)*alppha_z_capital*((1/Z_Y_capital)^(1/siggma_y))*alppha_kl_capital*((1/KL_Z_capital)^(1/siggma_z))*alppha_n_capital*((1/(h_capital*L_KL_capital))^(1/siggma_kl));    
        Mvirgin_Ycapital                    =   ((1/(A_m_capital*(1-gamma_capital)))^siggma_m)*((1/alppha_v_capital)^(siggma_m-1))*(((p_m_c_capital)/(p_virgin+t_m*gamma_capital*(1-omegga_ind_recycled)+c_m*gamma_capital))^siggma_m)*(1/Y_M_capital);
        Mrecycled_Ycapital                  =   ((1/(A_m_capital*(1-gamma_capital)))^siggma_m)*((1/(alppha_r_capital))^(siggma_m-1))*(((p_m_c_capital)/(p_recycled+t_m*gamma_capital*(1-omegga_ind_recycled)+c_m*gamma_capital))^siggma_m)*(1/Y_M_capital);
        El_Y_capital                        =   ((A_el_WITCH*alppha_el_capital)^siggma_e_f)*((p_e_capital/((p_el_f+t_el_f)))^siggma_e_f)*(Z_Y_capital/Z_E_capital)*(1/A_el_WITCH);
        Nel_Y_capital                       =   ((A_nel_WITCH*alppha_nel_capital)^siggma_e_f)*((p_e_capital/((p_nel_f+t_nel_f)))^siggma_e_f)*(Z_Y_capital/Z_E_capital)*(1/A_nel_WITCH);

        %------------------------------------------------------------------------------
        % 6.2. Nondurable, otherdurable and energy-using durable goods
        %------------------------------------------------------------------------------

    @#for s in ["nondurable","otherdurable","energydurable"]        
        p_@{s}                              =   ((alppha_z_@{s}^siggma_y)*(((alppha_kl_@{s}^siggma_z)*((((alppha_k_@{s}^siggma_kl)*(r_k^(1-siggma_kl))+(alppha_n_@{s}^siggma_kl)*(w^(1-siggma_kl)))^(1/(1-siggma_kl)))^(1-siggma_z))+(alppha_e_@{s}^siggma_z)*((p_e_@{s})^(1-siggma_z)))^(1/(1-siggma_z)))^(1-siggma_y)+(alppha_m_@{s}^siggma_y)*((p_m_@{s})^(1-siggma_y)))^(1/(1-siggma_y));       
        Y_M_@{s}                            =   (((p_m_@{s}/(p_@{s}))/(alppha_m_@{s}))^(siggma_y));                                
        Z_Y_@{s}                            =   ((1-alppha_m_@{s}*(1/Y_M_@{s})^((siggma_y-1)/siggma_y))/(alppha_z_@{s}))^(siggma_y/(siggma_y-1));
        Z_E_@{s}                            =   ((p_e_@{s}/(p_@{s}))/(alppha_z_@{s}*((1/Z_Y_@{s})^(1/siggma_y))*alppha_e_@{s}))^(siggma_z);
        KL_Z_@{s}                           =   ((1-alppha_e_@{s}*((1/Z_E_@{s})^((siggma_z-1)/siggma_z)))/alppha_kl_@{s})^(siggma_z/(siggma_z-1));
        K_KL_@{s}                           =   (alppha_z_@{s}*((1/Z_Y_@{s})^(1/siggma_y))*alppha_kl_@{s}*((1/KL_Z_@{s})^(1/siggma_z))*alppha_k_@{s}*((p_@{s})/r_k))^siggma_kl;
        L_KL_@{s}                           =   (1/h_@{s})*(alppha_z_@{s}*((1/Z_Y_@{s})^(1/siggma_y))*alppha_kl_@{s}*((1/KL_Z_@{s})^(1/siggma_z))*alppha_n_@{s}*((p_@{s})/w))^siggma_kl;      
        Mvirgin_Y_@{s}                      =   ((1/(A_m_@{s}*(1-gamma_@{s})))^siggma_m)*((1/alppha_v_@{s})^(siggma_m-1))*(((p_m_c_@{s})/(p_virgin+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s}))^siggma_m)*(1/Y_M_@{s});
        Mrecycled_Y_@{s}                    =   ((1/(A_m_@{s}*(1-gamma_@{s})))^siggma_m)*((1/(alppha_r_@{s}))^(siggma_m-1))*(((p_m_c_@{s})/(p_recycled+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s}))^siggma_m)*(1/Y_M_@{s});
        El_Y_@{s}                           =   ((A_el_WITCH)^siggma_e_f)*((alppha_el_@{s})^(siggma_e_f))*((p_e_@{s}/((p_el_f+t_el_f)))^siggma_e_f)*(Z_Y_@{s}/Z_E_@{s})*(1/A_el_WITCH);
        Nel_Y_@{s}                          =   ((A_nel_WITCH)^siggma_e_f)*(((alppha_nel_@{s}))^(siggma_e_f))*((p_e_@{s}/((p_nel_f+t_nel_f)))^siggma_e_f)*(Z_Y_@{s}/Z_E_@{s})*(1/A_nel_WITCH);
        p_row_@{s}	                        =   ((share_row_dom_@{s}^siggma_exports)*((p_fg_row)^(1-siggma_exports))+((share_row_@{s})^siggma_exports)*(((p_@{s}))^(1-siggma_exports)))^(1/(1-siggma_exports));
        p_def_@{s}                          =   (((share_domestic_@{s})^siggma_imports)*((p_@{s})^(1-siggma_imports))+((share_imp_@{s})^siggma_imports)*((p_fg_row+p_fg_row*t_imports_@{s})^(1-siggma_imports)))^(1/(1-siggma_imports));        
    @#endfor

        %------------------------------------------------------------------------------
        % 6.3. Repair services
        %------------------------------------------------------------------------------

        p_repair	                        =   ((alppha_k_repair^siggma_kl)*(r_k^(1-siggma_kl))+(alppha_n_repair^siggma_kl)*(((1-reduced_laborcosts)*w)^(1-siggma_kl)))^(1/(1-siggma_kl)); 
        Yrepair_Lrepair                     =   h_repair*((1/alppha_n_repair)*(w*(1-reduced_laborcosts)/p_repair))^siggma_kl;
        Yrepair_Krepair                     =   ((1/alppha_k_repair)*(r_k/p_repair))^siggma_kl;   

        %------------------------------------------------------------------------------
        % 6.4. Primary and secondary materials
        %------------------------------------------------------------------------------

        Yvirgin_RM                          =  (((t_m*gamma_virgin*(1-omegga_ind_recycled)+c_m*gamma_virgin+p_rawmaterials)*(1/(alppha_rm*(p_virgin)*(1-gamma_virgin))))^siggma_y)*(1-gamma_virgin);
        Yrecycled_RW                        =  ((((t_m*gamma_recycled*(1-omegga_ind_recycled)+c_m*gamma_recycled))/((p_recycled)*alppha_rw*(1-gamma_recycled)))^siggma_y)*(1-gamma_recycled);   
        Z_Y_virgin                          =   ((1-alppha_rm*(((1-gamma_virgin)*(1/Yvirgin_RM))^((siggma_y-1)/siggma_y)))/alppha_z_virgin)^(siggma_y/(siggma_y-1));     
        Z_Y_recycled                        =   ((1-alppha_rw*(((1-gamma_recycled)*(1/Yrecycled_RW))^((siggma_y-1)/siggma_y)))/alppha_z_recycled)^(siggma_y/(siggma_y-1));    
    @#for m in MATERIALS       
        Z_E_@{m}                            =   (p_e_@{m}/((p_@{m})*alppha_e_@{m}*alppha_z_@{m}*((1/Z_Y_@{m})^(1/siggma_y))))^(siggma_z);
        KL_Z_@{m}                           =   ((1-alppha_e_@{m}*((1/Z_E_@{m})^((siggma_z-1)/siggma_z)))/alppha_kl_@{m})^(siggma_z/(siggma_z-1));
        El_Y_@{m}                           =   ((A_el_WITCH)^siggma_e_@{m})*((alppha_el_@{m})^(siggma_e_@{m}))*((p_e_@{m}/((p_el_f+t_el_f)))^siggma_e_@{m})*(Z_Y_@{m}/Z_E_@{m})*(1/A_el_WITCH);
        Nel_Y_@{m}                          =   ((A_nel_WITCH)^siggma_e_@{m})*(((alppha_nel_@{m}))^(siggma_e_@{m}))*((p_e_@{m}/((p_nel_f+t_nel_f)))^siggma_e_@{m})*(Z_Y_@{m}/Z_E_@{m})*(1/A_nel_WITCH);  
        K_KL_@{m}                           =   (alppha_z_@{m}*((1/Z_Y_@{m})^(1/siggma_y))*alppha_kl_@{m}*((1/KL_Z_@{m})^(1/siggma_z))*((p_@{m})/r_k)*alppha_k_@{m})^siggma_kl;
        L_KL_@{m}                           =   (1/h_@{m})*(alppha_z_@{m}*((1/Z_Y_@{m})^(1/siggma_y))*alppha_kl_@{m}*((1/KL_Z_@{m})^(1/siggma_z))*alppha_n_@{m}*(p_@{m})/w)^siggma_kl; 
    @#endfor   
 
    %------------------------------------------------------------------------------------------------------------
    % 7. Consumption decisions
    %------------------------------------------------------------------------------------------------------------
        %------------------------------------------------------------------------------
        % 7.1. Price aggregators
        %------------------------------------------------------------------------------

    @#for h in LIFESTYLES
        q_ed_newtild_@{h}                   =   p_def_energydurable*(1+t_c+epr_fee_energydurable);
        p_g_inv_ed_@{h}                     =   ((alppha_ed_new_@{h}^siggma_inv_ed)*((p_def_energydurable*(1+t_c+epr_fee_energydurable))^(1-siggma_inv_ed))+((alppha_ed_repair_@{h})^siggma_inv_ed)*((p_repair*(1+t_c_reduced)*(1-repair_ed_bonus))^(1-siggma_inv_ed)))^(1/(1-siggma_inv_ed));          
        q_ed_depreciated_@{h}               =   p_g_inv_ed_@{h};
        AC_ID_new_@{h}                      =   0;
        AC_ID_g_@{h}                        =   0;   
        A_nel_@{h}                          =   A_nel_WITCH; 
        p_e_h_@{h}	                        =   ((((alppha_el_@{h})^(siggma_e_h))*((p_el_h+t_el_h)*(1+t_c)/A_el_WITCH)^(1-siggma_e_h))+((alppha_nel_@{h})^(siggma_e_h))*(((p_nel_h+t_nel_h)*(1+t_c)/A_nel_@{h})^(1-siggma_e_h)))^(1/(1-siggma_e_h));     
    @#endfor
        p_g_inv_ed                          =   omegga_lowcarbon*p_g_inv_ed_lowcarbon+omegga_cautious*p_g_inv_ed_cautious+(1-omegga_lowcarbon-omegga_cautious)*p_g_inv_ed_constrained;               
        p_nd_ati                            =   p_def_nondurable*(1+t_c)+t_w*(1-omegga_mun_recycled)*(((1-gamma_nondurable)/Y_M_nondurable)*(((((share_domestic_nondurable)*(p_def_nondurable/p_nondurable))^siggma_imports))+material_int_nondurable*(((share_imp_nondurable)
                                                *(p_def_nondurable/(p_fg_row+p_fg_row*t_imports_nondurable)))^siggma_imports)));     
                                    
        %------------------------------------------------------------------------------
        % 7.2. Energy-using durable goods
        %------------------------------------------------------------------------------

    @#for h in LIFESTYLES
        u_lowuse_@{h}                       = (((((1+g+n+g*n)^siggma_ies)*(q_ed_newtild_@{h}/betta))-q_ed_newtild_@{h})*(1/((siggma_dep_lowuse-1)))*(1/q_ed_depreciated_@{h})*(1/deltta_energydurable_fix))^(1/siggma_dep_lowuse);
        deltta_energydurable_lowuse_@{h}    =   deltta_energydurable_fix*((u_lowuse_@{h})^siggma_dep_lowuse);    
        g_inv_ed_ED_@{h}                    =   deltta_energydurable_lowuse_@{h};
        uc_@{h}                             =   ((((1+g+n+g*n)^siggma_ies)*(q_ed_newtild_@{h}/betta))-(q_ed_newtild_@{h}-q_ed_depreciated_@{h}*deltta_energydurable_lowuse_@{h}));
        g_inv_Inv_ed_new_@{h}               =   ((p_def_energydurable*(1+t_c+epr_fee_energydurable))/(p_g_inv_ed_@{h}*alppha_ed_new_@{h}))^siggma_inv_ed;
        g_inv_Inv_ed_repair_@{h}            =   ((p_repair*(1+t_c_reduced)*(1-repair_ed_bonus))/(p_g_inv_ed_@{h}*(alppha_ed_repair_@{h})))^siggma_inv_ed;
        Inv_ed_new_tild_ED_@{h}             =   (g+n+g*n);
        Inv_ed_repair_ED_@{h}               =   (1/g_inv_Inv_ed_repair_@{h})*(g_inv_ed_ED_@{h});
        Inv_ed_new_ED_@{h}                  =   (1/g_inv_Inv_ed_new_@{h})*(g_inv_ed_ED_@{h}); 
        repair_ed_@{h}                      =   Inv_ed_repair_ED_@{h};     
    @#endfor
        deltta_energydurable_lowuse         = omegga_lowcarbon*deltta_energydurable_lowuse_lowcarbon+omegga_cautious*deltta_energydurable_lowuse_cautious+(1-omegga_lowcarbon-omegga_cautious)*deltta_energydurable_lowuse_constrained;
        g_inv_ed_EDlowuse                   =   deltta_energydurable_lowuse;
        g_inv_Inv_ed_new                    =   ((p_def_energydurable*(1+t_c+epr_fee_energydurable))/(p_g_inv_ed*alppha_ed_new))^siggma_inv_ed;
        g_inv_Inv_ed_repair                 =   (p_repair*(1+t_c_reduced)*(1-repair_ed_bonus)/(p_g_inv_ed*(alppha_ed_repair)))^siggma_inv_ed;
        Inv_ed_new_tild_EDlowuse            =   (g+n+g*n);
        Inv_ed_repair_EDlowuse              =   (1/g_inv_Inv_ed_repair)*(g_inv_ed_EDlowuse);
        A_nel                               =   omegga_lowcarbon*A_nel_lowcarbon+omegga_cautious*A_nel_cautious+(1-omegga_lowcarbon-omegga_cautious)*A_nel_constrained;     
        diff_A_nel                          =   A_nel-A_nel_WITCH;   

        %------------------------------------------------------------------------------
        % 7.3. B2C energy services
        %------------------------------------------------------------------------------
        p_e_sharing	                        =   (((alppha_el_sharing^(siggma_e_h))*((p_el_f+t_el_f)/A_el_WITCH)^(1-siggma_e_h))+((alppha_nel_sharing)^(siggma_e_h))*(((p_nel_f+t_nel_f)/A_nel)^(1-siggma_e_h)))^(1/(1-siggma_e_h));
        AC_ID_new_highuse                   =   0; 
        q_ed_newtild_highuse                =   p_def_energydurable*(1+t_c+epr_fee_energydurable);
        u_highuse                           =   ((1-(betta)*(1+g+n+g*n)^(-siggma_ies))/((siggma_dep-1)*betta*(1+g+n+g*n)^(-siggma_ies)*deltta_energydurable_fix))^(1/siggma_dep); 
        deltta_energydurable_highuse        =   deltta_energydurable_fix*(u_highuse^(siggma_dep));
        Inv_ed_new_ED_highuse               =   (deltta_energydurable_fix*(u_highuse^siggma_dep)+g+n+g*n); 
        r_ed                                =   (1/(1-t_k))*((q_ed_newtild_highuse/betta)*(1+g+n+g*n)^(siggma_ies)-q_ed_newtild_highuse*(1-deltta_energydurable_fix*(u_highuse^siggma_dep))+cost_maintenance*u_highuse)/u_highuse;
        p_sharing                           =   ((alppha_n_sharing^siggma_sharing)*((w)^(1-siggma_sharing))+(alppha_es_sharing^siggma_sharing)*(((alppha_e_sharing^siggma_home)*((p_e_sharing))^(1-siggma_home)+(alppha_ed_sharing^siggma_home)*((r_ed))^(1-siggma_home))^(1/(1-siggma_home)))^(1-siggma_sharing))^(1/((1-siggma_sharing)));
        Ysh_Lsh                             =   (((w/(p_sharing))*(1/alppha_n_sharing))^siggma_sharing)*h_sharing; 
        ESshf_Ysh                           =   ((1-(alppha_n_sharing*((h_sharing*(1/Ysh_Lsh)))^((siggma_sharing-1)/siggma_sharing)))/alppha_es_sharing)^(siggma_sharing/(siggma_sharing-1));
        ESshf_Esh                           =   (((p_e_sharing/(p_sharing))*(1/alppha_es_sharing)*(ESshf_Ysh^(1/siggma_sharing))*(1/((alppha_e_sharing))))^(siggma_home));
        El_ESshf                            =   ((A_el_WITCH)^siggma_e_h)*((alppha_el_sharing)^(siggma_e_h))*((p_e_sharing/((p_el_f+t_el_f)))^siggma_e_h)*(1/ESshf_Esh)*(1/A_el_WITCH);
        Nel_ESshf                           =   ((A_nel)^siggma_e_h)*(((alppha_nel_sharing))^(siggma_e_h))*((p_e_sharing/((p_nel_f+t_nel_f)))^siggma_e_h)*(1/ESshf_Esh)*(1/A_nel_WITCH);
        uDsharing_ESshf                     =   (((p_sharing)/r_ed)*alppha_es_sharing*((1/ESshf_Ysh)^(1/siggma_sharing))*alppha_ed_sharing)^siggma_home; 

        %------------------------------------------------------------------------------
        % 7.4. Other
        %------------------------------------------------------------------------------
        M_stock_otherdurable_OD             =   ((deltta_otherdurable_fix+g+n+g*n)/(deltta_otherdurable_physical+g+n+g*n+Error_stock_otherdurable))*(((1-gamma_otherdurable)/Y_M_otherdurable)*((((share_domestic_otherdurable)*(p_def_otherdurable/(p_otherdurable)))^siggma_imports)
                                                +material_int_otherdurable*(((share_imp_otherdurable)*(p_def_otherdurable/(p_fg_row+p_fg_row*t_imports_otherdurable)))^siggma_imports)));   
    @#for h in LIFESTYLES
        Inv_od_OD_@{h}                      =   (deltta_otherdurable_fix+n+g+n*g);   
        X_OD_@{h}                           =   ((alppha_x/(alppha_od))*((((1+g+n+g*n)^siggma_ies)*(((p_def_otherdurable*(1+t_c+epr_fee_otherdurable)))/p_nd_ati)/betta)
                                                +(((t_w*(1-omegga_mun_recycled)*(M_stock_otherdurable_OD*deltta_otherdurable_physical)))/p_nd_ati)
                                                -(((p_def_otherdurable*(1+t_c+epr_fee_otherdurable)))/p_nd_ati)*(1-deltta_otherdurable_fix)))^siggma_nes; 
        NES_X_@{h}                          =   (alppha_x+(alppha_od)*((1/X_OD_@{h})^((siggma_nes-1)/siggma_nes)))^(siggma_nes/(siggma_nes-1));
        Eh_ED_@{h}                          =   ((1/u_lowuse_@{h})^(siggma_home-1))*(((uc_@{h}/(p_e_h_@{h}))*((alppha_e)/alppha_ed))^siggma_home); 
        p_home_@{h}	                        =   (((alppha_ed^(siggma_home))*(uc_@{h}/u_lowuse_@{h})^(1-siggma_home))+((alppha_e)^(siggma_home)*(p_e_h_@{h})^(1-siggma_home)))^(1/(1-siggma_home));
        EShome_ESsharing_@{h}               =   ((p_sharing*(1+t_c)/p_home_@{h})*((alppha_home_@{h})/alppha_sharing_@{h}))^siggma_es_@{h}; 
        ES_EShome_@{h}                      =   ((alppha_home_@{h})+alppha_sharing_@{h}*(1/EShome_ESsharing_@{h})^((siggma_es_@{h}-1)/siggma_es_@{h}))^(siggma_es_@{h}/(siggma_es_@{h}-1)); 
        ESh_ED_@{h}                         =   (alppha_ed*((u_lowuse_@{h})^((siggma_home-1)/siggma_home))+(alppha_e)*((Eh_ED_@{h})^((siggma_home-1)/siggma_home)))^(siggma_home/(siggma_home-1));  
        X_ED_@{h}                           =   ((ES_EShome_@{h}^((1/siggma_c)-(1/siggma_es_@{h})))*(1/(alppha_home_@{h}))*(uc_@{h}/p_nd_ati)*alppha_x*(1/alppha_ed)*(1/(u_lowuse_@{h}^((siggma_home-1)/siggma_home)))
                                                *(ESh_ED_@{h}^((1/siggma_c)-(1/siggma_home)))*(alppha_nes/(alppha_es))*(NES_X_@{h}^((1/siggma_nes)-(1/siggma_c))))^siggma_c;
        Elh_ED_@{h}                         =   (((p_e_h_@{h}/((p_el_h+t_el_h)*(1+t_c)))*alppha_el_@{h}*A_el_WITCH)^siggma_e_h)*Eh_ED_@{h}/A_el_WITCH;
        ESsharing_ED_@{h}                   =   (((p_home_@{h}/(p_sharing*(1+t_c)))*(alppha_sharing_@{h}/(alppha_home_@{h})))^(siggma_es_@{h}))*ESh_ED_@{h};   
    @#endfor  
        Inv_od_OD                           =   (deltta_otherdurable_fix+n+g+n*g); 
        X_OD                                =   omegga_lowcarbon*X_OD_lowcarbon+omegga_cautious*X_OD_cautious+(1-omegga_lowcarbon-omegga_cautious)*X_OD_constrained;              
        Eh_EDlowuse                         =   omegga_lowcarbon*Eh_ED_lowcarbon+omegga_cautious*Eh_ED_cautious+(1-omegga_lowcarbon-omegga_cautious)*Eh_ED_constrained;
        Elh_EDlowuse                        =   omegga_lowcarbon*Elh_ED_lowcarbon+omegga_cautious*Elh_ED_cautious+(1-omegga_lowcarbon-omegga_cautious)*Elh_ED_constrained;
        X_EDlowuse                          =   omegga_lowcarbon*X_ED_lowcarbon+omegga_cautious*X_ED_cautious+(1-omegga_lowcarbon-omegga_cautious)*X_ED_constrained;
        ESsharing_EDlowuse                  =   omegga_lowcarbon*ESsharing_ED_lowcarbon+omegga_cautious*ESsharing_ED_cautious+(1-omegga_lowcarbon-omegga_cautious)*ESsharing_ED_constrained;
        omegga_lowcarbon_saver              =   omegga_lowcarbon/(omegga_lowcarbon+omegga_cautious);  
        EDsharing_EDlowuse                  =   (uDsharing_ESshf/u_highuse)*ESshf_Ysh*ESsharing_EDlowuse;                                
 
    %------------------------------------------------------------------------------------------------------------
    % 8. Market clearing
    %------------------------------------------------------------------------------------------------------------

    EDlowuse_Ydurable                       =   (1/(Inv_ed_new_tild_EDlowuse+((1/g_inv_Inv_ed_new)*g_inv_ed_EDlowuse)+(Inv_ed_new_ED_highuse)*EDsharing_EDlowuse))*((1-(((share_row_energydurable)*(p_row_energydurable/((p_energydurable))))^siggma_exports)*Demand_foreign_energydurable
                                                -((p_def_energydurable/(p_energydurable))-((p_fg_row+p_fg_row*t_imports_energydurable)/(p_energydurable))*(((share_imp_energydurable)*(p_def_energydurable/(p_fg_row+p_fg_row*t_imports_energydurable)))^siggma_imports))*g_c_energydurable)     
                                                /((p_def_energydurable/(p_energydurable))-((p_fg_row+p_fg_row*t_imports_energydurable)/(p_energydurable))*(((share_imp_energydurable)*(p_def_energydurable/(p_fg_row+p_fg_row*t_imports_energydurable)))^siggma_imports)));   
    OD_Yotherdurable                        =   (1/(deltta_otherdurable_fix+n+g+g*n))*((1-(((share_row_otherdurable)*(p_row_otherdurable/((p_otherdurable))))^siggma_exports)*Demand_foreign_otherdurable
                                                -((p_def_otherdurable/(p_otherdurable))-((p_fg_row+p_fg_row*t_imports_otherdurable)/(p_otherdurable))*(((share_imp_otherdurable)*(p_def_otherdurable/(p_fg_row+p_fg_row*t_imports_otherdurable)))^siggma_imports))*g_c_otherdurable)     
                                                /((p_def_otherdurable/(p_otherdurable))-((p_fg_row+p_fg_row*t_imports_otherdurable)/(p_otherdurable))*(((share_imp_otherdurable)*(p_def_otherdurable/(p_fg_row+p_fg_row*t_imports_otherdurable)))^siggma_imports)));                                                         
    X_Ynondurable                           =   ((1-(((share_row_nondurable)*(p_row_nondurable/((p_nondurable))))^siggma_exports)*Demand_foreign_nondurable
                                                -((p_def_nondurable/(p_nondurable))-((p_fg_row+p_fg_row*t_imports_nondurable)/(p_nondurable))*(((share_imp_nondurable)*(p_def_nondurable/(p_fg_row+p_fg_row*t_imports_nondurable)))^siggma_imports))*g_c_nondurable)     
                                                /((p_def_nondurable/(p_nondurable))-((p_fg_row+p_fg_row*t_imports_nondurable)/(p_nondurable))*(((share_imp_nondurable)*(p_def_nondurable/(p_fg_row+p_fg_row*t_imports_nondurable)))^siggma_imports)));                                            
    ESsharing_Ydurable                      =   ESsharing_EDlowuse*EDlowuse_Ydurable;
    Ysh_Ydurable                            =   ESsharing_Ydurable;    
    Ik_Ycapital                             =   (1-(((share_row_capital)*(p_row_capital/((p_capital))))^siggma_exports)*Demand_foreign_capital)/((p_def_capital/(p_capital))*(1+alppha_k_powercapacities)-(1+alppha_k_powercapacities)*((p_fg_row+p_fg_row*t_imports_capital)/(p_capital))
                                                *(((share_imp_capital)*(p_def_capital/(p_fg_row+p_fg_row*t_imports_capital)))^siggma_imports));                                           
    Ycapital_K                              =   ((p_def_capital/(p_capital))*(1+alppha_k_powercapacities)-(1+alppha_k_powercapacities)*((p_fg_row+p_fg_row*t_imports_capital)/(p_capital))*(((share_imp_capital)*(p_def_capital/(p_fg_row+p_fg_row*t_imports_capital)))^siggma_imports))*(Inv_k_K)/(1-(((share_row_capital)
                                                *(p_row_capital/((p_capital))))^siggma_exports)*Demand_foreign_capital);
    Kcapital_K                              =   K_KL_capital*KL_Z_capital*Z_Y_capital*Ycapital_K;     
    Ycapital_Ydurable                       =   (((p_def_capital/(p_capital))*(1+alppha_k_powercapacities)-(1+alppha_k_powercapacities)*((p_fg_row+p_fg_row*t_imports_capital)/(p_capital))*(((share_imp_capital)*(p_def_capital/(p_fg_row+p_fg_row*t_imports_capital)))^siggma_imports))/(1-(((share_row_capital)*(p_row_capital/((p_capital))))^siggma_exports)*Demand_foreign_capital))
                                                *((Inv_k_K))*((1+g+n+g*n))*(K_KL_energydurable*KL_Z_energydurable*Z_Y_energydurable
                                                +K_KL_otherdurable*KL_Z_otherdurable*Z_Y_otherdurable*(1/OD_Yotherdurable)*(1/X_OD)*X_EDlowuse*EDlowuse_Ydurable
                                                +K_KL_nondurable*KL_Z_nondurable*Z_Y_nondurable*(1/X_Ynondurable)*X_EDlowuse*EDlowuse_Ydurable
                                                +K_KL_virgin*KL_Z_virgin*Z_Y_virgin*(Mvirgin_Y_energydurable+Mvirgin_Y_otherdurable*(1/OD_Yotherdurable)*(1/X_OD)*X_EDlowuse*EDlowuse_Ydurable+Mvirgin_Y_nondurable*(1/X_Ynondurable)*X_EDlowuse*EDlowuse_Ydurable)*((share_domestic_virgin^siggma_imports)/(1-((share_row_virgin)^siggma_exports)*Demand_foreign_virgin))
                                                +K_KL_recycled*KL_Z_recycled*Z_Y_recycled*(Mrecycled_Y_energydurable+Mrecycled_Y_otherdurable*(1/OD_Yotherdurable)*(1/X_OD)*X_EDlowuse*EDlowuse_Ydurable+Mrecycled_Y_nondurable*(1/X_Ynondurable)*X_EDlowuse*EDlowuse_Ydurable)*((share_domestic_recycled^siggma_imports)/(1-((share_row_recycled)^siggma_exports)*Demand_foreign_recycled))
                                                +(1/Yrepair_Krepair)*(Inv_ed_repair_EDlowuse*EDlowuse_Ydurable))
                                                /
                                                (1-(((p_def_capital/(p_capital))*(1+alppha_k_powercapacities)-(1+alppha_k_powercapacities)*((p_fg_row+p_fg_row*t_imports_capital)/(p_capital))*(((share_imp_capital)*(p_def_capital/(p_fg_row+p_fg_row*t_imports_capital)))^siggma_imports))/(1-(((share_row_capital)*(p_row_capital/((p_capital))))^siggma_exports)*Demand_foreign_capital))
                                                *((Inv_k_K)*((1+g+n+g*n))*(K_KL_capital*KL_Z_capital*Z_Y_capital
                                                +K_KL_virgin*KL_Z_virgin*Z_Y_virgin*(Mvirgin_Ycapital)*((share_domestic_virgin^siggma_imports)/(1-((share_row_virgin)^siggma_exports)*Demand_foreign_virgin))
                                                +K_KL_recycled*KL_Z_recycled*Z_Y_recycled*(Mrecycled_Ycapital)*((share_domestic_recycled^siggma_imports)/(1-((share_row_recycled)^siggma_exports)*Demand_foreign_recycled))))); 
                                            
    Yrepair_Ydurable                        =   Inv_ed_repair_EDlowuse*EDlowuse_Ydurable;
    Yvirgin_Ydurable                        =   (share_domestic_virgin^siggma_imports)*((Mvirgin_Y_energydurable+Mvirgin_Y_otherdurable*(1/OD_Yotherdurable)*(1/X_OD)*X_EDlowuse*EDlowuse_Ydurable
                                                +Mvirgin_Y_nondurable*(1/X_Ynondurable)*X_EDlowuse*EDlowuse_Ydurable+Mvirgin_Ycapital*Ycapital_Ydurable))/(1-((share_row_virgin)^siggma_exports)*Demand_foreign_virgin);
    Yrecycled_Ydurable                      =   (share_domestic_recycled^siggma_imports)*((Mrecycled_Y_energydurable+Mrecycled_Y_otherdurable*(1/OD_Yotherdurable)*(1/X_OD)*X_EDlowuse*EDlowuse_Ydurable
                                                +Mrecycled_Y_nondurable*(1/X_Ynondurable)*X_EDlowuse*EDlowuse_Ydurable+Mrecycled_Ycapital*Ycapital_Ydurable))/(1-((share_row_recycled)^siggma_exports)*Demand_foreign_recycled);

    %------------------------------------------------------------------------------------------------------------
    % 9. Employment
    %------------------------------------------------------------------------------------------------------------

    Lcapital_Ldurable                       =   L_KL_capital*KL_Z_capital*Z_Y_capital*Ycapital_Ydurable/(KL_Z_energydurable*Z_Y_energydurable*L_KL_energydurable);  
    Lotherdurable_Ldurable                  =   L_KL_otherdurable*KL_Z_otherdurable*Z_Y_otherdurable*(1/OD_Yotherdurable)*(1/X_OD)*X_EDlowuse*EDlowuse_Ydurable/(KL_Z_energydurable*Z_Y_energydurable*L_KL_energydurable); 
    Lnondurable_Ldurable                    =   L_KL_nondurable*KL_Z_nondurable*Z_Y_nondurable*(1/X_Ynondurable)*X_EDlowuse*EDlowuse_Ydurable/(KL_Z_energydurable*Z_Y_energydurable*L_KL_energydurable);           
    Lvirgin_Ldurable                        =   L_KL_virgin*KL_Z_virgin*Z_Y_virgin*Yvirgin_Ydurable/(KL_Z_energydurable*Z_Y_energydurable*L_KL_energydurable);
    Lrecycled_Ldurable                      =   L_KL_recycled*KL_Z_recycled*Z_Y_recycled*Yrecycled_Ydurable/(KL_Z_energydurable*Z_Y_energydurable*L_KL_energydurable);
    Lsh_Ldurable                            =   (1/Ysh_Lsh)*Ysh_Ydurable/(KL_Z_energydurable*Z_Y_energydurable*L_KL_energydurable);
    Lrepair_Ldurable                        =   (Yrepair_Ydurable/Yrepair_Lrepair)/(KL_Z_energydurable*Z_Y_energydurable*L_KL_energydurable);
    L_energydurable                         =   1/(1+Lnondurable_Ldurable+Lotherdurable_Ldurable+Lrecycled_Ldurable+Lcapital_Ldurable+Lvirgin_Ldurable+Lsh_Ldurable+Lrepair_Ldurable);
    L_virgin                                =   Lvirgin_Ldurable*L_energydurable;
    L_recycled                              =   Lrecycled_Ldurable*L_energydurable;
    L_sharing                               =   Lsh_Ldurable*L_energydurable;
    L_capital                               =   Lcapital_Ldurable*L_energydurable;
    L_nondurable                            =   Lnondurable_Ldurable*L_energydurable;
    L_otherdurable                          =   Lotherdurable_Ldurable*L_energydurable;
    L_repair                                =   Lrepair_Ldurable*L_energydurable;
    h                                       =   L_repair*h_repair+L_sharing*h_sharing+L_capital*h_capital+L_energydurable*h_energydurable+L_nondurable*h_nondurable+L_otherdurable*h_otherdurable+L_virgin*h_virgin+L_recycled*h_recycled;

    %------------------------------------------------------------------------------------------------------------
    % 10. Aggregates
    %------------------------------------------------------------------------------------------------------------
        %------------------------------------------------------------------------------
        % 10.1. Production sectors
        %------------------------------------------------------------------------------

    @#for s in SECTORS  
        KL_@{s}                             =   L_@{s}/L_KL_@{s};
        K_f_@{s}                            =   KL_@{s}*K_KL_@{s};
        Z_@{s}                              =   KL_@{s}/KL_Z_@{s};
        Y_@{s}                              =   Z_@{s}/Z_Y_@{s};
        E_@{s}                              =   Z_@{s}/Z_E_@{s};
        M_@{s}                              =   Y_@{s}/Y_M_@{s};
        M_virgin_@{s}                       =   ((1/(A_m_@{s}*(1-gamma_@{s})))^siggma_m)*((1/alppha_v_@{s})^(siggma_m-1))*(((p_m_c_@{s})/(p_virgin+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s}))^siggma_m)*M_@{s};
        M_recycled_@{s}                     =   ((1/(A_m_@{s}*(1-gamma_@{s})))^siggma_m)*((1/(alppha_r_@{s}))^(siggma_m-1))*(((p_m_c_@{s})/(p_recycled+t_m*gamma_@{s}*(1-omegga_ind_recycled)+c_m*gamma_@{s}))^siggma_m)*M_@{s};
        El_@{s}                             =   ((A_el_WITCH)^siggma_e_f)*((alppha_el_@{s})^(siggma_e_f))*((p_e_@{s}/((p_el_f+t_el_f)))^siggma_e_f)*E_@{s}*(1/A_el_WITCH); 
        Nel_@{s}                            =   ((A_nel_WITCH)^siggma_e_f)*(((alppha_nel_@{s}))^(siggma_e_f))*((p_e_@{s}/((p_nel_f+t_nel_f)))^siggma_e_f)*E_@{s}*(1/A_nel_WITCH); 
    @#endfor
        Y_repair                            =   Yrepair_Ydurable*Y_energydurable;
        K_repair                            =   Y_repair/Yrepair_Krepair;
        Y_sharing                           =   Ysh_Ydurable*Y_energydurable;
        ES_sharing_f                        =   ESshf_Ysh*Y_sharing;
        ED_lowuse                           =   EDlowuse_Ydurable*Y_energydurable;
        ED_highuse                          =   uDsharing_ESshf*ES_sharing_f/u_highuse;
        Inv_ed_new_highuse                  =   Inv_ed_new_ED_highuse*ED_highuse;
        ES_sharing                          =   ESsharing_EDlowuse*ED_lowuse;
        E_sharing                           =   (1/ESshf_Esh)*(ES_sharing_f);
        El_sharing                          =   ((A_el_WITCH)^siggma_e_h)*((alppha_el_sharing)^(siggma_e_h))*((p_e_sharing/((p_el_f+t_el_f)))^siggma_e_h)*E_sharing*(1/A_el_WITCH);
        Nel_sharing                         =   ((A_nel)^siggma_e_h)*(((alppha_nel_sharing))^(siggma_e_h))*((p_e_sharing/((p_nel_f+t_nel_f)))^siggma_e_h)*E_sharing*(1/A_nel);
        Y_virgin                            =   (M_virgin_energydurable+M_virgin_otherdurable+M_virgin_nondurable+M_virgin_capital)*(share_domestic_virgin^siggma_imports)/(1-((share_row_virgin)^siggma_exports)*Demand_foreign_virgin);
        RM                                  =   (1/Yvirgin_RM)*Y_virgin;
        Y_recycled                          =   (M_recycled_energydurable+M_recycled_otherdurable+M_recycled_nondurable+M_recycled_capital)*(share_domestic_recycled^siggma_imports)/(1-((share_row_recycled)^siggma_exports)*Demand_foreign_recycled);
        RW                                  =   (1/Yrecycled_RW)*Y_recycled;
    @#for m in MATERIALS
        Z_@{m}                              =   Z_Y_@{m}*Y_@{m};
        KL_@{m}                             =   KL_Z_@{m}*Z_@{m};
        K_@{m}                              =   KL_@{m}*K_KL_@{m};
        E_@{m}                              =   (1/Z_E_@{m})*Z_@{m};
        El_@{m}                             =   ((A_el_WITCH)^siggma_e_@{m})*((alppha_el_@{m})^(siggma_e_@{m}))*((p_e_@{m}/((p_el_f+t_el_f)))^siggma_e_@{m})*E_@{m}*(1/A_el_WITCH);                                                          
        Nel_@{m}                            =   ((A_nel_WITCH)^siggma_e_@{m})*(((alppha_nel_@{m}))^(siggma_e_@{m}))*((p_e_@{m}/((p_nel_f+t_nel_f)))^siggma_e_@{m})*E_@{m}*(1/A_nel_WITCH); 
    @#endfor
        marginalcost_recycled               =   ((alppha_z_recycled^siggma_y)*(((alppha_kl_recycled^siggma_z)*((((alppha_k_recycled^siggma_kl)*(r_k^(1-siggma_kl))+(alppha_n_recycled^siggma_kl)*(w^(1-siggma_kl)))^(1/(1-siggma_kl)))^(1-siggma_z))
                                                +(alppha_e_recycled^siggma_z)*((p_e_recycled)^(1-siggma_z)))^(1/(1-siggma_z)))^(1-siggma_y)+(alppha_rw^siggma_y)*(((t_m*gamma_recycled*(1-omegga_ind_recycled)+c_m*gamma_recycled)/(1-gamma_recycled))^(1-siggma_y)))^(1/(1-siggma_y)); 
        DIV_capital                         =   p_capital*Y_capital-w*h_capital*L_capital-r_k*K_f_capital-p_e_capital*E_capital-p_m_capital*M_capital;
        DIV_nondurable                      =   p_nondurable*Y_nondurable-w*h_nondurable*L_nondurable-r_k*K_f_nondurable-p_e_nondurable*E_nondurable-p_m_nondurable*M_nondurable;
        DIV_otherdurable                    =   p_otherdurable*Y_otherdurable-w*h_otherdurable*L_otherdurable-r_k*K_f_otherdurable-p_e_otherdurable*E_otherdurable-p_m_otherdurable*M_otherdurable;
        DIV_energydurable                   =   p_energydurable*Y_energydurable-w*h_energydurable*L_energydurable-r_k*K_f_energydurable-p_e_energydurable*E_energydurable-p_m_energydurable*M_energydurable;
        DIV_virgin                          =   p_virgin*Y_virgin-w*h_virgin*L_virgin-r_k*K_virgin-p_e_virgin*E_virgin-(t_m*gamma_virgin*(1-omegga_ind_recycled)+c_m*gamma_virgin+p_rawmaterials)*RM;
        DIV_recycled                        =   p_recycled*Y_recycled-w*h_recycled*L_recycled-r_k*K_recycled-p_e_recycled*E_recycled-(t_m*gamma_recycled*(1-omegga_ind_recycled)+c_m*gamma_recycled)*RW;
        DIV_repair                          =   p_repair*Y_repair-w*(1-reduced_laborcosts)*h_repair*L_repair-r_k*K_repair;
        DIV_sharing                         =   p_sharing*Y_sharing - w*h_sharing*L_sharing - p_e_sharing*E_sharing - r_ed*u_highuse*ED_highuse;
        DIV_total                           =   DIV_repair+DIV_sharing+DIV_capital+DIV_nondurable+DIV_otherdurable+DIV_energydurable+DIV_virgin+DIV_recycled;

        %------------------------------------------------------------------------------
        % 10.2. Capital and energy-using durable goods assets
        %------------------------------------------------------------------------------

        K                                   =   (1+g+n+g*n)*(K_f_energydurable+K_f_otherdurable+K_f_nondurable+K_f_capital+K_virgin+K_recycled+K_repair);
        Inv_k                               =   Inv_k_K*K;
        Inv_k_energy                        =   (eppsilon*alppha_k_powercapacities*Inv_k+(1-eppsilon)*(Inv_RDEN_EE+Inv_k_powercapacities));                                        
        K_lowcarbon                         =   K/(omegga_lowcarbon_saver+(1-omegga_lowcarbon_saver)*share_savings_cautious);
        K_cautious                          =   K_lowcarbon*share_savings_cautious;
        Inv_k_cautious                      =   Inv_k_cautious_K_cautious*K_cautious;
        Inv_k_lowcarbon                     =   Inv_k_lowcarbon_K_lowcarbon*K_lowcarbon;
        Inv_ed_new_tild                     =   Inv_ed_new_tild_EDlowuse*ED_lowuse;
        g_inv_ed                            =   g_inv_ed_EDlowuse*ED_lowuse;
        Inv_ed_repair                       =   Inv_ed_repair_EDlowuse*ED_lowuse;
        Inv_ed_new                          =   (1/g_inv_Inv_ed_new)*g_inv_ed;

        %------------------------------------------------------------------------------
        % 10.3. Consumption
        %------------------------------------------------------------------------------

        X                                   =   X_EDlowuse*ED_lowuse;
        E_h                                 =   Eh_EDlowuse*ED_lowuse;
        El_h                                =   Elh_EDlowuse*ED_lowuse;    
        OD                                  =   (1/X_OD)*X;
        Inv_od                              =   Inv_od_OD*OD;
        NES                                 =   (alppha_x*(X^((siggma_nes-1)/siggma_nes))+(alppha_od)*(OD^((siggma_nes-1)/siggma_nes)))^(siggma_nes/(siggma_nes-1));
        Nel_h                               =   (((p_e_h_lowcarbon*alppha_nel_lowcarbon*A_nel/((p_nel_h+t_nel_h)*(1+t_c))))^siggma_e_h)*E_h/A_nel; 

        %------------------------------------------------------------------------------
        % 10.4. Energy
        %------------------------------------------------------------------------------

        El	                                =   El_h+El_nondurable+El_otherdurable+El_energydurable+El_capital+El_sharing+El_recycled+El_virgin;
        Nel	                                =   Nel_h+Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_capital+Nel_sharing+Nel_recycled+Nel_virgin;
        Y_power                             =   p_el_h*(El_h)+p_el_f*(El_nondurable+El_otherdurable+El_energydurable+El_capital+El_recycled+El_virgin+El_sharing);

%------------------------------------------------------------------------------
% 11. Government expenses
%------------------------------------------------------------------------------

        EPR_budget                          =   redistribution_epr*((epr_fee_energydurable-0.0413049832)*p_def_energydurable*(Inv_ed_new_highuse+Inv_ed_new+Inv_ed_new_tild));         
        EPR_budget_bis                      =   (epr_fee_energydurable*p_def_energydurable*(Inv_ed_new_highuse+Inv_ed_new+Inv_ed_new_tild));
        X_G                                 =   g_c_nondurable*Y_nondurable;
        Inv_od_G                            =   g_c_otherdurable*Y_otherdurable;
        Inv_ed_G                            =   g_c_energydurable*Y_energydurable;
        ED_G      	                        =   Inv_ed_G/(deltta_energydurable_gov+g+n+g*n);
        OD_G      	                        =   Inv_od_G/(deltta_otherdurable_fix+g+n+g*n);
        sub_recycled                        =   (marginalcost_recycled-p_virgin)*Y_recycled;
        Carbon_budget                       =   redistribution*(t_nel_h*(Nel_h)+t_nel_f*(Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_virgin+Nel_capital+Nel_recycled+Nel_sharing));
        Expenses                            =   w*reduced_laborcosts*h_repair*L_repair+p_def_nondurable*X_G+p_def_otherdurable*Inv_od_G+p_def_energydurable*Inv_ed_G+Tr+Carbon_budget+EPR_budget+p_repair*(repair_ed_bonus*Inv_ed_repair);
        
%------------------------------------------------------------------------------
% 12. Trade
%------------------------------------------------------------------------------

        IMP_R	                            =   RM*(((6.6053092E-01*1+3.1742072E-02*0.48)*(M_virgin_energydurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(2.0252225E-01*1+6.9488153E-02*0.48)*(M_virgin_otherdurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(3.6768029E-01*1+6.6377722E-02*0.48)*(M_virgin_capital/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+1.8454667E-02*0.48*(M_virgin_nondurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))))+p_nel_f*(Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_capital+Nel_virgin+Nel_recycled+Nel_sharing)+p_nel_h*(Nel_h);
        Domestic_Extraction                 =   RM*(1-((6.6053092E-01*1+3.1742072E-02*0.48)*(M_virgin_energydurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(2.0252225E-01*1+6.9488153E-02*0.48)*(M_virgin_otherdurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(3.6768029E-01*1+6.6377722E-02*0.48)*(M_virgin_capital/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+1.8454667E-02*0.48*(M_virgin_nondurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))));
        EXPORT_virgin	                    =   ((share_row_virgin)^siggma_exports)*Demand_foreign_virgin*(Y_virgin);
        EXPORT_recycled	                    =   ((share_row_recycled)^siggma_exports)*Demand_foreign_recycled*(Y_recycled);
    @#for m in MATERIALS   
        IMP_@{m}                            =   ((share_imp_@{m})^siggma_imports)*(M_@{m}_energydurable+M_@{m}_nondurable+M_@{m}_otherdurable+M_@{m}_capital);
        Demand_dom_@{m}                     =   (share_domestic_@{m}^siggma_imports)*(M_@{m}_energydurable+M_@{m}_nondurable+M_@{m}_otherdurable+M_@{m}_capital);    
    @#endfor
        IMP_energydurable                   =   (((share_imp_energydurable)*(p_def_energydurable/(p_fg_row+p_fg_row*t_imports_energydurable)))^siggma_imports)*(Inv_ed_new_tild+Inv_ed_new+Inv_ed_new_highuse+Inv_ed_G);
        Demand_dom_energydurable            =   (((share_domestic_energydurable)*(p_def_energydurable/(p_energydurable)))^siggma_imports)*(Inv_ed_new_tild+Inv_ed_new+Inv_ed_new_highuse+Inv_ed_G);
        IMP_otherdurable                    =   (((share_imp_otherdurable)*(p_def_otherdurable/(p_fg_row+p_fg_row*t_imports_otherdurable)))^siggma_imports)*(Inv_od+Inv_od_G);
        Demand_dom_otherdurable             =   (((share_domestic_otherdurable)*(p_def_otherdurable/(p_otherdurable)))^siggma_imports)*(Inv_od+Inv_od_G);
        IMP_nondurable                      =   (((share_imp_nondurable)*(p_def_nondurable/(p_fg_row+p_fg_row*t_imports_nondurable)))^siggma_imports)*(X+X_G);
        Demand_dom_nondurable               =   (((share_domestic_nondurable)*(p_def_nondurable/(p_nondurable)))^siggma_imports)*(X+X_G);
        IMP_capital	                        =   (((share_imp_capital)*(p_def_capital/(p_fg_row+p_fg_row*t_imports_capital)))^siggma_imports)*(1+alppha_k_powercapacities)*Inv_k;
        Demand_dom_capital	                =   (((share_domestic_capital)*(p_def_capital/(p_capital)))^siggma_imports)*(1+alppha_k_powercapacities)*Inv_k;
    @#for s in SECTORS
        EXPORT_@{s}	                        =   (((share_row_@{s})*(p_row_@{s}/((p_@{s}))))^siggma_exports)*Demand_foreign_@{s}*Y_@{s};   
    @#endfor
        TB                                  =   p_capital*EXPORT_capital+p_nondurable*EXPORT_nondurable+p_otherdurable*EXPORT_otherdurable+p_energydurable*EXPORT_energydurable+p_recycled*EXPORT_recycled+p_virgin*EXPORT_virgin
                                                +(p_fg_row+p_fg_row*margin_capital)*gamma_reexport_capital*EXPORT_capital+(p_fg_row+p_fg_row*margin_nondurable)*gamma_reexport_nondurable*EXPORT_nondurable+(p_fg_row+p_fg_row*margin_otherdurable)*gamma_reexport_otherdurable*EXPORT_otherdurable+(p_fg_row+p_fg_row*margin_energydurable)*gamma_reexport_energydurable*EXPORT_energydurable
                                                -(p_fg_row*(IMP_nondurable)+p_fg_row*(IMP_otherdurable)+p_fg_row*(IMP_energydurable)+p_fg_row*(IMP_capital)+p_recycled*IMP_recycled+p_virgin*IMP_virgin+p_rawmaterials*(((6.6053092E-01*1+3.1742072E-02*0.48)*(M_virgin_energydurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(2.0252225E-01*1+6.9488153E-02*0.48)*(M_virgin_otherdurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(3.6768029E-01*1+6.6377722E-02*0.48)*(M_virgin_capital/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+1.8454667E-02*0.48*(M_virgin_nondurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))))*RM)
                                                -p_nel_f*(Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_capital+Nel_virgin+Nel_recycled+Nel_sharing)-p_nel_h*(Nel_h);
        DIV_imports                         =   p_def_nondurable*(X+X_G)-(p_fg_row+p_fg_row*t_imports_nondurable)*IMP_nondurable-p_nondurable*Demand_dom_nondurable
                                                +p_def_otherdurable*(Inv_od+Inv_od_G)-(p_fg_row+p_fg_row*t_imports_otherdurable)*IMP_otherdurable-p_otherdurable*Demand_dom_otherdurable
                                                +p_def_energydurable*(Inv_ed_new_tild+Inv_ed_new+Inv_ed_G+Inv_ed_new_highuse)-(p_fg_row+p_fg_row*t_imports_energydurable)*IMP_energydurable-p_energydurable*Demand_dom_energydurable
                                                +p_def_capital*(Inv_k+Inv_k_energy)-(p_fg_row+p_fg_row*t_imports_capital)*IMP_capital-p_capital*Demand_dom_capital
                                                +p_virgin*(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital)-p_virgin*IMP_virgin-p_virgin*Demand_dom_virgin
                                                +p_recycled*(M_recycled_energydurable+M_recycled_nondurable+M_recycled_otherdurable+M_recycled_capital)-p_recycled*IMP_recycled-p_recycled*Demand_dom_recycled;
   
%------------------------------------------------------------------------------
% 13. Gross Domestic Product
%------------------------------------------------------------------------------

        GDP                                 =   w*(h_sharing*L_sharing+h_repair*L_repair+h_virgin*L_virgin+h_recycled*L_recycled+h_nondurable*L_nondurable+h_otherdurable*L_otherdurable+h_energydurable*L_energydurable+h_capital*L_capital)
                                                +r_k*K
                                                +r_ed*u_highuse*ED_highuse
                                                +DIV_total
                                                +t_c_reduced*p_repair*(1-repair_ed_bonus)*Inv_ed_repair
                                                +t_c*(p_def_nondurable*X+p_def_energydurable*(Inv_ed_new_highuse+Inv_ed_new+Inv_ed_new_tild)+p_def_otherdurable*Inv_od
                                                +p_sharing*ES_sharing+(p_el_h+t_el_h)*El_h+(p_nel_h+t_nel_h)*Nel_h)
                                                +t_el_h*(El_h)+t_el_f*(El_nondurable+El_otherdurable+El_capital+El_energydurable+El_virgin+El_recycled+El_sharing)+t_nel_h*(Nel_h)+t_nel_f*(Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_capital+Nel_virgin+Nel_recycled+Nel_sharing)
                                                +p_fg_row*(t_imports_capital*(IMP_capital)+t_imports_energydurable*(IMP_energydurable)+t_imports_nondurable*(IMP_nondurable)+t_imports_otherdurable*(IMP_otherdurable))
                                                +margin_capital*p_fg_row*gamma_reexport_capital*EXPORT_capital+margin_nondurable*p_fg_row*gamma_reexport_nondurable*EXPORT_nondurable+margin_otherdurable*p_fg_row*gamma_reexport_otherdurable*EXPORT_otherdurable+margin_energydurable*p_fg_row*gamma_reexport_energydurable*EXPORT_energydurable;

%------------------------------------------------------------------------------
% 14. Government revenues
%------------------------------------------------------------------------------

        Revenues	                        =   Inv_od*epr_fee_otherdurable*p_def_otherdurable+(Inv_ed_new+Inv_ed_new_tild+Inv_ed_new_highuse)*epr_fee_energydurable*p_def_energydurable
                                                +t_c_reduced*p_repair*((1-repair_ed_bonus)*Inv_ed_repair)
                                                +t_k*r_ed*u_highuse*ED_highuse
                                                +t_c*(p_def_nondurable*X+p_def_energydurable*(Inv_ed_new_highuse+Inv_ed_new_tild+Inv_ed_new)+p_def_otherdurable*Inv_od+p_sharing*ES_sharing+(p_el_h+t_el_h)*El_h+(p_nel_h+t_nel_h)*Nel_h)
                                                +t_el_h*(El_h)+t_el_f*(El_nondurable+El_otherdurable+El_energydurable+El_capital+El_virgin+El_recycled+El_sharing)+t_nel_h*(Nel_h)+t_nel_f*(Nel_nondurable+Nel_otherdurable+Nel_energydurable+Nel_capital+Nel_virgin+Nel_recycled+Nel_sharing)
                                                +t_l*w*(h_repair*L_repair+h_sharing*L_sharing+h_nondurable*L_nondurable+h_otherdurable*L_otherdurable+h_energydurable*L_energydurable+h_capital*L_capital+h_virgin*L_virgin+h_recycled*L_recycled)+(t_k*(r_k*((K/(1+g+n+g*n)))*(1-deltta_capital_fix)))
                                                +(t_m*(1-omegga_ind_recycled)+c_m)*(gamma_nondurable*(M_virgin_nondurable+M_recycled_nondurable)+gamma_otherdurable*(M_virgin_otherdurable+M_recycled_otherdurable)+gamma_energydurable*(M_virgin_energydurable+M_recycled_energydurable)+gamma_virgin*RM+gamma_recycled*RW+gamma_capital*(M_virgin_capital+M_recycled_capital))
                                                +t_w*(1-omegga_mun_recycled)*((((1-gamma_nondurable)*M_nondurable/Y_nondurable)*(Demand_dom_nondurable+material_int_nondurable*IMP_nondurable)*(X/(X+X_G)))+(((((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*(Demand_dom_otherdurable+material_int_otherdurable*IMP_otherdurable))/(deltta_otherdurable_physical+g+n+g*n+Error_stock_otherdurable))*deltta_otherdurable_physical*(OD/(OD+OD_G))))
                                                +p_fg_row*(t_imports_capital*IMP_capital+t_imports_energydurable*IMP_energydurable+t_imports_nondurable*IMP_nondurable+t_imports_otherdurable*IMP_otherdurable); 
        PS                                  =   Revenues-Expenses;                                  
        
%------------------------------------------------------------------------------
% 15. Consumption per income group
%------------------------------------------------------------------------------

        ED_lowuse_constrained               =   ((1-t_l)*w*(h_repair*L_repair+h_sharing*L_sharing+h_nondurable*L_nondurable+h_otherdurable*L_otherdurable+h_energydurable*L_energydurable+h_capital*L_capital+h_virgin*L_virgin+h_recycled*L_recycled)+Tr+Carbon_budget+EPR_budget-redistribution_epr*(epr_fee_energydurable-0.0413049832)*p_def_energydurable*Inv_ed_new_highuse)
                                                /((1+t_c_reduced)*(p_repair*(1-repair_ed_bonus)*Inv_ed_repair_ED_constrained)
                                                +(p_def_otherdurable*(1+t_c+epr_fee_otherdurable))*(Inv_od_OD_constrained*(1/X_OD_constrained)*(X_ED_constrained))
                                                +(t_w*(1-omegga_mun_recycled)*M_stock_otherdurable_OD*deltta_otherdurable_physical)*(1/X_OD_constrained)*(X_ED_constrained)
                                                +p_nd_ati*X_ED_constrained+p_def_energydurable*epr_fee_energydurable*(Inv_ed_new_tild_ED_constrained+Inv_ed_new_ED_constrained)+(1+t_c)*(p_sharing*ESsharing_ED_constrained
                                                +p_def_energydurable*(Inv_ed_new_tild_ED_constrained+Inv_ed_new_ED_constrained)+(p_el_h+t_el_h)*Elh_ED_constrained
                                                +(p_nel_h+t_nel_h)*((alppha_nel_constrained/alppha_el_constrained)^(siggma_e_h))*(((A_nel_constrained*(p_el_h+t_el_h)/((p_nel_h+t_nel_h)*A_el_WITCH)))^(siggma_e_h))*(A_el_WITCH/A_nel_constrained)*Elh_ED_constrained));
        ED_lowuse_cautious                  =   ((omegga_cautious*((1-t_l)*w*(h_repair*L_repair+h_sharing*L_sharing+h_nondurable*L_nondurable+h_otherdurable*L_otherdurable+h_energydurable*L_energydurable+h_capital*L_capital+h_virgin*L_virgin+h_recycled*L_recycled)+Tr+Carbon_budget+EPR_budget)+((1-omegga_lowcarbon_saver))*(share_savings_cautious*(((1-t_k)*r_ed*u_highuse*ED_highuse-p_def_energydurable*(1+t_c+epr_fee_energydurable)*Inv_ed_new_highuse+Y_power-p_def_capital*Inv_k_energy)/(omegga_lowcarbon_saver+(1-omegga_lowcarbon_saver)*share_savings_cautious))
                                                +(share_savings_cautious*(PS+DIV_total+DIV_imports+p_rawmaterials*Domestic_Extraction)/(omegga_lowcarbon_saver+(1-omegga_lowcarbon_saver)*share_savings_cautious))
                                                -share_savings_cautious*((TB-((p_fg_row+p_fg_row*margin_capital)*gamma_reexport_capital*EXPORT_capital+(p_fg_row+p_fg_row*margin_nondurable)*gamma_reexport_nondurable*EXPORT_nondurable+(p_fg_row+p_fg_row*margin_otherdurable)*gamma_reexport_otherdurable*EXPORT_otherdurable+(p_fg_row+p_fg_row*margin_energydurable)*gamma_reexport_energydurable*EXPORT_energydurable))/(omegga_lowcarbon_saver+(1-omegga_lowcarbon_saver)*share_savings_cautious))
                                                +r_k*(1-t_k*(1-deltta_capital_fix))*((K_cautious/(1+g+n+g*n)))-p_def_capital*Inv_k_cautious)))
                                                /(omegga_cautious*((1+t_c_reduced)*(p_repair*(1-repair_ed_bonus)*Inv_ed_repair_ED_cautious)
                                                +(p_def_otherdurable*(1+t_c+epr_fee_otherdurable))*(Inv_od_OD_cautious*(1/X_OD_cautious)*(X_ED_cautious))
                                                +(t_w*(1-omegga_mun_recycled)*M_stock_otherdurable_OD*deltta_otherdurable_physical)*(1/X_OD_cautious)*(X_ED_cautious)
                                                +p_nd_ati*X_ED_cautious+p_def_energydurable*epr_fee_energydurable*(Inv_ed_new_tild_ED_cautious+Inv_ed_new_ED_cautious)+(1+t_c)*(p_sharing*ESsharing_ED_cautious
                                                +p_def_energydurable*(Inv_ed_new_tild_ED_cautious+Inv_ed_new_ED_cautious)+(p_el_h+t_el_h)*Elh_ED_cautious                                                    
                                                +(p_nel_h+t_nel_h)*((alppha_nel_cautious/alppha_el_cautious)^(siggma_e_h))*(((A_nel_cautious*(p_el_h+t_el_h)/((p_nel_h+t_nel_h)*A_el_WITCH)))^(siggma_e_h))*(A_el_WITCH/A_nel_cautious)*Elh_ED_cautious)));                                                            
        ED_lowuse_lowcarbon                 =   (ED_lowuse-omegga_cautious*ED_lowuse_cautious-(1-omegga_cautious-omegga_lowcarbon)*ED_lowuse_constrained)/omegga_lowcarbon;                                                         

    @#for h in LIFESTYLES
        Inv_ed_new_tild_@{h}                =   Inv_ed_new_tild_ED_@{h}*ED_lowuse_@{h};
        g_inv_ed_@{h}                       =   g_inv_ed_ED_@{h}*ED_lowuse_@{h};
        Inv_ed_repair_@{h}                  =   Inv_ed_repair_ED_@{h}*ED_lowuse_@{h};
        Inv_ed_new_@{h}                     =   Inv_ed_new_ED_@{h}*ED_lowuse_@{h}; 
        omegga_repair_@{h}                  =   Inv_ed_repair_@{h}/(Inv_ed_repair_@{h}+Inv_ed_new_@{h}+Inv_ed_new_tild_@{h}); 
        X_@{h}                              =   X_ED_@{h}*ED_lowuse_@{h};
        E_@{h}                              =   Eh_ED_@{h}*ED_lowuse_@{h};
        ES_sharing_@{h}                     =   ESsharing_ED_@{h}*ED_lowuse_@{h};
        ES_home_@{h}	                    =   (alppha_ed*((u_lowuse_@{h}*ED_lowuse_@{h})^((siggma_home-1)/siggma_home))+(alppha_e)*((E_@{h})^((siggma_home-1)/siggma_home)))^(siggma_home/(siggma_home-1));
        El_@{h}                             =   Elh_ED_@{h}*ED_lowuse_@{h};
        Nel_@{h}                            =   ((alppha_nel_@{h}/alppha_el_@{h})^(siggma_e_h))*(((A_nel*(p_el_h+t_el_h)/((p_nel_h+t_nel_h)*A_el_WITCH)))^(siggma_e_h))*A_el_WITCH*(El_@{h}/A_nel);
        OD_@{h}                             =   (1/X_OD_@{h})*X_@{h};
        Inv_od_@{h}                         =   Inv_od_OD_@{h}*OD_@{h};
        NES_@{h}                            =   (alppha_x*(X_@{h}^((siggma_nes-1)/siggma_nes))+(alppha_od)*(OD_@{h}^((siggma_nes-1)/siggma_nes)))^(siggma_nes/(siggma_nes-1));
        ES_@{h}	                            =   ((alppha_home_@{h})*(ES_home_@{h}^((siggma_es_@{h}-1)/siggma_es_@{h}))+alppha_sharing_@{h}*(ES_sharing_@{h}^((siggma_es_@{h}-1)/siggma_es_@{h})))^(siggma_es_@{h}/(siggma_es_@{h}-1));
        C_@{h}                              =   (alppha_nes*(NES_@{h}^((siggma_c-1)/siggma_c))+(alppha_es)*(ES_@{h}^((siggma_c-1)/siggma_c)))^(siggma_c/(siggma_c-1));
        disc_factor_@{h}                    =   (alppha_nes*((C_@{h}/NES_@{h})^(1/siggma_c))*alppha_x*((NES_@{h}/X_@{h})^(1/siggma_nes))*((C_@{h}-habit_@{h}*(C_@{h}/(1+g+n+g*n)))^(-siggma_ies)-habit_@{h}*betta
                                                *(C_@{h}*(1+g+n+g*n)-habit_@{h}*C_@{h})^(-siggma_ies)))
                                                /(alppha_nes*((C_@{h}/NES_@{h})^(1/siggma_c))*alppha_x*((NES_@{h}/X_@{h})^(1/siggma_nes))*((1+g+n+g*n)^(-siggma_ies))
                                                *((C_@{h}-habit_@{h}*(C_@{h}/(1+g+n+g*n)))^(-siggma_ies)-habit_@{h}*betta*(C_@{h}*(1+g+n+g*n)-habit_@{h}*C_@{h})^(-siggma_ies))); 
        Expenditures_LIFE_@{h}              =   p_def_energydurable*(1+t_c+epr_fee_energydurable)*(Inv_ed_new_tild_@{h}+Inv_ed_new_@{h})
                                                +p_repair*(1+t_c_reduced)*(1-repair_ed_bonus)*Inv_ed_repair_@{h};
    @#endfor

        Expenditures_LIFE                   =   omegga_lowcarbon*Expenditures_LIFE_lowcarbon+omegga_cautious*Expenditures_LIFE_cautious+(1-omegga_lowcarbon-omegga_cautious)*Expenditures_LIFE_constrained; 
        C                                   =   omegga_lowcarbon*C_lowcarbon+omegga_cautious*C_cautious+(1-omegga_lowcarbon-omegga_cautious)*C_constrained;
        ES                                  =   omegga_lowcarbon*ES_lowcarbon+omegga_cautious*ES_cautious+(1-omegga_lowcarbon-omegga_cautious)*ES_constrained;
        ES_home                             =   omegga_lowcarbon*ES_home_lowcarbon+omegga_cautious*ES_home_cautious+(1-omegga_lowcarbon-omegga_cautious)*ES_home_constrained;

%------------------------------------------------------------------------------
% 14. Materials stock and flows, waste flows and footprints
%------------------------------------------------------------------------------       
        omegga_constrained                  =   (1-omegga_lowcarbon-omegga_cautious); 
        M_stock_otherdurable                =   ((((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*(Demand_dom_otherdurable+material_int_otherdurable*IMP_otherdurable))/(deltta_otherdurable_physical+g+n+g*n+Error_stock_otherdurable));           
        Gross_additions_stock_energydurable =   ((1-gamma_energydurable)*M_energydurable/Y_energydurable)*(Demand_dom_energydurable+material_int_energydurable*IMP_energydurable);  
        M_stock_energydurable               =   (Gross_additions_stock_energydurable+Error_stock_energydurable)/(g+n+g*n+(((1-omegga_repair_lowcarbon)*deltta_energydurable_physical*(u_lowuse_lowcarbon^siggma_dep_lowuse)*omegga_lowcarbon*ED_lowuse_lowcarbon+(1-omegga_repair_cautious)*deltta_energydurable_physical*(u_lowuse_cautious^siggma_dep_lowuse)*omegga_cautious*ED_lowuse_cautious+(1-omegga_repair_constrained)*deltta_energydurable_physical*(u_lowuse_constrained^siggma_dep_lowuse)*omegga_constrained*ED_lowuse_constrained)/(ED_lowuse+ED_highuse+ED_G))
                                                +deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))+deltta_energydurable_gov*((ED_G)/(ED_lowuse+ED_highuse+ED_G)));   
        M_stock_capital                     =   (((1-gamma_capital)*M_capital/Y_capital)*(Demand_dom_capital+material_int_capital*IMP_capital)+Error_stock_capital)/(deltta_capital_physical+g+n+g*n);                                                                   
        M_stock                             =   M_stock_energydurable+M_stock_otherdurable+M_stock_capital;
        IW_r                                =   omegga_ind_recycled*(M_stock_capital*deltta_capital_physical+gamma_nondurable*M_nondurable+gamma_otherdurable*M_otherdurable+gamma_energydurable*M_energydurable+gamma_capital*M_capital+gamma_virgin*RM);        
        MW_energydurables                   =   M_stock_energydurable*(((1-omegga_repair_lowcarbon)*omegga_lowcarbon*deltta_energydurable_physical*(u_lowuse_lowcarbon^siggma_dep_lowuse)*ED_lowuse_lowcarbon+(1-omegga_repair_cautious)*omegga_cautious*deltta_energydurable_physical*(u_lowuse_cautious^siggma_dep_lowuse)*ED_lowuse_cautious+(1-omegga_repair_constrained)*omegga_constrained*deltta_energydurable_physical*(u_lowuse_constrained^siggma_dep_lowuse)*ED_lowuse_constrained)/(ED_lowuse+ED_highuse+ED_G))+M_stock_energydurable*deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))+M_stock_energydurable*deltta_energydurable_gov*(ED_G/(ED_lowuse+ED_highuse+ED_G));   
        Net_additions_stock_energydurable   =   Gross_additions_stock_energydurable-M_stock_energydurable*(((1-omegga_repair_lowcarbon)*omegga_lowcarbon*deltta_energydurable_physical*(u_lowuse_lowcarbon^siggma_dep_lowuse)*ED_lowuse_lowcarbon+(1-omegga_repair_cautious)*omegga_cautious*deltta_energydurable_physical*(u_lowuse_cautious^siggma_dep_lowuse)*ED_lowuse_cautious+(1-omegga_repair_constrained)*omegga_constrained*deltta_energydurable_physical*(u_lowuse_constrained^siggma_dep_lowuse)*ED_lowuse_constrained)/(ED_lowuse+ED_highuse+ED_G))-M_stock_energydurable*deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))-M_stock_energydurable*deltta_energydurable_gov*((ED_G)/(ED_lowuse+ED_highuse+ED_G));
        IW_l                                =   (1-omegga_ind_recycled)*(M_stock_capital*deltta_capital_physical+gamma_nondurable*M_nondurable+gamma_otherdurable*M_otherdurable+gamma_energydurable*M_energydurable+gamma_capital*M_capital+gamma_virgin*RM)+gamma_recycled*RW;  
        IW                                  =   IW_r+IW_l;
        IW_processedmat                     =   gamma_virgin*RM;   
        IW_finalgoods                       =   IW-IW_processedmat-gamma_recycled*RW;    
        MW_nondurables                      =   ((1-gamma_nondurable)*M_nondurable/Y_nondurable)*(Demand_dom_nondurable+material_int_nondurable*IMP_nondurable);
        MW_otherdurables                    =   M_stock_otherdurable*deltta_otherdurable_physical;
        MW_r	                            =   omegga_mun_recycled*(MW_energydurables+MW_otherdurables+MW_nondurables);   
        MW_l	                            =   (1-omegga_mun_recycled)*(MW_energydurables+MW_otherdurables+MW_nondurables);     
        MW                                  =   MW_r+MW_l;  
        CO2_incineration                    =   (MW_l*0.8946+IW_l*0.9492)*0.415/1e+12; 
        CO2_economy                         =   El*emissions_el_WITCH+Nel*emissions_nel_WITCH;
        CO2                                 =   El*emissions_el_WITCH+Nel*emissions_nel_WITCH+CO2_incineration;
        Finalsink_total                     =   MW_l+IW_l+MW_r+IW_r-RW;
        NR_stock_mu                         =   MW_l/(g+n+g*n+decay_mu);
        NR_stock_indu                       =   IW_l/(g+n+g*n+decay_indu);
        IMP_materials                       =   IMP_recycled+IMP_virgin; 
        EXP_materials                       =   EXPORT_recycled+EXPORT_virgin;
        IMP_raw                             =   RM*(((6.6053092E-01*1+3.1742072E-02*0.48)*(M_virgin_energydurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(2.0252225E-01*1+6.9488153E-02*0.48)*(M_virgin_otherdurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+(3.6768029E-01*1+6.6377722E-02*0.48)*(M_virgin_capital/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital))+1.8454667E-02*0.48*(M_virgin_nondurable/(M_virgin_energydurable+M_virgin_nondurable+M_virgin_otherdurable+M_virgin_capital)))); 
        Gross_additions_stock_otherdurable  =   ((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*(Demand_dom_otherdurable+material_int_otherdurable*IMP_otherdurable);
        Gross_additions_stock_capital       =   ((1-gamma_capital)*M_capital/Y_capital)*(Demand_dom_capital+material_int_capital*IMP_capital);
        Gross_additions_stock               =   Gross_additions_stock_otherdurable+Gross_additions_stock_energydurable+Gross_additions_stock_capital;
        Net_additions_stock_otherdurable    =   ((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*(Demand_dom_otherdurable+material_int_otherdurable*IMP_otherdurable)-M_stock_otherdurable*deltta_otherdurable_physical;
        Net_additions_stock_capital         =   ((1-gamma_capital)*M_capital/Y_capital)*(Demand_dom_capital+material_int_capital*IMP_capital)-M_stock_capital*deltta_capital_physical;
        Material_balance                    =   ((1-gamma_nondurable)*M_nondurable/Y_nondurable)*(Demand_dom_nondurable+EXPORT_nondurable)
                                                +((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*(Demand_dom_otherdurable+EXPORT_otherdurable)
                                                +((1-gamma_energydurable)*M_energydurable/Y_energydurable)*(Demand_dom_energydurable+EXPORT_energydurable)
                                                +((1-gamma_capital)*M_capital/Y_capital)*(Demand_dom_capital+EXPORT_capital)
                                                +gamma_nondurable*M_nondurable+gamma_otherdurable*M_otherdurable+gamma_energydurable*M_energydurable+gamma_capital*M_capital
                                                +EXPORT_recycled+EXPORT_virgin
                                                -(IMP_recycled+IMP_virgin+((1-gamma_virgin)*RM)+((1-gamma_recycled)*RW));
         IMP_goods_mateq                    =   ((1-gamma_nondurable)*M_nondurable/Y_nondurable)*(material_int_nondurable*IMP_nondurable)
                                                +((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*(material_int_otherdurable*IMP_otherdurable)
                                                +((1-gamma_energydurable)*M_energydurable/Y_energydurable)*(material_int_energydurable*IMP_energydurable)
                                                +((1-gamma_capital)*M_capital/Y_capital)*(material_int_capital*IMP_capital);
        DMI                                 =   Domestic_Extraction + IMP_raw + IMP_materials + IMP_goods_mateq;
        DMC                                 =   DMI-EXP_materials-((1-gamma_nondurable)*M_nondurable/Y_nondurable)*EXPORT_nondurable
                                                -((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*EXPORT_otherdurable
                                                -((1-gamma_energydurable)*M_energydurable/Y_energydurable)*EXPORT_energydurable
                                                -((1-gamma_capital)*M_capital/Y_capital)*EXPORT_capital;
        EXPORT_goods_mateq                  =   ((1-gamma_nondurable)*M_nondurable/Y_nondurable)*EXPORT_nondurable
                                                +((1-gamma_otherdurable)*M_otherdurable/Y_otherdurable)*EXPORT_otherdurable
                                                +((1-gamma_energydurable)*M_energydurable/Y_energydurable)*EXPORT_energydurable
                                                +((1-gamma_capital)*M_capital/Y_capital)*EXPORT_capital;
        Material_balance_EWMFA              =   (Domestic_Extraction+IMP_raw+IMP_materials+IMP_goods_mateq)
                                                -(EXP_materials+EXPORT_goods_mateq)
                                                -(g+n+g*n)*M_stock
                                                -Finalsink_total+(Error_stock_capital-M_stock_otherdurable*Error_stock_otherdurable+Error_stock_energydurable);
        Material_balance_stocks             =   Gross_additions_stock 
                                                -(M_stock_capital*deltta_capital_physical+M_stock_otherdurable*deltta_otherdurable_physical+MW_energydurables) 
                                                -(g+n+g*n)*M_stock+(Error_stock_capital-M_stock_otherdurable*Error_stock_otherdurable+Error_stock_energydurable);
        E_virgin_tot                        =   El_virgin+Nel_virgin;
        E_recycled_tot                      =   El_recycled+Nel_recycled;
        M_virgin_tot                        =   M_virgin_nondurable+M_virgin_otherdurable+M_virgin_energydurable+M_virgin_capital;
        M_recycled_tot                      =   M_recycled_nondurable+M_recycled_otherdurable+M_recycled_energydurable+M_recycled_capital;
        Inv_ed_total                        =   omegga_lowcarbon*(Inv_ed_new_tild_lowcarbon+Inv_ed_new_lowcarbon)+omegga_cautious*(Inv_ed_new_tild_cautious+Inv_ed_new_cautious)
                                                +(1-omegga_lowcarbon-omegga_cautious)*(Inv_ed_new_tild_constrained+Inv_ed_new_constrained)+Inv_ed_new_highuse+Inv_ed_G;
        share_energydurable_lowuse_prod     =   (Inv_ed_total-Inv_ed_new_highuse)/Inv_ed_total;
        share_energydurable_highuse_prod    =   Inv_ed_new_highuse/Inv_ed_total;
        E_upstream_nondurable               =   E_virgin_tot*(M_virgin_nondurable/M_virgin_tot)+E_recycled_tot*(M_recycled_nondurable/M_recycled_tot);
        E_upstream_otherdurable             =   E_virgin_tot*(M_virgin_otherdurable/M_virgin_tot)+E_recycled_tot*(M_recycled_otherdurable/M_recycled_tot);
        E_upstream_energydurable_lowuse     =   (E_virgin_tot*(M_virgin_energydurable/M_virgin_tot)+E_recycled_tot*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_lowuse_prod;
        E_upstream_energydurable_highuse    =   (E_virgin_tot*(M_virgin_energydurable/M_virgin_tot)+E_recycled_tot*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_highuse_prod;
        E_upstream_energydurable            =   E_virgin_tot*(M_virgin_energydurable/M_virgin_tot)+E_recycled_tot*(M_recycled_energydurable/M_recycled_tot);
        E_upstream_capital                  =   E_virgin_tot*(M_virgin_capital/M_virgin_tot)+E_recycled_tot*(M_recycled_capital/M_recycled_tot);
        E_prod_nondurable                   =   (El_nondurable+Nel_nondurable)+E_upstream_nondurable;
        E_prod_otherdurable                 =   (El_otherdurable+Nel_otherdurable)+E_upstream_otherdurable;
        E_prod_energydurable_lowuse         =   (El_energydurable+Nel_energydurable)*share_energydurable_lowuse_prod+E_upstream_energydurable_lowuse;
        E_prod_energydurable_highuse        =   (El_energydurable+Nel_energydurable)*share_energydurable_highuse_prod+E_upstream_energydurable_highuse;
        E_prod_energydurable                =   (El_energydurable+Nel_energydurable)+E_upstream_energydurable;
        E_prod_sharing                      =   El_sharing+Nel_sharing+E_prod_energydurable_highuse;
        E_direct_capital                    =   El_capital + Nel_capital;
        E_prod_capital                      =   E_direct_capital + E_upstream_capital;
        E_prod_total                        =   E_prod_nondurable+E_prod_otherdurable+E_prod_sharing+E_prod_capital+E_prod_energydurable_lowuse;
        K_in_capital_chain                  =   K_f_capital+ K_virgin*(M_virgin_capital/M_virgin_tot)+K_recycled*(M_recycled_capital/M_recycled_tot);
        CO2_prod_nondurable                 =   (CO2_economy-El_h*emissions_el_WITCH-Nel_h*emissions_nel_WITCH)*(E_prod_nondurable/E_prod_total);
        CO2_prod_otherdurable               =   (CO2_economy-El_h*emissions_el_WITCH-Nel_h*emissions_nel_WITCH)*(E_prod_otherdurable/E_prod_total);
        CO2_prod_energydurable              =   (CO2_economy-El_h*emissions_el_WITCH-Nel_h*emissions_nel_WITCH)*((E_prod_energydurable_lowuse)/E_prod_total);
        CO2_prod_sharing                    =   (CO2_economy-El_h*emissions_el_WITCH-Nel_h*emissions_nel_WITCH)*(E_prod_sharing/E_prod_total);
        CO2_prod_capital                    =   (CO2_economy-El_h*emissions_el_WITCH-Nel_h*emissions_nel_WITCH)*(E_prod_capital/E_prod_total); 
        CO2_prod_capital_nondurable         =   CO2_prod_capital*(K_f_nondurable+K_virgin*(M_virgin_nondurable/M_virgin_tot)+K_recycled*(M_recycled_nondurable/M_recycled_tot))/(K-K_in_capital_chain);
        CO2_prod_capital_otherdurable       =   CO2_prod_capital*(K_f_otherdurable+K_virgin*(M_virgin_otherdurable/M_virgin_tot)+K_recycled*(M_recycled_otherdurable/M_recycled_tot))/(K-K_in_capital_chain);
        CO2_prod_capital_energydurable      =   CO2_prod_capital*(K_f_energydurable*share_energydurable_lowuse_prod+(K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_lowuse_prod)/(K-K_in_capital_chain);
        CO2_prod_capital_repair             =   CO2_prod_capital*(K_repair/(K-K_in_capital_chain));
        CO2_prod_capital_sharing            =   CO2_prod_capital*(K_f_energydurable*share_energydurable_highuse_prod+(K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_highuse_prod)/(K-K_in_capital_chain);
        CO2_eol_nondurable                  =   (1-omegga_mun_recycled)*(MW_nondurables*0.8946)*0.415/1e+12;
        CO2_eol_otherdurable                =   (1-omegga_mun_recycled)*(MW_otherdurables*0.8946)*0.415/1e+12;
        CO2_eol_energydurable_lowuse        =   (1-omegga_mun_recycled)*M_stock_energydurable*(((1-omegga_repair_lowcarbon)*omegga_lowcarbon*deltta_energydurable_physical*(u_lowuse_lowcarbon^siggma_dep_lowuse)*ED_lowuse_lowcarbon+(1-omegga_repair_cautious)*omegga_cautious*deltta_energydurable_physical*(u_lowuse_cautious^siggma_dep_lowuse)*ED_lowuse_cautious+(1-omegga_repair_constrained)*omegga_constrained*deltta_energydurable_physical*(u_lowuse_constrained^siggma_dep_lowuse)*ED_lowuse_constrained)/(ED_lowuse+ED_highuse+ED_G))*0.8946*(0.415/1e+12);
        CO2_eol_energydurable_highuse       =   (1-omegga_mun_recycled)*M_stock_energydurable*deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))*0.8946*(0.415/1e+12);
        CO2_IW_capital                      =   (((gamma_capital*M_capital+M_stock_capital*deltta_capital_physical+gamma_virgin*RM*(M_virgin_capital/M_virgin_tot))*(1-omegga_ind_recycled)+gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))*0.9492)*(0.415/1e+12);
        CO2_IW_nondurable                   =   (((gamma_nondurable*M_nondurable+gamma_virgin*RM*(M_virgin_nondurable/M_virgin_tot))*(1-omegga_ind_recycled)+gamma_recycled*RW*(M_recycled_nondurable/M_recycled_tot))*0.9492)*(0.415/1e+12)+CO2_IW_capital*(K_f_nondurable+K_virgin*(M_virgin_nondurable/M_virgin_tot)+K_recycled*(M_recycled_nondurable/M_recycled_tot))/(K-K_in_capital_chain);
        CO2_IW_otherdurable                 =   (((gamma_otherdurable*M_otherdurable+gamma_virgin*RM*(M_virgin_otherdurable/M_virgin_tot))*(1-omegga_ind_recycled)+gamma_recycled*RW*(M_recycled_otherdurable/M_recycled_tot))*0.9492)*(0.415/1e+12)+CO2_IW_capital*(K_f_otherdurable+K_virgin*(M_virgin_otherdurable/M_virgin_tot)+K_recycled*(M_recycled_otherdurable/M_recycled_tot))/(K-K_in_capital_chain);
        CO2_IW_energydurable                =   (((gamma_energydurable*M_energydurable+gamma_virgin*RM*(M_virgin_energydurable/M_virgin_tot))*(1-omegga_ind_recycled)+gamma_recycled*RW*(M_recycled_energydurable/M_recycled_tot))*0.9492)*(0.415/1e+12)*share_energydurable_lowuse_prod+CO2_IW_capital*((K_f_energydurable+K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_lowuse_prod)/(K-K_in_capital_chain);
        CO2_IW_sharing                      =   (((gamma_energydurable*M_energydurable+gamma_virgin*RM*(M_virgin_energydurable/M_virgin_tot))*(1-omegga_ind_recycled)+gamma_recycled*RW*(M_recycled_energydurable/M_recycled_tot))*0.9492)*(0.415/1e+12)*share_energydurable_highuse_prod+CO2_IW_capital*((K_f_energydurable+K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_highuse_prod)/(K-K_in_capital_chain);
        CO2_IW_repair                       =   CO2_IW_capital*(K_repair/(K-K_in_capital_chain));

    @#for h in LIFESTYLES
        share_nondurable_@{h}               =   omegga_@{h}*X_@{h}/(X+X_G);
        share_otherdurable_@{h}             =   omegga_@{h}*Inv_od_@{h}/(Inv_od+Inv_od_G);
        share_energydurable_new_@{h}        =   omegga_@{h}*(Inv_ed_new_tild_@{h}+Inv_ed_new_@{h})/(Inv_ed_total);
        share_sharing_@{h}                  =   omegga_@{h}*ES_sharing_@{h}/ES_sharing;
        share_repair_@{h}                   =   omegga_@{h}*Inv_ed_repair_@{h}/Inv_ed_repair;
        CF_prod_repair_@{h}                 =   CO2_prod_capital_repair*share_repair_@{h};
        CF_prod_nondurable_@{h}             =   (CO2_prod_nondurable+CO2_prod_capital_nondurable)*share_nondurable_@{h}*(Demand_dom_nondurable/(Demand_dom_nondurable+EXPORT_nondurable));
        CF_prod_otherdurable_@{h}           =   (CO2_prod_otherdurable+CO2_prod_capital_otherdurable)*share_otherdurable_@{h}*(Demand_dom_otherdurable/(Demand_dom_otherdurable+EXPORT_otherdurable));
        CF_prod_energydurable_@{h}          =   (CO2_prod_energydurable*share_energydurable_new_@{h}+CO2_prod_capital_energydurable*share_energydurable_new_@{h})*(Demand_dom_energydurable/(Demand_dom_energydurable+EXPORT_energydurable));
        CF_prod_sharing_@{h}                =   (CO2_prod_sharing+CO2_prod_capital_sharing)*share_sharing_@{h}*(Demand_dom_energydurable/(Demand_dom_energydurable+EXPORT_energydurable));
        CF_eol_nondurable_@{h}              =   CO2_eol_nondurable*share_nondurable_@{h};
        CF_eol_otherdurable_@{h}            =   CO2_eol_otherdurable*omegga_@{h}*(OD_@{h}/(OD+OD_G));
        CF_eol_energydurable_@{h}           =   CO2_eol_energydurable_lowuse*omegga_@{h}*((1-omegga_repair_@{h})*deltta_energydurable_physical*(u_lowuse_@{h}^siggma_dep_lowuse)*ED_lowuse_@{h}/(omegga_lowcarbon*(1-omegga_repair_lowcarbon)*deltta_energydurable_physical*(u_lowuse_lowcarbon^siggma_dep_lowuse)*ED_lowuse_lowcarbon+omegga_cautious*(1-omegga_repair_cautious)*deltta_energydurable_physical*(u_lowuse_cautious^siggma_dep_lowuse)*ED_lowuse_cautious+omegga_constrained*(1-omegga_repair_constrained)*deltta_energydurable_physical*(u_lowuse_constrained^siggma_dep_lowuse)*ED_lowuse_constrained));
        CF_eol_sharing_@{h}                 =   (1-omegga_mun_recycled)*M_stock_energydurable*deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))*omegga_@{h}*ES_sharing_@{h}/ES_sharing*0.8946*(0.415/1e+12);
        CF_IW_nondurable_@{h}               =   CO2_IW_nondurable*share_nondurable_@{h}*(Demand_dom_nondurable/(Demand_dom_nondurable+EXPORT_nondurable));
        CF_IW_otherdurable_@{h}             =   CO2_IW_otherdurable*share_otherdurable_@{h}*(Demand_dom_otherdurable/(Demand_dom_otherdurable+EXPORT_otherdurable));
        CF_IW_energydurable_@{h}            =   CO2_IW_energydurable*share_energydurable_new_@{h}*(Demand_dom_energydurable/(Demand_dom_energydurable+EXPORT_energydurable));
        CF_IW_sharing_@{h}                  =   CO2_IW_sharing*share_sharing_@{h}*(Demand_dom_energydurable/(Demand_dom_energydurable+EXPORT_energydurable));
        CF_IW_repair_@{h}                   =   CO2_IW_repair*share_repair_@{h};
        CF_@{h}                             =   CF_prod_nondurable_@{h}+CF_eol_nondurable_@{h}+CF_IW_nondurable_@{h}
                                                +CF_prod_otherdurable_@{h}+CF_eol_otherdurable_@{h}+CF_IW_otherdurable_@{h}
                                                +CF_prod_energydurable_@{h}+CF_eol_energydurable_@{h}+CF_IW_energydurable_@{h}
                                                +CF_prod_sharing_@{h}+CF_eol_sharing_@{h}+CF_IW_sharing_@{h}
                                                +CF_prod_repair_@{h}+CF_IW_repair_@{h}+omegga_@{h}*(El_@{h}*emissions_el_WITCH+Nel_@{h}*emissions_nel_WITCH);
        WF_nondurable_@{h}                  =   (MW_nondurables
                                                +((gamma_nondurable*M_nondurable+gamma_virgin*RM*(M_virgin_nondurable/M_virgin_tot)
                                                +gamma_recycled*RW*(M_recycled_nondurable/M_recycled_tot))/Y_nondurable)
                                                *(Demand_dom_nondurable+material_int_nondurable*IMP_nondurable)
                                                +(gamma_capital*M_capital+M_stock_capital*deltta_capital_physical
                                                +gamma_virgin*RM*(M_virgin_capital/M_virgin_tot)
                                                +gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))
                                                *((K_f_nondurable+K_virgin*(M_virgin_nondurable/M_virgin_tot)+K_recycled*(M_recycled_nondurable/M_recycled_tot))/(K-K_in_capital_chain))*(Demand_dom_capital/Y_capital))*share_nondurable_@{h};
        WF_otherdurable_@{h}                =   (MW_otherdurables)*omegga_@{h}*(OD_@{h}/(OD+OD_G))
                                                +(((gamma_otherdurable*M_otherdurable+gamma_virgin*RM*(M_virgin_otherdurable/M_virgin_tot)
                                                +gamma_recycled*RW*(M_recycled_otherdurable/M_recycled_tot))/Y_otherdurable)
                                                *(Demand_dom_otherdurable+material_int_otherdurable*IMP_otherdurable)
                                                +(gamma_capital*M_capital+M_stock_capital*deltta_capital_physical
                                                +gamma_virgin*RM*(M_virgin_capital/M_virgin_tot)
                                                +gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))
                                                *((K_f_otherdurable+K_virgin*(M_virgin_otherdurable/M_virgin_tot)+K_recycled*(M_recycled_otherdurable/M_recycled_tot))/(K-K_in_capital_chain))*(Demand_dom_capital/Y_capital))*share_otherdurable_@{h};
        WF_energydurable_@{h}               =   M_stock_energydurable*(1-omegga_repair_@{h})*deltta_energydurable_physical*(u_lowuse_@{h}^siggma_dep_lowuse)*omegga_@{h}*ED_lowuse_@{h}/(ED_lowuse+ED_highuse+ED_G)
                                                +((gamma_energydurable*M_energydurable+gamma_virgin*RM*(M_virgin_energydurable/M_virgin_tot)
                                                +gamma_recycled*RW*(M_recycled_energydurable/M_recycled_tot))/Y_energydurable)
                                                *(Demand_dom_energydurable+material_int_energydurable*IMP_energydurable)
                                                *share_energydurable_lowuse_prod*share_energydurable_new_@{h}
                                                +(gamma_capital*M_capital+M_stock_capital*deltta_capital_physical
                                                +gamma_virgin*RM*(M_virgin_capital/M_virgin_tot)
                                                +gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))
                                                *(((K_f_energydurable+K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_lowuse_prod)/(K-K_in_capital_chain))*(Demand_dom_capital/Y_capital)*share_energydurable_new_@{h};
        WF_sharing_@{h}                     =   M_stock_energydurable*deltta_energydurable_physical*(u_highuse^siggma_dep)*(ED_highuse/(ED_lowuse+ED_highuse+ED_G))*share_sharing_@{h}
                                                +((gamma_energydurable*M_energydurable+gamma_virgin*RM*(M_virgin_energydurable/M_virgin_tot)
                                                +gamma_recycled*RW*(M_recycled_energydurable/M_recycled_tot))/Y_energydurable)
                                                *(Demand_dom_energydurable+material_int_energydurable*IMP_energydurable)
                                                *share_energydurable_highuse_prod*share_sharing_@{h}
                                                +(gamma_capital*M_capital+M_stock_capital*deltta_capital_physical
                                                +gamma_virgin*RM*(M_virgin_capital/M_virgin_tot)
                                                +gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))
                                                *(((K_f_energydurable+K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_highuse_prod)/(K-K_in_capital_chain))*(Demand_dom_capital/Y_capital)*share_sharing_@{h};
        WF_repair_@{h}                      =   (gamma_capital*M_capital+M_stock_capital*deltta_capital_physical
                                                +gamma_virgin*RM*(M_virgin_capital/M_virgin_tot)
                                                +gamma_recycled*RW*(M_recycled_capital/M_recycled_tot))*(K_repair/(K-K_in_capital_chain))*(Demand_dom_capital/Y_capital)*share_repair_@{h};
        WF_@{h}                             =   WF_nondurable_@{h}+WF_otherdurable_@{h}+WF_energydurable_@{h}+WF_sharing_@{h}+WF_repair_@{h};
        MF_@{h}                             =   (1-gamma_nondurable)*((M_virgin_nondurable+M_recycled_nondurable)*(Demand_dom_nondurable/Y_nondurable)
                                                +(M_virgin_nondurable+M_recycled_nondurable)/Y_nondurable*material_int_nondurable*IMP_nondurable)*share_nondurable_@{h}
                                                +(1-gamma_otherdurable)*((M_virgin_otherdurable+M_recycled_otherdurable)*(Demand_dom_otherdurable/Y_otherdurable)
                                                +(M_virgin_otherdurable+M_recycled_otherdurable)/Y_otherdurable*material_int_otherdurable*IMP_otherdurable)*share_otherdurable_@{h}
                                                +(1-gamma_energydurable)*((M_virgin_energydurable+M_recycled_energydurable)*(Demand_dom_energydurable/Y_energydurable)
                                                +(M_virgin_energydurable+M_recycled_energydurable)/Y_energydurable*material_int_energydurable*IMP_energydurable)*share_energydurable_lowuse_prod*share_energydurable_new_@{h}
                                                +(1-gamma_energydurable)*((M_virgin_energydurable+M_recycled_energydurable)*(Demand_dom_energydurable/Y_energydurable)
                                                +(M_virgin_energydurable+M_recycled_energydurable)/Y_energydurable*material_int_energydurable*IMP_energydurable)*share_energydurable_highuse_prod*share_sharing_@{h}
                                                +(1-gamma_capital)*((M_virgin_capital+M_recycled_capital)*(Demand_dom_capital/Y_capital)
                                                +(M_virgin_capital+M_recycled_capital)/Y_capital*material_int_capital*IMP_capital)
                                                *(((K_f_nondurable+K_virgin*(M_virgin_nondurable/M_virgin_tot)+K_recycled*(M_recycled_nondurable/M_recycled_tot))/(K-K_in_capital_chain))*share_nondurable_@{h}
                                                +((K_f_otherdurable+K_virgin*(M_virgin_otherdurable/M_virgin_tot)+K_recycled*(M_recycled_otherdurable/M_recycled_tot))/(K-K_in_capital_chain))*share_otherdurable_@{h}
                                                +(((K_f_energydurable+K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_lowuse_prod)/(K-K_in_capital_chain))*share_energydurable_new_@{h}
                                                +(((K_f_energydurable+K_virgin*(M_virgin_energydurable/M_virgin_tot)+K_recycled*(M_recycled_energydurable/M_recycled_tot))*share_energydurable_highuse_prod)/(K-K_in_capital_chain))*share_sharing_@{h}
                                                +(K_repair/(K-K_in_capital_chain))*share_repair_@{h});

    @#endfor

end;

%%%%%%%%%%%%%%%%%%
% INITIALISATION %
%%%%%%%%%%%%%%%%%%

initval;

@#include "CIRCEE_baseyear_values.m"

end;
resid; 
steady;
check;

%%%%%%%%%%%%%%%%%%%%%%%
% TERMINAL CONDITIONS %
%%%%%%%%%%%%%%%%%%%%%%%

endval;

@#include "CIRCEE_endvalues.m"

end;
resid; 
steady;
check;