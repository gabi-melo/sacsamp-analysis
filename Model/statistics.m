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

load('stat_dat.mat','stat_dat')
load('stat_fit_siginf.mat','stat_bst')


%%
%%% compare fitted parameters between conditions

load([main_folder 'Model/params_fit_siginf'],'params')
% load([main_folder 'Model/params_fit_all'],'params')

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

ya = stat_dat.rho_ang(stat_dat.cond_num==cond_a);
yb = stat_dat.rho_ang(stat_dat.cond_num==cond_b);

% ya = stat_dat.rho_ang(stat_dat.cond_num==cond_a & stat_dat.targ_len==targ_n);
% yb = stat_dat.rho_ang(stat_dat.cond_num==cond_b & stat_dat.targ_len==targ_n);

% ya = stat_bst.rho_ang{stat_bst.cond_num==cond_a};
% yb = stat_bst.rho_ang{stat_bst.cond_num==cond_b};

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

%%

ya = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_a);
yb = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_b);

% ya = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_a & stat_dat.targ_len==targ_n);
% yb = stat_dat.rho_mag_lo(stat_dat.cond_num==cond_b & stat_dat.targ_len==targ_n);

% ya = stat_bst.rho_mag_lo{stat_bst.cond_num==cond_a};
% yb = stat_bst.rho_mag_lo{stat_bst.cond_num==cond_b};

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

%%

ya = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_a);
yb = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_b);

% ya = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_a & stat_dat.targ_len==targ_n);
% yb = stat_dat.rho_mag_hi(stat_dat.cond_num==cond_b & stat_dat.targ_len==targ_n);

% ya = stat_bst.rho_mag_hi{stat_bst.cond_num==cond_a};
% yb = stat_bst.rho_mag_hi{stat_bst.cond_num==cond_b};

[H,P,CI,STATS] = ttest(ya,yb);

% [P,H,STATS] = signrank(ya,yb);

disp([mean(ya) mean(yb)])
disp(P)

