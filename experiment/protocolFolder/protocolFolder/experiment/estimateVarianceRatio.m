function [detRatio,disRatio] = estimateVarianceRatio(log)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

conf_vec = log.confidence;
conf_vec(log.resp(:,2)==0) = 7-log.confidence(log.resp(:,2)==0);
conf_vec(log.resp(:,2)==1) = log.confidence(log.resp(:,2)==1)+6;

%% detection
nR_signal = nan(1,12);
nR_noise = nan(1,12);

for i = 1:12
    nR_signal(i) = sum(conf_vec==i & log.Alpha>0 & log.detection==1);
    nR_noise(i) = sum(conf_vec==i & log.Alpha==0 & log.detection==1);
end

p_signal = cumsum(nR_signal)/sum(nR_signal);
p_noise = cumsum(nR_noise)/sum(nR_noise);

idx = find(p_signal>0 & p_noise>0 & p_signal<1 & p_noise<1);

z_signal = norminv(p_signal(idx));
z_noise = norminv(p_noise(idx));

det_coefs = polyfit(z_noise',z_signal',1);
detRatio = det_coefs(1);

%% discrimination
nR_tilt = nan(1,12);
nR_vert = nan(1,12);

for i = 1:12
    nR_tilt(13-i) = sum(conf_vec==i & log.Orientation'~=0 & log.detection==0);
    nR_vert(13-i) = sum(conf_vec==i & log.Orientation'==0 & log.detection==0);
end

p_tilt = cumsum(nR_tilt)/sum(nR_tilt);
p_vert = cumsum(nR_vert)/sum(nR_vert);

idx = find(p_vert>0 & p_tilt>0 & p_vert<1 & p_tilt<1);

z_tilt = norminv(p_tilt(idx));
z_vert = norminv(p_vert(idx));

dis_coefs = polyfit(z_vert',z_tilt',1);
disRatio = dis_coefs(1);
end

