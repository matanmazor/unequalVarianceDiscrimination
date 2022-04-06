excludeSubjects();

subj_list = good_ss;

load('project_params')
roi_list = { ...
% 			'preSMA',...
%             'rTPJ',...
%             'rSTS',...
%             'union_FPl',...
%             'union_FPm',...
%             'union_46'
              'insulaFromConfSqTaskF'
			};
for i_s = 1:length(subj_list)
    
    subj_id = [subj_list{i_s}];
    
    if ~exist(fullfile('ROIs',subj_id),'dir')
        mkdir(fullfile('ROIs',subj_id))
    end
    
    for i_r = 1:length(roi_list)
        AlignROI(...
            fullfile(project_params.stats_dir,'DM2555',subj_id,'beta_0001.nii'),...
            fullfile('ROIs',[roi_list{i_r},'.nii']),...
            fullfile('ROIs',subj_id,[roi_list{i_r},'.nii']));
    end
end
   