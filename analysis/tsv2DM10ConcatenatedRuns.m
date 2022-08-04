excludeSubjects;
load('project_params.mat')
which_blocks = toExclude+toExcludeFromConfAnalyses==0;
unprocessed_dir = fullfile(fileparts(project_params.raw_dir), 'data');
load(fullfile(project_params.raw_dir,'subject_details.mat'));
% each respxconfidence is modeled by a separate binary parametric
% modulator. baseline is detection and tilt recognition

for i_s = which_subjects
    
    if sum(which_blocks(i_s,:))>1
        
        clear('names','onsets','durations','instruction_onsets','relevant_runs','runwise_offset','pmod','orth');
        
        %% 2. initialize variables
        %     names of regressors
        
        names{1} = 'trial';
        onsets{1} = [];
        durations{1} = [];
        
        for i_p = 1:6
            
            pmod(1).name{i_p} = ['A',num2str(i_p)];
            pmod(1).param{i_p} = [];
            pmod(1).poly{i_p} = 1;
            
            pmod(1).name{6+i_p} = ['C',num2str(i_p)];
            pmod(1).param{6+i_p} = [];
            pmod(1).poly{6+i_p} = 1;
        end
        
        names{2} = 'index_finger_press';
        onsets{2} = [];
        durations{2} = [];
        
        names{3} = 'middle_finger_press';
        onsets{3} = [];
        durations{3} = [];
        
        names{4} = 'thumb_press';
        onsets{4} = [];
        durations{4} = [];
        
        relevant_runs = find(which_blocks(i_s,:)>0);
        instruction_onsets = [];
        trials_matrix = zeros(400,12);
        i_t = 0;
        
        for i_r = 1:numel(relevant_runs)
            
            events_file = fullfile(unprocessed_dir,['sub-',subj{i_s}.scanid],...
                'func',['sub-',subj{i_s}.scanid,'_task-unequalVariance_run-',...
                sprintf('%.2d',relevant_runs(i_r)),'_events.tsv']);
            
            %% 1. read table
            table = tdfread(events_file,'\t');
            
            %compute run-wise offset
            runwise_offset = project_params.TR*179*(i_r-1);
            table.onset = table.onset+runwise_offset;
            
            %% 3. loop over events
            
            conf_vec = [];
            logRT_vec = [];
            
            for event = 1:length(table.onset)
                
                event_name = table.trial_type(event,1:2);
                
                if ismember(event_name, {'CC','AC','CA','AA','YY','YN','NY','NN', ...
                        'TT','TV','VV','VV'})
                    
                    i_t = i_t+1;
                    
                    onsets{1} = [onsets{1}; table.onset(event,:)];
                    durations{1} = [durations{1}; 4];
                    confidence_level = str2num(table.confidence(event,:));
                    %                     conf_vec(end+1) = confidence_level;
                    %                     logRT_vec(end+1) = log(str2num(table.response_time(event,:)));
                    
                    p_col = 6*strfind('AC',event_name(2))+confidence_level-6;
                    trials_matrix(i_t,p_col) = 1;
                    
                elseif table.trial_type(event,:)=='button press'
                    if str2num(table.key_id(event,:))==50 %index finger
                        onsets{2} = [onsets{2}; table.onset(event,:)];
                        durations{2} = [durations{2}; 0];
                    elseif str2num(table.key_id(event,:))==51 %middle finger
                        onsets{3} = [onsets{3}; table.onset(event,:)];
                        durations{3} = [durations{3}; 0];
                    elseif str2num(table.key_id(event,:))==54 % thumb
                        onsets{4} = [onsets{4}; table.onset(event,:)];
                        durations{4} = [durations{4}; 0];
                    elseif str2num(table.key_id(event,:))==55 % thumb
                        onsets{4} = [onsets{4}; table.onset(event,:)];
                        durations{4} = [durations{4}; 0];
                    end
                    
                elseif strcmp(strtrim(table.trial_type(event,:)),'missed_trial')
                    if length(onsets)==4
                        names{5} = 'missed_trials';
                        onsets{5} = [];
                        durations{5} = [];
                    end
                    onsets{5} = [onsets{5}; table.onset(event,:)];
                    durations{5} = [durations{5}; 4];
                    
                elseif strcmp(strtrim(table.trial_type(event,:)),'instructions')
                    instruction_onsets = [instruction_onsets, table.onset(event,:)];
                end
            end
        end
        
        trials_matrix = trials_matrix(1:i_t,:);
        
        for i_c = 1:12 %condition columns
            
            trials_matrix(isnan(trials_matrix(:,i_c)),i_c) = 0;
            
            if mean(trials_matrix(:,i_c))>0 %if not empty
                pmod(1).param{i_c} = trials_matrix(:,i_c);
            end
            
        end
        
        names{end+1} = 'instructions';
        onsets{end+1} = instruction_onsets;
        durations{end+1} = ones(size(instruction_onsets))*5;
        
        % %add quadratic confidence trend to design matrix;
        % conf_centered = conf_vec-mean(conf_vec);
        % conf_quad = conf_centered(:).^2;
        % conf_quad_centered = conf_quad-mean(conf_quad);
        % pmod(1).param{16} = conf_quad_centered;
        %
        % %add logRT to design matrix
        % logRT_centered = logRT_vec-mean(logRT_vec);
        % pmod(1).param{17} = logRT_centered;
        
        
        
        % % change the order of parametric modulators so that the quadratic modulator
        % % comes first and logRT second
        % for i_p = 17:-1:1
        %
        %     pmod(1).param{i_p+2} = pmod(1).param{i_p};
        %     pmod(1).name{i_p+2} = pmod(1).name{i_p};
        %     pmod(1).poly{i_p+2} = pmod(1).poly{i_p};
        %
        % end
        %
        % pmod(1).param{1} = pmod(1).param{18};
        % pmod(1).name{1} = pmod(1).name{18};
        % pmod(1).poly{1} = pmod(1).poly{18};
        %
        % pmod(1).param{2} = pmod(1).param{19};
        % pmod(1).name{2} = pmod(1).name{19};
        % pmod(1).poly{2} = pmod(1).poly{19};
        %
        % pmod(1).param(18:19) = [];
        % pmod(1).name(18:19) = [];
        % pmod(1).poly(18:19) = [];
        
        %%%%%%% REMOVE EMPTY ONSET FIELDS %%%%%%%%
        % note thas this step means that regressor numbers can differ between
        % subjects and runs. For example, names might be {'A', 'B'} for one run and
        % {'A','C','B'} for a different run. When running contrasts, make sure to
        % use the appropriate function, that uses beta names to generate contrast
        % vectors.
        empty_conditions = find(cellfun(@isempty,pmod(1).param));
        pmod(1).param(empty_conditions)=[];
        pmod(1).name(empty_conditions) = [];
        pmod(1).poly(empty_conditions) = [];
        
        %prevent orthogonalization:
        orth = {};
        for i_n = 1:numel(names)
            orth{i_n}=0;
        end
        
         filename =  fullfile(project_params.data_dir, ['sub-',subj{i_s}.scanid], 'DM', ...
        'DM10_cr.mat');
        save(filename, 'names','onsets','pmod','durations','orth');  
    end
end




