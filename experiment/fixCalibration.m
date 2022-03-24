clear all
version = '2020-01-10';


%global variables
global log
global params
global w %psychtoolbox window
global global_clock
global task
global pressed

% PsychDebugWindowConfiguration()

%this is for KbCheck
pressed = 0

global_clock = tic();

%name: name of subject. Should start with the subject number. The name of
%the subject should be included in the data/subjects.mat file.
%practice: enter 0.
%scanning: enter 0

prompt = {'Name: ', 'Practice: ', 'Scanning: ', 'Do discrimination: ',...
    'Do detection:', 'Do tilt recognition:'};
dlg_title = 'Filename'; % title of the input dialog box
num_lines = 1; % number of input lines
default = {'999MaMa','0','0','1','1','1'}; % default filename
savestr = inputdlg(prompt,dlg_title,num_lines,default);

%set preferences and open screen
Screen('Preference','SkipSyncTests', 1)
screens=Screen('Screens');
screenNumber=max(screens);
doublebuffer=1;


[w, rect] = Screen('OpenWindow', screenNumber, [127,127,127],[], 32, doublebuffer+1);
Screen(w,'TextSize',40)

%load parameters
params = loadPars(w, rect, savestr, 2);

if params.scanning
    params.DisAlpha = str2num(initial_values{1});
    params.DetAlpha = str2num(initial_values{2});
    params.AngleSigma = str2num(initial_values{3});
end

%The fMRI button box does not work well with KbCheck. I use KbQueue
%instead here, to get precise timings and be sensitive to all presses.
if params.scanning
    KbQueueCreate;
    KbQueueStart;
end

KbName('UnifyKeyNames');
AssertOpenGL;
PsychVideoDelayLoop('SetAbortKeys', KbName('Escape'));
HideCursor();
Priority(MaxPriority(w));

% Enable alpha blending with proper blend-function. We need it
% for drawing of smoothed points:
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%initialize decision log
log.resp = zeros(params.Nsets,2);
log.task = nan(params.Nsets,1);
log.Alpha = nan(params.Nsets,1);
log.correct = nan(params.Nsets,1);
log.tilt = nan(params.Nsets,1);
log.orientation = nan(params.Nsets,1);
log.AngleSigma = nan(params.Nsets,1);
log.estimates = [];
log.events = [];

% change parameters:
params.trialsPerBlock = 1000; %arbitrary large number
params.Nsets = 3000;
[params.vVertical, params.vPresent, params.vTask, params.vOnset, params.vOrient] = ...
    get_trials_params(params);

% has performance level converged yet?
converged = 0;

num_trial = 1;
last_two_trials = [0,0];
alpha_vec = [];

reversal_points = [];
direction = [-1];

doTasks = logical([ones(1000,1)*params.doTiltRecognition;...
    ones(1000,1)*params.doDetection;...
    ones(1000,1)*params.doDiscrimination]);

params.vVertical = params.vVertical(doTasks);
params.vPresent = params.vPresent(doTasks);
params.vTask = params.vTask([doTasks(1),doTasks(1001),doTasks(2001)]);
params.vOnset = params.vOnset(doTasks);
params.vOrient = params.vOrient(doTasks);

params.Nsets = length(params.vVertical);

%% Strart the trials
while num_trial <= params.Nsets
    
    %At the beinning of each block, do:
    if mod(num_trial,round(params.trialsPerBlock))==1
        
        save(fullfile('data', params.filename),'params','log');
        
        %which task is it? 0: discrimination, 1: detection, or 2: tilt?
        task = params.vTask(ceil(num_trial/params.trialsPerBlock));
        
        if task ==0
            Screen('DrawTexture', w, params.vertTexture, [], params.positions{params.clockwise}, 45);
            Screen('DrawTexture', w, params.vertTexture, [], params.positions{3-params.clockwise}, -45)
            alpha = params.DisAlpha(end);
        elseif task==1
            Screen('DrawTexture', w, params.yesTexture, [], params.positions{params.yes})
            Screen('DrawTexture', w, params.noTexture, [], params.positions{3-params.yes})
            alpha = params.DetAlpha(end);
        elseif task ==2
            Screen('DrawTexture', w, params.vertTexture, [], params.positions{params.vertical})
            Screen('DrawTexture', w, params.xTexture, [], params.positions{3-params.vertical})
            alpha = params.TiltAlpha(end);
        else
            error('unknown task number');
        end
        
        anglesigma = params.AngleSigma(end);
        
        Screen('DrawTexture', w, params.orTexture);
        vbl=Screen('Flip', w);
        
        instruction_clock = tic;
        while toc(instruction_clock)<5
            continue
        end
    end
    
    
    % Generate the stimulus.
    % schedule of visibility gradient
    schedule = exp(-abs((1:round(params.display_time/params.ifi)) -...
        round(params.display_time/params.ifi/2))/2);
    
    if params.vPresent(num_trial)==0 %noise trial
        schedule = zeros(size(schedule));
    end
    
    frames = {};
    frames_xy = [];
    
    grating = generate_stim(params, num_trial);
    for i = 1:length(schedule)
        [target,target_xy] = generate_frame(grating, alpha*schedule(i));
        frames{i} = target;
        frames_xy = cat(3,frames_xy, target_xy);
    end
    
    % Save to log.
    log.Alpha(num_trial) = params.vPresent(num_trial)*alpha;
    log.orientation(num_trial) = params.vOrient(num_trial)*...
        (1-params.vVertical(num_trial));
    log.AngleSigma(num_trial) = anglesigma;
    log.xymatrix{num_trial} = target_xy;
    log.task(num_trial) = task;
    
    trial_clock = tic;
    while toc(trial_clock)<1
        % Present a dot at the centre of the screen.
        Screen('DrawDots', w, [0 0]', ...
            params.fixation_diameter_px, [255 255 255]*0.4, params.center,1);
        vbl=Screen('Flip', w);%initial flip
        
        keysPressed = queryInput();
    end
    
    response = [nan nan];
    
    while toc(trial_clock)<1.5
        % Present the fixation cross.
        %         DrawFormattedText(w, '+','center','center');
        Screen('DrawTexture', w, params.crossTexture,[],params.cross_position);
        vbl=Screen('Flip', w);
        keysPressed = queryInput();
    end
    
    % Present the stimulus.
    
    % The onset of the stimulus is encoded in the log file as '0'.
    log.events = [log.events; 0 toc(global_clock)];
    if task == 0
        orientation = params.vOrient(num_trial)*(1-params.vVertical(num_trial));
    else
        orientation = params.vOrient(num_trial)*params.AngleSigma(end)*(1-params.vVertical(num_trial));
    end
    
    tini = GetSecs;
    display_bool=0;
    for i = 1:length(frames)
        while toc(trial_clock)<1.5+i*params.ifi
            Screen('DrawTextures',w,frames{i}, [], [],0,...
                []);
            Screen('DrawTexture', w, params.crossTexture,[],params.cross_position);
            vbl=Screen('Flip', w);
            keysPressed = queryInput();
            resp1 = displayResps(task, response, display_bool);
            
            if keysPressed(KbName(params.keys{resp1}))
                response = [GetSecs-tini 1];
            elseif keysPressed(KbName(params.keys{3-resp1}))
                response = [GetSecs-tini 0];
            end
            
        end
    end
    
    while (GetSecs - tini)<params.display_time+params.time_to_respond
        
        Screen('DrawTexture', w, params.crossTexture,[],params.cross_position);
        resp1 = displayResps(task, response, display_bool);
        
        if (GetSecs - tini)>=params.display_time+0.4
            display_bool = 1;
        end
        
        vbl=Screen('Flip', w);
        keysPressed = queryInput();
        if keysPressed(KbName(params.keys{resp1}))
            response = [GetSecs-tini 1];
        elseif keysPressed(KbName(params.keys{3-resp1}))
            response = [GetSecs-tini 0];
        end
    end
    
    log.resp(num_trial,:) = response;
    if keysPressed(KbName('ESCAPE'))
        Screen('CloseAll');
    end
    
    % MM: check if the response was accurate or not
    if task==0 && ~isnan(log.resp(num_trial,2))
        if sign(log.resp(num_trial,2))== sign(params.vOrient(num_trial)+45)
            log.correct(num_trial) = 1;
        else
            log.correct(num_trial) = 0;
        end
    elseif task==1 && ~isnan(log.resp(num_trial,2))
        if log.resp(num_trial,2)== params.vPresent(num_trial)
            log.correct(num_trial) = 1;
        else
            log.correct(num_trial) = 0;
        end
    elseif task==2 && ~isnan(log.resp(num_trial,2))
        if log.resp(num_trial,2) == params.vVertical(num_trial)
            log.correct(num_trial) = 1;
        else
            log.correct(num_trial) = 0;
        end
    else
        log.correct(num_trial) = NaN;
    end
    
    % end of decision phase
    % monitor and update coherence levels
    % 1 up 2 down procedure
    
    if mod(num_trial,round(params.trialsPerBlock))>1
        if log.correct(num_trial) == 0
            if task==0
                if direction == -1
                    reversal_points(end+1) = alpha;
                    direction = 1;
                end
                alpha = alpha/0.95;
            elseif task==1
                if direction == -1
                    reversal_points(end+1) = alpha;
                    direction = 1;
                end
                alpha = alpha/0.95;
            elseif task==2
                if direction == -1
                    reversal_points(end+1) = anglesigma;
                    direction = 1;
                end
                anglesigma = anglesigma/0.95;
            end
            last_two_trials = [0,0];
        elseif log.correct(num_trial)==1
            if last_two_trials(2) == 1
                if task==0
                    if direction == 1
                        reversal_points(end+1) = alpha;
                        direction = -1;
                    end
                    alpha = alpha*0.95;
                elseif task==1
                    if direction == 1
                        reversal_points(end+1) = alpha;
                        direction = -1;
                    end
                    alpha = alpha*0.95;
                elseif task==2
                    if direction == 1
                        reversal_points(end+1) = anglesigma
                        direction = -1;
                    end
                    anglesigma = anglesigma*0.95;
                end
                last_two_trials = [0,0];
            elseif last_two_trials(2) == 0
                last_two_trials = [0,1];
            end
        end
        
        if length(reversal_points)>12
            if task == 0
                params.DisAlpha(end+1) = mean(reversal_points(end-3:end));
            elseif task == 1
                params.DetAlpha(end+1) = mean(reversal_points(end-3:end));
            elseif task == 2
                params.AngleSigma(end+1) = mean(reversal_points(end-3:end));
            end
            last_two_trials = [0,0];
            num_trial = ceil(num_trial/params.trialsPerBlock)*params.trialsPerBlock;
            reversal_points = [];
            direction = [1];
        end
%         if mod(num_trial,8)==0
%             if task==0
%                 params.DisAlpha = [params.DisAlpha;  mode(log.Alpha(num_trial-7:num_trial))];
%             elseif task==1
%                 %don't take into account target absence trials.
%                 last_alphas = log.Alpha(num_trial-7:num_trial);
%                 params.DetAlpha = [params.DetAlpha; mode(last_alphas(last_alphas>0))];
%                 params.DisAlpha = min(params.DetAlpha(end)*2,0.2);
%             elseif task==2
%                 params.TiltAlpha = [params.TiltAlpha;  mode(log.Alpha(num_trial-7:num_trial))];
%                 params.AngleSigma = [params.AngleSigma;  mode(log.AngleSigma(num_trial-7:num_trial))];
%             end
%             
%             if mod(num_trial, params.trialsPerBlock)>80 || params.scanning
%                 %and it didn't change last time either, move to the next
%                 %task.
%                 if task==0
%                     if ismember(params.DisAlpha(end),dis_alpha_bucket)
%                         last_two_trials = [0,0];
%                         num_trial = ceil(num_trial/params.trialsPerBlock)*params.trialsPerBlock;
%                     end
%                     dis_alpha_bucket(end+1) = params.DisAlpha(end);
%                 elseif task==1
%                     if ismember(params.DetAlpha(end),det_alpha_bucket)
%                         last_two_trials = [0,0];
%                         num_trial = ceil(num_trial/params.trialsPerBlock)*params.trialsPerBlock;
%                     end
%                     det_alpha_bucket(end+1) = params.DetAlpha(end);
%                 elseif task==2
%                     if ismember(params.AngleSigma(end),angle_sigma_bucket)
%                         last_two_trials = [0,0];
%                         num_trial = ceil(num_trial/params.trialsPerBlock)*params.trialsPerBlock;
%                     end
%                     angle_sigma_bucket(end+1) = params.AngleSigma(end);
%                 end
%             end
%         end
    end
    num_trial = num_trial+1;
end

%% write to log

log.date = date;
log.filename = params.filename;
log.version = version;
save(fullfile('data', params.filename),'params','log');

if ~params.scanning
    load gong.mat;
    soundsc(y);
end

%% close
Priority(0);
ShowCursor
Screen('CloseAll');

%% write report
fileID = fopen(fullfile('data',[params.subj,'_report.txt']),'w');
fprintf(fileID,'%s%s\r\n','Report for ',params.subj);
fprintf(fileID, '%s\r\n', date);
fprintf(fileID,'%s\r\n','===Calibration===');
fprintf(fileID,'%s%d\r\n','Mapping: ',params.conf_mapping);
fprintf(fileID,'%s%3f\r\n','Discrimination Alpha: ',params.DisAlpha(end));
fprintf(fileID,'%s%3f\r\n','Detection Alpha: ',params.DetAlpha(end));
fprintf(fileID,'%s%3f\r\n','Angle Sigma: ',params.AngleSigma(end));
fclose(fileID)
