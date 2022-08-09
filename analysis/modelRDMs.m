%  modelRDMs is a user-editable function which specifies the models which
%  brain-region RDMs should be compared to, and which specifies which kinds of
%  analysis should be performed.
%
%  Models should be stored in the "Models" struct as a single field labeled
%  with the model's name (use underscores in stead of spaces).
%  
%  Cai Wingfield 11-2009

function Models = modelRDMs()

task_02 = ones(4)*0.2;

task_08 = ones(4)*0.8;

resp_02 = 0.2+0.6*[0 0 1 1;...
    0 0 1 1;...
    1 1 0 0;...
    1 1 0 0];

resp_conf = [-1 1; 1 -1];

task_conf_strong = [0 1 0.8 0.8;...
    1 0 0.8 0.8;...
    0.8 0.8 0 1;...
    0.8 0.8 1 0];

task_conf_weak = [0.1 0.9 0.8 0.8;...
    0.9 0.1 0.8 0.8;...
    0.8 0.8 0.1 0.9;...
    0.8 0.8 0.9 0.1];

Models.task = [task_02, task_08, task_08; ...
    task_08, task_02, task_08; ...
    task_08, task_08, task_02];

Models.task(find(eye(12)))=0;

Models.variance_structure = [task_02, task_08, task_08;...
    task_08, resp_02, resp_02;...
    task_08, resp_02, resp_02];

Models.variance_structure(find(eye(12)))=0;

Models.detection = [task_08, task_08, task_08;...
    task_08, resp_02, task_08;...
    task_08, task_08, task_08];

Models.detection(find(eye(12)))=0;

Models.unequal_variance= [task_08, task_08, task_08;...
    task_08, resp_02, resp_02;...
    task_08, resp_02, resp_02];

Models.unequal_variance(find(eye(12)))=0;

Models.confidence = 0.5+repmat(resp_conf,[6,6])/2;

Models.confidence(find(eye(12)))=0;

Models.conf_x_var = [[0.5+resp_conf*0.5, 0.5+resp_conf*0.4; 0.5+resp_conf*0.4, 0.5+resp_conf*0.5],task_08,task_08;...
    task_08, task_conf_strong, task_conf_weak;...
    task_08, task_conf_weak, task_conf_strong];

Models.conf_x_var(find(eye(12)))=0;

Models.conf_detection = [task_08, task_08, task_08;
    task_08, task_conf_strong, task_08;
    task_08, task_08, task_08];

Models.conf_detection(find(eye(12)))=0;


Models.conf_x_uv = [task_08,task_08,task_08;...
    task_08, task_conf_strong, task_conf_weak;...
    task_08, task_conf_weak, task_conf_strong];

Models.conf_x_uv(find(eye(12)))=0;

end
