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
cond_str = {'act' 'pas' 'fix'};
cond_num = [1 2 3];
blocks = [1 4 7 10; 2 5 8 11; 3 6 9 12];

for s = 1:numel(subs_meg)
    sub = subs_meg(s);
    if sub < 10
        filedir{sub} = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp0%i_s0%i/', sub, sub);
    else
        filedir{sub} = sprintf('/Volumes/PortableSSD/SACSAMP/sacsamp%i_s%i/', sub, sub);
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


%% data preprocessing


subs = [2];

cond_str = {'fix'};
cond_num = [3];

save_raw = true;


for s = 1:numel(subs)

    sub = subs(s);

    for c = 1:numel(cond_str)

        ci = cond_num(c);
        cs = cond_str{c};

        fprintf('\n\npreprocessing sub %i cond %s \n\n', sub, cs)

        if save_raw 

            %%% concatenate blocks
    
            filename1 = sprintf('run0%i_sss.fif', blocks(ci,1));
            dat1 = ft_read_data([filedir{sub} filename1]);
            evt1 = ft_read_event([filedir{sub} filename1]);
    
            filename2 = sprintf('run0%i_sss.fif', blocks(ci,2));
            dat2 = ft_read_data([filedir{sub} filename2]);
            evt2 = ft_read_event([filedir{sub} filename2]);
    
            filename3 = sprintf('run0%i_sss.fif', blocks(ci,3));
            dat3 = ft_read_data([filedir{sub} filename3]);
            evt3 = ft_read_event([filedir{sub} filename3]);
    
            filename4 = sprintf('run%i_sss.fif', blocks(ci,4));
            dat4 = ft_read_data([filedir{sub} filename4]);
            evt4 = ft_read_event([filedir{sub} filename4]);
    
            hdr = ft_read_header([filedir{sub} filename4]);
    
            dat = cat(2, dat1, dat2, dat3, dat4);      % concatenate the data along the 2nd dimension
    
            % shift the sample of the events or triggers
            for i = 1:length(evt2)
                nsamples1 = size(dat1,2);
                evt2(i).sample = evt2(i).sample + nsamples1;
            end
    
            for i = 1:length(evt3)
                nsamples2 = nsamples1 + size(dat2,2);
                evt3(i).sample = evt3(i).sample + nsamples2;
            end
    
            for i = 1:length(evt4)
                nsamples3 = nsamples2 + size(dat3,2);
                evt4(i).sample = evt4(i).sample + nsamples3;
            end
    
            evt = cat(1, evt1, evt2, evt3, evt4);       % concatenate the events along the 2nd dimension
    
    
            %%% save raw data
    
            fprintf('\n\n  saving concatenated raw data - sub %i cond %s \n\n', sub, cs)
            filename = sprintf('raw_cat_%s.vhdr', cs);
            ft_write_data([filedir{sub} filename], dat, 'header', hdr, 'event', evt);
            disp(' saved !')

        end

        filename = sprintf('raw_cat_%s.vhdr', cs);

        %%% define trials based on triggers
        
        cfg = [];
        cfg.dataset = [filedir{sub} filename];
        cfg.trialdef.eventtype = 'STI101';
        cfg.trialdef.eventvalue = 81:92;      % target onset
        cfg.trialdef.prestim = 0.2;
        cfg.trialdef.poststim = 0.3;
        
        cfg = ft_definetrial(cfg);
       

        %%% detect trigger duplicates

        r = []; d = [];
        
        r = find(diff(cfg.trl(:,4))==0)';    % find immediate repetitions
        d = find(diff(cfg.trl(:,4))>1)';     % find late repetitions
    
        if numel(r) > 0
            r = r+1;
        end
    
        % check if the duplicates were correctly identified
        for i = 1:numel(r)
            fprintf('\n\n  found a trigger repetition at trial %i (shown at line 3): \n\n', r(i))
            disp(cfg.trl([r(i)-2:r(i)+2],:))
        end

        for i = 1:numel(d)
            fprintf('\n\n  found a trigger repetition at trial %i (shown at line 3): \n\n', d(i))
            disp(cfg.trl([d(i)-2:d(i)+2],:))
        end
    
        % if numel(r) > 0 || numel(d) > 0
        %     answer = questdlg('Continue?','','Yes!','Abort','Yes!');
        %     switch answer
        %         case 'Abort'
        %             error('something went wrong : aborted preprocessing ! ')
        %     end
        % end

        if sub == 6 & strcmp(cs,'pas')
            r = [r 41 42 43];
        elseif sub == 7 & strcmp(cs,'pas')
            r = [r 573 574 575];
        elseif sub == 7 & strcmp(cs,'fix')
            r = [r 97 98 99 264 265 754 755];
        elseif sub == 17 & strcmp(cs,'pas')
            r = [r 1 2 3 4];
        elseif sub == 28 & strcmp(cs,'fix')
            r = [r 1 2];
        end

        %%% remove duplicates

        trls_to_keep = 1:length(cfg.trl);
        trls_to_keep([r d]) = [];
        cfg.trials = trls_to_keep;
        
        cfg.trl([r d],:) = [];


        %%% add stimulus info to cfg.trl
        
        cfg.trl(:,5) = task_info.trl_num(task_info.sub_num==subs_num(sub) & task_info.cond_num==ci);
        cfg.trl(:,6) = task_info.targ_len(task_info.sub_num==subs_num(sub) & task_info.cond_num==ci);
        cfg.trl(:,7) = task_info.targ_num(task_info.sub_num==subs_num(sub) & task_info.cond_num==ci);
        cfg.trl(:,8) = task_info.blc_num(task_info.sub_num==subs_num(sub) & task_info.cond_num==ci);
        cfg.trl(:,9) = task_info.ref_num(task_info.sub_num==subs_num(sub) & task_info.cond_num==ci);

        % cfg.trl(:,5) = task_info.trl_num(task_info.sub_num==subs_num(sub) & task_info.cond_num==ci & (task_info.ref_num < 82 | task_info.ref_num > 87));
        % cfg.trl(:,6) = task_info.targ_len(task_info.sub_num==subs_num(sub) & task_info.cond_num==ci & (task_info.ref_num < 82 | task_info.ref_num > 87));
        % cfg.trl(:,7) = task_info.targ_num(task_info.sub_num==subs_num(sub) & task_info.cond_num==ci & (task_info.ref_num < 82 | task_info.ref_num > 87));
        % cfg.trl(:,8) = task_info.blc_num(task_info.sub_num==subs_num(sub) & task_info.cond_num==ci & (task_info.ref_num < 82 | task_info.ref_num > 87));
        % cfg.trl(:,9) = task_info.ref_num(task_info.sub_num==subs_num(sub) & task_info.cond_num==ci & (task_info.ref_num < 82 | task_info.ref_num > 87));
        

        %%% check number of trials

        targ1 = (cfg.trl(:,4) == 81);             % first target
        ntrls = sum(cfg.trl(targ1,7) == 1);
        if ntrls ~= max(task_info.ref_num)
            error('something went wrong : incorrect number of trials !')
        end


        %%% preprocess data

        dat_prep = ft_preprocessing(cfg);
        
        
        %%% rename channels
        
        dat_prep.label(1) = {'EOGH'};
        dat_prep.label(2) = {'EOGV'};
        % dat_select.label(3) = {''};
        % dat_select.label(end-6) = {''};
        % dat_select.label(end-5) = {''};
        dat_prep.label(end-4) = {'EYEH'};
        dat_prep.label(end-3) = {'EYEV'};
        dat_prep.label(end-2) = {'PUPIL'};
               
            
        %%% save preprocessed data
        
        fprintf('\n\n  saving preprocessed data - sub %i cond %s \n\n', sub, cs)
        
        dat = dat_prep;
        filename = sprintf('dat_prep_%s.mat', cs);
        save([filedir{sub} filename], 'dat')
        
        trl = cfg.trl;
        filename = sprintf('trl_prep_%s.mat', cs);
        save([filedir{sub} filename], 'trl')
        
        evt = cfg.event;
        filename = sprintf('evt_prep_%s.mat', cs);
        save([filedir{sub} filename], 'evt')

        disp(' saved !')

    end
end


%%



%%

%%% plot orientation of planar gradiometers

filename = '/Volumes/PortableSSD/SACSAMP/sacsamp22_s22/run01_sss.fif';

grad = ft_read_sens(filename, 'senstype', 'meg');

sel = find(strcmp(grad.chantype, 'megplanar'));

for i=1:numel(sel)
j = sel(i);
clear coilindex*
coilindex1 = find(grad.tra(j,:)>0)
coilindex2 = find(grad.tra(j,:)<0)
pos(i,:) = (grad.coilpos(coilindex2,:) + grad.coilpos(coilindex1,:))/2;
ori(i,:) = grad.coilpos(coilindex2,:) - grad.coilpos(coilindex1,:);
ori(i,:) = ori(i,:)/norm(ori(i,:));

end

figure
quiver3(pos(:,1), pos(:,2), pos(:,3), ori(:,1), ori(:,2), ori(:,3))
axis equal
axis vis3d


%%

%%% visualize the head position indicator coils

filename = '/Volumes/PortableSSD/SACSAMP/sacsamp22_s22/run01_sss.fif';

% visualize the known/fixed positions of the sensors
hdr = ft_read_header(filename, 'coordsys', 'dewar');
ft_plot_sens(hdr.grad);

% visualize the digitized positions of the head position indicator coils
shape = ft_read_headshape(filename, 'coordsys', 'dewar');
for ci = 1:size(shape.pos,1)
  if ~isempty(strfind(shape.label{ci},'hpi'))
      hold on;
      plot3(shape.pos(ci,1),shape.pos(ci,2),shape.pos(ci,3), 'ro', 'MarkerSize', 12, 'LineWidth', 3);
      hold on;
      text(shape.pos(ci,1),shape.pos(ci,2),shape.pos(ci,3), sscanf(shape.label{ci},'hpi_%s'));
  end
end

