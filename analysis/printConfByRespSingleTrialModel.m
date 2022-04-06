function [ax1,ax2,ax3,coefs] = printConfByRespSingleTrialModel(project_params, subjects, ROI_label, ROI_name)

p=project_params;
load(fullfile(p.raw_dir,'subject_details.mat'));
N = numel(subjects);

%add nice things to path
addpath('D:\Documents\software\cbrewer') %for color
[cb] = cbrewer('qual','Set1',10,'pchip');

A_num_trials = nan(N,6);
C_num_trials = nan(N,6);
Y_num_trials = nan(N,6);
N_num_trials = nan(N,6);
T_num_trials = nan(N,6);
V_num_trials = nan(N,6);

conf_A = nan(N,6);
conf_C = nan(N,6);
conf_Y = nan(N,6);
conf_N = nan(N,6);
conf_T = nan(N,6);
conf_V = nan(N,6);

if ~exist(['figures/',ROI_label,'single_trials'],'dir')
    mkdir(['figures/',ROI_label,'single_trials']);
end

for i_s = subjects
    
    %should this subject be excluded or not?
    exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','exclusion.txt'));
    
    blockNo = sum(exclusion_file==0);
    
    if blockNo>0
        ROI = load(fullfile(p.stats_dir,...
            'DM200',['sub-',subj{i_s}.scanid],[ROI_label,'.mat']));
        
        for rating = 1:6
            
            A_num_trials(i_s,rating)=...
                sum(ROI.confidence_vec==rating & ROI.task_vec==0 & ROI.response_vec==0 & ROI.include_vec==1);
            
            C_num_trials(i_s,rating)=...
                sum(ROI.confidence_vec==rating & ROI.task_vec==0 & ROI.response_vec==1 & ROI.include_vec==1);
            
            N_num_trials(i_s,rating)=...
                sum(ROI.confidence_vec==rating & ROI.task_vec==1 & ROI.response_vec==0 & ROI.include_vec==1);
            
            Y_num_trials(i_s,rating)=...
                sum(ROI.confidence_vec==rating & ROI.task_vec==1 & ROI.response_vec==1 & ROI.include_vec==1);
            
            V_num_trials(i_s,rating)=...
                sum(ROI.confidence_vec==rating & ROI.task_vec==2 & ROI.response_vec==0 & ROI.include_vec==1);
            
            T_num_trials(i_s,rating)=...
                sum(ROI.confidence_vec==rating & ROI.task_vec==2 & ROI.response_vec==1 & ROI.include_vec==1);
            
            conf_A(i_s,rating)=...
                nanmean(ROI.mean_beta_vec(ROI.confidence_vec==rating & ...
                ROI.task_vec==0 & ROI.response_vec==0 & ROI.include_vec==1));
            
            conf_C(i_s,rating)=...
                nanmean(ROI.mean_beta_vec(ROI.confidence_vec==rating & ...
                ROI.task_vec==0 & ROI.response_vec==1 & ROI.include_vec==1));
            
            conf_N(i_s,rating)=...
                nanmean(ROI.mean_beta_vec(ROI.confidence_vec==rating & ...
                ROI.task_vec==1 & ROI.response_vec==0 & ROI.include_vec==1));
            
            conf_Y(i_s,rating)=...
                nanmean(ROI.mean_beta_vec(ROI.confidence_vec==rating & ...
                ROI.task_vec==1 & ROI.response_vec==1 & ROI.include_vec==1));
            
            conf_V(i_s,rating)=...
                nanmean(ROI.mean_beta_vec(ROI.confidence_vec==rating & ...
                ROI.task_vec==2 & ROI.response_vec==0 & ROI.include_vec==1));
            
            conf_T(i_s,rating)=...
                nanmean(ROI.mean_beta_vec(ROI.confidence_vec==rating & ...
                ROI.task_vec==2 & ROI.response_vec==1 & ROI.include_vec==1));
        end
        
        figure;
        conf_levels = 1:6;
        ax1=subplot(1,3,1); hold on;
        title('detection');
        good_y = Y_num_trials(i_s,:)>0;
        plot(conf_levels(good_y), conf_Y(i_s,good_y),'-k');
        good_n = N_num_trials(i_s,:)>0;
        plot(0.2+conf_levels(good_n), conf_N(i_s,good_n),'-k');
        yes_points = scatter(conf_levels(good_y),conf_Y(i_s,good_y),5*(Y_num_trials(i_s,good_y))'+1,cb(2,:),...
            'filled','MarkerEdgeColor','k');
        no_points = scatter(0.2+conf_levels(good_n),conf_N(i_s,good_n),5*N_num_trials(i_s,good_n)'+1,cb(1,:),...
            'filled','MarkerEdgeColor','k');
        
        xlim([0,7]);
        % ylim([-0.5, 1.2]);
        xticks(1:6);
        % xtickangle(45);
        set(gca,'ytick',[0,1]);
        ylabel(sprintf('mean \\beta in the %s',ROI_name));
        xlabel('confidence');
        
        ax2=subplot(1,3,2); hold on;
        set(gca,'YColor','none')
        title('discrimination');
        good_c = C_num_trials(i_s,:)>0;
        plot(conf_levels(good_c), conf_C(i_s,good_c),'-k')
        good_a = A_num_trials(i_s,:)>0;
        plot(0.2+conf_levels(good_a), conf_A(i_s,good_a),'-k')
        CW_points = scatter(conf_levels(good_c),conf_C(i_s,good_c), 5*C_num_trials(i_s,good_c)'+1,cb(3,:),...
            'filled','MarkerEdgeColor','k');
        CCW_points = scatter(0.2+conf_levels(good_a),conf_A(i_s,good_a),5*A_num_trials(i_s,good_a)'+1,cb(4,:),...
            'filled','MarkerEdgeColor','k');
        %     % %for overlap:
        %     scatter(1:6,nanmean(conf_C),5*nanmean(C_num_trials)'+1,cb(3,:),...
        %         'filled','MarkerEdgeColor','k','MarkerFaceAlpha',0.5);
        %     scatter(0.2+(1:6),nanmean(conf_A),5*nanmean(A_num_trials)'+1,'k');
        %
            xlim([0,7]);
            % ylim([-0.5, 1.2]);
            xticks(1:6);
            % xtickangle(45);
            set(gca,'ytick',[0,1]);
            xlabel('confidence');
        %
        %     ax3=subplot(1,3,3); hold on;
        %     title('tilt recognition');
        %     errorbar(1:6, nanmean(conf_T),T_standard_error,'-k')
        %     errorbar(0.2+(1:6), nanmean(conf_V),V_standard_error,'-k')
        %     T_points = scatter(1:6,nanmean(conf_T),5*nanmean(T_num_trials)'+1,cb(7,:),...
        %         'filled','MarkerEdgeColor','k');
        %     V_points = scatter(0.2+(1:6),nanmean(conf_V),5*nanmean(V_num_trials)'+1,cb(6,:),...
        %         'filled','MarkerEdgeColor','k');
        %     % %for overlap:
        %     scatter(1:6,nanmean(conf_T),5*nanmean(T_num_trials)'+1,cb(7,:),...
        %         'filled','MarkerEdgeColor','k','MarkerFaceAlpha',0.5);
        %     scatter(0.2+(1:6),nanmean(conf_V),5*nanmean(V_num_trials)'+1,'k');
        %
        %     xlim([0,7]);
        %     % ylim([-0.5, 1.2]);
        %     xticks(1:6);
        %     % xtickangle(45);
        %     set(gca,'ytick',[0,1]);
        %     legend([T_points,V_points],'tilted','vertical')
        %     xlabel('confidence');
        %
        %
        
        set(gca,'ytick',[]);
        linkaxes([ax1,ax2],'y')
        set(gca,'YColor','none')
        
        s=hgexport('readstyle','presentation');
        s.Format = 'png';
        s.Width = 22.5;
        s.Height = 12;
        
        hgexport(gcf,['figures/',ROI_label,'single_trials/',subj{i_s}.scanid],s);
    end
end


%% get standard errors

for i=1:6
    A_standard_error(i) = nanstd(conf_A(:,i))/sqrt(sum(~isnan(conf_A(:,i))));
    C_standard_error(i) = nanstd(conf_C(:,i))/sqrt(sum(~isnan(conf_C(:,i))));
    Y_standard_error(i) = nanstd(conf_Y(:,i))/sqrt(sum(~isnan(conf_Y(:,i))));
    N_standard_error(i) = nanstd(conf_N(:,i))/sqrt(sum(~isnan(conf_N(:,i))));
    T_standard_error(i) = nanstd(conf_T(:,i))/sqrt(sum(~isnan(conf_T(:,i))));
    V_standard_error(i) = nanstd(conf_V(:,i))/sqrt(sum(~isnan(conf_V(:,i))));
end


figure;
ax1=subplot(1,3,1); hold on;
title('detection');
errorbar(1:6, nanmean(conf_Y),Y_standard_error,'-k');
errorbar(0.2+(1:6), nanmean(conf_N),N_standard_error,'-k');
yes_points = scatter(1:6,nanmean(conf_Y),5*nanmean(Y_num_trials)'+1,cb(2,:),...
    'filled','MarkerEdgeColor','k');
no_points = scatter(0.2+(1:6),nanmean(conf_N),5*nanmean(N_num_trials)'+1,cb(1,:),...
    'filled','MarkerEdgeColor','k');

%for overlap:
scatter(1:6,nanmean(conf_Y),5*nanmean(Y_num_trials)'+1,cb(2,:),...
    'filled','MarkerEdgeColor','k','MarkerFaceAlpha',0.5);
scatter(0.2+(1:6),nanmean(conf_N),5*nanmean(N_num_trials)'+1,'k');

xlim([0,7]);
% ylim([-0.5, 1.2]);
xticks(1:6);
% xtickangle(45);
set(gca,'ytick',[0,1]);
ylabel(sprintf('mean \\beta in the %s',ROI_name));
legend([yes_points,no_points],'yes','no')
xlabel('confidence');

ax2=subplot(1,3,2); hold on;
set(gca,'YColor','none')
title('discrimination');
errorbar(1:6, nanmean(conf_C),C_standard_error,'-k')
errorbar(0.2+(1:6), nanmean(conf_A),A_standard_error,'-k')
CW_points = scatter(1:6,nanmean(conf_C),5*nanmean(C_num_trials)'+1,cb(3,:),...
    'filled','MarkerEdgeColor','k');
CCW_points = scatter(0.2+(1:6),nanmean(conf_A),5*nanmean(A_num_trials)'+1,cb(4,:),...
    'filled','MarkerEdgeColor','k');
% %for overlap:
scatter(1:6,nanmean(conf_C),5*nanmean(C_num_trials)'+1,cb(3,:),...
    'filled','MarkerEdgeColor','k','MarkerFaceAlpha',0.5);
scatter(0.2+(1:6),nanmean(conf_A),5*nanmean(A_num_trials)'+1,'k');

xlim([0,7]);
% ylim([-0.5, 1.2]);
xticks(1:6);
% xtickangle(45);
set(gca,'ytick',[0,1]);
legend([CW_points,CCW_points],'CW','CCW')
xlabel('confidence');

ax3=subplot(1,3,3); hold on;
title('tilt recognition');
errorbar(1:6, nanmean(conf_T),T_standard_error,'-k')
errorbar(0.2+(1:6), nanmean(conf_V),V_standard_error,'-k')
T_points = scatter(1:6,nanmean(conf_T),5*nanmean(T_num_trials)'+1,cb(7,:),...
    'filled','MarkerEdgeColor','k');
V_points = scatter(0.2+(1:6),nanmean(conf_V),5*nanmean(V_num_trials)'+1,cb(6,:),...
    'filled','MarkerEdgeColor','k');
% %for overlap:
scatter(1:6,nanmean(conf_T),5*nanmean(T_num_trials)'+1,cb(7,:),...
    'filled','MarkerEdgeColor','k','MarkerFaceAlpha',0.5);
scatter(0.2+(1:6),nanmean(conf_V),5*nanmean(V_num_trials)'+1,'k');

xlim([0,7]);
% ylim([-0.5, 1.2]);
xticks(1:6);
% xtickangle(45);
set(gca,'ytick',[0,1]);
legend([T_points,V_points],'tilted','vertical')
xlabel('confidence');



set(gca,'ytick',[]);
linkaxes([ax1,ax2,ax3],'y')
set(gca,'YColor','none')

s=hgexport('readstyle','presentation');
s.Format = 'png';
s.Width = 22.5;
s.Height = 12;

hgexport(gcf,['figures/',ROI_label,'single_trials'],s);



coefs = nan(N,3,6); %subjects, degrees, responses: YNACTV
ROI_conf_betas = cat(3,conf_Y, conf_N, conf_A, conf_C, conf_T, conf_V);

for i_s = 1:N
    for i_r = 1:6
        confidence_levels=1:6;
        beta_values = ROI_conf_betas(i_s,:,i_r);
        confidence_levels(isnan(beta_values))=[];
        if numel(confidence_levels)>3
            beta_values(isnan(beta_values))=[];
            coefs(i_s,:,i_r) = polyfit(confidence_levels-mean(confidence_levels),...
                beta_values-mean(beta_values),2);
        end
    end
end


end
