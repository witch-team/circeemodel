clear; close all;

temp_list=dir('*.mod');
[num_mod,~]=size(temp_list);

for ii=1:num_mod
    mod_name = strsplit(temp_list(ii).name,'.');
    mod_name = char(mod_name(1));
    delete(['*',mod_name,'.m']);
    delete(['*',mod_name,'.log']);
    delete(['*',mod_name,'_results.mat']);
    if exist(mod_name,'dir') == 7
    rmdir(mod_name,'s');
    end
end

delete *_dynamic.m
delete *steadystate.m
delete *_steadystate2.m
delete *_set_auxiliary_variables.m
delete *_static.m
delete *.eps
delete *.asv
delete *.jnl
delete *.tex
delete *.aux
delete *.dvi
delete *.log
delete *.pdf
delete *.ps

rmdir ('+circee_pf','s')

clear;

