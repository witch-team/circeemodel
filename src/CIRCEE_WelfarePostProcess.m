function [] = CIRCEE_WelfarePostProcess(varargin)

p = inputParser;
addParameter(p, 'folder', '../results/welfare_inputs', @ischar);
addParameter(p, 'baseline', 'Baseline', @ischar);
addParameter(p, 'output', '../results', @ischar);
addParameter(p, 'foresight', '', @ischar);
addParameter(p, 'lifestyle', '', @ischar);
addParameter(p, 'foresight_short', '', @ischar); 
addParameter(p, 'csv_dir', '', @ischar);
parse(p, varargin{:});

welfareFolder = p.Results.folder;
baselineName  = p.Results.baseline;
outputFolder  = p.Results.output;

foresight_filter = p.Results.foresight;
if ~isempty(foresight_filter)
    matfiles = dir(fullfile(welfareFolder, ['*' foresight_filter '*.mat']));
else
    matfiles = dir(fullfile(welfareFolder, '*.mat'));
end

if isempty(matfiles)
    error('No scenario files found in %s. Run CIRCEE_RunFile for each scenario first.', welfareFolder);
end

fprintf('\n================================================================\n');
fprintf(' CIRCEE WELFARE POST-PROCESSING\n');
fprintf('================================================================\n');
fprintf(' Loading scenarios from: %s\n\n', welfareFolder);

results = struct();
scenario_list = {};

baselineFile = fullfile(welfareFolder, [matlab.lang.makeValidName(baselineName) '.mat']);
if ~exist(baselineFile, 'file')
    error('Baseline file not found: %s\nRun the Baseline scenario first.', baselineFile);
end

tmp = load(baselineFile);
R = tmp.welfare_save;
R.scenario = 'NoModifiers';                    
results.NoModifiers = R;
scenario_list{1} = 'NoModifiers';
fprintf('  [Reference] NoModifiers\n');

for i = 1:length(matfiles)
    fname = matfiles(i).name;
    if strcmp(fname, [matlab.lang.makeValidName(baselineName) '.mat'])
        continue;
    end
    tmp = load(fullfile(welfareFolder, fname));
    R = tmp.welfare_save;
    results.(matlab.lang.makeValidName(R.scenario)) = R;
    scenario_list{end+1} = R.scenario;
    fprintf('  [Scenario] %s\n', R.scenario);
end

fprintf('\n  %d scenarios loaded.\n', length(scenario_list));

if length(scenario_list) < 2
    error('Need at least 2 scenarios (Baseline + 1 policy). Found %d.', length(scenario_list));
end

fprintf('\n================================================================\n');
fprintf(' COMPUTING WELFARE METRICS\n');
fprintf('================================================================\n\n');

welfare = CIRCEE_WelfareAnalysis(results, scenario_list, ...
            p.Results.lifestyle, p.Results.foresight_short, p.Results.csv_dir);
CIRCEE_WelfareExport(welfare, scenario_list, outputFolder);

save(fullfile(outputFolder, 'CIRCEE_welfare_results.mat'), 'welfare');
fprintf('\n================================================================\n');
fprintf(' DONE. Results saved to %s/\n', outputFolder);
fprintf('================================================================\n');

end