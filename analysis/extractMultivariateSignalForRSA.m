function [] = extractMultivariateSignalForRSA(spm_dir,mask,ROI_name)
% Exctract 12 matrices, one for each condition. Each matrix is 6 (maximum
% number of runs per subject)xnumber of voxels in the mask, and represents
% the beta values for this condition in this specific run.

mask_matrix = niftiread(mask);
voxel_indices = find(mask_matrix(:)~=0);
num_voxels = length(voxel_indices);

conditions = {'C_H','C_L','A_H','A_L',...
    'Y_H','Y_L','N_H','N_L',...
    'T_H','T_L','V_H','V_L'};

BOLD = containers.Map;
for i=1:12
    BOLD(conditions{i})=nan(6,num_voxels);
end

subj_spm = load(fullfile(spm_dir, 'SPM.mat'));
regressor_names = subj_spm.SPM.xX.name;
num_regressors = length(regressor_names);

for i_r = 1:num_regressors
    
    regressor_name = regressor_names{i_r};
    
    matchexp = regexp(regressor_name, ...
    'Sn\((?<run_num>\d+)\) (?<trial>.+)',...
    'names');

    %is this a relevant regressor?
    if (any(strcmp({'C','A','Y','N','T','V'},matchexp.trial(1))) & ...
            any(strcmp({'H','L'},matchexp.trial(3))))

        run_num = str2num(matchexp.run_num);
        map = niftiread(fullfile(spm_dir, sprintf('beta_%04d.nii',i_r)));
        flat_map = map(:);
        activation_within_mask = flat_map(voxel_indices);

        activations = BOLD(matchexp.trial(1:3));
        activations(run_num,:)=activation_within_mask';
        BOLD(matchexp.trial(1:3)) = activations;
    
    end
    
end

if ~exist(fullfile(spm_dir,'rsa'))
    mkdir(fullfile(spm_dir,'rsa'));
end
save(fullfile(spm_dir,'rsa',[ROI_name,'_bold.mat']),'BOLD') 

end