clear all; clc;

at_usp = true;

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


%%

%%% load data

sub = 4;       % 4 | 18 | 22
block = 6;

if sub < 10
    filedir = sprintf('%ssacsamp0%i_s0%i/', data_folder, sub, sub);
else
    filedir = sprintf('%ssacsamp%i_s%i/', data_folder, sub, sub);
end

filename = sprintf('dat_prep_b%i.mat', block);
load([filedir filename], 'dat')
dat_prep = dat;


%%% detect eye artifacts

cfg = [];
cfg.viewmode = 'vertical';
cfg.continuous = 'no';
cfg.layout = 'neuromag306all.lay';
cfg.allowoverlap = 'yes';
cfg.verticalpadding = 0.3;
cfg.channel = {'EYEH','EYEV'};      % {'EOGH','EOGV','EYEH','EYEV'};
cfg.chanscale = [0.3,0.3];          % [400,400,0.5,0.5];

cfg = ft_databrowser(cfg, dat_prep);
artifact_times = cfg.artfctdef.visual;


%%% remove artifacts

cfg = [];
cfg.artfctdef.visual = artifact_times;
cfg.artfctdef.reject = 'nan';               % fill rejected trials with nans
dat_clean = ft_rejectartifact(cfg, dat_prep);


%%% save data

dat = dat_clean;
filename = sprintf('dat_clean_b%i.mat', block);

if ~exist([filedir filename],'file')
    save([filedir filename],'dat')
else
    error('file already exists - not overwritting')
end
