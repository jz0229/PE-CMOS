%load the pecmos data & mask 
load('./raw_data/fig3_pecmos_video.mat');
load('./raw_data/fig3_pecmos_mask.mat');

%%
%select the ROI
figure(2)
imagesc(sum(cse_video(:,:,:),3)/length(cse_video(:,:,:)), [100 200]); colormap(gray); 
set(gcf,'color','white');
box off;
cell_roi = roipoly; 

%%
time_range = 1:1800;
[Ph0, Ph1, Ph2, Ph3, cse_mask, sample_frame] = get_pixel_phase(cse_mask(:,:,1), cse_video, time_range, cell_roi);

%% 
% interpolation 
bpFilt = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',0.05,'HalfPowerFrequency2',90, 'SampleRate',200);


Ph0_filt =  filtfilt(bpFilt, Ph0);
Ph1_filt =  filtfilt(bpFilt, Ph1);
Ph2_filt =  filtfilt(bpFilt, Ph2);
Ph3_filt =  filtfilt(bpFilt, Ph3);

up_factor = 4;
Ph0_filt_up = upsample(Ph0_filt,up_factor);
Ph1_filt_up = upsample(Ph1_filt,up_factor);
Ph2_filt_up = upsample(Ph2_filt,up_factor);
Ph3_filt_up = upsample(Ph3_filt,up_factor);


Ph0_filt_up = Ph0_filt_up + circshift((Ph0_filt_up), 1)*1 + ...
    + circshift((Ph0_filt_up), 2)*1 + circshift((Ph0_filt_up), 3)*0.7;

Ph1_filt_up = Ph1_filt_up + circshift((Ph1_filt_up), 1)*1 + ...
    + circshift((Ph1_filt_up), 2)*1 + circshift((Ph1_filt_up), 3)*0.7;

Ph2_filt_up = Ph2_filt_up + circshift((Ph2_filt_up), 1)*1 + ...
    + circshift((Ph2_filt_up), 2)*1 + circshift((Ph2_filt_up), 3)*0.7;

Ph3_filt_up = Ph3_filt_up + circshift((Ph3_filt_up), 1)*1 + ...
    + circshift((Ph3_filt_up), 2)*1 + circshift((Ph3_filt_up), 3)*0.7;

Ph_total = Ph0_filt_up + circshift((Ph1_filt_up), 1) ...
                + circshift((Ph2_filt_up), 2) + circshift((Ph3_filt_up), 3);

figure(5)
%subplot(2,1,1);
plot(Ph_total(500:end));
title('pecmos time series @ 800Hz')
