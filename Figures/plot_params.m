clear all
close all
clc

project_path = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';

addpath(genpath(project_path))
cd(project_path)

load([project_path 'Model/Outputs/params_fit_all.mat'])
load([project_path 'Model/Outputs/params_fit_siginf.mat'])
load([project_path 'Model/Outputs/params_fit_sigsen.mat'])
load([project_path 'Model/Outputs/params_fit_sigrep.mat'])

set(0,'defaultAxesFontSize',14)  
labels = {'ACT', 'PAS', 'FIX'};


%%
%%% plot fitted parameters - siginf

figure('Color','white');

subplot(1,3,1)
siginfs = [fit_siginf.siginf(:,1) fit_siginf.siginf(:,2) fit_siginf.siginf(:,3)]
bar([1 2 3],mean(siginfs))
hold on
std_err = std(siginfs)/sqrt(length(siginfs))
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
xticklabels(labels)

subplot(1,3,2)
plapses = [fit_siginf.plapse(:,1) fit_siginf.plapse(:,2) fit_siginf.plapse(:,3)]
bar([1 2 3],mean(plapses))
hold on
std_err = std(plapses)/sqrt(length(plapses))
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
xticklabels(labels)

subplot(1,3,3)
alphas = [fit_siginf.alpha(:,1) fit_siginf.alpha(:,2) fit_siginf.alpha(:,3)]
bar([1 2 3],mean(alphas))
hold on
std_err = std(alphas)/sqrt(length(alphas))
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
xticklabels(labels)


%%
%%% plot fitted parameters - sigsen

figure('Color','white');

subplot(1,3,1)
sigsens = [fit_sigsen.sigsen(:,1) fit_sigsen.sigsen(:,2) fit_sigsen.sigsen(:,3)]
bar([1 2 3],mean(sigsens))
hold on
std_err = std(sigsens)/sqrt(length(sigsens))
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
xticklabels(labels)

subplot(1,3,2)
plapses = [fit_sigsen.plapse(:,1) fit_sigsen.plapse(:,2) fit_sigsen.plapse(:,3)]
bar([1 2 3],mean(plapses))
hold on
std_err = std(plapses)/sqrt(length(plapses))
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
xticklabels(labels)

subplot(1,3,3)
alphas = [fit_sigsen.alpha(:,1) fit_sigsen.alpha(:,2) fit_sigsen.alpha(:,3)]
bar([1 2 3],mean(alphas))
hold on
std_err = std(alphas)/sqrt(length(alphas))
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
xticklabels(labels)


%%
%%% plot fitted parameters - sigrep

figure('Color','white');

subplot(1,3,1)
sigreps = [fit_sigrep.sigrep(:,1) fit_sigrep.sigrep(:,2) fit_sigrep.sigrep(:,3)]
bar([1 2 3],mean(sigreps))
hold on
std_err = std(sigreps)/sqrt(length(sigreps))
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
xticklabels(labels)

subplot(1,3,2)
plapses = [fit_sigrep.plapse(:,1) fit_sigrep.plapse(:,2) fit_sigrep.plapse(:,3)]
bar([1 2 3],mean(plapses))
hold on
std_err = std(plapses)/sqrt(length(plapses))
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
xticklabels(labels)

subplot(1,3,3)
alphas = [fit_sigrep.alpha(:,1) fit_sigrep.alpha(:,2) fit_sigrep.alpha(:,3)]
bar([1 2 3],mean(alphas))
hold on
std_err = std(alphas)/sqrt(length(alphas))
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
xticklabels(labels)


%%
%%% plot fitted parameters - all

figure('Color','white');

subplot(2,3,1)
siginfs = [fit_all.siginf(:,1) fit_all.siginf(:,2) fit_all.siginf(:,3)]
bar([1 2 3],mean(siginfs))
hold on
std_err = std(siginfs)/sqrt(length(siginfs))
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
xticklabels(labels)

subplot(2,3,2)
sigsens = [fit_all.sigsen(:,1) fit_all.sigsen(:,2) fit_all.sigsen(:,3)]
bar([1 2 3],mean(sigsens))
hold on
std_err = std(sigsens)/sqrt(length(sigsens))
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
xticklabels(labels)

subplot(2,3,3)
sigreps = [fit_all.sigrep(:,1) fit_all.sigrep(:,2) fit_all.sigrep(:,3)]
bar([1 2 3],mean(sigreps))
hold on
std_err = std(sigreps)/sqrt(length(sigreps))
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
xticklabels(labels)

subplot(2,3,4)
plapses = [fit_all.plapse(:,1) fit_all.plapse(:,2) fit_all.plapse(:,3)]
bar([1 2 3],mean(plapses))
hold on
std_err = std(plapses)/sqrt(length(plapses))
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
xticklabels(labels)

subplot(2,3,5)
alphas = [fit_all.alpha(:,1) fit_all.alpha(:,2) fit_all.alpha(:,3)]
bar([1 2 3],mean(alphas))
hold on
std_err = std(alphas)/sqrt(length(alphas))
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
xticklabels(labels)
