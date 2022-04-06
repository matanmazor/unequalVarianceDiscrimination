T=readtable(fullfile('..','data','data','participants.csv'));

for i=1:45
    makeEventsTSV(T.name_initials{i},T.participant_id{i})
end
