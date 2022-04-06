clear;
session_files = dir(fullfile('..','experiment','data','*session*_.mat'));

for i=1:length(session_files)
    sprintf('session %d our of %d', i, length(session_files))
    %check if lite version exists
    lite_version = [fullfile(session_files(i).folder, session_files(i).name(1:end-4)),'lite.mat'];
%     if isfile(lite_version)
%         continue
%     else
    cur_file = load(fullfile(session_files(i).folder, session_files(i).name));
    % create unique trial identifiers
    cur_file.log.uid = i*100+(1:length(cur_file.log.confidence))';
    log = rmfield(cur_file.log,'xymatrix');
    params = cur_file.params;
    save(lite_version,'params','log');
%     end
end


