clear all
close all
clc

project_path = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';

addpath(genpath(project_path))
cd(project_path)

load([project_path 'full_data.mat'])

subs = unique(data.sub_num);
n_sub = length(subs);
n_cond = 3;

% cond #1 = saccade active
% cond #2 = saccade passive
% cond #3 = fixation


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
load([project_path 'Model/Outputs/' file_name],'model_fit')
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
load([project_path 'Model/Outputs/' file_name],'model_fit')
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
load([project_path 'Model/Outputs/' file_name],'model_fit')
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
load([project_path 'Model/Outputs/' file_name],'model_fit')
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

save([project_path 'Model/Outputs/model_eval'],'model_eval')


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


load([project_path 'Model/Outputs/output_fit_sigrep.mat'],'model_fit')

fit_sigrep.siginf(:,1) = vertcat(model_fit(:,1).siginf)
fit_sigrep.siginf(:,2) = vertcat(model_fit(:,2).siginf)
fit_sigrep.siginf(:,3) = vertcat(model_fit(:,3).siginf)

fit_sigrep.sigsen(:,1) = vertcat(model_fit(:,1).sigsen)
fit_sigrep.sigsen(:,2) = vertcat(model_fit(:,2).sigsen)
fit_sigrep.sigsen(:,3) = vertcat(model_fit(:,3).sigsen)

fit_sigrep.sigrep(:,1) = vertcat(model_fit(:,1).sigrep)
fit_sigrep.sigrep(:,2) = vertcat(model_fit(:,2).sigrep)
fit_sigrep.sigrep(:,3) = vertcat(model_fit(:,3).sigrep)

fit_sigrep.plapse(:,1) = vertcat(model_fit(:,1).plapse)
fit_sigrep.plapse(:,2) = vertcat(model_fit(:,2).plapse)
fit_sigrep.plapse(:,3) = vertcat(model_fit(:,3).plapse)

fit_sigrep.alpha(:,1) = vertcat(model_fit(:,1).alpha)
fit_sigrep.alpha(:,2) = vertcat(model_fit(:,2).alpha)
fit_sigrep.alpha(:,3) = vertcat(model_fit(:,3).alpha)

save([project_path 'Model/Outputs/params_fit_sigrep'],'fit_sigrep')

