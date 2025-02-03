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


% https://www.fieldtriptoolbox.org/tutorial/preproc/artifacts/
% https://www.fieldtriptoolbox.org/tutorial/preproc/automatic_artifact_rejection/
% https://www.fieldtriptoolbox.org/tutorial/preproc/ica_artifact_cleaning/
% https://www.fieldtriptoolbox.org/example/preproc/ica_ecg/
% https://www.fieldtriptoolbox.org/example/preproc/ica_eog/


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



%% %% manual artifact rejection


%% detect artifacts using ft_databrowser
% look for infrequent and atypical artifacts before the ICA

cfg = [];
cfg.continuous = 'no'; 
% cfg.continuous = 'yes';       % show all trials together
% cfg.blocksize = 60;             % show 60 seconds at the time
% cfg.plotevents = 'yes';
cfg.preproc.demean = 'yes';
cfg.layout = 'neuromag306all.lay';
cfg.allowoverlap = 'yes';
% cfg.channelclamped = {'ECG', 'EOGH', 'EOGV'};

cfg.channel = {'MEG*'};

chans_meg = 16:321;
cfg.channel = chans_meg(1:102);
% cfg.channel = chans_meg(103:204);
% cfg.channel = chans_meg(205:306);

cfg = ft_databrowser(cfg, dat_all);

% keep the time of the artifacts
cfg_artfctdef = cfg.artfctdef;


%% remove artifacts

cfg = [];
cfg.artifactdef = cfg_artfctdef;
cfg.artfctdef.reject = 'nan';       % replace artifacts with NaNs (rather than excluding)

data_clean = ft_rejectartifact(cfg, dat_all);


%% detect artifacts using ft_rejectvisual
% look for infrequent and atypical artifacts before the ICA

cfg = [];
cfg.method = 'summary'; 
cfg.keepchannel = 'yes';
cfg.keeptrial = 'nan';
cfg.layout = 'neuromag306all.lay';
cfg.channel = {'MEG*'};

% directly returns the cleaned data
data_clean = ft_rejectvisual(cfg, dat_all);


%%


%% %% automatic artifact rejection


%% detect ECG artifacts

cfg = [];
% cfg.channel = {'ECG'};

dat_ecg = ft_preprocessing(cfg, dat_all);

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

dat_eog = ft_preprocessing(cfg, dat_all);

cfg = [];
cfg.continuous = 'no';
cfg.artfctdef.eog.channel = {'EOGH', 'EOGV'};

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

dat_mus = ft_preprocessing(cfg, dat_all);

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

dat_jump = ft_preprocessing(cfg, dat_all);

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

dat_all_clean = ft_rejectartifact(cfg,dat_all);


%%


%% %%  artifact rejection using ICA


%% select meg channels

cfg = [];
cfg.channel = 'MEG*'; 

dat_meg = ft_preprocessing(cfg, dat_all);


%% downsample the data to a lower sampling rate 
% (from 1000Hz to 200-300Hz)

cfg = [];
cfg.resamplefs = 200;      % new sampling rate
cfg.detrend = 'no';        % do not remove linear trend from the data

% dat_resamp = ft_resampledata(cfg, dat_meg);
dat_resamp = ft_resampledata(cfg, dat_all);


%% perform ICA

cfg = [];
n_comp = rank(squeeze(dat_resamp.trial{1}) * squeeze(dat_resamp.trial{1})');    % find rank of the data
cfg.runica.pca = n_comp;
% cfg.runica.stop = 1e-7;

comp = ft_componentanalysis(cfg, dat_resamp);


%% inspect components using ft_topoplotIC

cfg = [];
cfg.component = 1:n_comp;       
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
cfg.component = [1 9];    % components to be removed

dat_meg_clean = ft_rejectcomponent(cfg, comp, dat_meg)

