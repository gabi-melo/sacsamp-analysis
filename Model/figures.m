clear all
clc

at_usp = true;

if at_usp
    main_folder = '/Users/Gabi/Documents/GitHub/sacsamp-analysis/';
else
    main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
end

addpath(genpath(main_folder))
cd(main_folder)

load([main_folder 'full_data.mat'],'data')
load([main_folder 'Model/stat_dat.mat'],'stat_dat')
load([main_folder 'Model/stat_fit_siginf.mat'],'stat_bst')

subs = unique(data.sub_num);
n_sub = length(subs);
n_cond = 3;
n_len = 3;
lens = [4 8 12];
cond_name = {'ACT','PAS','FIX'};

set(0,'defaultAxesFontSize',14)  


%% RESPONSE ERROR
%%% single subject

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
    
    sub_i

    pause 
    close
end


%% RESPONSE ERROR
%%% all subjects

plot_idx = [1 2 3; 4 5 6; 7 8 9];
colors = [[0.8500 0.3250 0.0980]; [0.4940 0.1840 0.5560]; [0.3660 0.5740 0.0880]];

for cond_i = 1:n_cond
    for len_i = 1:n_len
        len = lens(len_i);
        subplot(3,3,plot_idx(cond_i,len_i))
        
        resp_ori = data.resp_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        avg_ori = data.avg_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        err_ori = deg2range(resp_ori-avg_ori);
        nbins = round((max(err_ori)+abs(min(err_ori)))/8);

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


%% RESPONSE ERROR (FITS) 

colors = [[0.8500 0.3250 0.0980]; [0.4940 0.1840 0.5560]; [0.3160 0.5240 0.0380]];

for cond_i = 1:n_cond
    subplot(1,3,cond_i)
    for len_i = 1:n_len
        len = lens(len_i);
        
        resp_ori = data.resp_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        avg_ori = data.avg_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        err_ori = deg2range(resp_ori-avg_ori);
        nbins = round((max(err_ori)+abs(min(err_ori)))/8);

        h = histfit(err_ori,nbins,'normal');
        h(1).FaceColor = 'none'; 
        h(1).EdgeColor = 'none'; 
        h(2).Color = colors(len_i,:);
        h(2).LineWidth = 3;

        legend('','4','','8','','12')

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


%% RESPONSE ERROR (FITS) 

colors = [[0.8500 0.3250 0.0980]; [0.4940 0.1840 0.5560]; [0.3160 0.5240 0.0380]];

for len_i = 1:n_len 
    
    len = lens(len_i);

    subplot(1,3,len_i)

    for cond_i = 1:n_cond
        
        resp_ori = data.resp_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        avg_ori = data.avg_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        err_ori = deg2range(resp_ori-avg_ori);
        nbins = round((max(err_ori)+abs(min(err_ori)))/8);

        h = histfit(err_ori,nbins,'normal');
        h(1).FaceColor = 'none'; 
        h(1).EdgeColor = 'none'; 
        h(2).Color = colors(cond_i,:);
        h(2).LineWidth = 3;

        legend('','act','','pas','','fix')

        pd = fitdist(err_ori','Normal');
        text(-90,220-(40*cond_i),sprintf('sig = %0.1f',pd.sigma),'FontSize',11,'Color',colors(cond_i,:))
        text(-90,205-(40*cond_i),sprintf('mu = %0.1f',pd.mu),'FontSize',11,'Color',colors(cond_i,:))
        
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
    if len_i == 1
        title('4 ITEMS')
    elseif len_i == 2
        title('8 ITEMS')
    else
        title('12 ITEMS')
    end
end
set(gcf,'Position',[50 50 800 800])


%% CORRELATION BETWEEN TRUE AVERAGE AND RESPONSE

plot_idx = [1 2 3; 4 5 6; 7 8 9];
figure('Color','white');

for cond_i = 1:n_cond

    for len_i = 1:n_len

        subplot(3,3,plot_idx(cond_i,len_i));
        xlim([0,180]);
        ylim([0,180]);
     
        for sub_i = 1:28
            hold on
            ang_avg = stat_dat.ang_avg{stat_dat.sub_num==subs(sub_i) & stat_dat.cond_num==cond_i & stat_dat.targ_len==lens(len_i)};
            resp_ang = data.resp_ang(data.sub_num==subs(sub_i) & data.cond_num==cond_i & data.targ_len==lens(len_i) & data.targ_num==1)';
            scatter(ang_avg,resp_ang,'o','MarkerEdgeColor','none','MarkerFaceColor',[0.4 0.4 0.8],'MarkerFaceAlpha',0.3);
        end
        plot(xlim,ylim,'-','Color','k','LineWidth',2);
        text(30,150,sprintf('r = %.2f',mean(stat_dat.rho_ang(stat_dat.cond_num==cond_i & stat_dat.targ_len==lens(len_i)))));
    
        hold off
        set(gca,'TickDir','out','PlotBoxAspectRatio',[1,1,1],'LineWidth',0.75);
        set(gca,'XTick',0:30:180,'YTick',0:30:180);
        xlabel('Sequence average','FontSize',12);
        ylabel('Response','FontSize',12);
        if len_i == 1
            title(sprintf('%s 4 ITEMS',cond_name{cond_i}))
        elseif len_i == 2
            title(sprintf('%s 8 ITEMS',cond_name{cond_i}))
        else
            title(sprintf('%s 12 ITEMS',cond_name{cond_i}))
        end
    end
end


%% SEQUENCE COHERENCE (SUBJECT DATA)

figure('Color','white');
for cond_i = 1:3
    subplot(1,3,cond_i)
    xlim([1,15]);
    ylim([0.5,1]);
    hold on

    for len_i = 1:3
        plot(lens([len_i,len_i]),[mean(stat_dat.rho_c95_min(stat_dat.targ_len==lens(len_i) & stat_dat.cond_num==cond_i));mean(stat_dat.rho_c95_max(stat_dat.targ_len==lens(len_i) & stat_dat.cond_num==cond_i))],'k-','LineWidth',0.75);
        plot(lens(len_i),mean(stat_dat.rho_ang(stat_dat.targ_len==lens(len_i) & stat_dat.cond_num==cond_i)),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
        plot(lens(len_i)-0.5,mean(stat_dat.rho_mag_lo(stat_dat.targ_len==lens(len_i) & stat_dat.cond_num==cond_i)),'wo','MarkerSize',9,'MarkerFaceColor',[0.9,0.5,0.5],'LineWidth',1.5);
        plot(lens(len_i)+0.5,mean(stat_dat.rho_mag_hi(stat_dat.targ_len==lens(len_i) & stat_dat.cond_num==cond_i)),'wo','MarkerSize',9,'MarkerFaceColor',[0.5,0.9,0.5],'LineWidth',1.5);
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


%% SEQUENCE COHERENCE (MODEL SIMULATIONS)

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

figure('Color','white');
for cond_i = 1:n_cond
    subplot(1,3,cond_i)
    hold on
    xlim([1,15]);
    ylim([0.5,1]);

    for len_i = 1:3
        bar(lens(len_i),mean(mean(cell2mat(stat_bst.rho_ang(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))))),2,'EdgeColor','b','FaceColor',[0.5,0.5,1],'LineWidth',1);
        plot(lens([len_i,len_i]),mean(quantile(cell2mat(stat_bst.rho_ang(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))),[0.025,0.975]),2),'b-','LineWidth',0.75);
        plot(lens(len_i),mean(stat_dat.rho_ang(stat_dat.cond_num==cond_i & stat_dat.targ_len==lens(len_i))),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
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

figure('Color','white');
for cond_i = 1:n_cond
    subplot(1,3,cond_i)
    hold on
    xlim([1,15]);
    ylim([0,35]);
    
    for len_i = 1:3
        bar(lens(len_i),mean(mean(cell2mat(stat_bst.sig_err(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))))),2,'EdgeColor','k','FaceColor',[0.5,0.5,1],'LineWidth',1);
        plot(lens([len_i,len_i]),mean(quantile(cell2mat(stat_bst.sig_err(stat_bst.cond_num==cond_i & stat_bst.targ_len==lens(len_i))),[0.025,0.975]),2),'k-','LineWidth',1);
        plot(lens(len_i),mean(stat_dat.sig_err(stat_dat.cond_num==cond_i & stat_dat.targ_len==lens(len_i))),'wo','MarkerSize',9,'MarkerFaceColor','k','LineWidth',1.5);
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


%% MODEL PARAMETERS - FIT SIGINF

load([main_folder 'Model/params_fit_siginf.mat'],'params')

figure('Color','white');

subplot(1,3,1)
siginfs = [params.siginf(:,1) params.siginf(:,2) params.siginf(:,3)];
bar([1 2 3],mean(siginfs))
hold on
std_err = std(siginfs)/sqrt(length(siginfs));
er = errorbar([1 2 3],mean(siginfs),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('siginf')
ylim([1.5 3])
set(gca,'YTick',1.5:0.3:3);
axis square
box off
set(gca,'TickDir','out')

ylabel('siginf')
xticklabels(cond_name)

subplot(1,3,2)
plapses = [params.plapse(:,1) params.plapse(:,2) params.plapse(:,3)];
bar([1 2 3],mean(plapses))
hold on
std_err = std(plapses)/sqrt(length(plapses));
er = errorbar([1 2 3],mean(plapses),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('plapse')
ylim([0 0.05])
set(gca,'YTick',0:0.01:0.05);
axis square
box off
set(gca,'TickDir','out')

ylabel('plapse')
xticklabels(cond_name)

subplot(1,3,3)
alphas = [params.alpha(:,1) params.alpha(:,2) params.alpha(:,3)];
bar([1 2 3],mean(alphas))
hold on
std_err = std(alphas)/sqrt(length(alphas));
er = errorbar([1 2 3],mean(alphas),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('alpha')
ylim([0 0.25])
set(gca,'YTick',0:0.05:0.25);
axis square
box off
set(gca,'TickDir','out')

ylabel('alpha')
xticklabels(cond_name)

sgtitle('FIT SIGINF')


%% MODEL PARAMETERS - FIT SIGSEN

load([main_folder 'Model/params_fit_sigsen.mat'],'params')

figure('Color','white');

subplot(1,3,1)
sigsens = [params.sigsen(:,1) params.sigsen(:,2) params.sigsen(:,3)];
bar([1 2 3],mean(sigsens))
hold on
std_err = std(sigsens)/sqrt(length(sigsens));
er = errorbar([1 2 3],mean(sigsens),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('sigsen')
ylim([22 29])
set(gca,'YTick',23:2:29);
axis square
box off
set(gca,'TickDir','out')

ylabel('sigsen')
xticklabels(cond_name)

subplot(1,3,2)
plapses = [params.plapse(:,1) params.plapse(:,2) params.plapse(:,3)];
bar([1 2 3],mean(plapses))
hold on
std_err = std(plapses)/sqrt(length(plapses));
er = errorbar([1 2 3],mean(plapses),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('plapse')
ylim([0 0.05])
set(gca,'YTick',0:0.01:0.05);
axis square
box off
set(gca,'TickDir','out')

ylabel('plapse')
xticklabels(cond_name)

subplot(1,3,3)
alphas = [params.alpha(:,1) params.alpha(:,2) params.alpha(:,3)];
bar([1 2 3],mean(alphas))
hold on
std_err = std(alphas)/sqrt(length(alphas));
er = errorbar([1 2 3],mean(alphas),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('alpha')
ylim([0 0.25])
set(gca,'YTick',0:0.05:0.25);
axis square
box off
set(gca,'TickDir','out')

ylabel('alpha')
xticklabels(cond_name)

sgtitle('FIT SIGSEN')


%% MODEL PARAMETERS - FIT SIGREP

load([main_folder 'Model/params_fit_sigrep.mat'],'params')

figure('Color','white');

subplot(1,3,1)
sigreps = [params.sigrep(:,1) params.sigrep(:,2) params.sigrep(:,3)];
bar([1 2 3],mean(sigreps))
hold on
std_err = std(sigreps)/sqrt(length(sigreps));
er = errorbar([1 2 3],mean(sigreps),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('sigrep')
ylim([10 18])
set(gca,'YTick',10:2:18);
axis square
box off
set(gca,'TickDir','out')

ylabel('sigrep')
xticklabels(cond_name)

subplot(1,3,2)
plapses = [params.plapse(:,1) params.plapse(:,2) params.plapse(:,3)];
bar([1 2 3],mean(plapses))
hold on
std_err = std(plapses)/sqrt(length(plapses));
er = errorbar([1 2 3],mean(plapses),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('plapse')
ylim([0 0.07])
set(gca,'YTick',0:0.01:0.07);
axis square
box off
set(gca,'TickDir','out')

ylabel('plapse')
xticklabels(cond_name)

subplot(1,3,3)
alphas = [params.alpha(:,1) params.alpha(:,2) params.alpha(:,3)];
bar([1 2 3],mean(alphas))
hold on
std_err = std(alphas)/sqrt(length(alphas));
er = errorbar([1 2 3],mean(alphas),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('alpha')
ylim([0 0.25])
set(gca,'YTick',0:0.05:0.25);
axis square
box off
set(gca,'TickDir','out')

ylabel('alpha')
xticklabels(cond_name)

sgtitle('FIT SIGREP')


%% MODEL PARAMETERS - FIT ALL

load([main_folder 'Model/params_fit_all.mat'],'params')

figure('Color','white');

subplot(2,3,1)
siginfs = [params.siginf(:,1) params.siginf(:,2) params.siginf(:,3)];
bar([1 2 3],mean(siginfs))
hold on
std_err = std(siginfs)/sqrt(length(siginfs));
er = errorbar([1 2 3],mean(siginfs),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('siginf')
ylim([0.8 1.6])
set(gca,'YTick',0.8:0.2:1.6);
axis square
box off
set(gca,'TickDir','out')

ylabel('siginf')
xticklabels(cond_name)

subplot(2,3,2)
sigsens = [params.sigsen(:,1) params.sigsen(:,2) params.sigsen(:,3)];
bar([1 2 3],mean(sigsens))
hold on
std_err = std(sigsens)/sqrt(length(sigsens));
er = errorbar([1 2 3],mean(sigsens),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('sigsen')
ylim([5 17])
set(gca,'YTick',5:2:17);
axis square
box off
set(gca,'TickDir','out')

ylabel('sigsen')
xticklabels(cond_name)

subplot(2,3,3)
sigreps = [params.sigrep(:,1) params.sigrep(:,2) params.sigrep(:,3)];
bar([1 2 3],mean(sigreps))
hold on
std_err = std(sigreps)/sqrt(length(sigreps));
er = errorbar([1 2 3],mean(sigreps),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('sigrep')
ylim([4 9])
set(gca,'YTick',4:1:9);
axis square
box off
set(gca,'TickDir','out')

ylabel('sigrep')
xticklabels(cond_name)

subplot(2,3,4)
plapses = [params.plapse(:,1) params.plapse(:,2) params.plapse(:,3)];
bar([1 2 3],mean(plapses))
hold on
std_err = std(plapses)/sqrt(length(plapses));
er = errorbar([1 2 3],mean(plapses),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('plapse')
ylim([0 0.05])
set(gca,'YTick',0:0.01:0.05);
axis square
box off
set(gca,'TickDir','out')

ylabel('plapse')
xticklabels(cond_name)

subplot(2,3,5)
alphas = [params.alpha(:,1) params.alpha(:,2) params.alpha(:,3)];
bar([1 2 3],mean(alphas))
hold on
std_err = std(alphas)/sqrt(length(alphas));
er = errorbar([1 2 3],mean(alphas),-std_err,+std_err);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

title('alpha')
ylim([0 0.25])
set(gca,'YTick',0:0.05:0.25);
axis square
box off
set(gca,'TickDir','out')

ylabel('alpha')
xticklabels(cond_name)

sgtitle('FIT ALL')


%%

function err = deg2range(err)  
    err(err>90) = err(err>90) - 180;
    err(err<-90) = err(err<-90) + 180;
end
