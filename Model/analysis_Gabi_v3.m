
%% Test circular correlation coefficient metric

% clear command window
clc

% show help for circcorr function
help circcorr

% set analysis parameters
ndat  = 1e2; % number of data points
nrep  = 1e4; % number of repetitions
sigma = 1;   % angular standard deviation between x1 and x2 (in radians)
delta = 0;   % angular offset between x1 and x2 (in radians)

% simulate circular variables x1 and x2 and compute circular coerrelation coefficient
rho = nan(nrep,1);
for irep = 1:nrep
    % simulate circular variables
    x1 = rand(ndat,1)*2*pi;
    x2 = mod(x1+randn(ndat,1)*sigma+delta,2*pi);
    % compute circular correlation coefficient
    rho(irep) = circcorr(x1,x2);
end

% plot results
if ~exist('hf','var')
    hf = figure('Color','white');
else
    figure(hf);
    hold on
end
histogram(rho,'NumBins',30,'Normalization','pdf','EdgeColor','none');

%% Load data

% clear workspace, figures and command window
clear all
close all
clc

addpath('./CircStat/');

% load datafile
load ./data_active_sub1_1006-1034.mat

% get information from datafile
avg_ori   = info.avg_ori(:);
item_ori  = info.item_ori;
ntargs    = info.ntargs(:);
targ_item = info.targ_item;
resp      = data.resp(:);

% get number of trials
ntrl = numel(resp);

% get sequence-specific information
seqang  = cell(ntrl,1); % orientation samples (expressed in degrees)
ang_mu  = nan(ntrl,1);  % generative mean (expressed in degrees)
ang_avg = nan(ntrl,1);  % sequence average (expressed in degrees)
ang_coh = nan(ntrl,1);  % sequence coherence (expressed as vector length)
for itrl = 1:ntrl
    x = item_ori(itrl,targ_item(itrl,1:ntargs(itrl)));
    z = sum(exp(1i*x*2*pi/180));
    seqang{itrl} = x;
    ang_mu(itrl) = avg_ori(itrl);
    ang_avg(itrl) = mod(angle(z)/2/pi*180,180);
    ang_coh(itrl) = abs(z);
end

%% Plot correlation between sequence average and response

% clear command window
clc

% get list of number of targets
ntargs_lst = unique(ntargs);

rho_ang     = nan(1,3); % circular correlation btw sequence average and response
rho_ang_c95 = nan(2,3); % 95% confidence interval of circular correlation
sig_err     = nan(1,3); % s.d. of error btw sequence average and response (in degrees)
figure('Color','white');
for i = 1:3
    % filter trials of interest
    itrl = find(ntargs == ntargs_lst(i));
    % compute circular correlation btw sequence average and response
    [rho_ang(i),rho_ang_c95(:,i)] = circcorr(ang_avg(itrl)*2*pi/180,resp(itrl)*2*pi/180);
    % compute s.d. of error btw sequence average and response
    sig_err(i) = std(mod(resp(itrl)-ang_avg(itrl)+90,180)-90);
    subplot(1,3,i);
    hold on
    xlim([0,180]);
    ylim([0,180]);
    plot(xlim,ylim,'-','Color',[0.8,0.8,0.8],'LineWidth',0.75);
    scatter(ang_avg(itrl),resp(itrl),'o','MarkerEdgeColor','none','MarkerFaceColor','k','MarkerFaceAlpha',0.25);
        text(30,150,sprintf('r = %.3f',rho_ang(i)));
    hold off
    set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
    set(gca,'XTick',0:30:180,'YTick',0:30:180);
    xlabel('sequence average','FontSize',12);
    ylabel('response','FontSize',12);
end
sgtitle('Correlation between sequence average and response','FontSize',14);

% compute effect of sequence coherence on circular correlation
rho_ang_mag = nan(2,3);
for i = 1:3
    itrl = find(ntargs == ntargs_lst(i));
    islo = ang_coh(itrl) < median(ang_coh(itrl)); % low sequence coherence?
    ishi = ~islo; % high sequence coherence?
    rho_ang_mag(1,i) = circcorr(ang_avg(itrl(islo))*2*pi/180,resp(itrl(islo))*2*pi/180);
    rho_ang_mag(2,i) = circcorr(ang_avg(itrl(ishi))*2*pi/180,resp(itrl(ishi))*2*pi/180);
end

% plot circular correlation coefficient for each number of targets
figure('Color','white');
hold on
xlim([1,15]);
ylim([0,1]);
for i = 1:3
    plot(ntargs_lst([i,i]),rho_ang_c95(:,i),'k-','LineWidth',0.75);
    plot(ntargs_lst(i),rho_ang(i),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
    plot(ntargs_lst(i)-0.5,rho_ang_mag(1,i),'wo','MarkerSize',9,'MarkerFaceColor',[1,0.5,0.5],'LineWidth',1.5);
    plot(ntargs_lst(i)+0.5,rho_ang_mag(2,i),'wo','MarkerSize',9,'MarkerFaceColor',[0.5,1,0.5],'LineWidth',1.5);
end
hold off
set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
set(gca,'XTick',ntargs_lst,'YTick',0:0.2:1);
xlabel('number of items','FontSize',12);
ylabel('correlation coefficient','FontSize',12);

%% Fit circular inference model and simulate responses from it

% clear command window
clc

% create data structure for model fitting
dat = [];
dat.kappa  = 2;       % generative coherence
dat.seqang = seqang;  % orientation samples (expressed in degrees)
dat.resp   = resp(:); % orientation estimation report (expressed in degrees)

% fit circular inference model
% You should always either set sigsen to 0 or siginf to 0 because the two are
% probably highly collinear - and therefore difficult to fit simultaneously.
% You should try the model where both sigsen and siginf are set to 0, and
% compare the results to the model where sigsen and sigrep are set to 0.
% The winning model will I think be with either sigsen or siginf (but not both)
% is set to 0.
out_fit = fit_model_circinf(dat,'nrun',1,'verbose',2,'sigsen',0);
disp(out_fit);

% run particle filter and get simulations from best-fitting model
out_bst = fit_model_circinf(dat,out_fit);

rho_ang_sim     = nan(out_bst.nsmp,3);   % circular correlation btw sequence average and response
rho_ang_mag_sim = nan(out_bst.nsmp,2,3); % 95% confidence interval of circular correlation
sig_err_sim     = nan(out_bst.nsmp,3);   % s.d. of error btw sequence average and response (in degrees)
for ismp = 1:out_bst.nsmp
    for i = 1:3
        % filter trials of interest
        itrl = find(ntargs == ntargs_lst(i));
        % compute circular correlation btw sequence average and response
        rho_ang_sim(ismp,i) = circcorr(ang_avg(itrl)*2*pi/180,out_bst.rt(itrl,ismp)*2*pi/180);
        % compute s.d. of error btw sequence average and response
        sig_err_sim(ismp,i) = std(mod(out_bst.rt(itrl,ismp)-ang_avg(itrl)+90,180)-90);
        % compute effect of sequence coherence
        islo = ang_coh(itrl) < median(ang_coh(itrl)); % low sequence coherence?
        ishi = ~islo; % high sequence coherence?
        rho_ang_mag_sim(ismp,1,i) = circcorr(ang_avg(itrl(islo))*2*pi/180,out_bst.rt(itrl(islo),ismp)*2*pi/180);
        rho_ang_mag_sim(ismp,2,i) = circcorr(ang_avg(itrl(ishi))*2*pi/180,out_bst.rt(itrl(ishi),ismp)*2*pi/180);
    end
end

% plot circular correlation coefficient for each number of targets
figure('Color','white');
hold on
xlim([1,15]);
ylim([0,1]);
for i = 1:3
    plot(ntargs_lst([i,i]),quantile(rho_ang_sim(:,i),[0.025,0.975]),'k-','LineWidth',0.75);
    plot(ntargs_lst(i),mean(rho_ang_sim(:,i)),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
    plot(ntargs_lst(i)-0.5,mean(rho_ang_mag_sim(:,1,i)),'wo','MarkerSize',9,'MarkerFaceColor',[1,0.5,0.5],'LineWidth',1.5);
    plot(ntargs_lst(i)+0.5,mean(rho_ang_mag_sim(:,2,i)),'wo','MarkerSize',9,'MarkerFaceColor',[0.5,1,0.5],'LineWidth',1.5);
end
hold off
set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
set(gca,'XTick',ntargs_lst,'YTick',0:0.2:1);
xlabel('number of items','FontSize',12);
ylabel('correlation coefficient','FontSize',12);

% compare circular correlation coefficient between subjects and model
figure('Color','white');
hold on
xlim([1,15]);
ylim([0,1]);
bar(ntargs_lst,mean(rho_ang_sim,1),0.5,'EdgeColor','b','FaceColor',[0.5,0.5,1],'LineWidth',1.5);
for i = 1:3
    plot(ntargs_lst([i,i]),quantile(rho_ang_sim(:,i),[0.025,0.975]),'b-','LineWidth',0.75);
    plot(ntargs_lst(i),rho_ang(i),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
end
hold off
set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
set(gca,'XTick',ntargs_lst,'YTick',0:0.2:1);
xlabel('number of items','FontSize',12);
ylabel('correlation coefficient','FontSize',12);

% compare s.d. of error between subjects and model
figure('Color','white');
hold on
xlim([1,15]);
ylim([0,50]);
bar(ntargs_lst,mean(sig_err_sim,1),0.5,'EdgeColor','b','FaceColor',[0.5,0.5,1],'LineWidth',1);
for i = 1:3
    plot(ntargs_lst([i,i]),quantile(sig_err_sim(:,i),[0.025,0.975]),'b-','LineWidth',0.75);
    plot(ntargs_lst(i),sig_err(i),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1);
end
hold off
set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
set(gca,'XTick',ntargs_lst,'YTick',0:10:50);
xlabel('number of items','FontSize',12);
ylabel('s.d. of error (deg)','FontSize',12);


%% Run recovery analysis

% clear command window
clc

nrep = 10; % number of trial duplicates

% create data structure for model simulations
dat = [];
dat.kappa  = 2;      % generative coherence
dat.seqang = seqang; % orientation samples (expressed in degrees)
dat.resp   = [];     % no responses included for simulations

if nrep > 1
    % duplicate trials to estimate asymptotic fitting performance
    fprintf('Using %d trial duplicates to estimate asymptotic fitting performance.\n',nrep);
    dat.seqang = repmat(dat.seqang,[nrep,1]);
end

% simulate model (all parameters need to be fixed)
out_sim = fit_model_circinf(dat,'alpha',0,'sigsen',0,'siginf',2,'sigrep',5,'plapse',0.05);

% add simulated responses in data structure
dat.resp = out_sim.rt(:,1);

% fit simulated responses
out_rec = fit_model_circinf(dat,'nrun',1,'verbose',2,'sigsen',0)
