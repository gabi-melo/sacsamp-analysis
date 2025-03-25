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
conds_str = {'act' 'pas' 'fix'};
conds_num = [1 2 3];
blocks = [1 4 7 10; 2 5 8 11; 3 6 9 12];

for s = 1:numel(subs_meg)
    si = subs_meg(s);
    if si < 10
        sub_folder{si} = sprintf('%ssacsamp0%i_s0%i/', data_folder, si, si);
    else
        sub_folder{si} = sprintf('%ssacsamp%i_s%i/', data_folder, si, si);
    end
end

load('full_data.mat','data')
task_info = data;
clear data

subs_id = [10 9 13 4 17 21 11 1 22 25 26 19 18 20 28 34 23 27 49 42 45 36 48 16 29 38 30 51];

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
% 61:72 - cue onset

% blocks num
% act|pas|fix
%  1 | 2 | 3 
%  4 | 5 | 6 
%  7 | 8 | 9 
% 10 |11 |12 


%% perform artifact detection

%%% "flat" eye = 16 (pas), 22 (pas-act), 7 (act), 28 (act)
%%% many blinks = 7 (fix), 22 (fix), 26 (fix), 25 (act)
%%% noisy eye = 17 (fix)
%%% anticipated = 26 (act), 28 (act)

si = 28;
cs = 'act';

%%% load data
file_dat = sprintf('dat_prep_%s.mat', cs);
load([sub_folder{si} file_dat], 'dat')
dat_prep = dat;

if strcmp(cs,'pas')
    cue_n = task_info.cue_num(task_info.sub_num==subs_id(si) & task_info.cond_num==2);         
    cue_rep = find(cue_n>1);           % trials with cue repetitions

    targ_fix = task_info.targ_fix(task_info.sub_num==subs_id(si) & task_info.cond_num==2)';
    cue_on = task_info.cue_on(task_info.sub_num==subs_id(si) & task_info.cond_num==2)';
    targ_lat = targ_fix - cue_on;           % latency to detect target fixation after cue onset
    % histogram(targ_lat)
end

%%% check for pre-existing artifacts
bad_times = [];
file_bad = sprintf('bad_times_%s.mat', cs);
if exist([sub_folder{si} file_dat],'file')
    disp('loading pre-existing artifacts')
    load([sub_folder{si} file_bad],'bad_times')
end

%%% detect eye artifacts
cfg = [];
cfg.viewmode = 'vertical';
cfg.continuous = 'no';
cfg.allowoverlap = 'yes';
cfg.ploteventlabels = 'colorvalue';
cfg.position = [300 300 1920-150 1080-150];
cfg.channel  = {'EOGH','EOGV','EYEH','EYEV'};   

if strcmp(cs,'fix')
    cfg.verticalpadding = 2.0;
    cfg.chanscale = [500,500,0.3,0.3];    
else
    cfg.verticalpadding = 1.5;
    cfg.chanscale = [5000,5000,0.5,0.5];     
end

if ~isempty(bad_times)
    cfg.artfctdef.visual.artifact = bad_times;
end

cfg = ft_databrowser(cfg, dat_prep);
bad_times = cfg.artfctdef.visual.artifact;

%%% save artifacts
answer = questdlg('save artifacts?','','yes','no','yes');
switch answer
    case 'yes'
        file_bad = sprintf('bad_times_%s.mat', cs);
        save([sub_folder{si} file_bad],'bad_times')
        disp('saved !')
end


%% reject artifacts and apply frequency filters

subs = subs_meg;
for s = 1:numel(subs)
    si = subs(s);

    for c = 1:numel(conds_str)
        cs = conds_str{c};

        %%% load data
        file_bad = sprintf('bad_times_%s.mat', cs);
        load([sub_folder{si} file_bad],'bad_times')

        file_dat = sprintf('dat_prep_%s.mat', cs);
        load([sub_folder{si} file_dat], 'dat')
        dat_prep = dat;
        
        %%% reject artifacts
        cfg = [];
        cfg.artfctdef.visual.artifact = bad_times;
        cfg.artfctdef.reject = 'complete';           % remove entire trials
        dat_rej = ft_rejectartifact(cfg, dat_prep);

        %%% apply lowpass/highpass filters on meg channels
        cfg = [];
        cfg.channel = {'megplanar','megmag'};      % select magnetometers and planar gradiometers
        cfg.lpfilter = 'yes';                 
        cfg.lpfreq = 40;           % lowpass frequency
        cfg.hpfilter = 'yes';                 
        cfg.hpfreq = 0.5;          % highpass frequency
        dat_clean = ft_preprocessing(cfg, dat_rej);

        %%% save data
        dat = dat_clean;
        fprintf('\n\n    saving data - sub %i cond %s \n\n', si, cs)
        file_dat = sprintf('dat_clean_%s.mat', cs);
        save([sub_folder{si} file_dat],'dat')
        disp('saved !')
    
    end
end


%% apply baseline correction

subs = subs_meg;
for s = 1:numel(subs)
    si = subs(s);

    for c = 1:numel(conds_str)
        cs = conds_str{c};

        %%% load data
        file_dat = sprintf('dat_clean_%s.mat', cs);
        load([sub_folder{si} file_dat], 'dat')
        dat_clean = dat;
       
        %%% apply baseline correction
        cfg = [];
        cfg.demean = 'yes';     
        cfg.baselinewindow = [-0.1 0];
        dat_base = ft_preprocessing(cfg, dat_clean);

        %%% save data
        dat = dat_base;
        fprintf('\n\n    saving data - sub %i cond %s \n\n', si, cs)
        file_dat = sprintf('dat_base_%s.mat', cs);
        save([sub_folder{si} file_dat],'dat')
        disp('saved !')
    
    end
end
