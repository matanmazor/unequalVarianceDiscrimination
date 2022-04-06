% addpath('D:\Documents\software\FIL2BIDS');
load('project_params.mat');
load('..\data\raw_data\subject_details.mat');
addpath(project_params.spm_dir)
excludeSubjects();


for i_s=which_subjects

    raw_dirs = cellstr(ls(project_params.raw_dir));
            indexC = strfind(raw_dirs, subj{i_s}.scanid);
            index = find(not(cellfun('isempty', indexC)));



    FIL2BIDS(fullfile('..','data','raw_data',raw_dirs{index}), ...
        fullfile('..','data','data',['sub-',subj{i_s}.scanid]),...
        {'func','fmap','anat'},...
        {subj{i_s}.functional, [subj{i_s}.fieldmaps(1,1),subj{i_s}.fieldmaps(1,2)], subj{i_s}.structural}...
        )
    
end

%fix issue with how the FIL register TR
func_files = dir('..\data\openNeuro\*\*\*_bold.nii')

for i=1:length(func_files)
    i
    info = niftiinfo(fullfile(func_files(i).folder,func_files(i).name));
    info.PixelDimensions(4)=3.360;
    image = niftiread(fullfile(func_files(i).folder,func_files(i).name)); 
    niftiwrite(image,fullfile(func_files(i).folder,func_files(i).name),info);
end

