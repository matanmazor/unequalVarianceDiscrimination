function  [ax1,ax2, ax3, coefs, R2_mat] = plotQuadFit(project_params, subjects, ROI_label, ROI_name, single_trials)

if nargin==4
    single_trials=0;
end

addpath('D:\Documents\software\cbrewer') %for color
addpath('D:\Documents\software\sigstar') %for significance
[cb] = cbrewer('qual','Set1',10,'pchip');

if single_trials
    [ax1_ROI,ax2_ROI, ax3_ROI, coefs] = printConfByRespSingleTrialModel(project_params, subjects, ROI_label, ROI_name);
else
    [ax1_ROI,ax2_ROI, ax3_ROI, coefs, R2_mat] = printConfByResp(project_params, subjects, ROI_label, ROI_name);
end
fig = figure;

ax1 = subplot(2,3,2);
copyobj(get(ax1_ROI,'children'),ax1);
xticks(1:6); xlim([0.5,6.5]); xlabel('confidence'); 
title('Detection');
children = get(ax1,'children');
% legend([children(2),children(3)],{'yes','no'})


ax2 = subplot(2,3,1);
copyobj(get(ax2_ROI,'children'),ax2);
xticks(1:6); xlim([0.5,6.5]);  xlabel('confidence'); 
ylabel([ROI_name, ' mean \beta']);
title('Discrimination')
linkaxes([ax1,ax2],'y')
children = get(ax2,'children');
% legend([children(2),children(3)],{'CW','CCW'})

ax3 = subplot(2,3,3);
copyobj(get(ax3_ROI,'children'),ax3);
xticks(1:6); xlim([0.5,6.5]); xlabel('confidence'); 
title('Tilt recognition');
children = get(ax1,'children');

% legend([children(2),children(3)],{'CW','CCW'})

ax4 = subplot(2,3,4:6); hold on;

il = 1; %initial lag
ipg = 1; %interpolynomic gap
itg = 4 %intertask gap


b_C = bar([il+1,il+3+ipg],[nanmean(coefs(:,2,4)) nanmean(coefs(:,1,4))],...
    'FaceColor',cb(3,:),'BarWidth',0.25);
errorbar([il+1,il+3+ipg],[nanmean(coefs(:,2,4)) nanmean(coefs(:,1,4))],...
    [nanstd(coefs(:,2,4)) nanstd(coefs(:,1,4))]./sqrt(35),'.k')

b_A = bar([il+2,il+4+ipg],[nanmean(coefs(:,2,3)) nanmean(coefs(:,1,3))],...
    'FaceColor',cb(4,:),'BarWidth',0.25);
errorbar([il+2,il+4+ipg],[nanmean(coefs(:,2,3)) nanmean(coefs(:,1,3))],...
    [nanstd(coefs(:,2,3)) nanstd(coefs(:,1,3))]./sqrt(35),'.k')


b_yes = bar([il+5+ipg+itg,il+7+2*ipg+itg],[nanmean(coefs(:,2,1)) nanmean(coefs(:,1,1))],...
    'FaceColor',cb(2,:),'BarWidth',0.25);
errorbar([il+5+ipg+itg,il+7+2*ipg+itg],[nanmean(coefs(:,2,1)) nanmean(coefs(:,1,1))], ...
    [nanstd(coefs(:,2,1)) nanstd(coefs(:,1,1))]./sqrt(35),'.k');

b_no = bar([il+6+ipg+itg,il+8+2*ipg+itg],[nanmean(coefs(:,2,2)) nanmean(coefs(:,1,2))],...
    'FaceColor',cb(1,:),'BarWidth',0.25);
errorbar([il+6+ipg+itg,il+8+2*ipg+itg],[nanmean(coefs(:,2,2)) nanmean(coefs(:,1,2))],...
    [nanstd(coefs(:,2,2)) nanstd(coefs(:,1,2))]./sqrt(35),'.k');


b_T = bar([il+9+2*ipg+2*itg,il+11+3*ipg+2*itg],[nanmean(coefs(:,2,5)) nanmean(coefs(:,1,4))],...
    'FaceColor',cb(6,:),'BarWidth',0.25);
errorbar([il+9+2*ipg+2*itg,il+11+3*ipg+2*itg],[nanmean(coefs(:,2,5)) nanmean(coefs(:,1,4))],...
    [nanstd(coefs(:,2,5)) nanstd(coefs(:,1,5))]./sqrt(35),'.k')

b_V = bar([il+10+2*ipg+2*itg,il+12+3*ipg+2*itg],[nanmean(coefs(:,2,6)) nanmean(coefs(:,1,3))],...
    'FaceColor',cb(7,:),'BarWidth',0.25);
errorbar([il+10+2*ipg+2*itg,il+12+3*ipg+2*itg],[nanmean(coefs(:,2,6)) nanmean(coefs(:,1,3))],...
    [nanstd(coefs(:,2,6)) nanstd(coefs(:,1,6))]./sqrt(35),'.k')
ylabel('coefficient value (a.u.)');

yticks(0);
xticks([il+1.5,il+3.5+ipg, ...
    il+5.5+ipg+itg,il+7.5+2*ipg+itg, ...
    il+9.5+2*ipg+2*itg,il+11.5+3*ipg+2*itg]); 
xticklabels({'lin.','quad.', 'lin.','quad.', 'lin.','quad.', 'lin.','quad.'});
ylabel('coefficient');
xlim([-1,il+14+3*ipg+2*itg]);
s=hgexport('readstyle','presentation');
s.Format = 'png'; 
s.Width = 20;
s.Height = 12;

if single_trials
    hgexport(gcf,['figures/',ROI_label,'single_trials_coefficients'],s);
else
    hgexport(gcf,['figures/',ROI_label,'coefficients'],s);
end

end

