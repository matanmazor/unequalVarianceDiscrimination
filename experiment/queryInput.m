function keysPressed = queryInput()
% QUERYINPUT Query input from button box/scanner and write to log.
% Matan Mazor 2018

global log
global global_clock
global pressed
global params

if params.scanning
    [ ~, keysPressed]= KbQueueCheck;
    for i=1:length(find(keysPressed))
        key_vec = find(keysPressed,i);
        log.events = [log.events; key_vec(end) toc(global_clock)];
    end
else
    [keyIsDown, secs, keysPressed] = KbCheck();
    if ~keyIsDown
        pressed = 0;
    elseif pressed == 0
        for i=1:length(find(keysPressed))
            key_vec = find(keysPressed,i);
            log.events = [log.events; key_vec(end) toc(global_clock)];
        end
        pressed = 1;
    else
        keysPressed = zeros(size(keysPressed));
    end
    
    if keysPressed(KbName('ESCAPE'))
        Screen('CloseAll');
    end
    
end

