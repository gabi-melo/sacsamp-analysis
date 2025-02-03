clear all; clc;

main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
addpath(genpath(main_folder))
cd(main_folder)

load([main_folder 'full_data.mat'],'data','trls')
full_data = data;
full_trls = trls;
clear data trls

addpath('/Users/gabimelo/Documents/MATLAB/Fieldtrip/')
ft_defaults

% https://www.fieldtriptoolbox.org/tutorial/sensor/eventrelatedaveraging/


%%

sub = 18;       % 04 | 18 | 22
cond = 'fix';

filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);

filename = sprintf('data_prep_%s.mat', cond);
filepath = [filedir filename];
load(filepath,'dat_all')

filename = sprintf('evt_prep_%s.mat', cond);
filepath = [filedir filename];
load(filepath,'evt')


%%

% preprocess the data
cfg.channel = {'MEG*'};       
cfg.demean = 'yes';
cfg.baselinewindow = [-0.25 0];
cfg.lpfilter = 'yes';                            % apply lowpass filter
cfg.lpfreq = 35;                                 % lowpass at 35 Hz

dat_evt = ft_preprocessing(cfg, dat_meg_clean);


%%

cfg = [];
avg_evt = ft_timelockanalysis(cfg, dat_evt);


%%

cfg = [];
cfg.showlabels = 'yes';
cfg.fontsize = 6;
cfg.layout = 'neuromag306all.lay';
% cfg.baseline = [-0.25 0];
% cfg.xlim = [-0.25 0.5];
% cfg.ylim = [-3e-13 3e-13];

ft_multiplotER(cfg, avg_evt);


%%

cfg = [];
% cfg.xlim = [-0.2 1.0];
% cfg.ylim = [-1e-13 3e-13];
cfg.channel = 'MEG2333';
ft_singleplotER(cfg, avg_evt);


%%

cfg = [];
% cfg.xlim = [0.3 0.5];
cfg.colorbar = 'yes';
cfg.layout = 'neuromag306all.lay';
ft_topoplotER(cfg, avg_evt);

