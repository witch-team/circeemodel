function welfare = CIRCEE_WelfareAnalysis(results, scenario_list, lifestyle, foresight_short, csv_dir)

groups = {'lowcarbon','cautious','constrained'};
n_groups = 3;
T_sim = 82;
years = 2018:2100;
n_years = length(years);

% ---- Base year for welfare evaluation ----
% Set to 2020 so the welfare comparison starts after the calibration/initial steady-state
% period (2018), any initial transition dynamics (2019) and lifestyles changes implementation

base_year = 2020;
base_idx = find(years == base_year);
baseline_name = matlab.lang.makeValidName(scenario_list{1});
B = results.(baseline_name);
params = B.params;
growth_factor = (1 + params.g + params.n + params.g * params.n);

% ---- Atkinson epsilon values (used across all dimensions) ----
atkinson_eps = [0.5, 1.0, 1.5, 2.0, 3.0];
n_eps = length(atkinson_eps);

    function path = getvar(R, varname)
        idx = strmatch(varname, R.endo_names, 'exact');
        if ~isempty(idx)
            path = R.endo_simul(idx, 1:n_years);
            return;
        end
        idx_exo = strmatch(varname, R.exo_names, 'exact');
        if ~isempty(idx_exo)
            raw = R.exo_simul(:, idx_exo)';
            if length(raw) >= n_years
                path = raw(1:n_years);
            else
                path = [raw, repmat(raw(end), 1, n_years - length(raw))];
            end
            return;
        end
        fn = matlab.lang.makeValidName(varname);
        if isfield(R.params, fn)
            path = R.params.(fn) * ones(1, n_years);
            return;
        end
        error('Variable %s not found in endo_names, exo_names, or params', varname);
    end

    % ---- Load a rescaled per-capita footprint series from the output-level CSV ----
    %  varbase: 'CF' | 'WF' | 'MF' ; grp: 'lowcarbon'|'cautious'|'constrained'
    function series = load_footprint_pc(scenario_raw, varbase, grp)
        % NoModifiers has no lifestyle by construction → single generic file per foresight
        if strcmpi(scenario_raw, 'NoModifiers')
            fname = sprintf('NoModifiers_%s.csv', foresight_short);
        else
            fname = sprintf('%s_%s_%s.csv', lifestyle, foresight_short, scenario_raw);
        end
        fpath = fullfile(csv_dir, fname);
        persistent cache
        if isempty(cache); cache = containers.Map('KeyType','char','ValueType','any'); end
        if ~isKey(cache, fpath)
            if ~exist(fpath, 'file')
                error('Footprint CSV not found: %s', fpath);
            end
            T = readtable(fpath, 'ReadVariableNames', true, 'PreserveVariableNames', true);
            cache(fpath) = T;
        end
        T = cache(fpath);
        rowname = sprintf('%s_%s_percapita', varbase, grp);
        ridx = find(strcmp(T{:,1}, rowname), 1);
        if isempty(ridx)
            error('Row %s not found in %s', rowname, fname);
        end

        ycols = arrayfun(@(y) sprintf('Y%d', y), years, 'UniformOutput', false);
        vals  = zeros(1, n_years);
        for k = 1:n_years
            vals(k) = T{ridx, ycols{k}};
        end
        series = vals;
    end

% ---- Helper: compute between-group Atkinson index for 3 weighted groups ----
    function A = compute_atkinson(v1, v2, v3, w1, w2, w3, eps_val)
        v_mean = w1*v1 + w2*v2 + w3*v3;
        if abs(eps_val - 1) < 1e-8
            log_ratio = w1*log(v1/v_mean) + w2*log(v2/v_mean) + w3*log(v3/v_mean);
            A = 1 - exp(log_ratio);
        else
            sum_term = w1*(v1/v_mean)^(1-eps_val) ...
                     + w2*(v2/v_mean)^(1-eps_val) ...
                     + w3*(v3/v_mean)^(1-eps_val);
            A = 1 - sum_term^(1/(1-eps_val));
        end
    end

% ---- Helper: compute between-group Gini for 3 weighted groups ----
    function G = compute_gini(vals, wgts)
        v_mean = sum(vals .* wgts);
        G = 0;
        for ii = 1:3
            for jj = 1:3
                G = G + wgts(ii)*wgts(jj)*abs(vals(ii)-vals(jj));
            end
        end
        G = G / (2 * v_mean);
    end

% ---- Helper: compute "Palma", the high-to-low ratio, for 3 weighted groups ----
function P = compute_palma(vals, wgts) %#ok<INUSD>
        vals_s = sort(vals);
        if vals_s(1) < 1e-9
            P = NaN;
        else
            P = vals_s(end) / vals_s(1);   % top/bottom per-capita ratio
        end
    end

%% ==================================================================================
%  SECTION 1: EFFECTIVE CONSUMPTION & PERIOD UTILITY
%  ==================================================================================
% For each scenario and income group, this section computes:
%
%   - Effective consumption:   C_eff_h(t) = C_h(t) - habit_h * C_h(t-1) / (1+g+n+g*n)
%   - Utility:                 u_h(t)     = C_eff_h(t)^(1-sigma) / (1-sigma)
%%

sigma = params.siggma_ies;

for s = 1:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});
    R = results.(scen);

    for g = 1:n_groups
        grp = groups{g};
        habit = params.(['habit_' grp]);
        C_path = getvar(R, ['C_' grp]);
        C_eff = zeros(1, n_years);
        C_eff(1) = C_path(1) - habit * C_path(1) / growth_factor;
        for t = 2:n_years
            C_eff(t) = C_path(t) - habit * C_path(t-1) / growth_factor;
        end

        C_eff = max(C_eff, 1e-15);

        if abs(sigma - 1) < 1e-8
            u_period = log(C_eff);
        else
            u_period = (C_eff.^(1-sigma)) / (1-sigma);
        end

        welfare.scenarios.(scen).(grp).C_path = C_path;
        welfare.scenarios.(scen).(grp).C_eff  = C_eff;
        welfare.scenarios.(scen).(grp).u_period = u_period;
    end
end

%% =================================================================================
%  SECTION 2: LIFETIME WELFARE
%  =================================================================================
% The discounted lifetime utility is : 
%
%           V_h = sum_{t=base_year}^{2100} beta^(t-base_year) * u_h(t)
%%

beta = params.betta;
n_welfare_periods = n_years - base_idx + 1;
beta_vec = beta.^(0:n_welfare_periods-1);

for s = 1:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});

    for g = 1:n_groups
        grp = groups{g};
        u_path = welfare.scenarios.(scen).(grp).u_period;
        V = sum(beta_vec .* u_path(base_idx:end));
        welfare.scenarios.(scen).(grp).V_lifetime = V;
    end

    omega_lc = getvar(results.(scen), 'omegga_lowcarbon');
    omega_ca = getvar(results.(scen), 'omegga_cautious');

    V_agg = 0;
    for t = base_idx:n_years
        olc = omega_lc(t); oca = omega_ca(t); oco = 1 - olc - oca;
        u_agg_t = olc * welfare.scenarios.(scen).lowcarbon.u_period(t) ...
                + oca * welfare.scenarios.(scen).cautious.u_period(t) ...
                + oco * welfare.scenarios.(scen).constrained.u_period(t);
        V_agg = V_agg + beta^(t - base_idx) * u_agg_t;
    end
    welfare.scenarios.(scen).V_aggregate = V_agg;
end

%% ===============================================================================================
%  SECTION 3: CONSUMPTION-EQUIVALENT VARIATION (CEV) of WELFARE - Utility-based welfare analysis
%  What % consumption change makes household indifferent?
%  ===============================================================================================
% Lifetime welfare in consumption units (converts V_h ratio into consumption-equivalent terms): 
%
%                   lambda_h = (V_h_policy / V_h_base)^(1/(1-sigma)) - 1
%
% -> what permanent % change in baseline consumption yields the same welfare as the policy scenario?
%
% Year-by-year welfare in CEV: 
%
%                   lambda_h(t) = C_eff_h_policy(t) / C_eff_h_base(t) - 1
%
% Interpretation of results:
%   - Positive lambda = better off under policy scenario
%   - Negative lambda = worse off

base = matlab.lang.makeValidName(scenario_list{1});

for s = 2:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});

    for g = 1:n_groups
        grp = groups{g};

        V_base = welfare.scenarios.(base).(grp).V_lifetime;
        V_pol  = welfare.scenarios.(scen).(grp).V_lifetime;

        if abs(sigma - 1) < 1e-8
            beta_sum = sum(beta_vec);
            cev_lifetime = exp((V_pol - V_base) / beta_sum) - 1;
        else
            cev_lifetime = (V_pol / V_base)^(1/(1-sigma)) - 1;
        end

        C_eff_base = welfare.scenarios.(base).(grp).C_eff;
        C_eff_pol  = welfare.scenarios.(scen).(grp).C_eff;
        cev_snapshot = C_eff_pol ./ C_eff_base - 1;
        welfare.cev.(scen).(grp).lifetime = cev_lifetime;
        welfare.cev.(scen).(grp).snapshot = cev_snapshot;
    end

    V_base_agg = welfare.scenarios.(base).V_aggregate;
    V_pol_agg  = welfare.scenarios.(scen).V_aggregate;
    if abs(sigma - 1) < 1e-8
        welfare.cev.(scen).aggregate_lifetime = exp((V_pol_agg - V_base_agg) / sum(beta_vec)) - 1;
    else
        welfare.cev.(scen).aggregate_lifetime = (V_pol_agg / V_base_agg)^(1/(1-sigma)) - 1;
    end
end

%% ========================================================================
%  SECTION 4: EXPENDITURE INEQUALITY - GINI, PALMA, ATKINSON
%  ========================================================================

for s = 1:length(scenario_list)
    scen    = matlab.lang.makeValidName(scenario_list{s});
    R       = results.(scen);
    omega_lc        = getvar(R, 'omegga_lowcarbon');
    omega_ca        = getvar(R, 'omegga_cautious');
    Expend          = struct();
    p_def_ed        = getvar(R, 'p_def_energydurable');
    epr_fee_ed      = getvar(R, 'epr_fee_energydurable');
    p_nd_ati        = getvar(R, 'p_nd_ati');
    p_def_od        = getvar(R, 'p_def_otherdurable');
    p_sharing       = getvar(R, 'p_sharing');
    p_repair        = getvar(R, 'p_repair');
    p_el_h          = getvar(R, 'p_el_h');
    p_nel_h         = getvar(R, 'p_nel_h');
    OD_total        = getvar(R, 'OD');
    OD_G            = getvar(R, 'OD_G');
    M_stock_od      = getvar(R, 'M_stock_otherdurable');
    t_c             = params.t_c;
    t_el_h_val      = getvar(R, 't_el_h');
    t_nel_h_val     = getvar(R, 't_nel_h');
    epr_fee_od      = getvar(R, 'epr_fee_otherdurable');
    t_c_red         = getvar(R, 't_c_reduced');
    rep_bonus       = getvar(R, 'repair_ed_bonus');
    t_w_val         = getvar(R, 't_w');
    omegga_mun_r    = params.omegga_mun_recycled;
    deltta_od_ph    = params.deltta_otherdurable_physical;

    for g = 1:n_groups
        grp = groups{g};
        X_h = getvar(R, ['X_' grp]);
        Inv_od_h = getvar(R, ['Inv_od_' grp]);
        ES_sharing_h = getvar(R, ['ES_sharing_' grp]);
        El_h = getvar(R, ['El_' grp]);
        Nel_h = getvar(R, ['Nel_' grp]);
        Inv_ed_new_tild_h = getvar(R, ['Inv_ed_new_tild_' grp]);
        Inv_ed_new_h = getvar(R, ['Inv_ed_new_' grp]);
        Inv_ed_repair_h = getvar(R, ['Inv_ed_repair_' grp]);
        OD_h = getvar(R, ['OD_' grp]);
        Expend.(grp) = (1+t_c) .* (p_def_ed .* (Inv_ed_new_tild_h + Inv_ed_new_h) ...
                       + p_sharing .* ES_sharing_h ...
                       + (p_el_h + t_el_h_val) .* El_h ...
                       + (p_nel_h + t_nel_h_val) .* Nel_h) ...
                       + p_def_ed .* epr_fee_ed .* (Inv_ed_new_tild_h + Inv_ed_new_h) ...
                       + p_nd_ati .* X_h ...
                       + p_def_od .* (1 + t_c + epr_fee_od) .* Inv_od_h ...
                       + t_w_val .* (1 - omegga_mun_r) .* M_stock_od .* deltta_od_ph .* OD_h ./ (OD_total + OD_G) ...
                       + p_repair .* (1 + t_c_red) .* (1 - rep_bonus) .* Inv_ed_repair_h;
    end

    Gini_exp = zeros(1, n_years);
    Palma_exp = zeros(1, n_years);
    Atkinson_exp = zeros(n_eps, n_years);

    for t = 1:n_years
        olc = omega_lc(t); oca = omega_ca(t); oco = 1 - olc - oca;
        e_lc = Expend.lowcarbon(t);
        e_ca = Expend.cautious(t);
        e_co = Expend.constrained(t);
        vals = [e_lc, e_ca, e_co];
        wgts = [olc, oca, oco];

        Gini_exp(t)  = compute_gini(vals, wgts);
        Palma_exp(t) = compute_palma(vals, wgts);

        for ae = 1:n_eps
            Atkinson_exp(ae, t) = compute_atkinson(e_lc, e_ca, e_co, olc, oca, oco, atkinson_eps(ae));
        end
    end

    welfare.distribution.(scen).Gini  = Gini_exp;
    welfare.distribution.(scen).Palma = Palma_exp;
    welfare.distribution.(scen).Atkinson_05 = Atkinson_exp(1,:);
    welfare.distribution.(scen).Atkinson_10 = Atkinson_exp(2,:);
    welfare.distribution.(scen).Atkinson_15 = Atkinson_exp(3,:);
    welfare.distribution.(scen).Atkinson_20 = Atkinson_exp(4,:);
    welfare.distribution.(scen).Atkinson_30 = Atkinson_exp(5,:);
    welfare.distribution.(scen).Expend = Expend;
    welfare.distribution.(scen).years = years;
end

%% ==========================================================================================
%  SECTION 5: COMPENSATING VARIATION / EQUIVALENT VARIATION - Price-based welfare analysis
%  Compensating variation (CV) : How much compensation do income-groups need at new prices?
%  Equivalent variation (EV) : How much would the household pay at old prices to avoid the change?
%  ==========================================================================================
%  Uses CES bundles price indices: aggregate price of energy services, aggregate price of non-energy services 
%  and aggregate price of consumption basket (P_C_h)
%  Computes CV_h(t)  = P_C_h_policy(t) / P_C_h_baseline(t) - 1
%  Interpretation of results : positive = worse off, needs compensation.

for s = 1:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});
    R = results.(scen);
    p_nd_ati = getvar(R, 'p_nd_ati');
    p_sharing = getvar(R, 'p_sharing');
    p_def_od = getvar(R, 'p_def_otherdurable');
    sigma_c = params.siggma_c;
    sigma_nes = params.siggma_nes;
    sigma_home = params.siggma_home;
    a_nes = params.alppha_nes;
    a_es = params.alppha_es;
    a_x = params.alppha_x;
    a_od = params.alppha_od;

    for g = 1:n_groups
        grp = groups{g};

        p_home_h = getvar(R, ['p_home_' grp]);
        p_e_h = getvar(R, ['p_e_h_' grp]);

        X_h_cv  = getvar(R, ['X_' grp]);
        OD_h_cv = getvar(R, ['OD_' grp]);
        p_od_user_h = p_nd_ati .* (a_od/a_x) .* (X_h_cv ./ OD_h_cv).^(1/sigma_nes);

        sigma_es_h = getvar(R, ['siggma_es_' grp]);
        a_home_h   = getvar(R, ['alppha_home_' grp]);
        a_sharing_h = getvar(R, ['alppha_sharing_' grp]);
        mod_sh     = getvar(R, ['modifier_sharing_' grp]);
        t_c_val = params.t_c;
        p_sharing_atc = p_sharing * (1 + t_c_val);

        P_ES_h = zeros(1, n_years);
        for t = 1:n_years
            ses = sigma_es_h(t);
            ah = a_home_h(t);
            ash = a_sharing_h(t) * (1 - mod_sh(t));
            P_ES_h(t) = ((ah^ses) * (p_home_h(t)^(1-ses)) ...
                        + (ash^ses) * (p_sharing_atc(t)^(1-ses)))^(1/(1-ses));
        end

        P_NES_h = ((a_x^sigma_nes) * (p_nd_ati.^(1-sigma_nes)) ...
                  + (a_od^sigma_nes) * (p_od_user_h.^(1-sigma_nes))).^(1/(1-sigma_nes));

        P_C_h = ((a_nes^sigma_c) * (P_NES_h.^(1-sigma_c)) ...
                + (a_es^sigma_c) * (P_ES_h.^(1-sigma_c))).^(1/(1-sigma_c));

        welfare.prices.(scen).(grp).P_C   = P_C_h;
        welfare.prices.(scen).(grp).P_NES = P_NES_h;
        welfare.prices.(scen).(grp).P_ES  = P_ES_h;
        welfare.prices.(scen).(grp).p_home = p_home_h;
        welfare.prices.(scen).(grp).p_e_h  = p_e_h;
    end
end

for s = 2:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});

    for g = 1:n_groups
        grp = groups{g};

        P_C_base = welfare.prices.(base).(grp).P_C;
        P_C_pol  = welfare.prices.(scen).(grp).P_C;

        welfare.cv_ev.(scen).(grp).CV = P_C_pol ./ P_C_base - 1;
        welfare.cv_ev.(scen).(grp).EV = 1 - P_C_base ./ P_C_pol;

        P_NES_base  = welfare.prices.(base).(grp).P_NES;
        P_NES_pol   = welfare.prices.(scen).(grp).P_NES;
        P_ES_base   = welfare.prices.(base).(grp).P_ES;
        P_ES_pol    = welfare.prices.(scen).(grp).P_ES;
        p_home_base = welfare.prices.(base).(grp).p_home;
        p_home_pol  = welfare.prices.(scen).(grp).p_home;
        p_e_base    = welfare.prices.(base).(grp).p_e_h;
        p_e_pol     = welfare.prices.(scen).(grp).p_e_h;

        C_base = welfare.scenarios.(base).(grp).C_path;
        ES_home_base = getvar(results.(base), ['ES_home_' grp]);
        ES_sharing_base = getvar(results.(base), ['ES_sharing_' grp]);
        E_base = getvar(results.(base), ['E_' grp]);
        X_base = getvar(results.(base), ['X_' grp]);

        p_nd_base = getvar(results.(base), 'p_nd_ati');
        p_sh_base = getvar(results.(base), 'p_sharing') * (1 + params.t_c);

        welfare.cv_ev.(scen).(grp).CS_energy = -(p_e_pol ./ p_e_base - 1) ...
            .* (p_e_base .* E_base) ./ (P_C_base .* C_base);

        p_sh_pol = getvar(results.(scen), 'p_sharing') * (1 + params.t_c);
        welfare.cv_ev.(scen).(grp).CS_sharing = -(p_sh_pol ./ p_sh_base - 1) ...
            .* (p_sh_base .* ES_sharing_base) ./ (P_C_base .* C_base);

        p_nd_pol = getvar(results.(scen), 'p_nd_ati');
        welfare.cv_ev.(scen).(grp).CS_nondurable = -(p_nd_pol ./ p_nd_base - 1) ...
            .* (p_nd_base .* X_base) ./ (P_C_base .* C_base);
    end
end

%% ========================================================================
%  SECTION 5b: ENERGY SERVICES (ES) WELFARE ANALYSIS
%  ========================================================================
%
%   - ES-based snapshot CEV: how much more/less ES does the household get?
%   - ES-based Gini/Palma/Atkinson: inequality in energy services access

for s = 1:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});
    R = results.(scen);

    for g = 1:n_groups
        grp = groups{g};

        ES_h        = getvar(R, ['ES_' grp]);
        ES_home_h   = getvar(R, ['ES_home_' grp]);
        ES_sharing_h = getvar(R, ['ES_sharing_' grp]);
        welfare.es.(scen).(grp).ES              = ES_h;
        welfare.es.(scen).(grp).ES_home         = ES_home_h;
        welfare.es.(scen).(grp).ES_sharing      = ES_sharing_h;
        welfare.es.(scen).(grp).sharing_share   = ES_sharing_h ./ max(ES_h, 1e-15);

        if abs(sigma - 1) < 1e-8
            welfare.es.(scen).(grp).u_es = log(max(ES_h, 1e-15));
        else
            welfare.es.(scen).(grp).u_es = (max(ES_h, 1e-15).^(1-sigma)) / (1-sigma);
        end
    end

    omega_lc = getvar(R, 'omegga_lowcarbon');
    omega_ca = getvar(R, 'omegga_cautious');
    ES_agg = zeros(1, n_years);
    for t = 1:n_years
        olc = omega_lc(t); oca = omega_ca(t); oco = 1 - olc - oca;
        ES_agg(t) = olc * welfare.es.(scen).lowcarbon.ES(t) ...
                   + oca * welfare.es.(scen).cautious.ES(t) ...
                   + oco * welfare.es.(scen).constrained.ES(t);
    end
    welfare.es.(scen).ES_aggregate = ES_agg;
end

% ---- ES lifetime welfare (discounted from base_year) ----
for s = 1:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});

    for g = 1:n_groups
        grp = groups{g};
        u_es_path = welfare.es.(scen).(grp).u_es;
        welfare.es.(scen).(grp).V_es = sum(beta_vec .* u_es_path(base_idx:end));
    end

    omega_lc = getvar(results.(scen), 'omegga_lowcarbon');
    omega_ca = getvar(results.(scen), 'omegga_cautious');
    V_es_agg = 0;
    for t = base_idx:n_years
        olc = omega_lc(t); oca = omega_ca(t); oco = 1 - olc - oca;
        u_es_agg_t = olc * welfare.es.(scen).lowcarbon.u_es(t) ...
                   + oca * welfare.es.(scen).cautious.u_es(t) ...
                   + oco * welfare.es.(scen).constrained.u_es(t);
        V_es_agg = V_es_agg + beta^(t - base_idx) * u_es_agg_t;
    end
    welfare.es.(scen).V_es_aggregate = V_es_agg;
end

% ---- ES-based CEV (cross-scenario) ----
for s = 2:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});

    for g = 1:n_groups
        grp = groups{g};
        ES_base = welfare.es.(base).(grp).ES;
        ES_pol  = welfare.es.(scen).(grp).ES;
        welfare.es_cev.(scen).(grp).snapshot = ES_pol ./ ES_base - 1;
        V_es_base = welfare.es.(base).(grp).V_es;
        V_es_pol  = welfare.es.(scen).(grp).V_es;
        if abs(sigma - 1) < 1e-8
            welfare.es_cev.(scen).(grp).lifetime = exp((V_es_pol - V_es_base) / sum(beta_vec)) - 1;
        else
            welfare.es_cev.(scen).(grp).lifetime = (V_es_pol / V_es_base)^(1/(1-sigma)) - 1;
        end
    end

    V_es_base_agg = welfare.es.(base).V_es_aggregate;
    V_es_pol_agg  = welfare.es.(scen).V_es_aggregate;
    if abs(sigma - 1) < 1e-8
        welfare.es_cev.(scen).aggregate_lifetime = exp((V_es_pol_agg - V_es_base_agg) / sum(beta_vec)) - 1;
    else
        welfare.es_cev.(scen).aggregate_lifetime = (V_es_pol_agg / V_es_base_agg)^(1/(1-sigma)) - 1;
    end
end

% ---- ES-based Gini, Palma, Atkinson, and access gap ----
for s = 1:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});

    omega_lc = getvar(results.(scen), 'omegga_lowcarbon');
    omega_ca = getvar(results.(scen), 'omegga_cautious');

    Gini_es  = zeros(1, n_years);
    Palma_es = zeros(1, n_years);
    Atkinson_es = zeros(n_eps, n_years);
    access_gap = zeros(1, n_years);

    for t = 1:n_years
        olc = omega_lc(t); oca = omega_ca(t); oco = 1 - olc - oca;
        es_lc = welfare.es.(scen).lowcarbon.ES(t);
        es_ca = welfare.es.(scen).cautious.ES(t);
        es_co = welfare.es.(scen).constrained.ES(t);
        vals = [es_lc, es_ca, es_co];
        wgts = [olc, oca, oco];

        Gini_es(t)  = compute_gini(vals, wgts);
        Palma_es(t) = compute_palma(vals, wgts);

        for ae = 1:n_eps
            Atkinson_es(ae, t) = compute_atkinson(es_lc, es_ca, es_co, olc, oca, oco, atkinson_eps(ae));
        end

        access_gap(t) = es_co / max(es_lc, 1e-15);
    end

    welfare.es_distribution.(scen).Gini  = Gini_es;
    welfare.es_distribution.(scen).Palma = Palma_es;
    welfare.es_distribution.(scen).Atkinson_05 = Atkinson_es(1,:);
    welfare.es_distribution.(scen).Atkinson_10 = Atkinson_es(2,:);
    welfare.es_distribution.(scen).Atkinson_15 = Atkinson_es(3,:);
    welfare.es_distribution.(scen).Atkinson_20 = Atkinson_es(4,:);
    welfare.es_distribution.(scen).Atkinson_30 = Atkinson_es(5,:);
    welfare.es_distribution.(scen).access_gap = access_gap;
end

%% ========================================================================
%  SECTION 5b-FP: FOOTPRINT INEQUALITY (CF, WF, MF) — per-capita, rescaled CSV
%  ========================================================================
%   Gini/Palma/Atkinson on per-capita carbon (CF), waste (WF), material (MF)
%   footprints across household groups.

fp_specs = {'CF','cf_distribution'; 'WF','wf_distribution'; 'MF','mf_distribution'};

for fpi = 1:size(fp_specs,1)
    varbase  = fp_specs{fpi,1};
    distname = fp_specs{fpi,2};

    for s = 1:length(scenario_list)
        scen      = matlab.lang.makeValidName(scenario_list{s});
        scen_raw  = results.(scen).scenario;  

        omega_lc = getvar(results.(scen), 'omegga_lowcarbon');
        omega_ca = getvar(results.(scen), 'omegga_cautious');

        FP_lc = load_footprint_pc(scen_raw, varbase, 'lowcarbon');
        FP_ca = load_footprint_pc(scen_raw, varbase, 'cautious');
        FP_co = load_footprint_pc(scen_raw, varbase, 'constrained');

        Gini_fp  = zeros(1, n_years);
        Palma_fp = zeros(1, n_years);
        Atkinson_fp = zeros(n_eps, n_years);

        for t = 1:n_years
            olc = omega_lc(t); oca = omega_ca(t); oco = 1 - olc - oca;
            fp_lc = FP_lc(t); fp_ca = FP_ca(t); fp_co = FP_co(t);
            vals = [fp_lc, fp_ca, fp_co];
            wgts = [olc, oca, oco];

            Gini_fp(t)  = compute_gini(vals, wgts);
            Palma_fp(t) = compute_palma(vals, wgts);
            for ae = 1:n_eps
                Atkinson_fp(ae, t) = compute_atkinson(fp_lc, fp_ca, fp_co, olc, oca, oco, atkinson_eps(ae));
            end
        end

        welfare.(distname).(scen).Gini  = Gini_fp;
        welfare.(distname).(scen).Palma = Palma_fp;
        welfare.(distname).(scen).Atkinson_05 = Atkinson_fp(1,:);
        welfare.(distname).(scen).Atkinson_10 = Atkinson_fp(2,:);
        welfare.(distname).(scen).Atkinson_15 = Atkinson_fp(3,:);
        welfare.(distname).(scen).Atkinson_20 = Atkinson_fp(4,:);
        welfare.(distname).(scen).Atkinson_30 = Atkinson_fp(5,:);
    end
end

%% ========================================================================
%  SECTION 6: SUMMARY TABLE
%  ========================================================================

welfare.years = years;
welfare.groups = groups;
welfare.scenario_list = scenario_list;
welfare.base_year = base_year;
welfare.atkinson_eps = atkinson_eps;

fprintf('\n============================================================\n');
fprintf(' WELFARE ANALYSIS SUMMARY (all scenarios vs %s)\n', scenario_list{1});
fprintf(' Base year: %d | Discount from %d to 2100\n', base_year, base_year);
fprintf('============================================================\n\n');

yr_idx = @(yr) find(years == yr);
snapshot_years = [2030, 2040, 2050];

    function print_atkinson(dist_struct, scen_field, label)
        eps_labels = {'0.5', '1.0', '1.5', '2.0', '3.0'};
        field_suffixes = {'_05', '_10', '_15', '_20', '_30'};
        fprintf('  %s Atkinson (2018/2050):\n', label);
        for ae = 1:length(eps_labels)
            fn = ['Atkinson' field_suffixes{ae}];
            fprintf('    eps=%s:  %.4f / %.4f  (delta: %+.4f)\n', ...
                eps_labels{ae}, ...
                dist_struct.(scen_field).(fn)(yr_idx(2018)), ...
                dist_struct.(scen_field).(fn)(yr_idx(2050)), ...
                dist_struct.(scen_field).(fn)(yr_idx(2050)) - dist_struct.(scen_field).(fn)(yr_idx(2018)));
        end
    end

for s = 2:length(scenario_list)
    scen_name = scenario_list{s};
    scen = matlab.lang.makeValidName(scen_name);

    fprintf('--- %s ---\n', scen_name);
    fprintf('  Lifetime CEV (aggregate): %+.4f%%\n', welfare.cev.(scen).aggregate_lifetime * 100);
    fprintf('  Lifetime CEV by group:\n');
    for g = 1:n_groups
        grp = groups{g};
        fprintf('    %-12s: %+.4f%%\n', grp, welfare.cev.(scen).(grp).lifetime * 100);
    end

    fprintf('  Snapshot CEV (%%):');
    for y = snapshot_years
        fprintf('           Y%d', y);
    end
    fprintf('\n');
    for g = 1:n_groups
        grp = groups{g};
        fprintf('    %-12s:', grp);
        for y = snapshot_years
            ti = yr_idx(y);
            fprintf('     %+.4f%%', welfare.cev.(scen).(grp).snapshot(ti) * 100);
        end
        fprintf('\n');
    end

    % ---- Expenditure inequality ----
    fprintf('  --- Expenditure Inequality ---\n');
    fprintf('  Gini (2018/2050):    %.4f / %.4f  (delta: %+.4f)\n', ...
        welfare.distribution.(scen).Gini(yr_idx(2018)), ...
        welfare.distribution.(scen).Gini(yr_idx(2050)), ...
        welfare.distribution.(scen).Gini(yr_idx(2050)) - welfare.distribution.(scen).Gini(yr_idx(2018)));
    fprintf('  Palma (2018/2050):   %.4f / %.4f  (delta: %+.4f)\n', ...
        welfare.distribution.(scen).Palma(yr_idx(2018)), ...
        welfare.distribution.(scen).Palma(yr_idx(2050)), ...
        welfare.distribution.(scen).Palma(yr_idx(2050)) - welfare.distribution.(scen).Palma(yr_idx(2018)));
    print_atkinson(welfare.distribution, scen, 'Expenditure');

    % ---- Energy Services ----
    fprintf('  --- Energy Services Inequality ---\n');
    fprintf('  ES lifetime CEV (aggregate): %+.4f%%\n', welfare.es_cev.(scen).aggregate_lifetime * 100);
    fprintf('  ES lifetime CEV by group:\n');
    for g = 1:n_groups
        grp = groups{g};
        fprintf('    %-12s: %+.4f%%\n', grp, welfare.es_cev.(scen).(grp).lifetime * 100);
    end
    fprintf('  ES snapshot CEV (%%):');
    for y = snapshot_years
        fprintf('           Y%d', y);
    end
    fprintf('\n');
    for g = 1:n_groups
        grp = groups{g};
        fprintf('    %-12s:', grp);
        for y = snapshot_years
            ti = yr_idx(y);
            fprintf('     %+.4f%%', welfare.es_cev.(scen).(grp).snapshot(ti) * 100);
        end
        fprintf('\n');
    end
    fprintf('  ES Gini (2018/2050): %.4f / %.4f  (delta: %+.4f)\n', ...
        welfare.es_distribution.(scen).Gini(yr_idx(2018)), ...
        welfare.es_distribution.(scen).Gini(yr_idx(2050)), ...
        welfare.es_distribution.(scen).Gini(yr_idx(2050)) - welfare.es_distribution.(scen).Gini(yr_idx(2018)));
    fprintf('  ES Palma (2018/2050): %.4f / %.4f  (delta: %+.4f)\n', ...
        welfare.es_distribution.(scen).Palma(yr_idx(2018)), ...
        welfare.es_distribution.(scen).Palma(yr_idx(2050)), ...
        welfare.es_distribution.(scen).Palma(yr_idx(2050)) - welfare.es_distribution.(scen).Palma(yr_idx(2018)));
    print_atkinson(welfare.es_distribution, scen, 'ES');
    fprintf('  ES access gap (constrained/lowcarbon): %.4f -> %.4f\n', ...
        welfare.es_distribution.(scen).access_gap(yr_idx(2018)), ...
        welfare.es_distribution.(scen).access_gap(yr_idx(2050)));

    % ---- Carbon Footprint inequality per households----
    % ---- Footprint inequality (CF, WF, MF) ----
    fp_print = {'CF','cf_distribution','Carbon'; 'WF','wf_distribution','Waste'; 'MF','mf_distribution','Material'};
    for fpi = 1:size(fp_print,1)
        lbl  = fp_print{fpi,1};
        dn   = fp_print{fpi,2};
        full = fp_print{fpi,3};
        fprintf('  --- %s Footprint Inequality (per capita) ---\n', full);
        fprintf('  %s Gini (2018/2050): %.4f / %.4f  (delta: %+.4f)\n', lbl, ...
            welfare.(dn).(scen).Gini(yr_idx(2018)), ...
            welfare.(dn).(scen).Gini(yr_idx(2050)), ...
            welfare.(dn).(scen).Gini(yr_idx(2050)) - welfare.(dn).(scen).Gini(yr_idx(2018)));
        fprintf('  %s Palma (2018/2050): %.4f / %.4f  (delta: %+.4f)\n', lbl, ...
            welfare.(dn).(scen).Palma(yr_idx(2018)), ...
            welfare.(dn).(scen).Palma(yr_idx(2050)), ...
            welfare.(dn).(scen).Palma(yr_idx(2050)) - welfare.(dn).(scen).Palma(yr_idx(2018)));
        print_atkinson(welfare.(dn), scen, lbl);
    end
end

fprintf('============================================================\n');

end