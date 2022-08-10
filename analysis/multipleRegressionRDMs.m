function [] = multipleRegressionRDMs(project_params,which_subjects,metric)

load('cb.mat')
base_dir = fullfile('..','analyzed','RSA',metric);

% create our predictors design matrix
DM = modelRDMsForMultipleRegression();

% ROIs = {'FPl','FPm','BA46','vmPFC','rTPJ','rSTS','preSMA'};
ROIs = {'BA46','vmPFC','rSTS'};

all_combination_means = [];
all_combination_errors = [];

for i_ROI = 1:3
    
    ROI = ROIs{i_ROI}
    betas = nan(max(which_subjects),size(DM,2));
    
    load(fullfile(base_dir,[ROI,'_RDM.mat']))
    
    for i_s = which_subjects
        
        subj_RDM = squeeze(RDM(:,:,i_s));
        subj_RDM(logical(eye(size(subj_RDM,1))))=nan;
        subj_RDM_zscored = (subj_RDM-nanmean(subj_RDM(:)))./nanstd(subj_RDM(:));
        subj_RDM_zscored_flat = subj_RDM_zscored(:);
        betas(i_s,:) = regress(subj_RDM_zscored_flat,DM);
    end
   
    save(fullfile(base_dir,[ROI,'_multipleRegressionCoefficients.mat']),'betas');
    errors=nanstd(betas(:,1:18))/sqrt(35);
    means = nanmean(betas(:,1:18));
    figure;
    bar(1:18,means,'white');
    hold on;
    errorbar(1:18,means,errors,errors,'lineStyle','none','color','black');
    ylabel('betas')
    xlabel('component')
    f = gcf;
%     s=hgexport('readstyle','presentation');
%     s.Format = 'png';
%     s.Width = 20;
%     s.Height = 8;
%     hgexport(fig,fullfile('figures',[ROI,'_','coefficients_',metric]),s);
    exportgraphics(f,fullfile('figures',[ROI,'_','coefficients_',metric,'.png']),'Resolution',300)

    like_detection = mean(betas(:,[6,8]),2);
    like_discrimination = mean(betas(:,[3,7,12,16]),2);
    
    beta_combinations = [like_detection,like_discrimination];
    means = nanmean(beta_combinations);
    errors=nanstd(beta_combinations)/sqrt(35);
    all_combination_means = [all_combination_means means];
    all_combination_errors = [all_combination_errors errors];
    fig=figure;
    bar(1:2,means,'white');
    hold on;
    errorbar(1:2,means,errors,errors,'lineStyle','none','color','black');
    ylabel('beta combination')
    set(gca,'xtick',[1:2],'xticklabel',{'like detection', 'like discrimination'})
    ylim([-0.05,0.1]);
%     s=hgexport('readstyle','presentation');
%     s.Format = 'png';
%     s.Width = 20;
%     s.Height = 12;
%     hgexport(fig,fullfile('figures',[ROI,'_','combinations_',metric]),s);
    f = gcf;
    exportgraphics(f,fullfile('figures',[ROI,'_','combinations_',metric,'.png']),'Resolution',300)


end

fig=figure;
hold on;
xpositions = [1:3; 0.3+(1:3)];
xpositions = xpositions(:)';
bar(xpositions(1:2:end),all_combination_means(1:2:end),0.25,'faceColor',cb(2,:));
bar(xpositions(2:2:end),all_combination_means(2:2:end),0.25,'faceColor',cb(4,:));
errorbar(xpositions,all_combination_means,all_combination_errors,all_combination_errors,'lineStyle','none','color','black');
set(gca,'xtick',0.15+(1:3),'xticklabel',ROIs);
ylabel('beta combination')
%  s=hgexport('readstyle','presentation');
% s.Format = 'png';
% s.Width = 12;
% s.Height = 6;
% hgexport(fig,fullfile('figures',['all_combinations_',metric]),s);
saveas(gca,fullfile('figures',['all_combinations_',metric,'.png']))



end


