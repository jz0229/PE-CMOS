function [y_520Hz, y_260Hz, y_130Hz, y_65Hz] = offset_correction(x_520Hz, x_260Hz, x_130Hz, x_65Hz)

% correct for temporal fixed pattern offset
bpFilt = designfilt('bandpassiir','FilterOrder',2, ...
         'HalfPowerFrequency1',0.01,'HalfPowerFrequency2',0.9);

%520 Hz
x_520_p1_filt = filtfilt(bpFilt, x_520Hz(1:8:end));     
x_520_p2_filt = filtfilt(bpFilt, x_520Hz(2:8:end));      
x_520_p3_filt = filtfilt(bpFilt, x_520Hz(3:8:end));      
x_520_p4_filt = filtfilt(bpFilt, x_520Hz(4:8:end));      
x_520_p5_filt = filtfilt(bpFilt, x_520Hz(5:8:end));      
x_520_p6_filt = filtfilt(bpFilt, x_520Hz(6:8:end));      
x_520_p7_filt = filtfilt(bpFilt, x_520Hz(7:8:end));      
x_520_p8_filt = filtfilt(bpFilt, x_520Hz(8:8:end));      

up_factor = 8;
x_520_p1_filt_up = upsample(x_520_p1_filt,up_factor);
x_520_p2_filt_up = upsample(x_520_p2_filt,up_factor);
x_520_p3_filt_up = upsample(x_520_p3_filt,up_factor);
x_520_p4_filt_up = upsample(x_520_p4_filt,up_factor);
x_520_p5_filt_up = upsample(x_520_p5_filt,up_factor);
x_520_p6_filt_up = upsample(x_520_p6_filt,up_factor);
x_520_p7_filt_up = upsample(x_520_p7_filt,up_factor);
x_520_p8_filt_up = upsample(x_520_p8_filt,up_factor);

y_520Hz = x_520_p1_filt_up + circshift(x_520_p2_filt_up, 1) + circshift(x_520_p3_filt_up, 2)  ...
                + circshift(x_520_p4_filt_up, 3) + circshift(x_520_p5_filt_up, 4) ...
                + circshift(x_520_p6_filt_up, 5) + circshift(x_520_p7_filt_up, 6) + ... 
                  circshift(x_520_p8_filt_up, 7);
%260 Hz
x_260_p1_filt = filtfilt(bpFilt, x_260Hz(1:4:end));    
x_260_p2_filt = filtfilt(bpFilt, x_260Hz(2:4:end));  
x_260_p3_filt = filtfilt(bpFilt, x_260Hz(3:4:end));    
x_260_p4_filt = filtfilt(bpFilt, x_260Hz(4:4:end));  

up_factor = 4;
x_260_p1_filt_up = upsample(x_260_p1_filt,up_factor);
x_260_p2_filt_up = upsample(x_260_p2_filt,up_factor);
x_260_p3_filt_up = upsample(x_260_p3_filt,up_factor);
x_260_p4_filt_up = upsample(x_260_p4_filt,up_factor);

y_260Hz = x_260_p1_filt_up + circshift(x_260_p2_filt_up, 1) ...
                + circshift(x_260_p3_filt_up, 2) + circshift(x_260_p4_filt_up, 3);
            
%130 Hz
x_130_p1_filt = filtfilt(bpFilt, x_130Hz(1:2:end));    
x_130_p2_filt = filtfilt(bpFilt, x_130Hz(2:2:end));

up_factor = 2;
x_130_p1_filt_up = upsample(x_130_p1_filt,up_factor);
x_130_p2_filt_up = upsample(x_130_p2_filt,up_factor);

y_130Hz = x_130_p1_filt_up + circshift(x_130_p2_filt_up, 1);

%65 Hz
y_65Hz = filtfilt(bpFilt, x_65Hz);
