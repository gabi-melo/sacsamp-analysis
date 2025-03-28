clear all
clc

at_usp = false;

if at_usp
    main_folder = '/Users/Gabi/Documents/GitHub/sacsamp-analysis/';
else
    main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
end

addpath(genpath(main_folder))
cd(main_folder)

load('Model/stat_dat.mat','stat_dat')
load('Model/stat_fit_siginf.mat','stat_bst')
load('Model/params_fit_siginf','params')

load('Model/stat_bst_fit_siginf_v2.mat','stat_bst')
load('Model/params_fit_siginf_v2','params')

cond_name = {'ACT','PAS','FIX'};


%%
%%% compare fitted parameters between conditions


cond_a = 3;
cond_b = 2;


%%% siginf

ya = params.siginf(:,cond_a);
yb = params.siginf(:,cond_b);
[H,P,CI,STATS] = ttest(ya,yb);
% [P,H,STATS] = signrank(ya,yb);

fprintf('\n\n siginf : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%% plapse

ya = params.plapse(:,cond_a);
yb = params.plapse(:,cond_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n plapse : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%% alpha

ya = params.alpha(:,cond_a);
yb = params.alpha(:,cond_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n alpha  : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%
%%% compare correlation coef between conditions (data)


cond_a = 2;
cond_b = 3;


%%% rho_ang

ya = stat_dat.rho_ang(stat_dat.cond_num==cond_a);
yb = stat_dat.rho_ang(stat_dat.cond_num==cond_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n rho_ang      : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%% rho_mag_low

ya = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_a);
yb = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_low  : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%% rho_mag_high

ya = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_a);
yb = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_high : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%
%%% compare correlation coef between conditions (model)


cond_a = 1;
cond_b = 2;


%%% rho_ang

ya = stat_bst.rho_ang{stat_bst.cond_num==cond_a};
yb = stat_bst.rho_ang{stat_bst.cond_num==cond_b};
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n rho_ang      : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%% rho_mag_low

ya = stat_bst.rho_mag_lo{stat_bst.cond_num==cond_a};
yb = stat_bst.rho_mag_lo{stat_bst.cond_num==cond_b};
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_low  : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%% rho_mag_high

ya = stat_bst.rho_mag_hi{stat_bst.cond_num==cond_a};
yb = stat_bst.rho_mag_hi{stat_bst.cond_num==cond_b};
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_high : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%
%%% compare correlation coef between conditions (data)


cond_a = 3;
cond_b = 2;
targ_n = 12;


%%% rho_ang

ya = stat_dat.rho_ang(stat_dat.cond_num==cond_a & stat_dat.targ_len==targ_n);
yb = stat_dat.rho_ang(stat_dat.cond_num==cond_b & stat_dat.targ_len==targ_n);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n rho_ang      : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%% rho_mag_low

ya = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_a & stat_dat.targ_len==targ_n);
yb = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_b & stat_dat.targ_len==targ_n);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_low  : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%% rho_mag_high

ya = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_a & stat_dat.targ_len==targ_n);
yb = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_b & stat_dat.targ_len==targ_n);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_high : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%

ya = stat_dat.rho_mag_lo;
yb = stat_dat.rho_mag_hi;
[H,P,CI,STATS] = ttest(ya,yb)

% cond_a = 3;
% 
% ya = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_a);
% yb = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_a);
% [H,P,CI,STATS] = ttest(ya,yb);
% 
% 
% cond_a = 3;
% targ_n = 12;
% 
% ya = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_a & stat_dat.targ_len==targ_n);
% yb = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_a & stat_dat.targ_len==targ_n);
% [H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_low mean = %.2f, rho_mag_high mean = %.2f, p = %.2f \n', mean(ya), mean(yb), P)



%%
%%% compare correlation coef between trial lenghts (data)


targ_a = 8;
targ_b = 12;


cond_n = 1;

ya = stat_dat.rho_ang(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.rho_ang(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n rho_ang (%s)      : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


ya = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_low (%s)  : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


ya = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_high (%s) : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


cond_n = 2;

ya = stat_dat.rho_ang(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.rho_ang(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n rho_ang (%s)      : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


ya = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_low (%s)  : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


ya = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_high (%s) : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


cond_n = 3;

ya = stat_dat.rho_ang(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.rho_ang(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n rho_ang (%s)      : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


ya = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_low (%s)  : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


ya = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n rho_mag_high (%s) : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


%%
%%% compare error std dev between conditions (data)


cond_a = 2;
cond_b = 3;


ya = stat_dat.sig_err(stat_dat.cond_num==cond_a);
yb = stat_dat.sig_err(stat_dat.cond_num==cond_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n sig_err      : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%
%%% compare error std dev between conditions (model)


cond_a = 1;
cond_b = 2;


%%% rho_ang

ya = stat_bst.sig_err{stat_bst.cond_num==cond_a};
yb = stat_bst.sig_err{stat_bst.cond_num==cond_b};
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n sig_err      : mean %s = %.2f, mean %s = %.2f, p = %.2f \n', cond_name{cond_a}, mean(ya), cond_name{cond_b}, mean(yb), P)


%%
%%% compare error std dev between trial lenghts (data)


targ_a = 4;
targ_b = 8;


cond_n = 1;

ya = stat_dat.sig_err(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.sig_err(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n sig_err (%s)      : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


cond_n = 2;

ya = stat_dat.sig_err(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.sig_err(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n sig_err (%s)      : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)


cond_n = 3;

ya = stat_dat.sig_err(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_a);
yb = stat_dat.sig_err(stat_dat.cond_num==cond_n & stat_dat.targ_len==targ_b);
[H,P,CI,STATS] = ttest(ya,yb);

fprintf('\n\n sig_err (%s)      : mean %i = %.2f, mean %i = %.2f, p = %.2f \n', cond_name{cond_n}, targ_a, mean(ya), targ_b, mean(yb), P)

