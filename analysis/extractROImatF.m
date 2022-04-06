function extractROImatF(project_params, which_subjects, DM, coordinates, ROI_name, cov)
% Exctract a vector of mean values inside a sphere across subjects, for
% each contrast.

load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

if nargin<6
    cov = '';
end

fs = filesep;
p = project_params;

load(fullfile(p.stats_dir, ['DM',num2str(DM)],'F.mat'));



for j = 1:length(F.contrasts)
    
    contrastFolder = fullfile(p.stats_dir,['DM',num2str(DM)],'group',['F_',F.contrasts{j}]);
    fprintf('computing contrast vector for contrast %s \n',F.contrasts{j})
    % if the intended resultsFolder directory does not exits, make it and go into it
    if exist(contrastFolder,'dir') ~= 7
        mkdir(contrastFolder);
        cd(contrastFolder);
    end
        
    ROI_matrix = [];
    scans = F.scans{j};
    for i_scan=1:length(scans)
        scan_vec = load(fullfile(p.stats_dir,['DM',num2str(DM)],'group',scans{i_scan},[ROI_name,'.mat']));
        ROI_matrix = [ROI_matrix scan_vec.ROI_vec];
    end
  
    
    save(fullfile(contrastFolder,[ROI_name,'.mat']),'ROI_matrix');
end
end