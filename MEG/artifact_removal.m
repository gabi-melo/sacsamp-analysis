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


%% load data file

sub = 4;       % 4 | 18 | 22
block = 3;

if sub < 10
    filedir = sprintf('%ssacsamp0%i_s0%i/', data_folder, sub, sub);
else
    filedir = sprintf('%ssacsamp0%i_s%i/', data_folder, sub, sub);
end

filename = sprintf('dat_prep_b%i.mat', block);
filepath = [filedir filename];
load(filepath, 'dat')


%% detect eye artifacts using ft_databrowser

cfg = [];
cfg.viewmode = 'vertical';
cfg.continuous = 'no';
cfg.layout = 'neuromag306all.lay';
cfg.allowoverlap = 'yes';
cfg.preproc.demean = 'yes';
cfg.plotevents = 'yes';
cfg.verticalpadding = 0.1;

% cfg.channel = {'EYEH','EYEV'};
cfg.channel = {'EOGH','EOGV','EYEH','EYEV'};
cfg.chanscale = [400,400,0.5,0.5];

cfg = ft_databrowser(cfg, dat);

% keep the time of the artifacts
cfg_artfctdef = cfg.artfctdef;


%% remove eye artifacts

cfg = [];
cfg.artifactdef = cfg_artfctdef;
% cfg.artfctdef.reject = 'nan';       % replace artifacts with NaNs (rather than excluding)

% remove artifacts
dat_clean = ft_rejectartifact(cfg, dat);


%% save data

dat = dat_clean;

filename = sprintf('data_clean_b%s.mat', block);
filepath = [filedir filename];
save(filepath,'dat')


%% apply frequency filters

%%% line noise filter

% cfg.bsfilter = 'yes';                      % apply band-stop filter
% cfg.bsfreq = [49 51; 99 100; 149 151];     % line frequency and its harmonics

cfg.dftfilter = 'yes';           % apply discrete Fourier transform filter
cfg.dftfreq = [50 100 150];      % line frequency and its harmonics
cfg.padding = 5;                 % length (seconds) of trial padding

dat_dftfilter = ft_preprocessing(cfg, dat_clean);


%%% lowpass filter

cfg = [];
cfg.lpfilter = 'yes';                 
cfg.lpfreq = 35;          % lowpass at 35 Hz

dat_lpfilt = ft_preprocessing(cfg, dat_dftfilter);


%% save data

dat = dat_lpfilt;

filename = sprintf('data_filt_b%s.mat', block);
filepath = [filedir filename];
save(filepath,'dat')



