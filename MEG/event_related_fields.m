clear all
clc

at_usp = false;

if at_usp
    main_folder = '/Users/Gabi/Documents/GitHub/sacsamp-analysis/';
    data_folder = 'F:/sacsamp-data/';
    ft_folder = '/Users/Gabi/Documents/MATLAB/Fieldtrip/';
else
    main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
    data_folder = '/Volumes/PortableSSD/sacsamp-data/';
    ft_folder = '/Users/gabimelo/Documents/MATLAB/Fieldtrip/';
end

addpath(genpath(main_folder))
cd(main_folder)

addpath(ft_folder)
ft_defaults

subs_meg = [1:28];
subs_meg([8 9 10 11 12 13]) = [];
conds_str = {'act','pas','fix'};

for s = 1:numel(subs_meg)
    si = subs_meg(s);
    if si < 10
        sub_folder{si} = sprintf('/Volumes/PortableSSD/sacsamp-data/sacsamp0%i_s0%i/', si, si);
    else
        sub_folder{si} = sprintf('/Volumes/PortableSSD/sacsamp-data/sacsamp%i_s%i/', si, si);
    end
end


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

    
subs = subs_meg;

for s = 1:numel(subs)

    si = subs(s);

    for c = 1:numel(conds_str)

        cs = conds_str{c};

        %%% load data
    
        file_dat = sprintf('dat_clean_%s.mat', cs);
        load([sub_folder{si} file_dat], 'dat')
        dat_clean = dat;


        %%% compute the timelocked average ERFs

        cfg = [];
        % cfg.latency = [0 0.3];
        dat_avg = ft_timelockanalysis(cfg, dat_clean);
        
        
        %%% save ERF data
        
        fprintf('\n\n    saving ERF data - sub %i cond %s \n\n', si, cs)
        dat = dat_avg;
        file_dat = sprintf('dat_avg_%s.mat', cs);
        save([sub_folder{si} file_dat],'dat')

    end
end


%%

%%% get erfs from all subjects

subs = subs_meg;

for c = 1:numel(conds_str) 

    for s = 1:numel(subs)

        file_all = sprintf('dat_avg_%s.mat', conds_str{c});
        load([sub_folder{subs(s)} file_all],'dat')

        dat_avg_all{s} = dat;
    end

    file_all = sprintf('dat_avg_all_%s.mat', conds_str{c});
    dat = dat_avg_all;
    save([data_folder file_all],'dat')
end


%%

%%% calculate grand average by condition / magnetometers

file_act = 'dat_avg_all_act.mat';
load([data_folder file_act],'dat')
avg_all_act = dat;

file_pas = 'dat_avg_all_pas.mat';
load([data_folder file_pas],'dat')
avg_all_pas = dat;

file_fix = 'dat_avg_all_fix.mat';
load([data_folder file_fix],'dat')
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

%%% plot ERFs for a single sensor

cfg = [];
cfg.fontsize = 12;
cfg.showlegend = 'yes';
cfg.channel = 'MEG0111';

ft_singleplotER(cfg, gnd_avg_act, gnd_avg_pas, gnd_avg_fix);


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

%%

si = 4;

file_act = 'dat_avg_act.mat';
load([sub_folder{si} file_act],'dat')
avg_act = dat;

file_pas = 'dat_avg_pas.mat';
load([sub_folder{si} file_pas],'dat')
avg_pas = dat;

file_fix = 'dat_avg_fix.mat';
load([sub_folder{si} file_fix],'dat')
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


