clear all; clc;

main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
addpath(genpath(main_folder))
cd(main_folder)

addpath('/Users/gabimelo/Documents/MATLAB/Fieldtrip/')
ft_defaults

% https://www.fieldtriptoolbox.org/tutorial/sensor/eventrelatedaveraging/


%% load data file

sub = 4;       % 04 | 18 | 22
cond = 'fix';

if sub < 10
    filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp0%i_s0%i/', sub, sub);
else
    filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);
end

filename = sprintf('data_clean_%s.mat', cond);
filepath = [filedir filename];
load(filepath, 'dat')


%% preprocess data

cfg = [];

chans_mag = ft_channelselection('megmag', dat.hdr.label);
cfg.channel = chans_mag; 

cfg.demean = 'yes';
% cfg.baselinewindow = [-0.25 0];

dat_evt = ft_preprocessing(cfg, dat);


%% compute the timelocked average ERFs

cfg = [];
avg_evt = ft_timelockanalysis(cfg, dat_evt);


%% plot ERFs for all sensors

cfg = [];
cfg.showlabels = 'yes';
cfg.fontsize = 8;
cfg.layout = 'neuromag306all.lay';
% cfg.xlim = [-0.25 0.5];
% cfg.ylim = [-3e-13 3e-13];

ft_multiplotER(cfg, avg_evt);


%% plot ERFs for a single sensor

cfg = [];
cfg.fontsize = 12;
cfg.channel = 'MEG2333';

ft_singleplotER(cfg, avg_evt);


%% plot topographic distribution of ERFs

cfg = [];
cfg.fontsize = 10;
cfg.xlim = [0 0.5];
cfg.colorbar = 'yes';
cfg.layout = 'neuromag306all.lay';

ft_topoplotER(cfg, avg_evt);


%% plot topographic distribution of ERFs over time

cfg = [];
cfg.fontsize = 10;
% cfg.xlim = [-0.25 : 0.25 : 0.5];
cfg.xlim = [-0.2 : 0.1 : 0.5];

cfg.colorbar = 'yes';
cfg.layout = 'neuromag306all.lay';

ft_topoplotER(cfg, avg_evt);

