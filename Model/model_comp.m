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


file_name = 'model_sigrep_run5.mat';
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

file_name = 'model_siginf_run5.mat';
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

file_name = 'model_sigsen_run5.mat';
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

file_name = 'model_all_run5.mat';
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

disp('model fit all')
aic = sum(model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 1 & model_eval.sigrep == 1))
disp('model fit sigrep')
aic = sum(model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 0 & model_eval.sigrep == 1))
disp('model fit sigsen')
aic = sum(model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 0 & model_eval.sigrep == 0))
disp('model fit siginf')
aic = sum(model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 1 & model_eval.sigrep == 0))


%%
%%% compare models by condition

cond_i = 3

disp('model fit all')
aic = sum(model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 1 & model_eval.sigrep == 1 & model_eval.cond == cond_i))
disp('model fit sigrep')
aic = sum(model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 0 & model_eval.sigrep == 1 & model_eval.cond == cond_i))
disp('model fit sigsen')
aic = sum(model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 0 & model_eval.sigrep == 0 & model_eval.cond == cond_i))
disp('model fit siginf')
aic = sum(model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 1 & model_eval.sigrep == 0 & model_eval.cond == cond_i))


%%
%%% save parameters from best model


model_params.siginf(:,1) = vertcat(model_fit(:,1).siginf)
model_params.siginf(:,2) = vertcat(model_fit(:,2).siginf)
model_params.siginf(:,3) = vertcat(model_fit(:,3).siginf)

model_params.plapse(:,1) = vertcat(model_fit(:,1).plapse)
model_params.plapse(:,2) = vertcat(model_fit(:,2).plapse)
model_params.plapse(:,3) = vertcat(model_fit(:,3).plapse)

model_params.alpha(:,1) = vertcat(model_fit(:,1).alpha)
model_params.alpha(:,2) = vertcat(model_fit(:,2).alpha)
model_params.alpha(:,3) = vertcat(model_fit(:,3).alpha)


save([project_path 'Model/Outputs/model_params'],'model_params')

