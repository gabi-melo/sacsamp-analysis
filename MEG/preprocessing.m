clear all; clc;

main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
addpath(genpath(main_folder))
cd(main_folder)

load([main_folder 'full_data.mat'],'data','trls')
full_data = data;
full_trls = trls;
clear data trls

addpath('/Users/gabimelo/Documents/MATLAB/Fieldtrip/')
addpath('/Users/gabimelo/Documents/MATLAB/eeglab/')
ft_defaults


%% 

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

sub = 18;       % 04 | 18 | 22
cond = 'fix';
block = 6;

filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);

if block < 10
    filename = sprintf('run0%i_sss.fif', block);
else
    filename = sprintf('run%i_sss.fif', block);
end
filepath = [filedir filename];
                                    
hdr = ft_read_header(filepath);
raw = ft_read_data(filepath);
evt = ft_read_event(filepath);

% size(raw)
% recording of 327 channels for 279 seconds sampled at 1000 Hz (279000 samples)


%% select all blocks from a condition

sub = 18;       % 04 | 18 | 22
cond = 'fix';

if strcmp(cond, 'act')
    blocks = [1 4 7 10];
elseif strcmp(cond, 'pas')
    blocks = [2 5 8 11];
elseif strcmp(cond, 'fix')
    blocks = [3 6 9 12];
end

filedir = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);

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

% trl_on  = 22;       % fix point onset
% trl_off = 30;       % response onset

cfg = [];
cfg.dataset = filepath;

cfg.trialfun = 'ft_trialfun_general';
cfg.trialdef.eventtype = 'STI101';
cfg.trialdef.eventvalue = [81:92];      % target onset

cfg.trialdef.prestim = 0.25;
cfg.trialdef.poststim = 0.5;

cfg = ft_definetrial(cfg);

% insert end sample in cfg.trl 
% evt = ft_read_event(filepath);
% smp = vertcat(evt.sample);
% val = vertcat(evt.value);
% cfg.trl(:,2) = smp(val==trl_off);
% 
% dat_all = ft_redefinetrial(cfg, dat_all);


%% preprocess data

cfg.bsfilter = 'yes';                      % band-stop filter to remove line noise
cfg.bsfreq = [49 51; 99 100; 149 151];     % line frequency (50Hz) and its harmonics

dat_all = ft_preprocessing(cfg);

% Besides these “conventional” filters, during preprocessing you can also apply a very sharp discrete Fourier transform filter (cfg.dftfilter). 
% To make this dft filter very sharp, you have to pad the data to a large amount (cfg.padding), e.g., to 5 or 10 seconds. 
% The DFT filter is effective in removing the 50 Hz line noise (and the harmonics at 100 and 150 Hz). 
% After DFT filtering and multitaper frequency analysis, you will not notice any line noise in the power spectra any more.


%% rename channels

dat_all.label(1) = {'EOGH'};
dat_all.label(2) = {'EOGV'};
dat_all.label(3) = {'ECG'};
dat_all.label(322) = {'EMG1'};
dat_all.label(323) = {'EMG2'};
dat_all.label(324) = {'EYEH'};
dat_all.label(325) = {'EYEV'};
dat_all.label(326) = {'PUPIL'};


%% save data
filename = sprintf('data_prep_%s.mat', cond);
filepath = [filedir filename];
save(filepath,'dat_all')


%% add trigger labels to evt

% trigger labels
% act|pas|fix
% 12 |13 |14 - block onset
% 16 |17 |18 - block offset
% 20 |21 |22 - fixation point onset
% 24 |25 |26 - fixation point offset
% 28 |29 |30 - response onset
% 32 |33 |34 - response offset

% 41:52 - screen onset
% 81:92 - target onset

for i = 1:length(evt)

    if evt(i).value == 20 | evt(i).value == 21 | evt(i).value == 22
        evt(i).label = "FP";
    elseif evt(i).value == 24 | evt(i).value == 25 | evt(i).value == 26
        evt(i).label = "";

    elseif evt(i).value == 28 | evt(i).value == 29 | evt(i).value == 30
        evt(i).label = "REON";
    elseif evt(i).value == 32 | evt(i).value == 33 | evt(i).value == 34
        evt(i).label = "REOFF";

    elseif evt(i).value == 12
        evt(i).label = "BLACT";
    elseif evt(i).value == 13
        evt(i).label = "BLPAS";
    elseif evt(i).value == 14
        evt(i).label = "BLFIX";

    elseif evt(i).value == 16 | evt(i).value == 17 | evt(i).value == 18
        evt(i).label = "BLOFF";

    elseif evt(i).value == 41
        evt(i).label = "A01";
    elseif evt(i).value == 42
        evt(i).label = "A02";
    elseif evt(i).value == 43
        evt(i).label = "A03";
    elseif evt(i).value == 44
        evt(i).label = "A04";
    elseif evt(i).value == 45
        evt(i).label = "A05";
    elseif evt(i).value == 46
        evt(i).label = "A06";
    elseif evt(i).value == 47
        evt(i).label = "A07";
    elseif evt(i).value == 48
        evt(i).label = "A08";
    elseif evt(i).value == 49
        evt(i).label = "A09";
    elseif evt(i).value == 50
        evt(i).label = "A10";
    elseif evt(i).value == 51
        evt(i).label = "A11";
    elseif evt(i).value == 52
        evt(i).label = "A12";

    elseif evt(i).value == 81
        evt(i).label = "T01";
    elseif evt(i).value == 82
        evt(i).label = "T02";
    elseif evt(i).value == 83
        evt(i).label = "T03";
    elseif evt(i).value == 84
        evt(i).label = "T04";
    elseif evt(i).value == 85
        evt(i).label = "T05";
    elseif evt(i).value == 86
        evt(i).label = "T06";
    elseif evt(i).value == 87
        evt(i).label = "T07";   
    elseif evt(i).value == 88
        evt(i).label = "T08";
    elseif evt(i).value == 89
        evt(i).label = "T09";
    elseif evt(i).value == 90
        evt(i).label = "T10";
    elseif evt(i).value == 91
        evt(i).label = "T11";
    elseif evt(i).value == 92
        evt(i).label = "T12";
    end

end


%% save evt

filename = sprintf('evt_prep_%s.mat', cond);
filepath = [filedir filename];
save(filepath,'evt')


%% plot channels

trl = 10;

trl_evt = ft_filter_event(evt, 'minsample', dat_all.sampleinfo(trl,1), 'maxsample', dat_all.sampleinfo(trl,2));
evt_smp = vertcat(trl_evt.sample);
start_smp = dat_all.sampleinfo(trl,1);
evt_sec = (evt_smp - start_smp)/1000;
evt_value = vertcat(trl_evt.value);
evt_label = string(vertcat(trl_evt.label));

evt_sec_arr = evt_sec(startsWith(evt_label,'A'));
evt_label_arr = evt_label(startsWith(evt_label,'A'));

evt_sec_targ = evt_sec(startsWith(evt_label,'T'));
evt_label_targ = evt_label(startsWith(evt_label,'T'));

tmin = 0;
tmax = max(dat_all.time{trl});

figure()
subplot(3,3,1)
chansel = find(strcmp(dat_all.label,'ECG'));
plot(dat_all.time{trl}, dat_all.trial{trl}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
xlim([tmin,tmax])
title('ECG')
xline(evt_sec_arr,'r:',evt_label_arr,'LineWidth',2)
xline(evt_sec_targ,'k:',evt_label_targ,'LineWidth',2)
box off
set(gca,'TickDir','out')

subplot(3,3,2)
chansel = find(strcmp(dat_all.label,'EMG1'));
plot(dat_all.time{trl}, dat_all.trial{trl}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
xlim([tmin,tmax])
title('EMG1')
xline(evt_sec_arr,'r:',evt_label_arr,'LineWidth',2)
xline(evt_sec_targ,'k:',evt_label_targ,'LineWidth',2)
box off
set(gca,'TickDir','out')

subplot(3,3,3)
chansel = find(strcmp(dat_all.label,'EMG2'));
plot(dat_all.time{trl}, dat_all.trial{trl}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
xlim([tmin,tmax])
title('EMG2')
xline(evt_sec_arr,'r:',evt_label_arr,'LineWidth',2)
xline(evt_sec_targ,'k:',evt_label_targ,'LineWidth',2)
box off
set(gca,'TickDir','out')

subplot(3,3,4)
chansel = find(strcmp(dat_all.label,'EOGH'));
plot(dat_all.time{trl}, dat_all.trial{trl}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
xlim([tmin,tmax])
title('EOGH')
xline(evt_sec_arr,'r:',evt_label_arr,'LineWidth',2)
xline(evt_sec_targ,'k:',evt_label_targ,'LineWidth',2)
box off
set(gca,'TickDir','out')

subplot(3,3,5)
chansel = find(strcmp(dat_all.label,'EOGV'));
plot(dat_all.time{trl}, dat_all.trial{trl}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
xlim([tmin,tmax])
title('EOGV')
xline(evt_sec_arr,'r:',evt_label_arr,'LineWidth',2)
xline(evt_sec_targ,'k:',evt_label_targ,'LineWidth',2)
box off
set(gca,'TickDir','out')

subplot(3,3,7)
chansel = find(strcmp(dat_all.label,'EYEH'));
plot(dat_all.time{trl}, dat_all.trial{trl}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
xlim([tmin,tmax])
title('EYEH')
xline(evt_sec_arr,'r:',evt_label_arr,'LineWidth',2)
xline(evt_sec_targ,'k:',evt_label_targ,'LineWidth',2)
box off
set(gca,'TickDir','out')

subplot(3,3,8)
chansel = find(strcmp(dat_all.label,'EYEV'));
plot(dat_all.time{trl}, dat_all.trial{trl}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
xlim([tmin,tmax])
title('EYEV')
xline(evt_sec_arr,'r:',evt_label_arr,'LineWidth',2)
xline(evt_sec_targ,'k:',evt_label_targ,'LineWidth',2)
box off
set(gca,'TickDir','out')

subplot(3,3,6)
chansel = find(strcmp(dat_all.label,'PUPIL'));
plot(dat_all.time{trl}, dat_all.trial{trl}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
xlim([tmin,tmax])
title('PUPIL')
xline(evt_sec_arr,'r:',evt_label_arr,'LineWidth',2)
xline(evt_sec_targ,'k:',evt_label_targ,'LineWidth',2)
box off
set(gca,'TickDir','out')


%%

chansel = find(strcmp(dat_all.label,'EXCI'));
plot(dat.time{trl}, dat_all.trial{trl}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
legend(dat_all.label(chansel))
title('')


%%


%% rename channels 
% 
% %%% EOG channels
% label_old_eog = {'BIO001', 'BIO002'};       
% label_new_eog = {'EOGH', 'EOGV'};        
% type_old_eog  = {'eeg', 'eeg'};
% type_new_eog  = {'eog', 'eog'};
% chan_num_eog  = [1 2];  
% 
% %%% EMG channels
% label_old_emg = {'BIO003'};                 
% label_new_emg = {'EMG'};                    
% type_old_emg  = {'eeg'};
% type_new_emg  = {'emg'};
% chan_num_emg  = [3]; 
% 
% %%% ECG channels
% label_old_ecg = {'MISC001', 'MISC002'};      
% label_new_ecg = {'ECG1', 'ECG2'};          
% type_old_ecg  = {'eeg', 'eeg'};
% type_new_ecg  = {'ecg', 'ecg'};
% chan_num_ecg  = [322 323];  % [321 322]
% 
% %%% eye-tracking channels
% label_old_et = {'MISC007', 'MISC008', 'MISC009'};    
% label_new_et = {'EYE1', 'EYE2', 'PUPIL'};          
% type_old_et  = {'misc', 'misc', 'misc'};
% type_new_et  = {'misc', 'misc', 'misc'};
% chan_num_et  = [324 325 326];  % [323 324 325] 
% 
% 
% %%% MEG channels
% chan_num_meg  = 16:321;
% label_old_meg = hdr.label(chan_num_meg)';          
% label_new_meg = hdr.label(chan_num_meg)';         
% type_old      = cell(1,numel(chan_num_meg));
% type_old(:)   = {'eeg'};
% type_old_meg  = type_old;
% type_new      = cell(1,numel(chan_num_meg));
% type_new(:)   = {'meg'};
% type_new_meg  = type_new;
% 
% montage = [];
% montage.labelold    = [label_old_eog label_old_emg label_old_ecg label_old_meg label_old_et];                      
% montage.labelnew    = [label_new_eog label_new_emg label_new_ecg label_new_meg label_new_et];                     
% montage.chantypeold = [type_old_eog type_old_emg type_old_ecg type_old_meg type_old_et];
% montage.chantypenew = [type_new_eog type_new_emg type_new_ecg type_new_meg type_new_et];
% montage.tra         = eye(length(montage.labelold));    
% 
% cfg = [];
% cfg.dataset = filepath;
% cfg.montage = montage;
% dat_all = ft_preprocessing(cfg);

