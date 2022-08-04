function [  ] = tsv2DM200( events_file )
% Modeling each event separately

%% 1. read table
table = tdfread(events_file,'\t');

names = {};
onsets = {};
durations = {};

instructions_onsets = [];
instructions_durations = [];

%% 2. loop over events
run_number = str2num(events_file(end-11)); %file name ends with "_events.tsv"

i_e = 1;
for event = 1:length(table.onset)
    
    if table.duration(event)>0
                   
            event_name = sprintf('%s_task_%s_stimulus_%s_response_%s_confidence_%s_RT_%s_id_%s_include_%s',...
                strtrim(table.trial_type(event,:)),strtrim(table.task(event,:)),...,
                strtrim(table.stimulus(event,:)),strtrim(table.response(event,:)),...
                strtrim(table.confidence(event,:)),...
                strtrim(table.response_time(event,:)),...
                strtrim(table.uid(event,:)),...
                strtrim(table.include(event,:)));
            
            names{i_e} = event_name;
            onsets{i_e} = table.onset(event,:);
            durations{i_e} = table.duration(event);
            
        i_e = i_e+1;
        
%     elseif strcmp(strtrim(table.trial_type(event,:)),'instructions')
%         instructions_onsets = [instructions_onsets, table.onset(event,:)];
%         instructions_durations = [instructions_durations, 5];
    end
    
    
end

% names{end+1} = 'instructions';
% onsets{end+1} = instructions_onsets;
% durations{end+1} = instructions_durations;


filename = [events_file(1:end-11),'_DM200.mat'];
save(filename, 'names','onsets','durations');

end

