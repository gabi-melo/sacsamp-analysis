clear all
close all
clc

project_path = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';

addpath(genpath(project_path))
cd(project_path)

load([project_path 'full_data.mat'])

subs = unique(data.sub_num);
n_sub = length(subs);
n_cond = 3;
n_len = 3;
lens = [4 8 12];


%% CIRCULAR CORRELATION
%%% compute the circular correlation between sequence average and response

plotting = false;

stat = struct;
stat.sub_num = [];
stat.cond_num = [];
stat.targ_len = [];
stat.seq_ang = [];
stat.ang_mu = [];
stat.ang_avg = [];
stat.ang_coh = [];
stat.rho_ang = [];
stat.rho_c95_min = [];
stat.rho_c95_max = [];
stat.rho_mag_lo = [];
stat.rho_mag_hi = [];
stat.sig_err = [];

for sub_i = 1:n_sub

    for cond_i = 1:n_cond
        
        % get information from datafile
        avg_ang  = data.avg_ang(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.targ_num==1)';
        targ_len = data.targ_len(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.targ_num==1)';
        resp_ang = data.resp_ang(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.targ_num==1)';
        
        % get number of trials
        ntrls = numel(resp_ang);
        trls = unique(data.trl_num(data.sub_num==subs(sub_i) & data.cond_num==cond_i));
        
        % get sequence-specific information
        seq_ang = cell(ntrls,1);  % orientation samples (expressed in degrees)
        ang_mu  = nan(ntrls,1);   % generative mean (expressed in degrees)
        ang_avg = nan(ntrls,1);   % sequence average (expressed in degrees)
        ang_coh = nan(ntrls,1);   % sequence coherence (expressed as vector length)
        for itrl = 1:ntrls
            x = data.targ_ang(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.trl_num==trls(itrl));
            z = sum(exp(1i*x*2*pi/180));
            seq_ang{itrl} = x;
            ang_mu(itrl) = avg_ang(itrl);
            ang_avg(itrl) = mod(angle(z)/2/pi*180,180);
            ang_coh(itrl) = abs(z);
        end

        rho_ang     = nan(1,n_len);     % circular correlation btw sequence average and response
        rho_ang_c95 = nan(2,n_len);     % 95% confidence interval of circular correlation
        sig_err     = nan(1,n_len);     % s.d. of error btw sequence average and response (in degrees)
        for len_i = 1:n_len
            % filter trials of interest
            trls = find(targ_len == lens(len_i));
            % compute circular correlation btw sequence average and response
            [rho_ang(len_i),rho_ang_c95(:,len_i)] = circcorr(ang_avg(trls)*2*pi/180,resp_ang(trls)*2*pi/180);
            % compute s.d. of error btw sequence average and response
            sig_err(len_i) = std(mod(resp_ang(trls)-ang_avg(trls)+90,180)-90);
        
            if plotting
                if len_i == 1
                    figure('Color','white');
                end
                subplot(1,n_len,len_i);
                hold on
                xlim([0,180]);
                ylim([0,180]);
                plot(xlim,ylim,'-','Color',[0.8,0.8,0.8],'LineWidth',0.75);
                scatter(ang_avg(trls),resp_ang(trls),'o','MarkerEdgeColor','none','MarkerFaceColor','k','MarkerFaceAlpha',0.25);
                    text(30,150,sprintf('r = %.3f',rho_ang(len_i)));
                hold off
                set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
                set(gca,'XTick',0:30:180,'YTick',0:30:180);
                xlabel('Sequence average','FontSize',12);
                ylabel('Response','FontSize',12);
                if len_i == n_len
                    sgtitle('Correlation between sequence average and response','FontSize',14);
                    pause
                    close all
                end
            end
        end

        % compute effect of sequence coherence on circular correlation
        rho_ang_mag = nan(2,3);
        for len_i = 1:n_len
            trls = find(targ_len == lens(len_i));
            islo = ang_coh(trls) < median(ang_coh(trls)); % low sequence coherence?
            ishi = ~islo; % high sequence coherence?
            rho_ang_mag(1,len_i) = circcorr(ang_avg(trls(islo))*2*pi/180,resp_ang(trls(islo))*2*pi/180);
            rho_ang_mag(2,len_i) = circcorr(ang_avg(trls(ishi))*2*pi/180,resp_ang(trls(ishi))*2*pi/180);
        end
        
        if plotting
            figure('Color','white');
            hold on
            xlim([1,15]);
            ylim([0,1]);
            for len_i = 1:n_len
                plot(lens([len_i,len_i]),rho_ang_c95(:,len_i),'k-','LineWidth',0.75);
                plot(lens(len_i),rho_ang(len_i),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
                plot(lens(len_i)-0.5,rho_ang_mag(1,len_i),'wo','MarkerSize',9,'MarkerFaceColor',[1,0.5,0.5],'LineWidth',1.5);
                plot(lens(len_i)+0.5,rho_ang_mag(2,len_i),'wo','MarkerSize',9,'MarkerFaceColor',[0.5,1,0.5],'LineWidth',1.5);
            end
            hold off
            set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
            set(gca,'XTick',lens,'YTick',0:0.2:1);
            xlabel('Number of targets','FontSize',12);
            ylabel('Correlation coefficient','FontSize',12);
            pause
            close all
        end

        for len_i = 1:n_len
            trls = find(targ_len == lens(len_i));
            stat.sub_num(end+1) = subs(sub_i);
            stat.cond_num(end+1) = cond_i;
            stat.targ_len(end+1) = lens(len_i);
            stat.seq_ang{end+1} = seq_ang{len_i};   % orientation samples (expressed in degrees)
            stat.ang_mu{end+1}  = ang_mu(trls);     % generative mean (expressed in degrees)
            stat.ang_avg{end+1} = ang_avg(trls);    % sequence average (expressed in degrees)
            stat.ang_coh{end+1} = ang_coh(trls);    % sequence coherence (expressed as vector length)
            stat.rho_ang(end+1) = rho_ang(len_i);                   % circular correlation btw sequence average and response
            stat.rho_c95_min(end+1) = rho_ang_c95(1,len_i);         % 95% confidence interval of circular correlation
            stat.rho_c95_max(end+1) = rho_ang_c95(2,len_i);         
            stat.rho_mag_lo(end+1) = rho_ang_mag(1,len_i);
            stat.rho_mag_hi(end+1) = rho_ang_mag(2,len_i); 
            stat.sig_err(end+1) = sig_err(len_i);                   % s.d. of error btw sequence average and response (in degrees)
        end
    end
end

save([project_path 'full_data.mat'],'stat','-append')


%% CIRCULAR INFERENCE MODEL
%%% fit the circular inference model and simulate responses from it

tStart = tic;

plotting = false;

stat_bst.sub_num  = [];
stat_bst.cond_num = [];
stat_bst.targ_len = [];
stat_bst.rho_ang    = [];      
stat_bst.rho_mag_lo = [];
stat_bst.rho_mag_hi = [];
stat_bst.sig_err    = []; 

for sub_i = 1:n_sub

    for cond_i = 1:n_cond

        % clear command window
        % clc
        
        sub_i
        cond_i

        % get information from datafile
        avg_ang  = data.avg_ang(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.targ_num==1)';
        targ_len = data.targ_len(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.targ_num==1)';
        resp_ang = data.resp_ang(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.targ_num==1)';
        
        % get number of trials
        ntrls = numel(resp_ang);
        trls  = unique(data.trl_num(data.sub_num==subs(sub_i) & data.cond_num==cond_i));
        
        % get sequence-specific information
        seq_ang = cell(ntrls,1);     % orientation samples (expressed in degrees)
        ang_mu  = nan(ntrls,1);      % generative mean (expressed in degrees)
        ang_avg = nan(ntrls,1);      % sequence average (expressed in degrees)
        ang_coh = nan(ntrls,1);      % sequence coherence (expressed as vector length)

        for itrl = 1:ntrls
            x = data.targ_ang(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.trl_num==trls(itrl));
            z = sum(exp(1i*x*2*pi/180));
            seq_ang{itrl} = x;
            ang_mu(itrl)  = avg_ang(itrl);
            ang_avg(itrl) = mod(angle(z)/2/pi*180,180);
            ang_coh(itrl) = abs(z);
        end

        % create data structure for model fitting
        data_fit = [];
        data_fit.kappa  = 3;               % generative coherence
        data_fit.seqang = seq_ang;         % orientation samples (expressed in degrees)
        data_fit.resp   = resp_ang(:);     % orientation estimation report (expressed in degrees)
        
        % You should always either set sigsen to 0 or siginf to 0 because the two are
        % probably highly collinear - and therefore difficult to fit simultaneously.
        % You should try the model where both sigsen and siginf are set to 0, and
        % compare the results to the model where sigsen and sigrep are set to 0.
        % The winning model will I think be with either sigsen or siginf (but not both)
        % is set to 0.

        % free parameters:
        %  alpha  = inference imbalance (>0:recency, <0:primacy)
        %  sigsen = sensory noise (expressed in degrees modulo pi)
        %  siginf = inference noise (expressed in evidence units)
        %  sigrep = reporting noise (expressed in degrees modulo pi)
        %  plapse = reporting lapse rate

        runs = 5;           % number of random starting points
        
        % file_name = sprintf('model_sigrep_run%d.mat',runs);
        % out_fit = fit_model_circinf(data_fit,'nrun',runs,'verbose',1,'sigsen',0,'siginf',0);

        % file_name = sprintf('model_siginf_run%d.mat',runs);
        % out_fit = fit_model_circinf(data_fit,'nrun',runs,'verbose',1,'sigsen',0,'sigrep',0);

        % file_name = sprintf('model_sigsen_run%d.mat',runs);
        % out_fit = fit_model_circinf(data_fit,'nrun',runs,'verbose',1,'siginf',0,'sigrep',0);

        file_name = sprintf('model_all_run%d.mat',runs);
        out_fit = fit_model_circinf(data_fit,'nrun',runs,'verbose',1);

        % disp(out_fit);
        model_fit(sub_i,cond_i) = out_fit;

        % run particle filter and get simulations from best-fitting model
        out_bst = fit_model_circinf(data_fit,out_fit);
        
        toc(tStart)

        model_bst(sub_i,cond_i) = out_bst;
        
        rho_ang_sim     = nan(out_bst.nsmp,3);     % circular correlation btw sequence average and response
        rho_ang_mag_sim = nan(out_bst.nsmp,2,3); 
        sig_err_sim     = nan(out_bst.nsmp,3);     % s.d. of error btw sequence average and response (in degrees)

        for ismp = 1:out_bst.nsmp
            for len_i = 1:3
                % filter trials of interest
                trls = find(targ_len == lens(len_i));
                % compute circular correlation btw sequence average and response
                rho_ang_sim(ismp,len_i) = circcorr(ang_avg(trls)*2*pi/180,out_bst.rt(trls,ismp)*2*pi/180);
                % compute s.d. of error btw sequence average and response
                sig_err_sim(ismp,len_i) = std(mod(out_bst.rt(trls,ismp)-ang_avg(trls)+90,180)-90);
                % compute effect of sequence coherence
                islo = ang_coh(trls) < median(ang_coh(trls)); % low sequence coherence?
                ishi = ~islo; % high sequence coherence?
                rho_ang_mag_sim(ismp,1,len_i) = circcorr(ang_avg(trls(islo))*2*pi/180,out_bst.rt(trls(islo),ismp)*2*pi/180);
                rho_ang_mag_sim(ismp,2,len_i) = circcorr(ang_avg(trls(ishi))*2*pi/180,out_bst.rt(trls(ishi),ismp)*2*pi/180);
            end
        end

        for len_i = 1:3
            trls = find(targ_len == lens(len_i));

            stat_bst.sub_num(end+1) = subs(sub_i);
            stat_bst.cond_num(end+1) = cond_i;
            stat_bst.targ_len(end+1) = lens(len_i);

            stat_bst.rho_ang{end+1}    = rho_ang_sim(:,len_i);                  
            stat_bst.rho_mag_lo{end+1} = rho_ang_mag_sim(:,1,len_i);
            stat_bst.rho_mag_hi{end+1} = rho_ang_mag_sim(:,2,len_i); 
            stat_bst.sig_err{end+1}    = sig_err_sim(:,len_i); 
        end
        
        if plotting
            rho_ang = stat.rho_ang(stat.sub_num==subs(sub_i) & stat.cond_num==cond_i);  
            sig_err = stat.sig_err(stat.sub_num==subs(sub_i) & stat.cond_num==cond_i);  

            % plot circular correlation coefficient for each number of targets
            figure('Color','white');
            hold on
            xlim([1,15]);
            ylim([0,1]);
            for len_i = 1:3
                plot(lens([len_i,len_i]),quantile(rho_ang_sim(:,len_i),[0.025,0.975]),'k-','LineWidth',0.75);
                plot(lens(len_i),mean(rho_ang_sim(:,len_i)),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
                plot(lens(len_i)-0.5,mean(rho_ang_mag_sim(:,1,len_i)),'wo','MarkerSize',9,'MarkerFaceColor',[1,0.5,0.5],'LineWidth',1.5);
                plot(lens(len_i)+0.5,mean(rho_ang_mag_sim(:,2,len_i)),'wo','MarkerSize',9,'MarkerFaceColor',[0.5,1,0.5],'LineWidth',1.5);
            end
            hold off
            set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
            set(gca,'XTick',lens,'YTick',0:0.2:1);
            xlabel('number of items','FontSize',12);
            ylabel('correlation coefficient','FontSize',12);
            
            % compare circular correlation coefficient between subjects and model
            figure('Color','white');
            hold on
            xlim([1,15]);
            ylim([0,1]);
            bar(lens,mean(rho_ang_sim,1),0.5,'EdgeColor','b','FaceColor',[0.5,0.5,1],'LineWidth',1.5);
            for len_i = 1:3
                plot(lens([len_i,len_i]),quantile(rho_ang_sim(:,len_i),[0.025,0.975]),'b-','LineWidth',0.75);
                plot(lens(len_i),rho_ang(len_i),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
            end
            hold off
            set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
            set(gca,'XTick',lens,'YTick',0:0.2:1);
            xlabel('number of items','FontSize',12);
            ylabel('correlation coefficient','FontSize',12);
            
            % compare s.d. of error between subjects and model
            figure('Color','white');
            hold on
            xlim([1,15]);
            ylim([0,50]);
            bar(lens,mean(sig_err_sim,1),0.5,'EdgeColor','b','FaceColor',[0.5,0.5,1],'LineWidth',1.5);
            for len_i = 1:3
                plot(lens([len_i,len_i]),quantile(sig_err_sim(:,len_i),[0.025,0.975]),'b-','LineWidth',0.75);
                plot(lens(len_i),sig_err(len_i),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
            end
            hold off
            set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
            set(gca,'XTick',lens,'YTick',0:10:50);
            xlabel('number of items','FontSize',12);
            ylabel('s.d. of error (deg)','FontSize',12);
            
            pause
            close all
        end


        %%% RECOVERY ANALYSIS

        % nrep = 10;      % number of trial duplicates
        % 
        % % create data structure for model simulations
        % data_rec = [];
        % data_rec.kappa  = 3;           % generative coherence
        % data_rec.seqang = seq_ang;     % orientation samples (expressed in degrees)
        % data_rec.resp   = [];          % no responses included for simulations
        % 
        % if nrep > 1
        %     % duplicate trials to estimate asymptotic fitting performance
        %     fprintf('Using %d trial duplicates to estimate asymptotic fitting performance.\n',nrep);
        %     data_rec.seqang = repmat(data_rec.seqang,[nrep,1]);
        % end
        % 
        % % simulate model (all parameters need to be fixed)
        % out_sim = fit_model_circinf(data_rec,'alpha',0,'sigsen',0,'siginf',2,'sigrep',5,'plapse',0.05);
        % 
        % model_sim(sub_i,cond_i) = out_sim;
        % 
        % % add simulated responses in data structure
        % data_rec.resp = out_sim.rt(:,1);
        % 
        % % fit simulated responses
        % out_rec = fit_model_circinf(data_rec,'nrun',1,'verbose',2,'sigsen',0)
        % 
        % model_rec(sub_i,cond_i) = out_rec;

    end
end

save([project_path 'Model/' file_name],'model_fit','model_bst','stat_bst')

