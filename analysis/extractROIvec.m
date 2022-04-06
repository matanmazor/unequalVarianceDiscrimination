function extractROIvec(project_params, which_subjects, DM, coordinates, ROI_name, cov)
% Exctract a vector of mean values inside a sphere across subjects, for
% each contrast.

addpath(project_params.spm_dir);
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

if nargin<6
    cov = '';
end

fs = filesep;
p = project_params;

load(fullfile(p.stats_dir, ['DM',num2str(DM)],'T.mat'));
if numel(T.contrasts)~=size(T.contrastVectors,1)
    error('number of contrast names does not match number of contrasts')
end


for j = 1:length(T.contrasts)
    
    contrastFolder = fullfile(p.stats_dir,['DM',num2str(DM)],'group',T.contrasts{j});
    fprintf('computing contrast vector for contrast %s \n',T.contrasts{j})
    % if the intended resultsFolder directory does not exits, make it and go into it
    if exist(contrastFolder,'dir') ~= 7
        mkdir(contrastFolder);
        cd(contrastFolder);
    end
    
    conImg = sprintf('con_%04d.nii,1',j);
    
    ROI_vec = nan(length(which_subjects),1);
    i=1;
    for i_s = which_subjects  % select con image from every subject
        spmDir = fullfile(p.stats_dir,['DM',num2str(DM)],['sub-',subj{i_s}.scanid]);
        subj_SPM = load(fullfile(spmDir,'SPM.mat'));
        if numel(subj_SPM.SPM.xCon)>0
            subj_contrasts = {subj_SPM.SPM.xCon.name};
        else
            subj_contrasts = {};
        end
        if any(strcmp(subj_contrasts,T.contrasts{j}))
            conImg = sprintf('con_%04d.nii,1',find(strcmp(subj_contrasts,T.contrasts{j})));
            if length(coordinates)==3
                ROI_vec(i) = ...
                    spm_summarise(fullfile(spmDir,conImg),...
                    struct('def','sphere', 'spec',8, 'xyz',coordinates'),@nanmean);
            else
                ROI_vec(i) = ...
                    spm_summarise(fullfile(spmDir,conImg),...
                    struct('def','mask', 'spec',coordinates),@nanmean);        
            end
        else
             ROI_vec(i) = nan;
        end
        i=i+1;
    end
    
    save(fullfile(contrastFolder,[ROI_name,'.mat']),'ROI_vec');
end
end