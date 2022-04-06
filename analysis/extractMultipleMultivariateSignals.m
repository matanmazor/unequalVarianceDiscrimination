% clc;
% clear;
% close all;
% 
% excludeSubjects();
% load('project_params.mat');
% load(fullfile(project_params.raw_dir,'subject_details.mat'));

base_dir = '..\analyzed\DM2_unsmoothed';
base_masks_dir = '..\analyzed\DM101_unsmoothed';

for i_s=which_subjects
    
    subj_id=participants.participant_id{i_s};
    spm_dir = fullfile(base_dir,subj_id);
    mask_dir = fullfile(base_masks_dir,subj_id,'TDT');
    
    extractMultivariateSignalForRSA(spm_dir,fullfile(mask_dir,'vmPFC.nii'),'vmPFC');
    extractMultivariateSignalForRSA(spm_dir,fullfile(mask_dir,'union_FPl.nii'),'FPl');
    extractMultivariateSignalForRSA(spm_dir,fullfile(mask_dir,'union_FPm.nii'),'FPm');
    extractMultivariateSignalForRSA(spm_dir,fullfile(mask_dir,'union_46.nii'),'BA46');
    extractMultivariateSignalForRSA(spm_dir,fullfile(mask_dir,'preSMA.nii'),'preSMA');
    extractMultivariateSignalForRSA(spm_dir,fullfile(mask_dir,'rTPJ.nii'),'rTPJ');
    extractMultivariateSignalForRSA(spm_dir,fullfile(mask_dir,'rSTS.nii'),'rSTS');

end
