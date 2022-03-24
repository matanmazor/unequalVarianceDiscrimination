function [vVertical, vPresent, vTask, vOnset, vOrient] = get_trials_params(params)
%{
 GET_TRIALS_PARAMS this function randomizes the orientation
 and presence of stimuli, the order of the detection,discrimination, and
 tilt recognition blocks, and the timing of events.
%}

Nsets = params.Nsets;
Nblocks = params.Nblocks;

% in calibration always do things in this order, to make things easier on
% subjects.
if params.calibration
    vTask = [2,1,0];
else
    % randomize blocks for detection/discrimination/tilt. Always interleaved.
    order = randperm(3)-1;
    vTask = reshape([ones(Nblocks/3,1)*order(1),...
        ones(Nblocks/3,1)*order(2),...
        ones(Nblocks/3,1)*order(3)]',Nblocks,1);
end

vPresent = [];
vVertical = [];
vOrient = [];

% If calibration, make sure presence/orientation are balanced locally.
% this is done by randomizing things in balanced chunks of 8 trials, that
% are then concatenated together. As a consequence, the maximum number of
% trials of the same type that can appear in series is 8.
four0four1 = [0 0 0 0 1 1 1 1];

% loop over experimental blocks
for i=1:length(vTask)
    
    % what task is this block?
    task = vTask(i);
    
    random_vec = [ones(params.trialsPerBlock/2,1); zeros(params.trialsPerBlock/2,1)];
            random_vec = random_vec(randperm(params.trialsPerBlock));
            
    if task ==0 %if discrimination
        vVertical = [vVertical; zeros(params.trialsPerBlock,1)];
        vPresent = [vPresent; ones(params.trialsPerBlock,1)];
        if ~params.calibration
            clockwise_vec = random_vec;
        else
            clockwise_vec = [];
            for i_c = 1:params.trialsPerBlock/numel(four0four1)
                clockwise_vec = [clockwise_vec; four0four1(randperm(numel(four0four1)))'];
            end
        end
        vOrient = [vOrient; -45+90*clockwise_vec];
        
    elseif task==1 % detection
        vVertical = [vVertical; zeros(params.trialsPerBlock,1)];
        vOrient = [vOrient; normrnd(0,1,params.trialsPerBlock,1)];
        if ~params.calibration
            vPresent = [vPresent; random_vec];
        else
            for i_c = 1:params.trialsPerBlock/numel(four0four1)
                vPresent = [vPresent; four0four1(randperm(numel(four0four1)))'];
            end
        end
        
    elseif task==2 %tilt
        if ~params.calibration
            vVertical = [vVertical; random_vec];
        else
            for i_c = 1:params.trialsPerBlock/numel(four0four1)
                vVertical = [vVertical; four0four1(randperm(numel(four0four1)))'];
            end
        end
        vPresent = [vPresent; ones(params.trialsPerBlock,1)];
        vOrient = [vOrient; normrnd(0,1,params.trialsPerBlock,1)];
    end
    
end

%% Randomize event timing

% the trial duration includes extra 0.8 seconds to make the minimum spacing
% between consecutive trials 800 milliseconds.
trial_duration = params.fixation_time + params.display_time...
    + params.time_to_respond + params.time_to_conf+0.8;

% this is the duration (in seconds) of all trials combined + 15 seconds
% for the beginning of each experimental block.
used_time = trial_duration*length(vPresent)+10*length(vTask);

% this is the duration (in seconds) of rest time that can be fiddled with.
spare_time = params.run_duration-used_time;

% to add gitter to all events, first I draw numbers from a uniform
% distribution between 1 and 0, and scale them so that the minimum is 0 and
% the maximum is 1.
gitter_vec = Scale(rand(size(vPresent)));

% I then multiply them by the factor needed to make their total duration
% equal to the spare_time.
gitter_vec = gitter_vec/sum(gitter_vec)*spare_time;

% add the trial duration and the instruction screens to the gitter_vec.
gitter_vec = gitter_vec+trial_duration;
gitter_vec = [0; gitter_vec];
gitter_vec(1:Nsets/Nblocks:end) = gitter_vec(1:Nsets/Nblocks:end)+10;

% now the vector of trial onsets is the serial accumulation of the gitter vec.
vOnset = cumsum(gitter_vec(1:end-1));

if abs(sum(gitter_vec)-params.run_duration-10) > 0.0001 && ~params.calibration
    error('the randomization procedure went wrong')
end

end
