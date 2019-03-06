function [dist] = getSiftFv_FV_Distance(im1, im2, A, gmm)

im_mat1 = im1{1, 1};
im_gray_single1 = single(rgb2gray(im_mat1));
h = fspecial('gaussian', 3, 1.5);
% smoothed for dense sift
im1_1 = imfilter(im_gray_single1, h);
% sift
[~, sift2_1] = vl_dsift(im1_1, 'step', 2, 'size', 3);
x1 = getSiftFv_FV(sift2_1, A, gmm);

im_mat2 = im2{1, 1};
im_gray_single2 = single(rgb2gray(im_mat2));
% smoothed for dense sift
im2_1 = imfilter(im_gray_single2, h);
% sift
[~, sift2_2] = vl_dsift(im2_1, 'step', 2, 'size', 3);
x2 = getSiftFv_FV(sift2_2, A, gmm);

dist = pdist2(x1', x2'); 

end

