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

load('full_data.mat','data')
task_info = data;
clear data

sub_n = [10 9 13 4 17 21 11 1 22 25 26 19 18 20 28 34 23 27 49 42 35 45 36 48 16 29 38 30];

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

sub = 4;       % 4 | 18 | 22
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


%%% define trials based on triggers

cfg = [];
cfg.dataset = [filedir filename];
cfg.trialdef.eventtype = 'STI101';
cfg.trialdef.eventvalue = 81:92;      % target onset
cfg.trialdef.prestim = 0.2;
cfg.trialdef.poststim = 0.3;

cfg = ft_definetrial(cfg);


%%% add trial info to cfg.trl

trl_num = task_info.trl_num(task_info.sub_num == sub_n(sub) & task_info.blc_num==block);
targ_len = task_info.targ_len(task_info.sub_num == sub_n(sub) & task_info.blc_num==block);
targ_num = task_info.targ_num(task_info.sub_num == sub_n(sub) & task_info.blc_num==block);

% deal with trigger duplicates
if length(cfg.trl) > 216
    r = find((diff(cfg.trl(:,4))>1) | (diff(cfg.trl(:,4))==0));
    for i = 1:numel(r)
        trl_num = trl_num([1:r(i) nan(1,1) r(i)-1:end]);
        targ_len = targ_len([1:r(i) nan(1,1) r(i)-1:end]);
        targ_num = targ_num([1:r(i) nan(1,1) r(i)-1:end]);
    end
end

cfg.trl(:,5) = trl_num;
cfg.trl(:,6) = targ_len;
cfg.trl(:,7) = targ_num;


%%% preprocess data

dat_preproc = ft_preprocessing(cfg);


%%% remove extra channels

if sub <= 9
    chans = {'all', '-IASX+', '-IASX-', '-IASY+', '-IASY-', '-IASZ+', '-IASZ-', '-IAS_DX', '-IAS_DY', '-IAS_X', '-IAS_Y', '-IAS_Z', '-SYS201'};
else
    chans = {'all', '-EXCI', '-IASX+', '-IASX-', '-IASY+', '-IASY-', '-IASZ+', '-IASZ-', '-IAS_DX', '-IAS_DY', '-IAS_X', '-IAS_Y', '-IAS_Z', '-SYS201'};
end

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


if length(cfg.trl) > 216
    fprintf('\n\n found %i trigger duplicates \n', numel(r))
end


%%% save data

dat = dat_select;
filename = sprintf('dat_prep_b%i.mat', block);
save([filedir filename], 'dat')

trl = cfg.trl;
filename = sprintf('trl_b%i.mat', block);
save([filedir filename], 'trl')

evt = cfg.event;
filename = sprintf('evt_b%i.mat', block);
save([filedir filename], 'evt')

