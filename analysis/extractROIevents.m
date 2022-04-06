function extractROIevents(project_params,which_subjects,coordinates, ROI_name)
% Exctract a vector of mean values inside a sphere across subjects, for
% each contrast.

addpath(project_params.spm_dir);
load(fullfile(project_params.raw_dir,'subject_details.mat'));
cwd = pwd;

fs = filesep;
p = project_params;

for i_s = which_subjects
    
    fprintf('extracting betas for participant %s\n\n',subj{i_s}.scanid);
    % how many runs?
    exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','exclusion.txt'));
    conf_exclusion_file = csvread(fullfile(p.data_dir, ...
        ['sub-',subj{i_s}.scanid],'func','conf_exclusion.txt'));
    
    blockNo = sum(exclusion_file==0&conf_exclusion_file==0);
    usable_runs = find(exclusion_file==0&conf_exclusion_file==0);
    
    if blockNo ==0
        continue
    else
        spmmat = fullfile(p.stats_dir,...
            'DM200',['sub-',subj{i_s}.scanid],'SPM.mat');
        load(spmmat);
        names = SPM.xX.name;
        
        [mean_beta_vec,task_vec,stimulus_vec,response_vec,...
            RT_vec,confidence_vec, id, npress_vec, include_vec] = deal([]);
        type_vec = {};
        
        run_number=0;
        trial_number=1;
        
        for i_b = 1:numel(names)
            
            regressor_name =names{i_b};
            
            %is this a trial?
            if regexp(regressor_name,'response_(?<response>\d+)')
                
                %extract trial information from regressor name
                matchexp = regexp(regressor_name, ...
                    strcat('Sn\((?<run_num>\d+)\) (?<trial_type>\w+)_task_(?<task>\d+)',...
                    '_stimulus_(?<stimulus>\d+)_response_(?<response>\d+)',...
                    '_confidence_(?<confidence>\d+)_RT_(?<RT>\d+.\d+)_id_(?<id>\d+)',...
                    '_include_(?<include>\d+)'),...
                    'names');
                
                
                task_vec(end+1) = str2num(matchexp.task);
                stimulus_vec(end+1) = str2num(matchexp.stimulus);
                response_vec(end+1) = str2num(matchexp.response);
                confidence_vec(end+1) = str2num(matchexp.confidence);
                RT_vec(end+1) = str2num(matchexp.RT);
                id(end+1) = str2num(matchexp.id);
                type_vec{end+1} = matchexp.trial_type;
                include_vec(end+1) = str2num(matchexp.include);
                
                if str2num(matchexp.run_num)~=run_number
                    
                    run_number = str2num(matchexp.run_num);
                    trial_number=1;
                    
                    %extract number of left hand button presses
                    events_file = fullfile(project_params.data_dir,'..','data',...
                        ['sub-',subj{i_s}.scanid],'func',...
                        ['sub-',subj{i_s}.scanid,'_task-unequalVariance_run-0',...
                        num2str(usable_runs(run_number)),'_events.tsv']);
                    
                    table = tdfread(events_file,'\t');
                    
                    trial_rows = find(table.duration>0);
                    trial_rows(end+1)=length(table.onset);

                end
                
                % check that the trial I am looking at is the right trial
                
                while strcmp(table.trial_type(trial_rows(trial_number),:),'missed_trial')
                    trial_number = trial_number+1;
                    
                end
                i_t = trial_rows(trial_number);
                i_t_next = trial_rows(trial_number+1);
                sanity_check = strcmp(matchexp.task,table.task(i_t)) &...
                    strcmp(matchexp.trial_type,table.trial_type(i_t,1:2)) & ...
                    strcmp(matchexp.confidence,table.confidence(i_t));
                if ~sanity_check
                    error('misalignment between table and beta name')
                end
                
                %count presses
                num_presses = sum(str2num(table.key_id(i_t+1:i_t_next-1,2))>1);
                npress_vec(end+1) = num_presses;
                
                trial_number = trial_number+1;

                
                %extract mean beta
                beta_file = fullfile(p.stats_dir,...
                    'DM200',['sub-',subj{i_s}.scanid],sprintf('beta_%.04d.nii',i_b));
                
                if length(coordinates)==3
                    mean_beta_vec(end+1) = spm_summarise(beta_file,...
                        struct('def','sphere', 'spec',8, 'xyz',coordinates'),@nanmean);
                else
                    mean_beta_vec(end+1) = spm_summarise(beta_file,...
                        struct('def','mask', 'spec',coordinates),@nanmean);
                end
                
            end
        end
        
        
        save(fullfile(p.stats_dir,...
            'DM200',['sub-',subj{i_s}.scanid],strcat(ROI_name,'.mat')),...
            'mean_beta_vec', 'task_vec','stimulus_vec','response_vec',...
            'RT_vec','confidence_vec', 'id', 'include_vec',...
            'type_vec', 'npress_vec','coordinates');
        
    end
end


end