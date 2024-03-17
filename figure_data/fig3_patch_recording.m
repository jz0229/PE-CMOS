%%
load('fig3_patch.mat')

figure(1); 
plot([1:length(patch_recording)]*0.1,patch_recording)
xlabel('Time (ms)')
ylabel('Voltage (mV)')