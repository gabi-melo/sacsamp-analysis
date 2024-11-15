clear all
close all
clc

project_path = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';

addpath(genpath(project_path))
cd(project_path)

load([project_path 'full_data.mat'])
load([project_path 'Model/Outputs/model_eval.mat'])
load([project_path 'Model/Outputs/output_fit_siginf.mat'])

subs = unique(data.sub_num);
n_sub = length(subs);
n_cond = 3;
n_len = 3;
lens = [4 8 12];

set(0,'defaultAxesFontSize',14)  


%% ERROR DISTRIBUTION

cond_name = {'ACT','PAS','FIX'};
plot_idx = [1 2 3; 4 5 6; 7 8 9];
colors = [[0.8500 0.3250 0.0980]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]];

for sub_i = 1:n_sub
    for cond_i = 1:n_cond
        for len_i = 1:n_len
            len = lens(len_i);
            subplot(3,3,plot_idx(cond_i,len_i))

            resp_ori = data.resp_ang(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
            avg_ori = data.avg_ang(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
            err_ori = deg2range(resp_ori-avg_ori);
            nbins = round((max(err_ori)+abs(min(err_ori)))/8);

            h = histfit(err_ori,nbins,'normal');
            h(1).FaceColor = colors(len_i,:);
            h(1).FaceAlpha = 0.6;
            h(1).EdgeColor = [1 1 1];
            h(2).Color = [0 0 0];
            h(2).LineWidth = 3;
    
            set(gca,'XLim',[-100 100])
            % set(gca,'YLim',[0 12])
            set(gca,'YLim',[0 12])
            set(gca,'XTick',[-90 -45 0 45 90])
            title(sprintf('%d Targets',len),'FontSize',14)
            xlabel('Error \Delta\theta (Resp-Avg)')
            ylabel('Num Trials')
    
            pd = fitdist(err_ori','Normal');
            text(-90,11,sprintf('sig = %0.1f',pd.sigma),'FontSize',14)
            text(-90,10,sprintf('mu = %0.1f',pd.mu),'FontSize',14)
    
            axis square
            box off
            set(gca,'TickDir','out')
            title(sprintf('%s - %d Items',string(cond_name(cond_i)),len),'FontSize',14);
        end
    end
    set(gcf,'Position',[50 50 800 800])
    
    pause 
    close
end

%% 

cond_name = {'ACT','PAS','FIX'};
plot_idx = [1 2 3; 4 5 6; 7 8 9];
% colors = [[0.8500 0.3250 0.0980]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]];
colors = [[0.8500 0.3250 0.0980]; [0.4940 0.1840 0.5560]; [0.3660 0.5740 0.0880]];

for cond_i = 1:n_cond
    for len_i = 1:n_len
        len = lens(len_i);
        subplot(3,3,plot_idx(cond_i,len_i))
        
        resp_ori = data.resp_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        avg_ori = data.avg_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        err_ori = deg2range(resp_ori-avg_ori);
        nbins = round((max(err_ori)+abs(min(err_ori)))/8)

        % err_ori_ = [err_ori -90:1:90];
        % nbins = 20;

        h = histfit(err_ori,nbins,'normal');
        h(1).FaceColor = colors(len_i,:);
        h(1).FaceAlpha = 0.6;
        h(1).EdgeColor = [1 1 1];
        h(2).Color = [0 0 0];
        h(2).LineWidth = 3;

        set(gca,'XLim',[-100 100])
        set(gca,'YLim',[0 250])
        set(gca,'XTick',[-90 -45 0 45 90])

        title(sprintf('%d Items',len),'FontSize',14)
        xlabel('Error (Resp-Avg)')
        ylabel('Num Trials')

        pd = fitdist(err_ori','Normal');
        text(-90,230,sprintf('sig = %0.1f',pd.sigma),'FontSize',14)
        text(-90,210,sprintf('mu = %0.1f',pd.mu),'FontSize',14)

        axis square
        box off
        set(gca,'TickDir','out')
        title(sprintf('%s - %d Items',string(cond_name(cond_i)),len),'FontSize',14);
    end
end
set(gcf,'Position',[50 50 800 800])

%% 


colors = [[0.8500 0.3250 0.0980]; [0.4940 0.1840 0.5560]; [0.3160 0.5240 0.0380]];

for cond_i = 1:n_cond
    subplot(1,3,cond_i)
    for len_i = 1:n_len
        len = lens(len_i);
        
        resp_ori = data.resp_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        avg_ori = data.avg_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        err_ori = deg2range(resp_ori-avg_ori);
        nbins = round((max(err_ori)+abs(min(err_ori)))/8);

        % err_ori_ = [err_ori -90:1:90];
        % nbins = 20;

        h = histfit(err_ori,nbins,'normal');
        h(1).FaceColor = 'none'; 
        h(1).EdgeColor = 'none'; 
        h(2).Color = colors(len_i,:);
        h(2).LineWidth = 3;

        pd = fitdist(err_ori','Normal');
        text(-90,220-(40*len_i),sprintf('sig = %0.1f',pd.sigma),'FontSize',11,'Color',colors(len_i,:))
        text(-90,205-(40*len_i),sprintf('mu = %0.1f',pd.mu),'FontSize',11,'Color',colors(len_i,:))
        
        hold on
    end

    axis square
    box off
    set(gca,'TickDir','out')
    set(gca,'XLim',[-100 100])
    set(gca,'YLim',[0 200])
    set(gca,'XTick',[-90 -45 0 45 90])
    xlabel('Error (Resp-Avg)')
    ylabel('Num Trials')
    if cond_i == 1
        title('ACTIVE')
    elseif cond_i == 2
        title('PASSIVE')
    else
        title('FIXATION')
    end
end
set(gcf,'Position',[50 50 800 800])


%% CORRELATION BETWEEN TRUE AVERAGE AND RESPONSE

cond_i = 1

figure('Color','white');
for len_i = 1:n_len
    subplot(1,3,len_i);
    xlim([0,180]);
    ylim([0,180]);
 
    for sub_i = 1:28
        hold on
        ang_avg = stat.ang_avg{stat.sub_num==subs(sub_i) & stat.cond_num==cond_i & stat.targ_len==lens(len_i)};
        resp_ang = data.resp_ang(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.targ_len==lens(len_i) & data.targ_num==1)';
        scatter(ang_avg,resp_ang,'o','MarkerEdgeColor','none','MarkerFaceColor',[0.4 0.4 0.8],'MarkerFaceAlpha',0.3);
    end
    plot(xlim,ylim,'-','Color','k','LineWidth',2);
    text(30,150,sprintf('r = %.2f',mean(stat.rho_ang(stat.cond_num==cond_i & stat.targ_len==lens(len_i)))));

    hold off
    set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
    set(gca,'XTick',0:30:180,'YTick',0:30:180);
    xlabel('Sequence average','FontSize',12);
    ylabel('Response','FontSize',12);
    if len_i == 1
        title('4 ITEMS')
    elseif len_i == 2
        title('8 ITEMS')
    else
        title('12 ITEMS')
    end
end
if cond_i == 1
    sgtitle('ACTIVE')
elseif cond_i == 2
    sgtitle('PASSIVE')
else
    sgtitle('FIXATION')
end


%% SEQUENCE COHERENCE 

figure('Color','white');
for cond_i = 1:3
    subplot(1,3,cond_i)
    xlim([1,15]);
    ylim([0.5,1]);
    hold on

    for len_i = 1:3
        plot(lens([len_i,len_i]),[mean(stat.rho_c95_min(stat.targ_len==lens(len_i) & stat.cond_num==cond_i));mean(stat.rho_c95_max(stat.targ_len==lens(len_i) & stat.cond_num==cond_i))],'k-','LineWidth',0.75);
        plot(lens(len_i),mean(stat.rho_ang(stat.targ_len==lens(len_i) & stat.cond_num==cond_i)),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
        plot(lens(len_i)-0.5,mean(stat.rho_mag_lo(stat.targ_len==lens(len_i) & stat.cond_num==cond_i)),'wo','MarkerSize',9,'MarkerFaceColor',[0.9,0.5,0.5],'LineWidth',1.5);
        plot(lens(len_i)+0.5,mean(stat.rho_mag_hi(stat.targ_len==lens(len_i) & stat.cond_num==cond_i)),'wo','MarkerSize',9,'MarkerFaceColor',[0.5,0.9,0.5],'LineWidth',1.5);
    end

    hold off
    set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
    set(gca,'XTick',lens,'YTick',0.5:0.1:1);
    xlabel('Number of items','FontSize',12);
    ylabel('Correlation coefficient','FontSize',12);
    
    if cond_i == 1
        title('ACTIVE')
    elseif cond_i == 2
        title('PASSIVE')
    else
        title('FIXATION')
    end
end


%% SEQUENCE COHERENCE ON MODEL SIMULATIONS

sub_i = 1;

figure('Color','white');
for cond_i = 1:n_cond
    subplot(1,3,cond_i)
    hold on
    xlim([1,15]);
    ylim([0.5,1]);

    for len_i = 1:3
        plot(lens([len_i,len_i]),quantile(stat_bst.rho_ang{stat_bst.sub_num==sub_i & stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i)},[0.025,0.975]),'k-','LineWidth',0.75);
        plot(lens(len_i),mean(stat_bst.rho_ang{stat_bst.sub_num==sub_i & stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i)}),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
        plot(lens(len_i)-0.5,mean(stat_bst.rho_mag_lo{stat_bst.sub_num==sub_i & stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i)}),'wo','MarkerSize',9,'MarkerFaceColor',[0.9,0.5,0.5],'LineWidth',1.5);
        plot(lens(len_i)+0.5,mean(stat_bst.rho_mag_hi{stat_bst.sub_num==sub_i & stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i)}),'wo','MarkerSize',9,'MarkerFaceColor',[0.5,0.9,0.5],'LineWidth',1.5);
    end

    hold off
    set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
    set(gca,'XTick',lens,'YTick',0.5:0.1:1);
    xlabel('Number of items','FontSize',12);
    ylabel('Correlation coefficient','FontSize',12);
    if cond_i == 1
        title('ACTIVE')
    elseif cond_i == 2
        title('PASSIVE')
    else
        title('FIXATION')
    end
end

%%

figure('Color','white');
for cond_i = 1:n_cond
    subplot(1,3,cond_i)
    hold on
    xlim([1,15]);
    ylim([0.5,1]);

    for len_i = 1:3
        plot(lens([len_i,len_i]),mean(quantile(cell2mat(stat_bst.rho_ang(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))),[0.025,0.975]),2),'k-','LineWidth',0.75);
        plot(lens(len_i),mean(mean(cell2mat(stat_bst.rho_ang(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))))),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
        plot(lens(len_i)-0.5,mean(mean(cell2mat(stat_bst.rho_mag_lo(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))))),'wo','MarkerSize',9,'MarkerFaceColor',[0.9,0.5,0.5],'LineWidth',1.5);
        plot(lens(len_i)+0.5,mean(mean(cell2mat(stat_bst.rho_mag_hi(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))))),'wo','MarkerSize',9,'MarkerFaceColor',[0.5,0.9,0.5],'LineWidth',1.5);
    end

    hold off
    set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
    set(gca,'XTick',lens,'YTick',0.5:0.1:1);
    xlabel('Number of items','FontSize',12);
    ylabel('Correlation coefficient','FontSize',12);
    if cond_i == 1
        title('ACTIVE')
    elseif cond_i == 2
        title('PASSIVE')
    else
        title('FIXATION')
    end
end


%% CIRCULAR CORRELATION BETWEEN SUBJECTS AND MODEL

sub_i = 1;

figure('Color','white');
for cond_i = 1:n_cond
    subplot(1,3,cond_i)
    hold on
    xlim([1,15]);
    ylim([0.5,1]);
    
    for len_i = 1:3
        bar(lens(len_i),mean(stat_bst.rho_ang{stat_bst.sub_num==sub_i & stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i)}),2,'EdgeColor','b','FaceColor',[0.5,0.5,1],'LineWidth',1);
        plot(lens([len_i,len_i]),quantile(stat_bst.rho_ang{stat_bst.sub_num==sub_i & stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i)},[0.025,0.975]),'b-','LineWidth',0.75);
        plot(lens(len_i),stat.rho_ang(stat_bst.sub_num==sub_i & stat.cond_num==cond_i & stat.targ_len==lens(len_i)),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
    end
    
    hold off
    set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
    set(gca,'XTick',lens,'YTick',0.5:0.1:1);
    xlabel('Number of items','FontSize',12);
    ylabel('Correlation coefficient','FontSize',12);
    if cond_i == 1
        title('ACTIVE')
    elseif cond_i == 2
        title('PASSIVE')
    else
        title('FIXATION')
    end
end

%%

figure('Color','white');
for cond_i = 1:n_cond
    subplot(1,3,cond_i)
    hold on
    xlim([1,15]);
    ylim([0.5,1]);

    for len_i = 1:3
        bar(lens(len_i),mean(mean(cell2mat(stat_bst.rho_ang(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))))),2,'EdgeColor','b','FaceColor',[0.5,0.5,1],'LineWidth',1);
        plot(lens([len_i,len_i]),mean(quantile(cell2mat(stat_bst.rho_ang(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))),[0.025,0.975]),2),'b-','LineWidth',0.75);
        plot(lens(len_i),mean(stat.rho_ang(stat.cond_num==cond_i & stat.targ_len==lens(len_i))),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
    end

    hold off
    set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
    set(gca,'XTick',lens,'YTick',0.5:0.1:1);
    xlabel('Number of items','FontSize',12);
    ylabel('Correlation coefficient','FontSize',12);
    if cond_i == 1
        title('ACTIVE')
    elseif cond_i == 2
        title('PASSIVE')
    else
        title('FIXATION')
    end
end


%% ERROR SD BETWEEN SUBJECTS AND MODEL

sub_i = 1;

figure('Color','white');
for cond_i = 1:n_cond
    subplot(1,3,cond_i)
    hold on
    xlim([1,15]);
    ylim([0,40]);
    
    for len_i = 1:3
        bar(lens(len_i),mean(stat_bst.sig_err{stat_bst.sub_num==sub_i & stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i)}),2,'EdgeColor','b','FaceColor',[0.5,0.5,1],'LineWidth',1);
        plot(lens([len_i,len_i]),quantile(stat_bst.sig_err{stat_bst.sub_num==sub_i & stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i)},[0.025,0.975]),'b-','LineWidth',0.75);
        plot(lens(len_i),stat.sig_err(stat_bst.sub_num==sub_i & stat.cond_num==cond_i & stat.targ_len==lens(len_i)),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
    end

    hold off
    set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
    set(gca,'XTick',lens,'YTick',0:10:50);
    xlabel('Number of items','FontSize',12);
    ylabel('S.d. of error (deg)','FontSize',12);
    if cond_i == 1
        title('ACTIVE')
    elseif cond_i == 2
        title('PASSIVE')
    else
        title('FIXATION')
    end
end

%%

figure('Color','white');
for cond_i = 1:n_cond
    subplot(1,3,cond_i)
    hold on
    xlim([1,15]);
    ylim([0,35]);
    
    for len_i = 1:3
        % bar(lens(len_i),mean(mean(cell2mat(stat_bst.sig_err(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))))),2,'EdgeColor','b','FaceColor',[0.5,0.5,1],'LineWidth',1);
        % plot(lens([len_i,len_i]),mean(quantile(cell2mat(stat_bst.sig_err(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))),[0.025,0.975]),2),'b-','LineWidth',0.75);
        % plot(lens(len_i),mean(stat.sig_err(stat.cond_num==cond_i & stat.targ_len==lens(len_i))),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
        bar(lens(len_i),mean(mean(cell2mat(stat_bst.sig_err(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))))),2,'EdgeColor','k','FaceColor',[0.5,0.5,1],'LineWidth',1);
        plot(lens([len_i,len_i]),mean(quantile(cell2mat(stat_bst.sig_err(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))),[0.025,0.975]),2),'k-','LineWidth',1);
        plot(lens(len_i),mean(stat.sig_err(stat.cond_num==cond_i & stat.targ_len==lens(len_i))),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
    end

    hold off
    set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
    set(gca,'XTick',lens,'YTick',0:5:35);
    xlabel('Number of items','FontSize',12);
    ylabel('S.d. of error (deg)','FontSize',12);
    if cond_i == 1
        title('ACTIVE')
    elseif cond_i == 2
        title('PASSIVE')
    else
        title('FIXATION')
    end
end


%% AIC

labels = {'All', 'sigRep', 'sigSen', 'sigInf'};

figure('Color','white');
for cond_i = 1:n_cond

    subplot(1,3,cond_i)

    aic(:,1) = (model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 1 & model_eval.sigrep == 1 & model_eval.cond == cond_i))
    % aic(:,2) = (model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 0 & model_eval.sigrep == 1 & model_eval.cond == cond_i))
    % aic(:,3) = (model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 1 & model_eval.sigrep == 1 & model_eval.cond == cond_i))
    aic(:,2) = (model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 0 & model_eval.sigrep == 1 & model_eval.cond == cond_i))
    aic(:,3) = (model_eval.aic(model_eval.sigsen == 1 & model_eval.siginf == 0 & model_eval.sigrep == 0 & model_eval.cond == cond_i))
    aic(:,4) = (model_eval.aic(model_eval.sigsen == 0 & model_eval.siginf == 1 & model_eval.sigrep == 0 & model_eval.cond == cond_i))

    % aic = rescale(aic);
    % aic = rescale(aic)/28;

    bar(1:4,sum(aic))
    % ylim([0.4 0.45])
    % set(gca,'YTick',0.4:0.01:0.45);

    ylim([4000 6500])

    % ylim([11 12.5])
    % set(gca,'YTick',11:0.5:12.5);

    ylabel('AIC')
    xlabel('Free parameters')
    xticklabels(labels)

    hold on
    std_err = std(aic)/sqrt(length(aic))
    er = errorbar([1:4],sum(aic),-std_err,+std_err);    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  

    % boxplot(aic) %,'PlotStyle','compact')

    axis square
    box off
    set(gca,'TickDir','out')

    if cond_i == 1
        title('ACTIVE')
    elseif cond_i == 2
        title('PASSIVE')
    else
        title('FIXATION')
    end

end




%%


function err = deg2range(err)  
    
    err(err>90) = err(err>90) - 180;
    err(err<-90) = err(err<-90) + 180;
    
end
