function [  ] = tsv2DM102( events_file )
% For the multivariate analysis comparing high and low confidence in
% correct trials only in detection, tilt recognition and discrimination separately


%% 1. read table
table = tdfread(events_file,'\t');

% first, extract a cutoff for high and low confidence, in correct responses
% only. Do it separately for each task.
dis_correct_trials_indx = find(table.duration>0 & table.trial_type(:,1)==table.trial_type(:,2)&...
    (table.trial_type(:,1)=='A'|table.trial_type(:,1)=='C'));
dis_confidence_ratings = str2num(table.confidence(dis_correct_trials_indx));
dis_confidence_cutoff = median(dis_confidence_ratings);

% In order to decide what to do with trials in which the confidence rating
% was exactly equal to the confidence rating, I do the following:
if mean(dis_confidence_ratings>(dis_confidence_cutoff))<mean(dis_confidence_ratings<(dis_confidence_cutoff))
    dis_confidence_cutoff = dis_confidence_cutoff-1;
end

det_correct_trials_indx = find(table.duration>0 & table.trial_type(:,1)==table.trial_type(:,2)&...
    (table.trial_type(:,1)=='Y'|table.trial_type(:,1)=='N'));
det_confidence_ratings = str2num(table.confidence(det_correct_trials_indx));
det_confidence_cutoff = median(det_confidence_ratings);

% In order to decide what to do with trials in which the confidence rating
% was exactly equal to the confidence rating, I do the following:
if mean(det_confidence_ratings>(det_confidence_cutoff))<mean(det_confidence_ratings<(det_confidence_cutoff))
    det_confidence_cutoff = det_confidence_cutoff-1;
end

tilt_correct_trials_indx = find(table.duration>0 & table.trial_type(:,1)==table.trial_type(:,2)&...
    (table.trial_type(:,1)=='T'|table.trial_type(:,1)=='V'));
tilt_confidence_ratings = str2num(table.confidence(tilt_correct_trials_indx));
tilt_confidence_cutoff = median(tilt_confidence_ratings);

% In order to decide what to do with trials in which the confidence rating
% was exactly equal to the confidence rating, I do the following:
if mean(det_confidence_ratings>(det_confidence_cutoff))<mean(det_confidence_ratings<(det_confidence_cutoff))
    det_confidence_cutoff = det_confidence_cutoff-1;
end
%% 2. initialize variables
%     names of regressors
names{1} = 'det_high_correct';
onsets{1} = [];
durations{1} = [];

names{2} = 'det_low_correct';
onsets{2} = [];
durations{2} = [];

names{3} = 'det_high_incorrect';
onsets{3} = [];
durations{3} = [];

names{4} = 'det_low_incorrect';
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

names{9} = 'tilt_high_correct';
onsets{9} = [];
durations{9} = [];

names{10} = 'tilt_low_correct';
onsets{10} = [];
durations{10} = [];

names{11} = 'tilt_high_incorrect';
onsets{11} = [];
durations{11} = [];

names{12} = 'tilt_low_incorrect';
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
        elseif table.trial_type(event,1)=='Y' || table.trial_type(event,1)=='N' % detection
             
            trial_type = 10*(table.trial_type(event,1)==table.trial_type(event,2))+...
                (str2num(table.confidence(event))>det_confidence_cutoff);
            
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
            
        elseif table.trial_type(event,1)=='A' || table.trial_type(event,1)=='C' % discrimination
            
            trial_type = 10*(table.trial_type(event,1)==table.trial_type(event,2))+...
                (str2num(table.confidence(event))>dis_confidence_cutoff);
            
            switch trial_type
                case 11
                    i_reg = 5;
                case 10
                    i_reg = 6;
                case 1
                    i_reg = 7;
                case 0
                    i_reg = 8;
            end
            
        elseif table.trial_type(event,1)=='T' || table.trial_type(event,1)=='V' % tilt
            
            trial_type = 10*(table.trial_type(event,1)==table.trial_type(event,2))+...
                (str2num(table.confidence(event))>tilt_confidence_cutoff);
            
            switch trial_type
                case 11
                    i_reg = 9;
                case 10
                    i_reg = 10;
                case 1
                    i_reg = 11;
                case 0
                    i_reg = 12;
            end
            
        else
            error(sprintf('unknown trial type %s',table.trial_type(event,:)));
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

filename = [events_file(1:end-11),'_DM102.mat'];
save(filename, 'names','onsets','durations');

end

