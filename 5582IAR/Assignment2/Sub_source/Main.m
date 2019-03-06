clear
load('data_100.mat');
%% load Tiny ImageNet data set
% get labels
% cat_list = dir('tiny_data/tiny-imagenet-200/train');
% n_cat = 10; n_img = 100; n = 0; 
% % load images
% for k = 1:n_cat
%     ids(k, :) = cat_list(k + 2).name;
%     flist = dir(sprintf('tiny_data/tiny-imagenet-200/train/%s/images/*.JPEG', ids(k,:)));
%     for j=1:n_img
%         n=n+1; ims{n} = imread(sprintf('tiny_data/tiny-imagenet-200/train/%s/images/%s', ids(k,:), flist(j+2).name));
%     end
% end
% % associated labels
% ids = kron([1:n_cat], ones(1,n_img))';

%% [1] pooled (2x2) color histogram to represent images provide feature extraction and distance computing
% K-means training
% function kmean_entry64
load('kmeans_entry64_ran5.mat');
codebook = bins; % bins is the centers I trained for HSV
pooling = [2, 2];
% % Calculate random image pooled HSV histogram
im = ims(randi(100));
h = getPooledHSVHistogram(im, codebook, pooling);
% 
% % Calculate two random image pooled HSV histogram
ran_i = randi(100, [2, 1]);
% im1 = ims(ran_i(1)); im2 = ims(ran_i(2));
im1 = ims(2); im2 = ims(1);
dist = getPooledHSVDistance(im1, im2);

%% [2] Compute HoG feature for image, use average. Use block size of 8 pixel and 2x2 cell structure. 
% #get  image HOG
hog = getImHog(im);

% #get image hog distance
hog_dist = gethogDist(im1, im2);

%% [3] For each image compute its dense SIFT and use Fisher Vector to aggregate. 
% for one image
% load hw2-A-gmm-km.mat;
% im_mat = im{1, 1};
% im_gray_single = single(rgb2gray(im_mat));
% 
% h0 = fspecial('gaussian', 3, 1.5);
% % smoothed for dense sift
% im0 = imfilter(im_gray_single, h0);
% % sift
% [~, sift2] = vl_dsift(im0, 'step', 2, 'size', 3);
% d = getSiftFv_FV(sift2, A, gmm);

% For all images
load hw2-A-gmm-km.mat;
d_all = [];
for i = 1:100
    im = ims(i);
    im_mat = im{1, 1};
    im_gray_single = single(rgb2gray(im_mat));

    h0 = fspecial('gaussian', 3, 1.5);
    % smoothed for dense sift
    im0 = imfilter(im_gray_single, h0);
    % sift
    [~, sift2] = vl_dsift(im0, 'step', 2, 'size', 3);
    d = getSiftFv_FV(sift2, A, gmm);
    d_all = [d_all, d];
end

%% [4] For the 2x2 pooled HSV feature, HoG feature, Fisher Vector aggregated dense SIFT feature, 
% please compute the n x n distance map between all image pairs, and plot their TPR-FPR separately (hint: use vl_roc)
%% 4.1 Distance of HSV dist pairs:
% hsv_raw = [];
% for i = 1:100
%     hsv_colum = [];
%     for k = 1:100
%         hsv_dist = getPooledHSVDistance(ims(i), ims(k));
%         hsv_colum = [hsv_colum; hsv_dist];
%     end
%     hsv_raw = [hsv_raw, hsv_colum];
% end
% save hsv_dist_100_k64.mat hsv_raw

%% 4.2 Distance of HOG dist pairs:
% hog_raw = [];
% for i = 1:100
%     hog_colum = [];
%     for k = 1:100
%         hog_dist = gethogDist(ims(i), ims(k));
%         hog_colum = [hog_colum; hog_dist];
%     end
%     hog_raw = [hog_raw, hog_colum];
% end
% save hog_dist_100_dt36.mat hog_raw

%% 4.3 Distance of Fisher Vector aggregated dense SIFT feature dist pairs:
% load hw2-A-gmm-km.mat;
% Fisher_dsift_raw = [];
% for i = 1:100
%     Fisher_dsift_colum = [];
%     for k = 1:100
%         Fisher_dsift_dist = getSiftFv_FV_Distance(ims(i), ims(k), A, gmm);
%         Fisher_dsift_colum = [Fisher_dsift_colum; Fisher_dsift_dist];
%     end
%     Fisher_dsift_raw = [Fisher_dsift_raw, Fisher_dsift_colum];
% end
% save Fisher_dsift_100_New.mat Fisher_dsift_raw

%% plot the dist: 
load hsv_dist_100_k64.mat;
load hog_dist_100_dt36.mat;
load Fisher_dsift_100_New.mat

subplot(1, 3, 1); imagesc(hsv_raw); title('Pooled Histogram Dist');
subplot(1, 3, 2); imagesc(hog_raw); title('Hog Dist');
subplot(1, 3, 3); imagesc(Fisher_dsift_raw); title('Dense Sift Fv Dist');
%% plot TPR-FPR:

%% 4.1.1 HSV Performance
labels_hsv = ones(1, 100);
scores_hsv = zeros(1, 100);
for i =1:10
    for k = (10*i-9):10*i
    hsv_raw_1 = hsv_raw;
    hsv_raw_1(k, k) = max(hsv_raw_1(:, k)); 
    [value, index] = min(hsv_raw_1(:, k));
    scores_hsv(1, k) = value;
    if index <= 10*(i-1) || index > 10*i
        labels_hsv(1, k) = -1;
    end
    end
end

%% 4.2.1 HOG Performance
labels_hog = ones(1, 100);
scores_hog = zeros(1, 100);
for i =1:10
    for k = (10*i-9):10*i
    hog_raw_1 = hog_raw;
    hog_raw_1(k, k) = max(hog_raw_1(:, k)); 
    [value, index] = min(hog_raw_1(:, k));
    scores_hog(1, k) = value;
    if index <= 10*(i-1) || index > 10*i
        labels_hog(1, k) = -1;
    end
    end
end

%% 4.3.1 Distance of Fisher Vector aggregated dense SIFT feature Performance
labels_Fisher_dsift = ones(1, 100);
scores_Fisher_dsift = zeros(1, 100);
for i =1:10
    for k = (10*i-9):10*i
    Fisher_dsift_raw_1 = Fisher_dsift_raw;
    Fisher_dsift_raw_1(k, k) = max(Fisher_dsift_raw_1(:, k)); 
    [value, index] = min(Fisher_dsift_raw_1(:, k));
    scores_Fisher_dsift(1, k) = value;
    if index <= 10*(i-1) || index > 10*i
        labels_Fisher_dsift(1, k) = -1;
    end
    end
end
figure(2);
subplot(2, 3, 1); imagesc(hsv_raw); title('Pooled Histogram Dist');
subplot(2, 3, 2); imagesc(hog_raw); title('Hog Dist');
subplot(2, 3, 3); imagesc(Fisher_dsift_raw); title('Dense Sift Fv Dist');
subplot(2, 3, 4); vl_roc(labels_hsv, scores_hsv);
subplot(2, 3, 5); vl_roc(labels_hog, scores_hog);
subplot(2, 3, 6); vl_roc(labels_Fisher_dsift, scores_Fisher_dsift);
%% [5] Fuse the distances from different features, and try your own way of finding the best mixing parameters

mean_hog = mean2(hog_raw);
mean_hsv = mean2(hsv_raw);
mean_fis = mean2(Fisher_dsift_raw);
hog_raw_new = hog_raw / mean_hog;
hsv_raw_new = hsv_raw / mean_hsv;
Fisher_dsift_raw_new = Fisher_dsift_raw / mean_fis;

[~, ~, p_hsv]= vl_roc(labels_hsv, scores_hsv);
[~, ~, p_hog]= vl_roc(labels_hog, scores_hog);
[~, ~, p_fis]= vl_roc(labels_Fisher_dsift, scores_Fisher_dsift);

hsv_auc = p_hsv.auc - 0.5;
hog_auc = p_hog.auc - 0.5;
fis_auc = p_fis.auc - 0.5;
w1 = (hsv_auc / (hsv_auc+hog_auc + fis_auc));
w2 = (hog_auc / (hsv_auc+hog_auc + fis_auc));
w3 = (fis_auc / (hsv_auc+hog_auc + fis_auc));
w = (w1-w2) / w3;
Fuse_raw = w1*hsv_raw_new + w2*hog_raw_new + w3*Fisher_dsift_raw_new;

Label_Fuse = ones(1, 100);
Scores_Fuse = zeros(1, 100);
for i =1:10
    for k = (10*i-9):10*i
    Fuse_raw_1 = Fuse_raw;
    Fuse_raw_1(k, k) = max(Fuse_raw_1(:, k)); 
    [value, index] = min(Fuse_raw_1(:, k));
    Scores_Fuse(1, k) = value;
    if index <= 10*(i-1) || index > 10*i
        Label_Fuse(1, k) = -1;
    end
    end
end

% Ground Truth
All_labels = [];
for i =1:100
    for k = 1:100
        All_labels(i, k) = ids(i) - ids(k);
        if All_labels(i, k) < 0
            All_labels(i, k) = -All_labels(i, k);
        end
    end
end

figure(randi(100))
subplot(2, 4, 1); imagesc(hsv_raw); title('Pooled Histogram Dist');
subplot(2, 4, 2); imagesc(hog_raw); title('Hog Dist');
subplot(2, 4, 3); imagesc(Fisher_dsift_raw); title('Dense Sift Fv Dist');
subplot(2, 4, 4); imagesc(All_labels); title('GND truth');
subplot(2, 4, 5); vl_roc(labels_hsv, scores_hsv);
subplot(2, 4, 6); vl_roc(labels_hog, scores_hog);
subplot(2, 4, 7); vl_roc(labels_Fisher_dsift, scores_Fisher_dsift);
subplot(2, 4, 8); vl_roc(Label_Fuse, Scores_Fuse);
