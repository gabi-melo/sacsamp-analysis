clear; close;

clear all
close all
clc

project_path = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';

addpath(genpath(project_path))
cd([project_path 'Analysis/'])

load([project_path '/Analysis/full_data.mat'])

subs = unique(data.sub_num);
n_sub = length(subs);
n_cond = 3;
n_len = 3;
lens = [4 8 12];

set(0,'defaultAxesFontSize',14)  
cond_name = {'Active','Passive','Fixation'};
plot_idx = [1 2 3; 4 5 6; 7 8 9];
colors = [[0.8500 0.3250 0.0980]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]];


%%
%%% plot individual data

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
            
            title(sprintf('%s - %d Targets',string(cond_name(cond_i)),len),'FontSize',14);
    
        end
        
    end
    
    set(gcf,'Position',[50 50 800 800])
    
    pause 
    
    close

end


%% 
%%% plot all subjects

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

        title(sprintf('%d Targets',len),'FontSize',14)
        xlabel('Error (Resp-Avg)')
        ylabel('Num Trials')

        pd = fitdist(err_ori','Normal');

        text(-90,230,sprintf('sig = %0.1f',pd.sigma),'FontSize',14)
        text(-90,210,sprintf('mu = %0.1f',pd.mu),'FontSize',14)

        axis square
        box off
        set(gca,'TickDir','out')
        
        title(sprintf('%s - %d Targets',string(cond_name(cond_i)),len),'FontSize',14);

    end
    
end

set(gcf,'Position',[50 50 800 800])


%% 
%%% plot all subjects

for cond_i = 1:n_cond

    subplot(1,3,cond_i)

    for len_i = 1:n_len
        
        len = lens(len_i);
        
        resp_ori = data.resp_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        avg_ori = data.avg_ang(data.cond_num==cond_i & data.targ_len==len & data.targ_num==1);
        err_ori = deg2range(resp_ori-avg_ori);

        nbins = round((max(err_ori)+abs(min(err_ori)))/8);
        h = histfit(err_ori,nbins,'normal');

        h(1).FaceColor = colors(len_i,:);
        h(1).FaceAlpha = 0.4;
        h(1).EdgeColor = colors(len_i,:);

        h(2).Color = colors(len_i,:);
        h(2).LineWidth = 3;

        % set(gca,'XLim',[-100 100])
        % set(gca,'YLim',[0 250])
        % set(gca,'XTick',[-90 -45 0 45 90])
        % 
        % % title(sprintf('%d Targets',len),'FontSize',14)
        % xlabel('Error (Resp-Avg)')
        % ylabel('Num Trials')
        % 
        % pd = fitdist(err_ori','Normal');

        % text(-90,230,sprintf('sig = %0.1f',pd.sigma),'FontSize',14)
        % text(-90,210,sprintf('mu = %0.1f',pd.mu),'FontSize',14)
        
        % title(sprintf('%s - %d Targets',string(cond_name(cond_i)),len),'FontSize',14);

        hold on

    end
    
    axis square
    box off
    set(gca,'TickDir','out')

    set(gca,'XLim',[-100 100])
    set(gca,'YLim',[0 250])
    set(gca,'XTick',[-90 -45 0 45 90])

    % title(sprintf('%d Targets',len),'FontSize',14)
    xlabel('Error (Resp-Avg)')
    ylabel('Num Trials')

end

set(gcf,'Position',[50 50 800 800])
