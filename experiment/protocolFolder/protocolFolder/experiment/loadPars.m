function params = loadPars(w, rect, savestr, calibration)
%{
 LOADPARS load run/session parameters.
 Matan Mazor, 2020
%}


params.scanner_signal = KbName('5%');
params.subj = savestr{1};
params.practice = str2double(savestr{2});
params.scanning = str2double(savestr{3});

% load the subject list from the data folder.
load(fullfile('data','subjects.mat'));
if ismember(params.subj, subjects.keys)
    response_mappings = subjects(params.subj);
    %when this equals 1, bigger circles represent higher confidence
    params.conf_mapping = response_mappings(1);
else
    error('Participant is not in subjects list');
end

% A while-loop to start next session in line.
if ~params.practice && ~calibration
    num_session=0;
    stopper=0;
    while stopper==0
        num_session = num_session + 1;
        aux_filename = strjoin({params.subj,...
            ['session',num2str(num_session)],'.mat'},'_');
        stopper = isempty(dir(fullfile('data',aux_filename)));
        if ~stopper
            % if previous run exists, load log and parameters as
            % 'old_params'
            old_params = load(fullfile('data',aux_filename));
        end
    end
    params.num_session = num_session;
    params.filename = aux_filename;
else
    params.num_session = 0;
    num_session=0;
    params.filename = strjoin({params.subj,'calibration.mat'},'_');
end

% Tha mapping between Gabor orientations and right/left alternates between
% runs. When this equals 1, the 'Yes'/'clockwise'/'vertical' response will be on the right.
params.yes = 1+binornd(1,0.5);
params.vertical = 1+binornd(1,0.5);
params.clockwise = 1+binornd(1,0.5);

%% randomize
if ~params.practice
    subject_num = str2num(params.subj(1:2));
    serial_num = subject_num*100+num_session;
    % experimental randomization is a deterministic function of the
    % contents of the protocol folder, subject number, and session number.
    % read more here:
    % https://medium.com/@mazormatan/cryptographic-preregistration-from-newton-to-fmri-df0968377bb2
    params.protocolSum = preRNG('protocolFolder.zip',serial_num);
end

params.waitframes = 1;
if params.practice || calibration
    
    %Alpha is the parameter that controls the prevalence of signal pixels
    %in the stimulus. It is sometimes referred to here as 'transparency',
    %although it's not exactly the same thing.
    params.DetAlpha = 0.2; %transparency in detection
    params.DisAlpha = 0.2; %transparency in (equal variance) discrimination
    params.TiltAlpha = 0.2; %transparency in tilt detection/ unequal variance discrimination
    
    params.AngleSigma = 10; %variance of non-vertical Gabors
    params.AngleMu = 0; % overall bias of non-vertical Gabors
    
elseif ~exist('old_params') %this is the first run
    
    %load parameters from the calibration file.
    old_params = load(fullfile('data',strjoin({params.subj,'calibration.mat'},'_')));
    
    params.DetAlpha = old_params.params.DetAlpha(end);
    params.DisAlpha = old_params.params.DisAlpha(end);
    params.TiltAlpha = old_params.params.TiltAlpha(end);
    
    params.AngleSigma = old_params.params.AngleSigma(end);
    params.AngleMu = old_params.params.AngleMu(end);
    
else
    % Monitor and update the Alpha parameters based on performance on the
    % previous run. Don't change unless performance was below 0.525 or above
    % 0.85, in which case multiply or divide by a factor of 0.85. These
    % numbers were chosen because the likelihood of reaching these levels
    % of accuracy when performance is at 0.71 is around 1 percent.
    
    params.AngleSigma =  old_params.params.AngleSigma(end);
    if params.scanning
        lower_bound = 0.525;
        upper_bound = 0.85;
    else
        lower_bound = 0.6;
        upper_bound = 0.8;
    end
    
    %     IMPORTANT: tasks are encoded as follows:
    %     0 ==> Discrimination (equal variance)
    %     1 ==> Detection
    %     2 ==> Tilt (unequal variance)
    
    % if discrimination performance was too low, increase alpha
    if nanmean(old_params.log.correct(find(old_params.log.task==0)))<=lower_bound
        params.DisAlpha = old_params.params.DisAlpha(end)/0.95;
        
        % if discrimination performance was too high, decrease alpha
    elseif nanmean(old_params.log.correct(find(old_params.log.task==0)))>=upper_bound
        params.DisAlpha = old_params.params.DisAlpha(end)*0.95;
        
        % else, don't change alpha
    else
        params.DisAlpha = old_params.params.DisAlpha(end);
    end
    
    % if detection performance was too low, increase alpha
    if nanmean(old_params.log.correct(find(old_params.log.task==1)))<=lower_bound
        params.DetAlpha = old_params.params.DetAlpha(end)/0.95;
        
        % if detection performance was too high, decrease alpha
    elseif nanmean(old_params.log.correct(find(old_params.log.task==1)))>=upper_bound
        params.DetAlpha = old_params.params.DetAlpha(end)*0.95;
        
        % else, don't change alpha
    else
        params.DetAlpha = old_params.params.DetAlpha(end);
    end
    
    % if tilt performance was too low, increase angle sigma
    if nanmean(old_params.log.correct(find(old_params.log.task==2)))<=lower_bound
        params.AngleSigma = old_params.params.AngleSigma(end)/0.95;
        % if detection performance was too high, decrease angle sigma
    elseif nanmean(old_params.log.correct(find(old_params.log.task==2)))>=upper_bound
        params.AngleSigma = old_params.params.AngleSigma(end)*0.95;
        % else, don't change angle sigma
    else
        params.AngleSigma = old_params.params.AngleSigma(end);
    end
    %in any case, TiltAlpha and AngleMu don't change.
    params.TiltAlpha = old_params.params.TiltAlpha(end);
    params.AngleMu = old_params.params.AngleMu(end);
    
end

%% Visual properties
%background color
params.bg = 0.5; %gray
%letter size
params.letter_size = 25;
%dot color
params.fix_color = [0 0 255];
params.displace = 300;
Screen('TextFont',w,'Corbel');


%% Timing
params.fixation_time = 0.8;
params.display_time = 0.5; %duration of stimulus presentation
params.time_to_respond = 1;
params.time_to_conf = 2.5;
params.instruction_time = 5;
params.ifi = 1/20;

%% Number of trials and blocks
if params.practice
    params.trialsPerBlock = 4;
    params.Nblocks = 1;
    params.calibration = 0;
elseif calibration
    params.trialsPerBlock = 100;
    params.Nblocks = 3;
    params.calibration = 1;
else
    %in the scanner, run one block of each task in each run.
    params.trialsPerBlock = 26;
    params.Nblocks = 3;
    params.calibration = 0;
end

% this is the number of trials in the run.
params.Nsets = params.trialsPerBlock*params.Nblocks;

distance_from_monitor = 77; % cm
mon_width = 29;
mon_height = 21.5;
newResolution.width = 1024;
newResolution.height = 768;
cm_per_px_width  = mon_width/newResolution.width;
cm_per_px_height = mon_height/newResolution.height;
params.deg_per_px_width = cm_per_px_width * atan(1/distance_from_monitor) * 360/(2*pi);
params.deg_per_px_height = cm_per_px_height * atan(1/distance_from_monitor) * 360/(2*pi);

params.stimulus_width_deg = 3;
params.stimulus_width_px = round(params.stimulus_width_deg/params.deg_per_px_width);

params.fixation_diameter_deg = 0.2;
params.fixation_diameter_px = round(params.fixation_diameter_deg/params.deg_per_px_width);

params.cycles_deg      = 2;
params.cycle_length_deg = 1/params.cycles_deg;
params.cycle_length_px = round(params.cycle_length_deg/params.deg_per_px_width);

params.conf_diam_deg = 6;
params.conf_width_px = round(params.conf_diam_deg/params.deg_per_px_width);
params.conf_height_px = round(params.conf_diam_deg/params.deg_per_px_height);

% circle filter (to mask the Gabor patch)
x = [1:params.stimulus_width_px] - median(1:params.stimulus_width_px);
[xx yy] = meshgrid(x);
params.stimRadii    = sqrt(xx.^2 + yy.^2);
params.circleFilter = (params.stimRadii <= params.stimulus_width_px/2);

% coordinates of the centre of the screen.
[params.center(1), params.center(2)] = RectCenter(rect);
params.rect = rect;

%% Load all Textures

% I rendered some of the text as images because PTB is giving me hell
[img, ~, alpha] = imread(fullfile('textures','weAreJustAboutToBegin.png'));
img(:, :, 4) = alpha;
params.waitTexture = Screen('MakeTexture',w,img);

[img, ~, alpha] = imread(fullfile('textures','or.png'));
img(:, :, 4) = alpha;
params.orTexture = Screen('MakeTexture',w,img);

[img, ~, alpha] = imread(fullfile('textures','Y.png'));
img(:, :, 4) = alpha;
params.yesTexture = Screen('MakeTexture',w,img);

[img, ~, alpha] = imread(fullfile('textures','N.png'));
img(:, :, 4) = alpha;
params.noTexture = Screen('MakeTexture',w,img);

[img, ~, alpha] = imread(fullfile('textures','verticalLine.png'));
img(:, :, 4) = alpha;
params.vertTexture = Screen('MakeTexture',w,img);

[img, ~, alpha] = imread(fullfile('textures','x.png'));
img(:, :, 4) = alpha;
params.xTexture = Screen('MakeTexture',w,img);

[img, ~, alpha] = imread(fullfile('textures','cross.png'));
img(:, :, 4) = alpha;
params.crossTexture = Screen('MakeTexture',w,img);


params.positions = {[params.center(1)-250, params.center(2)-50,...
    params.center(1)-150, params.center(2)+50],...
    [params.center(1)+150, params.center(2)-50,...
    params.center(1)+250, params.center(2)+50]};

params.cross_position = [params.center(1)-10,params.center(2)-10,...
    params.center(1)+10, params.center(2)+10];

params.keys = {'2@','3#'};

% determine orientation and alpha for every trial
if params.practice == 10 %practice discrimination
    
    % in discrimination, samples are never vertical
    params.vVertical = zeros(params.Nsets,1);
    
    % in discrimination, a stimulus is presented on all trials
    params.vPresent = ones(params.Nsets,1);
    
    params.vTask = [0, 0];
    
    params.onsets = cumsum(6*ones(params.Nsets));
    
    %in discrimination, the orientation is 45 on half of the trials and -45
    %on the other half.
    params.vOrient = (1:params.Nsets)>params.Nsets/2;
    params.vOrient = -45+90*params.vOrient(randperm(params.Nsets));
    
    params.vPhase = rand(params.Nsets,1);
    
elseif params.practice == 11 %practice detection
    
    % in detection, samples are never vertical
    params.vVertical = zeros(params.Nsets,1);
    
    % only on half of the trials a stimulus is presented
    params.vPresent = (1:params.Nsets)>params.Nsets/2;
    params.vPresent = params.vPresent(randperm(params.Nsets));
    
    params.vTask = [1, 1];
    
    params.onsets = cumsum(6*ones(params.Nsets));
    
    params.vOrient = normrnd(0,1,params.Nsets,1);
    
    params.vPhase = rand(params.Nsets,1);
    
elseif params.practice == 12 %practice tilt detection/ unequal variance discrimination
    
    params.vVertical = (1:params.Nsets)>params.Nsets/2;
    params.vVertical = params.vVertical(randperm(params.Nsets));
    
    % in discrimination, a stimulus is presented on all trials
    params.vPresent = ones(params.Nsets,1);
    
    params.vTask = [2, 2];
    
    params.onsets = cumsum(6*ones(params.Nsets));
    
    params.vOrient = normrnd(0,1,params.Nsets,1);
    
    params.vPhase = rand(params.Nsets,1);
    
elseif calibration
    
    params.vPhase = rand(3000,1);
    params.run_duration = 601.44; %seconds = 179 TRs of 3.36 seconds;
    
else% true experimental session
    params.run_duration = 601.44; %seconds = 179 TRs of 3.36 seconds;
    [params.vVertical, params.vPresent, params.vTask, params.onsets,...
        params.vOrient] =  get_trials_params(params);
    
    % randomize phase of Gabor patches
    params.vPhase = rand(params.Nsets,1);
end

end