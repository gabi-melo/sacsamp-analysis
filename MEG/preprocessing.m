clear all; clc;

% main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
main_folder = '/Users/Gabi/Documents/GitHub/sacsamp-analysis/';

addpath(genpath(main_folder))
cd(main_folder)

% addpath('/Users/gabimelo/Documents/MATLAB/Fieldtrip/')
addpath('/Users/Gabi/Documents/MATLAB/Fieldtrip/')
ft_defaults


% trigger labels
% act|pas|fix
% 12 |13 |14 - block onset
% 16 |17 |18 - block offset
% 20 |21 |22 - fixation point onset
% 24 |25 |26 - fixation point offset
% 28 |29 |30 - response onset
% 32 |33 |34 - response offset

% 41:52 - array onset
% 81:92 - target onset


% blocks num
% act|pas|fix
%  1 | 2 | 3 
%  4 | 5 | 6 
%  7 | 8 | 9 
% 10 |11 |12 


%% select single block

sub = 4;       % 4 | 18 | 22
block = 3;

if sub < 10
    filedir = sprintf('F:/SACSAMP/sacsamp0%i_s0%i/', sub, sub);
    % filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp0%i_s0%i/', sub, sub);
else
    filedir = sprintf('F:/SACSAMP/sacsamp%i_s%i/', sub, sub);
    % filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);
end

if block < 10
    filename = sprintf('run0%i_sss.fif', block);
else
    filename = sprintf('run%i_sss.fif', block);
end
filepath = [filedir filename];


%% select all blocks from a condition

sub = 4;       % 4 | 18 | 22
cond = 'fix';

if strcmp(cond, 'act')
    blocks = [1 4 7 10];
elseif strcmp(cond, 'pas')
    blocks = [2 5 8 11];
elseif strcmp(cond, 'fix')
    blocks = [3 6 9 12];
end

if sub < 10
    filedir = sprintf('F:/SACSAMP/sacsamp0%i_s0%i/', sub, sub);
    % filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp0%i_s0%i/', sub, sub);
else
    filedir = sprintf('F:/SACSAMP/sacsamp%i_s%i/', sub, sub);
    % filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);
end

filename1 = sprintf('run0%i_sss.fif', blocks(1));
filename2 = sprintf('run0%i_sss.fif', blocks(2));
filename3 = sprintf('run0%i_sss.fif', blocks(3));
filename4 = sprintf('run%i_sss.fif', blocks(4));

filepath1 = [filedir filename1];
filepath2 = [filedir filename2];
filepath3 = [filedir filename3];
filepath4 = [filedir filename4];

hdr1 = ft_read_header(filepath1);
raw1 = ft_read_data(filepath1);
evt1 = ft_read_event(filepath1);

hdr2 = ft_read_header(filepath2);
raw2 = ft_read_data(filepath2);
evt2 = ft_read_event(filepath2);

hdr3 = ft_read_header(filepath3);
raw3 = ft_read_data(filepath3);
evt3 = ft_read_event(filepath3);

hdr4 = ft_read_header(filepath4);
raw4 = ft_read_data(filepath4);
evt4 = ft_read_event(filepath4);

hdr = hdr1;              
raw = cat(2, raw1, raw2, raw3, raw4);     % concatenate data 

% shift the sample of the triggers
for i=1:length(evt2)
  evt2(i).sample = evt2(i).sample + hdr1.nSamples; 
end
for i=1:length(evt3)
  evt3(i).sample = evt3(i).sample + hdr2.nSamples; 
end
for i=1:length(evt4)
  evt4(i).sample = evt4(i).sample + hdr3.nSamples;
end

evt = cat(1, evt1, evt2, evt3, evt4);     % concatenate events

filename = sprintf('data_raw_%s.vhdr', cond);
filepath = [filedir filename];
ft_write_data(filepath, raw, 'header', hdr, 'event', evt);


%% define trials based on triggers

cfg = [];
cfg.dataset = filepath;
cfg.trialdef.eventtype = 'STI101';
cfg.trialdef.eventvalue = 81:92;      % target onset
cfg.trialdef.prestim = 0.2;
cfg.trialdef.poststim = 0.3;

cfg = ft_definetrial(cfg);


%% preprocess data

cfg.bsfilter = 'yes';                      % apply band-stop filter to remove line noise
cfg.bsfreq = [49 51; 99 100; 149 151];     % line frequency and its harmonics

% cfg.dftfilter = 'yes';           % apply discrete Fourier transform filter to remove line noise
% cfg.dftfreq = [50 100 150];      % line frequency and its harmonics
% cfg.padding = 5;                 % length (seconds) of trial padding

dat_preproc = ft_preprocessing(cfg);


%%

cfg = [];
cfg.viewmode = 'vertical';
% cfg.viewmode = 'butterfly';
cfg.continuous = 'no'; 
cfg.layout = 'neuromag306all.lay';
cfg.allowoverlap = 'yes';
cfg.preproc.demean = 'yes';

cfg.channel = [chans_mag(1:40)];

ft_databrowser(cfg, dat_preproc);


%%

chan = find(strcmp(dat_preproc.label, 'MEG0111'));
plot(dat_preproc.time{1}, dat_preproc.trial{1}(chan,:))


%% remove extra channels

if sub <= 9
    chans = {'all', '-IASX+', '-IASX-', '-IASY+', '-IASY-', '-IASZ+', '-IASZ-', '-IAS_DX', '-IAS_DY', '-IAS_X', '-IAS_Y', '-IAS_Z', '-SYS201'};
else
    chans = {'all', '-EXCI', '-IASX+', '-IASX-', '-IASY+', '-IASY-', '-IASZ+', '-IASZ-', '-IAS_DX', '-IAS_DY', '-IAS_X', '-IAS_Y', '-IAS_Z', '-SYS201'};
end

cfg = [];
cfg.channel = ft_channelselection(chans, dat_preproc.label);

dat_select = ft_selectdata(cfg, dat_preproc);


%% rename channels

dat_select.label(1) = {'EOGH'};
dat_select.label(2) = {'EOGV'};
dat_select.label(3) = {'ECG'};
dat_select.label(310) = {'EMG1'};
dat_select.label(311) = {'EMG2'};
dat_select.label(312) = {'EYEH'};
dat_select.label(313) = {'EYEV'};
dat_select.label(314) = {'PUPIL'};


%% save data

dat = dat_select;

% filename = sprintf('dat_prep_%s.mat', cond);
filename = sprintf('dat_prep_b%i_%s.mat', block, cond);
filepath = [filedir filename];
save(filepath, 'dat')

