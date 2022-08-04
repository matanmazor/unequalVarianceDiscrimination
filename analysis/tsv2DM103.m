function [  ] = tsv2DM103( events_file )
% For the multivariate analysis comparing high and low confidence in
% correct trials in discrimination, hits vs. CRs in detection, and correct
% responses in tilt recognition

%% 1. read table
table = tdfread(events_file,'\t');

% to lock events to stimulus offset, add 0.033 seconds to events onsets:
table.onset = table.onset+0.033;

% first, extract a cutoff for high and low confidence, in correct responses
% only.
correct_trials_indx = find(table.duration>0 & table.trial_type(:,1)==table.trial_type(:,2) &...
    (table.trial_type(:,1)=='A'|table.trial_type(:,1)=='C'));
confidence_ratings = str2num(table.confidence(correct_trials_indx));
confidence_cutoff = median(confidence_ratings);
% In order to decide what to do with trials in which the confidence rating
% was exactly equal to the confidence rating, I do the following:
if mean(confidence_ratings>(confidence_cutoff))<mean(confidence_ratings<(confidence_cutoff))
    confidence_cutoff = confidence_cutoff-1;
end

%% 2. initialize variables
%     names of regressors
names{1} = 'det_hit';
onsets{1} = [];
durations{1} = [];

names{2} = 'det_CR';
onsets{2} = [];
durations{2} = [];

names{3} = 'det_FA';
onsets{3} = [];
durations{3} = [];

names{4} = 'det_miss';
onsets{4} = [];
durations{4} = [];

names{5} = 'dis_high_correct';
onsets{5} = [];
durations{5} = [];

names{6} = 'dis_low_correct';
onsets{6} = [];
durations{6} = [];

names{7} = 'dis_high_incorrect';
onsets{7} = [];
durations{7} = [];


names{8} = 'dis_low_incorrect';
onsets{8} = [];
durations{8} = [];

names{9} = 'tilt_TT';
onsets{9} = [];
durations{9} = [];

names{10} = 'tilt_VV';
onsets{10} = [];
durations{10} = [];

names{11} = 'tilt_VT';
onsets{11} = [];
durations{11} = [];

names{12} = 'tilt_TV';
onsets{12} = [];
durations{12} = [];

names{13} = 'missed_trials';
onsets{13} = [];
durations{13} = [];

names{14} = 'instructions';
onsets{14} = [];
durations{14} = [];

%% 3. loop over events

for event = 1:length(table.onset)
    if table.duration(event)>0
        
        if strcmp(table.trial_type(event,:), 'missed_trial')
            i_reg = 13;
        elseif strcmp(strtrim(table.trial_type(event,:)), 'instructions')
            i_reg = 14;
        elseif  table.trial_type(event,1:2)=='YY'
            i_reg = 1; %hit
        elseif  table.trial_type(event,1:2)=='NN'
            i_reg = 2; %CR
        elseif  table.trial_type(event,1:2)=='NY'
            i_reg = 3; %FA
        elseif  table.trial_type(event,1:2)=='YN'
            i_reg = 4; %miss
        elseif  table.trial_type(event,1:2)=='TT'
            i_reg = 9; %TT
        elseif  table.trial_type(event,1:2)=='VV'
            i_reg = 10; %VV
        elseif  table.trial_type(event,1:2)=='VT'
            i_reg = 11; %VT
        elseif  table.trial_type(event,1:2)=='TV'
            i_reg = 12; %VT
        else 
            %first digit: 1 for discrimination, 0 for detection
            %second digit: 1 for correct
            %third digit: 1 for high confidence
            trial_type = ...
                10*(table.trial_type(event,1)==table.trial_type(event,2))+...
                (str2num(table.confidence(event))>confidence_cutoff);
            
            switch trial_type
                case 11
                    i_reg = 5; %high correct
                case 10
                    i_reg = 6; %low correct
                case 01
                    i_reg = 7; %high incorrect
                case 00
                    i_reg = 8; %low incorrect
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

filename = [events_file(1:end-11),'_DM103.mat'];
save(filename, 'names','onsets','durations');

end

