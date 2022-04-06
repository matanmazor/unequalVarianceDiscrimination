function [] = compareCoefs(coefs) % coefs is subj x degree (2,1,0) x resp (Y,N,A,C,T,V)
    
    global_coefs = nanmean(coefs,3);
    det_resp_coefs = squeeze(coefs(:,:,1)-coefs(:,:,2));
    tilt_resp_coefs = squeeze(coefs(:,:,5)-coefs(:,:,6));
    dis_resp_coefs = squeeze(coefs(:,:,2)-coefs(:,:,3));
    
    linear_coefs = squeeze(coefs(:,2,:));
    linear_coefs(isnan(sum(linear_coefs,2)),:)=[];
    
    quad_coefs = squeeze(coefs(:,1,:));
    quad_coefs(isnan(sum(quad_coefs,2)),:)=[];


    task_coefs = nanmean(coefs(:,:,1:2),3)-nanmean(coefs(:,:,3:4),3);
    detection_coefs = nanmean(coefs(:,:,1:2),3);
    discrimination_coefs = nanmean(coefs(:,:,3:4),3);
    disc_resp_coefs = squeeze(coefs(:,:,3)-coefs(:,:,4));

    [~,linear_global_p,~,liner_global_stats] = ttest(global_coefs(:,2));
    [~,quad_global_p,~,quad_global_stats] = ttest(global_coefs(:,1));
    
    [~,linear_det_resp_p,~,linear_det_resp_stats] = ttest(det_resp_coefs(:,2));
    [~,quad_det_resp_p,~,quad_det_resp_stats] = ttest(det_resp_coefs(:,1));
    
    [~,linear_tilt_resp_p,~,linear_tilt_resp_stats] = ttest(tilt_resp_coefs(:,2));
    [~,quad_tilt_resp_p,~,quad_tilt_resp_stats] = ttest(tilt_resp_coefs(:,1));
    
    [~,linear_dis_resp_p,~,linear_dis_resp_stats] = ttest(dis_resp_coefs(:,2));
    [~,quad_dis_resp_p,~,quad_dis_resp_stats] = ttest(dis_resp_coefs(:,1));
    
    linear_anova = anova2(linear_coefs);
    linear_task_p = linear_anova(1);
    quad_anova = anova2(quad_coefs);
    quad_task_p = quad_anova(1);
    
    

end
