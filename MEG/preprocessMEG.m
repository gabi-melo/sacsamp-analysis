addpath '/Users/gabimelo/Documents/MATLAB/Fieldtrip'
addpath '/Users/gabimelo/Documents/GitHub/sacsamp'

%%

evt = [];

evt.label = repelem({
                     'ARRAY_ON_01'; 'ARRAY_ON_02'; 'ARRAY_ON_03'; 'ARRAY_ON_04'; 'ARRAY_ON_05'; 'ARRAY_ON_06'; ... 
                     'ARRAY_ON_07'; 'ARRAY_ON_08'; 'ARRAY_ON_09'; 'ARRAY_ON_10'; 'ARRAY_ON_11'; 'ARRAY_ON_12'; ...
                     'CUE_ON_01';   'CUE_ON_02';   'CUE_ON_03';   'CUE_ON_04';   'CUE_ON_05'; 'CUE_ON_06'; ...
                     'CUE_ON_06';   'CUE_ON_08';   'CUE_ON_09';   'CUE_ON_10';   'CUE_ON_11'; 'CUE_ON_12'; ...
                     'TARG_ON_01';  'TARG_ON_02';  'TARG_ON_03';  'TARG_ON_04';  'TARG_ON_05'; 'TARG_ON_06'; ...
                     'TARG_ON_07';  'TARG_ON_08';  'TARG_ON_09';  'TARG_ON_10';  'TARG_ON_11'; 'TARG_ON_12'; ...
                     'BLOCK_ON'; ...
                     'BLOCK_OFF';...
                     'POINT_ON'; ...
                     'POINT_OFF';...
                     'RESP_ON'; ...
                     'RESP_OFF';...
                     'PAUSE_ON'; ...
                     'PAUSE_OFF'},1,3);

evt.value = nan(size(evt.label));

evt.value(1:12,1:3) = repmat(41:52,3,1)';      % 'ARRAY_ON'
evt.value(13:24,1:3) = repmat(61:72,3,1)';     % 'CUE_ON'
evt.value(25:36,1:3) = repmat(81:92,3,1)';     % 'TARG_ON'

evt.value(37,1:3) = 12:14;      % 'BLOCK_ON'
evt.value(38,1:3) = 16:18;      % 'BLOCK_OFF'
evt.value(39,1:3) = 20:22;      % 'POINT_ON'
evt.value(40,1:3) = 24:26;      % 'POINT_OFF'     
evt.value(41,1:3) = 28:30;      % 'RESP_ON'
evt.value(42,1:3) = 32:34;      % 'RESP_OFF'

evt.value(43,1:3) = repmat(96,3,1)';         % 'PAUSE_ON'   
evt.value(44,1:3) = repmat(98,3,1)';         % 'PAUSE_OFF'   

evt.cond(1:44,1) = repelem({'ACT'},44,1);
evt.cond(1:44,2) = repelem({'PAS'},44,1);
evt.cond(1:44,3) = repelem({'FIX'},44,1);


%%
%fiff_file   = 'eporun09_s01_raw.fif';
fiff_file   = 'sssrun09_s01_raw.fif';

hdr = ft_read_header(fiff_file)

%%

cfg = [];
cfg.dataset = fiff_file;

cond = 3;
trig_on = evt.value(39,cond);         % POINT_ON
trig_off = evt.value(42,cond);        % RESP_OFF

% cfg.trialdef.eventtype = '?';
% dummy = ft_definetrial(cfg);

cfg.trialdef.eventtype = 'STI101';
cfg.trialdef.eventvalue = [trig_on trig_off];

cfg = ft_definetrial(cfg);

cfg.channel = [15:320];

predata = ft_preprocessing(cfg);

%%

cfg = [];
cfg.dataset = fiff_file;

cfg.channel = [1:3];

data_bio = ft_preprocessing(cfg);

%%

cfg = [];
cfg.dataset = fiff_file;

cfg.channel = [1:3];

data_bio = ft_preprocessing(cfg);

%%

cfg = [];
cfg.dataset = fiff_file;

cfg.channel = [1:3];

data_bio = ft_preprocessing(cfg);

%%

data_all = ft_appenddata(cfg, data_eeg, data_eogh, data_eogv);


%%

cfg = [];
cfg.dataset = fiff_file;

cfg.trialdef.eventtype = 'STI101';
cfg.trialdef.eventvalue = [trig_on trig_off];

cfg.trl(:,1) = predata.sampleinfo(predata.trialinfo==trig_on,1);
cfg.trl(:,2) = predata.sampleinfo(predata.trialinfo==trig_off,1);
cfg.trl(:,3) = predata.sampleinfo(predata.trialinfo==trig_off,1)-predata.sampleinfo(predata.trialinfo==trig_on,1);
cfg.trl(:,4) = repelem(trig_on,length(cfg.trl(:,1)),1);

prepredata = ft_redefinetrial(cfg, predata)


%%

events = cfg.event.sample;

cfg.event.sample(cfg.event.value==22)-cfg.event.sample(cfg.event.value==30)



%%



%%


%%
[events, mappings] = fiff_read_events(fiff_file); 

% data_mp.trialinfo = eventlist(:,3); % note that the events have been recoded w.r.t. the original trigger values


