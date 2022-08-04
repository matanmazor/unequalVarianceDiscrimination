function [  ] = tsv2DM105( events_file )
% Classifying responses in all three tasks, correct responses only

%% 1. read table
table = tdfread(events_file,'\t');

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

names{5} = 'dis_CC';
onsets{5} = [];
durations{5} = [];

names{6} = 'dis_AA';
onsets{6} = [];
durations{6} = [];

names{7} = 'dis_CA';
onsets{7} = [];
durations{7} = [];


names{8} = 'dis_AC';
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
        elseif  table.trial_type(event,1:2)=='CC'
            i_reg = 5; %CC
        elseif  table.trial_type(event,1:2)=='AA'
            i_reg = 6; %AA  
        elseif  table.trial_type(event,1:2)=='CA'
            i_reg = 7; %CA
        elseif  table.trial_type(event,1:2)=='AC'
            i_reg = 8; %AC  
        elseif  table.trial_type(event,1:2)=='TT'
            i_reg = 9; %TT
        elseif  table.trial_type(event,1:2)=='VV'
            i_reg = 10; %VV
        elseif  table.trial_type(event,1:2)=='VT'
            i_reg = 11; %VT
        elseif  table.trial_type(event,1:2)=='TV'
            i_reg = 12; %VT
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

filename = [events_file(1:end-11),'_DM105.mat'];
save(filename, 'names','onsets','durations');

end

