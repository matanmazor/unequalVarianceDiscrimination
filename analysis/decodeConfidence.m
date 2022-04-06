addpath(project_params.spm_dir);
ROI_dir = fullfile(fileparts(project_params.stats_dir), 'analysis','ROIs');
ROI_names = {'union_FPl','union_FPm','union_46','vmPFC','rTPJ','rSTS','preSMA', 'ventricles'};
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

p = project_params;

group_accuracy = nan(numel(ROI_names),49);

for i_s = which_subjects
    
    %only analyze participants with 4 or 5 usable runs
    %check which runs are relevant
    exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','exclusion.txt'));
    
    conf_exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','conf_exclusion.txt'));
    
    relevant_runs = find(exclusion_file==0 & conf_exclusion_file==0);
    
    fprintf('participant %s will be analyzed because it has %d usable runs\n',...
        subj{i_s}.scanid, length(relevant_runs))
    fprintf('This is participant number %d for this analysis\n', sum(~isnan(group_accuracy(1,:)))+1)
    SPM_dir = fullfile(p.stats_dir, 'DM101_unsmoothed',['sub-',subj{i_s}.scanid]);
    TDT_dir = fullfile(SPM_dir,'TDT');
    if exist(TDT_dir) ~= 7
        mkdir(TDT_dir);
    end

    % reslice masks
    ROIs = {};
    for i_mask = 1:length(ROI_names)
        ROI_name = ROI_names{i_mask};
        if ~exist(fullfile(TDT_dir,[ROI_name,'.nii']))
            spm_jobman('initcfg');

            matlabbatch{1}.spm.util.imcalc.input = {
                fullfile(SPM_dir,'beta_0001.nii,1')
                fullfile(ROI_dir,[ROI_name,'.nii,1'])
                };
            matlabbatch{1}.spm.util.imcalc.output = ROI_name;
            matl8abbatch{1}.spm.util.imcalc.outdir = {TDT_dir};
            matlabbatch{1}.spm.util.imcalc.expression = 'i2>0.5';
            matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{1}.spm.util.imcalc.options.mask = 0;
            matlabbatch{1}.spm.util.imcalc.options.interp = 1;
            matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

            spm_jobman('run',matlabbatch);
            movefile([ROI_name,'.nii'],fullfile(TDT_dir,[ROI_name,'.nii']));
        end
        ROIs{i_mask} = fullfile(TDT_dir,[ROI_name,'.nii']);
    end

    cfg = decoding_defaults;
    regressor_names = design_from_spm(SPM_dir);
    cfg = decoding_describe_data(cfg,{'high_correct',...
        'low_correct'},[1 -1],regressor_names,SPM_dir);
    cfg.files.mask = ROIs;
    cfg.analysis = 'ROI';
    cfg.results.overwrite = 1;
    cfg.design = make_design_cv(cfg);
    cfg.results.output = {'accuracy_minus_chance', ...
        'sensitivity','specificity','AUC_minus_chance'};
    cfg.decoding.method = 'classification';
    cfg.results.dir = fullfile(SPM_dir,'TDT');
    cfg.verbose = 0;
    results = decoding(cfg);
    group_accuracy(:,i_s) = results.accuracy_minus_chance.output;
        results.accuracy_minus_chance.output'
               
        
end