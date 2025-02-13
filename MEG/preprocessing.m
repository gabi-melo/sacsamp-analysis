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


%%

%%% load data

sub = 22;       % 4 | 18 | 22
block = 12;

if sub < 10
    filedir = sprintf('%ssacsamp0%i_s0%i/', data_folder, sub, sub);
else
    filedir = sprintf('%ssacsamp%i_s%i/', data_folder, sub, sub);
end

if block < 10
    filename = sprintf('run0%i_sss.fif', block);
else
    filename = sprintf('run%i_sss.fif', block);
end
filepath = [filedir filename];


%%% define trials based on triggers

cfg = [];
cfg.dataset = filepath;
cfg.trialdef.eventtype = 'STI101';
cfg.trialdef.eventvalue = 81:92;      % target onset
cfg.trialdef.prestim = 0.2;
cfg.trialdef.poststim = 0.3;

cfg = ft_definetrial(cfg);

dat_preproc = ft_preprocessing(cfg);


%%% remove extra channels

if sub <= 9
    chans = {'all', '-IASX+', '-IASX-', '-IASY+', '-IASY-', '-IASZ+', '-IASZ-', '-IAS_DX', '-IAS_DY', '-IAS_X', '-IAS_Y', '-IAS_Z', '-SYS201'};
else
    chans = {'all', '-EXCI', '-IASX+', '-IASX-', '-IASY+', '-IASY-', '-IASZ+', '-IASZ-', '-IAS_DX', '-IAS_DY', '-IAS_X', '-IAS_Y', '-IAS_Z', '-SYS201'};
end

cfg = [];
cfg.channel = ft_channelselection(chans, dat_preproc.label);
dat_select = ft_selectdata(cfg, dat_preproc);


%%% rename channels

dat_select.label(1) = {'EOGH'};
dat_select.label(2) = {'EOGV'};
% dat_select.label(3) = {''};
% dat_select.label(310) = {''};
% dat_select.label(311) = {''};
dat_select.label(312) = {'EYEH'};
dat_select.label(313) = {'EYEV'};
dat_select.label(314) = {'PUPIL'};


%%% save data

dat = dat_select;
filename = sprintf('dat_prep_b%i.mat', block);
filepath = [filedir filename];
save(filepath, 'dat')







%%



sub = 4;       % 4 | 18 | 22
block = 4;

if sub < 10
    filedir = sprintf('%ssacsamp0%i_s0%i/', data_folder, sub, sub);
else
    filedir = sprintf('%ssacsamp%i_s%i/', data_folder, sub, sub);
end

if block < 10
    filename = sprintf('run0%i_sss.fif', block);
else
    filename = sprintf('run%i_sss.fif', block);
end
filepath = [filedir filename];


cfg = [];
cfg.dataset = filepath;
dat_preproc = ft_preprocessing(cfg);

if sub <= 9
    chans = {'all', '-IASX+', '-IASX-', '-IASY+', '-IASY-', '-IASZ+', '-IASZ-', '-IAS_DX', '-IAS_DY', '-IAS_X', '-IAS_Y', '-IAS_Z', '-SYS201'};
else
    chans = {'all', '-EXCI', '-IASX+', '-IASX-', '-IASY+', '-IASY-', '-IASZ+', '-IASZ-', '-IAS_DX', '-IAS_DY', '-IAS_X', '-IAS_Y', '-IAS_Z', '-SYS201'};
end

cfg = [];
cfg.channel = ft_channelselection(chans, dat_preproc.label);
dat_select = ft_selectdata(cfg, dat_preproc);

dat_select.label(1) = {'EOGH'};
dat_select.label(2) = {'EOGV'};
% dat_select.label(3) = {'ECG'};
% dat_select.label(310) = {'EMG1'};
% dat_select.label(311) = {'EMG2'};
dat_select.label(312) = {'EYEH'};
dat_select.label(313) = {'EYEV'};
dat_select.label(314) = {'PUPIL'};

%%
cfg = [];
cfg.viewmode = 'vertical';
cfg.continuous = 'yes'; 
cfg.layout = 'neuromag306all.lay';
cfg.allowoverlap = 'yes';
cfg.plotevents = 'yes';
cfg.blocksize = 50;
cfg.verticalpadding = 0.1;

% cfg.channel = {'EOGH','EOGV'};
cfg.channel = {'EOGH','EOGV','EYEH','EYEV'};
cfg.chanscale = [600,600,0.5,0.5];

ft_databrowser(cfg, dat_select);

%%

figure()
chan = find(strcmp(dat_select.label, 'EYEV'));
plot(dat_select.time{1}, dat_select.trial{1}(chan,:))

