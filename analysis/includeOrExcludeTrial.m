function [inclusion] = includeOrExcludeTrial(log, i_t);
inclusion = 1;
this_task = log.task(i_t);

if mod(i_t,26)==1
    inclusion=0;
end

if sum(isnan(log.correct(log.task==this_task)))>5
    inclusion = 0;
end

if nanmean(log.correct(log.task==this_task))<0.6
    inclusion = 0;
end

conf0 = hist(log.confidence(log.task==this_task & log.resp(:,2)==0),1:6);
conf1 = hist(log.confidence(log.task==this_task & log.resp(:,2)==1),1:6);

if max(conf0)/sum(conf0)>0.9 | max(conf1)/sum(conf1)>0.9
    inclusion = 0;
end
    

