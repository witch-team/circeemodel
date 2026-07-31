%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation routine over 82 periods = 2018–2100. Discard 2081–2100 (added to avoid end-of-horizon spikes)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = CIRCEE_RunFile(varargin)

function val = extractMacro(filePath, macroName)
    fid = fopen(filePath, 'r');
    if fid == -1
        error('Could not open file: %s', filePath);
    end
    val = '';
    pat = ['@#define\s+' macroName '\s*=\s*"([^"]+)"'];
    while ~feof(fid)
        line = fgetl(fid);
        if contains(line, ['@#define ' macroName])
            tokens = regexp(line, pat, 'tokens');
            if ~isempty(tokens)
                val = tokens{1}{1};
                break;
            end
        end
    end
    fclose(fid);
    if isempty(val)
        error('%s not defined in %s', macroName, filePath);
    end
end

function rowOut = pickRow(charTable, varName, regionType)
    rows = charTable(strcmp(charTable.Variable, varName), :);
    if isempty(rows)
        rowOut = rows; return;
    end

    hasRegion = any(strcmpi(rows.Properties.VariableNames,'Region'));
    if ~hasRegion, rows.Region = repmat({''}, height(rows), 1); end

    isRegion  = @(x) strcmpi(x, regionType);
    isAll     = @(x) strcmpi(x,'ALL') | strcmp(x,'');

    pref = { @(r) isRegion(r.Region);
             @(r) isAll(r.Region) };

    rowOut = rows(1,:); found = false;
    for k = 1:numel(pref)
        idx = find(pref{k}(rows), 1, 'first');
        if ~isempty(idx)
            rowOut = rows(idx,:); found = true; break;
        end
    end
    if ~found
        rowOut = rows(1,:);
    end
end

mode = 'classic';
modFile = 'CIRCEE_PF.mod';
regionType = extractMacro(modFile, 'REGION');

if nargin >= 1 && ~isempty(varargin{1}), mode = varargin{1}; end
if nargin >= 2 && ~isempty(varargin{2}), regionType = varargin{2}; end

envVal = getenv('CIRCEE_MODE');         if ~isempty(envVal) && nargin < 1, mode       = envVal; end
envVal = getenv('CIRCEE_REGION');       if ~isempty(envVal) && nargin < 2, regionType = envVal; end

if strcmp(mode, 'calibration')
    disp('Running in calibration mode...');
    outputFolder = '../results/grid_point_data';
    if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
    shocksfile = fullfile('../results/grid_point_data', 'shocks.csv');
else
    disp('Running in classic mode...');
    outputFolder = '../results';
    if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
    shocksfile = ['../data/' regionType '/raw/shocks.csv'];
end

selectedScenario = getenv('CIRCEE_SSP_SCENARIO');
if isempty(selectedScenario), selectedScenario = 'SSP2'; 
end

global M_;
global oo_;

optsChar = detectImportOptions(['../data/' regionType '/raw/calibration.csv'],'Delimiter',';');
optsChar = setvartype(optsChar, 'char');
calibChar = readtable(['../data/' regionType '/raw/calibration.csv'], optsChar);
calibNum  = readtable(['../data/' regionType '/raw/calibration.csv'], 'Delimiter',';');

hasRegionCol = any(strcmpi(calibChar.Properties.VariableNames,'Region'));

isScenario_char = strcmp(calibChar.Scenario, selectedScenario);
isScenario_num = strcmp(calibNum.Scenario, selectedScenario);

isModel_char = true(size(calibChar,1),1);
isModel_num = true(size(calibNum,1),1);

if hasRegionCol
    isRegion_char = strcmpi(calibChar.Region, regionType) | strcmpi(calibChar.Region,'ALL') | strcmp(calibChar.Region,'');
    isRegion_num = strcmpi(calibNum.Region, regionType) | strcmpi(calibNum.Region,'ALL') | strcmp(calibNum.Region,'');
else
    isRegion_char = true(size(calibChar,1),1);
    isRegion_num = true(size(calibNum,1),1);
end

calibFilteredChar = calibChar(isScenario_char & isModel_char & isRegion_char, :);
calibFilteredNum = calibNum(isScenario_num & isModel_num & isRegion_num, :);

% ============================================================
% FORESIGHT MODE
% 'perfect_foresight'  : sigma/alppha and energy shocks fully anticipated from period 1
% 'anticipation_errors': sigma/alppha and energy shocks revealed period by period (myopic)
% ============================================================
foresight_mode = getenv('CIRCEE_FORESIGHT');
if isempty(foresight_mode), foresight_mode = 'perfect_foresight'; end
fprintf('Foresight mode : %s\n', foresight_mode);

% ============================================================
% SCENARIO DEFINITION for ECOSYSTEM CHANGES
% ============================================================
% Selected via env var CIRCEE_SIGMA_SCENARIO from config.sh.
% Each branch sets:
%   sigma_steady_state    - homogeneous sigma forced at year 2018 (required
%                           by Dynare's steady-state solver - different
%                           sigma per group is intractable at steady state)
%   sigma_common_terminal - long-run terminal sigma (post 2099) all groups
%                           reconverge to. Chosen for numerical feasibility,
%                           not economic interpretation (paper reports
%                           through 2049 only).
%   sigma_spec.<group>    - either a scalar (constant ramp.terminal, with
%                           default_ramp baseline/start/end) or a struct
%                           {baseline, terminal, start_year, end_year}.

sigma_scenario = getenv('CIRCEE_SIGMA_SCENARIO');
if isempty(sigma_scenario), sigma_scenario = 'Baseline'; end

switch sigma_scenario
    case 'Baseline'
        sigma_steady_state    = 1.1;
        sigma_common_terminal = 1.1;
        sigma_spec.lowcarbon   = 1.9;
        sigma_spec.cautious    = 1.5;
        sigma_spec.constrained = 1.1;
        default_ramp = struct('baseline', 1.1, 'start_year', 2024, 'end_year', 2050);
        alpha_home_ss    = 9.42504362208295E-01;
        alpha_sharing_ss = 8.17702473176507E-02;

    case 'Progressive'
        sigma_steady_state    = 1.1;
        sigma_common_terminal = 2.5;
        sigma_spec.lowcarbon   = struct('baseline',1.9,'terminal',2.5,'start_year',2024,'end_year',2050);
        sigma_spec.cautious    = struct('baseline',1.5,'terminal',3.5,'start_year',2024,'end_year',2050);
        sigma_spec.constrained = struct('baseline',1.1,'terminal',4.0,'start_year',2024,'end_year',2050);
        default_ramp = struct('baseline', 1.1, 'start_year', 2024, 'end_year', 2050);
        alpha_home_ss    = 9.42504362208295E-01;
        alpha_sharing_ss = 8.17702473176507E-02;

    case 'Regressive'
        sigma_steady_state    = 1.1;
        sigma_common_terminal = 2.5;
        sigma_spec.lowcarbon   = struct('baseline',1.9,'terminal',4.0,'start_year',2024,'end_year',2050);
        sigma_spec.cautious    = struct('baseline',1.5,'terminal',3.0,'start_year',2024,'end_year',2050);
        sigma_spec.constrained = struct('baseline',1.1,'terminal',2.5,'start_year',2024,'end_year',2050);
        default_ramp = struct('baseline', 1.1, 'start_year', 2024, 'end_year', 2050);
        alpha_home_ss    = 9.42504362208295E-01;
        alpha_sharing_ss = 8.17702473176507E-02;

    case 'Custom'
    sigma_val        = str2double(getenv('CIRCEE_SIGMA_VALUE'));
    alpha_home_ss    = str2double(getenv('CIRCEE_ALPHA_HOME'));
    alpha_sharing_ss = str2double(getenv('CIRCEE_ALPHA_SHARING'));
    sigma_steady_state    = sigma_val;
    sigma_common_terminal = sigma_val;
    sigma_spec.lowcarbon   = sigma_val;
    sigma_spec.cautious    = sigma_val;
    sigma_spec.constrained = sigma_val;
    default_ramp = struct('baseline', sigma_val, 'start_year', 2018, 'end_year', 2018);
    otherwise
        error('Unknown CIRCEE_SIGMA_SCENARIO: %s', sigma_scenario);
end

% ====== % 
% Y2018  % 
% ====== % 
anchor.p_home    = 0.999999999999997;
anchor.p_sharing = 1.000000000000004;
anchor.t_c       = 0.099;
data.lowcarbon   = struct('ES_home',0.058828474748748,'ES_sharing',0.003602742837743,'modifier_2018',0.0);
data.cautious    = struct('ES_home',0.050407028301444,'ES_sharing',0.003087000996720,'modifier_2018',0.0);
data.constrained = struct('ES_home',0.043432179341456,'ES_sharing',0.002659850926244,'modifier_2018',0.0);
baseline.lowcarbon   = struct('alpha_home',alpha_home_ss,'alpha_sharing',alpha_sharing_ss);
baseline.cautious    = baseline.lowcarbon;
baseline.constrained = baseline.lowcarbon;

%% -------- 1) Calibration block (CIRCEE_calibration.m) --------
variablesOfInterest = {'Y_sharing_ss','deltta_energydurable_gov', 'material_int_nondurable','material_int_otherdurable','material_int_energydurable','material_int_capital','gamma_energydurable','gamma_otherdurable','gamma_nondurable','gamma_capital','margin_capital', 'margin_nondurable', 'margin_otherdurable', 'margin_energydurable','gamma_reexport_capital', 'gamma_reexport_nondurable', 'gamma_reexport_otherdurable', 'gamma_reexport_energydurable','t_imports_capital','t_imports_nondurable','t_imports_otherdurable','t_imports_energydurable','alppha_k_powercapacities','t_el_f','t_el_h','gamma_virgin','gamma_recycled','omegga_mun_recycled','omegga_ind_recycled','Foreign_nondurable', 'Foreign_otherdurable', 'Foreign_energydurable', 'Foreign_capital', 'Foreign_virgin', 'Foreign_recycled','siggma_dep_lowuse','siggma_dep','siggma_imports', 'siggma_exports', 'siggma_c', 'siggma_home', 'siggma_y', 'siggma_kl', 'siggma_e_f', 'siggma_e_recycled', 'siggma_e_virgin', 'siggma_m', 'siggma_z', 'siggma_e_h', 'siggma_sharing', 'siggma_ies', 'siggma_nes', 'siggma_inv_ed', 'ac_ik', 'ac_id', 'p_capital_norm', 'decay_mu', 'decay_indu',  't_c', 't_k', 't_l', 'g_c_nondurable', 'g_c_otherdurable', 'g_c_energydurable',...
 'Demand_foreign_virgin','Demand_foreign_recycled','alppha_n_nondurable', 'alppha_k_nondurable', 'alppha_n_otherdurable', 'alppha_k_otherdurable', 'alppha_n_energydurable', 'alppha_k_energydurable', 'alppha_n_capital', 'alppha_k_capital', 'alppha_n_virgin', 'alppha_k_virgin', 'alppha_n_recycled', 'alppha_k_recycled', 'alppha_n_repair', 'alppha_k_repair', 'alppha_kl_nondurable', 'alppha_e_nondurable', 'alppha_kl_otherdurable', 'alppha_e_otherdurable', 'alppha_kl_energydurable', 'alppha_e_energydurable',...
 'alppha_kl_capital', 'alppha_e_capital', 'alppha_kl_virgin', 'alppha_e_virgin', 'alppha_kl_recycled', 'alppha_e_recycled', 'alppha_z_nondurable', 'alppha_m_nondurable', 'alppha_z_otherdurable', 'alppha_m_otherdurable', 'alppha_z_energydurable', 'alppha_m_energydurable', 'alppha_z_capital', 'alppha_m_capital', 'alppha_z_virgin', 'alppha_rm', 'alppha_z_recycled', 'alppha_rw','h_nondurable','h_otherdurable','h_energydurable','h_capital','h_repair','h_virgin','h_recycled','h_sharing',...
 'betta','share_domestic_nondurable','share_domestic_otherdurable','share_domestic_energydurable','share_domestic_capital','share_domestic_virgin','share_domestic_recycled','share_imp_nondurable','share_imp_otherdurable','share_imp_energydurable','share_imp_capital','share_imp_virgin','share_imp_recycled','share_row_nondurable','share_row_otherdurable','share_row_energydurable','share_row_capital','share_row_virgin','share_row_recycled',...
 'share_row_dom_nondurable','share_row_dom_otherdurable','share_row_dom_energydurable','share_row_dom_capital','Demand_foreign_capital','Demand_foreign_otherdurable','Demand_foreign_nondurable','Demand_foreign_energydurable','tax_other','Tr','habit_lowcarbon','habit_cautious','habit_constrained','share_savings_cautious','p_fg_row',...
 'deltta_capital_fix','deltta_capital_physical','deltta_energydurable_fix','deltta_otherdurable_fix','deltta_energydurable_physical','deltta_otherdurable_physical','deltta_nondurable_fix','alppha_ed_sharing','alppha_e_sharing','alppha_es_sharing','alppha_n_sharing','alppha_nes','alppha_es','alppha_x','alppha_od','alppha_ed_new_lowcarbon','alppha_ed_new_cautious','alppha_ed_new_constrained','alppha_ed_repair_lowcarbon','alppha_ed_repair_cautious','alppha_ed_repair_constrained',...
 'alppha_v_nondurable','alppha_v_otherdurable','alppha_v_energydurable','alppha_v_capital','alppha_r_nondurable','alppha_r_otherdurable','alppha_r_energydurable','alppha_r_capital','alppha_el_recycled','alppha_nel_recycled','alppha_el_virgin','alppha_nel_virgin','alppha_el_capital','alppha_nel_capital','alppha_el_energydurable','alppha_nel_energydurable','alppha_el_otherdurable','alppha_nel_otherdurable','alppha_el_nondurable','alppha_nel_nondurable','alppha_el_sharing','alppha_nel_sharing',...
 'alppha_ed','alppha_e','alppha_el_lowcarbon','alppha_el_cautious','alppha_el_constrained','alppha_nel_lowcarbon','alppha_nel_cautious','alppha_nel_constrained','n','g','p_el_h_2018','p_el_f_2018','p_nel_h_2018','p_nel_f_2018', ...
 'cost_maintenance'};

fid = fopen('CIRCEE_calibration.m', 'w');
uvars = unique(calibFilteredChar.Variable);
for k = 1:numel(uvars)
    v = uvars{k};
    if ~ismember(v, variablesOfInterest), continue; end
    rowUse = pickRow(calibFilteredChar, v, regionType);
    if ~isempty(rowUse)
        fprintf(fid, '%s = %s;\n', rowUse.Variable{1}, rowUse.Value{1});
    end
end
fclose(fid);

%% -------- 2) Initval block (CIRCEE_baseyear_values.m) --------
includedVars = {'etta','subsidies','eppsilon','Error_stock_otherdurable','Error_stock_energydurable','Error_stock_capital','Inv_RDEN_EE',' Inv_k_powercapacities','modifier_expenditures_cautious','modifier_expenditures_constrained','modifier_expenditures_lowcarbon','modifier_repair_cautious','modifier_repair_constrained','modifier_repair_lowcarbon','modifier_sharing_cautious','modifier_sharing_constrained','modifier_sharing_lowcarbon','A_m_nondurable','A_m_otherdurable','A_m_energydurable','A_m_capital','t_c_reduced',...
'repair_ed_bonus','mu_share','omegga_lowcarbon','omegga_cautious','epr_fee_otherdurable','epr_fee_energydurable',...
'c_m','A_el_WITCH','A_nel_WITCH','t_nel_h','t_nel_f','p_virgin','p_recycled','t_m','t_w','p_rawmaterials','redistribution','redistribution_epr','g_nel_witch','g_el_witch','emissions_el_WITCH','emissions_nel_WITCH'};

fileID = fopen('CIRCEE_baseyear_values.m', 'w');
for i = 1:length(includedVars)
    varName = includedVars{i};
    rowUse = pickRow(calibFilteredChar, varName, regionType);
    if ~isempty(rowUse)
        valueAsText = string(rowUse.Value);
        fprintf(fileID, '%s = %s;\n', varName, valueAsText);
    end
end

grps = {'lowcarbon','cautious','constrained'};
for g = 1:length(grps)
    grp = grps{g};
    fprintf(fileID, 'siggma_es_%s = %.15g;\n',       grp, sigma_steady_state);
    fprintf(fileID, 'alppha_home_%s = %.15g;\n',     grp, alpha_home_ss);
    fprintf(fileID, 'alppha_sharing_%s = %.15g;\n',  grp, alpha_sharing_ss);
end

fclose(fileID);

%% -------- 3) Shocks / exogenous --------
% 3.1 build constants-through-time from calibration. Here exogenous variables that are constant over time are stacked with shocks so Dynare receives
% a single unified path for all exogenous variables (mergedTable → data_shocks.csv)
constVars = {'A_m_nondurable','A_m_otherdurable','A_m_energydurable','A_m_capital','c_m','p_virgin','p_recycled','t_m','t_w','p_rawmaterials'};
years = (2019:2100)';

calibrationVariableCell = {};
calibrationYearCell = [];
calibrationValueCell = [];

for i = 1:length(constVars)
    v = constVars{i};
    rowUse = pickRow(calibFilteredChar, v, regionType);
    if ~isempty(rowUse)
        vVal = str2double(rowUse.Value);
    else
        vVal = NaN;
    end
    calibrationVariableCell = [calibrationVariableCell; repmat({v}, numel(years), 1)];
    calibrationYearCell = [calibrationYearCell; years];
    calibrationValueCell = [calibrationValueCell; repmat(vVal, numel(years), 1)];
end

calibrationTable = table(calibrationVariableCell, calibrationYearCell, calibrationValueCell, ...
                         'VariableNames', {'Variable','Year','Value'});

% 3.1.b read shocks.csv
raw = readtable(shocksfile, 'Delimiter',';', 'ReadVariableNames', true);

if ~all(ismember({'Variable','Year','Value'}, raw.Properties.VariableNames))
    raw = readtable(shocksfile, 'Delimiter',';', 'ReadVariableNames', false);
    if width(raw) >= 3
        raw.Properties.VariableNames(1:3) = {'Variable','Year','Value'};
        if width(raw) >= 4, raw.Properties.VariableNames{4} = 'Region'; end
        if width(raw) >= 5, raw.Properties.VariableNames{5} = 'Scenario'; end
    end
end

if any(strcmpi(raw.Variable,'Variable'))
    raw(strcmpi(raw.Variable,'Variable'),:) = [];
end

hasRegion_sh = any(strcmpi(raw.Properties.VariableNames,'Region'));
hasScen_sh = any(strcmpi(raw.Properties.VariableNames,'Scenario'));

if hasRegion_sh
    keepR = strcmpi(raw.Region, regionType) | strcmpi(raw.Region,'ALL') | strcmp(raw.Region,'');
else
    keepR = true(height(raw),1);
end
if hasScen_sh
    keepS = strcmpi(raw.Scenario, selectedScenario) | strcmpi(raw.Scenario,'ALL') | strcmp(raw.Scenario,'');
else
    keepS = true(height(raw),1);
end

shockTable = raw(keepR & keepS, :);
shockTable = shockTable(:, intersect({'Variable','Year','Value'}, shockTable.Properties.VariableNames));
mergedTable = [calibrationTable; shockTable];

% 3.1.2 scripted time paths
variables = struct('t_nel_h',0.872085900719203, 't_nel_f',0.524974380084049, 'epr_fee_energydurable', 0.041304983233002600,...
                   'epr_fee_otherdurable',0.00329413285147989, 't_c_reduced',0.099, ...
                   'repair_ed_bonus',0);
growthRates = struct(...
 't_nel_h',           [repmat(0,1,3), repmat(0,1,25), repmat(0,1,3), repmat(0,1,50)], ...
 't_nel_f',           [repmat(0,1,3), repmat(0,1,25), repmat(0,1,3), repmat(0,1,50)], ...
 'epr_fee_otherdurable',[repmat(0,1,3), repmat(0,1,25), repmat(0,1,3), repmat(0,1,50)], ...
 't_c_reduced',       [repmat(0,1,3), repmat(0,1,25), repmat(0,1,3), repmat(0,1,50)], ...
 'repair_ed_bonus',   [repmat(0,1,3), repmat(0,1,25), repmat(0,1,3), repmat(0,1,50)], ...
 'epr_fee_energydurable',[repmat(0,1,1), repmat(0,1,40), repmat(0,1,30)] ...
);

for year = 2019:2100
    period = year - 2018;
    if year < 2025
        variables.repair_ed_bonus = 0;
    elseif year == 2025
        variables.repair_ed_bonus = 0;
    else
        index = period - 7;
        variables.repair_ed_bonus = variables.repair_ed_bonus * (1 + growthRates.repair_ed_bonus(index));
    end
    mergedTable = [mergedTable; {'repair_ed_bonus', year, variables.repair_ed_bonus}];

    fns = fieldnames(variables);
    for ii = 1:numel(fns)
        varName = fns{ii};
        if strcmp(varName,'repair_ed_bonus'), continue; end
        index = year - 2018;
        gr = growthRates.(varName);
        grUse = gr(max(1, min(index, numel(gr))));
        variables.(varName) = variables.(varName) * (1 + grUse);
        mergedTable = [mergedTable; {varName, year, variables.(varName)}];
    end
end

eppsilon = { [2018,2018],1; [2019,2024],0; [2025,2080],0; [2081,2100],1};
for year = 2019:2100
    for i = 1:size(eppsilon,1)
        yr = eppsilon{i,1}; val = eppsilon{i,2};
        if year>=yr(1) && year<=yr(2)
            mergedTable = [mergedTable; {'eppsilon', year, val}];
        end
    end
end

redistribution_pattern_carbon = { [2018,2018],0; [2019,2024],0; [2025,2100],0};
for year = 2019:2100
    for i = 1:size(redistribution_pattern_carbon,1)
        yr = redistribution_pattern_carbon{i,1}; val = redistribution_pattern_carbon{i,2};
        if year>=yr(1) && year<=yr(2)
            mergedTable = [mergedTable; {'redistribution', year, val}];
        end
    end
end

redistribution_pattern_epr = { [2018,2018],0; [2019,2024],0; [2025,2099],0; [2100,2100],0 };
for year = 2019:2100
    for i = 1:size(redistribution_pattern_epr,1)
        yr = redistribution_pattern_epr{i,1}; val = redistribution_pattern_epr{i,2};
        if year>=yr(1) && year<=yr(2)
            mergedTable = [mergedTable; {'redistribution_epr', year, val}];
        end
    end
end

Error_stock_capital_pattern = { [2018,2018], -2.7948727140160E-01; [2019,2099],0 };
for year = 2019:2100
    for i = 1:size(Error_stock_capital_pattern,1)
        yr = Error_stock_capital_pattern{i,1}; val = Error_stock_capital_pattern{i,2};
        if year>=yr(1) && year<=yr(2)
            mergedTable = [mergedTable; {'Error_stock_capital', year, val}];
        end
    end
end

Error_stock_otherdurable_pattern = { [2018,2018], 0.082689526434680; [2019,2099],0 };
for year = 2019:2100
    for i = 1:size(Error_stock_otherdurable_pattern,1)
        yr = Error_stock_otherdurable_pattern{i,1}; val = Error_stock_otherdurable_pattern{i,2};
        if year>=yr(1) && year<=yr(2)
            mergedTable = [mergedTable; {'Error_stock_otherdurable', year, val}];
        end
    end
end

Error_stock_energydurable_pattern = { [2018,2018], 0.7922397516218E-03; [2019,2099],0 };
for year = 2019:2100
    for i = 1:size(Error_stock_energydurable_pattern,1)
        yr = Error_stock_energydurable_pattern{i,1}; val = Error_stock_energydurable_pattern{i,2};
        if year>=yr(1) && year<=yr(2)
            mergedTable = [mergedTable; {'Error_stock_energydurable', year, val}];
        end
    end
end

etta_pattern = { [2018,2100], 0 };
for year = 2019:2100
    for i = 1:size(etta_pattern,1)
        yr = etta_pattern{i,1}; val = etta_pattern{i,2};
        if year>=yr(1) && year<=yr(2)
            mergedTable = [mergedTable; {'etta', year, val}];
        end
    end
end

% ============ %
% BUILD PATHS  %
% ============ %
years_all = 2018:2099;
n_years   = length(years_all);
lifestyle_groups = {'lowcarbon','cautious','constrained'};
reconverge_start_year = 2080;
reconverge_end_year   = 2099;

sigma_store         = struct();
alpha_home_store    = struct();
alpha_sharing_store = struct();

if strcmp(sigma_scenario, 'Baseline')
    for g = 1:length(lifestyle_groups)
        grp = lifestyle_groups{g};
        peak_sigma = sigma_spec.(grp);
        ramp_start_year = 2080;
        ramp_end_year = 2099;
        
        sigma_path = zeros(n_years,1);
        for k = 1:n_years
            yr = years_all(k);
            if yr == 2018
                sigma_path(k) = 1.1;
            elseif yr < ramp_start_year
                sigma_path(k) = peak_sigma;
            elseif yr < ramp_end_year
                frac = (yr - ramp_start_year) / (ramp_end_year - ramp_start_year);
                sigma_path(k) = peak_sigma + frac * (1.1 - peak_sigma);
            else
                sigma_path(k) = 1.1;
            end
        end
        
        rho_base = (sigma_steady_state - 1) / sigma_steady_state;
        ES_rho_base = baseline.(grp).alpha_home * data.(grp).ES_home^rho_base ...
                    + (1 - data.(grp).modifier_2018) ...
                      * baseline.(grp).alpha_sharing * data.(grp).ES_sharing^rho_base;
        ES_agg_2018_grp = ES_rho_base ^ (1/rho_base);
        
        price_term = anchor.p_home / (anchor.p_sharing * (1 + anchor.t_c));
        quantity_ratio = data.(grp).ES_home / data.(grp).ES_sharing;
        mod_grp = data.(grp).modifier_2018;
        
        alpha_home_path = zeros(n_years,1);
        alpha_sharing_path = zeros(n_years,1);
        
        for k = 1:n_years
            sig = sigma_path(k);
            rho = (sig - 1) / sig;
            alpha_ratio = price_term * (quantity_ratio^(1/sig)) / (1 - mod_grp);
            ES_rho = ES_agg_2018_grp ^ rho;
            ES_home_rho = data.(grp).ES_home ^ rho;
            ES_sharing_rho = data.(grp).ES_sharing ^ rho;
            alpha_sharing_path(k) = ES_rho/(alpha_ratio*ES_home_rho+(1-mod_grp)*ES_sharing_rho);
            alpha_home_path(k) = alpha_ratio * alpha_sharing_path(k);
        end

        sigma_store.(grp)         = sigma_path;
        alpha_home_store.(grp)    = alpha_home_path;
        alpha_sharing_store.(grp) = alpha_sharing_path;

        if strcmp(foresight_mode, 'perfect_foresight')
            for k = 1:n_years
                yr = years_all(k);
                mergedTable = [mergedTable; ...
                    {sprintf('siggma_es_%s',      grp), yr, sigma_path(k)}; ...
                    {sprintf('alppha_home_%s',    grp), yr, alpha_home_path(k)}; ...
                    {sprintf('alppha_sharing_%s', grp), yr, alpha_sharing_path(k)}];
            end
        end
    end
    
else

    for g = 1:length(lifestyle_groups)
        grp  = lifestyle_groups{g};
        spec = sigma_spec.(grp);

        if isstruct(spec)
            ramp = spec;
        else
            ramp = default_ramp;
            ramp.terminal = spec;
        end

        sigma_path = zeros(n_years,1);
        for k = 1:n_years
            yr = years_all(k);
            if yr == 2018
                sigma_path(k) = sigma_steady_state;
            elseif yr < ramp.start_year
                sigma_path(k) = ramp.baseline;
            elseif yr < ramp.end_year
                frac = (yr - ramp.start_year) / (ramp.end_year - ramp.start_year);
                sigma_path(k) = ramp.baseline + frac*(ramp.terminal - ramp.baseline);
            elseif yr < reconverge_start_year
                sigma_path(k) = ramp.terminal;
            elseif yr < reconverge_end_year
                frac = (yr - reconverge_start_year) / (reconverge_end_year - reconverge_start_year);
                sigma_path(k) = ramp.terminal + frac*(sigma_common_terminal - ramp.terminal);
            else
                sigma_path(k) = sigma_common_terminal;
            end
        end

        rho_base = (sigma_steady_state - 1) / sigma_steady_state;
        ES_rho_base = baseline.(grp).alpha_home    * data.(grp).ES_home^rho_base ...
                    + (1 - data.(grp).modifier_2018) ...
                      * baseline.(grp).alpha_sharing * data.(grp).ES_sharing^rho_base;
        ES_agg_2018_grp = ES_rho_base ^ (1/rho_base);
        price_term     = anchor.p_home / (anchor.p_sharing * (1 + anchor.t_c));
        quantity_ratio = data.(grp).ES_home / data.(grp).ES_sharing;
        mod_grp        = data.(grp).modifier_2018;
        alpha_home_path    = zeros(n_years,1);
        alpha_sharing_path = zeros(n_years,1);

        for k = 1:n_years
            sig = sigma_path(k);
            rho = (sig - 1) / sig;
            alpha_ratio    = price_term * (quantity_ratio^(1/sig)) / (1 - mod_grp);
            ES_rho         = ES_agg_2018_grp          ^ rho;
            ES_home_rho    = data.(grp).ES_home       ^ rho;
            ES_sharing_rho = data.(grp).ES_sharing    ^ rho;
            alpha_sharing_path(k) = ES_rho / (alpha_ratio*ES_home_rho ...
                                    + (1-mod_grp)*ES_sharing_rho);
            alpha_home_path(k)    = alpha_ratio * alpha_sharing_path(k);
        end

        sigma_store.(grp)         = sigma_path;
        alpha_home_store.(grp)    = alpha_home_path;
        alpha_sharing_store.(grp) = alpha_sharing_path;

        if strcmp(foresight_mode, 'perfect_foresight')
            for k = 1:n_years
                yr = years_all(k);
                mergedTable = [mergedTable; ...
                    {sprintf('siggma_es_%s',      grp), yr, sigma_path(k)}; ...
                    {sprintf('alppha_home_%s',    grp), yr, alpha_home_path(k)}; ...
                    {sprintf('alppha_sharing_%s', grp), yr, alpha_sharing_path(k)}];
            end
        end
    end
end

% Carbon tax: fully anticipated in both modes — write full path to mergedTable
%tax_path = [0.872085901, 0.872085901, 0.872085901, 0.872085901, 0.872085901, 0.872085901, ...
%            0.959294491, 1.05522394,  1.160746334, 1.276820967, 1.404503064, 1.54495337, ...
%            1.699448707, 1.869393578, 2.056332936, 2.26196623,  2.488162853, 2.736979138, ...
%            3.010677052, 3.311744757, 3.642919232, 4.007211156, 4.407932271, 4.848725498, ...
%            5.333598048, 5.866957853, 6.453653638, 7.099019002, 7.808920902, 8.589812992, ...
%            9.448794292, 10.39367372, repmat(10.39367372, 1, 50)];

%for year = 2019:2100
%    p   = year - 2018;
%    val = tax_path(min(p, numel(tax_path)));
%    mergedTable = [mergedTable; {'t_nel_h', year, val}];
%end

% Written to src/ (CWD) because Dynare must find it in the same
% directory as CIRCEE_PF.mod — do not redirect to results/

writetable(mergedTable, 'data_shocks.csv');

% 3.2 shocks block file for Dynare
% -----------------------------------------------------------------------
% Variables subject to anticipation errors (anticipation_errors mode only):
%   - siggma_es, alppha_home, alppha_sharing  (ecosystem transition)
%   - A_nel_WITCH, A_el_WITCH, g_nel_witch, g_el_witch  (energy tech)
%
% In perfect_foresight mode: all vars go into shocks(learnt_in=1) with
% their full paths — no learnt_in=p blocks.
%
% In anticipation_errors mode:
%   - Standard vars: full path in shocks(learnt_in=1)
%   - Anticipation vars: period-1 value (permanent assumption) in
%     shocks(learnt_in=1), then updated each period via learnt_in=p
%     blocks wherever any value actually changes (change detection).
% -----------------------------------------------------------------------

sigma_alppha_vars      = {'siggma_es_lowcarbon','siggma_es_cautious','siggma_es_constrained', ...
                          'alppha_home_lowcarbon','alppha_home_cautious','alppha_home_constrained', ...
                          'alppha_sharing_lowcarbon','alppha_sharing_cautious','alppha_sharing_constrained'};

tech_anticipation_vars = {'A_nel_WITCH','A_el_WITCH','g_nel_witch','g_el_witch'};

all_anticipation_vars  = [sigma_alppha_vars, tech_anticipation_vars];

data_shocks = readtable('data_shocks.csv');
var_names   = unique(data_shocks{:,1});

% ------------------------------------------------------------------
% Build tech_paths lookup (always, so it is available in both modes)
% ------------------------------------------------------------------
tech_paths = struct();
for i = 1:length(tech_anticipation_vars)
    vn    = tech_anticipation_vars{i};
    vkey  = matlab.lang.makeValidName(vn);
    vdata = data_shocks(strcmp(data_shocks{:,1}, vn), :);
    vdata = sortrows(vdata, 2);
    path  = NaN(82,1);
    for pp = 1:82
        yr  = 2018 + pp;
        row = vdata(vdata{:,2} == yr, :);
        if ~isempty(row), path(pp) = row.Value(1); end
    end
    for pp = 2:82
        if isnan(path(pp)), path(pp) = path(pp-1); end
    end
    tech_paths.(vkey) = path;
end

% ------------------------------------------------------------------
% Change-detection helpers (used only in anticipation_errors mode)
% ------------------------------------------------------------------
sigma_changed_at = @(p) any(cellfun(@(grp) ...
    abs(sigma_store.(grp)(min(p+1,n_years)) - sigma_store.(grp)(min(p,n_years))) > 1e-12 || ...
    abs(alpha_home_store.(grp)(min(p+1,n_years)) - alpha_home_store.(grp)(min(p,n_years))) > 1e-12, ...
    lifestyle_groups));

tech_changed_at = @(p) any(cellfun(@(vn) ...
    abs(tech_paths.(matlab.lang.makeValidName(vn))(p) - ...
        tech_paths.(matlab.lang.makeValidName(vn))(max(p-1,1))) > 1e-12, ...
    tech_anticipation_vars));

last_change_p = 1;
for p = 2:82
    if sigma_changed_at(p) || tech_changed_at(p)
        last_change_p = p;
    end
end
fprintf('  Anticipation errors: writing learnt_in blocks up to period %d (year %d)\n', ...
        last_change_p, 2018 + last_change_p);

% ------------------------------------------------------------------
% Write shocks(learnt_in=1) — single block
% ------------------------------------------------------------------
vfmt = @(v,n) strjoin(arrayfun(@(x) sprintf('%.15g',x), ...
               repmat(v,1,n), 'UniformOutput',false), ',');

fid = fopen('CIRCEE_shocks.m','w');
fprintf(fid, 'shocks(learnt_in=1);\n\n');

for i = 1:length(var_names)
    var_name = var_names{i};
    var_data = data_shocks(strcmp(data_shocks{:,1}, var_name), :);
    var_data = var_data(var_data{:,2} >= 2019, :);
    if isempty(var_data), continue; end
    %var_data = sortrows(var_data, 2); %or none

    if strcmp(foresight_mode,'anticipation_errors') && ismember(var_name, all_anticipation_vars)
        % --- Anticipation vars: write period-1 value extended permanently ---
        % Agents start period 1 assuming this value holds forever.
        % learnt_in=p blocks (p>=2) will update them as reality unfolds.
        val1 = NaN;

        for g = 1:length(lifestyle_groups)
            grp = lifestyle_groups{g};
            for sf = {'siggma_es','alppha_home','alppha_sharing'}
                if strcmp(var_name, sprintf('%s_%s', sf{1}, grp))
                    switch sf{1}
                        case 'siggma_es',    val1 = sigma_store.(grp)(2);
                        case 'alppha_home',  val1 = alpha_home_store.(grp)(2);
                        case 'alppha_sharing', val1 = alpha_sharing_store.(grp)(2);
                    end
                end
            end
        end

        vkey = matlab.lang.makeValidName(var_name);
        if isnan(val1) && isfield(tech_paths, vkey)
            val1 = tech_paths.(vkey)(1);   % period 1 = year 2019
        end

        if ~isnan(val1)
            pds  = strjoin(string(1:82), ',');
            vstr = vfmt(val1, 82);
            fprintf(fid, 'var %s; periods %s; values %s;\n\n', var_name, char(pds), char(vstr));
        end

    else
        % --- Standard vars: full anticipated path ---
        periods   = strjoin(string((var_data{:,2} - 2018)'), ',');
        value_str = strjoin(arrayfun(@(x) sprintf('%.16g',x), var_data.Value, 'UniformOutput',false), ',');
        fprintf(fid, 'var %s; periods %s; values %s;\n\n', var_name, char(periods), char(value_str));
    end
end

if strcmp(foresight_mode,'anticipation_errors')
    pds_all = char(strjoin(string(1:82), ','));
    for g = 1:length(lifestyle_groups)
        grp = lifestyle_groups{g};
        fprintf(fid,'var siggma_es_%s;      periods %s; values %s;\n', grp, pds_all, vfmt(sigma_store.(grp)(2),         82));
        fprintf(fid,'var alppha_home_%s;    periods %s; values %s;\n', grp, pds_all, vfmt(alpha_home_store.(grp)(2),    82));
        fprintf(fid,'var alppha_sharing_%s; periods %s; values %s;\n', grp, pds_all, vfmt(alpha_sharing_store.(grp)(2), 82));
    end
end

fprintf(fid,'end;\n');

% ------------------------------------------------------------------
% learnt_in=p blocks (p=2 onwards) — anticipation_errors mode only
% Period-1 beliefs already written above; from p=2 agents update when
% values change. Only writes blocks where something actually changes.
% ------------------------------------------------------------------
if strcmp(foresight_mode, 'anticipation_errors')
    blocks_written = 0;
    for p = 2:last_change_p
        k           = min(p + 1, n_years);
        n_rem       = 82 - p + 1;
        pds_str     = strjoin(string(p:82), ',');
        write_sigma = sigma_changed_at(p);
        write_tech  = tech_changed_at(p);

        if ~write_sigma && ~write_tech, continue; end

        fprintf(fid, '\nshocks(learnt_in=%d);\n', p);

        if write_sigma
            for g = 1:length(lifestyle_groups)
                grp = lifestyle_groups{g};
                fprintf(fid,'var siggma_es_%s;      periods %s; values %s;\n', grp, pds_str, vfmt(sigma_store.(grp)(k),          n_rem));
                fprintf(fid,'var alppha_home_%s;    periods %s; values %s;\n', grp, pds_str, vfmt(alpha_home_store.(grp)(k),     n_rem));
                fprintf(fid,'var alppha_sharing_%s; periods %s; values %s;\n', grp, pds_str, vfmt(alpha_sharing_store.(grp)(k),  n_rem));
            end
        end

        if write_tech
            for ii = 1:length(tech_anticipation_vars)
                vn   = tech_anticipation_vars{ii};
                vkey = matlab.lang.makeValidName(vn);
                if abs(tech_paths.(vkey)(p) - tech_paths.(vkey)(p-1)) > 1e-12
                    fprintf(fid,'var %s; periods %s; values %s;\n', vn, pds_str, vfmt(tech_paths.(vkey)(p), n_rem));
                end
            end
        end

        fprintf(fid,'end;\n');
        blocks_written = blocks_written + 1;
    end
    fprintf('  Written %d learnt_in blocks (skipped %d constant periods after year %d)\n', ...
            blocks_written, 82 - last_change_p, 2018 + last_change_p);
end

fclose(fid);

% 3.3 endval block
% Terminal values are the last period of the shock path, not the steady state —
% ensures the model converges to the intended long-run trajectory.
excludedVars = ["modifier_sharing_cautious","modifier_sharing_constrained","modifier_sharing_lowcarbon",...
                "modifier_repair_cautious","modifier_repair_constrained","modifier_repair_lowcarbon",...
                "modifier_expenditures_cautious","modifier_expenditures_constrained","modifier_expenditures_lowcarbon","eppsilon"];

fileID = fopen('CIRCEE_shocks.m', 'r');
shocksContent = fread(fileID, '*char')';
fclose(fileID);

shocksLines = strsplit(shocksContent, '\n');
fileID = fopen('CIRCEE_endvalues.m', 'w');
pattern = 'var\s+(\w+);\s+periods\s+[\w,]+\s*;\s+values\s+([\w,.\s-]+);';
for i = 1:length(shocksLines)
    line = shocksLines{i};
    tokens = regexp(line, pattern, 'tokens');
    if ~isempty(tokens)
        varName = tokens{1}{1};
        if ~ismember(varName, excludedVars)
            valuesStr = tokens{1}{2};
            parts = strsplit(strtrim(valuesStr), ',');
            lastValueStr = strtrim(parts{end});
            fprintf(fileID, '%s = %s;\n', varName, lastValueStr);
        end
    end
end
fclose(fileID);

%% -------- 4) Run Dynare --------
dynare_file_name = 'CIRCEE_PF.mod';
dynare(dynare_file_name);

%%%%%%%%%%
% OUTPUT %
%%%%%%%%%%

%% 1. Rescale output with total economic growth
varNames = string(M_.endo_names);
simData  = oo_.endo_simul;
isAuxVar = startsWith(varNames, 'AUX_');
varNamesFiltered = varNames(~isAuxVar);
simDataFiltered  = simData(~isAuxVar, :);
startYear = 2018; endYear = 2100; numPeriods = endYear - startYear + 1;

if size(simDataFiltered, 2) >= numPeriods
    simDataFiltered = simDataFiltered(:, 1:numPeriods);
else
    error('Simulation data does not extend up to the year 2100.');
end

dateLabels = arrayfun(@(x) sprintf('Y%d', startYear + x), 0:numPeriods-1, 'UniformOutput', false);
dateLabels = cellstr(dateLabels);
dataTable  = array2table(simDataFiltered, 'VariableNames', dateLabels, 'RowNames', varNamesFiltered);

noRescaleVars_common = ["u_highuse","deltta_energydurable_highuse","q_ed_newtild_highuse","deltta_energydurable_lowuse","u_lowuse","u_lowuse_lowcarbon","u_lowuse_cautious","u_lowuse_constrained","r_k","r_ed","p_e_nondurable","p_e_otherdurable","p_e_energydurable","p_e_capital","p_e_virgin","p_e_recycled","p_e_sharing", ...
 "p_e_c_nondurable","p_e_c_otherdurable","p_e_c_energydurable","p_e_c_capital","p_e_c_virgin","p_e_c_recycled","p_e_c_sharing", ...
 "p_m_nondurable","p_m_otherdurable","p_m_energydurable","p_m_capital", "share_ed_lowuse_prod","share_ed_highuse_prod",...
 "p_m_c_nondurable","p_m_c_otherdurable","p_m_c_energydurable","p_m_c_capital", ...
 "share_nd_lowcarbon","share_nd_cautious","share_nd_constrained", ...
"share_od_lowcarbon","share_od_cautious","share_od_constrained", ...
"share_ed_new_lowcarbon","share_ed_new_cautious","share_ed_new_constrained", "omegga_constrained",...
"p_g_inv_ed_lowcarbon","p_g_inv_ed_cautious","p_g_inv_ed_constrained", "w", ...
"AC_ID_g_lowcarbon","AC_ID_g_cautious","AC_ID_g_constrained", ...
"AC_ID_new_lowcarbon","AC_ID_new_cautious","AC_ID_new_constrained", ...
"alppha_ed_new_lowcarbon","alppha_ed_new_cautious","alppha_ed_new_constrained", ...
"alppha_ed_repair_lowcarbon","alppha_ed_repair_cautious","alppha_ed_repair_constrained", ...
"A_nel_lowcarbon","A_nel_cautious","A_nel_constrained",...
"share_ed_lowcarbon","share_ed_cautious","share_ed_constrained", ...
"omegga_repair","omegga_repair_lowcarbon","omegga_repair_cautious","omegga_repair_constrained",...
"alppha_sharing_lowcarbon","alppha_sharing_cautious", "alppha_sharing_constrained","siggma_es_lowcarbon","siggma_es_cautious","siggma_es_constrained"...
"share_sh_lowcarbon","share_sh_cautious","share_sh_constrained", ...
"share_repair_lowcarbon","share_repair_cautious","share_repair_constrained", ...
 "p_row_nondurable","p_row_otherdurable","p_row_energydurable","p_row_capital", ...
 "p_def_nondurable","p_def_otherdurable","p_def_energydurable","p_def_capital", ...
 "p_nondurable","p_otherdurable","p_energydurable","p_capital","p_sharing","p_repair", ...
 "p_e_h_c","p_g_inv_energydurable","alppha_ed_new","alppha_ed_repair","p_nd_ati","alppha_sharing","alppha_home","alppha_el_h","alppha_nel_h", ...
 "h","deltta_energydurable","A_nel","modifier_sharing","modifier_repair","uc_lowcarbon","uc_cautious","uc_constrained", ...
 "deltta_energydurable_lowcarbon","deltta_energydurable_cautious","deltta_energydurable_constrained","p_g_inv_energydurable_lowcarbon","p_g_inv_energydurable_cautious","p_g_inv_energydurable_constrained", ...
 "q_ed_newtild_lowcarbon","q_ed_newtild_cautious","q_ed_newtild_constrained","q_ed_depreciated_lowcarbon","q_ed_depreciated_cautious","q_ed_depreciated_constrained", ...
 "repair_ed_lowcarbon","repair_ed_cautious","repair_ed_constrained","p_home_lowcarbon","p_home_cautious","p_home_constrained","r_ed_lowcarbon","r_ed_cautious","r_ed_constrained", ...
 "disc_factor_lowcarbon","disc_factor_cautious","disc_factor_constrained","marginalcost_recycled","p_e_h_lowcarbon","p_e_h_cautious","p_e_h_constrained","p_e_h_c_lowcarbon", ...
 "El_lowcarbon","Nel_lowcarbon","El_cautious","Nel_cautious","El_constrained","Nel_constrained","p_e_h_c_cautious","p_e_h_c_constrained","A_nel_lowcarbon","A_nel_cautious","debt_gdp", ...
 "A_nel_constrained","q_k_lowcarbon","L_nondurable","L_otherdurable","L_energydurable","L_capital","L_repair","L_sharing","L_virgin","L_recycled","p_el_h","p_el_f","p_nel_h","p_nel_f","diff_A_nel","omegga_lowcarbon","omegga_cautious","sub_recycled"];

 %Number of households in populatindata and growthdata is labour productivity growth. Both calibrated from IIASA database

scenarios = struct(...
 'SSP2', struct('populationData', [69291557.81,68846863.39,68405022.91,67966018.03,67529830.57,67096442.44,66665835.68,66237992.44,65812894.97,65390525.67,64970867.02,64553901.63,64139612.2,63727981.57,63318992.68,62912628.57,62508872.39,62107707.41,61709116.99,61313084.63,60919593.89,60528628.46,60140172.15,59754208.84,59370722.54,58989697.36,58611117.49,58234967.24,57861231.02,57489893.34,57120938.8,56754352.12,56390118.09,56028221.61,55668647.69,55311381.41,54956407.97,54603712.66,54253280.85,53905098.01,53559149.72,53215421.63,52873899.49,52534569.15,52197416.54,51862427.69,51529588.7,51198885.78,50870305.23,50543833.41,50219456.8,49897161.96,49576935.51,49258764.19,48942634.81,48628534.26,48316449.52,48006367.66,47698275.82,47392161.23,47088011.19,46785813.12,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46,46485554.46],...
                'growthData', [1,1.011529594,1.023192119,1.034989108,1.046922111,1.058992698,1.071202453,1.083552982,1.096045907,1.108682871,1.121465534,1.134395576,1.147474696,1.160704612,1.174087065,1.187623811,1.201316631,1.215167324,1.229177709,1.243349628,1.257684944,1.27218554,1.286853322,1.301690218,1.316698177,1.331879172,1.347235197,1.362768272,1.378480436,1.394373755,1.410450317,1.426712236,1.443161648,1.459800716,1.476631624,1.493656587,1.51087784,1.528297647,1.545918298,1.563742108,1.581771418,1.6000086,1.618456049,1.637116189,1.655991473,1.675084382,1.694397424,1.713933137,1.73369409,1.753682878,1.773902128,1.794354499,1.815042677,1.835969381,1.857137362,1.878549401,1.900208312,1.922116941,1.944278168,1.966694905,1.989370098,2.012306726,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805,2.035507805]));

populationData = scenarios.(selectedScenario).populationData;
growthData     = scenarios.(selectedScenario).growthData;

if length(populationData) == numPeriods && length(growthData) == numPeriods
    for i = 1:numPeriods
        for j = 1:height(dataTable)
            varName = dataTable.Properties.RowNames{j};
            if ~ismember(varName, noRescaleVars_common)
                scalingFactor = populationData(i) * growthData(i) * 7869329.28419378000;
                dataTable{j, i} = dataTable{j, i} * scalingFactor;
            end
        end
    end
else
    error('Mismatch in the number of periods between population/growth data and simulation data.');
end

for i = 1:numPeriods
    j = find(strcmp(dataTable.Properties.RowNames, 'w'));
    if ~isempty(j)
        dataTable{j, i} = dataTable{j, i} * growthData(i);
    end
end

if length(populationData) == numPeriods
    for i = 1:numPeriods
        for j = 1:height(dataTable)
            varName = dataTable.Properties.RowNames{j};
            if ismember(varName, ["L_nondurable","L_otherdurable","L_energydurable","L_capital","L_repair","L_sharing","L_virgin","L_recycled"])
                dataTable{j, i} = dataTable{j, i} * populationData(i);
            end
        end
    end
else
    error('Mismatch in the number of periods between population data and simulation data.');
end

omega_lc_path = oo_.exo_simul(:, strmatch('omegga_lowcarbon', M_.exo_names, 'exact'))';
omega_ca_path = oo_.exo_simul(:, strmatch('omegga_cautious', M_.exo_names, 'exact'))';
if length(omega_lc_path) < numPeriods
    omega_lc_path = [omega_lc_path, repmat(omega_lc_path(end), 1, numPeriods - length(omega_lc_path))];
end
if length(omega_ca_path) < numPeriods
    omega_ca_path = [omega_ca_path, repmat(omega_ca_path(end), 1, numPeriods - length(omega_ca_path))];
end
omega_co_path = 1 - omega_lc_path - omega_ca_path;
omega_map = struct('lowcarbon', omega_lc_path, ...
                   'cautious', omega_ca_path, ...
                   'constrained', omega_co_path);
grp_suffixes = {'lowcarbon', 'cautious', 'constrained'};

noRescaleVars_omegga = [...
    "CF_lowcarbon","CF_cautious","CF_constrained",...
    "WF_lowcarbon","WF_cautious","WF_constrained",...
    "MF_lowcarbon","MF_cautious","MF_constrained",...
    "WF_nondurable_lowcarbon","WF_nondurable_cautious","WF_nondurable_constrained",...
    "WF_otherdurable_lowcarbon","WF_otherdurable_cautious","WF_otherdurable_constrained",...
    "WF_energydurable_lowcarbon","WF_energydurable_cautious","WF_energydurable_constrained",...
    "WF_sharing_lowcarbon","WF_sharing_cautious","WF_sharing_constrained",...
    "WF_repair_lowcarbon","WF_repair_cautious","WF_repair_constrained"];

for j = 1:height(dataTable)
    varName = dataTable.Properties.RowNames{j};
    if ismember(varName, noRescaleVars_common)
        continue;
    end
    if ismember(varName, noRescaleVars_omegga)
        continue;
    end
    for gs = 1:length(grp_suffixes)
        suffix = grp_suffixes{gs};
        if endsWith(varName, ['_' suffix])
            for i = 1:numPeriods
                dataTable{j, i} = dataTable{j, i} * omega_map.(suffix)(i);
            end
            break;
        end
    end
end

%% 1c. Per-households output for CF/WF/MF only (noRescaleVars_omegga)
%  CF/WF/MF_h = total footprint of group h (omegga embedded via shares)
%  Per group member = divide by (population × omegga_h)
pc_rows = {};
pc_data = [];
for j = 1:height(dataTable)
    varName = dataTable.Properties.RowNames{j};
    if ~ismember(varName, noRescaleVars_omegga), continue; end
    for gs = 1:length(grp_suffixes)
        suffix = grp_suffixes{gs};
        if endsWith(varName, ['_' suffix])
            row_data = dataTable{j, :};
            for i = 1:numPeriods
                row_data(i) = row_data(i) / (populationData(i) * omega_map.(suffix)(i));
            end
            pc_rows{end+1} = [varName '_percapita']; %percapita values here are actually per-households
            pc_data = [pc_data; row_data];
            break;
        end
    end
end
if ~isempty(pc_data)
    pc_table = array2table(pc_data, 'RowNames', pc_rows, 'VariableNames', dataTable.Properties.VariableNames);
    dataTable = [dataTable; pc_table];
end

varsToScaleByTrillion = ["El","Nel","El_h","Nel_h","El_nondurable","El_otherdurable","El_energydurable","El_capital","El_virgin","El_recycled","El_sharing",...
 "Nel_nondurable","Nel_otherdurable","Nel_energydurable","Nel_capital","Nel_virgin","Nel_recycled","Nel_sharing"];
varsToScaleByMillion  = ["L_nondurable","L_otherdurable","L_energydurable","L_capital","L_virgin","L_recycled","L_repair","L_sharing"];
scaleFactorTrillion = 1e12;
scaleFactorMillion  = 1e6;

for i = 1:height(dataTable)
    varName = dataTable.Properties.RowNames{i};
    if ismember(varName, varsToScaleByTrillion)
        dataTable{i, :} = dataTable{i, :} / scaleFactorTrillion;
    elseif ismember(varName, varsToScaleByMillion)
        dataTable{i, :} = dataTable{i, :} / scaleFactorMillion;
    end
end

if any(strcmp(dataTable.Properties.RowNames, 'GDP'))
    GDP_Yen = dataTable{'GDP', :};
    
    exchange_rate_JPY_USD = [110.42, 109.01, 106.77, 109.75, 131.5, 140.49, 151.37, ... 
                             repmat(151.37, 1, 76)];  % World Bank

    ppp_factor_JPY = [104.16, 103.23, 100.74, 99.21, 94.51, 95.27, 95.11, ...  
                      repmat(95.11, 1, 76)];  % World Bank
    
    GDP_MER = GDP_Yen ./ exchange_rate_JPY_USD;
    GDP_PPP = GDP_Yen ./ ppp_factor_JPY;
    
    dataTable = [dataTable; array2table(GDP_MER, 'RowNames', {'GDP_MER'}, 'VariableNames', dataTable.Properties.VariableNames)];
    dataTable = [dataTable; array2table(GDP_PPP, 'RowNames', {'GDP_PPP'}, 'VariableNames', dataTable.Properties.VariableNames)];
else
    error('GDP variable not found in the dataTable.');
end

scenarioTag = getenv('CIRCEE_SIGMA_SCENARIO');
if isempty(scenarioTag), scenarioTag = 'Baseline'; end
csvFilePath   = fullfile(outputFolder, ['CIRCEE_output_levels_' scenarioTag '_' foresight_mode '.csv']);
excelFilePath = fullfile(outputFolder, ['CIRCEE_output_levels_' scenarioTag '_' foresight_mode '.xlsx']);
writetable(dataTable, csvFilePath, 'WriteRowNames', true);
try
    writetable(dataTable, excelFilePath, 'WriteRowNames', true, 'Sheet', 1);
catch
    warning('Could not write Excel file — skipping.');
end

%% 3. Outputs for specific variables
sharingVars = {'ES_sharing', 'ES_sharing_lowcarbon', 'ES_sharing_cautious', 'ES_sharing_constrained'};
repairingVars = {'Inv_ed_repair', 'Inv_ed_repair_lowcarbon', 'Inv_ed_repair_cautious', 'Inv_ed_repair_constrained'};
expendituresVars = {'Expenditures_LIFE', 'Expenditures_LIFE_lowcarbon', 'Expenditures_LIFE_cautious', 'Expenditures_LIFE_constrained'};

sharingIndices = find(ismember(M_.endo_names, sharingVars));
repairingIndices = find(ismember(M_.endo_names, repairingVars));

if isempty(sharingIndices)
    error('None of the sharing variables were found in M_.endo_names.');
end
if isempty(repairingIndices)
    error('None of the repairing variables were found in M_.endo_names.');
end

sharingData = oo_.endo_simul(sharingIndices, :);
repairingData = oo_.endo_simul(repairingIndices, :);

endo_names_cell = cellstr(M_.endo_names);
expendituresData = zeros(length(expendituresVars), size(oo_.endo_simul, 2));
for k = 1:length(expendituresVars)
    idx = find(strcmp(endo_names_cell, expendituresVars{k}));
    if isempty(idx)
        error('Variable %s not found in M_.endo_names.', expendituresVars{k});
    end
    expendituresData(k,:) = oo_.endo_simul(idx(1),:);
end

startYear = 2018;
numPeriods = size(oo_.endo_simul, 2);
yearLabels = arrayfun(@(x) sprintf('Y%d', startYear + x - 1), 1:numPeriods, 'UniformOutput', false);

writetable(array2table(sharingData, 'RowNames', sharingVars, 'VariableNames', yearLabels), ...
          fullfile(outputFolder, 'Sharing.csv'), 'WriteRowNames', true);
writetable(array2table(repairingData, 'RowNames', repairingVars, 'VariableNames', yearLabels), ...
          fullfile(outputFolder, 'Repairing.csv'), 'WriteRowNames', true);
writetable(array2table(expendituresData, 'RowNames', expendituresVars, 'VariableNames', yearLabels), ...
          fullfile(outputFolder, 'Lowering_Expenditures.csv'), 'WriteRowNames', true);

%% 4. Save detrended output for welfare post-processing
scenarioName = getenv('CIRCEE_SIGMA_SCENARIO');
if isempty(scenarioName), scenarioName = 'Baseline'; end

welfareFolder = fullfile(outputFolder, 'welfare_inputs');
if ~exist(welfareFolder, 'dir'), mkdir(welfareFolder); end

welfare_save = struct();
welfare_save.scenario    = scenarioName;
welfare_save.endo_simul  = oo_.endo_simul;
welfare_save.endo_names  = cellstr(M_.endo_names);
welfare_save.exo_simul   = oo_.exo_simul;
welfare_save.exo_names   = cellstr(M_.exo_names);
welfare_save.param_names = cellstr(M_.param_names);
welfare_save.params      = struct();
for k = 1:length(welfare_save.param_names)
    fn = matlab.lang.makeValidName(welfare_save.param_names{k});
    welfare_save.params.(fn) = M_.params(k);
end

savefile = fullfile(welfareFolder, [matlab.lang.makeValidName(scenarioName) '_' foresight_mode '.mat']);
save(savefile, 'welfare_save');
fprintf('\n  Detrended output saved to %s\n', savefile);

end