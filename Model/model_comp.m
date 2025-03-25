clear all
clc

at_usp = false;

if at_usp
    main_folder = '/Users/Gabi/Documents/GitHub/sacsamp-analysis/';
    data_folder = 'F:/sacsamp-model/';
else
    main_folder = '/Users/gabimelo/Documents/GitHub/sacsamp-analysis/';
    data_folder = '/Volumes/PortableSSD/sacsamp-model/';
end

addpath(genpath(main_folder))
cd(main_folder)

load('full_data.mat','data')

subs = unique(data.sub_num);
n_sub = length(subs);
n_cond = 3;


%%
%%% get models evaluation metrics

eval.sigsen = [];
eval.siginf = [];
eval.sigrep = [];
eval.sub    = [];
eval.cond   = [];
eval.bic    = [];
eval.aic    = [];
eval.ll     = [];

% file_name = 'output_fit_sigrep.mat';
file_name = 'output_fit_sigrep_v2.mat';
load([data_folder file_name],'model_fit')
for cond_i = 1:n_cond
    for sub_i = 1:n_sub
        eval.sigsen(end+1) = 0;
        eval.siginf(end+1) = 0;
        eval.sigrep(end+1) = 1;
        eval.sub(end+1) = sub_i;
        eval.cond(end+1) = cond_i;
        eval.bic(end+1) = vertcat(model_fit(sub_i,cond_i).aic);
        eval.aic(end+1) = vertcat(model_fit(sub_i,cond_i).bic);
        eval.ll(end+1) = vertcat(model_fit(sub_i,cond_i).ll);
    end
end

% file_name = 'output_fit_siginf.mat';
file_name = 'output_fit_siginf_v2.mat';
load([data_folder file_name],'model_fit')
for cond_i = 1:n_cond
    for sub_i = 1:n_sub
        eval.sigsen(end+1) = 0;
        eval.siginf(end+1) = 1;
        eval.sigrep(end+1) = 0;
        eval.sub(end+1) = sub_i;
        eval.cond(end+1) = cond_i;
        eval.bic(end+1) = vertcat(model_fit(sub_i,cond_i).aic);
        eval.aic(end+1) = vertcat(model_fit(sub_i,cond_i).bic);
        eval.ll(end+1) = vertcat(model_fit(sub_i,cond_i).ll);
    end
end

% file_name = 'output_fit_sigsen.mat';
file_name = 'output_fit_sigsen_v2.mat';
load([data_folder file_name],'model_fit')
for cond_i = 1:n_cond
    for sub_i = 1:n_sub
        eval.sigsen(end+1) = 1;
        eval.siginf(end+1) = 0;
        eval.sigrep(end+1) = 0;
        eval.sub(end+1) = sub_i;
        eval.cond(end+1) = cond_i;
        eval.bic(end+1) = vertcat(model_fit(sub_i,cond_i).aic);
        eval.aic(end+1) = vertcat(model_fit(sub_i,cond_i).bic);
        eval.ll(end+1) = vertcat(model_fit(sub_i,cond_i).ll);
    end
end

% file_name = 'output_fit_all.mat';
file_name = 'output_fit_all_v2.mat';
load([data_folder file_name],'model_fit')
for cond_i = 1:n_cond
    for sub_i = 1:n_sub
        eval.sigsen(end+1) = 1;
        eval.siginf(end+1) = 1;
        eval.sigrep(end+1) = 1;
        eval.sub(end+1) = sub_i;
        eval.cond(end+1) = cond_i;
        eval.bic(end+1) = vertcat(model_fit(sub_i,cond_i).aic);
        eval.aic(end+1) = vertcat(model_fit(sub_i,cond_i).bic);
        eval.ll(end+1) = vertcat(model_fit(sub_i,cond_i).ll);
    end
end

save([main_folder 'Model/model_comp_v2'],'eval')


%%
%%% compare models AIC 

load([main_folder 'Model/model_comp_v2'],'eval')

aic = sum(eval.aic(eval.sigsen == 1 & eval.siginf == 1 & eval.sigrep == 1));
fprintf('\n aic fit all = %0.2f \n',aic)

aic = sum(eval.aic(eval.sigsen == 0 & eval.siginf == 0 & eval.sigrep == 1));
fprintf('\n aic fit sigrep = %0.2f \n',aic)

aic = sum(eval.aic(eval.sigsen == 1 & eval.siginf == 0 & eval.sigrep == 0));
fprintf('\n aic fit sigsen = %0.2f \n',aic)

aic = sum(eval.aic(eval.sigsen == 0 & eval.siginf == 1 & eval.sigrep == 0));
fprintf('\n aic fit siginf = %0.2f \n',aic)


%%
%%% compare models AIC by condition

load([main_folder 'Model/model_comp_v2'],'eval')

cond_i = 2

aic = sum(eval.aic(eval.sigsen == 1 & eval.siginf == 1 & eval.sigrep == 1 & eval.cond == cond_i));
fprintf('\n aic fit all = %0.2f \n',aic)

aic = sum(eval.aic(eval.sigsen == 0 & eval.siginf == 0 & eval.sigrep == 1 & eval.cond == cond_i));
fprintf('\n aic fit sigrep = %0.2f \n',aic)

aic = sum(eval.aic(eval.sigsen == 1 & eval.siginf == 0 & eval.sigrep == 0 & eval.cond == cond_i));
fprintf('\n aic fit sigsen = %0.2f \n',aic)

aic = sum(eval.aic(eval.sigsen == 0 & eval.siginf == 1 & eval.sigrep == 0 & eval.cond == cond_i));
fprintf('\n aic fit siginf = %0.2f \n',aic)


%%
%%% plot AIC

load([main_folder 'Model/model_comp_v2'],'eval')

aic = [];
labels = {'all', 'sigRep', 'sigSen', 'sigInf'};

figure('Color','white');


subplot(1,4,1)

aic(:,1) = (eval.aic(eval.sigsen == 1 & eval.siginf == 1 & eval.sigrep == 1));
aic(:,2) = (eval.aic(eval.sigsen == 0 & eval.siginf == 0 & eval.sigrep == 1));
aic(:,3) = (eval.aic(eval.sigsen == 1 & eval.siginf == 0 & eval.sigrep == 0));
aic(:,4) = (eval.aic(eval.sigsen == 0 & eval.siginf == 1 & eval.sigrep == 0));

bar(1:4,mean(aic))
% bar(1:4,sum(aic))

ylim([185 205])
% ylim([15500 15500+2000])

% ylim([560 560+60])
% ylim([580 570+40])

ylabel('AIC')
xlabel('Free parameters')
xticklabels(labels)

% hold on
% std_err = std(aic)/sqrt(length(aic));
% er = errorbar(1:4,mean(aic),-std_err,+std_err); 
% er.Color = [0 0 0];                            
% er.LineStyle = 'none';  

axis square
box off
set(gca,'TickDir','out')

title('ALL')

aic = [];

for cond_i = 1:n_cond

    subplot(1,4,1+cond_i)

    aic(:,1) = (eval.aic(eval.sigsen == 1 & eval.siginf == 1 & eval.sigrep == 1 & eval.cond == cond_i));
    aic(:,2) = (eval.aic(eval.sigsen == 0 & eval.siginf == 0 & eval.sigrep == 1 & eval.cond == cond_i));
    aic(:,3) = (eval.aic(eval.sigsen == 1 & eval.siginf == 0 & eval.sigrep == 0 & eval.cond == cond_i));
    aic(:,4) = (eval.aic(eval.sigsen == 0 & eval.siginf == 1 & eval.sigrep == 0 & eval.cond == cond_i));

    bar(1:4,mean(aic))
    % bar(1:4,sum(aic))

    if cond_i == 3
        % ylim([4500 4500+400])
        ylim([160 180])
    else
        % ylim([5700 6100])
        ylim([200 220])
    end

    ylabel('AIC')
    xlabel('Free parameters')
    xticklabels(labels)

    % hold on
    % std_err = std(aic)/sqrt(length(aic));
    % er = errorbar(1:4,mean(aic),-std_err,+std_err); 
    % er.Color = [0 0 0];                            
    % er.LineStyle = 'none';  

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



