addpath(project_params.spm_dir);
ROI_dir = fullfile(fileparts(project_params.stats_dir), 'analysis','ROIs');
ROI_names = {'union_FPl','union_FPm','union_46','vmPFC','rTPJ','rSTS','preSMA', 'pMFC','ventricles'};
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

p = project_params;

group_accuracy_cross_YN1 = nan(numel(ROI_names),49);
group_accuracy_cross_YN2 = nan(numel(ROI_names),49);

group_accuracy_cross_TV1 = nan(numel(ROI_names),49);
group_accuracy_cross_TV2 = nan(numel(ROI_names),49);

group_accuracy_YN = nan(numel(ROI_names),49);
group_accuracy_TV = nan(numel(ROI_names),49);

for i_s = which_subjects
    
   
    %only analyze participants with 4 or 5 usable runs
    %check which runs are relevant
    exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','exclusion.txt'));
    
    conf_exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','conf_exclusion.txt'));
    
    relevant_runs = find(exclusion_file==0 & conf_exclusion_file==0);

        fprintf('participant %s will be analyzed because it has %d usable runs \n',...
            subj{i_s}.scanid, length(relevant_runs));
        fprintf('This is participant number %d for this analysis \n', sum(~isnan(group_accuracy_cross_YN1(1,:)))+1);
        SPM_dir = fullfile(p.stats_dir, 'DM103_unsmoothed',['sub-',subj{i_s}.scanid]);
        cross_YN1_dir = fullfile(SPM_dir,'TDT_TrainYNTestDis');
        cross_YN2_dir = fullfile(SPM_dir,'TDT_TrainDisTestYN');
        cross_TV1_dir = fullfile(SPM_dir,'TDT_TrainTVTestDis');
        cross_TV2_dir = fullfile(SPM_dir,'TDT_TrainDisTestTV');        
        dis_dir = fullfile(SPM_dir,'TDT_dis');
        YN_dir = fullfile(SPM_dir,'TDT_YN');
        TV_dir = fullfile(SPM_dir,'TDT_TV');
        roi_dir = fullfile(p.stats_dir, 'DM101_unsmoothed',['sub-',subj{i_s}.scanid], 'TDT');
        
        dirs_to_make = {cross_YN1_dir, cross_YN2_dir, cross_TV1_dir, ...
            cross_TV2_dir, dis_dir,YN_dir, TV_dir};
        
        for i=1:length(dirs_to_make)
            if exist(dirs_to_make{i}) ~= 7
                mkdir(dirs_to_make{i});
            end
        end
        
       
        ROIs = {};
        for i_mask = 1:length(ROI_names)
            ROI_name = ROI_names{i_mask};
            ROIs{i_mask} = fullfile(roi_dir,[ROI_name,'.nii']);
        end
       
        %%% Train on detection, test on discrimination
        regressor_names = design_from_spm(SPM_dir);
        cfg = decoding_defaults;
        cfg = decoding_describe_data(cfg,{'det_hit','det_CR','dis_high_correct',...
            'dis_low_correct'},[1 -1 1 -1],regressor_names,SPM_dir,[1 1 2 2]);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = cross_YN1_dir;
        vfg.verbose = 0;
        results1 = decoding(cfg);
        
        group_accuracy_cross_YN1(:,i_s) = results1.accuracy_minus_chance.output;
        results1.accuracy_minus_chance.output'
        
        %%%% Train on discrimination, test on detection
        cfg = decoding_defaults;
        cfg = decoding_describe_data(cfg,{'dis_high_correct',...
            'dis_low_correct', 'det_hit','det_CR'},...
            [1 -1 1 -1],regressor_names,SPM_dir,[1 1 2 2]);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = cross_YN2_dir;
        vfg.verbose = 0;
        results2 = decoding(cfg);
        
        group_accuracy_cross_YN2(:,i_s) = results2.accuracy_minus_chance.output;
        results2.accuracy_minus_chance.output'
        
         %%% Train on tilt, test on discrimination
        cfg = decoding_defaults;
        regressor_names = design_from_spm(SPM_dir);
        cfg = decoding_describe_data(cfg,{'tilt_TT','tilt_VV','dis_high_correct',...
            'dis_low_correct'},[1 -1 1 -1],regressor_names,SPM_dir,[1 1 2 2]);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = cross_TV1_dir;
        vfg.verbose = 0;
        results3 = decoding(cfg);
        
        group_accuracy_cross_TV1(:,i_s) = results3.accuracy_minus_chance.output;
        results3.accuracy_minus_chance.output'
        
        %%%% Train on discrimination, test on tilt
        cfg = decoding_defaults;
        cfg = decoding_describe_data(cfg,{'dis_high_correct',...
            'dis_low_correct', 'tilt_TT','tilt_VV',},...
            [1 -1 1 -1],regressor_names,SPM_dir,[1 1 2 2]);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_xclass_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = cross_YN2_dir;
        vfg.verbose = 0;
        results4 = decoding(cfg);
        
        group_accuracy_cross_TV2(:,i_s) = results4.accuracy_minus_chance.output;
        results4.accuracy_minus_chance.output'
        
        %%%% YN
        cfg = decoding_defaults;
        cfg = decoding_defaults;
        cfg = decoding_describe_data(cfg,{'det_hit','det_CR'},...
            [1 -1],regressor_names,SPM_dir);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = YN_dir;
        vfg.verbose = 0;
        results5 = decoding(cfg);
        
        group_accuracy_YN(:,i_s) = results5.accuracy_minus_chance.output;
        results5.accuracy_minus_chance.output'
        
        %%%% TV
        cfg = decoding_defaults;
        cfg = decoding_describe_data(cfg,{'tilt_TT','tilt_VV'},...
            [1 -1],regressor_names,SPM_dir);
        cfg.files.mask = ROIs;
        cfg.analysis = 'ROI';
        cfg.results.overwrite = 1;
        cfg.design = make_design_cv(cfg);
        cfg.results.output = {'accuracy_minus_chance', ...
            'sensitivity','specificity','AUC_minus_chance'};
        cfg.decoding.method = 'classification';
        plot_design(cfg);
        cfg.results.dir = TV_dir;
        vfg.verbose = 0;
        results6 = decoding(cfg);
        
        group_accuracy_TV(:,i_s) = results6.accuracy_minus_chance.output;
        results6.accuracy_minus_chance.output'        
        close all
end