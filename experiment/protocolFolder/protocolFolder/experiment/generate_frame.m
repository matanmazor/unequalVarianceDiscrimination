function [target, stimulus] = generate_frame(image, p)

global w
global params

%create a random array of grayscale values
stimulus = 255*rand(size(image));

%create an array with p ones and the rest zeros
p_mask = p*ones(size(image));
take_image_value = binornd(1,p_mask)>0;

%change these pixels to target pixels
stimulus(take_image_value) = image(take_image_value);

%make a texture
target = Screen('MakeTexture',w,cat(3, repmat(stimulus,1,1,3),...
255*Scale(params.circleFilter)));

end

