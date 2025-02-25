clear all
clc

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

subs_meg = [1:28];
subs_meg([8 9 10 11 12 13]) = [];
conds = {'act','pas','fix'};
blocks = [1 4 7 10; 2 5 8 11; 3 6 9 12];

for s = 1:numel(subs_meg)
    sub = subs_meg(s);
    if sub < 10
        filedir{sub} = sprintf('%ssacsamp0%i_s0%i/', data_folder, sub, sub);
    else
        filedir{sub} = sprintf('%ssacsamp%i_s%i/', data_folder, sub, sub);
    end
end

load('full_data.mat','data')
task_info = data;
clear data

subs_num = [10 9 13 4 17 21 11 1 22 25 26 19 18 20 28 34 23 27 49 42 45 36 48 16 29 38 30 51];

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


%% artifact rejection


sub = 14;
cond = 'pas';

filename = sprintf('dat_prep_%s.mat', cond);
load([filedir{sub} filename], 'dat')
dat_prep = dat;

% check for pre-existing files
if exist([filedir{sub} sprintf('dat_clean_nan_%s.mat', cond)],'file')
    error('found a pre-existing file')
end

% find trials with cue repetitions
if strcmp(cond,'pas')
    cue_rep = task_info.cue_num(task_info.sub_num==subs_num(sub) & task_info.cond_num==2);
    find(cue_rep>1)

    targ_lat = task_info.targ_fix(task_info.sub_num==subs_num(sub) & task_info.cond_num==2) - task_info.cue_on(task_info.sub_num==subs_num(sub) & task_info.cond_num==2);
    % histogram(targ_lat)
end

%  cue_rep =  22   162   243   265   356   495   763   803


%%% detect eye artifacts

cfg = [];
cfg.viewmode = 'vertical';
cfg.continuous = 'no';
cfg.allowoverlap = 'yes';
cfg.ploteventlabels = 'colorvalue';

if at_usp
    cfg.position = [150 150 1920-300 1080-300];
else
    cfg.position = [300 300 1920-150 1080-150];
end

% cfg.channel = {'EYEH','EYEV'};    
% cfg.verticalpadding = 1;
% cfg.chanscale = [0.3,0.3];    

cfg.channel  = {'EOGH','EOGV','EYEH','EYEV'};   

if strcmp(cond,'fix')
    cfg.verticalpadding = 2.0;
    cfg.chanscale = [500,500,0.3,0.3];    
else
    cfg.verticalpadding = 1.5;
    cfg.chanscale = [5000,5000,0.5,0.5];     
end

cfg = ft_databrowser(cfg, dat_prep);
artifact_times = cfg.artfctdef.visual;


%%% reject artifacts
    
cfg = [];
cfg.artfctdef.visual = artifact_times;
cfg.artfctdef.reject = 'nan';                % fill rejected trials with nans
dat_clean_nan = ft_rejectartifact(cfg, dat_prep);

cfg = [];
cfg.artfctdef.visual = artifact_times;
cfg.artfctdef.reject = 'zero';               % fill rejected trials with zero
dat_clean_zero = ft_rejectartifact(cfg, dat_prep);

cfg = [];
cfg.artfctdef.visual = artifact_times;
cfg.artfctdef.reject = 'complete';           % remove entire trials
dat_clean_rmv = ft_rejectartifact(cfg, dat_prep);


answer = questdlg('save?','','yes','no','yes');
switch answer
    case 'yes'
        keep = true;
    case 'no'
        keep = false;
end


%%% save data

if keep    
    fprintf('\n\n  saving cleaned data - sub %i cond %s \n\n', sub, cond)

    dat = dat_clean_nan;
    filename = sprintf('dat_clean_nan_%s.mat', cond);
    save([filedir{sub} filename],'dat')

    dat = dat_clean_zero;
    filename = sprintf('dat_clean_zero_%s.mat', cond);
    save([filedir{sub} filename],'dat')

    dat = dat_clean_rmv;
    filename = sprintf('dat_clean_rmv_%s.mat', cond);
    save([filedir{sub} filename],'dat')

    disp('saved !')
end


%% frequency filters


subs = [4 18];

for s = 1:numel(subs)

    sub = subs(s);

    for c = 1:numel(conds)

        cond = conds{c};

        %%% load data
    
        filename = sprintf('dat_clean_rmv_%s.mat', cond);
        load([filedir{sub} filename], 'dat')
        dat_clean = dat;
        
        
        %%% apply lowpass/highpass filters on magnetometers
        
        cfg = [];
        % cfg.channel = {'megmag'};     % select only magnetometers
        cfg.channel = {'megmag', 'megplanar'};      % select magnetometers and planar gradiometers
    
        cfg.lpfilter = 'yes';                 
        cfg.lpfreq = 40;           % lowpass frequency
        cfg.hpfilter = 'yes';                 
        cfg.hpfreq = 0.75;         % highpass frequency
        
        dat_filt = ft_preprocessing(cfg, dat_clean);
        
        
        %%% save filtered data
        
        fprintf('\n\n    saving filtered data - sub %i cond %s \n\n', sub, cond)

        dat = dat_filt;
        filename = sprintf('dat_filt_%s.mat', cond);
        save([filedir{sub} filename],'dat')
    
    end
end