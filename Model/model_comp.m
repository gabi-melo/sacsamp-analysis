clear all
clc

at_usp = false;

if at_usp
    main_folder = '/Users/Gabi/Documents/GitHub/sacsamp-analysis/';
    data_folder = 'F:/sacsamp-model/';
    ft_folder = '/Users/Gabi/Documents/MATLAB/Fieldtrip/';
else
    main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
    data_folder = '/Volumes/PortableSSD/sacsamp-model/';
    ft_folder = '/Users/gabimelo/Documents/MATLAB/Fieldtrip/';
end

addpath(genpath(main_folder))
cd(main_folder)

load('full_data.mat','data')

subs = unique(data.sub_num);
n_sub = length(subs);
n_cond = 3;


%%
%%% get models evaluation metrics


model_eval.sigsen = [];
model_eval.siginf = [];
model_eval.sigrep = [];
model_eval.sub    = [];
model_eval.cond   = [];
model_eval.bic    = [];
model_eval.aic    = [];
model_eval.ll     = [];

file_name = 'output_fit_sigrep.mat';
load([data_folder file_name],'model_fit')
for cond_i = 1:n_cond
    for sub_i = 1:n_sub
        model_eval.sigsen(end+1) = 0;
        model_eval.siginf(end+1) = 0;
        model_eval.sigrep(end+1) = 1;
        model_eval.sub(end+1) = sub_i;
        model_eval.cond(end+1) = cond_i;
        model_eval.bic(end+1) = vertcat(model_fit(sub_i,cond_i).aic);
        model_eval.aic(end+1) = vertcat(model_fit(sub_i,cond_i).bic);
        model_eval.ll(end+1) = vertcat(model_fit(sub_i,cond_i).ll);
    end
end

file_name = 'output_fit_siginf.mat';
load([data_folder file_name],'model_fit')
for cond_i = 1:n_cond
    for sub_i = 1:n_sub
        model_eval.sigsen(end+1) = 0;
        model_eval.siginf(end+1) = 1;
        model_eval.sigrep(end+1) = 0;
        model_eval.sub(end+1) = sub_i;
        model_eval.cond(end+1) = cond_i;
        model_eval.bic(end+1) = vertcat(model_fit(sub_i,cond_i).aic);
        model_eval.aic(end+1) = vertcat(model_fit(sub_i,cond_i).bic);
        model_eval.ll(end+1) = vertcat(model_fit(sub_i,cond_i).ll);
    end
end

file_name = 'output_fit_sigsen.mat';
load([data_folder file_name],'model_fit')
for cond_i = 1:n_cond
    for sub_i = 1:n_sub
        model_eval.sigsen(end+1) = 1;
        model_eval.siginf(end+1) = 0;
        model_eval.sigrep(end+1) = 0;
        model_eval.sub(end+1) = sub_i;
        model_eval.cond(end+1) = cond_i;
        model_eval.bic(end+1) = vertcat(model_fit(sub_i,cond_i).aic);
        model_eval.aic(end+1) = vertcat(model_fit(sub_i,cond_i).bic);
        model_eval.ll(end+1) = vertcat(model_fit(sub_i,cond_i).ll);
    end
end

file_name = 'output_fit_all.mat';
load([data_folder 'Model/Outputs/' file_name],'model_fit')
for cond_i = 1:n_cond
    for sub_i = 1:n_sub
        model_eval.sigsen(end+1) = 1;
        model_eval.siginf(end+1) = 1;
        model_eval.sigrep(end+1) = 1;
        model_eval.sub(end+1) = sub_i;
        model_eval.cond(end+1) = cond_i;
        model_eval.bic(end+1) = vertcat(model_fit(sub_i,cond_i).aic);
        model_eval.aic(end+1) = vertcat(model_fit(sub_i,cond_i).bic);
        model_eval.ll(end+1) = vertcat(model_fit(sub_i,cond_i).ll);
    end
end

save([main_folder 'Model/model_eval'],'model_eval')


%%
%%% compare models 


disp('aic fit all')
aic = sum(model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 1 & model_eval.sigrep == 1))
disp('aic fit sigrep')
aic = sum(model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 0 & model_eval.sigrep == 1))
disp('aic fit sigsen')
aic = sum(model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 0 & model_eval.sigrep == 0))
disp('aic fit siginf')
aic = sum(model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 1 & model_eval.sigrep == 0))


%%
%%% compare models by condition


cond_i = 3

disp('aic fit all')
aic = sum(model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 1 & model_eval.sigrep == 1 & model_eval.cond == cond_i))
disp('aic fit sigrep')
aic = sum(model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 0 & model_eval.sigrep == 1 & model_eval.cond == cond_i))
disp('aic fit sigsen')
aic = sum(model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 0 & model_eval.sigrep == 0 & model_eval.cond == cond_i))
disp('aic fit siginf')
aic = sum(model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 1 & model_eval.sigrep == 0 & model_eval.cond == cond_i))


%%
%%% save models parameters


file_name = 'fit_all';

load([data_folder 'output_' file_name],'model_fit')

params.siginf(:,1) = vertcat(model_fit(:,1).siginf)
params.siginf(:,2) = vertcat(model_fit(:,2).siginf)
params.siginf(:,3) = vertcat(model_fit(:,3).siginf)

params.sigsen(:,1) = vertcat(model_fit(:,1).sigsen)
params.sigsen(:,2) = vertcat(model_fit(:,2).sigsen)
params.sigsen(:,3) = vertcat(model_fit(:,3).sigsen)

params.sigrep(:,1) = vertcat(model_fit(:,1).sigrep)
params.sigrep(:,2) = vertcat(model_fit(:,2).sigrep)
params.sigrep(:,3) = vertcat(model_fit(:,3).sigrep)

params.plapse(:,1) = vertcat(model_fit(:,1).plapse)
params.plapse(:,2) = vertcat(model_fit(:,2).plapse)
params.plapse(:,3) = vertcat(model_fit(:,3).plapse)

params.alpha(:,1) = vertcat(model_fit(:,1).alpha)
params.alpha(:,2) = vertcat(model_fit(:,2).alpha)
params.alpha(:,3) = vertcat(model_fit(:,3).alpha)

save([main_folder 'Model/params_' file_name],'params')

