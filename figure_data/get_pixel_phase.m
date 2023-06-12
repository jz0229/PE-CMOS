function [Ph0, Ph1, Ph2, Ph3, cse_mask, sample_frame] = get_pixel_phase(asic_mask, cse_image, time_range, roi_mask) 

%pick a patch and linearize the patch 
%PixNum = length(row_range)*length(col_range); 
%TimeNum = length(time_range); 

%convert to 0-3 range
cse_mask = asic_mask(:,:,1);
cse_mask(find(asic_mask <= 31))=1; 
cse_mask(find(asic_mask >= 32 & asic_mask <= 63))=2; 
cse_mask(find(asic_mask >= 64 & asic_mask <= 95))=3; 
cse_mask(find(asic_mask >= 96 & asic_mask <= 127))=4; 

%pick the patch 

%cse_mask = randi([1 4], 127, 64);

mask_patch = cse_mask.*roi_mask;
cse_patch = cse_image(:, :, time_range); 

sample_frame = mask_patch;

%%
%Phase0, find the pixels with the same phase 
[row, col, ~] = find(mask_patch == 1);  
size(row)
sig_ph = [];
for i=1:length(row)
    tmp = cse_patch(row(i),col(i),:);
    sig_ph = [sig_ph; tmp(:)'];
end
Ph0 = -1*mean(sig_ph,1); %flip the trace
clear sig_ph;

%Phase1
[row, col, ~] = find(mask_patch == 2);  
size(row)
sig_ph = [];
for i=1:length(row)
    tmp = cse_patch(row(i),col(i),:);
    sig_ph = [sig_ph; tmp(:)'];
end
Ph1 = -1*mean(sig_ph,1);
clear sig_ph;

%Phase2
[row, col, ~] = find(mask_patch == 3);  
size(row)
sig_ph = [];
for i=1:length(row)
    tmp = cse_patch(row(i),col(i),:);
    sig_ph = [sig_ph; tmp(:)'];
end
Ph2 = -1*mean(sig_ph,1);
clear sig_ph;

%Phase3
[row, col, ~] = find(mask_patch == 4);  
size(row)

sig_ph = [];
for i=1:length(row)
    tmp = cse_patch(row(i),col(i),:);
    sig_ph = [sig_ph; tmp(:)'];
end
Ph3 = -1*mean(sig_ph,1);
clear sig_ph;

