%{
  fMRI experiment, run in the Wellcome Centre for Human Neuroimaging.
  Matan Mazor, 2020
%}

clear all
version = '2020-01-10';
%{
    add path to the preRNG folder, to support cryptographic time-locking of
    hypotheses and analysis plans. Can be downloaded/cloned from
    github.com/matanmazor/prerng
%}

addpath('..\..\..\complete\preRNG\Matlab')
% PsychDebugWindowConfiguration()

%global variables
global log
global params
global global_clock
global w %psychtoolbox window
global task
global pressed

%this is for KbCheck
pressed = 0

%name: name of subject. Should start with the subject number. The name of
%the subject should be included in the data/subjects.mat file.
%practice: 0 for no, 10 for discrimination practice, 11 for detection, 12
%for tilt practice.
%scanning: 0 for no, 1 for yes. this parameter only affects the sensitivity
%of the inter-run staircasing procedure.

prompt = {'Name: ', 'Practice: ', 'Scanning: '};
dlg_title = 'Filename'; % title of the input dialog box
num_lines = 1; % number of input lines
default = {'999MaMa','0','0'}; % default filename
savestr = inputdlg(prompt,dlg_title,num_lines,default);

%set preferences and open screen
% Screen('Preference','SkipSyncTests', 1)
screens=Screen('Screens');
screenNumber=max(screens);
doublebuffer=1;

% Open window.
[w, rect] = Screen('OpenWindow', screenNumber, [127,127,127],[], 32, doublebuffer+1);
Screen(w,'TextSize',40)
%Load parameters
params = loadPars(w, rect, savestr, 0);

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

% Initialize log with NaNs where possible.
log.confidence = nan(params.Nsets,1);
log.resp = zeros(params.Nsets,2);
log.task = nan(params.Nsets,1);
log.Alpha = nan(params.Nsets,1);
log.correct = nan(params.Nsets,1);
log.orientation = nan(params.Nsets,1);
log.events = [];


%% WAIT FOR 5
% Wait for the 6th volume to start the experiment.
% The 2d sequence sends a 5 for every slice, so waiting for 48*5 fives
% before starting the experiment.

excludeVolumes = 5;
slicesperVolume = 48;

%initialize
num_five = 0;
while num_five<=excludeVolumes && params.scanning
    Screen('DrawTexture', w, params.waitTexture);
    vbl=Screen('Flip', w);
    [ ~, firstPress]= KbQueueCheck;
    if firstPress(params.scanner_signal)
        num_five = num_five+1;
    elseif firstPress(KbName('0)'))  %for debugging
        num_five = inf;
    elseif firstPress(KbName('ESCAPE'))
        Screen('CloseAll');
        clear;
        return
    end
end

% All timings are relative to the onset of the 6th volume.

global_clock = tic();
%stop recording 5s from the scanner, because it seems to be too much for
%the kbcheck function.
DisableKeysForKbCheck(KbName('5%'));

%% MAIN LOOP:
for num_trial = 1:params.Nsets
    
    % Restrat Queue
    if params.scanning
        KbQueueStart;
    end
    
    %1. Set task to 0 (discrimination), 1 (detection) or 2 (tilt)
        task = params.vTask(ceil(num_trial/params.trialsPerBlock));
        
    % At the beginning of each experimental block:
    if mod(num_trial,round(params.trialsPerBlock))==1
        
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
        
        vbl=Screen('Flip', w);

        %2. Save data to file
        if ~params.practice
            save(fullfile('data', ['temp_',params.filename]),'params','log');
        end
        
        %3. Leave the instructions on the screen for 5 seconds.
        if num_trial==1
            remove_instruction_time = 0+params.instruction_time;
        else
            remove_instruction_time = trial_end_time + params.instruction_time;
        end
        
        %4. Present the instructions on the screen.
        while toc(global_clock)<remove_instruction_time
            
            keysPressed = queryInput();
        end
    end
    
    % schedule of visibility gradient
    schedule = exp(-abs((1:round(params.display_time/params.ifi)) -...
        round(params.display_time/params.ifi/2))/2);
    
    if params.vPresent(num_trial)==0 %noise trial
        schedule = zeros(size(schedule));
    end
    
    frames_xy = [];
    frames ={};
    %create the grating
    grating = generate_stim(params, num_trial);
    
    %create the frames
    for i = 1:length(schedule)
        [target,target_xy] = generate_frame(grating, alpha*schedule(i));
        frames_xy = cat(3,frames_xy, target_xy);
        frames{i} = target;
    end
    
    
    % Save to log.
    log.Alpha(num_trial) = params.vPresent(num_trial)*alpha;
    log.orientation(num_trial) = params.vOrient(num_trial)*...
        (1-params.vVertical(num_trial));
    log.xymatrix{num_trial} = frames_xy;
    log.task(num_trial) = task;
    
    while toc(global_clock)<params.onsets(num_trial)-0.5
        % Present a dot at the centre of the screen.
        Screen('DrawDots', w, [0 0]', ...
            params.fixation_diameter_px, [255 255 255]*0.4, params.center,1);
        vbl=Screen('Flip', w);%initial flip
        keysPressed = queryInput();
    end
    
    response = [nan nan];
    
    while toc(global_clock)<params.onsets(num_trial)
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
    
    %present the frames one by one.
    for i = 1:length(frames)
        while toc(global_clock)<params.onsets(num_trial)+i*params.ifi
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
    
    %% Wait for response
    
    while toc(global_clock)<params.onsets(num_trial)+params.display_time+params.time_to_respond
        
        Screen('DrawTexture', w, params.crossTexture,[],params.cross_position);
        resp1 = displayResps(task, response, display_bool);
        
        %only display the response signs after 0.4 seconds
        if toc(global_clock)<params.onsets(num_trial)+params.display_time+0.4
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
    
    % Write to log.
    log.resp(num_trial,:) = response;
    log.stimTime{num_trial} = vbl;
    if keysPressed(KbName('ESCAPE'))
        Screen('CloseAll');
    end
    
    % Check if the response was accurate or not
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
    end
    
    %% CONFIDENCE JUDGMENT
    if ~isnan(response(2))
        log.confidence(num_trial) = rateConf();
    end
    
    trial_end_time = toc(global_clock);
end

% Wait for the run to end.
if ~params.practice
    Screen('DrawDots', w, [0 02], ...
        params.fixation_diameter_px, [255 255 255]*0.4, params.center,1);
    vbl=Screen('Flip', w);%initial flip
    
    while toc(global_clock)<params.run_duration
        keysPressed = queryInput();
    end
end

%% close
Priority(0);
ShowCursor
Screen('CloseAll');

% Make a gong sound so that I can hear from outside the testing room that
% the behavioural session is over :-)
if ~params.scanning
    load gong.mat;
    soundsc(y);
end

%% write to log
if ~params.practice
    log.date = date;
    log.version = version;
    save(fullfile('data', params.filename),'params','log');
    if exist(fullfile('data', ['temp_',params.filename]), 'file')==2
        delete(fullfile('data', ['temp_',params.filename]));
    end
end

%% write to report
try
    fileID = fopen(fullfile('data',[params.subj,'_report.txt']),'a');
    fprintf(fileID,'%s%s%s\r\n','===Run ',num2str(params.num_session),...
        '===');
    fprintf(fileID,'%s%3f\r\n','Discrimination Alpha: ',params.DisAlpha(end));
    fprintf(fileID,'%s%2f\r\n','Discrimination accuracy: ',nanmean(log.correct(log.task==0)));
    fprintf(fileID,'%s%2f%s\r\n','Answered ''clockwise'' on ',...
        nanmean(log.resp(log.task==0)), 'of the trials');
    fprintf(fileID,'%s%3f\r\n','Detection Alpha: ',params.DetAlpha(end));
    fprintf(fileID,'%s%2f\r\n','Detection accuracy: ',nanmean(log.correct(log.task==1)));
    fprintf(fileID,'%s%3f\r\n','Angle Sigma: ',params.AngleSigma(end));
    fprintf(fileID,'%s%2f\r\n','Tilt recognition accuracy: ',nanmean(log.correct(log.task==2)));
    fclose(fileID)
catch
    error('close the report file!');
end
