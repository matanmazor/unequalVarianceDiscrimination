function data_struct = loadData(subj_id)
% load data from all participants and arrange in a dictionary

data_struct = containers.Map;
num_included = 0;

% load subject list
load(fullfile('..','experiment','data','subjects.mat'));
if (~exist('subj_id','var'))
    subj_list = subjects.keys;
else
    subj_list = {subj_id};
end

%load data
for i=1:length(subj_list) %don't analyze dummy subject 999MaMa
    subj = subj_list{i};
    if str2num(subj(1:2))<60
        subj_files = dir(fullfile('..','experiment','data',[subj,'_session*_.mat']));
        if ~isempty(subj_files)
            subject_data.DisAlpha = [];
            subject_data.DetAlpha = [];
            subject_data.AngleSigma = [];
            
            subject_data.DisOrientation = [];
            subject_data.DetOrientation = [];
            subject_data.TiltOrientation = [];
            
            subject_data.DisCorrect = [];
            subject_data.DetCorrect = [];
            subject_data.TiltCorrect = [];
            
            subject_data.DisConf = [];
            subject_data.DisConfInc = []; %increase confidence presses
            subject_data.DisConfDec = []; %decrease confidence presses
            subject_data.DetConf = [];
            subject_data.DetConfInc = [];
            subject_data.DetConfDec = [];
            subject_data.TiltConf = [];
            subject_data.TiltConfInc = [];
            subject_data.TiltConfDec = [];
            
            subject_data.DisResp = [];
            subject_data.DetResp = [];
            subject_data.TiltResp = [];
            
            subject_data.DisRT = [];
            subject_data.DetRT = [];
            subject_data.TiltRT = [];
            
            subject_data.vTask = [];
            
            subject_data.DetSignal = [];
            subject_data.DisSignal = [];
            subject_data.TiltSignal = [];
            
            subject_data.DetVertical = [];
            subject_data.DisVertcial = [];
            subject_data.TiltVertical = [];
            
            subject_data.DisInclude = [];
            subject_data.DetInclude = [];
            subject_data.TiltInclude = [];
            
            for j = 1:length(subj_files)
                load(fullfile('..','experiment','data',subj_files(j).name));
                num_trials = length(log.resp);
                num_blocks = num_trials/params.trialsPerBlock;
                log.confidence = log.confidence(1:num_trials);
                log.resp = log.resp(1:num_trials,:);
                log.task = log.task(1:num_trials,:);
                log.correct = log.correct(1:num_trials,:);
                log.Alpha = log.Alpha(1:num_trials);
                params.vTask = params.vTask(1:num_blocks);
                trial_events = find(log.events(:,1)==0);
                if not(length(trial_events)==78)
                    error(sprintf('wrong number of events %d',...
                        length(trial_events)))
                end
                trial_events(79) = length(log.events)+1;
                [up_count, down_count] = deal(nan(78,1));
                for i_t = 1:78
                    down_count(i_t) = sum(abs(...
                        log.events(trial_events(i_t):trial_events(i_t+1)-1,1)-55)<eps);
                    up_count(i_t) = sum(abs(...
                        log.events(trial_events(i_t):trial_events(i_t+1)-1,1)-54)<eps);
                end
                if params.conf_mapping==1
                    inc_count = up_count;
                    dec_count = down_count;
                else
                    inc_count = down_count;
                    dec_count = up_count;
                end
                
                subject_data.DisAlpha = [subject_data.DisAlpha; params.DisAlpha];
                subject_data.DetAlpha = [subject_data.DetAlpha; params.DetAlpha];
                subject_data.AngleSigma = [subject_data.AngleSigma; params.AngleSigma];
                
                subject_data.DisCorrect = [subject_data.DisCorrect; ...
                    log.correct(log.task==0)];
                subject_data.DetCorrect = [subject_data.DetCorrect; ...
                    log.correct(log.task==1)];
                subject_data.TiltCorrect= [subject_data.TiltCorrect; ...
                    log.correct(log.task==2)];
                
                % load confidence reports (same structure)
                subject_data.DisConf = [subject_data.DisConf; ...
                    log.confidence(log.task==0)];
                subject_data.DetConf = [subject_data.DetConf; ...
                    log.confidence(log.task==1)];
                subject_data.TiltConf = [subject_data.TiltConf; ...
                    log.confidence(log.task==2)];
                
                subject_data.DisConfInc = [subject_data.DisConfInc; ...
                    inc_count(log.task==0)];
                subject_data.DetConfInc = [subject_data.DetConfInc; ...
                    inc_count(log.task==1)];
                subject_data.TiltConfInc = [subject_data.TiltConfInc; ...
                    inc_count(log.task==2)];
                
                subject_data.DisConfDec = [subject_data.DisConfDec; ...
                    dec_count(log.task==0)];
                subject_data.DetConfDec = [subject_data.DetConfDec; ...
                    dec_count(log.task==1)];
                subject_data.TiltConfDec = [subject_data.TiltConfDec; ...
                    dec_count(log.task==2)];
                
                subject_data.DisOrientation = [subject_data.DisOrientation; ...
                    log.orientation(log.task==0)];
                subject_data.DetOrientation = [subject_data.DetOrientation; ...
                    log.orientation(log.task==1)];
                subject_data.TiltOrientation = [subject_data.TiltOrientation; ...
                    log.orientation(log.task==2)];
                
                % load responses
                subject_data.DisResp = [subject_data.DisResp; ...
                    log.resp(log.task==0,2)];
                subject_data.DetResp = [subject_data.DetResp; ...
                    log.resp(log.task==1,2)];
                % I'm sorry for this: in the experiment code, a 'vertical'
                % response is coded as 1, and a 'tilted' response as 0. But
                % for analysis, 'tilted' responses are more like detection
                % 'yes' responses (as both are associated with higher 
                % variance), so I flip the labels such that now 1 means
                % 'tilted' and 0 'vertical'. This is the reason that in the
                % following likne there's a 1-response.
                subject_data.TiltResp = ([subject_data.TiltResp; ...
                    1-log.resp(log.task==2,2)]);
                
                %load RTs
                subject_data.DisRT = [subject_data.DisRT; log.resp(log.task==0,1)];
                subject_data.DetRT = [subject_data.DetRT; log.resp(log.task==1,1)];
                subject_data.TiltRT = [subject_data.TiltRT; log.resp(log.task==2,1)];
                
                %load task order vector. 1 for detection, 0 for discrimination
                subject_data.vTask = [subject_data.vTask; params.vTask];
                
                %load trial order vector
                subject_data.DetSignal = [subject_data.DetSignal;
                    log.Alpha(log.task==1)>0];
                subject_data.DisSignal = [subject_data.DisSignal;
                    log.orientation(log.task==0)==45];
                %signal is defined as tilt here.
                subject_data.TiltSignal = [subject_data.TiltSignal;
                    1-params.vVertical(log.task==2)];
                
                %exclusion
                CW_conf = hist(log.confidence(log.task==0 & log.resp(:,2)==1),1:6);
                CCW_conf = hist(log.confidence(log.task==0 & log.resp(:,2)==0),1:6);
                
                Y_conf = hist(log.confidence(log.task==1 & log.resp(:,2)==1),1:6);
                N_conf = hist(log.confidence(log.task==1 & log.resp(:,2)==0),1:6);
                
                V_conf = hist(log.confidence(log.task==2 & log.resp(:,2)==1),1:6);
                T_conf = hist(log.confidence(log.task==2 & log.resp(:,2)==0),1:6);
                
                if sum(isnan(subject_data.DisCorrect(end-25:end)))<6 && ...
                        nanmean(subject_data.DisCorrect(end-25:end))>0.6 && ...
                        abs(nanmean(subject_data.DisResp(end-25:end))-0.5)<0.3 && ...
                        max(CW_conf)/sum(CW_conf)<0.9 && max(CCW_conf)/sum(CCW_conf)<0.9
                    subject_data.DisInclude = [subject_data.DisInclude; 0; ones(25,1)];
                else
                    subject_data.DisInclude = [subject_data.DisInclude; zeros(26,1)];
                end
                
                if sum(isnan(subject_data.DetCorrect(end-25:end)))<6 && ...
                        nanmean(subject_data.DetCorrect(end-25:end))>0.6 && ...
                        abs(nanmean(subject_data.DetResp(end-25:end))-0.5)<0.3 && ...
                        max(Y_conf)/sum(Y_conf)<0.9 && max(N_conf)/sum(N_conf)<0.9
                    subject_data.DetInclude = [subject_data.DetInclude; 0; ones(25,1)];
                else
                    subject_data.DetInclude = [subject_data.DetInclude; zeros(26,1)];
                end
                
                if sum(isnan(subject_data.TiltCorrect(end-25:end)))<6 && ...
                        nanmean(subject_data.TiltCorrect(end-25:end))>0.6 && ...
                        abs(nanmean(subject_data.TiltResp(end-25:end))-0.5)<0.3 && ...
                        max(T_conf)/sum(T_conf)<0.9 && max(V_conf)/sum(V_conf)<0.9
                    subject_data.TiltInclude = [subject_data.TiltInclude; 0; ones(25,1)];
                else
                    if nanmean(subject_data.TiltCorrect(end-25:end))<=0.6
                        sprintf('reason for excluding run %d from %s: accuracy',j, subj)
                    end
                    
                    if abs(nanmean(subject_data.TiltResp(end-25:end))-0.5)>=0.3
                        sprintf('reason for excluding run %d from %s: bias',j, subj)
                    end
                    
                    if max(T_conf)/sum(T_conf)>=0.9
                        sprintf('reason for excluding run %d from %s: confidence in tilted',j, subj)
                    end
                    
                    if max(V_conf)/sum(V_conf)>=0.9
                        sprintf('reason for excluding run %d from %s: confidence in vertical',j, subj)
                    end
                    
                    subject_data.TiltInclude = [subject_data.TiltInclude; zeros(26,1)];
                end
                
            end
            
            %compute bonus
            subject_data.bonus = ((subject_data.DetCorrect(find(~isnan(subject_data.DetConf)))-0.5)'...
                *subject_data.DetConf(find(~isnan(subject_data.DetConf)))+...
                (subject_data.DisCorrect(find(~isnan(subject_data.DisConf)))-0.5)'...
                *subject_data.DisConf(find(~isnan(subject_data.DisConf)))+...
                (subject_data.TiltCorrect(find(~isnan(subject_data.TiltConf)))-0.5)'...
                *subject_data.TiltConf(find(~isnan(subject_data.TiltConf))))/100;
            
            
            if sum(subject_data.DetInclude)>=75 && ...
                    sum(subject_data.DisInclude)>=75 && ...
                    sum(subject_data.TiltInclude)>=75
                subject_data.include = 1;
                num_included = num_included+1;
            else
                subject_data.include=0;
                if sum(subject_data.DetInclude)<75
                    sprintf('reason for excluding %s: detection',subj)
                end
                
                if sum(subject_data.DisInclude)<75
                    sprintf('reason for excluding %s: discrimination',subj)
                end
                
                if sum(subject_data.TiltInclude)<75
                    sprintf('reason for excluding %s: tilt',subj)
                end
            end
            
            data_struct(subj)=subject_data;
            
        end
    end
end
num_included
end

