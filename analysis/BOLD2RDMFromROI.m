function [] = BOLD2RDMFromROI(project_params,which_subjects,metric)
% For each ROI, extract a 12x12x35 matrix of RDMs by subjects, using the
% specified metric and averaged across runs. 
% any metric that makes pdist2 happy would work here 
% ('euclidean', 'correlation', 'spearman', etc.) - we used 'euclidean'

base_dir = fullfile('..','data','ROI_data','forRSA');
target_dir = fullfile('..','analyzed','RSA');

if ~isdir(target_dir)
    mkdir(target_dir)
end

conditions = {'C_H','C_L','A_H','A_L',...
    'Y_H','Y_L','N_H','N_L',...
    'T_H','T_L','V_H','V_L'};
participants = readtable(fullfile('..','data','participants.csv'));

load('cb.mat');


%initialize
RDM = nan(12,12,max(which_subjects));
ROIs = {'FPl','FPm','BA46','vmPFC','rTPJ','rSTS','preSMA'};

for i_ROI = 1:7
    ROI = ROIs{i_ROI};
    for i_s=which_subjects

        subj_id=participants.participant_id{i_s};
        %these are the same files that are shared in our github repo in
        %data/ROI_data
        roi=load(fullfile(base_dir,subj_id,[ROI,'_bold.mat']));

        %start filling in the RDM
        for cond1=1:12
            cond1_activations = roi.BOLD(conditions{cond1});
            for cond2 = 1:12
                cond2_activations = roi.BOLD(conditions{cond2});
                distances = nan(5,1);
                for i_run=1:5
                    cond1_run_activation = cond1_activations(i_run,:);
                    if any(~isnan(cond1_run_activation))
                        cond2_averaged_activation = nanmean(cond2_activations(setdiff(1:6,i_run),:));
                        distances(i_run) = pdist2(cond1_run_activation,cond2_averaged_activation,metric);
                    end
                end
                RDM(cond1,cond2,i_s)=nanmean(distances);
            end
        end
    end
    
    %make the RDM symmetric by computing the mean of the RDM and the
    %transpose RDM
    RDM = mean(cat(4,RDM,permute(RDM,[2,1,3])),4);
    
    if ~isdir(fullfile(target_dir,metric))
        mkdir(fullfile(target_dir,metric))
    end
    save(fullfile(target_dir,metric,[ROI,'_RDM.mat']),'RDM');
    
    %produce plot
    mean_RDM = squeeze(nanmean(RDM,3));
    symmetric1 = triu(mean_RDM)+triu(mean_RDM)'-eye(size(mean_RDM)).*mean_RDM;
    symmetric2 = tril(mean_RDM)+tril(mean_RDM)'-eye(size(mean_RDM)).*mean_RDM;
    symmetric_RDM = 0.5*symmetric1+0.5*symmetric2;
    symmetric_RDM(find(eye(size(symmetric_RDM))))=0;
    [Y,e] = cmdscale(symmetric_RDM,2);
    
    fig=figure;
    set(gca,'XColor','none')
    hold on;
    ms=70;
    
    scatter(Y(1,1),Y(1,2), ms, cb(3,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(2,1),Y(2,2), ms, cb(3,:), 'filled','MarkerEdgeColor',cb(3,:),'MarkerFaceAlpha',0.2)
    
    scatter(Y(3,1),Y(3,2), ms, cb(4,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(4,1),Y(4,2), ms, cb(4,:), 'filled','MarkerEdgeColor',cb(4,:),'MarkerFaceAlpha',0.2)
    
    scatter(Y(5,1),Y(5,2), ms, cb(2,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(6,1),Y(6,2), ms, cb(2,:), 'filled','MarkerEdgeColor',cb(2,:),'MarkerFaceAlpha',0.2) 

    scatter(Y(7,1),Y(7,2), ms, cb(1,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(8,1),Y(8,2), ms, cb(1,:), 'filled','MarkerEdgeColor',cb(1,:),'MarkerFaceAlpha',0.2) 
    
    scatter(Y(9,1),Y(9,2), ms, cb(6,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(10,1),Y(10,2), ms, cb(6,:), 'filled','MarkerEdgeColor',cb(6,:),'MarkerFaceAlpha',0.2) 
    
    scatter(Y(11,1),Y(11,2), ms, cb(7,:), 'filled','MarkerEdgeColor','k')
    scatter(Y(12,1),Y(12,2), ms, cb(7,:), 'filled','MarkerEdgeColor',cb(7,:),'MarkerFaceAlpha',0.2) 
        
 
%     text(Y(:,1),Y(:,2),conditions)
%     title([ROI,': ',metric])
%     xticks([]);
%     yticks([]);
%     axis off;
%     
%     s=hgexport('readstyle','presentation');
%     s.Format = 'png';
%     s.Width = 10;
%     s.Height = 10;

%     hgexport(fig,fullfile('figures','rsa',[ROI,'_',metric]),s);
f = gcf;

if ~isdir(fullfile('figures','rsa'))
    mkdir(fullfile('figures','rsa'))
end

exportgraphics(f,fullfile('figures','rsa',[ROI,'_',metric,'.png']),'Resolution',300)

end

