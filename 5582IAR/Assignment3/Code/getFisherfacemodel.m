function [A1] = getFisherfacemodel(faces, A0, ids)
path(path, 'LPP');
%% Fisherface
n_face = 1000; 
n_subj = length(unique(ids(1:n_face)));

all_num = length(faces);
im_s = all_num - n_face;

%eigenface kd
kd = 32;
opt.Fisherface = 1; 
% [A1, ~]=LDA(ids(1:n_face), opt, faces(1:n_face,:)*A0(:,1:kd));
[A1, ~]=getLDA(faces(im_s:all_num,:)*A0(:,1:kd), ids(im_s:all_num));

% eigenface
x1 = faces*A0(:,1:kd); 
f_dist1 = pdist2(x1(im_s:all_num,:), x1(im_s:all_num,:));
% fisherface
x2 = faces*A0(:,1:kd)*A1;   
f_dist2 = pdist2(x2(im_s:all_num,:), x2(im_s:all_num,:));

% Avoid singularity in convariance matrices
eigface = eye(400)*A0(:,1:kd);
fishface = eye(400)*A0(:,1:kd)*A1; 
for k=1:4
   figure(31);
   subplot(2,4,k); imagesc(reshape(eigface(:,k),[20, 20])); colormap('gray');
   title(sprintf('Eigf_%d', k)); 
   subplot(2,4,k+4); imagesc(reshape(fishface(:,k),[20, 20])); colormap('gray');
   title(sprintf('Fisherf_%d', k)); 
end

n_all_im = length(f_dist1);
n_im_s = n_all_im - 8;

figure(33); grid on; hold on;
% for subj=1
d0 = f_dist1(n_im_s:n_all_im,n_im_s:n_all_im); d1=f_dist1(1:(n_im_s-1), n_im_s:n_all_im);
[tp, fp, tn, fn]= getPrecisionRecall(d0(:), d1(:), 50); 
plot(fp./(tn+fp), tp./(tp+fn), '.-k', 'DisplayName', 'eigenface kd=32');
hold on
d0 = f_dist2(n_im_s:n_all_im,n_im_s:n_all_im); d1=f_dist2(1:(n_im_s-1), n_im_s:n_all_im);
[tp, fp, tn, fn]= getPrecisionRecall(d0(:), d1(:), 50); 
plot(fp./(tn+fp), tp./(tp+fn), '.-r', 'DisplayName', 'fisher kd=32');

xlabel('FPR'); ylabel('TPR'); title(sprintf('Eigen vs Fisher Face Recog: %d people, %d faces',n_subj, n_face));
legend('Eigen kd=32', 'Fisher kd=32');

end

