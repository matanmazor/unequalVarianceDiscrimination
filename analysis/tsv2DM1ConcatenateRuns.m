excludeSubjects;
load('project_params.mat')

%usable runs get 1, unusable runs get 0
which_blocks = toExclude+toExcludeFromConfAnalyses==0;
unprocessed_dir = fullfile(fileparts(project_params.raw_dir), 'data');
load(fullfile(project_params.raw_dir,'subject_details.mat'));

for i_s = which_subjects
    
    if sum(which_blocks(i_s,:))>1
        
        clear('names','onsets','durations','instruction_onsets','relevant_runs','runwise_offset','pmod');
        
        %% 1. initialize variables
        
        %     names of regressors.
        % C: counterclockwise
        % A: anticlockwise
        % Y: stimulus present
        % N: stimulus absent
        % T: tilted
        % V: vertical
        reg_names = {'C','A',...
            'Y','N',...
            'T','V',...
            'ignore','index_finger_press',...
            'middle_finger_press','thumb_press', ...
            'instructions'};
    
        % serial position of the first nuisance regressor
        first_nuis_idx = find(strcmp(reg_names,'ignore'));
        
        %create all regressors
        for i_r= 1:length(reg_names)
            names{i_r} = reg_names{i_r};
            onsets{i_r} = [];
            durations{i_r} = [];
        end
        
        %regressors of interest also get confidence modulators
        for i_r = 1:6
            pmod(i_r).name{1} = 'confidence';
            pmod(i_r).param{1} = [];
            pmod(i_r).poly{1} = 2;
        end

        relevant_runs = find(which_blocks(i_s,:)>0);
        
        instruction_onsets = [];
        
        all_trial_onsets = [];
        
        for i_r = 1:numel(relevant_runs)
            
            events_file = fullfile(unprocessed_dir,['sub-',subj{i_s}.scanid],...
                'func',['sub-',subj{i_s}.scanid,'_task-unequalVariance_run-',...
                sprintf('%.2d',relevant_runs(i_r)),'_events.tsv']);
            
            %% 1. read table
            table = tdfread(events_file,'\t');
            
            runwise_offset = project_params.TR*179*(i_r-1);
            table.onset = table.onset+runwise_offset;
            
            %% 3. loop over events
            for event = 1:length(table.onset)
                
                % ignore trials that are marked as not included
                if strcmp(table.include(event,1),'0')
                    reg_idx = find(strcmp(reg_names,'ignore'));
                    onsets{reg_idx} = [onsets{reg_idx}; table.onset(event,:)];
                    durations{reg_idx} = [durations{reg_idx}; 4];
                
                    all_trial_onsets(end+1)=table.onset(event,:);
                    
                    % model trials that are included
                elseif any(strcmp(reg_names(1:first_nuis_idx-1),...
                        table.trial_type(event,2)))
                    
                    reg_idx = find(strcmp(reg_names,table.trial_type(event,2)));
                    
                    onsets{reg_idx} = [onsets{reg_idx}; table.onset(event,:)];
                    durations{reg_idx} = [durations{reg_idx}; 4];
                    pmod(reg_idx).param{1} = [pmod(reg_idx).param{1}; 
                        str2num(table.confidence(event,:))];
                
                    all_trial_onsets(end+1)=table.onset(event,:);

                % buttom presses have duration 0              
                elseif table.trial_type(event,:)=='button press'
                    if str2num(table.key_id(event,:))==50 %index finger
                        reg_idx = find(strcmp(reg_names,'index_finger_press'));
                        onsets{reg_idx} = [onsets{reg_idx}; table.onset(event,:)];
                        durations{reg_idx} = [durations{reg_idx}; 0];
                    elseif str2num(table.key_id(event,:))==51 %middle finger
                        reg_idx = find(strcmp(reg_names,'middle_finger_press'));
                        onsets{reg_idx} = [onsets{reg_idx}; table.onset(event,:)];
                        durations{reg_idx} = [durations{reg_idx}; 0];
                    elseif str2num(table.key_id(event,:))==54 % thumb
                        reg_idx = find(strcmp(reg_names,'thumb_press'));
                        onsets{reg_idx} = [onsets{reg_idx}; table.onset(event,:)];
                        durations{reg_idx} = [durations{reg_idx}; 0];
                    elseif str2num(table.key_id(event,:))==55 % thumb
                        reg_idx = find(strcmp(reg_names,'thumb_press'));
                        onsets{reg_idx} = [onsets{reg_idx}; table.onset(event,:)];
                        durations{reg_idx} = [durations{reg_idx}; 0];
                    end

                   
                    
                elseif strcmp(strtrim(table.trial_type(event,:)),'missed_trial')
                    if ~any(strcmp(names,'missed_trial'))
                        names{end+1} = 'missed_trial';
                        onsets{end+1} = [];
                        durations{end+1} = [];
                    end
                    reg_idx = find(strcmp(names,'missed_trial'));
                    onsets{reg_idx} = [onsets{reg_idx}; table.onset(event,:)];
                    durations{reg_idx} = [durations{reg_idx}; 4];
                    all_trial_onsets(end+1)=table.onset(event,:);
                
                elseif strcmp(strtrim(table.trial_type(event,:)),'instructions')
                    reg_idx = find(strcmp(names,'instructions'));
                    onsets{reg_idx} = [onsets{reg_idx}; table.onset(event,:)];
                    durations{reg_idx} = [durations{reg_idx}; 5];
                end
            end
            
%             trial_onsets = table.onset(table.duration>0); %ignore key presses
%             
%             if length(trial_onsets)~=length(all_trial_onsets)/i_r
%                 error('trial numbers do not match')
%             end
%             
%             if length(onsets{first_nuis_idx})<3
%                 error('not enough excluded trials for participant,there should be at least 3 per block')
%             end

        end
        
        all_trials_from_DM = [];
        for i = 1:first_nuis_idx
            all_trials_from_DM = [all_trials_from_DM; onsets{i}];
        end
        if strcmp(names{end},'missed_trial')
            all_trials_from_DM = [all_trials_from_DM; onsets{end}];
        end
        if ~all(sort(all_trials_from_DM)==all_trial_onsets')
                error('trials do not match')
        end
        
        %center confidence ratings
        for i=1:first_nuis_idx-1
            pmod(i).param{1} = pmod(i).param{1}-mean(pmod(i).param{1});
        end
        
        for i = 1:numel(pmod)
            switch numel(unique(pmod(i).param{1}))
                case 1
                    pmod(i).name{1} = [];
                    pmod(i).param{1} = [];
                    pmod(i).poly{1} = [];
                case 2
                    pmod(i).poly{1} = 1;
                otherwise
                    pmod(i).poly{1} = 2;
            end
        end

        
        %%%%%%% REMOVE EMPTY ONSET FIELDS %%%%%%%%
        % note thas this step means that regressor numbers can differ between
        % subjects and runs. For example, names might be {'A', 'B'} for one run and
        % {'A','C','B'} for a different run. When running contrasts, make sure to
        % use the appropriate function, that uses beta names to generate contrast
        % vectors.
        empty_conditions = find(cellfun(@isempty,onsets));
        onsets(empty_conditions)=[];
        names(empty_conditions) = [];
        durations(empty_conditions)=[];
        pmod(empty_conditions) = [];
        
        dirname = fullfile(project_params.data_dir, ['sub-',subj{i_s}.scanid], 'DM');
        filename =  fullfile(dirname, 'DM1_cr.mat');
        if ~exist(dirname, 'dir')
            mkdir(dirname)
        end
        save(filename, 'names','onsets','pmod','durations');
    end
end
