function [] = extractROIFs(project_params, which_subjects, DM)

extractROImatF(project_params,which_subjects,DM,[0,46,-7],'vmPFC');

extractROImatF(project_params,which_subjects,DM,...
    'ROIs\union_FPl.nii','FPl');

extractROImatF(project_params,which_subjects,DM,...
    'ROIs\union_FPm.nii','FPm');

extractROImatF(project_params,which_subjects,DM,...
    'ROIs\union_46.nii','BA46');

extractROImatF(project_params,which_subjects,DM,...
    'ROIs\preSMA.nii','preSMA');

extractROImatF(project_params,which_subjects,DM,...
    'ROIs\rTPJ.nii','rTPJ');

extractROImatF(project_params,which_subjects,DM,...
    'ROIs\rSTS.nii','rSTS');

addpath(project_params.spm_dir);
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

fs = filesep;
p = project_params;

load(fullfile(p.stats_dir, ['DM',num2str(DM)],'F.mat'));

ROIs = {'FPl','FPm','BA46','vmPFC','rTPJ','rSTS','preSMA'};

for j = 1:length(F.contrasts)
    
    contrastFolder = fullfile(p.stats_dir,['DM',num2str(DM)],'group',['F_',F.contrasts{j}]);
    
    for i_roi = 1:numel(ROIs)
        cur = load(fullfile(contrastFolder,ROIs{i_roi}));
        [ps,tbl]=anova2(cur.ROI_matrix,1)
        F_values(i_roi) = tbl{2,5};
        p_values(i_roi) = tbl{2,6};
        
    end
    roi_table = table(ROIs', F_values',p_values','VariableNames',...
        {'region','F_value','p_value'});
    
    writetable(roi_table, fullfile(contrastFolder,'ROIs.csv'))
       
end
end

