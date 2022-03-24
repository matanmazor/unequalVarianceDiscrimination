function [resp1] = displayResps(task,response,display)

global w
global params

if task ==0 %discrimination
    if display
        Screen('DrawTexture', w, params.vertTexture, [], params.positions{params.clockwise},...
            45,[],0.5+0.5*(response(2)==1))
        Screen('DrawTexture', w, params.vertTexture, [], params.positions{3-params.clockwise},...
            -45,[],0.5+0.5*(response(2)==0))
    end
    resp1 = params.clockwise;
    
elseif task==1 %detection
    if display
        Screen('DrawTexture', w, params.yesTexture, [], params.positions{params.yes}, ...
            [],[], 0.5+0.5*(response(2)==1))
        Screen('DrawTexture', w, params.noTexture, [], params.positions{3-params.yes},...
            [],[], 0.5+0.5*(response(2)==0))
    end
    resp1 = params.yes;
    
elseif task==2 %tilt
    if display
        Screen('DrawTexture', w, params.vertTexture, [], params.positions{params.vertical},...
            [],[],0.5+0.5*(response(2)==1))
        Screen('DrawTexture', w, params.xTexture, [], params.positions{3-params.vertical},...
            [],[],0.5+0.5*(response(2)==0))
    end
    resp1 = params.vertical;
    
end

end

