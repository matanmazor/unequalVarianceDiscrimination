function [  ] = tsv2DM104( events_file )
% For the multivariate analysis comparing high and low confidence
% separately for the four responses
% 

%% 1. read table
table = tdfread(events_file,'\t');

% to lock events to stimulus offset, add 0.033 seconds to events onsets:
table.onset = table.onset+0.033;

% first, extract a cutoff for high and low confidence, in correct responses
% only.
confidence_cutoff = containers.Map;
responses = {'A','C','Y','N'};

for i_r = 1:4
    
    correct_trials_indx = find(table.duration>0 & table.trial_type(:,1)==responses{i_r} &...
        table.trial_type(:,2)==responses{i_r});
    confidence_ratings = str2num(table.confidence(correct_trials_indx));
    cutoff = median(confidence_ratings);
    % In order to decide what to do with trials in which the confidence rating
    % was exactly equal to the confidence rating, I do the following:
    if mean(confidence_ratings>(cutoff))<mean(confidence_ratings<(cutoff))
        cutoff = cutoff-1;
    end
    confidence_cutoff(responses{i_r})=cutoff;
end

%% 2. initialize variables
%     names of regressors

names{1} = 'A_high_correct';
onsets{1} = [];
durations{1} = [];

names{2} = 'C_high_correct';
onsets{2} = [];
durations{2} = [];

names{3} = 'Y_high_correct';
onsets{3} = [];
durations{3} = [];

names{4} = 'N_high_correct';
onsets{4} = [];
durations{4} = [];

names{5} = 'A_low_correct';
onsets{5} = [];
durations{5} = [];

names{6} = 'C_low_correct';
onsets{6} = [];
durations{6} = [];

names{7} = 'Y_low_correct';
onsets{7} = [];
durations{7} = [];

names{8} = 'N_low_correct';
onsets{8} = [];
durations{8} = [];

names{9} = 'A_incorrect';
onsets{9} = [];
durations{9} = [];

names{10} = 'C_incorrect';
onsets{10} = [];
durations{10} = [];

names{11} = 'Y_incorrect';
onsets{11} = [];
durations{11} = [];

names{12} = 'N_incorrect';
onsets{12} = [];
durations{12} = [];

names{13} = 'missed_trials';
onsets{13} = [];
durations{13} = [];

%% 3. loop over events

for event = 1:length(table.onset)
    if table.duration(event)>0
        
        if strcmp(table.trial_type(event,:), 'missed_trial')
            i_reg = 13;
            
        elseif  strcmp(table.trial_type(event,1:2),'AA') && ... 
            (str2num(table.confidence(event))>confidence_cutoff('A'))
            i_reg = 1; 
            
        elseif  strcmp(table.trial_type(event,1:2),'CC') && ...
            str2num(table.confidence(event))>confidence_cutoff('C')
            i_reg = 2; 
            
        elseif  strcmp(table.trial_type(event,1:2),'YY') && ...
            str2num(table.confidence(event))>confidence_cutoff('Y')
            i_reg = 3;  
            
        elseif  strcmp(table.trial_type(event,1:2),'NN') && ...
            str2num(table.confidence(event))>confidence_cutoff('N')
            i_reg = 4; 
            
        elseif  strcmp(table.trial_type(event,1:2),'AA') && ... 
            str2num(table.confidence(event))<=confidence_cutoff('A')
            i_reg = 5; 
            
        elseif  strcmp(table.trial_type(event,1:2),'CC') && ...
            str2num(table.confidence(event))<=confidence_cutoff('C')
            i_reg = 6; 
            
        elseif  strcmp(table.trial_type(event,1:2),'YY') && ...
            str2num(table.confidence(event))<=confidence_cutoff('Y')
            i_reg = 7;  
            
        elseif  strcmp(table.trial_type(event,1:2),'NN') && ...
            str2num(table.confidence(event))<=confidence_cutoff('N')
            i_reg = 8; 
        
        elseif strcmp(table.trial_type(event,1:2),'CA')
            i_reg = 9;
            
        elseif strcmp(table.trial_type(event,1:2),'AC')
            i_reg = 9;
            
        elseif strcmp(table.trial_type(event,1:2),'NY')
            i_reg = 10;
            
        elseif strcmp(table.trial_type(event,1:2),'YN')
            i_reg = 11;
        end
     
        onsets{i_reg} = [onsets{i_reg}; table.onset(event,:)];
        durations{i_reg} = [durations{i_reg}; 4.3];
        
    end
end

trial_onsets = table.onset(table.duration>0); %ignore key presses
names{end+1} = 'instructions';
onsets{end+1} = [0, trial_onsets(40)+5];
durations{end+1} = [5,5];

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

filename = [events_file(1:end-11),'_DM104.mat'];
save(filename, 'names','onsets','durations');

end

