function [] = compareOnOffDiagonal_gm(project_params,which_subjects,metric)

addpath('D:\Documents\software\cbrewer') %for color
[cb] = cbrewer('qual','Set1',10,'pchip');
base_dir = fullfile('..','analyzed','DM6_unsmoothed','group','rsa_gm',metric);
Models = modelRDMs();

ROIs = {'FPl','FPm','BA46','vmPFC','rTPJ','rSTS','preSMA'};


for i_ROI = 1:7
    
    ROI = ROIs{i_ROI}
    onDiagonal = nan(max(which_subjects),1);
    offDiagonal = nan(max(which_subjects),1);

    load(fullfile(base_dir,[ROI,'_RDM.mat']))
    
    for i_s = which_subjects
        
        subj_RDM = squeeze(RDM(:,:,i_s));
        rank_RDM = reshape(tiedrank(subj_RDM(:)),size(subj_RDM,1),size(subj_RDM,2));
        onDiagonal(i_s)=mean(rank_RDM(logical(eye(size(subj_RDM,1)))));
        offDiagonal(i_s)=mean(rank_RDM(~logical(eye(size(subj_RDM,1)))));

    end

    save(fullfile(base_dir,[ROI,'_OnOffDiagonal.mat']),'onDiagonal', 'offDiagonal');
    [h,p,ci,stats]=ttest(onDiagonal-offDiagonal)
    
    
end
end

