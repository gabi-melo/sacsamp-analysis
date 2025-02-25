clear all
clc

at_usp = false;

if at_usp
    main_folder = '/Users/Gabi/Documents/GitHub/sacsamp-analysis/';
    data_folder = 'F:/SACSAMP/';
    ft_folder = '/Users/Gabi/Documents/MATLAB/Fieldtrip/';
else
    main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
    data_folder = '/Volumes/PortableSSD/SACSAMP/';
    ft_folder = '/Users/gabimelo/Documents/MATLAB/Fieldtrip/';
end

addpath(genpath(main_folder))
cd(main_folder)

addpath(ft_folder)
ft_defaults

conds = {'act','pas','fix'};

filedir_gen = '/Volumes/PortableSSD/SACSAMP/';


% cfg.layout = 'neuromag306all.lay';
% cfg.layout = 'neuromag306mag.lay';
% cfg.layout = 'neuromag306planar.lay';
% cfg.layout = 'neuromag306cmb.lay';

% cfg.layout = 'neuromag306all_helmet.mat';
% cfg.layout = 'neuromag306mag_helmet.mat';
% cfg.layout = 'neuromag306planar_helmet.mat';
% cfg.layout = 'neuromag306cmb_helmet.mat';

% cfg.template = 'neuromag306mag_neighb.mat'
% cfg.template = 'neuromag306planar_neighb.mat'
% cfg.template = 'neuromag306cmb_neighb.mat'


%%

%%% get erfs from all subjects

subs = [4 18];

for c = 1:numel(conds) 

    for s = 1:numel(subs)

        filename = sprintf('dat_avg_%s.mat', conds{c});
        load([filedir{subs(s)} filename],'dat')

        dat_avg_all{s} = dat;
    end

    filename = sprintf('dat_avg_all_%s.mat', conds{c});
    dat = dat_avg_all;
    save([filedir_gen filename],'dat')
end


%%

%%% calculate grand average by condition / magnetometers

filename = 'dat_avg_all_act.mat';
load([filedir_gen filename],'dat')
avg_all_act = dat;

filename = 'dat_avg_all_pas.mat';
load([filedir_gen filename],'dat')
avg_all_pas = dat;

filename = 'dat_avg_all_fix.mat';
load([filedir_gen filename],'dat')
avg_all_fix = dat;

cfg = [];
cfg.channel = {'megmag'};
cfg.latency = 'all';
cfg.parameter = 'avg';
gnd_avg_act = ft_timelockgrandaverage(cfg, avg_all_act{:});
gnd_avg_pas = ft_timelockgrandaverage(cfg, avg_all_pas{:});
gnd_avg_fix = ft_timelockgrandaverage(cfg, avg_all_fix{:});


%%

%%% plot ERFs for all sensors

cfg = [];
cfg.channel = {'megmag'};
cfg.showlabels = 'yes';
cfg.fontsize = 8;
cfg.layout = 'neuromag306mag.lay';

ft_multiplotER(cfg, gnd_avg_act, gnd_avg_pas, gnd_avg_fix);


%%

%%% plot topographic distribution of ERFs

cfg = [];
cfg.channel = {'megmag'};
cfg.fontsize = 10;
% cfg.xlim = [0 0.2];
cfg.xlim = [0 : 0.05 : 0.2];      % plot over time
% cfg.xlim = [-0.2 : 0.1 : 0.3];      % plot over time
cfg.colorbar = 'yes';
% cfg.layout = 'neuromag306mag.lay';
cfg.layout = 'neuromag306mag_helmet.mat';

ft_topoplotER(cfg, gnd_avg_act);
sgtitle('ACT')
ft_topoplotER(cfg, gnd_avg_pas);
sgtitle('PAS')
ft_topoplotER(cfg, gnd_avg_fix);
sgtitle('FIX')


%%

%%% t-test with Bonferroni correction

cfg = [];
cfg.channel = 'megmag';  
cfg.latency = [0 0.2];
cfg.avgovertime = 'yes';
cfg.parameter = 'avg';
cfg.method = 'analytic';
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.alpha = 0.05;
% cfg.correctm = 'no';
cfg.correctm = 'bonferroni';

n_sub = 2;
cfg.design(1,1:2*n_sub) = [ones(1,n_sub) 2*ones(1,n_sub)];
cfg.design(2,1:2*n_sub) = [1:n_sub 1:n_sub];
cfg.ivar = 1;           % the 1st row in cfg.design contains the independent variable
cfg.uvar = 2;           % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg, avg_all_act{:}, avg_all_pas{:});


cfg = [];
cfg.style = 'blank';
cfg.layout = 'neuromag306mag_helmet.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment = 'no';

figure()
ft_topoplotER(cfg, gnd_avg_act)
title('t-test (bonferroni correction)')


%%

%%% permutation test

cfg = [];
cfg.channel = 'megmag';
cfg.latency = [0 0.2];
cfg.avgovertime = 'yes';
cfg.parameter = 'avg';
cfg.method = 'montecarlo';
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.alpha = 0.05;
cfg.correctm = 'no';
cfg.correcttail = 'prob';
cfg.numrandomization = 'all';      % with n subjects, there are 2^n possible permutations

n_sub = 2;
cfg.design(1,1:2*n_sub) = [ones(1,n_sub) 2*ones(1,n_sub)];
cfg.design(2,1:2*n_sub) = [1:n_sub 1:n_sub];
cfg.ivar = 1;           % the 1st row in cfg.design contains the independent variable
cfg.uvar = 2;           % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg, avg_all_act{:}, avg_all_pas{:})


cfg = [];
cfg.style = 'blank';
cfg.layout = 'neuromag306mag_helmet.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment = 'no';

figure()
ft_topoplotER(cfg, gnd_avg_act)
title('nonparametric test')


%%

%%% permutation test with cluster-based multiple comparison correction
% average the effect over a predefined time window

cfg = [];
cfg.feedback = 'yes';
cfg.method = 'template';        % 'distance' | 'triangulation' | template'
cfg.channel = 'megmag';
cfg.template = 'neuromag306mag_neighb.mat';
cfg.layout = 'neuromag306mag.lay';
neighbours = ft_prepare_neighbours(cfg, gnd_avg_act);

cfg = [];
cfg.channel = 'megmag';
cfg.neighbours = neighbours; 
cfg.latency = [0 0.2];
cfg.avgovertime = 'yes';
cfg.parameter = 'avg';
cfg.method = 'montecarlo';
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.alpha = 0.05;
cfg.correctm = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization = 'all';      % with n subjects, there are 2^n possible permutations 

n_sub = 2;
cfg.design(1,1:2*n_sub) = [ones(1,n_sub) 2*ones(1,n_sub)];
cfg.design(2,1:2*n_sub) = [1:n_sub 1:n_sub];
cfg.ivar = 1;           % the 1st row in cfg.design contains the independent variable
cfg.uvar = 2;           % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg, avg_all_act{:}, avg_all_pas{:});


cfg = [];
cfg.style = 'blank';
cfg.layout = 'neuromag306mag_helmet.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment = 'no';
figure() 
ft_topoplotER(cfg, gnd_avg_act)
title('nonparametric test (cluster-based correction)')


%%

%%% permutation test with cluster-based multiple comparison correction
% cluster simultaneously over neighbouring channels and neighbouring time points

cfg = [];
cfg.channel = 'megmag';
cfg.neighbours = neighbours; 
cfg.latency = [0 0.2];
cfg.avgovertime = 'no';
cfg.parameter = 'avg';
cfg.method = 'montecarlo';
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.alpha = 0.05;
cfg.correctm  = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization = 'all';  
cfg.minnbchan = 2;      % minimal number of neighbouring channels

n_sub = 2;
cfg.design(1,1:2*n_sub) = [ones(1,n_sub) 2*ones(1,n_sub)];
cfg.design(2,1:2*n_sub) = [1:n_sub 1:n_sub];
cfg.ivar = 1;           % the 1st row in cfg.design contains the independent variable
cfg.uvar = 2;           % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg, avg_all_act{:}, avg_all_pas{:});


cfg = [];
cfg.highlightsymbolseries = ['*','*','.','.','.'];
cfg.layout = 'neuromag306mag_helmet.mat';
cfg.contournum = 0;
cfg.markersymbol = '.';
cfg.alpha = 0.05;
cfg.parameter = 'stat';
cfg.zlim = [-5 5];
ft_clusterplot(cfg, stat)

