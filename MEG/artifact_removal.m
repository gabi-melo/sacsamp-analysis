clear all; clc;

main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
addpath(genpath(main_folder))
cd(main_folder)

addpath('/Users/gabimelo/Documents/MATLAB/Fieldtrip/')
ft_defaults


%% load data file

sub = 4;       % 4 | 18 | 22
cond = 'fix';

if sub < 10
    filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp0%i_s0%i/', sub, sub);
else
    filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);
end

filename = sprintf('dat_prep_%s.mat', cond);
filepath = [filedir filename];
load(filepath, 'dat')


%% %% visual artifact rejection


%% select meg channels

cfg = [];
cfg.channel = 'MEG*'; 

dat_meg = ft_preprocessing(cfg, dat);


%% detect artifacts using ft_rejectvisual
% look for infrequent and atypical artifacts before the ICA

cfg = [];
cfg.method = 'summary'; 
cfg.keepchannel = 'yes';
% cfg.keeptrial = 'yes';
cfg.layout = 'neuromag306all.lay';
cfg.channel = {'MEG*'};

% directly returns the cleaned data
dat_clean_vis = ft_rejectvisual(cfg, dat_meg); 


%% detect artifacts using ft_databrowser
% look for infrequent and atypical artifacts before the ICA

cfg = [];
cfg.viewmode = 'vertical';
% cfg.viewmode = 'butterfly';
cfg.continuous = 'no'; 
cfg.layout = 'neuromag306all.lay';
cfg.allowoverlap = 'yes';
cfg.preproc.demean = 'yes';

chans_meg = ft_channelselection('MEG*', dat.label);
cfg.channel = [chans_meg(1:40)];

% cfg.channelclamped = {'ECG', 'EOGH', 'EOGV'};

% cfg = ft_databrowser(cfg, dat);
cfg = ft_databrowser(cfg, dat_meg);

% keep the time of the artifacts
cfg_artfctdef = cfg.artfctdef;


%%

cfg = [];
cfg.artifactdef = cfg_artfctdef;
cfg.artfctdef.reject = 'nan';       % replace artifacts with NaNs (rather than excluding)
cfg.artfctdef.reject = 'partial';

% remove artifacts
dat_clean_vis = ft_rejectartifact(cfg, dat_meg);


%%

%% %%  artifact rejection using ICA


%% downsample the data to a lower sampling rate 
% (from 1000Hz to 200-300Hz)

cfg = [];
cfg.resamplefs = 200;      % new sampling rate
cfg.detrend = 'no';        % do not remove linear trend from the data

dat_resamp = ft_resampledata(cfg, dat_meg);
% dat_resamp = ft_resampledata(cfg, dat_clean_vis);


%% perform ICA

cfg = [];
n_comp = rank(squeeze(dat_resamp.trial{1}) * squeeze(dat_resamp.trial{1})');    % compute rank 
cfg.runica.pca = n_comp;
% cfg.runica.stop = 1e-7;

comp = ft_componentanalysis(cfg, dat_resamp);


%% inspect components using ft_topoplotIC

cfg = [];
cfg.component = 1:20;       
cfg.layout = 'neuromag306all.lay'; 
cfg.comment = 'no';

ft_topoplotIC(cfg, comp)


%% inspect components using ft_databrowser

cfg = [];
cfg.layout = 'neuromag306all.lay'; 
cfg.viewmode = 'component';

ft_databrowser(cfg, comp)


%% remove bad components
% backproject to the original (not downsampled) data

cfg = [];
cfg.component = [1:5];    % components to be removed

% dat_clean_ica = ft_rejectcomponent(cfg, comp, dat_meg)
dat_clean_ica = ft_rejectcomponent(cfg, comp, dat_clean_vis)


%% apply lowpass filter

cfg = [];
cfg.lpfilter = 'yes';                 
cfg.lpfreq = 35;          % lowpass at 35 Hz

dat_lpfilt = ft_preprocessing(cfg, dat_clean_ica);


%% save data

dat = dat_lpfilt;

filename = sprintf('data_clean_%s.mat', cond);
filepath = [filedir filename];
save(filepath,'dat')


%%


%% %% automatic artifact rejection


%% detect ECG artifacts

cfg = [];
% cfg.channel = {'ECG'};

dat_ecg = ft_preprocessing(cfg, dat);

cfg = [];
cfg.continuous = 'no';
cfg.artfctdef.ecg.inspect = {'ECG'};

[cfg, art_ecg] = ft_artifact_ecg(cfg, dat_ecg);

%   cfg.artfctdef.ecg.channel = Nx1 cell-array with selection of channels
%   cfg.artfctdef.ecg.pretim  = pre-artifact rejection interval in seconds (default = 0.05)
%   cfg.artfctdef.ecg.psttim  = post-artifact rejection interval in seconds (default = 0.3)
%   cfg.artfctdef.ecg.cutoff  = peak threshold (default = 3)
%   cfg.artfctdef.ecg.inspect = Nx1 list of channels which will be shown as a QRS-locked average


%% detect EOG artifacts

% preprocess data with optimal cfg parameters for identifying EOG artifacts
cfg = [];
cfg.artfctdef.eog.bpfilter = 'yes';
cfg.artfctdef.eog.bpfilttype = 'but';
cfg.artfctdef.eog.bpfreq = [1 15];
cfg.artfctdef.eog.bpfiltord = 4;
cfg.artfctdef.eog.hilbert = 'yes';

dat_eog = ft_preprocessing(cfg, dat);

cfg = [];
cfg.continuous = 'no';
cfg.artfctdef.eog.channel = {'EOGH', 'EOGV'};
% cfg.artfctdef.eog.trlpadding = 1;
% cfg.artfctdef.eog.fltpadding = 1;
% cfg.artfctdef.eog.artpadding = 1;

[cfg, art_eog] = ft_artifact_eog(cfg, dat_eog);

%   cfg.artfctdef.eog.channel      = Nx1 cell-array with selection of channels
%   cfg.artfctdef.eog.cutoff       = z-value at which to threshold (default = 4)
%   cfg.artfctdef.eog.trlpadding   = number in seconds (default = 0.5)
%   cfg.artfctdef.eog.fltpadding   = number in seconds (default = 0.1)
%   cfg.artfctdef.eog.artpadding   = number in seconds (default = 0.1)


%% detect muscle artifacts

% preprocess data with optimal cfg parameters for identifying muscle artifacts
cfg = [];
cfg.artfctdef.muscle.bpfilter = 'yes';
cfg.artfctdef.muscle.bpfreq = [110 140];
cfg.artfctdef.muscle.bpfiltord = 8;
cfg.artfctdef.muscle.bpfilttype = 'but';
cfg.artfctdef.muscle.hilbert = 'yes';
cfg.artfctdef.muscle.boxcar = 0.2;

dat_mus = ft_preprocessing(cfg, dat);

cfg = [];
cfg.continuous = 'no';
cfg.artfctdef.eog.channel = {'EMG1', 'EMG2'};

[cfg, art_mus] = ft_artifact_eog(cfg, dat_mus)

%   cfg.artfctdef.muscle.channel     = Nx1 cell-array with selection of channels
%   cfg.artfctdef.muscle.cutoff      = z-value at which to threshold (default = 4)
%   cfg.artfctdef.muscle.trlpadding  = number in seconds (default = 0.1)
%   cfg.artfctdef.muscle.fltpadding  = number in seconds (default = 0.1)
%   cfg.artfctdef.muscle.artpadding  = number in seconds (default = 0.1)


%% detect jumps artifacts

% preprocess data with optimal cfg parameters for identifying SQUID jump artifacts
cfg = [];
cfg.artfctdef.jump.medianfilter = 'yes';
cfg.artfctdef.jump.medianfiltord = 9;
cfg.artfctdef.jump.absdiff = 'yes';

dat_jump = ft_preprocessing(cfg, dat);

cfg = [];
cfg.continuous = 'no';
cfg.artfctdef.jump.channel = 'MEG*'; % dat_all.label(chans_meg);

[cfg, art_jump] = ft_artifact_jump(cfg, dat_jump);

%   cfg.artfctdef.jump.channel       = Nx1 cell-array with selection of channels
%   cfg.artfctdef.jump.cutoff        = z-value at which to threshold (default = 20)
%   cfg.artfctdef.jump.trlpadding    = number in seconds (default = 0.0)
%   cfg.artfctdef.jump.fltpadding    = number in seconds (default = 0.0)
%   cfg.artfctdef.jump.artpadding    = number in seconds (default = 0.0)


%% remove artifacts

cfg = [];
cfg.artfctdef.reject = 'partial';     % 'complete' = reject complete trials, 'partial' = partial rejection
cfg.artfctdef.ecg.artifact = art_ecg;
cfg.artfctdef.eog.artifact = art_eog;
cfg.artfctdef.jump.artifact = art_jump;
cfg.artfctdef.muscle.artifact = art_mus;

dat_all_clean = ft_rejectartifact(cfg, dat);


%%




