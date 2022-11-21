function [table] = countThumbPresses(table)
% count the number of thumb presses per trial

n_events = length(table.key_id);
num_thumb_presses = cell(n_events,1);
trial_index=0; %this is necessary because some participants click before the experiment starts.

for i=1:n_events

    trial_type = table.trial_type(i,:);

    if any(strcmp({'NN', 'NY', 'YY','YN',...
            'CA','AA','CC','AC',...
            'VT','TV','TT','VV'},trial_type(1:2)))

        % this is a trial!
        trial_index = i;
        num_thumb_presses{trial_index}=0;
    
    else
        num_thumb_presses{i} = 'n/a';
        if strcmp(trial_type, 'button press') & any([54,55]==str2num(table.key_id(i,:)))
            %this is a thumb press!
            if (trial_index~=0)
                num_thumb_presses{trial_index} = num_thumb_presses{trial_index}+1;
            end
        end
    end

end
table.num_thumb_presses=num_thumb_presses;
end