clear all
clc

at_usp = true;

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

subs_meg = 1:28;
subs_meg([8 9 10 11 12 13]) = [];
conds_str = {'act','pas','fix'};

for s = 1:numel(subs_meg)
    si = subs_meg(s);
    if si < 10
        sub_folder{si} = sprintf('%ssacsamp0%i_s0%i/', data_folder, si, si);
    else
        sub_folder{si} = sprintf('%ssacsamp%i_s%i/', data_folder, si, si);
    end
end

% cfg.layout = 'neuromag306all.lay';
% cfg.layout = 'neuromag306mag.lay';
% cfg.layout = 'neuromag306planar.lay';
% cfg.layout = 'neuromag306cmb.lay';
% cfg.layout = 'neuromag306all_helmet.mat';


%% compute the timelocked average ERFs
    
subs = subs_meg;

for s = 1:numel(subs)
    si = subs(s);

    for c = 1:numel(conds_str)
        cs = conds_str{c};

        %%% load data
        file_dat = sprintf('dat_clean_%s.mat', cs);
        load([sub_folder{si} file_dat], 'dat')
        dat_clean = dat;

        %%% compute ERFs
        cfg = [];
        cfg.channel = {'megplanar'};
        dat_avg = ft_timelockanalysis(cfg, dat_clean);

        %%% combine planar gradiometers
        % cfg.demean = 'yes';            % perform baseline correction
        % cfg.baselinewindow = [-0.1 0];
        dat_cmb = ft_combineplanar(cfg, dat_cmb);

        %%% save ERF data
        fprintf('\n\n    saving ERF data - sub %i cond %s \n\n', si, cs)
        dat = dat_cmb;
        file_dat = sprintf('dat_cmb_%s.mat', cs);
        save([sub_folder{si} file_dat],'dat')
    end
end


%% compute the grand average over all subjects

for c = 1:numel(conds_str) 

    dat_avg_all = [];
    for s = 1:numel(subs_meg)
        file_sub = sprintf('dat_cmb_%s.mat', conds_str{c});
        load([sub_folder{subs_meg(s)} file_sub],'dat')
        dat_avg_all{s} = dat;
    end

    cfg = [];
    if c == 1
        gnd_avg_act = ft_timelockgrandaverage(cfg, dat_avg_all{:});
    elseif c == 2
        gnd_avg_pas = ft_timelockgrandaverage(cfg, dat_avg_all{:});
    else
        gnd_avg_fix = ft_timelockgrandaverage(cfg, dat_avg_all{:});
    end
end


%%
%%% plot ERFs for all sensors

cfg = [];
cfg.showlabels = 'yes';
cfg.fontsize = 8;
cfg.layout = 'neuromag306cmb.lay';

% ft_multiplotER(cfg, gnd_avg_act, gnd_avg_pas, gnd_avg_fix);
ft_multiplotER(cfg, gnd_avg_act);


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
