addpath(project_params.spm_dir);
ROI_names = {'union_FPl','union_FPm','union_46','vmPFC','rTPJ','rSTS','preSMA', 'ventricles'};
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

p = project_params;

group_accuracy_detection = nan(numel(ROI_names),49);
group_accuracy_discrimination = nan(numel(ROI_names),49);
group_accuracy_tilt = nan(numel(ROI_names),49);

for i_s = which_subjects
    
    %only analyze participants with 4 or 5 usable runs
    %check which runs are relevant
    exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','exclusion.txt'));
    
    conf_exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','conf_exclusion.txt'));
    
    relevant_runs = find(exclusion_file==0 & conf_exclusion_file==0);
    
%     if length(relevant_runs)<4
%         fprintf('participant %s cannot be analyzed because it only has %d usable runs',...
%             subj{i_s}.scanid, length(relevant_runs));
%         continue
%     else
        fprintf('participant %s will be analyzed because it has %d usable runs',...
            subj{i_s}.scanid, length(relevant_runs));
        fprintf('This is participant number %d for this analysis', sum(~isnan(group_accuracy_detection(1,:)))+1);
        SPM_dir = fullfile(p.stats_dir, 'DM102_unsmoothed',['sub-',subj{i_s}.scanid]);
        det_dir = fullfile(SPM_dir,'TDT_det');
        dis_dir = fullfile(SPM_dir,'TDT_dis');
        tilt_dir = fullfile(SPM_dir,'TDT_dis');

        roi_dir = fullfile(p.stats_dir, 'DM101_unsmoothed',['sub-',subj{i_s}.scanid], 'TDT');
        
        if exist(det_dir) ~= 7
            mkdir(det_dir);
        end
        
        if exist(dis_dir) ~= 7
            mkdir(dis_dir);
        end
        
        if exist(tilt_dir) ~= 7
            mkdir(tilt_dir);
        end
        % reslice masks
        ROIs = {};
        for i_mask = 1:length(ROI_names)
            ROI_name = ROI_names{i_mask};
            if ~exist(fullfile(dis_dir,[ROI_name,'.nii']))
                copyfile(fullfile(roi_dir,[ROI_name,'.nii']),fullfile(dis_dir,[ROI_name,'.nii']));
            end
            ROIs{i_mask} = fullfile(dis_dir,[ROI_name,'.nii']);
        end
        
        cfg = decoding_defaults;
        regressor_names = design_from_spm(SPM_dir);
        cfg = decoding_describe_data(cfg,{'dis_high_correct',...
            'dis_low_correct'},[1 -1],regressor_names,SPM_dir);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.results.dir = dis_dir;
        vfg.verbose = 0;
        if sum(cfg.design.label(:)==1)==sum(cfg.design.label(:)==-1)
          [results,cfg] = decoding(cfg);
          group_accuracy_discrimination(:,i_s) = results.accuracy_minus_chance.output;
        end
%         close all;
%         cfg.design = make_design_permutation(cfg,1000,1);
%         [reference,cfg]=decoding(cfg);
%         cfg.stats.test = 'permutation';
%         cfg.stats.tail = 'right';
%         cfg.stats.output = 'accuracy_minus_chance';
%         p_values = decoding_statistics(cfg,results,reference);
%         p_values(p_values == 1) = (cfg.design.n_sets*2-1)/(cfg.design.n_sets*2);
%         
%         group_accuracy_discrimination(:,i_s) = max(norminv(1-p_values),-6);
%         max(norminv(1-p_values)',-6)
         
         
        cfg = decoding_defaults;
        regressor_names = design_from_spm(SPM_dir);
        cfg = decoding_describe_data(cfg,{'det_high_correct',...
            'det_low_correct'},[1 -1],regressor_names,SPM_dir);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.results.dir = det_dir;
        vfg.verbose = 0;
        if sum(cfg.design.label(:)==1)==sum(cfg.design.label(:)==-1)
          [results,cfg] = decoding(cfg);
          group_accuracy_detection(:,i_s) = results.accuracy_minus_chance.output;
        end
        
        cfg = decoding_defaults;
        regressor_names = design_from_spm(SPM_dir);
        cfg = decoding_describe_data(cfg,{'tilt_high_correct',...
            'tilt_low_correct'},[1 -1],regressor_names,SPM_dir);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.results.dir = tilt_dir;
        vfg.verbose = 0;
        if sum(cfg.design.label(:)==1)==sum(cfg.design.label(:)==-1)
          [results,cfg] = decoding(cfg);
          group_accuracy_tilt(:,i_s) = results.accuracy_minus_chance.output;
        end


%         dis_results = decoding_example('ROI','dis_high_correct','dis_low_correct',...
%             SPM_dir,...
%             dis_dir,...
%             [],cfg);
%         
%         group_accuracy_discrimination(:,i_s) = dis_results.accuracy_minus_chance.output;
%         dis_results.accuracy_minus_chance.output'
%         
%         det_results = decoding_example('ROI','det_high_correct','det_low_correct',...
%             SPM_dir,...
%             det_dir,...
%             [],cfg);
%         
%         group_accuracy_detection(:,i_s) = det_results.accuracy_minus_chance.output;
%         det_results.accuracy_minus_chance.output'
%         
%     end
    close all
    
end