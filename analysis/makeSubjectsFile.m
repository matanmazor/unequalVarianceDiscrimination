clear;
subjects = containers.Map;

session_files = dir(fullfile('..','experiment','data','*session1_lite.mat'));

for i=1:length(session_files)
    cur_file = load(fullfile(session_files(i).folder, session_files(i).name));
    % make some sanity checks
    if isfield(cur_file.log, 'orientation')
        subjects(cur_file.params.subj)=cur_file.params.conf_mapping;
    else
        delete(fullfile(session_files(i).folder, session_files(i).name));
    end
end

save(fullfile('..','experiment','data','subjects.mat'),'subjects');

