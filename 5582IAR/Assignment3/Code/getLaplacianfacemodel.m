function [A2, S] = getLaplacianfacemodel(faces, A0, ids)

% load('faces_ids_new_train_test.mat');
% [A0, ~, lat]=pca(train_faces); 


train_faces = faces;
train_label = ids;

path(path, 'LPP');

n_face = 1000; 
all_im = length(train_faces);
im_s = all_im - n_face;

new_label = train_label(im_s:all_im);
% new_label(1493:1501) = 418;
new_faces = train_faces(im_s:all_im,:);

%LPP
n_subj = length(unique(train_label(im_s:all_im)));

% eigenface 
kd=32; 
eigenface = new_faces*A0(:,1:kd); 
eigen_dist = pdist2(eigenface, eigenface);

% LPP - compute affinity
% heat kernel size
mdist = mean(eigen_dist(:)); 
h = -log(50)/mdist; 
S1 = exp(-h*eigen_dist); 

figure(40);
subplot(2,2,1); imagesc(eigen_dist); colormap('gray'); title('d(x_i, d_j)');
subplot(2,2,2); imagesc(S1); colormap('gray'); title('Affinity'); 

%subplot(2,2,3); grid on; hold on; [h_aff, v_aff]=hist(S(:), 40); plot(v_aff, h_aff, '.-'); 
% utilize supervised info
id_dist = pdist2(new_label, new_label);
id_dist_map = pdist2(train_label, train_label);
subplot(2,2,3); imagesc(id_dist_map); title('Label distance');
S2=S1; S2(find(id_dist~=0)) = 0; S=S2;
subplot(2,2,4); imagesc(S2); colormap('gray'); title('Affinity-supervised');  

% laplacian face
lpp_opt.PCARatio = 1; 
[A2, ~]=LPP(S2, lpp_opt, eigenface); 

% eigface = eye(400)*A0(:,1:kd);
% lapface = eye(400)*A0(:,1:kd)*A2; 
% for k=1:4
%    figure(41);
%    subplot(2,4,k); imagesc(reshape(eigface(:,k),[20, 20])); colormap('gray');
%    title(sprintf('eigf_%d', k)); 
%    subplot(2,4,k+4); imagesc(reshape(lapface(:,k),[20, 20])); colormap('gray');
%    title(sprintf('lapf_%d', k)); 
% end


x2 = eigenface*A2; 
LPP_dist = pdist2(x2, x2);

new_a = length(LPP_dist);
new_s = new_a - 8;

% figure(43); grid on; hold on;
% % for subj=1
% d0_eigen = eigen_dist(new_s:new_a,new_s:new_a); 
% d1_eigen=eigen_dist(new_s:new_a, 1:(new_s-1));
% [tp, fp, tn, fn]= getPrecisionRecall(d0_eigen(:), d1_eigen(:), 60); 
% plot(fp./(tn+fp), tp./(tp+fn), '.-k', 'DisplayName', 'Eigenface kd=32');
% 
% d0_lpp = LPP_dist(new_s:new_a,new_s:new_a); 
% d1_lpp=LPP_dist(new_s:new_a, 1:(new_s-1));
% [tp, fp, tn, fn]= getPrecisionRecall(d0_lpp(:), d1_lpp(:), 60); 
% plot(fp./(tn+fp), tp./(tp+fn), '.-r', 'DisplayName', 'Laplacian kd=32');
% xlabel('FPR'); ylabel('TPR'); title(sprintf('Eigen vs Laplacian face recog: %d people, %d faces',n_subj, n_face));
% legend('Eigen kd=32', 'Laplacian kd=32');
kernelSize = [0.001, 0.5, 3, 10, 50];
color = ["b", "r", "g", "c", "m"];
for i = 1:5
    h_n = -log(kernelSize(i))/mdist; 
    S_n = exp(-h_n*eigen_dist); 
    S_n(find(id_dist~=0)) = 0;
    [A_n, ~]=LPP(S_n, lpp_opt, eigenface); 
    x_n = eigenface*A_n; 
    LPP_dist_n = pdist2(x_n, x_n);
    
    figure(44); grid on; hold on;
    d0_lpp = LPP_dist_n(new_s:new_a,new_s:new_a); 
    d1_lpp=LPP_dist_n(new_s:new_a, 1:(new_s-1));
    [tp, fp, tn, fn]= getPrecisionRecall(d0_lpp(:), d1_lpp(:), 60); 
    plot(fp./(tn+fp), tp./(tp+fn), color(i));
    hold on;
end
xlabel('FPR'); ylabel('TPR'); title(sprintf('Different Kernel Size for Affinity Matrix'));
legend('Kernel Size: 0.5', 'Kernel Size: 0.0001', 'Kernel Size: 3', 'Kernel Size: 10', 'Kernel Size: 50');


end

