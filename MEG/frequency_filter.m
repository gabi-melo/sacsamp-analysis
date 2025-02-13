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

sub = 4;       % 4 | 18 | 22
block = 12;

if sub < 10
    filedir = sprintf('%ssacsamp0%i_s0%i/', data_folder, sub, sub);
else
    filedir = sprintf('%ssacsamp0%i_s%i/', data_folder, sub, sub);
end

filename = sprintf('dat_clean_b%i.mat', block);
filepath = [filedir filename];
load(filepath, 'dat')
dat_clean = dat;


%%% apply line noise filter

% cfg.bsfilter = 'yes';                      % apply band-stop filter
% cfg.bsfreq = [49 51; 99 100; 149 151];     % line frequency and its harmonics

cfg = [];
cfg.dftfilter = 'yes';           % apply discrete Fourier transform filter
cfg.dftfreq = [50 100 150];      % line frequency and its harmonics
cfg.padding = 5;                 % length (seconds) of trial padding
dat_dft = ft_preprocessing(cfg, dat_clean);


%%% apply lowpass filter

cfg = [];
cfg.lpfilter = 'yes';                 
cfg.lpfreq = 35;                 % lowpass at 35 Hz
dat_lp = ft_preprocessing(cfg, dat_dft);


%%% save data

dat = dat_lp;
filename = sprintf('dat_filt_b%i.mat', block);
filepath = [filedir filename];
save(filepath,'dat')


