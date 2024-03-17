%load the scmos data & mask 
load("./raw_data/fig3_scmos_video.mat");


figure(1)
imagesc(sum(scmos_video,3)/length(scmos_video),[100 140]); colormap(gray);
cell_roi = roipoly;

%%
scmos_fullroi_raw = zeros(1,7000);
for i=1:7000
   tmp = -1*scmos_video(:,:,i); 
   scmos_fullroi_raw(i) = sum(sum(tmp.*cell_roi))/sum(sum(cell_roi));
end

bpFilt = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',0.05,'HalfPowerFrequency2',360, 'SampleRate',800);

scmos_bp_filt =  filtfilt(bpFilt, scmos_fullroi_raw); 

figure(2)
plot(scmos_bp_filt(100:end));
title('scmos time series @ 800Hz')