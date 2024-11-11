clear all
close all
clc

project_path = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';

addpath(genpath(project_path))
cd(project_path)

load([project_path 'full_data.mat'])

% cond #1 = saccade active
% cond #2 = saccade passive
% cond #3 = fixation


%%
%%% compare fitted parameters between conditions

% load([project_path 'Model/Outputs/params_fit_siginf'],'fit_siginf')
load([project_path 'Model/Outputs/params_fit_all'],'fit_all')

% params = fit_all;

cond_a = 1;
cond_b = 3;


%%

ya = params.siginf(:,cond_a);
yb = params.siginf(:,cond_b);

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

%%

ya = params.plapse(:,cond_a);
yb = params.plapse(:,cond_b);

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

%%

ya = params.alpha(:,cond_a);
yb = params.alpha(:,cond_b);

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

%%

ya = params.sigsen(:,cond_a);
yb = params.sigsen(:,cond_b);

[H,P,CI,STATS] = ttest(ya,yb);

[P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

%%

ya = params.sigrep(:,cond_a);
yb = params.sigrep(:,cond_b);

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

