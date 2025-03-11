clear all
clc

at_usp = false;

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


%% rename channels

dat_all.label(1) = {'EOGH'};
dat_all.label(2) = {'EOGV'};
dat_all.label(3) = {'ECG'};
dat_all.label(322) = {'EMG1'};
dat_all.label(323) = {'EMG2'};
dat_all.label(324) = {'EYEH'};
dat_all.label(325) = {'EYEV'};
dat_all.label(326) = {'PUPIL'};


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