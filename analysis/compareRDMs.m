function [] = compareRDMs(project_params,which_subjects,metric)

addpath('D:\Documents\software\cbrewer') %for color
[cb] = cbrewer('qual','Set1',10,'pchip');
base_dir = fullfile('..','analyzed','DM2_unsmoothed','group','rsa',metric);
Models = modelRDMs();

ROIs = {'FPl','FPm','BA46','vmPFC','rTPJ','rSTS','preSMA'};


for i_ROI = 1:7
    
    ROI = ROIs{i_ROI}
    correlations = nan(max(which_subjects),10);
    
    load(fullfile(base_dir,[ROI,'_RDM.mat']))
    
    rankRDM = nan(size(RDM));
    for i_s = which_subjects
        subj_RDM = squeeze(RDM(:,:,i_s));
        subj_RDM(logical(eye(size(subj_RDM,1))))=nan; %ignore the diagonal
        rankRDM(:,:,i_s)= reshape(tiedrank(subj_RDM(:)),size(subj_RDM,1),size(subj_RDM,2));
    end
    
    meanRankRDM = nanmean(rankRDM,3);
    
    for i_s = which_subjects
        
        subj_RDM = squeeze(RDM(:,:,i_s));
        subj_RDM(logical(eye(size(subj_RDM,1))))=nan; %ignore the diagonal
        correlations(i_s,1) = corr(subj_RDM(:), Models.task(:),'type','Spearman', 'rows','complete');
        correlations(i_s,2) = corr(subj_RDM(:), Models.variance_structure(:),'type','Spearman', 'rows','complete');
        correlations(i_s,3) = corr(subj_RDM(:), Models.detection(:),'type','Spearman', 'rows','complete');
        correlations(i_s,4) = corr(subj_RDM(:), Models.unequal_variance(:),'type','Spearman', 'rows','complete');
        correlations(i_s,5) = corr(subj_RDM(:), Models.confidence(:),'type','Spearman', 'rows','complete');
        correlations(i_s,6) = corr(subj_RDM(:), Models.conf_x_var(:),'type','Spearman', 'rows','complete');
        correlations(i_s,7) = corr(subj_RDM(:), Models.conf_detection(:),'type','Spearman', 'rows','complete');
        correlations(i_s,8) = corr(subj_RDM(:), Models.conf_x_uv(:),'type','Spearman', 'rows','complete');
        correlations(i_s,9) = corr(subj_RDM(:), meanRankRDM(:),'type','Spearman', 'rows','complete');
        
        %obtain mean rank RDM for all other subjects
        meanOthersRankRDM = nanmean(rankRDM(:,:,setdiff(which_subjects,i_s)),3);
        correlations(i_s,10) = corr(subj_RDM(:), meanOthersRankRDM(:),'type','Spearman', 'rows','complete');


    end
    
    correlations_table = table(correlations(:,1),...
        correlations(:,2),...
        correlations(:,3),...
        correlations(:,4), ...
        correlations(:,5), ...
        correlations(:,6), ...
        correlations(:,7), ...
        correlations(:,8),...
        correlations(:,9),...
        correlations(:,10),...
        'VariableNames', {'task','varianceStructure','detection','unequal_variane',...
        'confidence','conf_x_var','conf_detection','conf_x_uv','upperNoiseCeiling',...
        'lowerNoiseCeiling'});
    save(fullfile(base_dir,[ROI,'_SpearmanCorrelations.mat']),'correlations_table', 'correlations');
    
    %make figure
    mean_RDM = squeeze(nanmean(RDM,3));
    symmetric1 = triu(mean_RDM)+triu(mean_RDM)'-eye(size(mean_RDM)).*mean_RDM;
    symmetric2 = tril(mean_RDM)+tril(mean_RDM)'-eye(size(mean_RDM)).*mean_RDM;
    symmetric_RDM = 0.5*symmetric1+0.5*symmetric2;
    symmetric_RDM(find(eye(size(symmetric_RDM))))=0;
    [Y,e] = cmdscale(symmetric_RDM,2);
    
    fig=figure;
    subplot(1,4,4);
    set(gca,'XColor','none')
    hold on;
    ms=70;
    
    scatter(Y(1,1),Y(1,2), ms, cb(3,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(2,1),Y(2,2), ms, cb(3,:), 'filled','MarkerEdgeColor',cb(3,:),'MarkerFaceAlpha',0.2)
    
    scatter(Y(3,1),Y(3,2), ms, cb(4,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(4,1),Y(4,2), ms, cb(4,:), 'filled','MarkerEdgeColor',cb(4,:),'MarkerFaceAlpha',0.2)
    
    scatter(Y(5,1),Y(5,2), ms, cb(2,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(6,1),Y(6,2), ms, cb(2,:), 'filled','MarkerEdgeColor',cb(2,:),'MarkerFaceAlpha',0.2) 

    scatter(Y(7,1),Y(7,2), ms, cb(1,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(8,1),Y(8,2), ms, cb(1,:), 'filled','MarkerEdgeColor',cb(1,:),'MarkerFaceAlpha',0.2) 
    
    scatter(Y(9,1),Y(9,2), ms, cb(6,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(10,1),Y(10,2), ms, cb(6,:), 'filled','MarkerEdgeColor',cb(6,:),'MarkerFaceAlpha',0.2) 
    
    scatter(Y(11,1),Y(11,2), ms, cb(7,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(12,1),Y(12,2), ms, cb(7,:), 'filled','MarkerEdgeColor',cb(7,:),'MarkerFaceAlpha',0.2) 
    
    title([ROI,': ',metric])
    axis equal;
    xticks([]);
    yticks([]);
    axis off;
    
    N = max(which_subjects);
    means = nanmean(correlations(:,1:8));
    errors = nanstd(correlations(:,1:8))/sqrt(length(which_subjects));
    noise = normrnd(0,0.05,N,1);
    lower_noise_ceiling = nanmean(correlations(:,10));
    upper_noise_ceiling = nanmean(correlations(:,9));
    subplot(1,4,[1:3]); hold on;
    bar(1:8,means,'white')
    errorbar(1:8,means,errors,errors,'lineStyle','none','color','black');
    %     x_positions = repmat(1:8,N,1) + repmat(noise,1,8);
    %     % plot([ones(1,35)+noise1; 2*ones(1,35)+noise2],[meanAccDis;meanAccDet],'color',[0.5,0.5,0.5]);
    %     scatter(x_positions(:),correlations(:),'MarkerEdgeColor','k','MarkerFaceColor',...
    %         [0,0,0],'LineWidth',1, 'MarkerEdgeAlpha',0.3,'MarkerFaceAlpha',0.3);
    xlim([0.5,8.5]); xlabel('Theoretical RDM');
    ylabel('Spearman correlation');
    refline(0,lower_noise_ceiling);
    % ylim([0.4,1]);
    set(gca,'xtick',1:8,'xticklabel',{'A','B','C','D',...
        'E','F','G','H'})
    fig = gcf;
    s=hgexport('readstyle','presentation');
    s.Format = 'png';
    s.Width = 20;
    s.Height = 8;
    hgexport(fig,fullfile('figures',[ROI,'_','correlations_',metric]),s);
    
%     fig=figure;
%     conditions = {'C_H','C_L','A_H','A_L',...
%     'Y_H','Y_L','N_H','N_L',...
%     'T_H','T_L','V_H','V_L'};
%     heatmap(conditions,conditions,Scale(mean_RDM),'colorMap',jet);
%     s=hgexport('readstyle','presentation');
%     s.Format = 'png';
%     s.Width = 11;
%     s.Height = 10;
%     hgexport(fig,fullfile('figures',[ROI,'_','RDM_',metric]),s);
    close all;
    
    
end
end

