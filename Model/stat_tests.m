clear all
close all
clc

project_path = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';

addpath(genpath(project_path))
cd(project_path)

load([project_path 'full_data.mat'])
load([project_path 'Model/Outputs/model_params'],'model_params')


%%
%%% compare model parameters between conditions

cond_a = 1;
cond_b = 2;

ya = model_params.siginf(:,cond_a);
yb = model_params.siginf(:,cond_b);

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

%%

ya = model_params.plapse(:,cond_a);
yb = model_params.plapse(:,cond_b);

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

%%

ya = model_params.alpha(:,cond_a);
yb = model_params.alpha(:,cond_b);

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)


%%



%%
%%% compare correlation coef between conditions
%%% compare error s.d. between conditions

cond_a = 2;
cond_b = 3;
targ_n = 12;

ya = stat.rho_ang(stat.cond_num==cond_a);
yb = stat.rho_ang(stat.cond_num==cond_b);

% ya = stat.rho_ang(stat.cond_num==cond_a & stat.targ_len==targ_n);
% yb = stat.rho_ang(stat.cond_num==cond_b & stat.targ_len==targ_n);

% ya = stat_bst.rho_ang{stat_bst.cond_num==cond_a};
% yb = stat_bst.rho_ang{stat_bst.cond_num==cond_b};

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

%%

ya = stat.rho_mag_lo(stat.cond_num==cond_a);
yb = stat.rho_mag_lo(stat.cond_num==cond_b);

% ya = stat.rho_mag_lo(stat.cond_num==cond_a & stat.targ_len==targ_n);
% yb = stat.rho_mag_lo(stat.cond_num==cond_b & stat.targ_len==targ_n);

% ya = stat_bst.rho_mag_lo{stat_bst.cond_num==cond_a};
% yb = stat_bst.rho_mag_lo{stat_bst.cond_num==cond_b};

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

%%

ya = stat.rho_mag_hi(stat.cond_num==cond_a);
yb = stat.rho_mag_hi(stat.cond_num==cond_b);

% ya = stat.rho_mag_hi(stat.cond_num==cond_a & stat.targ_len==targ_n);
% yb = stat.rho_mag_hi(stat.cond_num==cond_b & stat.targ_len==targ_n);

% ya = stat_bst.rho_mag_hi{stat_bst.cond_num==cond_a};
% yb = stat_bst.rho_mag_hi{stat_bst.cond_num==cond_b};

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

