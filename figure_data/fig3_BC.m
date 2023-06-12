%load data
load('./raw_data/pecmos_65Hz.mat'); 
load('./raw_data/pecmos_130Hz.mat'); 
load('./raw_data/pecmos_260Hz.mat'); 
load('./raw_data/pecmos_520Hz.mat'); 

%%
figure(1); 
subplot(1,4,1); 
imagesc(sum(pcmos_65Hz,3)/length(pcmos_65Hz),[0 1000]); colormap(gray); 
title('65 Hz, pixel scale 0-1000')

subplot(1,4,2); 
imagesc(sum(pcmos_130Hz,3)/length(pcmos_130Hz),[0 700]); colormap(gray); 
title('130 Hz, pixel scale 0-700')

subplot(1,4,3); 
imagesc(sum(pcmos_260Hz,3)/length(pcmos_260Hz),[0 500]); colormap(gray); 
title('260 Hz, pixel scale 0-500')

subplot(1,4,4); 
imagesc(sum(pcmos_520Hz,3)/length(pcmos_520Hz),[0 300]); colormap(gray); 
title('520 Hz, pixel scale 0-300')

set(gcf,'color','white'); box off;
set(gcf,'position',[50,50,1200,300])
% select an ROI
cell_roi = roipoly; 

%%
x_520Hz = zeros(1,length(pcmos_520Hz)); 
for i=1:length(pcmos_520Hz)
   tmp = -1*pcmos_520Hz(:,:,i); 
   x_520Hz(i) = sum(sum(tmp.*cell_roi))/sum(sum(cell_roi));
end

x_260Hz = zeros(1,length(pcmos_260Hz)); 
for i=1:length(pcmos_260Hz)
   tmp = -1*pcmos_260Hz(:,:,i); 
   x_260Hz(i) = sum(sum(tmp.*cell_roi))/sum(sum(cell_roi));
end

x_130Hz = zeros(1,length(pcmos_130Hz)); 
for i=1:length(pcmos_130Hz)
   tmp = -1*pcmos_130Hz(:,:,i); 
   x_130Hz(i) = sum(sum(tmp.*cell_roi))/sum(sum(cell_roi));
end

x_65Hz = zeros(1,length(pcmos_65Hz)); 
for i=1:length(pcmos_65Hz)
   tmp = -1*pcmos_65Hz(:,:,i); 
   x_65Hz(i) = sum(sum(tmp.*cell_roi))/sum(sum(cell_roi));
end

% correction for offsets
[y_520Hz, y_260Hz, y_130Hz, y_65Hz] = offset_correction(x_520Hz, x_260Hz, x_130Hz, x_65Hz);


%% signal % noise filtering
d0 = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',0.1,'HalfPowerFrequency2',520/2*0.9, 'SampleRate', 520);
d1 = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',0.1,'HalfPowerFrequency2',260/2*0.9, 'SampleRate', 260);
d2 = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',0.1,'HalfPowerFrequency2',130/2*0.9, 'SampleRate', 130);
d3 = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',0.1,'HalfPowerFrequency2',65/2*0.9, 'SampleRate', 65);

d0_noise = designfilt('highpassiir','FilterOrder',4, ...
         'HalfPowerFrequency',10, 'SampleRate', 520);
d1_noise = designfilt('highpassiir','FilterOrder',4, ...
         'HalfPowerFrequency',10, 'SampleRate', 260);
d2_noise = designfilt('highpassiir','FilterOrder',4, ...
         'HalfPowerFrequency',10, 'SampleRate', 130);
d3_noise = designfilt('highpassiir','FilterOrder',4, ...
         'HalfPowerFrequency',10, 'SampleRate', 65);     

y_520Hz_filt =  filtfilt(d0, y_520Hz); 
y_260Hz_filt =  filtfilt(d1, y_260Hz)/2; 
y_130Hz_filt =  filtfilt(d2, y_130Hz)/4; 
y_65Hz_filt  =   filtfilt(d3, y_65Hz)/8; %with normaliztion added

y_520Hz_noise =  filtfilt(d0_noise, y_520Hz); 
y_260Hz_noise =  filtfilt(d1_noise, y_260Hz/2); 
y_130Hz_noise =  filtfilt(d2_noise, y_130Hz/4); 
y_65Hz_noise  =  filtfilt(d3_noise, y_65Hz/8); 

%time range 
xlow = 20;   %670; %200; %675; %210; %680; 
xhigh = 800; %715; %300; %715; %229; %780; 

%noise range
xnoise_low = 340; 
xnoise_high = 470;

figure(8)
x1 = subplot(4,1,1);
plot([1:length(y_520Hz_filt(xlow*8:xhigh*8))]*1/520, y_520Hz_filt(xlow*8:xhigh*8),'LineWidth',1); hold on; 
stem(5*std(y_520Hz_noise(xnoise_low*8:xnoise_high*8))); hold off; 
xlabel('Seconds');
title('1/4 ROI time series (520 Hz)'); 
legend('Full ROI', 'SNR 5');
xlim([0 12]);
box off;

x2 = subplot(4,1,2);
plot([1:length(y_260Hz_filt(xlow*4:xhigh*4))]*1/260, y_260Hz_filt(xlow*4:xhigh*4),'LineWidth',1); hold on; 
stem(5*std(y_260Hz_noise(xnoise_low*4:xnoise_high*4))); hold off; 
title('1/4 ROI time series (260 Hz)'); 
xlim([0 12]);
box off;

x3 = subplot(4,1,3);
plot([1:length(y_130Hz_filt(xlow*2:xhigh*2))]*1/130, y_130Hz_filt(xlow*2:xhigh*2),'LineWidth',1);hold on; 
stem(5*std(y_130Hz_noise(xnoise_low*2:xnoise_high*2))); hold off; 
title('1/4 ROI time series (130 Hz)'); 
xlim([0 12]);
box off;

x4 = subplot(4,1,4);
plot([1:length(y_65Hz_filt(xlow:xhigh))]*1/65, y_65Hz_filt(xlow:xhigh),'LineWidth',1);hold on; 
stem(5*std(y_65Hz_noise(xnoise_low:xnoise_high))); hold off; 
title('1/4 ROI time series (65 Hz)'); 
xlim([0 12]);
linkaxes([x1 x2 x3 x4],'xy')
set(gcf,'color','white'); 
box off;



