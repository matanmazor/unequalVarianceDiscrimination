function [image] = generate_stim(params, num_trial)
%{ 
 GENERATE_STIM takes as input the parameter structure and the trial number
 and returns the target texture.
 largely based on a script used for 
 Fleming, S. M., Maniscalco, B., Ko, Y., Amendi, N., Ro, T., & Lau, H.
   (2015). Action-specific disruption of perceptual confidence. 
   Psychological science, 26(1), 89-98.
 Matan Mazor 2019
%}

global task
global log

if task  ==0
    theta = params.vOrient(num_trial);
else
    theta = params.vOrient(num_trial)*(1-params.vVertical(num_trial))*...
        params.AngleSigma(end);
end
log.orientation(num_trial) = theta;

% make target patch
[target_xy, mask]  = makeGrating(params.stimulus_width_px,[],1,...
    params.cycle_length_px,'pixels per period','vertical',...
    params.vPhase(num_trial), theta);

image = 255*Scale(target_xy);

end

