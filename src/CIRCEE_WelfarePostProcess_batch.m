%% ============================================================
%  CIRCEE_WelfarePostProcess_batch.m
%  Example driver: runs welfare post-processing for all lifestyle x
%  foresight x scenario combinations, using the corrected NoModifiers
%  mat files as the welfare baseline. This is a TEMPLATE — adapt the
%  USER PATHS and the lifestyle/scenario lists to your own runs.
%% ============================================================

% ========================================================================
%  USER PATHS — EDIT THESE to point at your own directories
% ========================================================================
mat_base     = '<PATH>/Mat files';                  % saved welfare .mat files
welfare_base = '<PATH>/Welfare';                    % welfare CSV output
csv_dir      = '<PATH>/CIRCEE_output_levels';       % output-level CSVs
% ------------------------------------------------------------------------

lifestyles = {'ecoactive_ecoactive','affordability_affordability',...
              'ecoactive_affordability','affordability_ecoactive'};

foresights = {'AE','PF'};
foresight_names = struct('AE','anticipation_errors','PF','perfect_foresight');

% Ecosystem (sigma) scenarios. These names must match the scenario tags
% produced by the model runs (CIRCEE_SIGMA_SCENARIO in config.sh / run.sh)
% and the corresponding .mat filenames on disk.
scenarios = {'Baseline','Progressive','Regressive'};

scenario_fn = struct(...
    'Baseline',    'Baseline',...
    'Progressive', 'Progressive',...
    'Regressive',  'Regressive');

total = 0; errors = 0;

for li = 1:length(lifestyles)
    ls = lifestyles{li};
    for fi = 1:length(foresights)
        fs = foresights{fi};
        fn = foresight_names.(fs);
        fprintf('\n=== Assembling: %s_%s ===\n', ls, fs);

        % Create temp welfare_inputs folder
        temp_folder = fullfile(welfare_base, sprintf('%s_%s', ls, fs), 'welfare_inputs');
        if ~exist(temp_folder, 'dir'), mkdir(temp_folder); end

        % Copy NoModifiers mat file (welfare baseline)
        nm_src = fullfile(mat_base, sprintf('circee_%s_%s_Baseline', ls, fs), ...
                          sprintf('NoModifiers_%s.mat', fn));
        nm_dst = fullfile(temp_folder, sprintf('NoModifiers_%s.mat', fn));
        if exist(nm_src, 'file')
            copyfile(nm_src, nm_dst);
            fprintf('  Copied NoModifiers_%s.mat\n', fn);
        else
            fprintf('  MISSING NoModifiers: %s\n', nm_src);
            errors = errors + 1;
            continue;
        end

        % Copy each scenario mat file
        all_ok = true;
        for si = 1:length(scenarios)
            sc    = scenarios{si};
            sc_fn = scenario_fn.(sc);
            src   = fullfile(mat_base, sprintf('circee_%s_%s_%s', ls, fs, sc), ...
                             sprintf('%s_%s.mat', sc_fn, fn));
            dst   = fullfile(temp_folder, sprintf('%s_%s.mat', sc_fn, fn));
            if exist(src, 'file')
                copyfile(src, dst);
                fprintf('  Copied %s_%s.mat\n', sc_fn, fn);
            else
                fprintf('  MISSING: %s\n', src);
                all_ok = false;
            end
        end

        if ~all_ok
            fprintf('  Skipping welfare due to missing files\n');
            errors = errors + 1;
            continue;
        end

        % Run welfare post-processing
        out_dir = fullfile(welfare_base, sprintf('%s_%s', ls, fs));
        if ~exist(out_dir, 'dir'), mkdir(out_dir); end
        fprintf('  Running welfare post-processing...\n');
        try
            CIRCEE_WelfarePostProcess(...
                'folder',   temp_folder, ...
                'baseline', sprintf('NoModifiers_%s', fn), ...
                'foresight', fn, ...
                'output',   out_dir, ...
                'lifestyle', ls, ...
                'foresight_short', fs, ...
                'csv_dir',  csv_dir);
            fprintf('  -> Done: %s_%s\n', ls, fs);
            total = total + 1;
        catch e
            fprintf('  ERROR: %s\n', e.message);
            errors = errors + 1;
        end
    end
end

fprintf('\n=== Done: %d welfare runs completed, %d errors ===\n', total, errors);