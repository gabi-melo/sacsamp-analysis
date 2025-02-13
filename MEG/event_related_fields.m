clear all; clc;

main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
data_folder = '/Volumes/PortableSSD/SACSAMP/';
ft_folder = '/Users/gabimelo/Documents/MATLAB/Fieldtrip/';

% main_folder = '/Users/Gabi/Documents/GitHub/sacsamp-analysis/';
% data_folder = 'F:/SACSAMP/';
% ft_folder = '/Users/Gabi/Documents/MATLAB/Fieldtrip/';

addpath(genpath(main_folder))
cd(main_folder)

addpath(ft_folder)
ft_defaults


%%

%%% load data

sub = 4;       % 04 | 18 | 22
block = 12;

if sub < 10
    filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp0%i_s0%i/', sub, sub);
else
    filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);
end

filename = sprintf('dat_filt_b%i.mat', block);
filepath = [filedir filename];
load(filepath, 'dat')
dat_filt = dat;


%%% preprocess data

cfg = [];
chans_mag = ft_channelselection('megmag', dat_filt.hdr.label);
cfg.channel = chans_mag; 
dat_mag = ft_preprocessing(cfg, dat_filt);


%%% compute the timelocked average ERFs

cfg = [];
% cfg.latency = [0 0.3];
dat_erf = ft_timelockanalysis(cfg, dat_mag);


%%% save data

dat = dat_erf;
filename = sprintf('dat_erf_b%i.mat', block);
filepath = [filedir filename];
save(filepath,'dat')


%%

sub = 4;  

if sub < 10
    filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp0%i_s0%i/', sub, sub);
else
    filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);
end

blocks = [3 6 9 12];

for b = 1:4

    block = blocks(b);
    filename = sprintf('dat_erf_b%i.mat', block);
    filepath = [filedir filename];
    load(filepath, 'dat')
    
    dat_erf_all(b) = dat;
end

dat = dat_erf_all;
filename = 'dat_erf_all';
filepath = [filedir filename];
save(filepath,'dat')


%% plot ERFs for all sensors

cfg = [];
cfg.showlabels = 'yes';
cfg.fontsize = 8;
cfg.layout = 'neuromag306all.lay';

ft_multiplotER(cfg, dat_erf);


%% plot topographic distribution of ERFs

cfg = [];
cfg.fontsize = 10;
cfg.xlim = [0 0.5];
cfg.colorbar = 'yes';
cfg.layout = 'neuromag306all.lay';

ft_topoplotER(cfg, dat_erf);


%% plot topographic distribution of ERFs over time

cfg = [];
cfg.fontsize = 10;
cfg.xlim = [-0.2 : 0.1 : 0.3];

cfg.colorbar = 'yes';
cfg.layout = 'neuromag306all.lay';

ft_topoplotER(cfg, dat_erf);


%% plot ERFs for a single sensor

cfg = [];
cfg.fontsize = 12;
cfg.channel = 'MEG2333';

ft_singleplotER(cfg, dat_erf);

