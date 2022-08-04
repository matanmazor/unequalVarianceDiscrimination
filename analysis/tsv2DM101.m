function [  ] = tsv2DM101( events_file )
% For the multivariate analysis comparing high and low confidence in
% correct trials only

%% 1. read table
table = tdfread(events_file,'\t');

% first, extract a cutoff for high and low confidence, in correct responses
% only.
correct_trials_indx = find(table.duration>0 & table.trial_type(:,1)==table.trial_type(:,2));
confidence_ratings = str2num(table.confidence(correct_trials_indx));
confidence_cutoff = median(confidence_ratings);
% In order to decide what to do with trials in which the confidence rating
% was exactly equal to the confidence rating, I do the following:
if mean(confidence_ratings>(confidence_cutoff))<mean(confidence_ratings<(confidence_cutoff))
    confidence_cutoff = confidence_cutoff-1;
end

%% 2. initialize variables
%     names of regressors
names{1} = 'high_correct';
onsets{1} = [];
durations{1} = [];

names{2} = 'low_correct';
onsets{2} = [];
durations{2} = [];

names{3} = 'high_incorrect';
onsets{3} = [];
durations{3} = [];


names{4} = 'low_incorrect';
onsets{4} = [];
durations{4} = [];

names{5} = 'missed_trials';
onsets{5} = [];
durations{5} = [];

names{6} = 'instructions';
onsets{6} = [];
durations{6} = [];

%% 3. loop over events

for event = 1:length(table.onset)
    if table.duration(event)>0
        
        if strcmp(table.trial_type(event,:), 'missed_trial')
            i_reg = 5;
        elseif strcmp(strtrim(table.trial_type(event,:)), 'instructions')
            i_reg = 6;
        else            
            trial_type = 10*(table.trial_type(event,1)==table.trial_type(event,2))+...
                (str2num(table.confidence(event))>confidence_cutoff);
            
            switch trial_type
                case 11
                    i_reg = 1;
                case 10
                    i_reg = 2;
                case 1
                    i_reg = 3;
                case 0
                    i_reg = 4;
            end
        end
        
        onsets{i_reg} = [onsets{i_reg}; table.onset(event,:)];
        durations{i_reg} = [durations{i_reg}; table.duration(event)];
        
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

filename = [events_file(1:end-11),'_DM101.mat'];
save(filename, 'names','onsets','durations');

end

