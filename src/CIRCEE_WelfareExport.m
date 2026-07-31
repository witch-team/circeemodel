function CIRCEE_WelfareExport(welfare, scenario_list, outputFolder)

if nargin < 3, outputFolder = 'Output'; end
if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end

years = welfare.years;
groups = welfare.groups;
base = matlab.lang.makeValidName(scenario_list{1});
yr_idx = @(yr) find(years == yr);

%% ========================================================================
%  TABLE 1: Lifetime CEV summary
%  ========================================================================

rows = {};
for s = 2:length(scenario_list)
    row = struct();
    scen = matlab.lang.makeValidName(scenario_list{s});
    row.Scenario = scenario_list{s};
    for g = 1:3
        grp = groups{g};
        row.(['CEV_lifetime_' grp]) = welfare.cev.(scen).(grp).lifetime * 100;
    end
    row.CEV_lifetime_aggregate = welfare.cev.(scen).aggregate_lifetime * 100;
    rows{end+1} = row;
end
T1 = struct2table([rows{:}]);
writetable(T1, fullfile(outputFolder, 'welfare_CEV_lifetime.csv'));
fprintf('  Saved welfare_CEV_lifetime.csv\n');

%% ========================================================================
%  TABLE 2: Year-by-year CEV snapshots
%  ========================================================================

snapshot_years = [2025, 2030, 2035, 2040, 2045, 2050];
rows = {};
for s = 2:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});
    for g = 1:3
        row = struct(); 
        grp = groups{g};
        row.Scenario = scenario_list{s};
        row.Group = grp;
        row.(['CEV_lifetime_lowcarbon'])   = welfare.cev.(scen).lowcarbon.lifetime * 100;
        row.(['CEV_lifetime_cautious'])    = welfare.cev.(scen).cautious.lifetime * 100;
        row.(['CEV_lifetime_constrained']) = welfare.cev.(scen).constrained.lifetime * 100;
        row.CEV_lifetime_aggregate        = welfare.cev.(scen).aggregate_lifetime * 100;
        for y = snapshot_years
            ti = yr_idx(y);
            row.(['Y' num2str(y)]) = welfare.cev.(scen).(grp).snapshot(ti) * 100;
        end
        rows{end+1} = row;
    end
end
T2 = struct2table([rows{:}]);
writetable(T2, fullfile(outputFolder, 'welfare_CEV_snapshots.csv'));
fprintf('  Saved welfare_CEV_snapshots.csv\n');

%% ========================================================================
%  TABLE 3: Expenditure Gini, Palma, Atkinson for all scenarios
%  ========================================================================
rows = {};
for s = 1:length(scenario_list)
    row = struct();   % ← FIXED
    scen = matlab.lang.makeValidName(scenario_list{s});
    row.Scenario = scenario_list{s};
    for y = [2018, 2020, 2025, 2030, 2035, 2040, 2045, 2050]
        ti = yr_idx(y);
        row.(['Gini_' num2str(y)])        = welfare.distribution.(scen).Gini(ti);
        row.(['Palma_' num2str(y)])       = welfare.distribution.(scen).Palma(ti);
        row.(['Atkinson05_' num2str(y)])  = welfare.distribution.(scen).Atkinson_05(ti);
        row.(['Atkinson10_' num2str(y)])  = welfare.distribution.(scen).Atkinson_10(ti);
        row.(['Atkinson15_' num2str(y)])  = welfare.distribution.(scen).Atkinson_15(ti);
        row.(['Atkinson20_' num2str(y)])  = welfare.distribution.(scen).Atkinson_20(ti);
        row.(['Atkinson30_' num2str(y)])  = welfare.distribution.(scen).Atkinson_30(ti);
    end
    rows{end+1} = row;
end
T3 = struct2table([rows{:}]);
writetable(T3, fullfile(outputFolder, 'welfare_expenditure_distribution.csv'));
fprintf('  Saved welfare_expenditure_distribution.csv\n');

%% ========================================================================
%  TABLE 4: CV/EV at key years
%  ========================================================================
rows = {};
for s = 2:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});
    for g = 1:3
        row = struct();
        grp = groups{g};
        row.Scenario = scenario_list{s};
        row.Group = grp;
        for y = snapshot_years
            ti = yr_idx(y);
            row.(['CV_' num2str(y)]) = welfare.cv_ev.(scen).(grp).CV(ti) * 100;
            row.(['EV_' num2str(y)]) = welfare.cv_ev.(scen).(grp).EV(ti) * 100;
        end
        rows{end+1} = row;
    end
end
T4 = struct2table([rows{:}]);
writetable(T4, fullfile(outputFolder, 'welfare_CV_EV.csv'));
fprintf('  Saved welfare_CV_EV.csv\n');

%% ========================================================================
%  TABLE 5: ES-based CEV
%  ========================================================================
rows = {};
for s = 2:length(scenario_list)
    row = struct();
    scen = matlab.lang.makeValidName(scenario_list{s});
    row.Scenario = scenario_list{s};
    for g = 1:3
        grp = groups{g};
        row.(['ES_CEV_lifetime_' grp]) = welfare.es_cev.(scen).(grp).lifetime * 100;
        for y = snapshot_years
            ti = yr_idx(y);
            row.(['ES_CEV_' grp '_Y' num2str(y)]) = welfare.es_cev.(scen).(grp).snapshot(ti) * 100;
        end
    end
    row.ES_CEV_lifetime_aggregate = welfare.es_cev.(scen).aggregate_lifetime * 100;
    rows{end+1} = row;
end
T5_es = struct2table([rows{:}]);
writetable(T5_es, fullfile(outputFolder, 'welfare_ES_CEV.csv'));
fprintf('  Saved welfare_ES_CEV.csv\n');

%% ========================================================================
%  TABLE 6: ES Gini, Palma, Atkinson, and access gap
%  ========================================================================
rows = {};
for s = 1:length(scenario_list)
    row = struct();
    scen = matlab.lang.makeValidName(scenario_list{s});
    row.Scenario = scenario_list{s};
    for y = [2018, 2020, 2025, 2030, 2035, 2040, 2045, 2050]
        ti = yr_idx(y);
        row.(['ES_Gini_' num2str(y)])        = welfare.es_distribution.(scen).Gini(ti);
        row.(['ES_Palma_' num2str(y)])       = welfare.es_distribution.(scen).Palma(ti);
        row.(['ES_Atkinson05_' num2str(y)])  = welfare.es_distribution.(scen).Atkinson_05(ti);
        row.(['ES_Atkinson10_' num2str(y)])  = welfare.es_distribution.(scen).Atkinson_10(ti);
        row.(['ES_Atkinson15_' num2str(y)])  = welfare.es_distribution.(scen).Atkinson_15(ti);
        row.(['ES_Atkinson20_' num2str(y)])  = welfare.es_distribution.(scen).Atkinson_20(ti);
        row.(['ES_Atkinson30_' num2str(y)])  = welfare.es_distribution.(scen).Atkinson_30(ti);
        row.(['ES_access_gap_' num2str(y)])  = welfare.es_distribution.(scen).access_gap(ti);
    end
    rows{end+1} = row;
end
T6_es = struct2table([rows{:}]);
writetable(T6_es, fullfile(outputFolder, 'welfare_ES_distribution.csv'));
fprintf('  Saved welfare_ES_distribution.csv\n');

%% ========================================================================
%  TABLE 6b: Footprint inequality (CF, WF, MF) — per households
%  ========================================================================
fp_exp = {'cf_distribution','CF','welfare_CF_distribution.csv'; ...
          'wf_distribution','WF','welfare_WF_distribution.csv'; ...
          'mf_distribution','MF','welfare_MF_distribution.csv'};
for fpi = 1:size(fp_exp,1)
    dn   = fp_exp{fpi,1};
    pref = fp_exp{fpi,2};
    file = fp_exp{fpi,3};
    rows = {};
    for s = 1:length(scenario_list)
        row = struct();
        scen = matlab.lang.makeValidName(scenario_list{s});
        row.Scenario = scenario_list{s};
        for y = [2018, 2020, 2025, 2030, 2035, 2040, 2045, 2050]
            ti = yr_idx(y);
            row.([pref '_Gini_' num2str(y)])       = welfare.(dn).(scen).Gini(ti);
            row.([pref '_Palma_' num2str(y)])      = welfare.(dn).(scen).Palma(ti);
            row.([pref '_Atkinson05_' num2str(y)]) = welfare.(dn).(scen).Atkinson_05(ti);
            row.([pref '_Atkinson10_' num2str(y)]) = welfare.(dn).(scen).Atkinson_10(ti);
            row.([pref '_Atkinson15_' num2str(y)]) = welfare.(dn).(scen).Atkinson_15(ti);
            row.([pref '_Atkinson20_' num2str(y)]) = welfare.(dn).(scen).Atkinson_20(ti);
            row.([pref '_Atkinson30_' num2str(y)]) = welfare.(dn).(scen).Atkinson_30(ti);
        end
        rows{end+1} = row;
    end
    Tfp = struct2table([rows{:}]);
    writetable(Tfp, fullfile(outputFolder, file));
    fprintf('  Saved %s\n', file);
end

%% ========================================================================
%  TABLE 7: Full time series (welfare, distribution)
%  ========================================================================
rows = {};
for s = 2:length(scenario_list)
    scen = matlab.lang.makeValidName(scenario_list{s});
    for t = 1:length(years)
        row = struct();
        row.Scenario = scenario_list{s};
        row.Year = years(t);
        for g = 1:3
            grp = groups{g};
            row.(['CEV_' grp])          = welfare.cev.(scen).(grp).snapshot(t) * 100;
            row.(['CV_' grp])           = welfare.cv_ev.(scen).(grp).CV(t) * 100;
            row.(['ES_CEV_' grp])       = welfare.es_cev.(scen).(grp).snapshot(t) * 100;
        end
        % Expenditure inequality
        row.Gini         = welfare.distribution.(scen).Gini(t);
        row.Palma        = welfare.distribution.(scen).Palma(t);
        row.Atkinson_05  = welfare.distribution.(scen).Atkinson_05(t);
        row.Atkinson_10  = welfare.distribution.(scen).Atkinson_10(t);
        row.Atkinson_15  = welfare.distribution.(scen).Atkinson_15(t);
        row.Atkinson_20  = welfare.distribution.(scen).Atkinson_20(t);
        row.Atkinson_30  = welfare.distribution.(scen).Atkinson_30(t);
        % ES inequality
        row.ES_Gini        = welfare.es_distribution.(scen).Gini(t);
        row.ES_Palma       = welfare.es_distribution.(scen).Palma(t);
        row.ES_Atkinson_05 = welfare.es_distribution.(scen).Atkinson_05(t);
        row.ES_Atkinson_10 = welfare.es_distribution.(scen).Atkinson_10(t);
        row.ES_Atkinson_15 = welfare.es_distribution.(scen).Atkinson_15(t);
        row.ES_Atkinson_20 = welfare.es_distribution.(scen).Atkinson_20(t);
        row.ES_Atkinson_30 = welfare.es_distribution.(scen).Atkinson_30(t);
        row.ES_access_gap  = welfare.es_distribution.(scen).access_gap(t);
        % CF inequality
        row.CF_Gini        = welfare.cf_distribution.(scen).Gini(t);
        row.CF_Palma       = welfare.cf_distribution.(scen).Palma(t);
        row.CF_Atkinson_05 = welfare.cf_distribution.(scen).Atkinson_05(t);
        row.CF_Atkinson_10 = welfare.cf_distribution.(scen).Atkinson_10(t);
        row.CF_Atkinson_15 = welfare.cf_distribution.(scen).Atkinson_15(t);
        row.CF_Atkinson_20 = welfare.cf_distribution.(scen).Atkinson_20(t);
        row.CF_Atkinson_30 = welfare.cf_distribution.(scen).Atkinson_30(t);
        % WF inequality
        row.WF_Gini        = welfare.wf_distribution.(scen).Gini(t);
        row.WF_Palma       = welfare.wf_distribution.(scen).Palma(t);
        row.WF_Atkinson_10 = welfare.wf_distribution.(scen).Atkinson_10(t);
        % MF inequality
        row.MF_Gini        = welfare.mf_distribution.(scen).Gini(t);
        row.MF_Palma       = welfare.mf_distribution.(scen).Palma(t);
        row.MF_Atkinson_10 = welfare.mf_distribution.(scen).Atkinson_10(t);
        % Lifetime CEV
        row.CEV_lifetime_lowcarbon   = welfare.cev.(scen).lowcarbon.lifetime * 100;
        row.CEV_lifetime_cautious    = welfare.cev.(scen).cautious.lifetime * 100;
        row.CEV_lifetime_constrained = welfare.cev.(scen).constrained.lifetime * 100;
        row.CEV_lifetime_aggregate   = welfare.cev.(scen).aggregate_lifetime * 100;
        % Milestone snapshot CEV columns
        for y = [2025, 2030, 2035, 2040, 2045, 2050]
            ti_y = yr_idx(y);
            row.(['Y' num2str(y)]) = welfare.cev.(scen).lowcarbon.snapshot(ti_y) * 100;
        end
        rows{end+1} = row;
    end
end
T8 = struct2table([rows{:}]);
writetable(T8, fullfile(outputFolder, 'welfare_full_timeseries.csv'));
fprintf('  Saved welfare_full_timeseries.csv\n');

fprintf('\n  All welfare exports complete.\n');
end