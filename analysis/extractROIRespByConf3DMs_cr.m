function [conf_C, conf_A, conf_Y, conf_N, conf_T, conf_V] = extractROIRespByConf3DMs_cr(project_params,which_subjects,coordinates, ROI_name)
% Exctract four matrices with the mean activation for responsexconfidence
% level within this region.

if nargin==3
    ROI_name = 'dontSaveMe';
end

addpath(project_params.spm_dir);
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

fs = filesep;
p = project_params;

[conf_C, conf_A, conf_Y, conf_N, conf_T, conf_V] = deal(nan(numel(which_subjects),6));

row_number = 1;
for i_s = which_subjects
    
    fprintf('extracting betas for participant %s\n\n',subj{i_s}.scanid);
    % how many runs?
    exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','exclusion.txt'));
    conf_exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','conf_exclusion.txt'));
    
    blockNo = sum(exclusion_file==0&conf_exclusion_file==0);
    
    if blockNo ==0
        continue
    else
        conf_mat = nan(7,5,6); %resp(C,A,Y,N,T,V,dummy) x session x confidence level
        % the dummy is there just so that I don't confuse the response
        % dimension with the confidence dimension.

        for DM_num = [10555,11555,12555]
            spmmat = fullfile(p.stats_dir,...
            ['DM',num2str(DM_num)],['sub-',subj{i_s}.scanid],'SPM.mat');
            load(spmmat);
            names = SPM.xX.name;


            for i_b = 1:numel(names)

                regressor_name =names{i_b};

                %is this a trial?
                if regexp(regressor_name,'trialx')

                    %extract trial information from regressor name
                    matchexp = regexp(regressor_name, ...
                        'Sn\((?<run_num>\d+)\) trialx(?<resp>\w)(?<conf_level>\d+)',...
                        'names');

                    run_num = str2num(matchexp.run_num);
                    resp = strfind('CAYNTV',matchexp.resp);
                    conf_level = str2num(matchexp.conf_level);
                    

                        %extract mean beta
                        beta_file = fullfile(p.stats_dir,...
                            ['DM',num2str(DM_num)],['sub-',subj{i_s}.scanid],sprintf('beta_%.04d.nii',i_b));

                        if length(coordinates)==3 && ~strcmp(ROI_name, 'dontSaveMe')
                            conf_mat(resp,run_num,conf_level) = spm_summarise(beta_file,...
                                struct('def','sphere', 'spec',8, 'xyz',coordinates'),@nanmean);
                        else 
                            conf_mat(resp,run_num,conf_level) = spm_summarise(beta_file,...
                                struct('def','mask', 'spec',coordinates),@nanmean);
                        end

                end
            end
        end
    end
    
    conf_C(row_number, :) = nanmean(squeeze(conf_mat(1,:,:)));
    conf_A(row_number, :) = nanmean(squeeze(conf_mat(2,:,:)));
    conf_Y(row_number, :) = nanmean(squeeze(conf_mat(3,:,:)));
    conf_N(row_number, :) = nanmean(squeeze(conf_mat(4,:,:)));
    conf_T(row_number, :) = nanmean(squeeze(conf_mat(5,:,:)));
    conf_V(row_number, :) = nanmean(squeeze(conf_mat(6,:,:)));

    row_number = row_number+1;
    
end

if ~strcmp(ROI_name, 'dontSaveMe')
    save(fullfile(p.stats_dir,'DM10555','group',ROI_name),...
    'conf_C','conf_A','conf_Y','conf_N', 'conf_T', 'conf_V')

    save(fullfile(p.stats_dir,'DM11555','group',ROI_name),...
    'conf_C','conf_A','conf_Y','conf_N', 'conf_T', 'conf_V')

    save(fullfile(p.stats_dir,'DM12555','group',ROI_name),...
    'conf_C','conf_A','conf_Y','conf_N', 'conf_T', 'conf_V')
end
end