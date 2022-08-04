function [] = extractROIcsvs(project_params, which_subjects, DM)

extractROIcsv(project_params,which_subjects,DM,[0,46,-7],'vmPFC');

extractROIcsv(project_params,which_subjects,DM,...
    'ROIs\union_FPl.nii','FPl');

extractROIcsv(project_params,which_subjects,DM,...
    'ROIs\union_FPm.nii','FPm');

extractROIcsv(project_params,which_subjects,DM,...
    'ROIs\union_46.nii','BA46');

extractROIcsv(project_params,which_subjects,DM,...
    'ROIs\preSMA.nii','preSMA');

extractROIcsv(project_params,which_subjects,DM,...
    'ROIs\rTPJ.nii','rTPJ');

extractROIcsv(project_params,which_subjects,DM,...
    'ROIs\rSTS.nii','rSTS');

end

