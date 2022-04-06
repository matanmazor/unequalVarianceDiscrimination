addpath('D:\Documents\software\cbrewer') %for color
[cb] = cbrewer('qual','Set1',10,'pchip');
base_dir = fullfile('..','analyzed','DM2_unsmoothed','group','rsa','euclidean');

% ROIs = {'FPl','FPm','BA46','vmPFC','rTPJ','rSTS','preSMA'};
ROIs = {'BA46','vmPFC','rSTS'};

RDMs = {'task','varianceStructure','detection','unequal_variane',...
        'confidence','conf_x_var','conf_detection','conf_x_uv'};
all_data = [];

for i_roi = 1:length(ROIs)
    
    ROI_file = load(fullfile(base_dir,[ROIs{i_roi},'_SpearmanCorrelations.mat']));
    all_data = cat(3,all_data,ROI_file.correlations(:,1:8));
    
end

means = squeeze(nanmean(all_data,1));
errors = squeeze(nanstd(all_data,1))./sqrt(squeeze(sum(~isnan(all_data),1)));
ds = means./squeeze(nanstd(all_data,1));
best_RDM = ds==max(ds);

for i_RDM = 1:length(RDMs)
    fig = figure;
    hold on;
    h = bar(1:3,means(i_RDM,:),'FaceColor','flat');
    h.CData=repmat([1,1,1],3,1);
    errorbar(1:3,means(i_RDM,:),errors(i_RDM,:),errors(i_RDM,:),'lineStyle','none','color','black');
    xlim([0.5,3.5]); 
    ylim([-0.1,0.1]);
    ylabel('Spearman correlation');
    % ylim([0.4,1]);
    set(gca,'xtick',1:3,'xticklabel',ROIs)
    xtickangle(45);
    best_indices = find(best_RDM(i_RDM,:)==1);
    if length(best_indices)>0
        h.CData(best_indices,:)=repmat([0.7,0.8,1],length(best_indices),1);
    end
    fig = gcf;
    s=hgexport('readstyle','presentation');
    s.Format = 'png';
    s.Width = 8;
    s.Height = 8;
    hgexport(fig,fullfile('figures',[RDMs{i_RDM},'_','correlations_euclidean']),s);
end