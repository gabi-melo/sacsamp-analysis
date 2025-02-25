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

subs_meg = [1:28];
subs_meg([8 9 10 11 12 13]) = [];
conds = {'act','pas','fix'};

for s = 1:numel(subs_meg)
    sub = subs_meg(s);
    if sub < 10
        filedir{sub} = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp0%i_s0%i/', sub, sub);
    else
        filedir{sub} = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);
    end
end

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


%% event-related fields (ERFs)

    
subs = [4 18];

for s = 1:numel(subs)

    sub = subs(s);

    for c = 1:numel(conds)

        cond = conds{c};

        %%% load data
    
        filename = sprintf('dat_filt_%s.mat', cond);
        load([filedir{sub} filename], 'dat')
        dat_filt = dat;


        %%% compute the timelocked average ERFs

        cfg = [];
        % cfg.latency = [0 0.3];
        dat_avg = ft_timelockanalysis(cfg, dat_filt);
        
        
        %%% save ERF data
        
        fprintf('\n\n    saving ERF data - sub %i cond %s \n\n', sub, cond)

        dat = dat_avg;
        filename = sprintf('dat_avg_%s.mat', cond);
        save([filedir{sub} filename],'dat')

    end
end


%%

sub = 4;

filename = 'dat_avg_act.mat';
load([filedir{sub} filename],'dat')
avg_act = dat;

filename = 'dat_avg_pas.mat';
load([filedir{sub} filename],'dat')
avg_pas = dat;

filename = 'dat_avg_fix.mat';
load([filedir{sub} filename],'dat')
avg_fix = dat;


%% 

%%% plot ERFs for all sensors

cfg = [];
cfg.channel = {'megmag'};
cfg.showlabels = 'yes';
cfg.fontsize = 8;
cfg.layout = 'neuromag306mag.lay';

ft_multiplotER(cfg, avg_act);
sgtitle('ACT')
ft_multiplotER(cfg, avg_pas);
sgtitle('PAS')
ft_multiplotER(cfg, avg_fix);
sgtitle('FIX')


%% 

%%% plot topographic distribution of ERFs

cfg = [];
cfg.channel = {'megmag'};
cfg.fontsize = 10;
cfg.xlim = [0 0.3];
% cfg.xlim = [-0.2 : 0.1 : 0.3];      % plot over time
cfg.colorbar = 'yes';
% cfg.layout = 'neuromag306mag_helmet.mat';
cfg.layout = 'neuromag306mag.lay';

ft_topoplotER(cfg, avg_act);
sgtitle('ACT')
ft_topoplotER(cfg, avg_pas);
sgtitle('PAS')
ft_topoplotER(cfg, avg_fix);
sgtitle('FIX')


%% 

%%% plot ERFs for a single sensor

cfg = [];
cfg.fontsize = 12;
cfg.channel = 'MEG2333';

ft_singleplotER(cfg, avg_act);
sgtitle('ACT')
ft_singleplotER(cfg, avg_pas);
sgtitle('PAS')
ft_singleplotER(cfg, avg_fix);
sgtitle('FIX')


