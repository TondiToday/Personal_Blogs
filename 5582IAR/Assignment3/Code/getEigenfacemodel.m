function [A0, eigv] = getEigenfacemodel(faces)

[A1, ~, lat]=pca(faces); 
A0 = A1;
eigv = lat;

%% 2 plot the Eigenface basis, and corresponding eigen values
%%%%%%%=plot Eigenface=%%%%%%%
h=20; w=20;
% figure(20); 
% subplot(1,2,1); grid on; hold on; plot(lat(1:16), '.-'); 
% title(sprintf('Eigen Values'));
% f_eng=lat(1:16).*lat(1:16); 
% subplot(1,2,2); grid on; hold on; plot(cumsum(f_eng)/sum(f_eng), '.-'); 
% title(sprintf('Eigen Values'));
% 
% figure(21); 
% for k=1:8
%     subplot(2,4,k); colormap('gray'); imagesc(reshape(A1(:,(k)), [h, w]));
%     title(sprintf('eigenface_%d', k));
% end
%%%%%%%%%%%%%%%%%%%%%%%%

%% 3 explain if you keep 8 dimensions, how much information/energy is lost ?
% 16 dimensions and 1000 faces
nface=1000;

all_images = length(faces);
image_start = all_images - nface;


kd_16=32;
x_16=faces * A1(:, 1:kd_16); 
f_dist_16 = pdist2(x_16(image_start:all_images,:), x_16(image_start:all_images,:));

% and 8 dimensions
kd_8=8;
x_8=faces * A1(:, 1:kd_8); 
f_dist_8 = pdist2(x_8(image_start:all_images,:), x_8(image_start:all_images,:));

% figure(22);  
% subplot(1,2,1); imagesc(f_dist_8); colormap('gray');
% subplot(1,2,2); imagesc(f_dist_16); colormap('gray');
% title(sprintf('dist, left - 8 kd, right - 16 kd, 1000 faces'));

new_all_images = length(f_dist_8);
new_image_start = new_all_images - 8;

d0_8 = f_dist_8(new_image_start:new_all_images,new_image_start:new_all_images); d1_8=f_dist_8(1:(new_image_start-1), new_image_start:new_all_images);
[tp8, fp8, tn8, fn8]= getPrecisionRecall(d0_8(:), d1_8(:), 50); 

d0_16 = f_dist_16(new_image_start:new_all_images,new_image_start:new_all_images); d1_16=f_dist_16(1:(new_image_start-1), new_image_start:new_all_images);
[tp_16, fp_16, tn_16, fn_16]= getPrecisionRecall(d0_16(:), d1_16(:), 50); 

figure(23); hold  on; grid on; 
plot(fp8./(tn8+fp8), tp8./(tp8+fn8), '.-b', 'DisplayName', 'tpr-fpr color, data set');
hold on
plot(fp_16./(tn_16+fp_16), tp_16./(tp_16+fn_16), '.-r', 'DisplayName', 'tpr-fpr color, data set');
xlabel('FPR'); ylabel('TPR'); title('EIGface Recog 1000 images');
legend('kd=8','kd=16')

end

