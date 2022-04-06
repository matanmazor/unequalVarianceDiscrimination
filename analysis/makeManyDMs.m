function [] = makeManyDMs(project_params, which_subjects, DM)

load(fullfile(project_params.raw_dir,'subject_details.mat'));
unprocessed_dir = fullfile(fileparts(project_params.raw_dir), 'data');
func = eval(['@tsv2DM',num2str(DM)]);

for s = which_subjects
    
    files = dir(fullfile(unprocessed_dir,['sub-',subj{s}.scanid],'func','*.tsv'));
    
    for i =1:length(files)
        
        func(fullfile(unprocessed_dir,['sub-',subj{s}.scanid],'func',files(i).name))
        
        DM_file = dir(fullfile(unprocessed_dir,['sub-',subj{s}.scanid],...
            'func',['*DM',num2str(DM),'.mat']));
       
        if ~exist(fullfile(project_params.data_dir, ['sub-',subj{s}.scanid], 'DM'),'dir')
            mkdir(fullfile(project_params.data_dir, ['sub-',subj{s}.scanid], 'DM'))
        end
        
        movefile(fullfile(unprocessed_dir,['sub-',subj{s}.scanid],'func',DM_file(1).name),...
        fullfile(project_params.data_dir, ['sub-',subj{s}.scanid], 'DM', ...
        ['run-',num2str(i),'_DM',num2str(DM),'.mat']));  
        
    end
end
end