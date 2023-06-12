%
load('./raw_data/fig2_H_vid.mat'); 
load('./raw_data/fig2_H_mask.mat');

%%
%draw an ROI
figure(1)
imagesc(sum(pcmos_vid,3)/length(pcmos_vid), [300 800]); colormap(gray); 
title('Max. Project of the pCMOS video'); 
set(gcf,'color','white'); box off;
set(gcf,'position',[50,50,350,640])
cell_roi = roipoly; 

%% return the mask and signal at all the phase
time_range = 1:3000;
[Ph0, Ph1, Ph2, Ph3, mask, ~] = get_pixel_phase(pcmos_mask(:,:,1), pcmos_vid, time_range, cell_roi);

%% display 
mask_roi = (mask).*(cell_roi);
c = lines(5);
c(3,:) = c(1,:); 
c(1,:) = [0 0 0];

sum_img = sum(pcmos_vid,3)/length(pcmos_vid);
figure(2); 
a = subplot(1,2,1); 
imagesc(sum_img(10:end,1:50), [300 800]); colormap(gray); 
title('Max. Project of the pCMOS video'); 
b = subplot(1,2,2); 
imagesc(mask_roi(10:end,1:50)); 
colormap(a,gray); colormap(b,c); 
title('Pixel phases with the ROI'); 
%% setup the filters 
%bandpass filter (0.5Hz - 90Hz) for 200 Hz pCMOS pixels (100 Hz Nyquist)
bpFilt = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',90, 'SampleRate',200);

%high pass (>50 Hz) to eliminte all high amplitude oscillations at low
%frequency
hpFilt_noise = designfilt('highpassiir','FilterOrder',4, ...
         'HalfPowerFrequency',50, 'SampleRate',200);

%filtering the pCMOS output
Ph0_filt =  filtfilt(bpFilt, Ph0);
Ph1_filt =  filtfilt(bpFilt, Ph1);
Ph2_filt =  filtfilt(bpFilt, Ph2);
Ph3_filt =  filtfilt(bpFilt, Ph3);

%filtering to caluclate noise std
Ph0_noise =  filtfilt(hpFilt_noise, Ph0);
Ph1_noise =  filtfilt(hpFilt_noise, Ph1);
Ph2_noise =  filtfilt(hpFilt_noise, Ph2);
Ph3_noise =  filtfilt(hpFilt_noise, Ph3);

xlow = 1;
xhigh = 3000; 
x_range = [100:1000];

%min max for display
ylo = min([Ph0_filt(x_range) Ph1_filt(x_range) Ph2_filt(x_range) Ph3_filt(x_range)]); 
yhi = max([Ph0_filt(x_range) Ph1_filt(x_range) Ph2_filt(x_range) Ph3_filt(x_range)]);

figure(3)
x1 = subplot(2,2,1); 
plot(x_range*1/200, Ph0_filt(x_range), 'LineWidth',1); 
ylim([ylo yhi]);
title('Phase 0 outputs');
set(gcf,'color','white');
box off;
xlabel('Time (s)');

x2 = subplot(2,2,2); 
plot(x_range*1/200, Ph1_filt(x_range), 'LineWidth',1);
ylim([ylo yhi]);

title('Phase 1 outputs');
set(gcf,'color','white');
box off;
x3 = subplot(2,2,3); 
plot(x_range*1/200, Ph2_filt(x_range), 'LineWidth',1);
ylim([ylo yhi]);

title('Phase 2 outputs');
set(gcf,'color','white');
box off;

x4 = subplot(2,2,4); 
plot(x_range*1/200, Ph3_filt(x_range), 'LineWidth',1);
ylim([ylo yhi]);
title('Phase 3 outputs');
set(gcf,'color','white');
box off;

linkaxes([x1 x2 x3 x4],'xy');
%% upsampling the interplate all the phases
%upsampling 
up_factor = 4;
Ph0_filt_up = upsample(Ph0_filt,up_factor);
Ph1_filt_up = upsample(Ph1_filt,up_factor);
Ph2_filt_up = upsample(Ph2_filt,up_factor);
Ph3_filt_up = upsample(Ph3_filt,up_factor);

%linear interpolation 
Ph0_filt_up = Ph0_filt_up + circshift((Ph0_filt_up), 1) + ...
    + circshift((Ph0_filt_up), 2) + circshift((Ph0_filt_up), 3);

Ph1_filt_up = Ph1_filt_up + circshift((Ph1_filt_up), 1)*1 + ...
    + circshift((Ph1_filt_up), 2) + circshift((Ph1_filt_up), 3);

Ph2_filt_up = Ph2_filt_up + circshift((Ph2_filt_up), 1)*1 + ...
    + circshift((Ph2_filt_up), 2) + circshift((Ph2_filt_up), 3)*1;

Ph3_filt_up = Ph3_filt_up + circshift((Ph3_filt_up), 1)*1 + ...
    + circshift((Ph3_filt_up), 2) + circshift((Ph3_filt_up), 3);

%summation of the interplated outputs with phase shift 
Ph_total = Ph0_filt_up + circshift((Ph1_filt_up), 1) ...
                + circshift((Ph2_filt_up), 2) + circshift((Ph3_filt_up), 3);

%a HP filter (>50Hz) to eliminate high amplitude osciallation s for 800 Hz interplolated signal 
hpFilt_noise_800Hz = designfilt('highpassiir','FilterOrder',4, ...
         'HalfPowerFrequency',50, 'SampleRate',800);
            
Ph_total_noise = filtfilt(hpFilt_noise_800Hz, Ph_total);
noise_range = (2600:3600);
Ph_total_noise_std = std(Ph_total_noise(noise_range))

total_range = [100:12000];

figure(5);
plot([1:length(Ph_total(total_range))]*1/1,Ph_total(total_range)); hold on; 
stem(0, 5*Ph_total_noise_std); hold off; 
set(gcf,'color','white');
box off;


