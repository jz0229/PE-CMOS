% load the data
load('./raw_data/fig2_B_vid.mat');

%plot max. projection and select ROI
figure(2)
max_proj_img = sum(scmos_vid,3)/length(scmos_vid);
imagesc(max_proj_img); colormap(gray);
title('max project image');
set(gcf,'color','white'); box off;
set(gcf,'position',[50,50,350,640])
cell_roi = roipoly;

%%
%make 4 mask each selecting 1/4 of ROI to compare with pCMOS at differe phase
mask_phase_1 = zeros(size(max_proj_img)); 
for r=1:2:size(mask_phase_1,1)
    for c=1:2:size(mask_phase_1,2)
        mask_phase_1(r,c) = 1; 
    end
end

mask_phase_2 = zeros(size(max_proj_img)); 
for r=1:2:size(mask_phase_2,1)
    for c=2:2:size(mask_phase_2,2)
        mask_phase_2(r,c) = 1; 
    end
end

mask_phase_3 = zeros(size(max_proj_img)); 
for r=2:2:size(mask_phase_3,1)
    for c=1:2:size(mask_phase_3,2)
        mask_phase_3(r,c) = 1; 
    end
end

mask_phase_4 = zeros(size(max_proj_img)); 
for r=2:2:size(mask_phase_4,1)
    for c=2:2:size(mask_phase_4,2)
        mask_phase_4(r,c) = 1; 
    end
end

%% getting the time series 
scmos_fullroi_raw = zeros(1,length(scmos_vid));
scmos_qroi_1_raw = zeros(1,length(scmos_vid));
scmos_qroi_2_raw = zeros(1,length(scmos_vid));
scmos_qroi_3_raw = zeros(1,length(scmos_vid));
scmos_qroi_4_raw = zeros(1,length(scmos_vid));

for i=1:length(scmos_vid)
   tmp = -1*scmos_vid(:,:,i); 
   
   %1/4 ROI
   scmos_qroi_1_raw(i)  = sum(sum(tmp.*cell_roi.*mask_phase_1))/sum(sum(cell_roi.*mask_phase_1));
   scmos_qroi_2_raw(i)  = sum(sum(tmp.*cell_roi.*mask_phase_2))/sum(sum(cell_roi.*mask_phase_1));
   scmos_qroi_3_raw(i)  = sum(sum(tmp.*cell_roi.*mask_phase_3))/sum(sum(cell_roi.*mask_phase_1));
   scmos_qroi_4_raw(i)  = sum(sum(tmp.*cell_roi.*mask_phase_4))/sum(sum(cell_roi.*mask_phase_1));
   
   %full ROI
   scmos_fullroi_raw(i) = sum(sum(tmp.*cell_roi))/sum(sum(cell_roi));
end


%signal bandpass filter (0.5-360Hz)
bpFilt = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',360,'SampleRate',800);  
     
%noise estimation bandpass filter (50 Hz HP cutoff)
bpFilt_noise = designfilt('highpassiir','FilterOrder',4, ...
         'HalfPowerFrequency',50, 'SampleRate',800);
     
%filter full ROI time series and noise (also invert the signal)
gevi_scmos_fullroi =  filtfilt(bpFilt,scmos_fullroi_raw(10:end-10));
fullroi_noise = filtfilt(bpFilt_noise,scmos_fullroi_raw(10:end-10));

%filter 1/4 ROI time series and noise 
gevi_scmos_1_qroi =  filtfilt(bpFilt,scmos_qroi_1_raw(10:end-10));
gevi_scmos_2_qroi =  filtfilt(bpFilt,scmos_qroi_2_raw(10:end-10));
gevi_scmos_3_qroi =  filtfilt(bpFilt,scmos_qroi_3_raw(10:end-10));
gevi_scmos_4_qroi =  filtfilt(bpFilt,scmos_qroi_4_raw(10:end-10));

qroi_noise_1 = filtfilt(bpFilt_noise,scmos_qroi_1_raw(10:end-10));
qroi_noise_2 = filtfilt(bpFilt_noise,scmos_qroi_2_raw(10:end-10));
qroi_noise_3 = filtfilt(bpFilt_noise,scmos_qroi_3_raw(10:end-10));
qroi_noise_4 = filtfilt(bpFilt_noise,scmos_qroi_4_raw(10:end-10));

%calculate noise std
noise_range = [2800:4400];
full_noise_std = std(fullroi_noise(noise_range));
qroi_noise_1_std = std(qroi_noise_1(noise_range));
qroi_noise_2_std = std(qroi_noise_2(noise_range));
qroi_noise_3_std = std(qroi_noise_3(noise_range));
qroi_noise_4_std = std(qroi_noise_4(noise_range));


%% plotting 1/4 ROI signals
figure(2);
x1 = subplot(2,2,1); 
x_range = [1300:3000];
plot((1:length(gevi_scmos_1_qroi(x_range)))*1/800, gevi_scmos_1_qroi(x_range)); hold on; 
stem(0, 5*qroi_noise_1_std); hold off; 
title('1/4 ROI time series'); 
legend('Full ROI', 'SNR 5'); 
xlabel('Seconds'); 
box off;

x2 = subplot(2,2,2); 
plot((1:length(gevi_scmos_2_qroi(x_range)))*1/800, gevi_scmos_2_qroi(x_range)); hold on; 
stem(0, 5*qroi_noise_2_std); hold off; 
box off;

x3 = subplot(2,2,3); 
plot((1:length(gevi_scmos_3_qroi(x_range)))*1/800, gevi_scmos_3_qroi(x_range)); hold on; 
stem(0, 5*qroi_noise_3_std); hold off; 
box off;

x4 = subplot(2,2,4); 
plot((1:length(gevi_scmos_4_qroi(x_range)))*1/800, gevi_scmos_4_qroi(x_range)); hold on; 
stem(0, 5*qroi_noise_4_std); hold off; 
set(gcf,'color','white');
box off;

linkaxes([x1 x2 x3 x4],'xy');

%% plotting the full ROI
figure(3); 
plot((1:length(gevi_scmos_fullroi(x_range)))*1/800, gevi_scmos_fullroi(x_range)); hold on; 
stem(0, 5*full_noise_std); hold off; 
title('Full ROI time series'); 
legend('Full ROI', 'SNR 5'); 
set(gcf,'color','white');
box off;


